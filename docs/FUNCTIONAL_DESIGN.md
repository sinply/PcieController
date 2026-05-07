# Functional Design

This document describes the intended behavior of the main PCIe endpoint
functions.

## Configuration Space and Enumeration

`PcieConfigSpaceCtrl` implements a PCIe Type 0 configuration header plus MSI-X,
Power Management, and PCIe capabilities.

Key behavior:

- Vendor ID, device ID, class code, BARs, subsystem IDs, interrupt pin, and
  capability pointer are readable by configuration requests.
- Command register writes enable memory space decode, I/O space decode, bus
  mastering, SERR, and INTx disable according to the writable mask.
- Status register bits use write-one-to-clear behavior while preserving the
  capability-list bit.
- BAR0 and BAR1 support all-ones size probing and base address programming.
- MSI-X capability advertises 32 vectors through table size `N - 1` and exposes
  enable/function-mask through `msgCtrl[15:14]`.

Capability layout:

| Capability | Offset | Notes |
| --- | --- | --- |
| MSI-X | `0x40` | Table and PBA use BAR1 |
| Power Management | `0x50` | Basic D0/D3hot fields |
| PCI Express | `0x60` | Endpoint, Gen2 x1 capability fields |

## BAR0 User Register Access

Inbound memory requests that hit BAR0 are forwarded to the user register
interface.

Memory read:

```text
MEM_RD to BAR0
  -> ioRegAddr/ioRegRdEn
  -> read ioRegRdData
  -> CplD with byte count 4 and matching requester/tag
```

Memory write:

```text
MEM_WR to BAR0
  -> ioRegAddr/ioRegWrData/ioRegWrEn
  -> no completion, because memory writes are posted
```

I/O-space requests use the same register interface. I/O reads return CplD, and
I/O writes return Cpl as required for non-posted I/O write requests.

## DMA

The DMA engine supports host-to-device and device-to-host transfers through the
AXI4-Lite control register block.

Host-to-device:

1. Software programs source PCIe address, destination local address, and length.
2. DMA issues one Memory Read request at a time.
3. DMA waits for a matching CplD tag.
4. Completion payload is written to local AXI memory.
5. Remaining length and total byte counters are updated.

Device-to-host:

1. Software programs source local address, destination PCIe address, and length.
2. DMA reads one 64-bit local AXI beat.
3. DMA emits a Memory Write TLP with one or two DWORDs.
4. Remaining length and total byte counters are updated.

The DMA read path respects the 4 KiB boundary and MRRS-sized chunking for H2D
Memory Read requests. D2H writes are currently emitted in 64-bit local-memory
chunks.

## MSI-X

The MSI-X controller owns a vector table and pending bit array.

1. Software programs the MSI-X table through BAR1.
2. Software sets MSI-X enable in configuration space.
3. User logic asserts `intReq[n]`.
4. The controller records pending requests that are not function-masked or
   vector-masked.
5. The selected vector emits a MsgD TLP with the programmed message address and
   data.
6. `intAck[n]` pulses when the message packet is accepted.

## TLP Receive

`TlpRxEngine` parses incoming DWORD streams into `TlpStreamPacket`.

- Request packets capture requester ID, tag, byte enables, and address.
- Completion packets capture completer ID, completion status, byte count,
  requester ID, tag, and lower address.
- Payloads up to four DWORDs are buffered inline.
- Larger payloads are streamed through `memDataOut`; the first four DWORDs are
  still retained in the inline buffer.
- Invalid type codes or oversized buffered payloads raise status flags and enter
  discard mode.

## TLP Transmit

`TlpTxEngine` accepts memory write, memory read, and completion streams through
FIFOs and serializes them to 32-bit DWORDs.

- Memory requests use request headers with 3DW or 4DW address selection.
- Completion packets use completion header DWORDs and optional CplD payload.
- Posted, non-posted, and completion credits are checked before packet accept.
- Round-robin source selection avoids permanent starvation among active queues.

## Current Limitations

- Single-lane Gen2 x1 endpoint only.
- D2H DMA emits one local 64-bit beat per Memory Write packet.
- Scatter-gather descriptor memory exists internally; external descriptor fetch
  from host memory is not implemented.
- Power-management states are modeled in the LTSSM but not fully integrated with
  platform power control.
- Full `sbt test` may run for a long time because some simulations contain broad
  wait loops; targeted tests are recommended while developing.
