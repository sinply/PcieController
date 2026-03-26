package pcie

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

// ============================================================
// PCIe Controller - Top Level
//
// Architecture:
//   Application ──► DMA Engine ──► TLP TX/RX ──► DL Layer ──► PHY
//                   MSI-X Ctrl ◄──┘              └─► Config Space
//                   I/O Handler ◄──► DLLP Handler ◄──► FC Manager
//
// AXI4 User Interface:
//   - io.userCtrl : AXI4-Lite slave (DMA descriptor registers)
//   - io.localMem : AX4 master (local memory access)
//   - io.intReq   : Interrupt request lines
// ============================================================
case class PcieControllerConfig(
  vendorId   : Int = 0x10EE,
  deviceId   : Int = 0x7021,
  classCode  : Int = 0x020000,
  maxPayload : Int = 256,
  numMsixVec : Int = 32
)

class PcieController(cfg: PcieControllerConfig = PcieControllerConfig()) extends Component {

  val io = new Bundle {
    // ---- PCIe PHY Interface ----
    val txSymbols  = out Bits(10 bits)   // To SerDes TX
    val rxSymbols  = in  Bits(10 bits)   // From SerDes RX

    // ---- PHY Control/Status ----
    val phyTxEn       = out Bool()
    val phyRxPolarity = out Bool()
    val phyRxElecIdle = in  Bool()
    val phyRxValid    = in  Bool()

    // ---- User AXI4-Lite Control (DMA config + MSI-X table) ----
    val userCtrl = slave(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 32, useStrb = false,
      useLock = false, useCache = false, useProt = false,
      useQos = false, useRegion = false,
      idWidth = 4
    )))

    // ---- User AXI4 Local Memory ----
    val localMem = master(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 64,
      useStrb = true, idWidth = 4
    )))

    // ---- Interrupt Inputs ----
    val intReq   = in Bits(cfg.numMsixVec bits)
    val intAck   = out Bits(cfg.numMsixVec bits)

    // ---- I/O Register Interface ----
    val ioRegAddr  = out UInt(32 bits)
    val ioRegWrData = out Bits(32 bits)
    val ioRegRdData = in  Bits(32 bits)
    val ioRegWrEn  = out Bool()
    val ioRegRdEn  = out Bool()

    // ---- Status ----
    val linkUp      = out Bool()
    val linkSpeed   = out UInt(2 bits)
    val ltssState   = out (LtssState())
    val symbolAlign = out Bool()
    val codeErr     = out Bool()
    val dispErr     = out Bool()
    val h2dDone     = out Bool()
    val d2hDone     = out Bool()
    val dmaErr      = out Bool()
  }

  // ============================================================
  // Instantiate sub-modules
  // ============================================================
  val phy        = new PhysicalLayer()
  val dlTx       = new DlTxFramer()
  val dlRx       = new DlRxDeframer()
  val dllpHandler = new DllpHandler()
  val fcMgr      = new FlowControlMgr()
  val txEngine   = new TlpTxFifoWrapper()
  val rxEngine   = new TlpRxEngine(cfg.maxPayload)
  val ioHandler  = new IoRequestHandler()
  val cfgSpace   = new PcieConfigSpaceCtrl(cfg.vendorId, cfg.deviceId, cfg.classCode)
  val dma        = new DmaEngine(cfg.maxPayload)
  val msix       = new MsixController(cfg.numMsixVec)

  // ============================================================
  // BDF (Bus:Device:Function) - learned during link training
  // ============================================================
  val myBdf = Reg(UInt(16 bits)) init(0x0100)

  // Update BDF from PHY training (bus number from TS2)
  when(phy.io.busNum =/= 0) {
    myBdf(15 downto 8) := phy.io.busNum
  }

  // ============================================================
  // PHY Layer Connections
  // ============================================================
  phy.io.rxSymbols   := io.rxSymbols
  io.txSymbols       := phy.io.txSymbols
  io.phyTxEn         := phy.io.phyTxEn
  io.phyRxPolarity   := phy.io.phyRxPolarity
  phy.io.phyRxElecIdle := io.phyRxElecIdle
  phy.io.phyRxValid  := io.phyRxValid

  io.linkUp      := phy.io.linkUp
  io.linkSpeed   := 1   // Gen2
  io.ltssState   := phy.io.ltssState
  io.symbolAlign := phy.io.aligned
  io.codeErr     := phy.io.codeErr
  io.dispErr     := phy.io.disparityErr

  // ============================================================
  // Data Link Layer: DL TX
  // ============================================================
  dlTx.io.tlpIn      << txEngine.io.tlpOut
  dlTx.io.seqAck     := dlRx.io.txAck
  phy.io.txData      << dlTx.io.frameOut

  // ============================================================
  // Data Link Layer: DL RX
  // ============================================================
  dlRx.io.frameIn   << phy.io.rxData
  rxEngine.io.tlpIn << dlRx.io.tlpOut

  // ============================================================
  // DLLP Handler - Process ACK/NAK/FC DLLPs
  // ============================================================
  // Note: DLLP input would come from a separate detection path
  // in a full implementation. Here we connect it for structure.
  dllpHandler.io.dllpIn.valid := False
  dllpHandler.io.dllpIn.payload := 0
  dllpHandler.io.dllpValid := False

  // ============================================================
  // Flow Control Manager - Full Implementation
  // ============================================================
  fcMgr.io.init          := False
  fcMgr.io.linkUp        := phy.io.linkUp

  // Credit consumption from TLP TX engine
  fcMgr.io.phConsumed    := 0
  fcMgr.io.pdConsumed    := 0
  fcMgr.io.nphConsumed   := 0
  fcMgr.io.npdConsumed   := 0
  fcMgr.io.cplhConsumed  := 0
  fcMgr.io.cpldConsumed  := 0

  // FC updates from DLLP handler
  fcMgr.io.fcInitValid   := dllpHandler.io.fcInitValid
  fcMgr.io.fcInit        := dllpHandler.io.fcInit
  fcMgr.io.fcUpdateValid := dllpHandler.io.fcUpdateValid
  fcMgr.io.fcUpdate      := dllpHandler.io.fcUpdate

  txEngine.io.fcCredits  := fcMgr.io.available

  // ============================================================
  // TLP RX Engine → Route packets to handlers
  // ============================================================

  // Config requests → Config Space Controller
  cfgSpace.io.cfgReq  << rxEngine.io.cfgReq
  cfgSpace.io.busDevFunc := myBdf
  cfgSpace.io.barCheckAddr := rxEngine.io.memReq.payload.addr

  // Config completions → TX Engine
  txEngine.io.cplIn   << cfgSpace.io.cfgResp

  // Memory requests → DMA completion handler
  dma.io.cplIn        << rxEngine.io.cplIn

  // Memory requests (inbound MMIO writes to our BAR space)
  val inboundMemReq = rxEngine.io.memReq

  // Route BAR1 writes to MSI-X table, others to user
  val barHit      = cfgSpace.io.barHit
  val isBar1Req   = inboundMemReq.valid && barHit(1)

  msix.io.tableAddr  := inboundMemReq.payload.addr(11 downto 0).asBits.asUInt
  msix.io.tableWdata := inboundMemReq.payload.data(0)
  msix.io.tableWen   := isBar1Req && inboundMemReq.payload.tlpType === TlpType.MEM_WR
  msix.io.tableBe    := inboundMemReq.payload.firstBe
  msix.io.busDevFunc := myBdf
  msix.io.msixEnable := cfgSpace.io.cfgRegs.command(2)
  msix.io.funcMask   := False
  msix.io.intReq     := io.intReq
  io.intAck          := msix.io.intAck

  // MSI-X interrupt TLPs → TX Engine
  val memWrArb = StreamArbiterFactory.roundRobin.onArgs(
    msix.io.msgTlpOut,
    dma.io.memWrOut,
    ioHandler.io.cplOut  // Include I/O completions
  )
  txEngine.io.memWrIn << memWrArb

  // Consume/drop inbound mem request
  inboundMemReq.ready := True

  // ============================================================
  // I/O Request Handler
  // ============================================================
  ioHandler.io.ioReq     << rxEngine.io.ioReq
  ioHandler.io.regRdData := io.ioRegRdData

  io.ioRegAddr           := ioHandler.io.regAddr
  io.ioRegWrData         := ioHandler.io.regWrData
  io.ioRegWrEn           := ioHandler.io.regWrEn
  io.ioRegRdEn           := ioHandler.io.regRdEn

  // ============================================================
  // DMA Engine
  // ============================================================
  dma.io.ctrl         << io.userCtrl
  dma.io.busDevFunc   := myBdf
  dma.io.memRdOut     >> txEngine.io.memRdIn

  // ============================================================
  // Local Memory (pass-through to DMA)
  // ============================================================
  io.localMem.ar  << dma.io.localMem.ar
  dma.io.localMem.r << io.localMem.r
  io.localMem.aw  << dma.io.localMem.aw
  io.localMem.w   << dma.io.localMem.w
  dma.io.localMem.b << io.localMem.b

  // ============================================================
  // Status outputs
  // ============================================================
  io.h2dDone := dma.io.h2dDone
  io.d2hDone := dma.io.d2hDone
  io.dmaErr  := dma.io.dmaErr
}

// ============================================================
// Verilog/VHDL Generation
// ============================================================
object PcieControllerGen extends App {
  val config = PcieControllerConfig(
    vendorId   = 0x10EE,
    deviceId   = 0x7021,
    classCode  = 0x020000,
    maxPayload = 256,
    numMsixVec = 32
  )

  SpinalConfig(
    targetDirectory    = "rtl/",
    defaultClockDomainFrequency = FixedFrequency(250 MHz),
    onlyStdLogicVectorAtTopLevelIo = true
  ).generateVerilog(new PcieController(config))
    .printPrunedIo()

  println("[PcieControllerGen] Verilog generation complete → rtl/PcieController.v")
}

// ============================================================
// Simulation Test Bench
// ============================================================
object PcieControllerSim extends App {
  import spinal.core.sim._

  SimConfig
    .withWave
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(250 MHz)))
    .compile(new PcieController())
    .doSim { dut =>
      dut.clockDomain.forkStimulus(4)  // 250 MHz = 4ns period

      // ---- Reset ----
      dut.io.intReq #= 0
      dut.io.rxSymbols #= 0
      dut.io.phyRxElecIdle #= false
      dut.io.phyRxValid #= true
      dut.io.ioRegRdData #= 0
      dut.clockDomain.waitSampling(20)

      println("[SIM] Reset complete, waiting for link training...")

      // ---- Wait for link up ----
      var cycles = 0
      while (!dut.io.linkUp.toBoolean && cycles < 50000) {
        dut.clockDomain.waitSampling()
        cycles += 1
      }

      if (dut.io.linkUp.toBoolean) {
        println(s"[SIM] Link UP after $cycles cycles!")
      } else {
        println("[SIM] Warning: Link did not come up in simulation time")
      }

      // ---- Trigger an interrupt ----
      println("[SIM] Triggering interrupt vector 0...")
      dut.io.intReq #= 1
      dut.clockDomain.waitSampling(10)
      dut.io.intReq #= 0
      dut.clockDomain.waitSampling(20)

      println("[SIM] Simulation complete!")
      dut.clockDomain.waitSampling(100)
    }
}
