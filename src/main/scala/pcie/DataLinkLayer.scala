package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// CRC-32 helper
// ============================================================
object Crc32 {
  val table: Array[Long] = Array.tabulate(256) { i =>
    var c = i.toLong
    for (_ <- 0 until 8)
      c = if ((c & 1L) != 0) 0xEDB88320L ^ (c >>> 1) else c >>> 1
    c & 0xFFFFFFFFL
  }

  def updateByte(crcIn: UInt, byte: Bits): UInt = {
    val idx = (crcIn(7 downto 0) ^ byte.asUInt).resize(8)
    val rom = Mem(UInt(32 bits), table.map(v => U(v, 32 bits)))
    (crcIn >> 8).resize(32) ^ rom.readAsync(idx)
  }

  def updateDword(crcIn: UInt, dw: Bits): UInt = {
    var c = crcIn
    for (b <- 0 until 4)
      c = updateByte(c, dw(b * 8 + 7 downto b * 8))
    c
  }
}

// ============================================================
// DL TX Framer
// ============================================================
class DlTxFramer extends Component {
  val io = new Bundle {
    val tlpIn    = slave  Stream(Bits(32 bits))
    val frameOut = master Stream(Bits(32 bits))
    val seqAck   = in  UInt(12 bits)
    val nextSeq  = out UInt(12 bits)
  }

  val txSeq = Reg(UInt(12 bits)) init(0)
  io.nextSeq := txSeq

  object St extends SpinalEnum { val IDLE, SEND_SEQ, FWD, LCRC = newElement() }
  val state = Reg(St()) init(St.IDLE)
  val crc   = Reg(UInt(32 bits)) init(0xFFFFFFFFL)

  val replayMem  = Mem(Bits(32 bits), 256)
  val replayWPtr = Reg(UInt(8 bits)) init(0)

  io.frameOut.valid   := False
  io.frameOut.payload := 0
  io.tlpIn.ready      := False

  switch(state) {
    is(St.IDLE) {
      when(io.tlpIn.valid) { crc := 0xFFFFFFFFL; state := St.SEND_SEQ }
    }
    is(St.SEND_SEQ) {
      val seqDw = B"8'hAA" ## B"4'h0" ##
              txSeq(11 downto 8).asBits ##
              txSeq(7  downto 0).asBits ##
              B"8'h00"
      io.frameOut.valid   := True
      io.frameOut.payload := seqDw
      when(io.frameOut.ready) { crc := Crc32.updateDword(crc, seqDw); state := St.FWD }
    }
    is(St.FWD) {
      io.frameOut.valid   := io.tlpIn.valid
      io.frameOut.payload := io.tlpIn.payload
      io.tlpIn.ready      := io.frameOut.ready
      when(io.tlpIn.fire) {
        crc := Crc32.updateDword(crc, io.tlpIn.payload)
        replayMem(replayWPtr) := io.tlpIn.payload
        replayWPtr := replayWPtr + 1
      }
      when(!io.tlpIn.valid && RegNext(io.tlpIn.valid, False)) { state := St.LCRC }
    }
    is(St.LCRC) {
      io.frameOut.valid   := True
      io.frameOut.payload := (~crc).asBits
      when(io.frameOut.ready) { txSeq := txSeq + 1; state := St.IDLE }
    }
  }
}

// ============================================================
// DL RX Deframer
// ============================================================
class DlRxDeframer extends Component {
  val io = new Bundle {
    val frameIn  = slave  Stream(Bits(32 bits))
    val tlpOut   = master Stream(Bits(32 bits))
    val txAck    = out UInt(12 bits)
    val txNak    = out UInt(12 bits)
    val ackValid = out Bool()
    val nakValid = out Bool()
    val crcErr   = out Bool()
  }

  object St extends SpinalEnum { val IDLE, RX_SEQ, DATA, CHECK = newElement() }
  val state    = Reg(St()) init(St.IDLE)
  val crc      = Reg(UInt(32 bits)) init(0xFFFFFFFFL)
  val rxSeq    = Reg(UInt(12 bits)) init(0)
  val expSeq   = Reg(UInt(12 bits)) init(0)
  val prevData = Reg(Bits(32 bits)) init(0)
  val prevVld  = Reg(Bool()) init(False)

  io.txAck    := expSeq
  io.txNak    := 0
  io.ackValid := False
  io.nakValid := False
  io.crcErr   := False

  io.tlpOut.valid   := False
  io.tlpOut.payload := prevData
  io.frameIn.ready  := !io.tlpOut.valid || io.tlpOut.ready

  switch(state) {
    is(St.IDLE) {
      when(io.frameIn.valid) { crc := 0xFFFFFFFFL; prevVld := False; state := St.RX_SEQ }
    }
    is(St.RX_SEQ) {
      when(io.frameIn.fire) {
        rxSeq := io.frameIn.payload(23 downto 12).asUInt.resize(12)
        crc   := Crc32.updateDword(crc, io.frameIn.payload)
        state := St.DATA
      }
    }
    is(St.DATA) {
      when(io.frameIn.valid) {
        when(prevVld) {
          io.tlpOut.valid   := True
          io.tlpOut.payload := prevData
        }
        when(io.frameIn.ready) {
          crc      := Crc32.updateDword(crc, io.frameIn.payload)
          prevData := io.frameIn.payload
          prevVld  := True
        }
      }.otherwise {
        when(prevVld) { state := St.CHECK }
      }
    }
    is(St.CHECK) {
      val ok = (~crc).asBits === prevData && rxSeq === expSeq
      when(ok)    { expSeq := expSeq + 1; io.ackValid := True;  io.txAck := rxSeq }
              .otherwise  { io.nakValid := True; io.txNak := rxSeq; io.crcErr := (~crc).asBits =/= prevData }
      prevVld := False
      state   := St.IDLE
    }
  }
}

// ============================================================
// Flow Control Manager with Full Credit Tracking
// ============================================================
class FlowControlMgr extends Component {
  val io = new Bundle {
    // Initialization
    val init          = in  Bool()
    val linkUp        = in  Bool()

    // Credit consumption from TLP TX
    val phConsumed    = in  UInt(8 bits)
    val pdConsumed    = in  UInt(12 bits)
    val nphConsumed   = in  UInt(8 bits)
    val npdConsumed   = in  UInt(12 bits)
    val cplhConsumed  = in  UInt(8 bits)
    val cpldConsumed  = in  UInt(12 bits)

    // FC update from received DLLPs
    val fcUpdateValid = in  Bool()
    val fcUpdate      = in(FlowControlCredits())

    // FC Init from FCP DLLPs (during link training)
    val fcInitValid   = in  Bool()
    val fcInit        = in(FlowControlCredits())

    // Available credits for TX
    val available     = out(FlowControlCredits())

    // Credit status for monitoring
    val phExhausted   = out Bool()
    val nphExhausted  = out Bool()
    val cplhExhausted = out Bool()
  }

  // Credit counters
  val ph   = Reg(UInt(8  bits)) init(16)
  val nph  = Reg(UInt(8  bits)) init(16)
  val cplh = Reg(UInt(8  bits)) init(16)
  val pd   = Reg(UInt(12 bits)) init(512)
  val npd  = Reg(UInt(12 bits)) init(512)
  val cpld = Reg(UInt(12 bits)) init(512)

  // Infinite credits for completion (we always accept completions)
  val cplhInfinite = Reg(Bool()) init(False)
  val cpldInfinite = Reg(Bool()) init(False)

  // Initialize credits (reset or link down)
  when(io.init || !io.linkUp) {
    ph := 0; nph := 0; cplh := 0
    pd := 0; npd := 0; cpld := 0
    cplhInfinite := False
    cpldInfinite := False
  }

  // FC Init from FCP DLLPs (Initial FC values during link training)
  when(io.fcInitValid) {
    ph := io.fcInit.phCredits
    nph := io.fcInit.nphCredits
    cplh := io.fcInit.cplhCredits
    pd := io.fcInit.pdCredits
    npd := io.fcInit.npdCredits
    cpld := io.fcInit.cpldCredits
    // Check for infinite credits (0x80 means infinite for headers, 0x800 for data)
    cplhInfinite := io.fcInit.cplhCredits(7)
    cpldInfinite := io.fcInit.cpldCredits(11)
  }

  // FC Update from UpdateFC DLLPs
  when(io.fcUpdateValid) {
    when(!cplhInfinite) {
      ph := ph + io.fcUpdate.phCredits
      nph := nph + io.fcUpdate.nphCredits
      cplh := cplh + io.fcUpdate.cplhCredits
    }
    when(!cpldInfinite) {
      pd := pd + io.fcUpdate.pdCredits
      npd := npd + io.fcUpdate.npdCredits
      cpld := cpld + io.fcUpdate.cpldCredits
    }
  }

  // Credit consumption from TLP transmission
  when(io.phConsumed > 0) {
    ph := Mux(ph >= io.phConsumed, ph - io.phConsumed, U(0, 8 bits))
  }
  when(io.pdConsumed > 0) {
    pd := Mux(pd >= io.pdConsumed, pd - io.pdConsumed, U(0, 12 bits))
  }
  when(io.nphConsumed > 0) {
    nph := Mux(nph >= io.nphConsumed, nph - io.nphConsumed, U(0, 8 bits))
  }
  when(io.npdConsumed > 0) {
    npd := Mux(npd >= io.npdConsumed, npd - io.npdConsumed, U(0, 12 bits))
  }
  when(io.cplhConsumed > 0 && !cplhInfinite) {
    cplh := Mux(cplh >= io.cplhConsumed, cplh - io.cplhConsumed, U(0, 8 bits))
  }
  when(io.cpldConsumed > 0 && !cpldInfinite) {
    cpld := Mux(cpld >= io.cpldConsumed, cpld - io.cpldConsumed, U(0, 12 bits))
  }

  // Output available credits
  io.available.phCredits   := ph
  io.available.nphCredits  := nph
  io.available.cplhCredits := Mux(cplhInfinite, U(0xFF, 8 bits), cplh)
  io.available.pdCredits   := pd
  io.available.npdCredits  := npd
  io.available.cpldCredits := Mux(cpldInfinite, U(0xFFF, 12 bits), cpld)

  // Exhausted flags for backpressure
  io.phExhausted   := (ph === 0)
  io.nphExhausted  := (nph === 0)
  io.cplhExhausted := (cplh === 0) && !cplhInfinite
}

// ============================================================
// DLLP (Data Link Layer Packet) Handler
// Handles ACK, NAK, and FC DLLPs
// ============================================================
object DllpType extends SpinalEnum(binaryOneHot) {
  val ACK, NAK, PM_ENTER_L1, PM_REQ_ACK,
      FC_P, FC_NP, FC_CPL, FC_P_RESERVED = newElement()
}

class DllpHandler extends Component {
  val io = new Bundle {
    // From RX path
    val dllpIn    = slave  Stream(Bits(32 bits))
    val dllpValid = in  Bool()

    // To TX path
    val ackSeq    = out UInt(12 bits)
    val ackValid  = out Bool()
    val nakSeq    = out UInt(12 bits)
    val nakValid  = out Bool()

    // To Flow Control Manager
    val fcInitValid = out Bool()
    val fcInit      = out(FlowControlCredits())
    val fcUpdateValid = out Bool()
    val fcUpdate    = out(FlowControlCredits())

    // To Power Management
    val pmEnterL1  = out Bool()
  }

  // DLLP format: [Type(4)][Data(24)][CRC(4)]
  val dllpType = io.dllpIn.payload(31 downto 28)
  val dllpData = io.dllpIn.payload(27 downto 4)

  io.ackValid := False
  io.nakValid := False
  io.ackSeq := 0
  io.nakSeq := 0
  io.fcInitValid := False
  io.fcUpdateValid := False
  io.pmEnterL1 := False

  // Default outputs
  io.fcInit.phCredits := 0
  io.fcInit.nphCredits := 0
  io.fcInit.cplhCredits := 0
  io.fcInit.pdCredits := 0
  io.fcInit.npdCredits := 0
  io.fcInit.cpldCredits := 0
  io.fcUpdate := io.fcInit

  when(io.dllpValid && io.dllpIn.fire) {
    switch(dllpType) {
      // ACK DLLP
      is(B"4'h0") {
        io.ackSeq := dllpData(11 downto 0).asUInt
        io.ackValid := True
      }
      // NAK DLLP
      is(B"4'h1") {
        io.nakSeq := dllpData(11 downto 0).asUInt
        io.nakValid := True
      }
      // PM_Enter_L1 DLLP
      is(B"4'h2") {
        io.pmEnterL1 := True
      }
      // FC_P (Posted) Init
      is(B"4'hB") {
        io.fcInitValid := True
        io.fcInit.phCredits := dllpData(3 downto 0).asUInt.resize(8) ## dllpData(7 downto 4)
        io.fcInit.pdCredits := dllpData(19 downto 8).asUInt
      }
      // FC_NP (Non-Posted) Init
      is(B"4'hC") {
        io.fcInitValid := True
        io.fcInit.nphCredits := dllpData(3 downto 0).asUInt.resize(8) ## dllpData(7 downto 4)
        io.fcInit.npdCredits := dllpData(19 downto 8).asUInt
      }
      // FC_CPL (Completion) Init
      is(B"4'hD") {
        io.fcInitValid := True
        io.fcInit.cplhCredits := dllpData(3 downto 0).asUInt.resize(8) ## dllpData(7 downto 4)
        io.fcInit.cpldCredits := dllpData(19 downto 8).asUInt
      }
      // UpdateFC DLLPs (similar format, different type codes)
      is(B"4'hE") {
        io.fcUpdateValid := True
        io.fcUpdate.phCredits := dllpData(3 downto 0).asUInt.resize(8)
        io.fcUpdate.pdCredits := dllpData(15 downto 4).asUInt
      }
    }
  }

  io.dllpIn.ready := True
}
