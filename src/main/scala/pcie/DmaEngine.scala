package pcie

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

// ============================================================
// Scatter-Gather DMA Engine
// Supports:
//   - Host-to-Device (H2D): PCIe MRd -> local memory
//   - Device-to-Host (D2H): local memory -> PCIe MWr
// ============================================================
class DmaEngine(maxPayload: Int = 256) extends Component {

  val io = new Bundle {
    // Control interface (AXI4-Lite style, modeled with Axi4 channels)
    val ctrl   = slave(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 32, useStrb = false,
      useLock = false, useCache = false, useProt = false,
      useQos = false, useRegion = false, idWidth = 4
    )))

    // PCIe TLP interfaces
    val memWrOut = master Stream(TlpStreamPacket())   // D2H write
    val memRdOut = master Stream(TlpStreamPacket())   // H2D read request
    val cplIn    = slave  Stream(TlpStreamPacket())   // H2D completions

    // Local AXI4 master (to on-chip memory)
    val localMem = master(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 64,
      useStrb = true, idWidth = 4
    )))

    // Status
    val h2dDone    = out Bool()
    val d2hDone    = out Bool()
    val dmaErr     = out Bool()
    val busDevFunc = in UInt(16 bits)
  }

  // -------------------------------------------------------
  // Control / Status Registers
  // 0x00: Control [start(0), direction(1)]
  // 0x04: Status  [done(0), busy(1), error(2)]
  // 0x08: SrcAddrLo
  // 0x0C: SrcAddrHi
  // 0x10: DstAddrLo
  // 0x14: DstAddrHi
  // 0x18: Length(bytes)
  // -------------------------------------------------------
  val ctrlReg    = Reg(Bits(32 bits)) init(0)
  val statusReg  = Reg(Bits(32 bits)) init(0)
  val srcAddrLo  = Reg(UInt(32 bits)) init(0)
  val srcAddrHi  = Reg(UInt(32 bits)) init(0)
  val dstAddrLo  = Reg(UInt(32 bits)) init(0)
  val dstAddrHi  = Reg(UInt(32 bits)) init(0)
  val lengthReg  = Reg(UInt(32 bits)) init(0)

  // AXI4-Lite register access
  val axilAr = io.ctrl.ar
  val axilAw = io.ctrl.aw
  val axilW  = io.ctrl.w
  val axilR  = io.ctrl.r
  val axilB  = io.ctrl.b

  val rValid = Reg(Bool()) init(False)
  val rId    = Reg(cloneOf(axilAr.id)) init(0)
  val rData  = Reg(Bits(32 bits)) init(0)

  axilAr.ready := !rValid
  axilR.valid  := rValid
  axilR.id     := rId
  axilR.data   := rData
  axilR.resp   := 0
  axilR.last   := True

  when(axilAr.fire) {
    rValid := True
    rId    := axilAr.id
    switch(axilAr.addr(7 downto 2)) {
      is(0)  { rData := ctrlReg }
      is(1)  { rData := statusReg }
      is(2)  { rData := srcAddrLo.asBits }
      is(3)  { rData := srcAddrHi.asBits }
      is(4)  { rData := dstAddrLo.asBits }
      is(5)  { rData := dstAddrHi.asBits }
      is(6)  { rData := lengthReg.asBits }
      default { rData := B(0xDEADBEEFL, 32 bits) }
    }
  }

  when(axilR.fire) {
    rValid := False
  }

  val awPending = Reg(Bool()) init(False)
  val awAddrReg = Reg(UInt(32 bits)) init(0)
  val awIdReg   = Reg(cloneOf(axilAw.id)) init(0)
  val wPending  = Reg(Bool()) init(False)
  val wDataReg  = Reg(Bits(32 bits)) init(0)

  axilAw.ready := !awPending
  axilW.ready  := !wPending

  when(axilAw.fire) {
    awPending := True
    awAddrReg := axilAw.addr
    awIdReg   := axilAw.id
  }

  when(axilW.fire) {
    wPending := True
    wDataReg := axilW.data
  }

  val bValid = Reg(Bool()) init(False)
  val bId    = Reg(cloneOf(axilAw.id)) init(0)
  axilB.valid := bValid
  axilB.id    := bId
  axilB.resp  := 0

  val doWrite = awPending && wPending && !bValid
  when(doWrite) {
    bValid := True
    bId    := awIdReg
    awPending := False
    wPending  := False

    switch(awAddrReg(7 downto 2)) {
      is(0)  { ctrlReg   := wDataReg }
      is(2)  { srcAddrLo := wDataReg.asUInt }
      is(3)  { srcAddrHi := wDataReg.asUInt }
      is(4)  { dstAddrLo := wDataReg.asUInt }
      is(5)  { dstAddrHi := wDataReg.asUInt }
      is(6)  { lengthReg := wDataReg.asUInt }
      default {}
    }
  }

  when(axilB.fire) {
    bValid := False
  }

  // -------------------------------------------------------
  // DMA FSM
  // -------------------------------------------------------
  val startBit   = ctrlReg(0)
  val startPrev  = RegNext(startBit) init(False)
  val startPulse = startBit && !startPrev
  val direction  = ctrlReg(1)  // 0=H2D, 1=D2H

  object DmaState extends SpinalEnum {
    val IDLE, H2D_RD_REQ, H2D_WAIT_CPL, H2D_WR_LOCAL,
      D2H_RD_LOCAL, D2H_WR_PCIE, DONE, ERROR = newElement()
  }

  val dmaState   = Reg(DmaState()) init(DmaState.IDLE)
  val remaining  = Reg(UInt(20 bits)) init(0)   // in DWORD
  val offset     = Reg(UInt(20 bits)) init(0)   // in bytes
  val tagCtr     = Reg(UInt(8 bits))  init(0)

  val maxPayloadDw = U(maxPayload / 4, 20 bits)
  val chunkDw      = UInt(20 bits)
  chunkDw := Mux(remaining < maxPayloadDw, remaining, maxPayloadDw)

  // Local memory data path is 64-bit, so each D2H packet carries <=2 DWORDs
  val d2hChunkDw = UInt(20 bits)
  d2hChunkDw := Mux(remaining < 2, remaining, U(2, 20 bits))

  // TLP defaults
  val memWrPkt = TlpStreamPacket()
  val memRdPkt = TlpStreamPacket()

  memWrPkt.tlpType   := TlpType.MEM_WR
  memWrPkt.tc        := 0
  memWrPkt.attr      := 0
  memWrPkt.firstBe   := 0xF
  memWrPkt.lastBe    := 0xF
  memWrPkt.reqId     := io.busDevFunc
  memWrPkt.tag       := tagCtr
  memWrPkt.addr      := (dstAddrHi ## dstAddrLo).asUInt + offset
  memWrPkt.length    := d2hChunkDw.resize(10)
  memWrPkt.dataValid := d2hChunkDw.resize(3)
  for(i <- 0 until 4) memWrPkt.data(i) := 0

  memRdPkt.tlpType   := TlpType.MEM_RD
  memRdPkt.tc        := 0
  memRdPkt.attr      := 0
  memRdPkt.firstBe   := 0xF
  memRdPkt.lastBe    := 0xF
  memRdPkt.reqId     := io.busDevFunc
  memRdPkt.tag       := tagCtr
  memRdPkt.addr      := (srcAddrHi ## srcAddrLo).asUInt + offset
  memRdPkt.length    := chunkDw.resize(10)
  memRdPkt.dataValid := 0
  for(i <- 0 until 4) memRdPkt.data(i) := 0

  io.memWrOut.valid   := False
  io.memWrOut.payload := memWrPkt
  io.memRdOut.valid   := False
  io.memRdOut.payload := memRdPkt
  io.cplIn.ready      := False
  io.h2dDone          := statusReg(0)
  io.d2hDone          := statusReg(0)
  io.dmaErr           := statusReg(2)

  // Local AXI4 master defaults
  io.localMem.ar.valid := False
  io.localMem.ar.addr  := 0
  io.localMem.ar.id    := 0
  io.localMem.ar.len   := 0
  io.localMem.ar.size  := 3
  io.localMem.ar.burst := 1
  io.localMem.ar.region := 0
  io.localMem.ar.lock   := 0
  io.localMem.ar.cache  := 0
  io.localMem.ar.qos    := 0
  io.localMem.ar.prot   := 0
  io.localMem.r.ready  := True
  io.localMem.aw.valid := False
  io.localMem.aw.addr  := 0
  io.localMem.aw.id    := 0
  io.localMem.aw.len   := 0
  io.localMem.aw.size  := 3
  io.localMem.aw.burst := 1
  io.localMem.aw.region := 0
  io.localMem.aw.lock   := 0
  io.localMem.aw.cache  := 0
  io.localMem.aw.qos    := 0
  io.localMem.aw.prot   := 0
  io.localMem.w.valid  := False
  io.localMem.w.data   := 0
  io.localMem.w.strb   := 0x00
  io.localMem.w.last   := True
  io.localMem.b.ready  := True

  val h2dWriteAddr = Reg(UInt(32 bits)) init(0)
  val h2dWriteData = Reg(Bits(64 bits)) init(0)
  val h2dWriteStrb = Reg(Bits(8 bits)) init(0)

  switch(dmaState) {

    is(DmaState.IDLE) {
      when(startPulse && statusReg(1) === False) {
        val lengthDw = (lengthReg.resize(20) >> 2).resize(20)
        remaining := lengthDw
        offset    := 0
        statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000002L, 32 bits)
        tagCtr    := tagCtr + 1

        when(lengthDw === 0) {
          dmaState := DmaState.DONE
        } elsewhen(direction === False) {
          dmaState := DmaState.H2D_RD_REQ
        } otherwise {
          dmaState := DmaState.D2H_RD_LOCAL
        }
      }
    }

    // ---- Host-to-Device: Send MRd TLPs ----
    is(DmaState.H2D_RD_REQ) {
      io.memRdOut.valid := True
      when(io.memRdOut.ready) {
        val chunk        = chunkDw
        val nextRemain   = remaining - chunk
        offset    := offset + (chunk |<< 2)
        remaining := nextRemain
        dmaState  := DmaState.H2D_WAIT_CPL
      }
    }

    // Wait for completion data
    is(DmaState.H2D_WAIT_CPL) {
      io.cplIn.ready := True
      when(io.cplIn.fire && io.cplIn.payload.tag === tagCtr) {
        val cplWords = Mux(io.cplIn.payload.dataValid === 0, U(1, 3 bits), io.cplIn.payload.dataValid)
        h2dWriteAddr := (dstAddrLo + offset - (io.cplIn.payload.length |<< 2)).resized
        h2dWriteData := (io.cplIn.payload.data(1) ## io.cplIn.payload.data(0)).asBits
        h2dWriteStrb := (cplWords === 1) ? B"8'h0F" | B"8'hFF"
        dmaState     := DmaState.H2D_WR_LOCAL
      }
    }

    is(DmaState.H2D_WR_LOCAL) {
      io.localMem.aw.valid := True
      io.localMem.aw.addr  := h2dWriteAddr
      io.localMem.w.valid  := True
      io.localMem.w.data   := h2dWriteData
      io.localMem.w.strb   := h2dWriteStrb

      when(io.localMem.aw.ready && io.localMem.w.ready) {
        when(remaining === 0) {
          dmaState := DmaState.DONE
        } otherwise {
          tagCtr   := tagCtr + 1
          dmaState := DmaState.H2D_RD_REQ
        }
      }
    }

    // ---- Device-to-Host: Read local, send MWr TLPs ----
    is(DmaState.D2H_RD_LOCAL) {
      io.localMem.ar.valid := True
      io.localMem.ar.addr  := (srcAddrLo + offset).resized
      io.localMem.ar.len   := Mux(d2hChunkDw === 0, U(0, 8 bits), (d2hChunkDw - 1).resize(8))

      when(io.localMem.ar.ready) {
        dmaState := DmaState.D2H_WR_PCIE
      }
    }

    is(DmaState.D2H_WR_PCIE) {
      when(io.localMem.r.valid) {
        val chunk = d2hChunkDw
        val p = TlpStreamPacket()

        p.tlpType := TlpType.MEM_WR
        p.reqId   := io.busDevFunc
        p.tag     := tagCtr
        p.addr    := (dstAddrHi ## dstAddrLo).asUInt + offset
        p.firstBe := 0xF
        p.lastBe  := 0xF
        p.tc      := 0
        p.attr    := 0
        p.length    := chunk.resize(10)
        p.dataValid := chunk.resize(3)
        p.data(0)   := io.localMem.r.data(31 downto 0)
        p.data(1)   := (chunk > 1) ? io.localMem.r.data(63 downto 32) | B(0, 32 bits)
        p.data(2)   := 0
        p.data(3)   := 0

        io.memWrOut.valid   := True
        io.memWrOut.payload := p

        when(io.memWrOut.ready) {
          val nextRemain = remaining - chunk
          offset    := offset + (chunk |<< 2)
          remaining := nextRemain

          when(nextRemain === 0) {
            dmaState := DmaState.DONE
          } otherwise {
            tagCtr   := tagCtr + 1
            dmaState := DmaState.D2H_RD_LOCAL
          }
        }
      }
    }

    is(DmaState.DONE) {
      statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000001L, 32 bits)
      dmaState  := DmaState.IDLE
    }

    is(DmaState.ERROR) {
      statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000004L, 32 bits)
      dmaState  := DmaState.IDLE
    }
  }
}
