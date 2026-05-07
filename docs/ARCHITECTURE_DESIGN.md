# Architecture Design

The controller is organized as a PCIe Gen2 x1 endpoint pipeline with application
functions above the transaction layer and a 10-bit symbol PHY interface below.

## Layering

```text
Application Layer
  DMA Engine
  MSI-X Controller
  Config Space Controller
  BAR0 / I/O Register Request Handler
        |
Transaction Layer
  TLP RX Engine
  TLP TX Engine with per-channel FIFOs
        |
Data Link Layer
  TX Framer, RX Deframer, DLLP Handler, Flow Control Manager
        |
Physical Layer
  LTSSM, TS detector, symbol aligner, 8b/10b codec
        |
SerDes adaptation
```

## Top-Level Integration

`PcieController.scala` instantiates and connects all layers.

Receive path:

```text
rxSymbols
  -> PhysicalLayer.rxData
  -> DlRxDeframer.tlpOut
  -> TlpRxEngine
  -> cfgReq / cplIn / ioReq / memReq
```

Transmit path:

```text
DMA MemWr/MemRd, Config Cpl, I/O/BAR0 Cpl, MSI-X MsgD
  -> TlpTxFifoWrapper
  -> DlTxFramer
  -> PhysicalLayer.txData
  -> txSymbols
```

## Transaction-Layer Routing

`TlpRxEngine` parses the first three or four DWORDs, classifies the packet, and
emits it to one of four Stream channels.

| Channel | Packet classes | Consumer |
| --- | --- | --- |
| `cfgReq` | CfgRd0, CfgWr0, CfgRd1, CfgWr1 | `PcieConfigSpaceCtrl` |
| `cplIn` | Cpl, CplD | `DmaEngine` |
| `ioReq` | I/O read/write | `IoRequestHandler` |
| `memReq` | Memory read/write | BAR router in `PcieController` |

Completion TLPs use dedicated internal fields (`cplId`, `cplStatus`,
`cplByteCount`, `cplLowerAddr`) so that request headers and completion headers
are not overloaded.

## BAR Routing

The configuration space owns BAR decode and applies the Memory Space Enable bit
from the PCI command register.

| BAR | Route |
| --- | --- |
| BAR0 | Routed to `IoRequestHandler` and exposed as `ioReg*` |
| BAR1 | Memory writes update the MSI-X table |
| Other BARs | Not implemented |

The BAR0 stream is arbitrated with I/O-space requests before entering
`IoRequestHandler`. BAR1 table writes are qualified with `inboundMemReq.fire`
so the table updates only when the memory request handshake completes.

## Completion Generation

Two modules generate completions:

| Source | Completion type |
| --- | --- |
| `PcieConfigSpaceCtrl` | CplD for config reads, Cpl for config writes |
| `IoRequestHandler` | CplD for I/O and BAR0 reads, Cpl for I/O writes |

BAR0 memory writes are posted and do not generate completions.

`TlpTxEngine` serializes completion packets using the PCIe completion header
format:

```text
DW0: Fmt/Type/TC/Attr/Length
DW1: Completer ID / Status / BCM / Byte Count
DW2: Requester ID / Tag / Rsvd / Lower Address
DW3+: Optional payload
```

## Flow Control and Arbitration

`TlpTxFifoWrapper` provides independent FIFOs for posted memory writes,
non-posted memory reads, and completions. `TlpTxEngine` arbitrates among them
and checks header/data credits before accepting a packet.

`FlowControlMgr` tracks posted, non-posted, and completion credits from FC init
and update DLLPs. TX credit consumption pulses are generated when the TX engine
accepts a packet.

## Data Link and PHY

The data link layer frames TLP DWORD streams with sequence numbers and LCRC,
and deframes receive traffic into TLP and DLLP streams. The physical layer
performs training sequence detection, LTSSM progression, symbol alignment, and
8b/10b coding.

## Generated RTL

`PcieControllerGen` writes the generated top-level RTL to
`rtl/PcieController.v`. The checked-in RTL should be regenerated after any
interface or packet format change.
