# PCIe Controller

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
Application ──► DMA Engine ──► TLP TX/RX ──► DL Layer ──► PHY
                MSI-X Ctrl ◄──┘              └─► Config Space
```

## Requirements

- Scala 2.11.12
- SpinalHDL 1.9.4
- sbt

## Build

```bash
sbt compile
```

## Generate RTL

```bash
sbt "runMain pcie.PcieControllerGen"
```

Output: `rtl/PcieController.v`

## Simulation

```bash
sbt "runMain pcie.PcieControllerSim"
```

## Configuration

Default PCIe device configuration (can be customized):

| Parameter | Default Value |
|-----------|---------------|
| Vendor ID | 0x10EE (Xilinx) |
| Device ID | 0x7021 |
| Class Code | 0x020000 (Network Controller) |
| Max Payload | 256 bytes |
| MSI-X Vectors | 32 |

## Directory Structure

```
src/main/scala/pcie/
├── PcieController.scala      # Top-level module
├── PcieTypes.scala           # TLP types and bundles
├── PhysicalLayer.scala       # PHY layer
├── DataLinkLayer.scala       # Data Link Layer (TX/RX)
├── TlpTxEngine.scala         # Transaction Layer TX
├── TlpRxEngine.scala         # Transaction Layer RX
├── ConfigSpaceCtrl.scala     # Config space controller
├── DmaEngine.scala           # DMA engine
└── MsixController.scala      # MSI-X controller
```

## License

MIT
