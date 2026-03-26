package pcie

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba4.axi._

// ============================================================
// Scatter-Gather DMA Engine
// Supports:
//   - Host-to-Device (H2D): PCIe MRd -> local memory
//   - Device-to-Host (D2H): local memory -> PCIe MWr
//   - Descriptor chaining for scatter-gather operations
//   - Up to 256 descriptors in internal memory
// ============================================================

// DMA Descriptor for scatter-gather (32 bytes, 256 bits)
case class SgDmaDescriptor() extends Bundle {
  val srcAddr   = UInt(64 bits)   // Source address
  val dstAddr   = UInt(64 bits)   // Destination address
  val length    = UInt(32 bits)   // Transfer length in bytes
  val control   = Bits(32 bits)   // Control flags
  val nextDesc  = UInt(64 bits)   // Next descriptor address (for chaining)
}

// Control flags bits
object DmaControl {
  val START      = 0   // Start transfer
  val DIRECTION  = 1   // 0=H2D, 1=D2H
  val INT_EN     = 2   // Interrupt on completion
  val LAST_DESC  = 3   // Last descriptor in chain
  val DESC_FETCH = 4   // Fetch descriptor from memory
}

class DmaEngine(maxPayload: Int = 256, maxDescriptors: Int = 256) extends Component {

  val io = new Bundle {
    // Control interface (AXI4-Lite style, modeled with Axi4 channels)
    val ctrl   = slave(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 32, useStrb = false,
      useLock = false, useCache = false, useProt = false,
      useQos = false, useRegion = false, idWidth = 4
    )))

    // PCIe TLP interfaces
    val memWrOut = master Stream(TlpStreamPacket())   // D2H write
    val memRdOut = master Stream(TlpStreamPacket())   // H2D read request
    val cplIn    = slave  Stream(TlpStreamPacket())   // H2D completions

    // Local AXI4 master (to on-chip memory)
    val localMem = master(Axi4(Axi4Config(
      addressWidth = 32, dataWidth = 64,
      useStrb = true, idWidth = 4
    )))

    // Status
    val h2dDone    = out Bool()
    val d2hDone    = out Bool()
    val dmaErr     = out Bool()
    val busDevFunc = in UInt(16 bits)
  }

  // -------------------------------------------------------
  // Control / Status Registers
  // 0x00: Control [start(0), direction(1), int_en(2), sg_mode(3)]
  // 0x04: Status  [done(0), busy(1), error(2), desc_done(3)]
  // 0x08: SrcAddrLo
  // 0x0C: SrcAddrHi
  // 0x10: DstAddrLo
  // 0x14: DstAddrHi
  // 0x18: Length(bytes)
  // 0x1C: DescTableLo  - Descriptor table base address low
  // 0x20: DescTableHi  - Descriptor table base address high
  // 0x24: DescCount    - Number of descriptors
  // 0x28: DescCurrent  - Current descriptor index
  // 0x2C: TotalBytes   - Total bytes transferred
  // -------------------------------------------------------
  val ctrlReg    = Reg(Bits(32 bits)) init(0)
  val statusReg  = Reg(Bits(32 bits)) init(0)
  val srcAddrLo  = Reg(UInt(32 bits)) init(0)
  val srcAddrHi  = Reg(UInt(32 bits)) init(0)
  val dstAddrLo  = Reg(UInt(32 bits)) init(0)
  val dstAddrHi  = Reg(UInt(32 bits)) init(0)
  val lengthReg  = Reg(UInt(32 bits)) init(0)
  val descTableLo = Reg(UInt(32 bits)) init(0)
  val descTableHi = Reg(UInt(32 bits)) init(0)
  val descCount   = Reg(UInt(16 bits)) init(0)
  val descCurrent = Reg(UInt(16 bits)) init(0)
  val totalBytes  = Reg(UInt(32 bits)) init(0)

  // AXI4-Lite register access
  val axilAr = io.ctrl.ar
  val axilAw = io.ctrl.aw
  val axilW  = io.ctrl.w
  val axilR  = io.ctrl.r
  val axilB  = io.ctrl.b

  val rValid = Reg(Bool()) init(False)
  val rId    = Reg(cloneOf(axilAr.id)) init(0)
  val rData  = Reg(Bits(32 bits)) init(0)

  axilAr.ready := !rValid
  axilR.valid  := rValid
  axilR.id     := rId
  axilR.data   := rData
  axilR.resp   := 0
  axilR.last   := True

  when(axilAr.fire) {
    rValid := True
    rId    := axilAr.id
    switch(axilAr.addr(7 downto 2)) {
      is(0)  { rData := ctrlReg }
      is(1)  { rData := statusReg }
      is(2)  { rData := srcAddrLo.asBits }
      is(3)  { rData := srcAddrHi.asBits }
      is(4)  { rData := dstAddrLo.asBits }
      is(5)  { rData := dstAddrHi.asBits }
      is(6)  { rData := lengthReg.asBits }
      is(7)  { rData := descTableLo.asBits }
      is(8)  { rData := descTableHi.asBits }
      is(9)  { rData := descCount.asBits.resized }
      is(10) { rData := descCurrent.asBits.resized }
      is(11) { rData := totalBytes.asBits }
      default { rData := B(32 bits, default -> True) }
    }
  }

  when(axilR.fire) {
    rValid := False
  }

  val awPending = Reg(Bool()) init(False)
  val awAddrReg = Reg(UInt(32 bits)) init(0)
  val awIdReg   = Reg(cloneOf(axilAw.id)) init(0)
  val wPending  = Reg(Bool()) init(False)
  val wDataReg  = Reg(Bits(32 bits)) init(0)

  axilAw.ready := !awPending
  axilW.ready  := !wPending

  when(axilAw.fire) {
    awPending := True
    awAddrReg := axilAw.addr
    awIdReg   := axilAw.id
  }

  when(axilW.fire) {
    wPending := True
    wDataReg := axilW.data
  }

  val bValid = Reg(Bool()) init(False)
  val bId    = Reg(cloneOf(axilAw.id)) init(0)
  axilB.valid := bValid
  axilB.id    := bId
  axilB.resp  := 0

  val doWrite = awPending && wPending && !bValid
  when(doWrite) {
    bValid := True
    bId    := awIdReg
    awPending := False
    wPending  := False

    switch(awAddrReg(7 downto 2)) {
      is(0)  { ctrlReg   := wDataReg }
      is(2)  { srcAddrLo := wDataReg.asUInt }
      is(3)  { srcAddrHi := wDataReg.asUInt }
      is(4)  { dstAddrLo := wDataReg.asUInt }
      is(5)  { dstAddrHi := wDataReg.asUInt }
      is(6)  { lengthReg := wDataReg.asUInt }
      is(7)  { descTableLo := wDataReg.asUInt }
      is(8)  { descTableHi := wDataReg.asUInt }
      is(9)  { descCount := wDataReg(15 downto 0).asUInt }
      is(10) { descCurrent := wDataReg(15 downto 0).asUInt }
      default {}
    }
  }

  when(axilB.fire) {
    bValid := False
  }

  // -------------------------------------------------------
  // Scatter-Gather Descriptor Memory
  // -------------------------------------------------------
  val descriptorMem = Mem(SgDmaDescriptor(), maxDescriptors)
  val activeDesc = Reg(SgDmaDescriptor()) init(SgDmaDescriptor().getZero)

  // -------------------------------------------------------
  // DMA FSM with Scatter-Gather Support
  // -------------------------------------------------------
  val startBit   = ctrlReg(DmaControl.START)
  val startPrev  = RegNext(startBit) init(False)
  val startPulse = startBit && !startPrev
  val direction  = ctrlReg(DmaControl.DIRECTION)  // 0=H2D, 1=D2H
  val sgMode     = ctrlReg(DmaControl.DESC_FETCH) // Scatter-gather mode (bit 4)
  val intEnable  = ctrlReg(DmaControl.INT_EN)     // Interrupt enable

  object DmaState extends SpinalEnum {
    val IDLE, FETCH_DESC, H2D_RD_REQ, H2D_WAIT_CPL, H2D_WR_LOCAL,
      D2H_RD_LOCAL, D2H_WR_PCIE, NEXT_DESC, DONE, ERROR = newElement()
  }

  val dmaState   = Reg(DmaState()) init(DmaState.IDLE)
  val remaining  = Reg(UInt(32 bits)) init(0)   // in DWORD (was 20-bit, now 32-bit)
  val offset     = Reg(UInt(32 bits)) init(0)   // in bytes (was 20-bit, now 32-bit)
  val tagCtr     = Reg(UInt(8 bits))  init(0)
  val reqTag     = Reg(UInt(8 bits))  init(0)   // Tag of outstanding request
  val descIdx    = Reg(UInt(16 bits)) init(0)   // Current descriptor index
  val outstandingDw = Reg(UInt(32 bits)) init(0) // Outstanding DWORDs for current request
  val waitingCpl = Reg(Bool()) init(False)       // Waiting for completion
  val cplTimeout = Reg(UInt(24 bits)) init(0)    // Completion timeout counter

  // Max Read Request Size (from config space, default 128 DW = 512 bytes)
  val mrrsDw = Reg(UInt(32 bits)) init(128)
  // Max Payload Size for writes
  val maxPayloadDw = U(maxPayload / 4, 32 bits)

  // 4KB boundary calculation for reads
  // Only lower 12 bits matter for 4KB boundary calculation
  val srcAddrFull = (srcAddrHi ## srcAddrLo).asUInt
  val offsetExtended = offset.resize(64 bits)
  // Get lower 32 bits of address for 4KB boundary calculation
  val addrLower32 = (srcAddrFull + offsetExtended)(31 downto 0)
  val bytesTo4k = U(4096, 32 bits) - (addrLower32 & U(4095, 32 bits))
  val boundaryDw = (bytesTo4k >> 2).resized

  // Read chunk size: min(MRRS, 4KB boundary, remaining)
  val maxReadDw = Mux(mrrsDw < boundaryDw, mrrsDw, boundaryDw)
  val chunkDw   = Mux(remaining < maxReadDw, remaining, maxReadDw)

  // Local memory data path is 64-bit, so each D2H packet carries <=2 DWORDs
  val d2hChunkDw = Mux(remaining < 2, remaining, U(2, 32 bits))

  // TLP defaults
  val memWrPkt = TlpStreamPacket()
  val memRdPkt = TlpStreamPacket()

  memWrPkt.tlpType   := TlpType.MEM_WR
  memWrPkt.tc        := 0
  memWrPkt.attr      := 0
  memWrPkt.firstBe   := 0xF
  memWrPkt.lastBe    := 0xF
  memWrPkt.reqId     := io.busDevFunc
  memWrPkt.tag       := tagCtr
  memWrPkt.addr      := (dstAddrHi ## dstAddrLo).asUInt + offset
  memWrPkt.length    := d2hChunkDw.resize(10)
  memWrPkt.dataValid := d2hChunkDw.resize(3)
  for(i <- 0 until 4) memWrPkt.data(i) := 0

  memRdPkt.tlpType   := TlpType.MEM_RD
  memRdPkt.tc        := 0
  memRdPkt.attr      := 0
  memRdPkt.firstBe   := 0xF
  memRdPkt.lastBe    := 0xF
  memRdPkt.reqId     := io.busDevFunc
  memRdPkt.tag       := tagCtr
  memRdPkt.addr      := (srcAddrHi ## srcAddrLo).asUInt + offset
  memRdPkt.length    := chunkDw.resize(10)
  memRdPkt.dataValid := 0
  for(i <- 0 until 4) memRdPkt.data(i) := 0

  io.memWrOut.valid   := False
  io.memWrOut.payload := memWrPkt
  io.memRdOut.valid   := False
  io.memRdOut.payload := memRdPkt
  io.cplIn.ready      := True   // Always accept completions to avoid deadlock
  io.h2dDone          := statusReg(0)
  io.d2hDone          := statusReg(0)
  io.dmaErr           := statusReg(2)

  // Local AXI4 master defaults
  io.localMem.ar.valid := False
  io.localMem.ar.addr  := 0
  io.localMem.ar.id    := 0
  io.localMem.ar.len   := 0
  io.localMem.ar.size  := 3
  io.localMem.ar.burst := 1
  io.localMem.ar.region := 0
  io.localMem.ar.lock   := 0
  io.localMem.ar.cache  := 0
  io.localMem.ar.qos    := 0
  io.localMem.ar.prot   := 0
  io.localMem.r.ready  := True
  io.localMem.aw.valid := False
  io.localMem.aw.addr  := 0
  io.localMem.aw.id    := 0
  io.localMem.aw.len   := 0
  io.localMem.aw.size  := 3
  io.localMem.aw.burst := 1
  io.localMem.aw.region := 0
  io.localMem.aw.lock   := 0
  io.localMem.aw.cache  := 0
  io.localMem.aw.qos    := 0
  io.localMem.aw.prot   := 0
  io.localMem.w.valid  := False
  io.localMem.w.data   := 0
  io.localMem.w.strb   := 0x00
  io.localMem.w.last   := True
  io.localMem.b.ready  := True

  val h2dWriteAddr = Reg(UInt(32 bits)) init(0)
  val h2dWriteData = Reg(Bits(64 bits)) init(0)
  val h2dWriteStrb = Reg(Bits(8 bits)) init(0)

  // Load descriptor from memory
  val descReadData = descriptorMem.readAsync(descIdx.resize(log2Up(maxDescriptors)))

  switch(dmaState) {

    is(DmaState.IDLE) {
      when(startPulse && statusReg(1) === False) {
        totalBytes := 0
        descIdx := 0

        when(sgMode) {
          // Scatter-gather mode: check descriptor count bounds
          when(descCount > maxDescriptors) {
            statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000004L, 32 bits)
            dmaState := DmaState.ERROR
          } otherwise {
            dmaState := DmaState.FETCH_DESC
          }
        } otherwise {
          // Single transfer mode
          val lengthDw = (lengthReg >> 2).resize(32 bits)
          remaining := lengthDw
          offset    := 0
          statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000002L, 32 bits)

          when(lengthDw === 0) {
            dmaState := DmaState.DONE
          } elsewhen(direction === False) {
            dmaState := DmaState.H2D_RD_REQ
          } otherwise {
            dmaState := DmaState.D2H_RD_LOCAL
          }
        }
      }
    }

    // Fetch descriptor for scatter-gather mode
    is(DmaState.FETCH_DESC) {
      when(descIdx < descCount && descIdx < maxDescriptors) {
        activeDesc := descReadData
        statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000002L, 32 bits)

        val descLengthDw = (descReadData.length >> 2).resize(32 bits)
        remaining := descLengthDw
        offset    := 0

        // Use descriptor addresses
        srcAddrLo := descReadData.srcAddr(31 downto 0)
        srcAddrHi := descReadData.srcAddr(63 downto 32)
        dstAddrLo := descReadData.dstAddr(31 downto 0)
        dstAddrHi := descReadData.dstAddr(63 downto 32)

        when(descLengthDw === 0) {
          dmaState := DmaState.NEXT_DESC
        } elsewhen(descReadData.control(1) === False) {
          // H2D transfer
          dmaState := DmaState.H2D_RD_REQ
        } otherwise {
          // D2H transfer
          dmaState := DmaState.D2H_RD_LOCAL
        }
      } otherwise {
        dmaState := DmaState.DONE
      }
    }

    // ---- Host-to-Device: Send MRd TLPs ----
    is(DmaState.H2D_RD_REQ) {
      io.memRdOut.valid := True
      when(io.memRdOut.ready) {
        // Save request parameters for completion matching
        outstandingDw := chunkDw
        reqTag        := tagCtr
        tagCtr        := tagCtr + 1
        waitingCpl    := True
        cplTimeout    := 0
        // Don't update remaining here - wait for completion
        dmaState      := DmaState.H2D_WAIT_CPL
      }
    }

    // Wait for completion data with timeout
    is(DmaState.H2D_WAIT_CPL) {
      cplTimeout := cplTimeout + 1

      when(io.cplIn.fire && io.cplIn.payload.tag === reqTag && waitingCpl) {
        val cplWords = Mux(io.cplIn.payload.dataValid === 0, U(1, 3 bits), io.cplIn.payload.dataValid)
        val cplDw = io.cplIn.payload.length.resize(32 bits)

        h2dWriteAddr := (dstAddrLo + offset).resized
        h2dWriteData := (io.cplIn.payload.data(1) ## io.cplIn.payload.data(0)).asBits
        h2dWriteStrb := (cplWords === 1) ? B"8'h0F" | B"8'hFF"

        // Update tracking after successful completion
        offset      := offset + (cplDw |<< 2)
        remaining   := remaining - cplDw
        totalBytes  := totalBytes + (cplDw << 2).resize(32)
        waitingCpl  := False

        dmaState    := DmaState.H2D_WR_LOCAL
      } elsewhen(cplTimeout === U(10000000, 24 bits)) {
        // Completion timeout - report error
        statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000004L, 32 bits)
        waitingCpl := False
        dmaState := DmaState.ERROR
      }
    }

    is(DmaState.H2D_WR_LOCAL) {
      io.localMem.aw.valid := True
      io.localMem.aw.addr  := h2dWriteAddr
      io.localMem.w.valid  := True
      io.localMem.w.data   := h2dWriteData
      io.localMem.w.strb   := h2dWriteStrb

      when(io.localMem.aw.ready && io.localMem.w.ready) {
        when(remaining === 0) {
          when(sgMode) {
            dmaState := DmaState.NEXT_DESC
          } otherwise {
            dmaState := DmaState.DONE
          }
        } otherwise {
          dmaState := DmaState.H2D_RD_REQ
        }
      }
    }

    // ---- Device-to-Host: Read local, send MWr TLPs ----
    is(DmaState.D2H_RD_LOCAL) {
      io.localMem.ar.valid := True
      io.localMem.ar.addr  := (srcAddrLo + offset).resized
      io.localMem.ar.len   := Mux(d2hChunkDw === 0, U(0, 8 bits), (d2hChunkDw - 1).resize(8))

      when(io.localMem.ar.ready) {
        dmaState := DmaState.D2H_WR_PCIE
      }
    }

    is(DmaState.D2H_WR_PCIE) {
      when(io.localMem.r.valid) {
        val chunk = d2hChunkDw
        val p = TlpStreamPacket()

        p.tlpType := TlpType.MEM_WR
        p.reqId   := io.busDevFunc
        p.tag     := tagCtr
        p.addr    := (dstAddrHi ## dstAddrLo).asUInt + offset
        p.firstBe := 0xF
        p.lastBe  := 0xF
        p.tc      := 0
        p.attr    := 0
        p.length    := chunk.resize(10)
        p.dataValid := chunk.resize(3)
        p.data(0)   := io.localMem.r.data(31 downto 0)
        p.data(1)   := (chunk > 1) ? io.localMem.r.data(63 downto 32) | B(0, 32 bits)
        p.data(2)   := 0
        p.data(3)   := 0

        io.memWrOut.valid   := True
        io.memWrOut.payload := p

        when(io.memWrOut.ready) {
          val nextRemain = remaining - chunk
          offset    := offset + (chunk |<< 2)
          remaining := nextRemain
          totalBytes := totalBytes + (chunk << 2).resize(32)

          when(nextRemain === 0) {
            when(sgMode) {
              dmaState := DmaState.NEXT_DESC
            } otherwise {
              dmaState := DmaState.DONE
            }
          } otherwise {
            tagCtr   := tagCtr + 1
            dmaState := DmaState.D2H_RD_LOCAL
          }
        }
      }
    }

    // Move to next descriptor in scatter-gather mode
    is(DmaState.NEXT_DESC) {
      descIdx := descIdx + 1
      descCurrent := descIdx + 1
      statusReg(3) := True  // Descriptor done flag

      when(descIdx + 1 >= descCount) {
        dmaState := DmaState.DONE
      } otherwise {
        dmaState := DmaState.FETCH_DESC
      }
    }

    is(DmaState.DONE) {
      statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000001L, 32 bits)
      dmaState  := DmaState.IDLE
    }

    is(DmaState.ERROR) {
      statusReg := (statusReg & B(0xFFFFFFF8L, 32 bits)) | B(0x00000004L, 32 bits)
      dmaState  := DmaState.IDLE
    }
  }
}
