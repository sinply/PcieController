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

### PHY Interface (SerDes)

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| txSymbols | Output | 10 bits | To SerDes TX - 8b/10b encoded symbols |
| rxSymbols | Input | 10 bits | From SerDes RX - 8b/10b encoded symbols |

**Usage Example:**
```verilog
// Connect to Xilinx 7-Series GTX/GTH Transceiver
// Note: 8b/10b encoding is simplified in this implementation
assign tx_symbols = txSymbols;  // To GTX TXDATA
assign rxSymbols = rx_symbols;  // From GTX RXDATA
```

**Important:** The current 8b/10b encoder/decoder is a placeholder. For production use, replace with:
- Xilinx GTX/GTH native encoding
- Or implement full 8b/10b tables with running disparity tracking

### User Control Interface (AXI4 Slave)

DMA configuration registers accessible via AXI4-Lite.

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| userCtrl.aw.valid | Input | 1 | Write address valid |
| userCtrl.aw.addr | Input | 32 | Write address |
| userCtrl.aw.id | Input | 4 | Transaction ID |
| userCtrl.w.valid | Input | 1 | Write data valid |
| userCtrl.w.data | Input | 32 | Write data |
| userCtrl.w.last | Input | 1 | Last beat |
| userCtrl.b.ready | Input | 1 | Write response ready |
| userCtrl.ar.valid | Input | 1 | Read address valid |
| userCtrl.ar.addr | Input | 32 | Read address |
| userCtrl.ar.id | Input | 4 | Transaction ID |
| userCtrl.r.ready | Input | 1 | Read data ready |

**DMA Register Map:**

| Offset | Name | R/W | Description |
|--------|------|-----|-------------|
| 0x00 | CTRL | R/W | Control register: bit[0]=start, bit[1]=direction (0=H2D, 1=D2H) |
| 0x04 | STATUS | R | Status register: bit[0]=done, bit[1]=busy, bit[2]=error |
| 0x08 | SRC_ADDR_LO | R/W | Source address [31:0] (PCIe address for H2D, local for D2H) |
| 0x0C | SRC_ADDR_HI | R/W | Source address [63:32] |
| 0x10 | DST_ADDR_LO | R/W | Destination address [31:0] (local for H2D, PCIe for D2H) |
| 0x14 | DST_ADDR_HI | R/W | Destination address [63:32] |
| 0x18 | LENGTH | R/W | Transfer length in bytes (must be DWORD aligned) |

**DMA Usage Example:**
```verilog
// Host-to-Device DMA: Read 4KB from PCIe address 0x12340000 to local address 0x00010000
// 1. Configure DMA
axi_write(0x08, 0x12340000);  // SRC_ADDR_LO - PCIe source address
axi_write(0x0C, 0x00000000);  // SRC_ADDR_HI
axi_write(0x10, 0x00010000);  // DST_ADDR_LO - Local destination
axi_write(0x14, 0x00000000);  // DST_ADDR_HI
axi_write(0x18, 0x00001000);  // LENGTH = 4KB

// 2. Start H2D transfer (direction=0)
axi_write(0x00, 32'h00000001);

// 3. Wait for completion
while (!(axi_read(0x04) & 0x1));  // Wait for done bit
```

### Local Memory Interface (AX4 Master)

Used by DMA engine for local memory access.

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| localMem.aw.* | Output | - | Write address channel |
| localMem.w.* | Output | - | Write data channel (64-bit) |
| localMem.b.* | Input | - | Write response channel |
| localMem.ar.* | Output | - | Read address channel |
| localMem.r.* | Input | - | Read data channel (64-bit) |

**AXI4 Configuration:**
- Address Width: 32 bits
- Data Width: 64 bits
- ID Width: 4 bits
- Supports: strobe, burst transactions

**Connection Example:**
```verilog
// Connect to on-chip BRAM or memory controller
axi_interconnect u_axi (
    .s00_axi (localMem),   // From PCIe controller
    .m00_axi (bram_port)   // To local memory
);
```

### Interrupt Interface

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| intReq | Input | numMsixVec | Interrupt request lines (default: 32) |
| intAck | Output | numMsixVec | Interrupt acknowledge pulses |

**MSI-X Usage:**
```verilog
// Trigger interrupt vector 0
assign intReq[0] = my_interrupt_condition;

// intAck[0] pulses when MSI-X message is sent
always @(posedge clk) begin
    if (intAck[0]) begin
        // Interrupt acknowledged, can re-trigger
    end
end
```

**MSI-X Table (via BAR1):**
- Each vector has 4 DWORDs:
  - Offset 0x00: Message Address [31:0]
  - Offset 0x04: Message Address [63:32]
  - Offset 0x08: Message Data
  - Offset 0x0C: Vector Control (bit[0]=mask)

### Status Outputs

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| linkUp | Output | 1 | Link training complete, ready for TLP traffic |
| linkSpeed | Output | 2 | Link speed: 0=Gen1(2.5GT/s), 1=Gen2(5GT/s) |
| ltssState | Output | 5 | Current LTSSM state (for debug) |
| h2dDone | Output | 1 | Host-to-Device DMA transfer complete |
| d2hDone | Output | 1 | Device-to-Host DMA transfer complete |
| dmaErr | Output | 1 | DMA error occurred |

## BAR Configuration

| BAR | Size | Description |
|-----|------|-------------|
| BAR0 | 4KB | Device control registers |
| BAR1 | 64KB | MSI-X Table and PBA |

## Known Limitations

This is a **reference/educational implementation** with the following limitations:

1. **8b/10b Encoding**: Simplified placeholder - does not perform real encoding
2. **LTSSM**: Uses fixed placeholder inputs - requires SerDes integration for real hardware
3. **TLP Data Path**: RX limited to 4 DWORDs inline data (16 bytes max payload)
4. **Flow Control**: Not fully implemented - credits never updated
5. **I/O Requests**: Dropped without response
6. **Scatter-Gather**: DMA supports single operation only (no chaining)

For production use, these components would need to be completed or replaced with IP blocks.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SpinalHDL](https://github.com/SpinalHDL/SpinalHDL) - Hardware description language
- [PCI Express Base Specification 2.0](https://pcisig.com/)
