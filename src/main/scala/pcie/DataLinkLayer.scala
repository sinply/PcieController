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
// Flow Control Manager
// ============================================================
class FlowControlMgr extends Component {
  val io = new Bundle {
    val init          = in  Bool()
    val phConsumed    = in  UInt(4 bits)
    val nphConsumed   = in  UInt(4 bits)
    val cplhConsumed  = in  UInt(4 bits)
    val fcUpdateValid = in  Bool()
    val fcUpdate      = in(FlowControlCredits())
    val available     = out(FlowControlCredits())
  }

  val ph   = Reg(UInt(8  bits)) init(16)
  val nph  = Reg(UInt(8  bits)) init(16)
  val cplh = Reg(UInt(8  bits)) init(16)
  val pd   = Reg(UInt(12 bits)) init(512)
  val npd  = Reg(UInt(12 bits)) init(512)
  val cpld = Reg(UInt(12 bits)) init(512)

  when(io.init) { ph := 0; nph := 0; cplh := 0; pd := 0; npd := 0; cpld := 0 }

  when(io.fcUpdateValid) {
    ph   := io.fcUpdate.phCredits
    nph  := io.fcUpdate.nphCredits
    cplh := io.fcUpdate.cplhCredits
    pd   := io.fcUpdate.pdCredits
    npd  := io.fcUpdate.npdCredits
    cpld := io.fcUpdate.cpldCredits
  }

  when(io.phConsumed   > 0) { ph   := Mux(ph   >= io.phConsumed.resized,   ph   - io.phConsumed.resized,   U(0, 8 bits)) }
  when(io.nphConsumed  > 0) { nph  := Mux(nph  >= io.nphConsumed.resized,  nph  - io.nphConsumed.resized,  U(0, 8 bits)) }
  when(io.cplhConsumed > 0) { cplh := Mux(cplh >= io.cplhConsumed.resized, cplh - io.cplhConsumed.resized, U(0, 8 bits)) }

  io.available.phCredits   := ph
  io.available.nphCredits  := nph
  io.available.cplhCredits := cplh
  io.available.pdCredits   := pd
  io.available.npdCredits  := npd
  io.available.cpldCredits := cpld
}
