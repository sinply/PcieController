package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// PCIe Configuration Space Controller (Type 0 Header)
// Handles CfgRd/CfgWr TLPs and returns Completion TLPs
// Supports full 4KB extended config space
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
  // Configuration Registers - First 64 bytes (Type 0 Header)
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
    for(i <- 2 until 6) barMask(i) := 0  // Unimplemented BARs

    // BAR probe state for size discovery
    val barProbe = Vec.fill(6)(Reg(Bool()) init(False))
  }

  // -------------------------------------------------------
  // Extended Configuration Space (4KB total, 0x000-0xFFF)
  // Covers 0x40 to 0x3FF DWORD addresses (960 DWORDs)
  // -------------------------------------------------------
  private val EXT_CFG_DWORDS = 0x400 - 0x40  // 960 DWORDs
  private val extAddrWidth = log2Up(EXT_CFG_DWORDS)
  val extConfigMem = Mem(Bits(32 bits), EXT_CFG_DWORDS)

  // Helper functions for extended config access
  def isExtDw(dwAddr: UInt): Bool = (dwAddr >= U(0x40, 12 bits)) && (dwAddr < U(0x400, 12 bits))
  def extIdx(dwAddr: UInt): UInt = (dwAddr - U(0x40, 12 bits)).resize(extAddrWidth)

  // -------------------------------------------------------
  // MSI-X Capability (at offset 0x40)
  // -------------------------------------------------------
  val msixCap = new Area {
    val capId      = B"8'h11"     // MSI-X capability ID
    val nextCap    = Reg(UInt(8 bits)) init(0x50)     // Points to PM cap
    val msgCtrl    = Reg(Bits(16 bits)) init(0x0020)  // Table size = 32, enabled
    val tableBIR   = Reg(Bits(3 bits)) init(0x1)      // BAR1
    val tableOff   = Reg(Bits(29 bits)) init(0x0000)
    val pbaBIR     = Reg(Bits(3 bits)) init(0x1)      // BAR1
    val pbaOff     = Reg(Bits(29 bits)) init(0x1000)  // PBA after table
  }

  // -------------------------------------------------------
  // Power Management Capability (at offset 0x50)
  // -------------------------------------------------------
  val pmCap = new Area {
    val capId      = B"8'h01"     // PM capability ID
    val nextCap    = Reg(UInt(8 bits)) init(0x60)     // Points to PCIe cap
    val pmCapReg   = Reg(Bits(16 bits)) init(0x0002)  // D0, D3hot supported
    val pmCtrlStat = Reg(Bits(16 bits)) init(0x0000)  // D0 state
    val pmData     = Reg(Bits(8 bits))  init(0x00)    // PM data
    val pmBridgeExt = Reg(Bits(8 bits)) init(0x00)    // Bridge extensions
  }

  // -------------------------------------------------------
  // PCIe Capability (at offset 0x60)
  // -------------------------------------------------------
  val pcieCap = new Area {
    val capId      = B"8'h10"     // PCIe capability ID
    val nextCap    = Reg(UInt(8 bits)) init(0x00)     // End of capability list
    val pcieCapReg = Reg(Bits(16 bits)) init(0x0142)  // Device, Gen2, x1
    val devCap     = Reg(Bits(32 bits)) init(0x00000029)  // Max payload 256, completion timeout
    val devCtrl    = Reg(Bits(16 bits)) init(0x0000)
    val devStat    = Reg(Bits(16 bits)) init(0x0000)
    val linkCap    = Reg(Bits(32 bits)) init(0x00012412)  // Gen2, x1, ASPM L0s
    val linkCtrl   = Reg(Bits(16 bits)) init(0x0000)
    val linkStat   = Reg(Bits(16 bits)) init(0x0012)  // Gen2, x1
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

  // BAR hit detection with memory decode enable gating
  val memDecodeEn = regs.command(1)  // Memory Space Enable bit
  for (i <- 0 until 6) {
    val barBase = regs.bar(i) & regs.barMask(i)
    val reqBase = io.barCheckAddr(31 downto 0) & regs.barMask(i)
    io.barHit(i) := memDecodeEn && (regs.barMask(i) =/= 0) && (reqBase === barBase)
  }

  // -------------------------------------------------------
  // Helper functions for config space handling
  // -------------------------------------------------------
  // Merge with byte enable for partial writes
  def mergeBe32(oldData: Bits, newData: Bits, be: Bits): Bits = {
    val result = Bits(32 bits)
    result := oldData
    for (i <- 0 until 4) {
      when(be(i)) {
        result(i*8+7 downto i*8) := newData(i*8+7 downto i*8)
      }
    }
    result
  }

  // BAR read with size probe support
  def barRead(i: Int): Bits = {
    val d = Bits(32 bits)
    d := regs.bar(i).asBits
    when(regs.barProbe(i)) {
      // During probe, return size mask (writable bits)
      d := regs.barMask(i).asBits
    }
    d
  }

  // Command register writable mask
  private val COMMAND_WR_MASK = B"16'h0447"  // IO/MEM/BM/SERR/INTxDisable

  // -------------------------------------------------------
  // Config Read Data MUX (decode DWORD address)
  // Supports full 4KB extended config space
  // -------------------------------------------------------
  def readConfigDword(dwAddr: UInt): Bits = {
    val data = Bits(32 bits)

    switch(dwAddr) {
      // Standard Type 0 Header
      is(0)  { data := (regs.deviceIdReg ## regs.vendorIdReg).asBits }
      is(1)  { data := (regs.status ## regs.command) }
      is(2)  { data := (regs.classCodeReg ## regs.revisionId.asBits) }
      is(3)  { data := (B"8'h00" ## B"8'h00" ## regs.latencyTimer.asBits ## regs.cacheLineSize.asBits) }
      is(4)  { data := barRead(0) }
      is(5)  { data := barRead(1) }
      is(6)  { data := barRead(2) }
      is(7)  { data := barRead(3) }
      is(8)  { data := barRead(4) }
      is(9)  { data := barRead(5) }
      is(10) { data := 0 }  // CardBus CIS Ptr
      is(11) { data := (regs.subSystemId ## regs.subVendorId).asBits }
      is(12) { data := 0 }  // Expansion ROM
      is(13) { data := (B"24'h000000" ## regs.capPointer.asBits) }
      is(14) { data := 0 }  // Reserved
      is(15) { data := (B"8'h00" ## regs.intPin.asBits ## B"8'h00" ## regs.intLine.asBits) }

      // MSI-X Capability (0x40-0x4F in byte address, 0x10-0x13 in dwAddr)
      // Capability header: [15:8]=nextCap, [7:0]=capId
      is(0x10) { data := (B"16'h0000" ## msixCap.nextCap.asBits ## msixCap.capId) }
      is(0x11) { data := (msixCap.msgCtrl ## B"16'h0000") }
      is(0x12) { data := (msixCap.tableOff ## msixCap.tableBIR).asBits }
      is(0x13) { data := (msixCap.pbaOff ## msixCap.pbaBIR).asBits }

      // Power Management Capability (0x50-0x57 in byte address, 0x14-0x17 in dwAddr)
      is(0x14) { data := (B"16'h0000" ## pmCap.nextCap.asBits ## pmCap.capId) }
      is(0x15) { data := (pmCap.pmCapReg ## B"16'h0000") }
      is(0x16) { data := (pmCap.pmData ## pmCap.pmBridgeExt ## pmCap.pmCtrlStat) }

      // PCIe Capability (0x60-0x7F in byte address, 0x18-0x1F in dwAddr)
      is(0x18) { data := (B"16'h0000" ## pcieCap.nextCap.asBits ## pcieCap.capId) }
      is(0x19) { data := (pcieCap.pcieCapReg ## B"16'h0000") }
      is(0x1A) { data := pcieCap.devCap }
      is(0x1B) { data := (pcieCap.devStat ## pcieCap.devCtrl) }
      is(0x1C) { data := pcieCap.linkCap }
      is(0x1D) { data := (pcieCap.linkStat ## pcieCap.linkCtrl) }

      // Extended Config Space (0x40+ in dwAddr)
      default {
        when(isExtDw(dwAddr)) {
          data := extConfigMem.readAsync(extIdx(dwAddr))
        } otherwise {
          // Extended PCIe config space (0x400-0xFFF in byte address)
          // These are advanced extended capabilities - return 0 for now
          data := 0
        }
      }
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
    val dwAddr = req.addr(11 downto 2).asBits.asUInt  // Full 4KB addressing

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

        // Write to writable fields with byte enable handling
        switch(dwAddr) {
          // Command/Status register (addr 0x04, dwAddr 1)
          is(1) {
            val merged = mergeBe32((regs.status ## regs.command), req.data(0), req.firstBe)
            regs.command := (merged(15 downto 0) & COMMAND_WR_MASK)
            // Status bits are W1C (Write 1 to Clear)
            val w1cStatus = merged(31 downto 16)
            regs.status := (regs.status & ~w1cStatus) | B"16'h0010"  // Keep Cap List bit set
          }
          is(3)  { regs.cacheLineSize := req.data(0)(7 downto 0).asUInt }
          // BAR0 with probe support
          is(4) {
            when(req.firstBe === B"4'b1111" && req.data(0) === B"32'hFFFFFFFF") {
              regs.barProbe(0) := True  // Size probe
            } otherwise {
              regs.barProbe(0) := False
              val merged = mergeBe32(regs.bar(0).asBits, req.data(0), req.firstBe).asUInt
              regs.bar(0) := (merged & regs.barMask(0)).resized
            }
          }
          // BAR1 with probe support
          is(5) {
            when(req.firstBe === B"4'b1111" && req.data(0) === B"32'hFFFFFFFF") {
              regs.barProbe(1) := True
            } otherwise {
              regs.barProbe(1) := False
              val merged = mergeBe32(regs.bar(1).asBits, req.data(0), req.firstBe).asUInt
              regs.bar(1) := (merged & regs.barMask(1)).resized
            }
          }
          is(15) {
            regs.intLine := req.data(0)(7 downto 0).asUInt
            regs.intPin  := req.data(0)(15 downto 8).asUInt
          }
          // MSI-X writes
          is(0x11) { msixCap.msgCtrl := req.data(0)(15 downto 0) }
          is(0x12) {
            msixCap.tableOff := req.data(0)(31 downto 3)
            msixCap.tableBIR := req.data(0)(2 downto 0)
          }
          is(0x13) {
            msixCap.pbaOff := req.data(0)(31 downto 3)
            msixCap.pbaBIR := req.data(0)(2 downto 0)
          }
          // PCIe capability writes
          is(0x1B) { pcieCap.devCtrl := req.data(0)(15 downto 0) }
          is(0x1D) { pcieCap.linkCtrl := req.data(0)(15 downto 0) }
          // Extended config space writes
          default {
            when(isExtDw(dwAddr)) {
              extConfigMem.write(extIdx(dwAddr), req.data(0))
            }
          }
        }
      }
      default {}
    }
  }
}
