package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// TLP RX Engine with Extended Data Path and I/O Support
// ============================================================
// Features:
// - Streaming data path for large payloads
// - I/O request handling with completion generation
// - Extended buffer support (up to 64 DWORDs)
// - Parse error detection and recovery
// ============================================================
class TlpRxEngine(maxPayloadBytes: Int = 256) extends Component {

  val maxPayloadDw = maxPayloadBytes / 4

  val io = new Bundle {
    // From Data Link Layer
    val tlpIn      = slave  Stream(Bits(32 bits))

    // To Transaction Layer handlers
    val memReq     = master Stream(TlpStreamPacket())   // Memory Rd/Wr Requests
    val cfgReq     = master Stream(TlpStreamPacket())   // Config Rd/Wr Requests
    val cplIn      = master Stream(TlpStreamPacket())   // Completions (for DMA)
    val ioReq      = master Stream(TlpStreamPacket())   // I/O Requests

    // Streaming data output (for large payloads)
    val memDataOut = master Stream(TlpDataStream())     // Streaming data
    val memDataStart = out Bool()                        // Start of new packet

    // Status
    val parseErr   = out Bool()
    val overflow   = out Bool()                          // Payload exceeded buffer
  }

  // -------------------------------------------------------
  // RX State Machine
  // -------------------------------------------------------
  object RxState extends SpinalEnum {
    val IDLE, HDR2, HDR3, HDR4, DATA, DATA_STREAM, EMIT, DISCARD = newElement()
  }

  val state      = Reg(RxState()) init(RxState.IDLE)
  val pkt        = Reg(TlpStreamPacket())
  val dataIdx    = Reg(UInt(11 bits)) init(0)
  val is4DW      = Reg(Bool()) init(False)
  val hasData    = Reg(Bool()) init(False)
  val parseErrR  = Reg(Bool()) init(False)
  val overflowR  = Reg(Bool()) init(False)

  io.parseErr := parseErrR
  io.overflow := overflowR

  // Output routing registers
  val outValid   = Reg(Bool()) init(False)
  val outChannel = Reg(UInt(2 bits)) init(0)  // 0=mem,1=cfg,2=cpl,3=io
  val outPkt     = Reg(TlpStreamPacket())

  // Streaming data path
  val streamValid = Reg(Bool()) init(False)
  val streamData  = Reg(Bits(32 bits))
  val streamLast  = Reg(Bool()) init(False)

  io.memDataOut.valid := streamValid
  io.memDataOut.data  := streamData
  io.memDataOut.last  := streamLast
  io.memDataOut.byteEn := 0xF
  io.memDataStart := False

  // Default outputs: all invalid
  io.memReq.valid   := False
  io.cfgReq.valid   := False
  io.cplIn.valid    := False
  io.ioReq.valid    := False
  io.memReq.payload := outPkt
  io.cfgReq.payload := outPkt
  io.cplIn.payload  := outPkt
  io.ioReq.payload  := outPkt

  // Drain output when valid
  when(outValid) {
    switch(outChannel) {
      is(0) {
        io.memReq.valid := True
        when(io.memReq.ready) { outValid := False }
      }
      is(1) {
        io.cfgReq.valid := True
        when(io.cfgReq.ready) { outValid := False }
      }
      is(2) {
        io.cplIn.valid := True
        when(io.cplIn.ready) { outValid := False }
      }
      is(3) {
        io.ioReq.valid := True
        when(io.ioReq.ready) { outValid := False }
      }
    }
  }

  // Accept input only when output is not pending
  io.tlpIn.ready := !outValid && state =/= RxState.EMIT && state =/= RxState.DISCARD

  // -------------------------------------------------------
  // Parse incoming DWORDs
  // -------------------------------------------------------
  switch(state) {
    is(RxState.IDLE) {
      when(io.tlpIn.fire) {
        val dw    = io.tlpIn.payload
        val fmt   = dw(31 downto 29)
        val tcode = dw(28 downto 24)

        hasData      := fmt(1)
        is4DW        := fmt(0)
        pkt.length   := dw(9 downto 0).asUInt
        pkt.tc       := dw(22 downto 20).asUInt
        pkt.attr     := dw(13 downto 12)
        pkt.dataValid := 0
        pkt.data(0) := B(0, 32 bits)
        pkt.data(1) := B(0, 32 bits)
        pkt.data(2) := B(0, 32 bits)
        pkt.data(3) := B(0, 32 bits)

        parseErrR := False
        overflowR := False

        switch(tcode) {
          is(B"5'b00000") {
            pkt.tlpType := fmt(1) ? TlpType.MEM_WR | TlpType.MEM_RD
          }
          is(B"5'b00010") {
            pkt.tlpType := fmt(1) ? TlpType.IO_WR | TlpType.IO_RD
          }
          is(B"5'b00100") {
            pkt.tlpType := fmt(1) ? TlpType.CFG_WR0 | TlpType.CFG_RD0
          }
          is(B"5'b00101") {
            pkt.tlpType := fmt(1) ? TlpType.CFG_WR1 | TlpType.CFG_RD1
          }
          is(B"5'b01010") {
            pkt.tlpType := fmt(1) ? TlpType.CPL_D | TlpType.CPL
          }
          is(B"5'b10000") {
            pkt.tlpType := fmt(1) ? TlpType.MSG_D | TlpType.MSG
          }
          default {
            pkt.tlpType := TlpType.INVALID
            parseErrR   := True
          }
        }

        // Check for invalid length (would overflow dataIdx)
        when(pkt.length > 64 && hasData) {
          overflowR := True
        }

        // On parse error or overflow, go to DISCARD state
        when(parseErrR || overflowR) {
          state := RxState.DISCARD
        } otherwise {
          state := RxState.HDR2
        }
      }
    }

    is(RxState.HDR2) {
      when(io.tlpIn.fire) {
        // Skip processing if in error state
        when(!parseErrR && !overflowR) {
          val dw = io.tlpIn.payload
          pkt.reqId   := dw(31 downto 16).asUInt
          pkt.tag     := dw(15 downto  8).asUInt
          pkt.lastBe  := dw( 7 downto  4)
          pkt.firstBe := dw( 3 downto  0)
        }
        state       := RxState.HDR3
      }
    }

    is(RxState.HDR3) {
      when(io.tlpIn.fire) {
        when(is4DW) {
          pkt.addr(63 downto 32) := io.tlpIn.payload.asUInt
          state := RxState.HDR4
        } otherwise {
          pkt.addr(31 downto 0)  := io.tlpIn.payload.asUInt
          pkt.addr(63 downto 32) := 0
          when(hasData) {
            dataIdx := 0
            // Use streaming for large payloads
            when(pkt.length > 4) {
              state := RxState.DATA_STREAM
              io.memDataStart := True
            } otherwise {
              state := RxState.DATA
            }
          } otherwise {
            state := RxState.EMIT
          }
        }
      }
    }

    is(RxState.HDR4) {
      when(io.tlpIn.fire) {
        pkt.addr(31 downto 0) := io.tlpIn.payload.asUInt
        when(hasData) {
          dataIdx := 0
          when(pkt.length > 4) {
            state := RxState.DATA_STREAM
            io.memDataStart := True
          } otherwise {
            state := RxState.DATA
          }
        } otherwise {
          state := RxState.EMIT
        }
      }
    }

    // Small data path: buffer up to 4 DWORDs inline
    is(RxState.DATA) {
      when(io.tlpIn.fire) {
        val totalDw     = Mux(pkt.length === 0, U(1024, 11 bits), pkt.length.resize(11))
        val nextDataIdx = dataIdx + 1

        when(dataIdx < 4) {
          pkt.data(dataIdx.resized) := io.tlpIn.payload
        }
        pkt.dataValid := Mux(nextDataIdx > 4, U(4, 3 bits), nextDataIdx.resize(3))

        when(dataIdx === (totalDw - 1)) {
          state := RxState.EMIT
        } otherwise {
          dataIdx := nextDataIdx
        }
      }
    }

    // Streaming data path: for large payloads
    is(RxState.DATA_STREAM) {
      val totalDw = Mux(pkt.length === 0, U(1024, 11 bits), pkt.length.resize(11))

      streamValid := io.tlpIn.valid
      streamData  := io.tlpIn.payload
      streamLast  := (dataIdx === (totalDw - 1))

      // Also store first 4 DWORDs in inline buffer for address decode
      when(dataIdx < 4) {
        pkt.data(dataIdx.resized) := io.tlpIn.payload
      }
      pkt.dataValid := Mux(dataIdx >= 3, U(4, 3 bits), (dataIdx + 1).resize(3))

      when(io.tlpIn.fire) {
        when(streamLast) {
          state := RxState.EMIT
        } otherwise {
          dataIdx := dataIdx + 1
        }
      }
    }

    is(RxState.EMIT) {
      outPkt     := pkt
      outChannel := classifyChannel(pkt.tlpType)
      outValid   := True
      streamValid := False
      state      := RxState.IDLE
    }

    is(RxState.DISCARD) {
      // Accept all remaining DWORDs of the errored packet
      io.tlpIn.ready := True
      streamValid := False
      // Wait until we've consumed all data or packet ends
      when(io.tlpIn.fire) {
        when(!hasData || dataIdx >= pkt.length - 1) {
          state := RxState.IDLE
          dataIdx := 0
        } otherwise {
          dataIdx := dataIdx + 1
        }
      }
    }
  }

  // -------------------------------------------------------
  // Channel Classification Helper
  // -------------------------------------------------------
  def classifyChannel(t: TlpType.C): UInt = {
    val ch = UInt(2 bits)
    ch := 3  // default = ioReq
    when(t === TlpType.MEM_RD || t === TlpType.MEM_WR) { ch := 0 }
    when(t === TlpType.CFG_RD0 || t === TlpType.CFG_WR0 ||
         t === TlpType.CFG_RD1 || t === TlpType.CFG_WR1) { ch := 1 }
    when(t === TlpType.CPL || t === TlpType.CPL_D) { ch := 2 }
    ch
  }
}

// ============================================================
// I/O Request Handler with Completion Generation
// ============================================================
class IoRequestHandler extends Component {
  val io = new Bundle {
    // I/O Request input
    val ioReq    = slave  Stream(TlpStreamPacket())

    // Completion output
    val cplOut   = master Stream(TlpStreamPacket())

    // Register interface
    val regAddr  = out UInt(32 bits)
    val regWrData = out Bits(32 bits)
    val regRdData = in  Bits(32 bits)
    val regWrEn  = out Bool()
    val regRdEn  = out Bool()
    val regWidth = in  UInt(2 bits)  // 0=byte, 1=word, 2=dword

    // Status
    val ioErr    = out Bool()
  }

  // I/O completion status
  object IoState extends SpinalEnum {
    val IDLE, PROCESS, RESPOND = newElement()
  }

  val state = Reg(IoState()) init(IoState.IDLE)
  val reqPkt = Reg(TlpStreamPacket())
  val respPkt = Reg(TlpStreamPacket())

  // Initialize respPkt fields to avoid UNASSIGNED REGISTER warnings
  respPkt.tlpType := TlpType.CPL
  respPkt.reqId := 0
  respPkt.tag := 0
  respPkt.addr := 0
  respPkt.length := 0
  respPkt.firstBe := 0
  respPkt.lastBe := 0
  respPkt.tc := 0
  respPkt.attr := 0
  for (i <- 0 until 4) respPkt.data(i) := 0
  respPkt.dataValid := 0

  // Default outputs
  io.regAddr := 0
  io.regWrData := 0
  io.regWrEn := False
  io.regRdEn := False
  io.ioErr := False

  io.cplOut.valid := False
  io.cplOut.payload := respPkt

  io.ioReq.ready := (state === IoState.IDLE)

  switch(state) {
    is(IoState.IDLE) {
      when(io.ioReq.fire) {
        reqPkt := io.ioReq.payload
        state := IoState.PROCESS
      }
    }

    is(IoState.PROCESS) {
      // Decode I/O address
      io.regAddr := reqPkt.addr(31 downto 0)

      when(reqPkt.tlpType === TlpType.IO_RD) {
        // I/O Read: generate completion with data
        io.regRdEn := True
        respPkt.tlpType := TlpType.CPL_D
        respPkt.length := 1
        respPkt.data(0) := io.regRdData
        respPkt.dataValid := 1
        state := IoState.RESPOND
      } elsewhen(reqPkt.tlpType === TlpType.IO_WR) {
        // I/O Write: generate completion without data
        io.regWrEn := True
        io.regWrData := reqPkt.data(0)
        respPkt.tlpType := TlpType.CPL
        respPkt.length := 0
        respPkt.dataValid := 0
        state := IoState.RESPOND
      } otherwise {
        // Invalid I/O request
        io.ioErr := True
        respPkt.tlpType := TlpType.CPL
        respPkt.length := 0
        respPkt.dataValid := 0
        state := IoState.RESPOND
      }

      // Set completion fields
      respPkt.reqId := 0  // Our completer ID (set by upper layer)
      respPkt.tag := reqPkt.tag
      respPkt.addr := reqPkt.reqId.resize(64)  // Requester ID as lower address
      respPkt.firstBe := reqPkt.firstBe
      respPkt.lastBe := reqPkt.lastBe
      respPkt.tc := 0
      respPkt.attr := 0
    }

    is(IoState.RESPOND) {
      io.cplOut.valid := True
      when(io.cplOut.ready) {
        state := IoState.IDLE
      }
    }
  }
}
