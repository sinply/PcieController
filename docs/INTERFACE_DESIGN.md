# Interface Design

This document describes the externally visible interfaces of `PcieController`
and the main internal packet interface used between layers.

## Top-Level PCIe PHY Interface

The top level exposes a narrow 10-bit symbol interface intended to connect to a
SerDes wrapper or FPGA transceiver adaptation layer.

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `txSymbols` | output | 10 | 8b/10b encoded transmit symbol stream |
| `rxSymbols` | input | 10 | 8b/10b encoded receive symbol stream |
| `phyTxEn` | output | 1 | PHY transmitter enable |
| `phyRxPolarity` | output | 1 | RX polarity control from link training |
| `phyRxElecIdle` | input | 1 | Receiver electrical idle indication |
| `phyRxValid` | input | 1 | Receiver valid or signal detect indication |

The internal physical layer owns symbol alignment, 8b/10b decode, training
sequence detection, LTSSM state, and transmit encoding.

## User Control AXI4-Lite Interface

`userCtrl` is an AXI4-style 32-bit slave interface used for DMA control and
status registers. The implementation accepts independent AW and W channels and
returns a single B response when both are present.

| Offset | Name | Access | Description |
| --- | --- | --- | --- |
| `0x00` | `CTRL` | R/W | bit 0 start, bit 1 direction, bit 2 interrupt enable, bit 4 scatter-gather mode |
| `0x04` | `STATUS` | R | bit 0 done, bit 1 busy, bit 2 error, bit 3 descriptor done |
| `0x08` | `SRC_ADDR_LO` | R/W | Source address bits `[31:0]` |
| `0x0C` | `SRC_ADDR_HI` | R/W | Source address bits `[63:32]` |
| `0x10` | `DST_ADDR_LO` | R/W | Destination address bits `[31:0]` |
| `0x14` | `DST_ADDR_HI` | R/W | Destination address bits `[63:32]` |
| `0x18` | `LENGTH` | R/W | Transfer length in bytes, DWORD aligned |
| `0x1C` | `DESC_TABLE_LO` | R/W | Descriptor table base address low |
| `0x20` | `DESC_TABLE_HI` | R/W | Descriptor table base address high |
| `0x24` | `DESC_COUNT` | R/W | Number of descriptors |
| `0x28` | `DESC_CURRENT` | R/W | Current descriptor index |
| `0x2C` | `TOTAL_BYTES` | R | Total transferred bytes |

## Local Memory AXI4 Master Interface

`localMem` is a 64-bit AXI4 master interface used by the DMA engine.

| Channel | Direction | Description |
| --- | --- | --- |
| `ar` | output | Local memory read address for D2H DMA |
| `r` | input | Local memory read data, accepted during D2H packet construction |
| `aw` | output | Local memory write address for H2D DMA |
| `w` | output | Local memory write data, 64-bit data with byte strobes |
| `b` | input | Local memory write response |

Current DMA accesses issue single 64-bit beats for D2H reads and one 64-bit
write beat per H2D completion segment.

## BAR and User Register Interface

The configuration space exposes two implemented BARs.

| BAR | Size | Target | Behavior |
| --- | --- | --- | --- |
| BAR0 | 4 KiB | User register file | Memory reads and writes are routed to `ioReg*` |
| BAR1 | 64 KiB | MSI-X table/PBA aperture | Memory writes update MSI-X table entries |

BAR0 and I/O space requests share the register interface below.

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `ioRegAddr` | output | 32 | Register byte address |
| `ioRegWrData` | output | 32 | Register write data |
| `ioRegRdData` | input | 32 | Register read data |
| `ioRegWrEn` | output | 1 | One-cycle write enable |
| `ioRegRdEn` | output | 1 | One-cycle read enable |

I/O writes generate completion TLPs. BAR0 memory writes are posted and therefore
do not generate completions. BAR0 memory reads and I/O reads generate CplD.

## Interrupt Interface

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `intReq` | input | `numMsixVec` | Interrupt request bits |
| `intAck` | output | `numMsixVec` | Acknowledge pulse when a vector message is accepted |

The MSI-X table is exposed through BAR1. Each vector entry is 16 bytes:

| Offset | Field |
| --- | --- |
| `+0x0` | Message address low |
| `+0x4` | Message address high |
| `+0x8` | Message data |
| `+0xC` | Vector control, bit 0 mask |

MSI-X enable and function mask come from the MSI-X capability `msgCtrl` bits
15 and 14 respectively.

## Internal TLP Packet Interface

Transaction-layer modules exchange `Stream(TlpStreamPacket())` payloads.

| Field | Description |
| --- | --- |
| `tlpType` | Internal packet type enum |
| `reqId` | Requester ID for requests and completions |
| `tag` | Request tag |
| `addr` | Request or message address |
| `length` | TLP length in DWORDs, with 0 representing 1024 DWORDs |
| `firstBe`, `lastBe` | Request byte enables |
| `tc`, `attr` | Traffic class and attributes |
| `cplId` | Completion completer ID |
| `cplStatus` | Completion status |
| `cplByteCount` | Completion byte count |
| `cplLowerAddr` | Completion lower address |
| `data` | Up to four inline DWORDs |
| `dataValid` | Number of valid inline DWORDs |

Large receive payloads can also be emitted through `memDataOut`, while the first
four DWORDs are retained in the inline packet buffer for address decode and
small-payload consumers.
