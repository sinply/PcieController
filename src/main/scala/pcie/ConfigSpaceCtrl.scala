package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// PCIe Configuration Space Controller (Type 0 Header)
// Handles CfgRd/CfgWr TLPs and returns Completion TLPs
// ============================================================
class PcieConfigSpaceCtrl(
  vendorId : Int = 0x10EE,
  deviceId : Int = 0x7021,
  classCode: Int = 0x020000  // Ethernet Controller
) extends Component {

  val io = new Bundle {
    val cfgReq    = slave  Stream(TlpStreamPacket())
    val cfgResp   = master Stream(TlpStreamPacket())
    val barHit    = out Bits(6 bits)   // Which BAR matched
    val barCheckAddr = in UInt(64 bits)
    val busDevFunc = in UInt(16 bits)  // Our BDF from link training
    val cfgRegs   = out(PcieConfigRegs())  // Expose to user logic
  }

  // -------------------------------------------------------
  // Configuration Registers
  // -------------------------------------------------------
  val regs = new Area {
    val vendorIdReg    = Reg(UInt(16 bits)) init(vendorId)
    val deviceIdReg    = Reg(UInt(16 bits)) init(deviceId)
    val command        = Reg(Bits(16 bits)) init(0x0000)
    val status         = Reg(Bits(16 bits)) init(0x0010)
    val revisionId     = Reg(UInt(8 bits))  init(0x01)
    val classCodeReg   = Reg(Bits(24 bits)) init(classCode)
    val cacheLineSize  = Reg(UInt(8 bits))  init(0x00)
    val latencyTimer   = Reg(UInt(8 bits))  init(0x00)
    val bar            = Vec.fill(6)(Reg(UInt(32 bits)) init(0))
    val barMask        = Vec.fill(6)(UInt(32 bits))
    val subVendorId    = Reg(UInt(16 bits)) init(0x10EE)
    val subSystemId    = Reg(UInt(16 bits)) init(0x0001)
    val capPointer     = Reg(UInt(8 bits))  init(0x40)
    val intLine        = Reg(UInt(8 bits))  init(0xFF)
    val intPin         = Reg(UInt(8 bits))  init(0x01)

    // BAR size masks (BAR0 = 4KB, BAR1 = 64KB, rest disabled)
    barMask(0) := 0xFFFFF000L  // 4KB
    barMask(1) := 0xFFFF0000L  // 64KB
    for(i <- 2 until 6) barMask(i) := 0xFFFFFFFFL
  }

  // Expose config registers
  io.cfgRegs.vendorId      := regs.vendorIdReg
  io.cfgRegs.deviceId      := regs.deviceIdReg
  io.cfgRegs.command       := regs.command
  io.cfgRegs.status        := regs.status
  io.cfgRegs.revisionId    := regs.revisionId
  io.cfgRegs.classCode     := regs.classCodeReg
  io.cfgRegs.cacheLineSize := regs.cacheLineSize
  io.cfgRegs.latencyTimer  := regs.latencyTimer
  io.cfgRegs.headerType    := 0x00
  io.cfgRegs.bist          := 0x00
  io.cfgRegs.bar           := regs.bar
  io.cfgRegs.subVendorId   := regs.subVendorId
  io.cfgRegs.subSystemId   := regs.subSystemId
  io.cfgRegs.capPointer    := regs.capPointer
  io.cfgRegs.intLine       := regs.intLine
  io.cfgRegs.intPin        := regs.intPin

  // BAR hit detection
  for (i <- 0 until 6) {
    val barBase = regs.bar(i) & regs.barMask(i)
    val reqBase = io.barCheckAddr(31 downto 0) & regs.barMask(i)
    io.barHit(i) := (regs.bar(i)(31 downto 4) =/= 0) && (reqBase === barBase)
  }

  // -------------------------------------------------------
  // Config Read Data MUX (decode DWORD address)
  // -------------------------------------------------------
  def readConfigDword(dwAddr: UInt): Bits = {
    val data = Bits(32 bits)
    switch(dwAddr) {
      is(0)  { data := (regs.deviceIdReg ## regs.vendorIdReg).asBits }
      is(1)  { data := (regs.status ## regs.command) }
      is(2)  { data := (regs.classCodeReg ## regs.revisionId.asBits) }
      is(3)  { data := (regs.latencyTimer.asBits ## B"8'h00" ##
                        regs.cacheLineSize.asBits ## B"8'h00") }
      is(4)  { data := regs.bar(0).asBits }
      is(5)  { data := regs.bar(1).asBits }
      is(6)  { data := regs.bar(2).asBits }
      is(7)  { data := regs.bar(3).asBits }
      is(8)  { data := regs.bar(4).asBits }
      is(9)  { data := regs.bar(5).asBits }
      is(10) { data := 0 }  // CardBus CIS Ptr
      is(11) { data := (regs.subSystemId ## regs.subVendorId).asBits }
      is(12) { data := 0 }  // Expansion ROM
      is(13) { data := (B"24'h000000" ## regs.capPointer.asBits) }
      is(15) { data := (B"8'h00" ## regs.intPin.asBits ##
                        B"8'h00" ## regs.intLine.asBits) }
      default { data := B(32 bits, default -> True) }   // 全1 // default { data := 0xFFFFFFFF }
    }
    data
  }

  // -------------------------------------------------------
  // Response Generation FSM
  // -------------------------------------------------------
  val respValid = Reg(Bool()) init(False)
  val respPkt   = Reg(TlpStreamPacket())

  io.cfgResp.valid   := respValid
  io.cfgResp.payload := respPkt
  io.cfgReq.ready    := !respValid  // Back-pressure when busy

  when(io.cfgResp.fire) { respValid := False }

  when(io.cfgReq.fire) {
    val req    = io.cfgReq.payload
    val dwAddr = req.addr(9 downto 2).asBits.asUInt

    // Build completion response
    val r = TlpStreamPacket()
    r.tlpType  := TlpType.CPL
    r.reqId    := req.reqId
    r.tag      := req.tag
    r.addr     := 0
    r.length   := 1
    r.firstBe  := 0xF
    r.lastBe   := 0x0
    r.tc       := 0
    r.attr     := 0
    r.dataValid := 1
    r.data(0) := 0
    for (i <- 1 until 4) r.data(i) := 0

    switch(req.tlpType) {
      // ---- Config Read ----
      is(TlpType.CFG_RD0, TlpType.CFG_RD1) {
        r.tlpType  := TlpType.CPL_D
        r.data(0)  := readConfigDword(dwAddr)
        respPkt    := r
        respValid  := True
      }

      // ---- Config Write ----
      is(TlpType.CFG_WR0, TlpType.CFG_WR1) {
        r.tlpType := TlpType.CPL
        r.data(0) := 0
        respPkt   := r
        respValid := True

        // Write to writable fields
        switch(dwAddr) {
          is(1)  { regs.command := req.data(0)(15 downto 0) }
          is(3)  { regs.cacheLineSize := req.data(0)(7 downto 0).asUInt }
          is(4)  { regs.bar(0) := (req.data(0).asUInt & regs.barMask(0)).resized }
          is(5)  { regs.bar(1) := (req.data(0).asUInt & regs.barMask(1)).resized }
          is(15) {
            regs.intLine := req.data(0)(7 downto 0).asUInt
            regs.intPin  := req.data(0)(15 downto 8).asUInt
          }
          default {}
        }
      }
      default {}
    }
  }
}
