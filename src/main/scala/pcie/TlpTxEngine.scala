package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// TLP TX Engine
// Serializes TlpStreamPacket -> 32-bit DWORD stream
// Supports 3DW/4DW headers with optional data payload
// ============================================================
class TlpTxEngine extends Component {

  val io = new Bundle {
    val memWrReq  = slave  Stream(TlpStreamPacket())  // Memory Write Requests
    val memRdReq  = slave  Stream(TlpStreamPacket())  // Memory Read Requests
    val cplReq    = slave  Stream(TlpStreamPacket())  // Completion packets
    val tlpOut    = master Stream(Bits(32 bits))       // To Data Link Layer
    val fcCredits = in(FlowControlCredits())           // Available credits
  }

  // -------------------------------------------------------
  // Round-robin arbitration among request sources
  // -------------------------------------------------------
  object ArbState extends SpinalEnum {
    val IDLE, SEL_CPL, SEL_MEM_WR, SEL_MEM_RD = newElement()
  }

  val arbState   = Reg(ArbState()) init(ArbState.IDLE)
  val activeReq  = Reg(TlpStreamPacket())
  val granted    = Reg(TlpType.craft())

  // Grant priority: Completion > MemWr > MemRd
  val canSendCpl   = io.cplReq.valid   && io.fcCredits.cplhCredits > 0
  val canSendMemWr = io.memWrReq.valid && io.fcCredits.phCredits > 0
  val canSendMemRd = io.memRdReq.valid && io.fcCredits.nphCredits > 0

  // -------------------------------------------------------
  // TX State Machine
  // -------------------------------------------------------
  object TxState extends SpinalEnum {
    val IDLE, HDR1, HDR2, HDR3, HDR4, DATA = newElement()
  }

  val state    = Reg(TxState()) init(TxState.IDLE)
  val dataIdx  = Reg(UInt(4 bits)) init(0)
  val needData = Reg(Bool()) init(False)
  val is4DW    = Reg(Bool()) init(False)  // 64-bit address

  // Default outputs
  io.tlpOut.valid   := False
  io.tlpOut.payload := 0
  io.memWrReq.ready := False
  io.memRdReq.ready := False
  io.cplReq.ready   := False

  // -------------------------------------------------------
  // Build HDR1: [FMT|Type|TC|0|Attr|0|0|TD|EP|Length]
  // -------------------------------------------------------
  def buildHdr1(pkt: TlpStreamPacket): Bits = {
    val fmt    = Bits(3 bits)
    val ttype  = Bits(5 bits)
    val hdr    = Bits(32 bits)

    val hasData = packetHasData(pkt)
    val addr64  = packetUses4Dw(pkt)

    fmt := B"3'b000"
    when(addr64 && hasData) {
      fmt := B"3'b011"
    } elsewhen(addr64 && !hasData) {
      fmt := B"3'b001"
    } elsewhen(!addr64 && hasData) {
      fmt := B"3'b010"
    }

    ttype := B"5'b11111"
    switch(pkt.tlpType) {
      is(TlpType.MEM_RD, TlpType.MEM_WR) { ttype := B"5'b00000" }
      is(TlpType.IO_RD, TlpType.IO_WR)   { ttype := B"5'b00010" }
      is(TlpType.CFG_RD0, TlpType.CFG_WR0) { ttype := B"5'b00100" }
      is(TlpType.CFG_RD1, TlpType.CFG_WR1) { ttype := B"5'b00101" }
      is(TlpType.CPL, TlpType.CPL_D)     { ttype := B"5'b01010" }
      is(TlpType.MSG, TlpType.MSG_D)     { ttype := B"5'b10000" }
    }

    hdr := 0
    hdr(31 downto 29) := fmt
    hdr(28 downto 24) := ttype
    hdr(22 downto 20) := pkt.tc.asBits
    hdr(13 downto 12) := pkt.attr
    hdr(9 downto 0)   := pkt.length.asBits
    hdr
  }

  def packetHasData(pkt: TlpStreamPacket): Bool = {
    val hasData = Bool()
    hasData := pkt.dataValid =/= 0
    when(pkt.tlpType === TlpType.MEM_WR ||
         pkt.tlpType === TlpType.IO_WR  ||
         pkt.tlpType === TlpType.CFG_WR0 ||
         pkt.tlpType === TlpType.CFG_WR1 ||
         pkt.tlpType === TlpType.CPL_D ||
         pkt.tlpType === TlpType.MSG   ||
         pkt.tlpType === TlpType.MSG_D) {
      hasData := True
    }
    hasData
  }

  def packetUses4Dw(pkt: TlpStreamPacket): Bool = {
    val use4Dw = Bool()
    val canUse4Dw = (pkt.tlpType === TlpType.MEM_RD ||
      pkt.tlpType === TlpType.MEM_WR ||
      pkt.tlpType === TlpType.IO_RD ||
      pkt.tlpType === TlpType.IO_WR)
    use4Dw := canUse4Dw && (pkt.addr(63 downto 32) =/= 0)
    use4Dw
  }

  // HDR2: [ReqID | Tag | LastBE | FirstBE]
  def buildHdr2(pkt: TlpStreamPacket): Bits =
    (pkt.reqId.asBits ## pkt.tag.asBits ##
     pkt.lastBe ## pkt.firstBe).asBits

  // HDR3 (3DW addr upper) / HDR3 (4DW addr[63:32])
  def buildHdr3_4DW(pkt: TlpStreamPacket): Bits = pkt.addr(63 downto 32).asBits
  def buildHdr3_3DW(pkt: TlpStreamPacket): Bits = pkt.addr(31 downto  0).asBits

  // HDR4 (4DW addr lower)
  def buildHdr4_4DW(pkt: TlpStreamPacket): Bits = pkt.addr(31 downto  0).asBits

  // -------------------------------------------------------
  // Main FSM
  // -------------------------------------------------------
  switch(state) {

    is(TxState.IDLE) {
      when(canSendCpl) {
        activeReq  := io.cplReq.payload
        needData   := packetHasData(io.cplReq.payload)
        is4DW      := packetUses4Dw(io.cplReq.payload)
        state      := TxState.HDR1
        io.cplReq.ready := True
      } elsewhen(canSendMemWr) {
        activeReq  := io.memWrReq.payload
        needData   := packetHasData(io.memWrReq.payload)
        is4DW      := packetUses4Dw(io.memWrReq.payload)
        state      := TxState.HDR1
        io.memWrReq.ready := True
      } elsewhen(canSendMemRd) {
        activeReq  := io.memRdReq.payload
        needData   := packetHasData(io.memRdReq.payload)
        is4DW      := packetUses4Dw(io.memRdReq.payload)
        state      := TxState.HDR1
        io.memRdReq.ready := True
      }
    }

    is(TxState.HDR1) {
      io.tlpOut.valid   := True
      io.tlpOut.payload := buildHdr1(activeReq)
      when(io.tlpOut.ready) { state := TxState.HDR2 }
    }

    is(TxState.HDR2) {
      io.tlpOut.valid   := True
      io.tlpOut.payload := buildHdr2(activeReq)
      when(io.tlpOut.ready) {
        state := TxState.HDR3
      }
    }

    is(TxState.HDR3) {
      io.tlpOut.valid := True
      io.tlpOut.payload := is4DW ?
        buildHdr3_4DW(activeReq) |
        buildHdr3_3DW(activeReq)
      when(io.tlpOut.ready) {
        state := is4DW ? TxState.HDR4 |
                 (needData ? TxState.DATA | TxState.IDLE)
        dataIdx := 0
      }
    }

    is(TxState.HDR4) {
      io.tlpOut.valid   := True
      io.tlpOut.payload := buildHdr4_4DW(activeReq)
      when(io.tlpOut.ready) {
        state   := needData ? TxState.DATA | TxState.IDLE
        dataIdx := 0
      }
    }

    is(TxState.DATA) {
      val payloadWords = Mux(activeReq.dataValid === 0, U(1, 3 bits), activeReq.dataValid)
      io.tlpOut.valid   := True
      io.tlpOut.payload := activeReq.data(dataIdx.resized)
      when(io.tlpOut.ready) {
        dataIdx := dataIdx + 1
        when(dataIdx === payloadWords - 1) {
          state := TxState.IDLE
        }
      }
    }
  }
}

// ============================================================
// TLP TX FIFO Wrapper (with backpressure buffer)
// ============================================================
class TlpTxFifoWrapper extends Component {
  val io = new Bundle {
    val memWrIn  = slave  Stream(TlpStreamPacket())
    val memRdIn  = slave  Stream(TlpStreamPacket())
    val cplIn    = slave  Stream(TlpStreamPacket())
    val tlpOut   = master Stream(Bits(32 bits))
    val fcCredits = in(FlowControlCredits())
  }

  // Per-channel FIFOs to prevent head-of-line blocking
  val memWrFifo = StreamFifo(TlpStreamPacket(), 64)
  val memRdFifo = StreamFifo(TlpStreamPacket(), 32)
  val cplFifo   = StreamFifo(TlpStreamPacket(), 32)

  memWrFifo.io.push << io.memWrIn
  memRdFifo.io.push << io.memRdIn
  cplFifo.io.push   << io.cplIn

  val engine = new TlpTxEngine()
  engine.io.memWrReq  << memWrFifo.io.pop
  engine.io.memRdReq  << memRdFifo.io.pop
  engine.io.cplReq    << cplFifo.io.pop
  engine.io.fcCredits := io.fcCredits
  io.tlpOut           << engine.io.tlpOut
}
