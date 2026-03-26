package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// TLP RX Engine
// Deserializes 32-bit DWORD stream -> TlpStreamPacket
// Classifies TLPs and routes to appropriate handlers
// ============================================================
class TlpRxEngine extends Component {

  val io = new Bundle {
    val tlpIn    = slave  Stream(Bits(32 bits))       // From Data Link Layer
    val memReq   = master Stream(TlpStreamPacket())   // Memory Rd/Wr Requests
    val cfgReq   = master Stream(TlpStreamPacket())   // Config Rd/Wr Requests
    val cplIn    = master Stream(TlpStreamPacket())   // Completions (for DMA)
    val ioReq    = master Stream(TlpStreamPacket())   // I/O Requests
    val parseErr = out Bool()                         // Parse error flag
  }

  // -------------------------------------------------------
  // RX State Machine
  // -------------------------------------------------------
  object RxState extends SpinalEnum {
    val IDLE, HDR2, HDR3, HDR4, DATA, EMIT, DISCARD = newElement()
  }

  val state      = Reg(RxState()) init(RxState.IDLE)
  val pkt        = Reg(TlpStreamPacket())
  val dataIdx    = Reg(UInt(11 bits)) init(0)
  val is4DW      = Reg(Bool()) init(False)
  val hasData    = Reg(Bool()) init(False)
  val parseErrR  = Reg(Bool()) init(False)

  io.parseErr := parseErrR

  // Output routing registers
  val outValid   = Reg(Bool()) init(False)
  val outChannel = Reg(UInt(2 bits)) init(0)  // 0=mem,1=cfg,2=cpl,3=io
  val outPkt     = Reg(TlpStreamPacket())

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

  // Accept input only when output is not pending and we are not in emit stage
  io.tlpIn.ready := !outValid && state =/= RxState.EMIT && state =/= RxState.DISCARD

  // -------------------------------------------------------
  // Parse incoming DWORDs
  // -------------------------------------------------------
  switch(state) {

    // DW0: [Fmt[2:0] | Type[4:0] | TC[2:0] | ... | Length[9:0]]
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
        for(i <- 0 until 4) pkt.data(i) := 0

        parseErrR := False
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
        state := RxState.HDR2
      }
    }

    // DW1: [ReqID[15:0] | Tag[7:0] | LastBE[3:0] | FirstBE[3:0]]
    is(RxState.HDR2) {
      when(io.tlpIn.fire) {
        val dw = io.tlpIn.payload
        pkt.reqId   := dw(31 downto 16).asUInt
        pkt.tag     := dw(15 downto  8).asUInt
        pkt.lastBe  := dw( 7 downto  4)
        pkt.firstBe := dw( 3 downto  0)
        state       := RxState.HDR3
      }
    }

    // DW2: 4DW->addr[63:32], 3DW->addr[31:0]
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
            state   := RxState.DATA
          } otherwise {
            state   := RxState.EMIT
          }
        }
      }
    }

    // DW3 (only 4DW): addr[31:0]
    is(RxState.HDR4) {
      when(io.tlpIn.fire) {
        pkt.addr(31 downto 0) := io.tlpIn.payload.asUInt
        when(hasData) {
          dataIdx := 0
          state   := RxState.DATA
        } otherwise {
          state := RxState.EMIT
        }
      }
    }

    // Data DWORDs
    is(RxState.DATA) {
      when(io.tlpIn.fire) {
        val totalDw     = Mux(pkt.length === 0, U(1024, 11 bits), pkt.length.resize(11))
        val nextDataIdx = dataIdx + 1
        val clipped     = Mux(nextDataIdx > 4, U(4, 11 bits), nextDataIdx)

        when(dataIdx < 4) {
          pkt.data(dataIdx.resized) := io.tlpIn.payload
        }
        pkt.dataValid := clipped.resize(3)

        when(dataIdx === (totalDw - 1)) {
          state := RxState.EMIT
        } otherwise {
          dataIdx := nextDataIdx
        }
      }
    }

    // Emit full packet one cycle after all packet fields are registered
    is(RxState.EMIT) {
      outPkt     := pkt
      outChannel := classifyChannel(pkt.tlpType)
      outValid   := True
      state      := RxState.IDLE
    }

    is(RxState.DISCARD) {
      io.tlpIn.ready := True
      state := RxState.IDLE
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

