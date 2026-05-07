# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Build Commands

```bash
# Compile the project
sbt compile

# Generate Verilog output to rtl/PcieController.v
sbt "runMain pcie.PcieControllerGen"

# Run simulation
sbt "runMain pcie.PcieControllerSim"

# Run tests
sbt test

# Run a specific test class
sbt "testOnly pcie.PcieControllerTest"
sbt "testOnly pcie.Encoder8b10bFuncTest"
sbt "testOnly pcie.LtssmTest"
```

## Architecture Overview

```
Application Layer
    ├── DMA Engine (scatter-gather for host memory access)
    ├── MSI-X Controller (interrupt handling)
    ├── Config Space Controller (Type 0 header, BAR decode, capabilities)
    └── I/O/BAR0 Request Handler (I/O completions and BAR0 register access)
         │
Transaction Layer
    ├── TlpTxEngine (TLP transmission with flow control)
    └── TlpRxEngine (TLP parsing and routing)
         │
Data Link Layer
    ├── DlTxFramer (TLP framing with CRC-32, sequence numbers)
    ├── DlRxDeframer (TLP deframing, ACK/NAK handling)
    └── DllpHandler (flow control DLLPs)
         │
Physical Layer
    ├── Encoder8b10b / Decoder8b10b (8b/10b with running disparity)
    ├── SymbolAligner (K28.5 comma detection)
    └── LtssController (link training state machine)
```

## Key SpinalHDL Patterns

### Vec in Objects: Use `def` Not `val`
Global `val` Vec definitions cause "OLD NETLIST RE-USED" errors because the hardware is created once and reused across elaborations. Use `def` to create fresh instances:

```scala
// WRONG - causes OLD NETLIST RE-USED error
object Encoder8b10bTables {
  val data5b6b: Vec[Bits] = Vec(...)  // Created once, reused incorrectly
}

// CORRECT - creates fresh hardware each call
object Encoder8b10bTables {
  def data5b6b: Vec[Bits] = Vec(...)  // Fresh Vec each time
}
```

### Read-Only Registers Need Self-Assignment
SpinalHDL warns about UNASSIGNED REGISTER for read-only registers. Add self-assignments:

```scala
val vendorIdReg = Reg(UInt(16 bits)) init(0x10EE)
vendorIdReg := vendorIdReg  // Prevents UNASSIGNED REGISTER warning
```

### Avoid Latches with Default Assignments
Signals only assigned in conditional blocks cause LATCH DETECTED errors. Set defaults before conditionals:

```scala
io.txData.ready := False  // Default prevents latch
when(someCondition) {
  io.txData.ready := True
}
```

### Width Mismatch in Cross-Width Operations
When mixing 64-bit and 32-bit values, extract/resize appropriately:

```scala
// For 4KB boundary calculation on 64-bit address
val addrLower32 = (fullAddr + offset)(31 downto 0)  // Extract lower 32 bits
val bytesTo4k = U(4096, 32 bits) - (addrLower32 & U(4095, 32 bits))
```

## Project Structure

- `src/main/scala/pcie/` - Main source files
  - `PcieController.scala` - Top-level module and config
  - `PcieTypes.scala` - TLP types, bundles, enums
  - `PhysicalLayer.scala` - PHY, LTSSM, encoder/decoder
  - `Encoder8b10b.scala` - 8b/10b codec with disparity
  - `DataLinkLayer.scala` - DL framing, DLLP handling
  - `TlpTxEngine.scala` - Transaction layer TX
  - `TlpRxEngine.scala` - Transaction layer RX, I/O handler
  - `ConfigSpaceCtrl.scala` - PCIe config space
  - `DmaEngine.scala` - Scatter-gather DMA
  - `MsixController.scala` - MSI-X interrupt controller

- `src/test/scala/pcie/` - Test suite
- `rtl/` - Generated Verilog output

## Known Issues

- Full `sbt test` can run for a long time because some simulations contain broad wait loops; use targeted `testOnly` filters during development.
- SpinalHDL may warn that generated async `Mem.readAsync` blocks are emitted as write-first memories in Verilog; this is expected for the current generated RTL.
- Many top-level debug/status fields are pruned by Verilog generation because they are not consumed by downstream logic.

## PCIe Configuration

Default configuration in `PcieControllerConfig`:
- vendorId: 0x10EE (Xilinx)
- deviceId: 0x7021
- classCode: 0x020000 (Network Controller)
- maxPayload: 256 bytes
- numMsixVec: 32

BAR0: 4KB (device registers via `ioReg*`), BAR1: 64KB (MSI-X table/PBA)

## Design Documents

- `docs/INTERFACE_DESIGN.md` - top-level IO, AXI interfaces, BAR apertures, interrupts, and internal TLP packet fields
- `docs/ARCHITECTURE_DESIGN.md` - layer structure, routing, completion generation, and flow-control architecture
- `docs/FUNCTIONAL_DESIGN.md` - enumeration, BAR0 access, DMA, MSI-X, TLP RX/TX behavior, and limitations
