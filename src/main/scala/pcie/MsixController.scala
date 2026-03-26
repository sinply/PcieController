package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// MSI-X Interrupt Controller
// Supports up to 32 interrupt vectors
// Generates PCIe Message TLPs for each interrupt
// ============================================================
class MsixController(numVectors: Int = 32) extends Component {
  require(numVectors <= 2048)

  val io = new Bundle {
    val intReq     = in  Bits(numVectors bits)    // Interrupt request lines
    val intAck     = out Bits(numVectors bits)    // Interrupt acknowledged
    val msgTlpOut  = master Stream(TlpStreamPacket())  // MSI-X Message TLPs
    val busDevFunc = in  UInt(16 bits)
    // BAR access for MSI-X table (simplified MMIO)
    val tableAddr  = in  UInt(12 bits)
    val tableRdata = out Bits(32 bits)
    val tableWdata = in  Bits(32 bits)
    val tableWen   = in  Bool()
    val tableBe    = in  Bits(4 bits)
    // MSI-X Capability enable
    val msixEnable = in  Bool()
    val funcMask   = in  Bool()
  }

  // -------------------------------------------------------
  // MSI-X Table: (Msg Addr Lo, Msg Addr Hi, Msg Data, Vector Ctrl)
  // Each entry = 4 DWORDs = 16 bytes
  // -------------------------------------------------------
  val tableAddrLo  = Mem(Bits(32 bits), numVectors)
  val tableAddrHi  = Mem(Bits(32 bits), numVectors)
  val tableMsgData = Mem(Bits(32 bits), numVectors)
  val tableVCtrl   = Mem(Bits(32 bits), numVectors)  // bit0 = masked

  // -------------------------------------------------------
  // Pending Bit Array (PBA)
  // -------------------------------------------------------
  val pendingBits = Reg(Bits(numVectors bits)) init(0)
  val maskedBits  = Bits(numVectors bits)

  // Mask check (per-vector and function-level)
  for (i <- 0 until numVectors) {
    maskedBits(i) := io.funcMask | tableVCtrl.readAsync(U(i, log2Up(numVectors) bits))(0)
  }

  // Accumulate pending
  val newPending = Mux(io.msixEnable, io.intReq & ~maskedBits, B(0, numVectors bits))
  pendingBits := pendingBits | newPending

  // -------------------------------------------------------
  // MSI-X Table MMIO Read/Write
  // -------------------------------------------------------
  val rdVecIdx  = io.tableAddr(11 downto 4).asBits.asUInt.resize(log2Up(numVectors))   // 16B per entry
  val rdDwOff   = io.tableAddr(3 downto 2).asBits.asUInt

  switch(rdDwOff) {
    is(0) { io.tableRdata := tableAddrLo.readAsync(rdVecIdx) }
    is(1) { io.tableRdata := tableAddrHi.readAsync(rdVecIdx) }
    is(2) { io.tableRdata := tableMsgData.readAsync(rdVecIdx) }
    default { io.tableRdata := tableVCtrl.readAsync(rdVecIdx) }
  }

  def applyByteEnable(oldData: Bits, newData: Bits, be: Bits): Bits = {
    val merged = Bits(32 bits)
    merged := oldData
    for (b <- 0 until 4) {
      when(be(b)) {
        merged(b * 8 + 7 downto b * 8) := newData(b * 8 + 7 downto b * 8)
      }
    }
    merged
  }

  when(io.tableWen) {
    switch(rdDwOff) {
      is(0) { tableAddrLo.write(rdVecIdx, applyByteEnable(tableAddrLo.readAsync(rdVecIdx), io.tableWdata, io.tableBe)) }
      is(1) { tableAddrHi.write(rdVecIdx, applyByteEnable(tableAddrHi.readAsync(rdVecIdx), io.tableWdata, io.tableBe)) }
      is(2) { tableMsgData.write(rdVecIdx, applyByteEnable(tableMsgData.readAsync(rdVecIdx), io.tableWdata, io.tableBe)) }
      is(3) { tableVCtrl.write(rdVecIdx, applyByteEnable(tableVCtrl.readAsync(rdVecIdx), io.tableWdata, io.tableBe)) }
    }
  }

  // -------------------------------------------------------
  // Interrupt Dispatch FSM
  // -------------------------------------------------------
  object IrqState extends SpinalEnum {
    val SCAN, SEND_MSG, ACK = newElement()
  }

  val irqState  = Reg(IrqState()) init(IrqState.SCAN)
  val activeVec = Reg(UInt(log2Up(numVectors) bits)) init(0)
  val scanIdx   = Reg(UInt(log2Up(numVectors) bits)) init(0)

  io.msgTlpOut.valid   := False
  io.msgTlpOut.payload.assignDontCare()
  io.intAck := 0

  switch(irqState) {

    // Priority-scan pending interrupts
    is(IrqState.SCAN) {
      when(io.msixEnable) {
        when(pendingBits(scanIdx)) {
          activeVec := scanIdx
          irqState  := IrqState.SEND_MSG
        }
        scanIdx := (scanIdx === (numVectors - 1)) ? U(0) | (scanIdx + 1)
      }
    }

    // Build and send MSI-X Message TLP
    is(IrqState.SEND_MSG) {
      val p = TlpStreamPacket()

      p.tlpType  := TlpType.MSG_D
      p.tc       := 0
      p.attr     := 0
      p.reqId    := io.busDevFunc
      p.tag      := 0
      p.firstBe  := 0xF
      p.lastBe   := 0xF
      p.length   := 1
      p.dataValid := 1
      p.addr     := (tableAddrHi.readAsync(activeVec) ##
                     tableAddrLo.readAsync(activeVec)).asUInt
      p.data(0)  := tableMsgData.readAsync(activeVec)
      for(i <- 1 until 4) p.data(i) := 0

      io.msgTlpOut.valid   := True
      io.msgTlpOut.payload := p

      when(io.msgTlpOut.ready) {
        irqState := IrqState.ACK
      }
    }

    is(IrqState.ACK) {
      // Clear pending bit
      pendingBits(activeVec) := False
      io.intAck(activeVec)   := True
      irqState := IrqState.SCAN
    }
  }
}

