package pcie

import spinal.core._
import spinal.lib._

// ============================================================
// TLP Format & Type Encoding (PCIe 2.0 Spec)
// ============================================================
object TlpFmt {
  val WITH_3DW_NO_DATA  = B"2'b00"
  val WITH_4DW_NO_DATA  = B"2'b01"
  val WITH_3DW_WITH_DATA = B"2'b10"
  val WITH_4DW_WITH_DATA = B"2'b11"
}

object TlpTypeCode {
  val MEM_RD    = B"5'b00000"
  val MEM_WR    = B"5'b00000"  // fmt differentiates
  val IO_RD     = B"5'b00010"
  val IO_WR     = B"5'b00010"
  val CFG_RD_0  = B"5'b00100"
  val CFG_WR_0  = B"5'b00100"
  val CPL       = B"5'b01010"
  val CPL_D     = B"5'b01010"
  val MSG       = B"5'b10000"
}

object TlpType extends SpinalEnum(binarySequential) {
  val MEM_RD, MEM_WR, IO_RD, IO_WR,
      CFG_RD0, CFG_WR0, CFG_RD1, CFG_WR1,
      CPL, CPL_D,
      MSG, MSG_D,
      INVALID = newElement()
}

// ============================================================
// TLP Header Bundles
// ============================================================
case class TlpHeader() extends Bundle {
  val fmt     = Bits(2 bits)   // Format [1:0]
  val tlpType = Bits(5 bits)   // Type [4:0]
  val tc      = UInt(3 bits)   // Traffic Class
  val attr    = Bits(2 bits)   // Attributes (RO, NS)
  val td      = Bool()         // TLP Digest present
  val ep      = Bool()         // Error Poisoned
  val length  = UInt(10 bits)  // Length in DWORDs (0=1024)
}

case class TlpReqHeader() extends Bundle {
  val hdr   = TlpHeader()
  val reqId = UInt(16 bits)   // Bus[7:0]:Dev[4:0]:Func[2:0]
  val tag   = UInt(8 bits)    // Transaction tag
  val lastBe  = Bits(4 bits)  // Last DW Byte Enable
  val firstBe = Bits(4 bits)  // First DW Byte Enable
  val addr  = UInt(64 bits)   // Target address
}

case class TlpCplHeader() extends Bundle {
  val hdr        = TlpHeader()
  val cplId      = UInt(16 bits) // Completer ID
  val status     = UInt(3 bits)  // Completion Status (000=SC)
  val bcm        = Bool()        // Byte Count Modified
  val byteCount  = UInt(12 bits) // Remaining byte count
  val reqId      = UInt(16 bits) // Requester ID
  val tag        = UInt(8 bits)  // Tag
  val lowerAddr  = UInt(7 bits)  // Lower address
}

// ============================================================
// TLP Stream Packet (serialized to 32-bit DWORDS)
// Supports streaming data path with configurable inline data
// ============================================================
case class TlpStreamPacket() extends Bundle {
  val tlpType  = TlpType()
  val reqId    = UInt(16 bits)
  val tag      = UInt(8 bits)
  val addr     = UInt(64 bits)
  val length   = UInt(10 bits)
  val firstBe  = Bits(4 bits)
  val lastBe   = Bits(4 bits)
  val tc       = UInt(3 bits)
  val attr     = Bits(2 bits)
  val data     = Vec(Bits(32 bits), 4)  // Inline data for small payloads (up to 16 bytes)
  val dataValid = UInt(3 bits)          // How many inline data DWORDs valid
}

// ============================================================
// Extended TLP Stream Packet with larger buffer for streaming
// Supports max payload size (up to 256 bytes = 64 DWORDs)
// ============================================================
case class TlpStreamPacketExtended() extends Bundle {
  val tlpType  = TlpType()
  val reqId    = UInt(16 bits)
  val tag      = UInt(8 bits)
  val addr     = UInt(64 bits)
  val length   = UInt(10 bits)
  val firstBe  = Bits(4 bits)
  val lastBe   = Bits(4 bits)
  val tc       = UInt(3 bits)
  val attr     = Bits(2 bits)
  val data     = Vec(Bits(32 bits), 64) // Full max payload support
  val dataValid = UInt(7 bits)          // How many data DWORDs valid (0-64)
  val dataLast  = Bool()                // Last beat of data
}

// ============================================================
// Streaming TLP Data Interface
// For large payloads, data is streamed rather than buffered
// ============================================================
case class TlpDataStream() extends Bundle {
  val data     = Bits(32 bits)
  val valid    = Bool()
  val last     = Bool()
  val byteEn   = Bits(4 bits)
}

// ============================================================
// PCIe Configuration Space (Type 0, first 64 bytes)
// ============================================================
case class PcieConfigRegs() extends Bundle {
  val vendorId       = UInt(16 bits)
  val deviceId       = UInt(16 bits)
  val command        = Bits(16 bits)
  val status         = Bits(16 bits)
  val revisionId     = UInt(8 bits)
  val classCode      = Bits(24 bits)
  val cacheLineSize  = UInt(8 bits)
  val latencyTimer   = UInt(8 bits)
  val headerType     = UInt(8 bits)
  val bist           = UInt(8 bits)
  val bar            = Vec(UInt(32 bits), 6)
  val subVendorId    = UInt(16 bits)
  val subSystemId    = UInt(16 bits)
  val capPointer     = UInt(8 bits)
  val intLine        = UInt(8 bits)
  val intPin         = UInt(8 bits)
}

// ============================================================
// Flow Control Credits
// ============================================================
case class FlowControlCredits() extends Bundle {
  val phCredits = UInt(8 bits)   // Posted Header Credits
  val pdCredits = UInt(12 bits)  // Posted Data Credits
  val nphCredits = UInt(8 bits)  // Non-Posted Header Credits
  val npdCredits = UInt(12 bits) // Non-Posted Data Credits
  val cplhCredits = UInt(8 bits) // Completion Header Credits
  val cpldCredits = UInt(12 bits)// Completion Data Credits
}

// ============================================================
// DMA Descriptor
// ============================================================
case class DmaDescriptor() extends Bundle {
  val srcAddr  = UInt(64 bits)
  val dstAddr  = UInt(64 bits)
  val length   = UInt(20 bits)  // Bytes
  val tag      = UInt(8 bits)
  val reqId    = UInt(16 bits)
}
