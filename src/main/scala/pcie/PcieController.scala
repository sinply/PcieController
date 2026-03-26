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
//
// AXI4 User Interface:
//   - io.userAxi  : AXI4 slave (user reads/writes host memory via DMA)
//   - io.userCtrl : AXI4-Lite slave (DMA descriptor registers)
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

        // ---- User AXI4-Lite Control (DMA config + MSI-X table) ----
        val userCtrl = slave(Axi4(Axi4Config(
            addressWidth = 32, dataWidth = 32, useStrb = false,
            useLock = false, useCache = false, useProt = false,
            useQos = false, useRegion = false,
            idWidth = 4      // 根据你的设计需求设置，常见值 1~8
        )))

        // ---- User AXI4 Local Memory ----
        val localMem = master(Axi4(Axi4Config(
            addressWidth = 32, dataWidth = 64,
            useStrb = true, idWidth = 4
        )))

        // ---- Interrupt Inputs ----
        val intReq   = in Bits(cfg.numMsixVec bits)
        val intAck   = out Bits(cfg.numMsixVec bits)

        // ---- Status ----
        val linkUp    = out Bool()
        val linkSpeed = out UInt(2 bits)
        val ltssState = out (LtssState())
        val h2dDone   = out Bool()
        val d2hDone   = out Bool()
        val dmaErr    = out Bool()
    }

    // ============================================================
    // Instantiate sub-modules
    // ============================================================
    val phy      = new PhysicalLayer()
    val dlTx     = new DlTxFramer()
    val dlRx     = new DlRxDeframer()
    val fcMgr    = new FlowControlMgr()
    val txEngine = new TlpTxFifoWrapper()
    val rxEngine = new TlpRxEngine()
    val cfgSpace = new PcieConfigSpaceCtrl(cfg.vendorId, cfg.deviceId, cfg.classCode)
    val dma      = new DmaEngine(cfg.maxPayload)
    val msix     = new MsixController(cfg.numMsixVec)

    // ============================================================
    // BDF (Bus:Device:Function) - set during config by Root Complex
    // In a real design this comes from TS1/TS2 ordered sets
    // ============================================================
    val myBdf = Reg(UInt(16 bits)) init(0x0100)  // Bus=0, Dev=0, Func=0

    // ============================================================
    // PHY Layer Connections
    // ============================================================
    phy.io.rxSymbols := io.rxSymbols
    io.txSymbols     := phy.io.txSymbols
    io.linkUp        := phy.io.linkUp
    io.linkSpeed     := 1   // Gen2
    io.ltssState     := phy.io.ltssState

    // ============================================================
    // Data Link Layer: DL TX
    // PHY ──► DlTxFramer ──► PHY TX
    // ============================================================
    dlTx.io.tlpIn      << txEngine.io.tlpOut
    dlTx.io.seqAck     := dlRx.io.txAck
    phy.io.txData      << dlTx.io.frameOut

    // ============================================================
    // Data Link Layer: DL RX
    // PHY RX ──► DlRxDeframer ──► TLP RX Engine
    // ============================================================
    dlRx.io.frameIn   << phy.io.rxData
    rxEngine.io.tlpIn << dlRx.io.tlpOut

    // ============================================================
    // Flow Control Manager (PARTIAL IMPLEMENTATION)
    // ============================================================
    // NOTE: Flow control update processing is not fully implemented.
    // In PCIe, FC credits are consumed when sending TLPs and restored
    // when receiving FC update DLLPs from the link partner.
    //
    // Current limitations:
    // - FC update DLLPs are not processed (fcUpdateValid always False)
    // - Credit consumption tracking is not connected
    // - Credits will eventually run out in sustained traffic
    //
    // For production, implement:
    // 1. FC DLLP reception in Data Link Layer
    // 2. Parse FC credits from received DLLPs
    // 3. Update fcMgr.io.fcUpdate with parsed credits
    // 4. Track consumed credits from TLP TX
    // ============================================================
    fcMgr.io.init          := False
    fcMgr.io.phConsumed    := 0
    fcMgr.io.nphConsumed   := 0
    fcMgr.io.cplhConsumed  := 0
    fcMgr.io.fcUpdateValid := False
    fcMgr.io.fcUpdate.assignDontCare()
    txEngine.io.fcCredits  := fcMgr.io.available

    // ============================================================
    // TLP RX Engine → Route packets to handlers
    // ============================================================

    // Config requests → Config Space Controller
    cfgSpace.io.cfgReq  << rxEngine.io.cfgReq
    cfgSpace.io.busDevFunc := myBdf
    cfgSpace.io.barCheckAddr := rxEngine.io.memReq.payload.addr

    // Config completions → TX Engine (send back to Root Complex)
    txEngine.io.cplIn   << cfgSpace.io.cfgResp

    // Memory requests → DMA completion handler
    dma.io.cplIn        << rxEngine.io.cplIn

    // Memory requests (inbound MMIO writes to our BAR space)
    // In this design, forward to MSI-X table if addr matches BAR1
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
    // MSI-X and DMA memory writes share TX MEM_WR input via arbiter
    val memWrArb = StreamArbiterFactory.roundRobin.onArgs(
      msix.io.msgTlpOut,
      dma.io.memWrOut
    )
    txEngine.io.memWrIn << memWrArb
    // Consume/drop inbound mem request
    inboundMemReq.ready := True

    // I/O requests (NOT IMPLEMENTED)
    // NOTE: I/O space requests are dropped without response.
    // For production, implement:
    // 1. I/O read/write handling
    // 2. Completion generation for I/O reads
    // 3. I/O address decoding
    rxEngine.io.ioReq.ready := True

    // ============================================================
    // DMA Engine
    // ============================================================
    dma.io.ctrl         << io.userCtrl
    dma.io.busDevFunc   := myBdf
    dma.io.memRdOut     >> txEngine.io.memRdIn

    // ============================================================
    // Local Memory (pass-through to DMA)
    // ============================================================
    // Connect DMA local memory AXI to user local memory slave port
    // In a full design this would go through an AXI interconnect
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
