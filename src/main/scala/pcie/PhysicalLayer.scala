package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// Simplified 8b/10b Encoder (PLACEHOLDER IMPLEMENTATION)
// ============================================================
// WARNING: This is a simplified placeholder that does NOT perform
// real 8b/10b encoding. It simply passes 8-bit data as 10-bit output.
//
// For production use, you must replace this with:
// 1. A full 8b/10b encoder with running disparity tracking, OR
// 2. Native SerDes encoding (e.g., Xilinx GTX/GTH 8b/10b mode)
//
// Real 8b/10b encoding requirements:
// - Full lookup tables for all 256 data bytes + 12 K-codes
// - Running disparity (RD) tracking for DC-balance
// - Control symbol generation (K28.5, K27.7, etc.)
// ============================================================
class Encoder8b10b extends Component {
  val io = new Bundle {
    val dataIn  = in  Bits(8 bits)
    val kCode   = in  Bool()
    val dataOut = out Bits(10 bits)
    val rdOut   = out Bool()   // Running disparity out
    val rdIn    = in  Bool()   // Running disparity in
  }
  // PLACEHOLDER: Just pass through data without real encoding
  // Real implementation would use lookup tables and RD tracking
  io.dataOut := io.dataIn.resize(10)
  io.rdOut   := io.rdIn ^ io.dataIn.xorR
}

// ============================================================
// Simplified 8b/10b Decoder (PLACEHOLDER IMPLEMENTATION)
// ============================================================
// WARNING: This is a simplified placeholder that does NOT perform
// real 8b/10b decoding. It assumes data is already decoded.
//
// For production use, you must replace this with:
// 1. A full 8b/10b decoder with disparity error detection, OR
// 2. Native SerDes decoding (e.g., Xilinx GTX/GTH 8b/10b mode)
//
// Real 8b/10b decoding requirements:
// - Full lookup tables for all valid 10-bit codes
// - Running disparity checking
// - Disparity error detection
// - Code error detection for invalid symbols
// ============================================================
class Decoder8b10b extends Component {
  val io = new Bundle {
    val dataIn   = in  Bits(10 bits)
    val dataOut  = out Bits(8 bits)
    val kCode    = out Bool()
    val codeErr  = out Bool()
    val rdErr    = out Bool()
  }
  // PLACEHOLDER: Just extract lower 8 bits without real decoding
  io.dataOut := io.dataIn(7 downto 0)
  io.kCode   := io.dataIn(9) & io.dataIn(8)
  io.codeErr := False  // Would detect invalid symbols in real impl
  io.rdErr   := False  // Would detect disparity errors in real impl
}

// ============================================================
// LTSSM (Link Training and Status State Machine)
// PCIe Spec Figure 4-19
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
  L1_ENTRY, L1_IDLE,
  L2_IDLE,
  DISABLED,
  HOT_RESET,
  LOOPBACK_ENTRY, LOOPBACK_ACTIVE, LOOPBACK_EXIT = newElement()
}

class LtssController extends Component {
  val io = new Bundle {
    val rxDetected    = in  Bool()
    val rxElecIdle    = in  Bool()
    val rxValid       = in  Bool()
    val ts1Rcvd       = in  Bool()
    val ts2Rcvd       = in  Bool()
    val linkResetReq  = in  Bool()
    val pmReq         = in  Bool()   // Power management request

    val linkUp        = out Bool()
    val linkSpeed     = out UInt(2 bits)   // 0=Gen1, 1=Gen2, 2=Gen3
    val linkWidth     = out UInt(5 bits)   // Active lanes
    val txTs1         = out Bool()
    val txTs2         = out Bool()
    val txIdleOs      = out Bool()
    val curState      = out (LtssState())
  }

  val state    = Reg(LtssState()) init(LtssState.DETECT_QUIET)
  val timer    = Reg(UInt(24 bits)) init(0)
  val ts1Count = Reg(UInt(8 bits))  init(0)
  val ts2Count = Reg(UInt(8 bits))  init(0)

  io.linkUp    := (state === LtssState.L0)
  io.linkSpeed := 1   // Default Gen2
  io.linkWidth := 1   // x1
  io.txTs1     := False
  io.txTs2     := False
  io.txIdleOs  := False
  io.curState  := state
  timer        := timer + 1

  switch(state) {

    // -------- DETECT --------
    is(LtssState.DETECT_QUIET) {
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

    // -------- POLLING --------
    is(LtssState.POLLING_ACTIVE) {
      io.txTs1 := True
      ts1Count := ts1Count + io.ts1Rcvd.asUInt.resized
      when(ts1Count >= 8) {
        state    := LtssState.POLLING_CONFIG
        ts1Count := 0
        ts2Count := 0
        timer    := 0
      } elsewhen(timer > 24000) {
        state := LtssState.DETECT_QUIET
        timer := 0
      }
    }

    is(LtssState.POLLING_CONFIG) {
      io.txTs2 := True
      ts2Count := ts2Count + io.ts2Rcvd.asUInt.resized
      when(ts2Count >= 8) {
        state    := LtssState.CONFIG_LINKWIDTH_START
        ts2Count := 0
        timer    := 0
      }
    }

    // -------- CONFIG --------
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

    // -------- L0 (Normal Operation) --------
    is(LtssState.L0) {
      when(io.linkResetReq) {
        state := LtssState.HOT_RESET
      } elsewhen(!io.rxValid && timer > 100) {
        state := LtssState.RECOVERY_RCVRLOCK
        timer := 0
      } elsewhen(io.pmReq) {
        state := LtssState.L1_ENTRY
      }
    }

    // -------- RECOVERY --------
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

    // -------- L1 Power Management --------
    is(LtssState.L1_ENTRY) {
      state := LtssState.L1_IDLE
    }

    is(LtssState.L1_IDLE) {
      when(!io.pmReq) {
        state := LtssState.RECOVERY_RCVRLOCK
      }
    }

    // -------- HOT RESET --------
    is(LtssState.HOT_RESET) {
      timer := 0
      state := LtssState.DETECT_QUIET
    }

    default {
      state := LtssState.DETECT_QUIET
    }
  }
}

// ============================================================
// Physical Layer Top
// ============================================================
class PhysicalLayer extends Component {
  val io = new Bundle {
    // Connects to Data Link Layer
    val txData    = slave  Stream(Bits(32 bits))
    val rxData    = master Stream(Bits(32 bits))

    // "PHY" pins (would connect to SerDes IP in real design)
    val txSymbols = out Bits(10 bits)
    val rxSymbols = in  Bits(10 bits)

    // Status
    val linkUp    = out Bool()
    val ltssState = out (LtssState())
  }

  val ltssm = new LtssController()
  val enc   = new Encoder8b10b()
  val dec   = new Decoder8b10b()

  // ============================================================
  // LTSSM Inputs (PLACEHOLDER - requires SerDes integration)
  // ============================================================
  // WARNING: These inputs are hardcoded placeholders for simulation.
  // In a real design, these must come from the SerDes PHY:
  // - rxDetected: Receiver detection from PHY
  // - rxElecIdle: Electrical idle detection
  // - rxValid: Valid symbol alignment
  // - ts1Rcvd/ts2Rcvd: Training sequence detection
  //
  // For production, implement:
  // 1. TS1/TS2 ordered set detection and parsing
  // 2. Symbol alignment logic
  // 3. Link number and lane negotiation
  // 4. Speed change handshake
  // ============================================================
  ltssm.io.rxDetected   := True  // PLACEHOLDER: Should come from PHY
  ltssm.io.rxElecIdle   := False // PLACEHOLDER: Should come from PHY
  ltssm.io.rxValid      := True  // PLACEHOLDER: Should come from PHY
  ltssm.io.ts1Rcvd      := True  // PLACEHOLDER: Detect K28.5 + TS1 data
  ltssm.io.ts2Rcvd      := True  // PLACEHOLDER: Detect K28.5 + TS2 data
  ltssm.io.linkResetReq := False
  ltssm.io.pmReq        := False

  io.linkUp    := ltssm.io.linkUp
  io.ltssState := ltssm.io.curState

  // TX path: only send data in L0
  val txByte   = Reg(UInt(2 bits)) init(0)
  val txBuf    = Reg(Bits(32 bits))
  val txActive = Reg(Bool()) init(False)

  enc.io.rdIn   := False  // simplified
  enc.io.kCode  := False
  enc.io.dataIn := 0

  io.txData.ready := False

  when(ltssm.io.linkUp) {
    when(!txActive && io.txData.valid) {
      txBuf    := io.txData.payload
      txActive := True
      txByte   := 0
      io.txData.ready := True
    }
    when(txActive) {
      enc.io.dataIn :=  txBuf.subdivideIn(8 bits)(txByte) // txBuf(txByte * 8 + 7 downto txByte * 8)
      txByte := txByte + 1
      when(txByte === 3) {
        txActive := False
      }
    }
  }

  io.txSymbols := enc.io.dataOut

  // RX path
  dec.io.dataIn := io.rxSymbols

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
  }

  when(ltssm.io.linkUp && !dec.io.kCode && !dec.io.codeErr && (!rxValid || io.rxData.ready)) {
    rxBuf.subdivideIn(8 bits)(rxByte) := dec.io.dataOut
    when(rxByte === 3) {
      rxByte := 0
      rxValid := True
    } otherwise {
      rxByte := rxByte + 1
    }
  }
}
