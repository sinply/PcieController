# PCIe Controller

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SpinalHDL](https://img.shields.io/badge/SpinalHDL-1.9.4-blue.svg)](https://github.com/SpinalHDL/SpinalHDL)
[![Scala](https://img.shields.io/badge/Scala-2.11-orange.svg)](https://www.scala-lang.org/)

A PCIe 2.0 controller implemented in [SpinalHDL](https://github.com/SpinalHDL/SpinalHDL).

## Features

- **Physical Layer** - Link training and symbol handling
- **Data Link Layer** - TLP framing/deframing with CRC and sequence numbers
- **Transaction Layer** - TLP RX/TX engines with flow control
- **Configuration Space Controller** - PCIe config space (Type 0) with BAR support
- **DMA Engine** - Scatter-gather DMA for host memory access
- **MSI-X Controller** - Up to 32 interrupt vectors

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Application                               │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│    │ User AXI │    │Local Mem │    │ Interrupt│                 │
│    │  Control │    │   AXI    │    │  Inputs  │                 │
│    └────┬─────┘    └────┬─────┘    └────┬─────┘                 │
└─────────┼───────────────┼───────────────┼────────────────────────┘
          │               │               │
          ▼               ▼               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PcieController                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐      │
│  │   DMA    │   │  MSI-X   │   │  Config  │   │   TLP    │      │
│  │  Engine  │   │  Ctrl    │   │  Space   │   │ TX/RX    │      │
│  └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘      │
│       │              │              │              │             │
│       └──────────────┴──────────────┴──────────────┘             │
│                              │                                   │
│                      ┌───────┴───────┐                          │
│                      │  Data Link    │                          │
│                      │    Layer      │                          │
│                      └───────┬───────┘                          │
│                              │                                   │
│                      ┌───────┴───────┐                          │
│                      │  Physical     │                          │
│                      │    Layer      │                          │
│                      └───────┬───────┘                          │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               ▼
                         ┌───────────┐
                         │  SerDes   │
                         │  (PHY)    │
                         └───────────┘
```

## Requirements

- Scala 2.11.12
- SpinalHDL 1.9.4
- sbt 1.x

## Quick Start

### Build

```bash
sbt compile
```

### Generate Verilog

```bash
sbt "runMain pcie.PcieControllerGen"
```

Output: `rtl/PcieController.v`

### Run Simulation

```bash
sbt "runMain pcie.PcieControllerSim"
```

## Configuration

Customize the controller via `PcieControllerConfig`:

```scala
val config = PcieControllerConfig(
  vendorId   = 0x10EE,    // Xilinx
  deviceId   = 0x7021,
  classCode  = 0x020000,  // Network Controller
  maxPayload = 256,       // bytes
  numMsixVec = 32         // MSI-X vectors
)
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| vendorId | 0x10EE | PCI Vendor ID |
| deviceId | 0x7021 | PCI Device ID |
| classCode | 0x020000 | PCI Class Code |
| maxPayload | 256 | Max payload size (bytes) |
| numMsixVec | 32 | Number of MSI-X vectors |

## Directory Structure

```
.
├── build.sbt              # SBT build configuration
├── src/main/scala/pcie/
│   ├── PcieController.scala      # Top-level module
│   ├── PcieTypes.scala           # TLP types and bundles
│   ├── PhysicalLayer.scala       # PHY layer
│   ├── DataLinkLayer.scala       # Data Link Layer
│   ├── TlpTxEngine.scala         # Transaction Layer TX
│   ├── TlpRxEngine.scala         # Transaction Layer RX
│   ├── ConfigSpaceCtrl.scala     # Config space controller
│   ├── DmaEngine.scala           # DMA engine
│   └── MsixController.scala      # MSI-X controller
├── rtl/                   # Generated Verilog output
└── project/               # SBT project files
```

## Interfaces

| Interface | Type | Description |
|-----------|------|-------------|
| txSymbols | Output (10-bit) | To SerDes TX |
| rxSymbols | Input (10-bit) | From SerDes RX |
| userCtrl | AXI4 Slave | DMA configuration registers |
| localMem | AXI4 Master | Local memory access |
| intReq | Input | Interrupt request lines |
| intAck | Output | Interrupt acknowledge |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SpinalHDL](https://github.com/SpinalHDL/SpinalHDL) - Hardware description language
- [PCI Express Base Specification 2.0](https://pcisig.com/)
