package t

import spinal.core._
import spinal.lib._

// =============================================================================
// CRC-32 (IEEE 802.3 poly 0xEDB88320, reflected input/output)
// All intermediate UInt values are kept at 32 bits to avoid SpinalHDL's
// automatic width-trimming on shift operations.
// =============================================================================
object Crc32 {

    // Standard CRC-32 lookup table (reflected algorithm)
    private val tableValues: Array[Long] = Array(
        0x00000000L, 0x77073096L, 0xEE0E612CL, 0x990951BAL,
        0x076DC419L, 0x706AF48FL, 0xE963A535L, 0x9E6495A3L,
        0x0EDB8832L, 0x79DCB8A4L, 0xE0D5E91BL, 0x97D2D988L,
        0x09B64C2BL, 0x7EB17CBFL, 0xE7B82D09L, 0x90BF1CBBL,
        0x1DB71064L, 0x6AB020F2L, 0xF3B97148L, 0x84BE41DEL,
        0x1ADAD47DL, 0x6DDDE4EBL, 0xF4D4B551L, 0x83D385C7L,
        0x136C9856L, 0x646BA8C0L, 0xFD62F97AL, 0x8A65C9ECL,
        0x14015C4FL, 0x63066CD9L, 0xFA0F3D63L, 0x8D080DF5L,
        0x3B6E20C8L, 0x4C69105EL, 0xD56041E4L, 0xA2677172L,
        0x3C03E4D1L, 0x4B04D447L, 0xD20D85FDL, 0xA50AB56BL,
        0x35B5A8FAL, 0x42B2986CL, 0xDBBBC9D6L, 0xACBCF940L,
        0x32D86CE3L, 0x45DF5C75L, 0xDCD60DCFL, 0xABD13D59L,
        0x26D930ACL, 0x51DE003AL, 0xC8D75180L, 0xBFD06116L,
        0x21B4F928L, 0x56B3C423L, 0xCFBA9599L, 0xB8BDA50FL,
        0x2802B89EL, 0x5F058808L, 0xC60CD9B2L, 0xB10BE924L,
        0x2F6F7C87L, 0x58684C11L, 0xC1611DABL, 0xB6662D3DL,
        0x76DC4190L, 0x01DB7106L, 0x98D220BCL, 0xEFD5102AL,
        0x71B18589L, 0x06B6B51FL, 0x9FBFE4A5L, 0xE8B8D433L,
        0x7807C9A2L, 0x0F00F934L, 0x9609A88EL, 0xE10E9818L,
        0x7F6AD2BBL, 0x086D3D2DL, 0x91646C97L, 0xE6635C01L,
        0x6B6B51F4L, 0x1C6C6162L, 0x856530D8L, 0xF262004EL,
        0x6C0695EDL, 0x1B01A57BL, 0x8208F4C1L, 0xF50FC457L,
        0x65B0D9C6L, 0x12B7E950L, 0x8BBEB8EAL, 0xFCB9887CL,
        0x62DD1DDFL, 0x15DA2D49L, 0x8CD37CF3L, 0xFBD44C65L,
        0x4DB26158L, 0x3AB551CEL, 0xA3BC0074L, 0xD4BB30E2L,
        0x4ADFA541L, 0x3DD895D7L, 0xA4D1C46DL, 0xD3D6F4FBL,
        0x4369E96AL, 0x346ED9FCL, 0xAD678846L, 0xDA60B8D0L,
        0x44042D73L, 0x33031DE5L, 0xAA0A4C5FL, 0xDD0D7CC9L,
        0x5005713CL, 0x270241AAL, 0xBE0B1010L, 0xC90C2086L,
        0x5768B525L, 0x206F85B3L, 0xB966D409L, 0xCE61E49FL,
        0x5EDEF90EL, 0x29D9C998L, 0xB0D09822L, 0xC7D7A8B4L,
        0x59B33D17L, 0x2EB40D81L, 0xB7BD5C3BL, 0xC0BA6CADL,
        0xEDB88320L, 0x9ABFB3B6L, 0x03B6E20CL, 0x74B1D29AL,
        0xEAD54739L, 0x9DD277AFL, 0x04DB2615L, 0x73DC1683L,
        0xE3630B12L, 0x94643B84L, 0x0D6D6A3EL, 0x7A6A5AA8L,
        0xE40ECF0BL, 0x9309FF9DL, 0x0A00AE27L, 0x7D079EB1L,
        0xF00F9344L, 0x8708A3D2L, 0x1E01F268L, 0x6906C2FEL,
        0xF762575DL, 0x806567CBL, 0x196C3671L, 0x6E6B06E7L,
        0xFED41B76L, 0x89D32BE0L, 0x10DA7A5AL, 0x67DD4ACCL,
        0xF9B9DF6FL, 0x8EBEEFF9L, 0x17B7BE43L, 0x60B08ED5L,
        0xD6D6A3E8L, 0xA1D1937EL, 0x38D8C2C4L, 0x4FDFF252L,
        0xD1BB67F1L, 0xA6BC5767L, 0x3FB506DDL, 0x48B2364BL,
        0xD80D2BDAL, 0xAF0A1B4CL, 0x36034AF6L, 0x41047A60L,
        0xDF60EFC3L, 0xA8670955L, 0x316658EFL, 0x46616879L,
        0xCB61B38CL, 0xBC66831AL, 0x256FD2A0L, 0x5268E236L,
        0xCC0C7795L, 0xBB0B4703L, 0x220216B9L, 0x5505262FL,
        0xC5BA3BBEL, 0xB2BD0B28L, 0x2BB45A92L, 0x5CB36A04L,
        0xC2D7FFA7L, 0xB5D0CF31L, 0x2CD99E8BL, 0x5BDEAE1DL,
        0x9B64C2B0L, 0xEC63F226L, 0x756AA39CL, 0x026D930AL,
        0x9C0906A9L, 0xEB0E363FL, 0x72076785L, 0x05005713L,
        0x95BF4A82L, 0xE2B87A14L, 0x7BB12BAEL, 0x0CB61B38L,
        0x92D28E9BL, 0xE5D5BE0DL, 0x7CDCEFB7L, 0x0BDBDF21L,
        0x86D3D2D4L, 0xF1D4E242L, 0x68DDB3F8L, 0x1FDA836EL,
        0x81BE16CDL, 0xF6B9265BL, 0x6FB077E1L, 0x18B74777L,
        0x88085AE6L, 0xFF0F6A70L, 0x66063BCAL, 0x11010B5CL,
        0x8F659EFFL, 0xF862AE69L, 0x616BFFD3L, 0x166CCF45L,
        0xA00AE278L, 0xD70DD2EEL, 0x4E048354L, 0x3903B3C2L,
        0xA7672661L, 0xD06016F7L, 0x4969474DL, 0x3E6E77DBL,
        0xAED16A4AL, 0xD9D65ADCL, 0x40DF0B66L, 0x37D83BF0L,
        0xA9BCAE53L, 0xDEBB9EC5L, 0x47B2CF7FL, 0x30B5FFE9L,
        0xBDBDF21CL, 0xCABAC28AL, 0x53B39330L, 0x24B4A3A6L,
        0xBAD03605L, 0xCDD70693L, 0x54DE5729L, 0x23D967BFL,
        0xB3667A2EL, 0xC4614AB8L, 0x5D681B02L, 0x2A6F2B94L,
        0xB40BBE37L, 0xC30C8EA1L, 0x5A05DF1BL, 0x2D02EF8DL
    )

    // Build a ROM (Seq of UInt constants) from the table
    def makeTable(): Vec[UInt] = Vec(tableValues.map(v => U(v, 32 bits)))

    // updateByte: advance CRC by one byte.
    // Fix: explicitly resize (crc >> 8) back to 32 bits before XOR.
    def updateByte(crc: UInt, byte: UInt, table: Vec[UInt]): UInt = {
        val idx = (crc(7 downto 0) ^ byte.resize(8)).resize(8)
        (crc >> 8).resize(32) ^ table(idx)   // .resize(32) prevents 24-bit truncation
    }

    // updateDword: advance CRC by one 32-bit word, little-endian byte order.
    def updateDword(crc: UInt, dw: Bits, table: Vec[UInt]): UInt = {
        require(dw.getWidth == 32, s"updateDword expects 32-bit input, got ${dw.getWidth}")
        var c = crc
        for (i <- 0 until 4) {
            c = updateByte(c, dw(i * 8 + 7 downto i * 8).asUInt, table)
        }
        c
    }
}

// =============================================================================
// DL Tx Framer
//
// Encapsulates a TLP stream (32-bit dwords) into a PCIe DL frame:
//   [STP | SEQ[11:8] | SEQ[7:0] | RES] [TLP dwords...] [LCRC]
//
// io.tlpIn  : slave  Stream[Bits(32)]  – raw TLP dwords from Transaction Layer
// io.frameOut: master Stream[Bits(32)] – framed output toward Physical Layer
// =============================================================================
class DlTxFramer(replayDepth: Int = 256) extends Component {

    val io = new Bundle {
        val tlpIn    = slave  Stream(Bits(32 bits))
        val frameOut = master Stream(Bits(32 bits))
    }

    // ---------- state ----------
    object St extends SpinalEnum { val IDLE, SEQ, FWD, LCRC = newElement() }
    val state = RegInit(St.IDLE)

    val txSeq    = Reg(UInt(12 bits)) init 0
    val crc      = Reg(UInt(32 bits)) init 0
    val replayMem = Mem(Bits(32 bits), replayDepth)
    val replayWPtr = Reg(UInt(log2Up(replayDepth) bits)) init 0

    // Build CRC table once as a ROM
    val crcTable = Crc32.makeTable()

    // ---------- output defaults ----------
    io.frameOut.valid   := False
    io.frameOut.payload := B(0, 32 bits)
    io.tlpIn.ready      := False

    // ---------- FSM ----------
    switch(state) {

        // Wait for a new TLP
        is(St.IDLE) {
            when(io.tlpIn.valid) {
                crc   := 0xFFFFFFFFL
                state := St.SEQ
            }
        }

        // Send the sequence-number dword (STP framing byte + 12-bit seq number)
        // Layout: [STP=0xAA][0][SEQ(11:8)][SEQ(7:0)][RES=0x00]
        //   bits: 8          4   4          8          8   = 32 bits ✓
        is(St.SEQ) {
            // Build 32-bit sequence dword — total must equal 32 bits
            val seqDw =
                B"8'hAA"                    ##   //  8 bits  → bits[31:24]
                        B"4'h0"                     ##   //  4 bits  → bits[23:20]  (reserved)
                        txSeq(11 downto 8).asBits   ##   //  4 bits  → bits[19:16]
                        txSeq( 7 downto 0).asBits   ##   //  8 bits  → bits[15:8]
                        B"8'h00"                        //  8 bits  → bits[7:0]   (reserved)
            // 8 + 4 + 4 + 8 + 8 = 32 bits ✓

            io.frameOut.valid   := True
            io.frameOut.payload := seqDw

            when(io.frameOut.ready) {
                crc   := Crc32.updateDword(crc, seqDw, crcTable)
                state := St.FWD
            }
        }

        // Forward TLP dwords, accumulate CRC, store in replay buffer
        is(St.FWD) {
            io.frameOut.valid   := io.tlpIn.valid
            io.frameOut.payload := io.tlpIn.payload
            io.tlpIn.ready      := io.frameOut.ready

            when(io.tlpIn.fire) {
                crc                    := Crc32.updateDword(crc, io.tlpIn.payload, crcTable)
                replayMem(replayWPtr)  := io.tlpIn.payload
                replayWPtr             := replayWPtr + 1
            }

            // Detect falling edge of tlpIn.valid → TLP is done
            when(!io.tlpIn.valid && RegNext(io.tlpIn.valid, init = False)) {
                state := St.LCRC
            }
        }

        // Send LCRC (bit-inverted final CRC)
        is(St.LCRC) {
            io.frameOut.valid   := True
            io.frameOut.payload := (~crc).asBits   // 32 bits ✓

            when(io.frameOut.ready) {
                txSeq := txSeq + 1
                state := St.IDLE
            }
        }
    }
}

// =============================================================================
// DL Rx Checker (skeleton)
//
// Strips the sequence-number dword and LCRC, verifies CRC, passes TLP
// dwords upstream.  Sends ACK/NAK via the Ack/Nak DLLP path (not shown).
// =============================================================================
class DlRxChecker extends Component {

    val io = new Bundle {
        val frameIn = slave  Stream(Bits(32 bits))
        val tlpOut  = master Stream(Bits(32 bits))
        val crcOk   = out Bool()
    }

    object St extends SpinalEnum { val IDLE, FWD, CHECK = newElement() }
    val state     = RegInit(St.IDLE)
    val crc       = Reg(UInt(32 bits)) init 0
    val crcTable  = Crc32.makeTable()
    val rxSeq     = Reg(UInt(12 bits)) init 0
    val lastDword = Reg(Bits(32 bits))

    io.tlpOut.valid   := False
    io.tlpOut.payload := B(0, 32 bits)
    io.frameIn.ready  := False
    io.crcOk          := False

    switch(state) {
        is(St.IDLE) {
            io.frameIn.ready := True
            when(io.frameIn.valid) {
                // First dword is STP/SEQ — consume and start CRC
                crc   := Crc32.updateDword(0xFFFFFFFFL, io.frameIn.payload, crcTable)
                rxSeq := (io.frameIn.payload(19 downto 16) ## io.frameIn.payload(15 downto 8)).asUInt
                state := St.FWD
            }
        }

        is(St.FWD) {
            io.frameIn.ready  := io.tlpOut.ready
            io.tlpOut.valid   := io.frameIn.valid
            io.tlpOut.payload := lastDword   // one-cycle delayed to allow LCRC detection

            when(io.frameIn.valid && io.tlpOut.ready) {
                lastDword := io.frameIn.payload
                crc       := Crc32.updateDword(crc, io.frameIn.payload, crcTable)
            }
            // Transition to CHECK when frame ends (EDP signalling not modelled here;
            // a real implementation would use a sideband "end-of-frame" signal)
        }

        is(St.CHECK) {
            // CRC of entire frame (including LCRC field) should equal 0xDEBB20E3
            io.crcOk := (crc === 0xDEBB20E3L)
            state    := St.IDLE
        }
    }
}

// =============================================================================
// Top-level PCIe Controller wrapper (minimal)
// =============================================================================
class PcieController extends Component {

    val io = new Bundle {
        // Transaction layer interface
        val tlpTx    = slave  Stream(Bits(32 bits))
        val tlpRx    = master Stream(Bits(32 bits))
        // Physical layer interface (byte-serial not modelled; dword stream here)
        val phyTx    = master Stream(Bits(32 bits))
        val phyRx    = slave  Stream(Bits(32 bits))
        // Status
        val rxCrcOk  = out Bool()
    }

    val dlTx = new DlTxFramer()
    val dlRx = new DlRxChecker()

    // Tx path: TLP → DL framer → PHY
    dlTx.io.tlpIn    <> io.tlpTx
    io.phyTx         <> dlTx.io.frameOut

    // Rx path: PHY → DL checker → TLP
    dlRx.io.frameIn  <> io.phyRx
    io.tlpRx         <> dlRx.io.tlpOut
    io.rxCrcOk       := dlRx.io.crcOk
}

// =============================================================================
// Elaboration entry point
// =============================================================================
object PcieControllerGen extends App {
    SpinalConfig(
        defaultClockDomainFrequency = FixedFrequency(250 MHz),
        defaultConfigForClockDomains = ClockDomainConfig(resetKind = SYNC)
    ).generateVerilog(new PcieController)
}
