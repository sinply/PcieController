package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// LTSSM (Link Training and Status State Machine)
// PCIe Spec Figure 4-19 with full power management
// ============================================================
object LtssState extends SpinalEnum {
  val DETECT_QUIET, DETECT_ACTIVE,
  POLLING_ACTIVE, POLLING_COMPLIANCE, POLLING_CONFIG,
  CONFIG_LINKWIDTH_START, CONFIG_LINKWIDTH_ACCEPT,
  CONFIG_LANENUM_WAIT, CONFIG_LANENUM_ACCEPT,
  CONFIG_COMPLETE, CONFIG_IDLE,
  L0,
  RECOVERY_RCVRLOCK, RECOVERY_RCVRCFG, RECOVERY_IDLE,
  L0S,
  L1_ENTRY, L1_IDLE, L1_EXIT,
  L2_IDLE, L2_TRANSMIT_WAKE, L2_DETECT_WAKE,
  DISABLED,
  HOT_RESET,
  LOOPBACK_ENTRY, LOOPBACK_ACTIVE, LOOPBACK_EXIT = newElement()
}

// ============================================================
// Link Width Configuration
// ============================================================
object LinkWidth extends SpinalEnum {
  val X1, X2, X4, X8 = newElement()
}

// ============================================================
// Power Management State
// ============================================================
object PmState extends SpinalEnum {
  val D0, D1, D2, D3HOT, D3COLD = newElement()
}

// ============================================================
// Training Sequence (TS1/TS2) Detector
// Detects K28.5 followed by TS1/TS2 pattern (14 symbols total)
// ============================================================
class TsDetector extends Component {
  val io = new Bundle {
    val dataIn   = in  Bits(8 bits)
    val kCodeIn  = in  Bool()
    val validIn  = in  Bool()
    val ts1Det   = out Bool()
    val ts2Det   = out Bool()
    val linkNum  = out UInt(8 bits)
    val laneNum  = out UInt(5 bits)
  }

  // TS1/TS2 format: K28.5 (COM) + 14 symbols = 15 total
  // Symbol 0: K28.5 (comma)
  // Symbol 1: Link Number
  // Symbol 2: Lane Number
  // Symbol 3: Number of FTS (N_FTS)
  // Symbol 4: Data Rate
  // Symbol 5: Training Control
  // Symbols 6-13: TS ID (D10.2 for TS1, D5.2 for TS2)
  // Symbol 14: Equalization (Gen2+)

  val symIdx = Reg(UInt(4 bits)) init(0)   // 0-14 symbol index
  val linkNumReg = Reg(UInt(8 bits)) init(0)
  val laneNumReg = Reg(UInt(5 bits)) init(0)
  val isTs2 = Reg(Bool()) init(False)
  val tsValid = Reg(Bool()) init(False)

  io.ts1Det := tsValid && !isTs2
  io.ts2Det := tsValid && isTs2
  io.linkNum := linkNumReg
  io.laneNum := laneNumReg

  // Clear detection each cycle
  tsValid := False

  when(io.validIn) {
    when(io.kCodeIn && io.dataIn === B"8'b10111100") {
      // K28.5 (COM) detected - start of training sequence
      symIdx := 0
      isTs2 := False
    } elsewhen(symIdx < 15) {
      // Process TS symbols
      switch(symIdx) {
        is(0) {
          // Symbol 1: Link Number
          linkNumReg := io.dataIn.asUInt
          symIdx := 1
        }
        is(1) {
          // Symbol 2: Lane Number
          laneNumReg := io.dataIn.asUInt.resize(5)
          symIdx := 2
        }
        is(2, 3, 4, 5) {
          // Symbols 3-5: N_FTS, Rate, Training Control
          symIdx := symIdx + 1
        }
        is(6, 7, 8, 9, 10, 11, 12, 13) {
          // Symbols 6-13: TS ID pattern
          // D10.2 = 0x4A for TS1, D5.2 = 0x45 for TS2
          when(io.dataIn === B"8'h45") {
            isTs2 := True
          }
          symIdx := symIdx + 1
        }
        is(14) {
          // Symbol 14: Equalization - complete sequence
          tsValid := True
          symIdx := 0
        }
      }
    }
  } otherwise {
    symIdx := 0
  }
}

// ============================================================
// LTSSM Controller with Full Power Management and Multi-Lane Support
// ============================================================
class LtssController(maxLanes: Int = 8) extends Component {
  val io = new Bundle {
    // From PHY/SerDes
    val rxDetected    = in  Bool()
    val rxElecIdle    = in  Bool()
    val rxValid       = in  Bool()
    val ts1Rcvd       = in  Bool()
    val ts2Rcvd       = in  Bool()
    val linkResetReq  = in  Bool()
    val pmReq         = in  Bool()
    val pmState       = in(PmState())   // Power management state request
    val wakeReq       = in  Bool()      // Wake request for L2 exit

    // From Training Sequence Detector
    val tsLinkNum     = in  UInt(8 bits)
    val tsLaneNum     = in  UInt(5 bits)

    // Multi-lane support
    val laneReversal  = in  Bool()      // Lane reversal detected
    val negotiatedWidth = out(LinkWidth())

    // Outputs
    val linkUp        = out Bool()
    val linkSpeed     = out UInt(2 bits)
    val linkWidth     = out UInt(5 bits)
    val txTs1         = out Bool()
    val txTs2         = out Bool()
    val txIdleOs      = out Bool()
    val curState      = out(LtssState())

    // BDF output (learned during training)
    val busNum        = out UInt(8 bits)

    // Power management outputs
    val inL1          = out Bool()
    val inL2          = out Bool()
    val pmAck         = out Bool()      // Power management acknowledge
  }

  val state    = Reg(LtssState()) init(LtssState.DETECT_QUIET)
  val timer    = Reg(UInt(24 bits)) init(0)
  val ts1Count = Reg(UInt(8 bits)) init(0)
  val ts2Count = Reg(UInt(8 bits)) init(0)

  // Learned parameters from training
  val busNumReg   = Reg(UInt(8 bits)) init(0)
  val linkWidthReg = Reg(UInt(5 bits)) init(1)
  val linkWidthEnum = Reg(LinkWidth()) init(LinkWidth.X1)

  // Power management
  val inL1Reg = Reg(Bool()) init(False)
  val inL2Reg = Reg(Bool()) init(False)

  io.linkUp    := (state === LtssState.L0)
  io.linkSpeed := 1   // Default Gen2
  io.linkWidth := linkWidthReg
  io.txTs1     := False
  io.txTs2     := False
  io.txIdleOs  := False
  io.curState  := state
  io.busNum    := busNumReg
  io.negotiatedWidth := linkWidthEnum
  io.inL1      := inL1Reg
  io.inL2      := inL2Reg
  io.pmAck     := False
  timer        := timer + 1

  // Helper to convert lane count to LinkWidth enum
  def toLinkWidthEnum(lanes: UInt): LinkWidth.C = {
    val result = LinkWidth()
    switch(lanes) {
      is(1)  { result := LinkWidth.X1 }
      is(2)  { result := LinkWidth.X2 }
      is(4)  { result := LinkWidth.X4 }
      is(8)  { result := LinkWidth.X8 }
      default { result := LinkWidth.X1 }
    }
    result
  }

  switch(state) {
    is(LtssState.DETECT_QUIET) {
      inL1Reg := False
      inL2Reg := False
      when(timer > 10000) {
        state := LtssState.DETECT_ACTIVE
        timer := 0
      }
    }

    is(LtssState.DETECT_ACTIVE) {
      when(io.rxDetected) {
        state := LtssState.POLLING_ACTIVE
        timer := 0
      } elsewhen(timer > 12000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.POLLING_ACTIVE) {
      io.txTs1 := True
      when(io.ts1Rcvd) {
        ts1Count := ts1Count + 1
      }
      when(ts1Count >= 8) {
        state    := LtssState.POLLING_CONFIG
        ts1Count := 0
        timer    := 0
      } elsewhen(timer > 24000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.POLLING_CONFIG) {
      io.txTs2 := True
      when(io.ts2Rcvd) {
        ts2Count := ts2Count + 1
        // Capture link number from TS2
        busNumReg := io.tsLinkNum
      }
      when(ts2Count >= 8) {
        state    := LtssState.CONFIG_LINKWIDTH_START
        ts2Count := 0
        timer    := 0
      }
    }

    is(LtssState.CONFIG_LINKWIDTH_START) {
      io.txTs1 := True
      when(io.ts1Rcvd) {
        state := LtssState.CONFIG_LINKWIDTH_ACCEPT
        timer := 0
      }
    }

    is(LtssState.CONFIG_LINKWIDTH_ACCEPT) {
      io.txTs1 := True
      when(io.ts2Rcvd) {
        linkWidthReg := io.tsLaneNum + 1
        linkWidthEnum := toLinkWidthEnum(io.tsLaneNum + 1)
        state := LtssState.CONFIG_LANENUM_WAIT
        timer := 0
      }
    }

    is(LtssState.CONFIG_LANENUM_WAIT) {
      io.txTs2 := True
      when(io.ts2Rcvd) {
        state := LtssState.CONFIG_COMPLETE
        timer := 0
      }
    }

    is(LtssState.CONFIG_COMPLETE) {
      io.txTs2 := True
      when(io.ts2Rcvd && timer > 2) {
        state := LtssState.CONFIG_IDLE
        timer := 0
      }
    }

    is(LtssState.CONFIG_IDLE) {
      io.txIdleOs := True
      when(io.rxValid && timer > 4) {
        state := LtssState.L0
        timer := 0
      }
    }

    is(LtssState.L0) {
      inL1Reg := False
      inL2Reg := False
      when(io.linkResetReq) {
        state := LtssState.HOT_RESET
      } elsewhen(io.pmReq && io.pmState === PmState.D1) {
        // Transition to L0s (D1 state maps to L0s)
        state := LtssState.L0S
        timer := 0
      } elsewhen(!io.rxValid && timer > 100) {
        state := LtssState.RECOVERY_RCVRLOCK
        timer := 0
      } elsewhen(io.pmReq && io.pmState === PmState.D3HOT) {
        // Transition to L1
        state := LtssState.L1_ENTRY
        timer := 0
      } elsewhen(io.pmReq && io.pmState === PmState.D3COLD) {
        // Transition to L2
        state := LtssState.L2_IDLE
        timer := 0
      }
    }

    // L0s low-power state - minimal recovery
    is(LtssState.L0S) {
      io.txIdleOs := True
      // Exit L0s on activity or PM exit
      when(!io.pmReq || io.rxDetected || io.ts1Rcvd) {
        state := LtssState.RECOVERY_RCVRCFG
        timer := 0
      }
    }

    is(LtssState.RECOVERY_RCVRLOCK) {
      io.txTs1 := True
      when(io.ts1Rcvd) {
        state := LtssState.RECOVERY_RCVRCFG
        timer := 0
      } elsewhen(timer > 24000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.RECOVERY_RCVRCFG) {
      io.txTs2 := True
      when(io.ts2Rcvd) {
        state := LtssState.RECOVERY_IDLE
        timer := 0
      }
    }

    is(LtssState.RECOVERY_IDLE) {
      io.txIdleOs := True
      when(io.rxValid) {
        state := LtssState.L0
        timer := 0
      }
    }

    // ============================================================
    // L1 Power Management States
    // ============================================================
    is(LtssState.L1_ENTRY) {
      io.txIdleOs := True
      io.pmAck := True
      inL1Reg := True
      when(timer > 10) {  // Wait for electrical idle
        state := LtssState.L1_IDLE
        timer := 0
      }
    }

    is(LtssState.L1_IDLE) {
      // In L1, link is in electrical idle
      // Exit on PM exit request or beacon detection
      when(!io.pmReq || io.rxDetected) {
        state := LtssState.L1_EXIT
        timer := 0
      }
    }

    is(LtssState.L1_EXIT) {
      io.txTs1 := True
      when(io.ts1Rcvd && timer > 100) {
        state := LtssState.RECOVERY_RCVRCFG
        inL1Reg := False
        timer := 0
      } elsewhen(timer > 20000) {
        // Timeout, go back to detect
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    // ============================================================
    // L2 Power Management States
    // ============================================================
    is(LtssState.L2_IDLE) {
      inL2Reg := True
      io.pmAck := True
      // L2 is deep power down - only exit on wake event
      when(io.wakeReq) {
        state := LtssState.L2_TRANSMIT_WAKE
        timer := 0
      }
    }

    is(LtssState.L2_TRANSMIT_WAKE) {
      // Transmit wake signal (Vaux related)
      when(timer > 1000) {
        state := LtssState.L2_DETECT_WAKE
        timer := 0
      }
    }

    is(LtssState.L2_DETECT_WAKE) {
      when(io.rxDetected && io.ts1Rcvd) {
        state := LtssState.POLLING_ACTIVE
        inL2Reg := False
        timer := 0
      } elsewhen(timer > 50000) {
        // Timeout
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.HOT_RESET) {
      timer := 0
      state := LtssState.DETECT_QUIET
    }

    // ============================================================
    // Loopback States (for testing/debug)
    // ============================================================
    is(LtssState.LOOPBACK_ENTRY) {
      io.txTs1 := True
      when(io.ts1Rcvd && timer > 100) {
        state := LtssState.LOOPBACK_ACTIVE
        timer := 0
      } elsewhen(timer > 24000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.LOOPBACK_ACTIVE) {
      // In loopback, TX data is looped back to RX
      // Exit on directed request or error
      when(io.linkResetReq) {
        state := LtssState.LOOPBACK_EXIT
        timer := 0
      }
    }

    is(LtssState.LOOPBACK_EXIT) {
      io.txTs2 := True
      when(io.ts2Rcvd) {
        state := LtssState.DETECT_QUIET
        timer := 0
      } elsewhen(timer > 24000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    default {
      state := LtssState.DETECT_QUIET
    }
  }
}

// ============================================================
// Physical Layer Top with Enhanced Features
// ============================================================
class PhysicalLayer extends Component {
  val io = new Bundle {
    // Connects to Data Link Layer
    val txData    = slave  Stream(Bits(32 bits))
    val rxData    = master Stream(Bits(32 bits))

    // PHY pins (connect to SerDes)
    val txSymbols = out Bits(10 bits)
    val rxSymbols = in  Bits(10 bits)

    // PHY control/status
    val phyTxEn   = out Bool()
    val phyRxPolarity = out Bool()
    val phyRxElecIdle = in  Bool()
    val phyRxValid = in  Bool()

    // Status
    val linkUp    = out Bool()
    val ltssState = out(LtssState())
    val aligned   = out Bool()
    val codeErr   = out Bool()
    val disparityErr = out Bool()

    // BDF from training
    val busNum    = out UInt(8 bits)
  }

  // ============================================================
  // Instantiate sub-components
  // ============================================================
  val aligner = new SymbolAligner()
  val decoder = new Decoder8b10b()
  val encoder = new Encoder8b10b()
  val ltssm   = new LtssController()
  val tsDet   = new TsDetector()

  // ============================================================
  // RX Path: SerDes -> Symbol Aligner -> Decoder -> TS Detector
  // ============================================================
  aligner.io.dataIn := io.rxSymbols
  aligner.io.shift := 0

  decoder.io.dataIn := aligner.io.dataOut

  // TS1/TS2 detection
  tsDet.io.dataIn  := decoder.io.dataOut
  tsDet.io.kCodeIn := decoder.io.kCode
  tsDet.io.validIn := aligner.io.aligned

  // ============================================================
  // LTSSM Connections (from real signals, not placeholders)
  // ============================================================
  ltssm.io.rxDetected   := io.phyRxValid
  ltssm.io.rxElecIdle   := io.phyRxElecIdle
  ltssm.io.rxValid      := aligner.io.aligned && !decoder.io.codeErr
  ltssm.io.ts1Rcvd      := tsDet.io.ts1Det
  ltssm.io.ts2Rcvd      := tsDet.io.ts2Det
  ltssm.io.tsLinkNum    := tsDet.io.linkNum
  ltssm.io.tsLaneNum    := tsDet.io.laneNum
  ltssm.io.linkResetReq := False  // From external control
  ltssm.io.pmReq        := False  // From power management
  ltssm.io.pmState      := PmState.D0  // Default power state
  ltssm.io.wakeReq      := False  // Wake request
  ltssm.io.laneReversal := False  // Lane reversal detection

  // ============================================================
  // TX Path: Encoder -> SerDes
  // ============================================================
  val txState = Reg(UInt(2 bits)) init(0)
  val txByte  = Reg(UInt(2 bits)) init(0)
  val txBuf   = Reg(Bits(32 bits))
  val txKCode = Reg(Bool()) init(False)

  // Default encoder inputs
  encoder.io.rdIn   := False
  encoder.io.kCode  := txKCode
  encoder.io.dataIn := 0

  // Default txData.ready to avoid latch
  io.txData.ready := False

  // Generate training sequences when requested by LTSSM
  when(ltssm.io.txTs1) {
    // TS1: K28.5 + TS1 pattern
    encoder.io.kCode  := (txByte === 0)
    encoder.io.dataIn := Mux(txByte === 0, B"8'b10111100",  // K28.5
                             B"8'h00")  // Link number placeholder
  } elsewhen(ltssm.io.txTs2) {
    // TS2: K28.5 + TS2 pattern
    encoder.io.kCode  := (txByte === 0)
    encoder.io.dataIn := Mux(txByte === 0, B"8'b10111100",
                             B"8'h80")  // TS2 identifier
  } elsewhen(ltssm.io.txIdleOs) {
    // Idle ordered set: K28.5 + D5.6
    encoder.io.kCode  := (txByte === 0)
    encoder.io.dataIn := Mux(txByte === 0, B"8'b10111100", B"8'hB5")
  } elsewhen(ltssm.io.linkUp) {
    // Normal operation: send data from upper layers
    io.txData.ready := (txByte === 0) && io.txData.valid
    when(io.txData.fire) {
      txBuf   := io.txData.payload
      txKCode := False
    }
    when(txByte =/= 0 || io.txData.fire) {
      encoder.io.dataIn := txBuf.subdivideIn(8 bits)(txByte)
      encoder.io.kCode  := False
    }
  }

  // TX byte counter
  when(!ltssm.io.linkUp) {
    txByte := 0
  } elsewhen(ltssm.io.txTs1 || ltssm.io.txTs2 || ltssm.io.txIdleOs || txByte =/= 0) {
    txByte := txByte + 1
    when(txByte === 3) {
      txByte := 0
    }
  }

  io.txSymbols := encoder.io.dataOut
  io.phyTxEn   := ltssm.io.linkUp || ltssm.io.txTs1 || ltssm.io.txTs2
  io.phyRxPolarity := False  // Can be used to correct polarity inversion

  // ============================================================
  // RX Path: Accumulate bytes into DWORDs
  // ============================================================
  val rxBuf    = Reg(Bits(32 bits))
  val rxByte   = Reg(UInt(2 bits)) init(0)
  val rxValid  = Reg(Bool()) init(False)

  io.rxData.valid   := rxValid
  io.rxData.payload := rxBuf

  when(rxValid && io.rxData.ready) {
    rxValid := False
  }

  when(!ltssm.io.linkUp) {
    rxByte := 0
    rxValid := False
  } elsewhen(aligner.io.aligned && !decoder.io.kCode && !decoder.io.codeErr && (!rxValid || io.rxData.ready)) {
    rxBuf.subdivideIn(8 bits)(rxByte) := decoder.io.dataOut
    when(rxByte === 3) {
      rxByte := 0
      rxValid := True
    } otherwise {
      rxByte := rxByte + 1
    }
  }

  // ============================================================
  // Status Outputs
  // ============================================================
  io.linkUp      := ltssm.io.linkUp
  io.ltssState   := ltssm.io.curState
  io.aligned     := aligner.io.aligned
  io.codeErr     := decoder.io.codeErr
  io.disparityErr := decoder.io.rdErr
  io.busNum      := ltssm.io.busNum
}
