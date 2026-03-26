// Generator : SpinalHDL v1.9.4    git head : 270018552577f3bb8e5339ee2583c9c22d324215
// Component : PcieController
// Git hash  : 0699282e37b91ab3fdf47c5e5e35d10740a211d9

`timescale 1ns/1ps

module PcieController (
  output wire [9:0]    io_txSymbols,
  input  wire [9:0]    io_rxSymbols,
  output wire          io_phyTxEn,
  output wire          io_phyRxPolarity,
  input  wire          io_phyRxElecIdle,
  input  wire          io_phyRxValid,
  input  wire          io_userCtrl_aw_valid,
  output wire          io_userCtrl_aw_ready,
  input  wire [31:0]   io_userCtrl_aw_payload_addr,
  input  wire [3:0]    io_userCtrl_aw_payload_id,
  input  wire [7:0]    io_userCtrl_aw_payload_len,
  input  wire [2:0]    io_userCtrl_aw_payload_size,
  input  wire [1:0]    io_userCtrl_aw_payload_burst,
  input  wire          io_userCtrl_w_valid,
  output wire          io_userCtrl_w_ready,
  input  wire [31:0]   io_userCtrl_w_payload_data,
  input  wire          io_userCtrl_w_payload_last,
  output wire          io_userCtrl_b_valid,
  input  wire          io_userCtrl_b_ready,
  output wire [3:0]    io_userCtrl_b_payload_id,
  output wire [1:0]    io_userCtrl_b_payload_resp,
  input  wire          io_userCtrl_ar_valid,
  output wire          io_userCtrl_ar_ready,
  input  wire [31:0]   io_userCtrl_ar_payload_addr,
  input  wire [3:0]    io_userCtrl_ar_payload_id,
  input  wire [7:0]    io_userCtrl_ar_payload_len,
  input  wire [2:0]    io_userCtrl_ar_payload_size,
  input  wire [1:0]    io_userCtrl_ar_payload_burst,
  output wire          io_userCtrl_r_valid,
  input  wire          io_userCtrl_r_ready,
  output wire [31:0]   io_userCtrl_r_payload_data,
  output wire [3:0]    io_userCtrl_r_payload_id,
  output wire [1:0]    io_userCtrl_r_payload_resp,
  output wire          io_userCtrl_r_payload_last,
  output wire          io_localMem_aw_valid,
  input  wire          io_localMem_aw_ready,
  output wire [31:0]   io_localMem_aw_payload_addr,
  output wire [3:0]    io_localMem_aw_payload_id,
  output wire [3:0]    io_localMem_aw_payload_region,
  output wire [7:0]    io_localMem_aw_payload_len,
  output wire [2:0]    io_localMem_aw_payload_size,
  output wire [1:0]    io_localMem_aw_payload_burst,
  output wire [0:0]    io_localMem_aw_payload_lock,
  output wire [3:0]    io_localMem_aw_payload_cache,
  output wire [3:0]    io_localMem_aw_payload_qos,
  output wire [2:0]    io_localMem_aw_payload_prot,
  output wire          io_localMem_w_valid,
  input  wire          io_localMem_w_ready,
  output wire [63:0]   io_localMem_w_payload_data,
  output wire [7:0]    io_localMem_w_payload_strb,
  output wire          io_localMem_w_payload_last,
  input  wire          io_localMem_b_valid,
  output wire          io_localMem_b_ready,
  input  wire [3:0]    io_localMem_b_payload_id,
  input  wire [1:0]    io_localMem_b_payload_resp,
  output wire          io_localMem_ar_valid,
  input  wire          io_localMem_ar_ready,
  output wire [31:0]   io_localMem_ar_payload_addr,
  output wire [3:0]    io_localMem_ar_payload_id,
  output wire [3:0]    io_localMem_ar_payload_region,
  output wire [7:0]    io_localMem_ar_payload_len,
  output wire [2:0]    io_localMem_ar_payload_size,
  output wire [1:0]    io_localMem_ar_payload_burst,
  output wire [0:0]    io_localMem_ar_payload_lock,
  output wire [3:0]    io_localMem_ar_payload_cache,
  output wire [3:0]    io_localMem_ar_payload_qos,
  output wire [2:0]    io_localMem_ar_payload_prot,
  input  wire          io_localMem_r_valid,
  output wire          io_localMem_r_ready,
  input  wire [63:0]   io_localMem_r_payload_data,
  input  wire [3:0]    io_localMem_r_payload_id,
  input  wire [1:0]    io_localMem_r_payload_resp,
  input  wire          io_localMem_r_payload_last,
  input  wire [31:0]   io_intReq,
  output wire [31:0]   io_intAck,
  output wire [31:0]   io_ioRegAddr,
  output wire [31:0]   io_ioRegWrData,
  input  wire [31:0]   io_ioRegRdData,
  output wire          io_ioRegWrEn,
  output wire          io_ioRegRdEn,
  output wire          io_linkUp,
  output wire [1:0]    io_linkSpeed,
  output wire [4:0]    io_ltssState,
  output wire          io_symbolAlign,
  output wire          io_codeErr,
  output wire          io_dispErr,
  output wire          io_h2dDone,
  output wire          io_d2hDone,
  output wire          io_dmaErr,
  input  wire          clk,
  input  wire          reset
);
  localparam LtssState_DETECT_QUIET = 5'd0;
  localparam LtssState_DETECT_ACTIVE = 5'd1;
  localparam LtssState_POLLING_ACTIVE = 5'd2;
  localparam LtssState_POLLING_COMPLIANCE = 5'd3;
  localparam LtssState_POLLING_CONFIG = 5'd4;
  localparam LtssState_CONFIG_LINKWIDTH_START = 5'd5;
  localparam LtssState_CONFIG_LINKWIDTH_ACCEPT = 5'd6;
  localparam LtssState_CONFIG_LANENUM_WAIT = 5'd7;
  localparam LtssState_CONFIG_LANENUM_ACCEPT = 5'd8;
  localparam LtssState_CONFIG_COMPLETE = 5'd9;
  localparam LtssState_CONFIG_IDLE = 5'd10;
  localparam LtssState_L0 = 5'd11;
  localparam LtssState_RECOVERY_RCVRLOCK = 5'd12;
  localparam LtssState_RECOVERY_RCVRCFG = 5'd13;
  localparam LtssState_RECOVERY_IDLE = 5'd14;
  localparam LtssState_L0S = 5'd15;
  localparam LtssState_L1_ENTRY = 5'd16;
  localparam LtssState_L1_IDLE = 5'd17;
  localparam LtssState_L1_EXIT = 5'd18;
  localparam LtssState_L2_IDLE = 5'd19;
  localparam LtssState_L2_TRANSMIT_WAKE = 5'd20;
  localparam LtssState_L2_DETECT_WAKE = 5'd21;
  localparam LtssState_DISABLED = 5'd22;
  localparam LtssState_HOT_RESET = 5'd23;
  localparam LtssState_LOOPBACK_ENTRY = 5'd24;
  localparam LtssState_LOOPBACK_ACTIVE = 5'd25;
  localparam LtssState_LOOPBACK_EXIT = 5'd26;
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  wire                dllpHandler_1_io_dllpIn_valid;
  wire       [31:0]   dllpHandler_1_io_dllpIn_payload;
  wire                dllpHandler_1_io_dllpValid;
  wire                fcMgr_io_init;
  wire       [7:0]    fcMgr_io_phConsumed;
  wire       [11:0]   fcMgr_io_pdConsumed;
  wire       [7:0]    fcMgr_io_nphConsumed;
  wire       [11:0]   fcMgr_io_npdConsumed;
  wire       [7:0]    fcMgr_io_cplhConsumed;
  wire       [11:0]   fcMgr_io_cpldConsumed;
  wire                rxEngine_io_memReq_ready;
  wire                rxEngine_io_memDataOut_ready;
  wire       [1:0]    ioHandler_io_regWidth;
  wire       [63:0]   cfgSpace_io_barCheckAddr;
  wire       [11:0]   msix_io_tableAddr;
  wire                msix_io_tableWen;
  wire                msix_io_msixEnable;
  wire                msix_io_funcMask;
  wire                phy_io_txData_ready;
  wire                phy_io_rxData_valid;
  wire       [31:0]   phy_io_rxData_payload;
  wire       [9:0]    phy_io_txSymbols;
  wire                phy_io_phyTxEn;
  wire                phy_io_phyRxPolarity;
  wire                phy_io_linkUp;
  wire       [4:0]    phy_io_ltssState;
  wire                phy_io_aligned;
  wire                phy_io_codeErr;
  wire                phy_io_disparityErr;
  wire       [7:0]    phy_io_busNum;
  wire                dlTx_io_tlpIn_ready;
  wire                dlTx_io_frameOut_valid;
  wire       [31:0]   dlTx_io_frameOut_payload;
  wire       [11:0]   dlTx_io_nextSeq;
  wire                dlRx_io_frameIn_ready;
  wire                dlRx_io_tlpOut_valid;
  wire       [31:0]   dlRx_io_tlpOut_payload;
  wire       [11:0]   dlRx_io_txAck;
  wire       [11:0]   dlRx_io_txNak;
  wire                dlRx_io_ackValid;
  wire                dlRx_io_nakValid;
  wire                dlRx_io_crcErr;
  wire                dllpHandler_1_io_dllpIn_ready;
  wire       [11:0]   dllpHandler_1_io_ackSeq;
  wire                dllpHandler_1_io_ackValid;
  wire       [11:0]   dllpHandler_1_io_nakSeq;
  wire                dllpHandler_1_io_nakValid;
  wire                dllpHandler_1_io_fcInitValid;
  wire       [7:0]    dllpHandler_1_io_fcInit_phCredits;
  wire       [11:0]   dllpHandler_1_io_fcInit_pdCredits;
  wire       [7:0]    dllpHandler_1_io_fcInit_nphCredits;
  wire       [11:0]   dllpHandler_1_io_fcInit_npdCredits;
  wire       [7:0]    dllpHandler_1_io_fcInit_cplhCredits;
  wire       [11:0]   dllpHandler_1_io_fcInit_cpldCredits;
  wire                dllpHandler_1_io_fcUpdateValid;
  wire       [7:0]    dllpHandler_1_io_fcUpdate_phCredits;
  wire       [11:0]   dllpHandler_1_io_fcUpdate_pdCredits;
  wire       [7:0]    dllpHandler_1_io_fcUpdate_nphCredits;
  wire       [11:0]   dllpHandler_1_io_fcUpdate_npdCredits;
  wire       [7:0]    dllpHandler_1_io_fcUpdate_cplhCredits;
  wire       [11:0]   dllpHandler_1_io_fcUpdate_cpldCredits;
  wire                dllpHandler_1_io_pmEnterL1;
  wire       [7:0]    fcMgr_io_available_phCredits;
  wire       [11:0]   fcMgr_io_available_pdCredits;
  wire       [7:0]    fcMgr_io_available_nphCredits;
  wire       [11:0]   fcMgr_io_available_npdCredits;
  wire       [7:0]    fcMgr_io_available_cplhCredits;
  wire       [11:0]   fcMgr_io_available_cpldCredits;
  wire                fcMgr_io_phExhausted;
  wire                fcMgr_io_nphExhausted;
  wire                fcMgr_io_cplhExhausted;
  wire                txEngine_io_memWrIn_ready;
  wire                txEngine_io_memRdIn_ready;
  wire                txEngine_io_cplIn_ready;
  wire                txEngine_io_tlpOut_valid;
  wire       [31:0]   txEngine_io_tlpOut_payload;
  wire                rxEngine_io_tlpIn_ready;
  wire                rxEngine_io_memReq_valid;
  wire       [3:0]    rxEngine_io_memReq_payload_tlpType;
  wire       [15:0]   rxEngine_io_memReq_payload_reqId;
  wire       [7:0]    rxEngine_io_memReq_payload_tag;
  wire       [63:0]   rxEngine_io_memReq_payload_addr;
  wire       [9:0]    rxEngine_io_memReq_payload_length;
  wire       [3:0]    rxEngine_io_memReq_payload_firstBe;
  wire       [3:0]    rxEngine_io_memReq_payload_lastBe;
  wire       [2:0]    rxEngine_io_memReq_payload_tc;
  wire       [1:0]    rxEngine_io_memReq_payload_attr;
  wire       [31:0]   rxEngine_io_memReq_payload_data_0;
  wire       [31:0]   rxEngine_io_memReq_payload_data_1;
  wire       [31:0]   rxEngine_io_memReq_payload_data_2;
  wire       [31:0]   rxEngine_io_memReq_payload_data_3;
  wire       [2:0]    rxEngine_io_memReq_payload_dataValid;
  wire                rxEngine_io_cfgReq_valid;
  wire       [3:0]    rxEngine_io_cfgReq_payload_tlpType;
  wire       [15:0]   rxEngine_io_cfgReq_payload_reqId;
  wire       [7:0]    rxEngine_io_cfgReq_payload_tag;
  wire       [63:0]   rxEngine_io_cfgReq_payload_addr;
  wire       [9:0]    rxEngine_io_cfgReq_payload_length;
  wire       [3:0]    rxEngine_io_cfgReq_payload_firstBe;
  wire       [3:0]    rxEngine_io_cfgReq_payload_lastBe;
  wire       [2:0]    rxEngine_io_cfgReq_payload_tc;
  wire       [1:0]    rxEngine_io_cfgReq_payload_attr;
  wire       [31:0]   rxEngine_io_cfgReq_payload_data_0;
  wire       [31:0]   rxEngine_io_cfgReq_payload_data_1;
  wire       [31:0]   rxEngine_io_cfgReq_payload_data_2;
  wire       [31:0]   rxEngine_io_cfgReq_payload_data_3;
  wire       [2:0]    rxEngine_io_cfgReq_payload_dataValid;
  wire                rxEngine_io_cplIn_valid;
  wire       [3:0]    rxEngine_io_cplIn_payload_tlpType;
  wire       [15:0]   rxEngine_io_cplIn_payload_reqId;
  wire       [7:0]    rxEngine_io_cplIn_payload_tag;
  wire       [63:0]   rxEngine_io_cplIn_payload_addr;
  wire       [9:0]    rxEngine_io_cplIn_payload_length;
  wire       [3:0]    rxEngine_io_cplIn_payload_firstBe;
  wire       [3:0]    rxEngine_io_cplIn_payload_lastBe;
  wire       [2:0]    rxEngine_io_cplIn_payload_tc;
  wire       [1:0]    rxEngine_io_cplIn_payload_attr;
  wire       [31:0]   rxEngine_io_cplIn_payload_data_0;
  wire       [31:0]   rxEngine_io_cplIn_payload_data_1;
  wire       [31:0]   rxEngine_io_cplIn_payload_data_2;
  wire       [31:0]   rxEngine_io_cplIn_payload_data_3;
  wire       [2:0]    rxEngine_io_cplIn_payload_dataValid;
  wire                rxEngine_io_ioReq_valid;
  wire       [3:0]    rxEngine_io_ioReq_payload_tlpType;
  wire       [15:0]   rxEngine_io_ioReq_payload_reqId;
  wire       [7:0]    rxEngine_io_ioReq_payload_tag;
  wire       [63:0]   rxEngine_io_ioReq_payload_addr;
  wire       [9:0]    rxEngine_io_ioReq_payload_length;
  wire       [3:0]    rxEngine_io_ioReq_payload_firstBe;
  wire       [3:0]    rxEngine_io_ioReq_payload_lastBe;
  wire       [2:0]    rxEngine_io_ioReq_payload_tc;
  wire       [1:0]    rxEngine_io_ioReq_payload_attr;
  wire       [31:0]   rxEngine_io_ioReq_payload_data_0;
  wire       [31:0]   rxEngine_io_ioReq_payload_data_1;
  wire       [31:0]   rxEngine_io_ioReq_payload_data_2;
  wire       [31:0]   rxEngine_io_ioReq_payload_data_3;
  wire       [2:0]    rxEngine_io_ioReq_payload_dataValid;
  wire                rxEngine_io_memDataOut_valid;
  wire       [31:0]   rxEngine_io_memDataOut_payload_data;
  wire                rxEngine_io_memDataOut_payload_valid;
  wire                rxEngine_io_memDataOut_payload_last;
  wire       [3:0]    rxEngine_io_memDataOut_payload_byteEn;
  wire                rxEngine_io_memDataStart;
  wire                rxEngine_io_parseErr;
  wire                rxEngine_io_overflow;
  wire                ioHandler_io_ioReq_ready;
  wire                ioHandler_io_cplOut_valid;
  wire       [3:0]    ioHandler_io_cplOut_payload_tlpType;
  wire       [15:0]   ioHandler_io_cplOut_payload_reqId;
  wire       [7:0]    ioHandler_io_cplOut_payload_tag;
  wire       [63:0]   ioHandler_io_cplOut_payload_addr;
  wire       [9:0]    ioHandler_io_cplOut_payload_length;
  wire       [3:0]    ioHandler_io_cplOut_payload_firstBe;
  wire       [3:0]    ioHandler_io_cplOut_payload_lastBe;
  wire       [2:0]    ioHandler_io_cplOut_payload_tc;
  wire       [1:0]    ioHandler_io_cplOut_payload_attr;
  wire       [31:0]   ioHandler_io_cplOut_payload_data_0;
  wire       [31:0]   ioHandler_io_cplOut_payload_data_1;
  wire       [31:0]   ioHandler_io_cplOut_payload_data_2;
  wire       [31:0]   ioHandler_io_cplOut_payload_data_3;
  wire       [2:0]    ioHandler_io_cplOut_payload_dataValid;
  wire       [31:0]   ioHandler_io_regAddr;
  wire       [31:0]   ioHandler_io_regWrData;
  wire                ioHandler_io_regWrEn;
  wire                ioHandler_io_regRdEn;
  wire                ioHandler_io_ioErr;
  wire                cfgSpace_io_cfgReq_ready;
  wire                cfgSpace_io_cfgResp_valid;
  wire       [3:0]    cfgSpace_io_cfgResp_payload_tlpType;
  wire       [15:0]   cfgSpace_io_cfgResp_payload_reqId;
  wire       [7:0]    cfgSpace_io_cfgResp_payload_tag;
  wire       [63:0]   cfgSpace_io_cfgResp_payload_addr;
  wire       [9:0]    cfgSpace_io_cfgResp_payload_length;
  wire       [3:0]    cfgSpace_io_cfgResp_payload_firstBe;
  wire       [3:0]    cfgSpace_io_cfgResp_payload_lastBe;
  wire       [2:0]    cfgSpace_io_cfgResp_payload_tc;
  wire       [1:0]    cfgSpace_io_cfgResp_payload_attr;
  wire       [31:0]   cfgSpace_io_cfgResp_payload_data_0;
  wire       [31:0]   cfgSpace_io_cfgResp_payload_data_1;
  wire       [31:0]   cfgSpace_io_cfgResp_payload_data_2;
  wire       [31:0]   cfgSpace_io_cfgResp_payload_data_3;
  wire       [2:0]    cfgSpace_io_cfgResp_payload_dataValid;
  wire       [5:0]    cfgSpace_io_barHit;
  wire       [15:0]   cfgSpace_io_cfgRegs_vendorId;
  wire       [15:0]   cfgSpace_io_cfgRegs_deviceId;
  wire       [15:0]   cfgSpace_io_cfgRegs_command;
  wire       [15:0]   cfgSpace_io_cfgRegs_status;
  wire       [7:0]    cfgSpace_io_cfgRegs_revisionId;
  wire       [23:0]   cfgSpace_io_cfgRegs_classCode;
  wire       [7:0]    cfgSpace_io_cfgRegs_cacheLineSize;
  wire       [7:0]    cfgSpace_io_cfgRegs_latencyTimer;
  wire       [7:0]    cfgSpace_io_cfgRegs_headerType;
  wire       [7:0]    cfgSpace_io_cfgRegs_bist;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_0;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_1;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_2;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_3;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_4;
  wire       [31:0]   cfgSpace_io_cfgRegs_bar_5;
  wire       [15:0]   cfgSpace_io_cfgRegs_subVendorId;
  wire       [15:0]   cfgSpace_io_cfgRegs_subSystemId;
  wire       [7:0]    cfgSpace_io_cfgRegs_capPointer;
  wire       [7:0]    cfgSpace_io_cfgRegs_intLine;
  wire       [7:0]    cfgSpace_io_cfgRegs_intPin;
  wire                dma_io_ctrl_ar_ready;
  wire                dma_io_ctrl_aw_ready;
  wire                dma_io_ctrl_w_ready;
  wire                dma_io_ctrl_r_valid;
  wire       [31:0]   dma_io_ctrl_r_payload_data;
  wire       [3:0]    dma_io_ctrl_r_payload_id;
  wire       [1:0]    dma_io_ctrl_r_payload_resp;
  wire                dma_io_ctrl_r_payload_last;
  wire                dma_io_ctrl_b_valid;
  wire       [3:0]    dma_io_ctrl_b_payload_id;
  wire       [1:0]    dma_io_ctrl_b_payload_resp;
  wire                dma_io_memWrOut_valid;
  wire       [3:0]    dma_io_memWrOut_payload_tlpType;
  wire       [15:0]   dma_io_memWrOut_payload_reqId;
  wire       [7:0]    dma_io_memWrOut_payload_tag;
  wire       [63:0]   dma_io_memWrOut_payload_addr;
  wire       [9:0]    dma_io_memWrOut_payload_length;
  wire       [3:0]    dma_io_memWrOut_payload_firstBe;
  wire       [3:0]    dma_io_memWrOut_payload_lastBe;
  wire       [2:0]    dma_io_memWrOut_payload_tc;
  wire       [1:0]    dma_io_memWrOut_payload_attr;
  wire       [31:0]   dma_io_memWrOut_payload_data_0;
  wire       [31:0]   dma_io_memWrOut_payload_data_1;
  wire       [31:0]   dma_io_memWrOut_payload_data_2;
  wire       [31:0]   dma_io_memWrOut_payload_data_3;
  wire       [2:0]    dma_io_memWrOut_payload_dataValid;
  wire                dma_io_memRdOut_valid;
  wire       [3:0]    dma_io_memRdOut_payload_tlpType;
  wire       [15:0]   dma_io_memRdOut_payload_reqId;
  wire       [7:0]    dma_io_memRdOut_payload_tag;
  wire       [63:0]   dma_io_memRdOut_payload_addr;
  wire       [9:0]    dma_io_memRdOut_payload_length;
  wire       [3:0]    dma_io_memRdOut_payload_firstBe;
  wire       [3:0]    dma_io_memRdOut_payload_lastBe;
  wire       [2:0]    dma_io_memRdOut_payload_tc;
  wire       [1:0]    dma_io_memRdOut_payload_attr;
  wire       [31:0]   dma_io_memRdOut_payload_data_0;
  wire       [31:0]   dma_io_memRdOut_payload_data_1;
  wire       [31:0]   dma_io_memRdOut_payload_data_2;
  wire       [31:0]   dma_io_memRdOut_payload_data_3;
  wire       [2:0]    dma_io_memRdOut_payload_dataValid;
  wire                dma_io_cplIn_ready;
  wire                dma_io_localMem_ar_valid;
  wire       [31:0]   dma_io_localMem_ar_payload_addr;
  wire       [3:0]    dma_io_localMem_ar_payload_id;
  wire       [3:0]    dma_io_localMem_ar_payload_region;
  wire       [7:0]    dma_io_localMem_ar_payload_len;
  wire       [2:0]    dma_io_localMem_ar_payload_size;
  wire       [1:0]    dma_io_localMem_ar_payload_burst;
  wire       [0:0]    dma_io_localMem_ar_payload_lock;
  wire       [3:0]    dma_io_localMem_ar_payload_cache;
  wire       [3:0]    dma_io_localMem_ar_payload_qos;
  wire       [2:0]    dma_io_localMem_ar_payload_prot;
  wire                dma_io_localMem_aw_valid;
  wire       [31:0]   dma_io_localMem_aw_payload_addr;
  wire       [3:0]    dma_io_localMem_aw_payload_id;
  wire       [3:0]    dma_io_localMem_aw_payload_region;
  wire       [7:0]    dma_io_localMem_aw_payload_len;
  wire       [2:0]    dma_io_localMem_aw_payload_size;
  wire       [1:0]    dma_io_localMem_aw_payload_burst;
  wire       [0:0]    dma_io_localMem_aw_payload_lock;
  wire       [3:0]    dma_io_localMem_aw_payload_cache;
  wire       [3:0]    dma_io_localMem_aw_payload_qos;
  wire       [2:0]    dma_io_localMem_aw_payload_prot;
  wire                dma_io_localMem_w_valid;
  wire       [63:0]   dma_io_localMem_w_payload_data;
  wire       [7:0]    dma_io_localMem_w_payload_strb;
  wire                dma_io_localMem_w_payload_last;
  wire                dma_io_localMem_r_ready;
  wire                dma_io_localMem_b_ready;
  wire                dma_io_h2dDone;
  wire                dma_io_d2hDone;
  wire                dma_io_dmaErr;
  wire       [31:0]   msix_io_intAck;
  wire                msix_io_msgTlpOut_valid;
  wire       [3:0]    msix_io_msgTlpOut_payload_tlpType;
  wire       [15:0]   msix_io_msgTlpOut_payload_reqId;
  wire       [7:0]    msix_io_msgTlpOut_payload_tag;
  wire       [63:0]   msix_io_msgTlpOut_payload_addr;
  wire       [9:0]    msix_io_msgTlpOut_payload_length;
  wire       [3:0]    msix_io_msgTlpOut_payload_firstBe;
  wire       [3:0]    msix_io_msgTlpOut_payload_lastBe;
  wire       [2:0]    msix_io_msgTlpOut_payload_tc;
  wire       [1:0]    msix_io_msgTlpOut_payload_attr;
  wire       [31:0]   msix_io_msgTlpOut_payload_data_0;
  wire       [31:0]   msix_io_msgTlpOut_payload_data_1;
  wire       [31:0]   msix_io_msgTlpOut_payload_data_2;
  wire       [31:0]   msix_io_msgTlpOut_payload_data_3;
  wire       [2:0]    msix_io_msgTlpOut_payload_dataValid;
  wire       [31:0]   msix_io_tableRdata;
  wire                streamArbiter_1_io_inputs_0_ready;
  wire                streamArbiter_1_io_inputs_1_ready;
  wire                streamArbiter_1_io_inputs_2_ready;
  wire                streamArbiter_1_io_output_valid;
  wire       [3:0]    streamArbiter_1_io_output_payload_tlpType;
  wire       [15:0]   streamArbiter_1_io_output_payload_reqId;
  wire       [7:0]    streamArbiter_1_io_output_payload_tag;
  wire       [63:0]   streamArbiter_1_io_output_payload_addr;
  wire       [9:0]    streamArbiter_1_io_output_payload_length;
  wire       [3:0]    streamArbiter_1_io_output_payload_firstBe;
  wire       [3:0]    streamArbiter_1_io_output_payload_lastBe;
  wire       [2:0]    streamArbiter_1_io_output_payload_tc;
  wire       [1:0]    streamArbiter_1_io_output_payload_attr;
  wire       [31:0]   streamArbiter_1_io_output_payload_data_0;
  wire       [31:0]   streamArbiter_1_io_output_payload_data_1;
  wire       [31:0]   streamArbiter_1_io_output_payload_data_2;
  wire       [31:0]   streamArbiter_1_io_output_payload_data_3;
  wire       [2:0]    streamArbiter_1_io_output_payload_dataValid;
  wire       [1:0]    streamArbiter_1_io_chosen;
  wire       [2:0]    streamArbiter_1_io_chosenOH;
  reg        [15:0]   myBdf;
  wire                when_PcieController_l99;
  wire                isBar1Req;
  wire                memWrArb_valid;
  wire                memWrArb_ready;
  wire       [3:0]    memWrArb_payload_tlpType;
  wire       [15:0]   memWrArb_payload_reqId;
  wire       [7:0]    memWrArb_payload_tag;
  wire       [63:0]   memWrArb_payload_addr;
  wire       [9:0]    memWrArb_payload_length;
  wire       [3:0]    memWrArb_payload_firstBe;
  wire       [3:0]    memWrArb_payload_lastBe;
  wire       [2:0]    memWrArb_payload_tc;
  wire       [1:0]    memWrArb_payload_attr;
  wire       [31:0]   memWrArb_payload_data_0;
  wire       [31:0]   memWrArb_payload_data_1;
  wire       [31:0]   memWrArb_payload_data_2;
  wire       [31:0]   memWrArb_payload_data_3;
  wire       [2:0]    memWrArb_payload_dataValid;
  `ifndef SYNTHESIS
  reg [183:0] io_ltssState_string;
  reg [55:0] memWrArb_payload_tlpType_string;
  `endif


  PhysicalLayer phy (
    .io_txData_valid   (dlTx_io_frameOut_valid        ), //i
    .io_txData_ready   (phy_io_txData_ready           ), //o
    .io_txData_payload (dlTx_io_frameOut_payload[31:0]), //i
    .io_rxData_valid   (phy_io_rxData_valid           ), //o
    .io_rxData_ready   (dlRx_io_frameIn_ready         ), //i
    .io_rxData_payload (phy_io_rxData_payload[31:0]   ), //o
    .io_txSymbols      (phy_io_txSymbols[9:0]         ), //o
    .io_rxSymbols      (io_rxSymbols[9:0]             ), //i
    .io_phyTxEn        (phy_io_phyTxEn                ), //o
    .io_phyRxPolarity  (phy_io_phyRxPolarity          ), //o
    .io_phyRxElecIdle  (io_phyRxElecIdle              ), //i
    .io_phyRxValid     (io_phyRxValid                 ), //i
    .io_linkUp         (phy_io_linkUp                 ), //o
    .io_ltssState      (phy_io_ltssState[4:0]         ), //o
    .io_aligned        (phy_io_aligned                ), //o
    .io_codeErr        (phy_io_codeErr                ), //o
    .io_disparityErr   (phy_io_disparityErr           ), //o
    .io_busNum         (phy_io_busNum[7:0]            ), //o
    .clk               (clk                           ), //i
    .reset             (reset                         )  //i
  );
  DlTxFramer dlTx (
    .io_tlpIn_valid      (txEngine_io_tlpOut_valid        ), //i
    .io_tlpIn_ready      (dlTx_io_tlpIn_ready             ), //o
    .io_tlpIn_payload    (txEngine_io_tlpOut_payload[31:0]), //i
    .io_frameOut_valid   (dlTx_io_frameOut_valid          ), //o
    .io_frameOut_ready   (phy_io_txData_ready             ), //i
    .io_frameOut_payload (dlTx_io_frameOut_payload[31:0]  ), //o
    .io_seqAck           (dlRx_io_txAck[11:0]             ), //i
    .io_nextSeq          (dlTx_io_nextSeq[11:0]           ), //o
    .clk                 (clk                             ), //i
    .reset               (reset                           )  //i
  );
  DlRxDeframer dlRx (
    .io_frameIn_valid   (phy_io_rxData_valid         ), //i
    .io_frameIn_ready   (dlRx_io_frameIn_ready       ), //o
    .io_frameIn_payload (phy_io_rxData_payload[31:0] ), //i
    .io_tlpOut_valid    (dlRx_io_tlpOut_valid        ), //o
    .io_tlpOut_ready    (rxEngine_io_tlpIn_ready     ), //i
    .io_tlpOut_payload  (dlRx_io_tlpOut_payload[31:0]), //o
    .io_txAck           (dlRx_io_txAck[11:0]         ), //o
    .io_txNak           (dlRx_io_txNak[11:0]         ), //o
    .io_ackValid        (dlRx_io_ackValid            ), //o
    .io_nakValid        (dlRx_io_nakValid            ), //o
    .io_crcErr          (dlRx_io_crcErr              ), //o
    .clk                (clk                         ), //i
    .reset              (reset                       )  //i
  );
  DllpHandler dllpHandler_1 (
    .io_dllpIn_valid         (dllpHandler_1_io_dllpIn_valid              ), //i
    .io_dllpIn_ready         (dllpHandler_1_io_dllpIn_ready              ), //o
    .io_dllpIn_payload       (dllpHandler_1_io_dllpIn_payload[31:0]      ), //i
    .io_dllpValid            (dllpHandler_1_io_dllpValid                 ), //i
    .io_ackSeq               (dllpHandler_1_io_ackSeq[11:0]              ), //o
    .io_ackValid             (dllpHandler_1_io_ackValid                  ), //o
    .io_nakSeq               (dllpHandler_1_io_nakSeq[11:0]              ), //o
    .io_nakValid             (dllpHandler_1_io_nakValid                  ), //o
    .io_fcInitValid          (dllpHandler_1_io_fcInitValid               ), //o
    .io_fcInit_phCredits     (dllpHandler_1_io_fcInit_phCredits[7:0]     ), //o
    .io_fcInit_pdCredits     (dllpHandler_1_io_fcInit_pdCredits[11:0]    ), //o
    .io_fcInit_nphCredits    (dllpHandler_1_io_fcInit_nphCredits[7:0]    ), //o
    .io_fcInit_npdCredits    (dllpHandler_1_io_fcInit_npdCredits[11:0]   ), //o
    .io_fcInit_cplhCredits   (dllpHandler_1_io_fcInit_cplhCredits[7:0]   ), //o
    .io_fcInit_cpldCredits   (dllpHandler_1_io_fcInit_cpldCredits[11:0]  ), //o
    .io_fcUpdateValid        (dllpHandler_1_io_fcUpdateValid             ), //o
    .io_fcUpdate_phCredits   (dllpHandler_1_io_fcUpdate_phCredits[7:0]   ), //o
    .io_fcUpdate_pdCredits   (dllpHandler_1_io_fcUpdate_pdCredits[11:0]  ), //o
    .io_fcUpdate_nphCredits  (dllpHandler_1_io_fcUpdate_nphCredits[7:0]  ), //o
    .io_fcUpdate_npdCredits  (dllpHandler_1_io_fcUpdate_npdCredits[11:0] ), //o
    .io_fcUpdate_cplhCredits (dllpHandler_1_io_fcUpdate_cplhCredits[7:0] ), //o
    .io_fcUpdate_cpldCredits (dllpHandler_1_io_fcUpdate_cpldCredits[11:0]), //o
    .io_pmEnterL1            (dllpHandler_1_io_pmEnterL1                 )  //o
  );
  FlowControlMgr fcMgr (
    .io_init                  (fcMgr_io_init                              ), //i
    .io_linkUp                (phy_io_linkUp                              ), //i
    .io_phConsumed            (fcMgr_io_phConsumed[7:0]                   ), //i
    .io_pdConsumed            (fcMgr_io_pdConsumed[11:0]                  ), //i
    .io_nphConsumed           (fcMgr_io_nphConsumed[7:0]                  ), //i
    .io_npdConsumed           (fcMgr_io_npdConsumed[11:0]                 ), //i
    .io_cplhConsumed          (fcMgr_io_cplhConsumed[7:0]                 ), //i
    .io_cpldConsumed          (fcMgr_io_cpldConsumed[11:0]                ), //i
    .io_fcUpdateValid         (dllpHandler_1_io_fcUpdateValid             ), //i
    .io_fcUpdate_phCredits    (dllpHandler_1_io_fcUpdate_phCredits[7:0]   ), //i
    .io_fcUpdate_pdCredits    (dllpHandler_1_io_fcUpdate_pdCredits[11:0]  ), //i
    .io_fcUpdate_nphCredits   (dllpHandler_1_io_fcUpdate_nphCredits[7:0]  ), //i
    .io_fcUpdate_npdCredits   (dllpHandler_1_io_fcUpdate_npdCredits[11:0] ), //i
    .io_fcUpdate_cplhCredits  (dllpHandler_1_io_fcUpdate_cplhCredits[7:0] ), //i
    .io_fcUpdate_cpldCredits  (dllpHandler_1_io_fcUpdate_cpldCredits[11:0]), //i
    .io_fcInitValid           (dllpHandler_1_io_fcInitValid               ), //i
    .io_fcInit_phCredits      (dllpHandler_1_io_fcInit_phCredits[7:0]     ), //i
    .io_fcInit_pdCredits      (dllpHandler_1_io_fcInit_pdCredits[11:0]    ), //i
    .io_fcInit_nphCredits     (dllpHandler_1_io_fcInit_nphCredits[7:0]    ), //i
    .io_fcInit_npdCredits     (dllpHandler_1_io_fcInit_npdCredits[11:0]   ), //i
    .io_fcInit_cplhCredits    (dllpHandler_1_io_fcInit_cplhCredits[7:0]   ), //i
    .io_fcInit_cpldCredits    (dllpHandler_1_io_fcInit_cpldCredits[11:0]  ), //i
    .io_available_phCredits   (fcMgr_io_available_phCredits[7:0]          ), //o
    .io_available_pdCredits   (fcMgr_io_available_pdCredits[11:0]         ), //o
    .io_available_nphCredits  (fcMgr_io_available_nphCredits[7:0]         ), //o
    .io_available_npdCredits  (fcMgr_io_available_npdCredits[11:0]        ), //o
    .io_available_cplhCredits (fcMgr_io_available_cplhCredits[7:0]        ), //o
    .io_available_cpldCredits (fcMgr_io_available_cpldCredits[11:0]       ), //o
    .io_phExhausted           (fcMgr_io_phExhausted                       ), //o
    .io_nphExhausted          (fcMgr_io_nphExhausted                      ), //o
    .io_cplhExhausted         (fcMgr_io_cplhExhausted                     ), //o
    .clk                      (clk                                        ), //i
    .reset                    (reset                                      )  //i
  );
  TlpTxFifoWrapper txEngine (
    .io_memWrIn_valid             (memWrArb_valid                            ), //i
    .io_memWrIn_ready             (txEngine_io_memWrIn_ready                 ), //o
    .io_memWrIn_payload_tlpType   (memWrArb_payload_tlpType[3:0]             ), //i
    .io_memWrIn_payload_reqId     (memWrArb_payload_reqId[15:0]              ), //i
    .io_memWrIn_payload_tag       (memWrArb_payload_tag[7:0]                 ), //i
    .io_memWrIn_payload_addr      (memWrArb_payload_addr[63:0]               ), //i
    .io_memWrIn_payload_length    (memWrArb_payload_length[9:0]              ), //i
    .io_memWrIn_payload_firstBe   (memWrArb_payload_firstBe[3:0]             ), //i
    .io_memWrIn_payload_lastBe    (memWrArb_payload_lastBe[3:0]              ), //i
    .io_memWrIn_payload_tc        (memWrArb_payload_tc[2:0]                  ), //i
    .io_memWrIn_payload_attr      (memWrArb_payload_attr[1:0]                ), //i
    .io_memWrIn_payload_data_0    (memWrArb_payload_data_0[31:0]             ), //i
    .io_memWrIn_payload_data_1    (memWrArb_payload_data_1[31:0]             ), //i
    .io_memWrIn_payload_data_2    (memWrArb_payload_data_2[31:0]             ), //i
    .io_memWrIn_payload_data_3    (memWrArb_payload_data_3[31:0]             ), //i
    .io_memWrIn_payload_dataValid (memWrArb_payload_dataValid[2:0]           ), //i
    .io_memRdIn_valid             (dma_io_memRdOut_valid                     ), //i
    .io_memRdIn_ready             (txEngine_io_memRdIn_ready                 ), //o
    .io_memRdIn_payload_tlpType   (dma_io_memRdOut_payload_tlpType[3:0]      ), //i
    .io_memRdIn_payload_reqId     (dma_io_memRdOut_payload_reqId[15:0]       ), //i
    .io_memRdIn_payload_tag       (dma_io_memRdOut_payload_tag[7:0]          ), //i
    .io_memRdIn_payload_addr      (dma_io_memRdOut_payload_addr[63:0]        ), //i
    .io_memRdIn_payload_length    (dma_io_memRdOut_payload_length[9:0]       ), //i
    .io_memRdIn_payload_firstBe   (dma_io_memRdOut_payload_firstBe[3:0]      ), //i
    .io_memRdIn_payload_lastBe    (dma_io_memRdOut_payload_lastBe[3:0]       ), //i
    .io_memRdIn_payload_tc        (dma_io_memRdOut_payload_tc[2:0]           ), //i
    .io_memRdIn_payload_attr      (dma_io_memRdOut_payload_attr[1:0]         ), //i
    .io_memRdIn_payload_data_0    (dma_io_memRdOut_payload_data_0[31:0]      ), //i
    .io_memRdIn_payload_data_1    (dma_io_memRdOut_payload_data_1[31:0]      ), //i
    .io_memRdIn_payload_data_2    (dma_io_memRdOut_payload_data_2[31:0]      ), //i
    .io_memRdIn_payload_data_3    (dma_io_memRdOut_payload_data_3[31:0]      ), //i
    .io_memRdIn_payload_dataValid (dma_io_memRdOut_payload_dataValid[2:0]    ), //i
    .io_cplIn_valid               (cfgSpace_io_cfgResp_valid                 ), //i
    .io_cplIn_ready               (txEngine_io_cplIn_ready                   ), //o
    .io_cplIn_payload_tlpType     (cfgSpace_io_cfgResp_payload_tlpType[3:0]  ), //i
    .io_cplIn_payload_reqId       (cfgSpace_io_cfgResp_payload_reqId[15:0]   ), //i
    .io_cplIn_payload_tag         (cfgSpace_io_cfgResp_payload_tag[7:0]      ), //i
    .io_cplIn_payload_addr        (cfgSpace_io_cfgResp_payload_addr[63:0]    ), //i
    .io_cplIn_payload_length      (cfgSpace_io_cfgResp_payload_length[9:0]   ), //i
    .io_cplIn_payload_firstBe     (cfgSpace_io_cfgResp_payload_firstBe[3:0]  ), //i
    .io_cplIn_payload_lastBe      (cfgSpace_io_cfgResp_payload_lastBe[3:0]   ), //i
    .io_cplIn_payload_tc          (cfgSpace_io_cfgResp_payload_tc[2:0]       ), //i
    .io_cplIn_payload_attr        (cfgSpace_io_cfgResp_payload_attr[1:0]     ), //i
    .io_cplIn_payload_data_0      (cfgSpace_io_cfgResp_payload_data_0[31:0]  ), //i
    .io_cplIn_payload_data_1      (cfgSpace_io_cfgResp_payload_data_1[31:0]  ), //i
    .io_cplIn_payload_data_2      (cfgSpace_io_cfgResp_payload_data_2[31:0]  ), //i
    .io_cplIn_payload_data_3      (cfgSpace_io_cfgResp_payload_data_3[31:0]  ), //i
    .io_cplIn_payload_dataValid   (cfgSpace_io_cfgResp_payload_dataValid[2:0]), //i
    .io_tlpOut_valid              (txEngine_io_tlpOut_valid                  ), //o
    .io_tlpOut_ready              (dlTx_io_tlpIn_ready                       ), //i
    .io_tlpOut_payload            (txEngine_io_tlpOut_payload[31:0]          ), //o
    .io_fcCredits_phCredits       (fcMgr_io_available_phCredits[7:0]         ), //i
    .io_fcCredits_pdCredits       (fcMgr_io_available_pdCredits[11:0]        ), //i
    .io_fcCredits_nphCredits      (fcMgr_io_available_nphCredits[7:0]        ), //i
    .io_fcCredits_npdCredits      (fcMgr_io_available_npdCredits[11:0]       ), //i
    .io_fcCredits_cplhCredits     (fcMgr_io_available_cplhCredits[7:0]       ), //i
    .io_fcCredits_cpldCredits     (fcMgr_io_available_cpldCredits[11:0]      ), //i
    .clk                          (clk                                       ), //i
    .reset                        (reset                                     )  //i
  );
  TlpRxEngine rxEngine (
    .io_tlpIn_valid               (dlRx_io_tlpOut_valid                      ), //i
    .io_tlpIn_ready               (rxEngine_io_tlpIn_ready                   ), //o
    .io_tlpIn_payload             (dlRx_io_tlpOut_payload[31:0]              ), //i
    .io_memReq_valid              (rxEngine_io_memReq_valid                  ), //o
    .io_memReq_ready              (rxEngine_io_memReq_ready                  ), //i
    .io_memReq_payload_tlpType    (rxEngine_io_memReq_payload_tlpType[3:0]   ), //o
    .io_memReq_payload_reqId      (rxEngine_io_memReq_payload_reqId[15:0]    ), //o
    .io_memReq_payload_tag        (rxEngine_io_memReq_payload_tag[7:0]       ), //o
    .io_memReq_payload_addr       (rxEngine_io_memReq_payload_addr[63:0]     ), //o
    .io_memReq_payload_length     (rxEngine_io_memReq_payload_length[9:0]    ), //o
    .io_memReq_payload_firstBe    (rxEngine_io_memReq_payload_firstBe[3:0]   ), //o
    .io_memReq_payload_lastBe     (rxEngine_io_memReq_payload_lastBe[3:0]    ), //o
    .io_memReq_payload_tc         (rxEngine_io_memReq_payload_tc[2:0]        ), //o
    .io_memReq_payload_attr       (rxEngine_io_memReq_payload_attr[1:0]      ), //o
    .io_memReq_payload_data_0     (rxEngine_io_memReq_payload_data_0[31:0]   ), //o
    .io_memReq_payload_data_1     (rxEngine_io_memReq_payload_data_1[31:0]   ), //o
    .io_memReq_payload_data_2     (rxEngine_io_memReq_payload_data_2[31:0]   ), //o
    .io_memReq_payload_data_3     (rxEngine_io_memReq_payload_data_3[31:0]   ), //o
    .io_memReq_payload_dataValid  (rxEngine_io_memReq_payload_dataValid[2:0] ), //o
    .io_cfgReq_valid              (rxEngine_io_cfgReq_valid                  ), //o
    .io_cfgReq_ready              (cfgSpace_io_cfgReq_ready                  ), //i
    .io_cfgReq_payload_tlpType    (rxEngine_io_cfgReq_payload_tlpType[3:0]   ), //o
    .io_cfgReq_payload_reqId      (rxEngine_io_cfgReq_payload_reqId[15:0]    ), //o
    .io_cfgReq_payload_tag        (rxEngine_io_cfgReq_payload_tag[7:0]       ), //o
    .io_cfgReq_payload_addr       (rxEngine_io_cfgReq_payload_addr[63:0]     ), //o
    .io_cfgReq_payload_length     (rxEngine_io_cfgReq_payload_length[9:0]    ), //o
    .io_cfgReq_payload_firstBe    (rxEngine_io_cfgReq_payload_firstBe[3:0]   ), //o
    .io_cfgReq_payload_lastBe     (rxEngine_io_cfgReq_payload_lastBe[3:0]    ), //o
    .io_cfgReq_payload_tc         (rxEngine_io_cfgReq_payload_tc[2:0]        ), //o
    .io_cfgReq_payload_attr       (rxEngine_io_cfgReq_payload_attr[1:0]      ), //o
    .io_cfgReq_payload_data_0     (rxEngine_io_cfgReq_payload_data_0[31:0]   ), //o
    .io_cfgReq_payload_data_1     (rxEngine_io_cfgReq_payload_data_1[31:0]   ), //o
    .io_cfgReq_payload_data_2     (rxEngine_io_cfgReq_payload_data_2[31:0]   ), //o
    .io_cfgReq_payload_data_3     (rxEngine_io_cfgReq_payload_data_3[31:0]   ), //o
    .io_cfgReq_payload_dataValid  (rxEngine_io_cfgReq_payload_dataValid[2:0] ), //o
    .io_cplIn_valid               (rxEngine_io_cplIn_valid                   ), //o
    .io_cplIn_ready               (dma_io_cplIn_ready                        ), //i
    .io_cplIn_payload_tlpType     (rxEngine_io_cplIn_payload_tlpType[3:0]    ), //o
    .io_cplIn_payload_reqId       (rxEngine_io_cplIn_payload_reqId[15:0]     ), //o
    .io_cplIn_payload_tag         (rxEngine_io_cplIn_payload_tag[7:0]        ), //o
    .io_cplIn_payload_addr        (rxEngine_io_cplIn_payload_addr[63:0]      ), //o
    .io_cplIn_payload_length      (rxEngine_io_cplIn_payload_length[9:0]     ), //o
    .io_cplIn_payload_firstBe     (rxEngine_io_cplIn_payload_firstBe[3:0]    ), //o
    .io_cplIn_payload_lastBe      (rxEngine_io_cplIn_payload_lastBe[3:0]     ), //o
    .io_cplIn_payload_tc          (rxEngine_io_cplIn_payload_tc[2:0]         ), //o
    .io_cplIn_payload_attr        (rxEngine_io_cplIn_payload_attr[1:0]       ), //o
    .io_cplIn_payload_data_0      (rxEngine_io_cplIn_payload_data_0[31:0]    ), //o
    .io_cplIn_payload_data_1      (rxEngine_io_cplIn_payload_data_1[31:0]    ), //o
    .io_cplIn_payload_data_2      (rxEngine_io_cplIn_payload_data_2[31:0]    ), //o
    .io_cplIn_payload_data_3      (rxEngine_io_cplIn_payload_data_3[31:0]    ), //o
    .io_cplIn_payload_dataValid   (rxEngine_io_cplIn_payload_dataValid[2:0]  ), //o
    .io_ioReq_valid               (rxEngine_io_ioReq_valid                   ), //o
    .io_ioReq_ready               (ioHandler_io_ioReq_ready                  ), //i
    .io_ioReq_payload_tlpType     (rxEngine_io_ioReq_payload_tlpType[3:0]    ), //o
    .io_ioReq_payload_reqId       (rxEngine_io_ioReq_payload_reqId[15:0]     ), //o
    .io_ioReq_payload_tag         (rxEngine_io_ioReq_payload_tag[7:0]        ), //o
    .io_ioReq_payload_addr        (rxEngine_io_ioReq_payload_addr[63:0]      ), //o
    .io_ioReq_payload_length      (rxEngine_io_ioReq_payload_length[9:0]     ), //o
    .io_ioReq_payload_firstBe     (rxEngine_io_ioReq_payload_firstBe[3:0]    ), //o
    .io_ioReq_payload_lastBe      (rxEngine_io_ioReq_payload_lastBe[3:0]     ), //o
    .io_ioReq_payload_tc          (rxEngine_io_ioReq_payload_tc[2:0]         ), //o
    .io_ioReq_payload_attr        (rxEngine_io_ioReq_payload_attr[1:0]       ), //o
    .io_ioReq_payload_data_0      (rxEngine_io_ioReq_payload_data_0[31:0]    ), //o
    .io_ioReq_payload_data_1      (rxEngine_io_ioReq_payload_data_1[31:0]    ), //o
    .io_ioReq_payload_data_2      (rxEngine_io_ioReq_payload_data_2[31:0]    ), //o
    .io_ioReq_payload_data_3      (rxEngine_io_ioReq_payload_data_3[31:0]    ), //o
    .io_ioReq_payload_dataValid   (rxEngine_io_ioReq_payload_dataValid[2:0]  ), //o
    .io_memDataOut_valid          (rxEngine_io_memDataOut_valid              ), //o
    .io_memDataOut_ready          (rxEngine_io_memDataOut_ready              ), //i
    .io_memDataOut_payload_data   (rxEngine_io_memDataOut_payload_data[31:0] ), //o
    .io_memDataOut_payload_valid  (rxEngine_io_memDataOut_payload_valid      ), //o
    .io_memDataOut_payload_last   (rxEngine_io_memDataOut_payload_last       ), //o
    .io_memDataOut_payload_byteEn (rxEngine_io_memDataOut_payload_byteEn[3:0]), //o
    .io_memDataStart              (rxEngine_io_memDataStart                  ), //o
    .io_parseErr                  (rxEngine_io_parseErr                      ), //o
    .io_overflow                  (rxEngine_io_overflow                      ), //o
    .clk                          (clk                                       ), //i
    .reset                        (reset                                     )  //i
  );
  IoRequestHandler ioHandler (
    .io_ioReq_valid              (rxEngine_io_ioReq_valid                   ), //i
    .io_ioReq_ready              (ioHandler_io_ioReq_ready                  ), //o
    .io_ioReq_payload_tlpType    (rxEngine_io_ioReq_payload_tlpType[3:0]    ), //i
    .io_ioReq_payload_reqId      (rxEngine_io_ioReq_payload_reqId[15:0]     ), //i
    .io_ioReq_payload_tag        (rxEngine_io_ioReq_payload_tag[7:0]        ), //i
    .io_ioReq_payload_addr       (rxEngine_io_ioReq_payload_addr[63:0]      ), //i
    .io_ioReq_payload_length     (rxEngine_io_ioReq_payload_length[9:0]     ), //i
    .io_ioReq_payload_firstBe    (rxEngine_io_ioReq_payload_firstBe[3:0]    ), //i
    .io_ioReq_payload_lastBe     (rxEngine_io_ioReq_payload_lastBe[3:0]     ), //i
    .io_ioReq_payload_tc         (rxEngine_io_ioReq_payload_tc[2:0]         ), //i
    .io_ioReq_payload_attr       (rxEngine_io_ioReq_payload_attr[1:0]       ), //i
    .io_ioReq_payload_data_0     (rxEngine_io_ioReq_payload_data_0[31:0]    ), //i
    .io_ioReq_payload_data_1     (rxEngine_io_ioReq_payload_data_1[31:0]    ), //i
    .io_ioReq_payload_data_2     (rxEngine_io_ioReq_payload_data_2[31:0]    ), //i
    .io_ioReq_payload_data_3     (rxEngine_io_ioReq_payload_data_3[31:0]    ), //i
    .io_ioReq_payload_dataValid  (rxEngine_io_ioReq_payload_dataValid[2:0]  ), //i
    .io_cplOut_valid             (ioHandler_io_cplOut_valid                 ), //o
    .io_cplOut_ready             (streamArbiter_1_io_inputs_2_ready         ), //i
    .io_cplOut_payload_tlpType   (ioHandler_io_cplOut_payload_tlpType[3:0]  ), //o
    .io_cplOut_payload_reqId     (ioHandler_io_cplOut_payload_reqId[15:0]   ), //o
    .io_cplOut_payload_tag       (ioHandler_io_cplOut_payload_tag[7:0]      ), //o
    .io_cplOut_payload_addr      (ioHandler_io_cplOut_payload_addr[63:0]    ), //o
    .io_cplOut_payload_length    (ioHandler_io_cplOut_payload_length[9:0]   ), //o
    .io_cplOut_payload_firstBe   (ioHandler_io_cplOut_payload_firstBe[3:0]  ), //o
    .io_cplOut_payload_lastBe    (ioHandler_io_cplOut_payload_lastBe[3:0]   ), //o
    .io_cplOut_payload_tc        (ioHandler_io_cplOut_payload_tc[2:0]       ), //o
    .io_cplOut_payload_attr      (ioHandler_io_cplOut_payload_attr[1:0]     ), //o
    .io_cplOut_payload_data_0    (ioHandler_io_cplOut_payload_data_0[31:0]  ), //o
    .io_cplOut_payload_data_1    (ioHandler_io_cplOut_payload_data_1[31:0]  ), //o
    .io_cplOut_payload_data_2    (ioHandler_io_cplOut_payload_data_2[31:0]  ), //o
    .io_cplOut_payload_data_3    (ioHandler_io_cplOut_payload_data_3[31:0]  ), //o
    .io_cplOut_payload_dataValid (ioHandler_io_cplOut_payload_dataValid[2:0]), //o
    .io_regAddr                  (ioHandler_io_regAddr[31:0]                ), //o
    .io_regWrData                (ioHandler_io_regWrData[31:0]              ), //o
    .io_regRdData                (io_ioRegRdData[31:0]                      ), //i
    .io_regWrEn                  (ioHandler_io_regWrEn                      ), //o
    .io_regRdEn                  (ioHandler_io_regRdEn                      ), //o
    .io_regWidth                 (ioHandler_io_regWidth[1:0]                ), //i
    .io_ioErr                    (ioHandler_io_ioErr                        ), //o
    .clk                         (clk                                       ), //i
    .reset                       (reset                                     )  //i
  );
  PcieConfigSpaceCtrl cfgSpace (
    .io_cfgReq_valid              (rxEngine_io_cfgReq_valid                  ), //i
    .io_cfgReq_ready              (cfgSpace_io_cfgReq_ready                  ), //o
    .io_cfgReq_payload_tlpType    (rxEngine_io_cfgReq_payload_tlpType[3:0]   ), //i
    .io_cfgReq_payload_reqId      (rxEngine_io_cfgReq_payload_reqId[15:0]    ), //i
    .io_cfgReq_payload_tag        (rxEngine_io_cfgReq_payload_tag[7:0]       ), //i
    .io_cfgReq_payload_addr       (rxEngine_io_cfgReq_payload_addr[63:0]     ), //i
    .io_cfgReq_payload_length     (rxEngine_io_cfgReq_payload_length[9:0]    ), //i
    .io_cfgReq_payload_firstBe    (rxEngine_io_cfgReq_payload_firstBe[3:0]   ), //i
    .io_cfgReq_payload_lastBe     (rxEngine_io_cfgReq_payload_lastBe[3:0]    ), //i
    .io_cfgReq_payload_tc         (rxEngine_io_cfgReq_payload_tc[2:0]        ), //i
    .io_cfgReq_payload_attr       (rxEngine_io_cfgReq_payload_attr[1:0]      ), //i
    .io_cfgReq_payload_data_0     (rxEngine_io_cfgReq_payload_data_0[31:0]   ), //i
    .io_cfgReq_payload_data_1     (rxEngine_io_cfgReq_payload_data_1[31:0]   ), //i
    .io_cfgReq_payload_data_2     (rxEngine_io_cfgReq_payload_data_2[31:0]   ), //i
    .io_cfgReq_payload_data_3     (rxEngine_io_cfgReq_payload_data_3[31:0]   ), //i
    .io_cfgReq_payload_dataValid  (rxEngine_io_cfgReq_payload_dataValid[2:0] ), //i
    .io_cfgResp_valid             (cfgSpace_io_cfgResp_valid                 ), //o
    .io_cfgResp_ready             (txEngine_io_cplIn_ready                   ), //i
    .io_cfgResp_payload_tlpType   (cfgSpace_io_cfgResp_payload_tlpType[3:0]  ), //o
    .io_cfgResp_payload_reqId     (cfgSpace_io_cfgResp_payload_reqId[15:0]   ), //o
    .io_cfgResp_payload_tag       (cfgSpace_io_cfgResp_payload_tag[7:0]      ), //o
    .io_cfgResp_payload_addr      (cfgSpace_io_cfgResp_payload_addr[63:0]    ), //o
    .io_cfgResp_payload_length    (cfgSpace_io_cfgResp_payload_length[9:0]   ), //o
    .io_cfgResp_payload_firstBe   (cfgSpace_io_cfgResp_payload_firstBe[3:0]  ), //o
    .io_cfgResp_payload_lastBe    (cfgSpace_io_cfgResp_payload_lastBe[3:0]   ), //o
    .io_cfgResp_payload_tc        (cfgSpace_io_cfgResp_payload_tc[2:0]       ), //o
    .io_cfgResp_payload_attr      (cfgSpace_io_cfgResp_payload_attr[1:0]     ), //o
    .io_cfgResp_payload_data_0    (cfgSpace_io_cfgResp_payload_data_0[31:0]  ), //o
    .io_cfgResp_payload_data_1    (cfgSpace_io_cfgResp_payload_data_1[31:0]  ), //o
    .io_cfgResp_payload_data_2    (cfgSpace_io_cfgResp_payload_data_2[31:0]  ), //o
    .io_cfgResp_payload_data_3    (cfgSpace_io_cfgResp_payload_data_3[31:0]  ), //o
    .io_cfgResp_payload_dataValid (cfgSpace_io_cfgResp_payload_dataValid[2:0]), //o
    .io_barHit                    (cfgSpace_io_barHit[5:0]                   ), //o
    .io_barCheckAddr              (cfgSpace_io_barCheckAddr[63:0]            ), //i
    .io_busDevFunc                (myBdf[15:0]                               ), //i
    .io_cfgRegs_vendorId          (cfgSpace_io_cfgRegs_vendorId[15:0]        ), //o
    .io_cfgRegs_deviceId          (cfgSpace_io_cfgRegs_deviceId[15:0]        ), //o
    .io_cfgRegs_command           (cfgSpace_io_cfgRegs_command[15:0]         ), //o
    .io_cfgRegs_status            (cfgSpace_io_cfgRegs_status[15:0]          ), //o
    .io_cfgRegs_revisionId        (cfgSpace_io_cfgRegs_revisionId[7:0]       ), //o
    .io_cfgRegs_classCode         (cfgSpace_io_cfgRegs_classCode[23:0]       ), //o
    .io_cfgRegs_cacheLineSize     (cfgSpace_io_cfgRegs_cacheLineSize[7:0]    ), //o
    .io_cfgRegs_latencyTimer      (cfgSpace_io_cfgRegs_latencyTimer[7:0]     ), //o
    .io_cfgRegs_headerType        (cfgSpace_io_cfgRegs_headerType[7:0]       ), //o
    .io_cfgRegs_bist              (cfgSpace_io_cfgRegs_bist[7:0]             ), //o
    .io_cfgRegs_bar_0             (cfgSpace_io_cfgRegs_bar_0[31:0]           ), //o
    .io_cfgRegs_bar_1             (cfgSpace_io_cfgRegs_bar_1[31:0]           ), //o
    .io_cfgRegs_bar_2             (cfgSpace_io_cfgRegs_bar_2[31:0]           ), //o
    .io_cfgRegs_bar_3             (cfgSpace_io_cfgRegs_bar_3[31:0]           ), //o
    .io_cfgRegs_bar_4             (cfgSpace_io_cfgRegs_bar_4[31:0]           ), //o
    .io_cfgRegs_bar_5             (cfgSpace_io_cfgRegs_bar_5[31:0]           ), //o
    .io_cfgRegs_subVendorId       (cfgSpace_io_cfgRegs_subVendorId[15:0]     ), //o
    .io_cfgRegs_subSystemId       (cfgSpace_io_cfgRegs_subSystemId[15:0]     ), //o
    .io_cfgRegs_capPointer        (cfgSpace_io_cfgRegs_capPointer[7:0]       ), //o
    .io_cfgRegs_intLine           (cfgSpace_io_cfgRegs_intLine[7:0]          ), //o
    .io_cfgRegs_intPin            (cfgSpace_io_cfgRegs_intPin[7:0]           ), //o
    .clk                          (clk                                       ), //i
    .reset                        (reset                                     )  //i
  );
  DmaEngine dma (
    .io_ctrl_aw_valid              (io_userCtrl_aw_valid                    ), //i
    .io_ctrl_aw_ready              (dma_io_ctrl_aw_ready                    ), //o
    .io_ctrl_aw_payload_addr       (io_userCtrl_aw_payload_addr[31:0]       ), //i
    .io_ctrl_aw_payload_id         (io_userCtrl_aw_payload_id[3:0]          ), //i
    .io_ctrl_aw_payload_len        (io_userCtrl_aw_payload_len[7:0]         ), //i
    .io_ctrl_aw_payload_size       (io_userCtrl_aw_payload_size[2:0]        ), //i
    .io_ctrl_aw_payload_burst      (io_userCtrl_aw_payload_burst[1:0]       ), //i
    .io_ctrl_w_valid               (io_userCtrl_w_valid                     ), //i
    .io_ctrl_w_ready               (dma_io_ctrl_w_ready                     ), //o
    .io_ctrl_w_payload_data        (io_userCtrl_w_payload_data[31:0]        ), //i
    .io_ctrl_w_payload_last        (io_userCtrl_w_payload_last              ), //i
    .io_ctrl_b_valid               (dma_io_ctrl_b_valid                     ), //o
    .io_ctrl_b_ready               (io_userCtrl_b_ready                     ), //i
    .io_ctrl_b_payload_id          (dma_io_ctrl_b_payload_id[3:0]           ), //o
    .io_ctrl_b_payload_resp        (dma_io_ctrl_b_payload_resp[1:0]         ), //o
    .io_ctrl_ar_valid              (io_userCtrl_ar_valid                    ), //i
    .io_ctrl_ar_ready              (dma_io_ctrl_ar_ready                    ), //o
    .io_ctrl_ar_payload_addr       (io_userCtrl_ar_payload_addr[31:0]       ), //i
    .io_ctrl_ar_payload_id         (io_userCtrl_ar_payload_id[3:0]          ), //i
    .io_ctrl_ar_payload_len        (io_userCtrl_ar_payload_len[7:0]         ), //i
    .io_ctrl_ar_payload_size       (io_userCtrl_ar_payload_size[2:0]        ), //i
    .io_ctrl_ar_payload_burst      (io_userCtrl_ar_payload_burst[1:0]       ), //i
    .io_ctrl_r_valid               (dma_io_ctrl_r_valid                     ), //o
    .io_ctrl_r_ready               (io_userCtrl_r_ready                     ), //i
    .io_ctrl_r_payload_data        (dma_io_ctrl_r_payload_data[31:0]        ), //o
    .io_ctrl_r_payload_id          (dma_io_ctrl_r_payload_id[3:0]           ), //o
    .io_ctrl_r_payload_resp        (dma_io_ctrl_r_payload_resp[1:0]         ), //o
    .io_ctrl_r_payload_last        (dma_io_ctrl_r_payload_last              ), //o
    .io_memWrOut_valid             (dma_io_memWrOut_valid                   ), //o
    .io_memWrOut_ready             (streamArbiter_1_io_inputs_1_ready       ), //i
    .io_memWrOut_payload_tlpType   (dma_io_memWrOut_payload_tlpType[3:0]    ), //o
    .io_memWrOut_payload_reqId     (dma_io_memWrOut_payload_reqId[15:0]     ), //o
    .io_memWrOut_payload_tag       (dma_io_memWrOut_payload_tag[7:0]        ), //o
    .io_memWrOut_payload_addr      (dma_io_memWrOut_payload_addr[63:0]      ), //o
    .io_memWrOut_payload_length    (dma_io_memWrOut_payload_length[9:0]     ), //o
    .io_memWrOut_payload_firstBe   (dma_io_memWrOut_payload_firstBe[3:0]    ), //o
    .io_memWrOut_payload_lastBe    (dma_io_memWrOut_payload_lastBe[3:0]     ), //o
    .io_memWrOut_payload_tc        (dma_io_memWrOut_payload_tc[2:0]         ), //o
    .io_memWrOut_payload_attr      (dma_io_memWrOut_payload_attr[1:0]       ), //o
    .io_memWrOut_payload_data_0    (dma_io_memWrOut_payload_data_0[31:0]    ), //o
    .io_memWrOut_payload_data_1    (dma_io_memWrOut_payload_data_1[31:0]    ), //o
    .io_memWrOut_payload_data_2    (dma_io_memWrOut_payload_data_2[31:0]    ), //o
    .io_memWrOut_payload_data_3    (dma_io_memWrOut_payload_data_3[31:0]    ), //o
    .io_memWrOut_payload_dataValid (dma_io_memWrOut_payload_dataValid[2:0]  ), //o
    .io_memRdOut_valid             (dma_io_memRdOut_valid                   ), //o
    .io_memRdOut_ready             (txEngine_io_memRdIn_ready               ), //i
    .io_memRdOut_payload_tlpType   (dma_io_memRdOut_payload_tlpType[3:0]    ), //o
    .io_memRdOut_payload_reqId     (dma_io_memRdOut_payload_reqId[15:0]     ), //o
    .io_memRdOut_payload_tag       (dma_io_memRdOut_payload_tag[7:0]        ), //o
    .io_memRdOut_payload_addr      (dma_io_memRdOut_payload_addr[63:0]      ), //o
    .io_memRdOut_payload_length    (dma_io_memRdOut_payload_length[9:0]     ), //o
    .io_memRdOut_payload_firstBe   (dma_io_memRdOut_payload_firstBe[3:0]    ), //o
    .io_memRdOut_payload_lastBe    (dma_io_memRdOut_payload_lastBe[3:0]     ), //o
    .io_memRdOut_payload_tc        (dma_io_memRdOut_payload_tc[2:0]         ), //o
    .io_memRdOut_payload_attr      (dma_io_memRdOut_payload_attr[1:0]       ), //o
    .io_memRdOut_payload_data_0    (dma_io_memRdOut_payload_data_0[31:0]    ), //o
    .io_memRdOut_payload_data_1    (dma_io_memRdOut_payload_data_1[31:0]    ), //o
    .io_memRdOut_payload_data_2    (dma_io_memRdOut_payload_data_2[31:0]    ), //o
    .io_memRdOut_payload_data_3    (dma_io_memRdOut_payload_data_3[31:0]    ), //o
    .io_memRdOut_payload_dataValid (dma_io_memRdOut_payload_dataValid[2:0]  ), //o
    .io_cplIn_valid                (rxEngine_io_cplIn_valid                 ), //i
    .io_cplIn_ready                (dma_io_cplIn_ready                      ), //o
    .io_cplIn_payload_tlpType      (rxEngine_io_cplIn_payload_tlpType[3:0]  ), //i
    .io_cplIn_payload_reqId        (rxEngine_io_cplIn_payload_reqId[15:0]   ), //i
    .io_cplIn_payload_tag          (rxEngine_io_cplIn_payload_tag[7:0]      ), //i
    .io_cplIn_payload_addr         (rxEngine_io_cplIn_payload_addr[63:0]    ), //i
    .io_cplIn_payload_length       (rxEngine_io_cplIn_payload_length[9:0]   ), //i
    .io_cplIn_payload_firstBe      (rxEngine_io_cplIn_payload_firstBe[3:0]  ), //i
    .io_cplIn_payload_lastBe       (rxEngine_io_cplIn_payload_lastBe[3:0]   ), //i
    .io_cplIn_payload_tc           (rxEngine_io_cplIn_payload_tc[2:0]       ), //i
    .io_cplIn_payload_attr         (rxEngine_io_cplIn_payload_attr[1:0]     ), //i
    .io_cplIn_payload_data_0       (rxEngine_io_cplIn_payload_data_0[31:0]  ), //i
    .io_cplIn_payload_data_1       (rxEngine_io_cplIn_payload_data_1[31:0]  ), //i
    .io_cplIn_payload_data_2       (rxEngine_io_cplIn_payload_data_2[31:0]  ), //i
    .io_cplIn_payload_data_3       (rxEngine_io_cplIn_payload_data_3[31:0]  ), //i
    .io_cplIn_payload_dataValid    (rxEngine_io_cplIn_payload_dataValid[2:0]), //i
    .io_localMem_aw_valid          (dma_io_localMem_aw_valid                ), //o
    .io_localMem_aw_ready          (io_localMem_aw_ready                    ), //i
    .io_localMem_aw_payload_addr   (dma_io_localMem_aw_payload_addr[31:0]   ), //o
    .io_localMem_aw_payload_id     (dma_io_localMem_aw_payload_id[3:0]      ), //o
    .io_localMem_aw_payload_region (dma_io_localMem_aw_payload_region[3:0]  ), //o
    .io_localMem_aw_payload_len    (dma_io_localMem_aw_payload_len[7:0]     ), //o
    .io_localMem_aw_payload_size   (dma_io_localMem_aw_payload_size[2:0]    ), //o
    .io_localMem_aw_payload_burst  (dma_io_localMem_aw_payload_burst[1:0]   ), //o
    .io_localMem_aw_payload_lock   (dma_io_localMem_aw_payload_lock         ), //o
    .io_localMem_aw_payload_cache  (dma_io_localMem_aw_payload_cache[3:0]   ), //o
    .io_localMem_aw_payload_qos    (dma_io_localMem_aw_payload_qos[3:0]     ), //o
    .io_localMem_aw_payload_prot   (dma_io_localMem_aw_payload_prot[2:0]    ), //o
    .io_localMem_w_valid           (dma_io_localMem_w_valid                 ), //o
    .io_localMem_w_ready           (io_localMem_w_ready                     ), //i
    .io_localMem_w_payload_data    (dma_io_localMem_w_payload_data[63:0]    ), //o
    .io_localMem_w_payload_strb    (dma_io_localMem_w_payload_strb[7:0]     ), //o
    .io_localMem_w_payload_last    (dma_io_localMem_w_payload_last          ), //o
    .io_localMem_b_valid           (io_localMem_b_valid                     ), //i
    .io_localMem_b_ready           (dma_io_localMem_b_ready                 ), //o
    .io_localMem_b_payload_id      (io_localMem_b_payload_id[3:0]           ), //i
    .io_localMem_b_payload_resp    (io_localMem_b_payload_resp[1:0]         ), //i
    .io_localMem_ar_valid          (dma_io_localMem_ar_valid                ), //o
    .io_localMem_ar_ready          (io_localMem_ar_ready                    ), //i
    .io_localMem_ar_payload_addr   (dma_io_localMem_ar_payload_addr[31:0]   ), //o
    .io_localMem_ar_payload_id     (dma_io_localMem_ar_payload_id[3:0]      ), //o
    .io_localMem_ar_payload_region (dma_io_localMem_ar_payload_region[3:0]  ), //o
    .io_localMem_ar_payload_len    (dma_io_localMem_ar_payload_len[7:0]     ), //o
    .io_localMem_ar_payload_size   (dma_io_localMem_ar_payload_size[2:0]    ), //o
    .io_localMem_ar_payload_burst  (dma_io_localMem_ar_payload_burst[1:0]   ), //o
    .io_localMem_ar_payload_lock   (dma_io_localMem_ar_payload_lock         ), //o
    .io_localMem_ar_payload_cache  (dma_io_localMem_ar_payload_cache[3:0]   ), //o
    .io_localMem_ar_payload_qos    (dma_io_localMem_ar_payload_qos[3:0]     ), //o
    .io_localMem_ar_payload_prot   (dma_io_localMem_ar_payload_prot[2:0]    ), //o
    .io_localMem_r_valid           (io_localMem_r_valid                     ), //i
    .io_localMem_r_ready           (dma_io_localMem_r_ready                 ), //o
    .io_localMem_r_payload_data    (io_localMem_r_payload_data[63:0]        ), //i
    .io_localMem_r_payload_id      (io_localMem_r_payload_id[3:0]           ), //i
    .io_localMem_r_payload_resp    (io_localMem_r_payload_resp[1:0]         ), //i
    .io_localMem_r_payload_last    (io_localMem_r_payload_last              ), //i
    .io_h2dDone                    (dma_io_h2dDone                          ), //o
    .io_d2hDone                    (dma_io_d2hDone                          ), //o
    .io_dmaErr                     (dma_io_dmaErr                           ), //o
    .io_busDevFunc                 (myBdf[15:0]                             ), //i
    .clk                           (clk                                     ), //i
    .reset                         (reset                                   )  //i
  );
  MsixController msix (
    .io_intReq                      (io_intReq[31:0]                         ), //i
    .io_intAck                      (msix_io_intAck[31:0]                    ), //o
    .io_msgTlpOut_valid             (msix_io_msgTlpOut_valid                 ), //o
    .io_msgTlpOut_ready             (streamArbiter_1_io_inputs_0_ready       ), //i
    .io_msgTlpOut_payload_tlpType   (msix_io_msgTlpOut_payload_tlpType[3:0]  ), //o
    .io_msgTlpOut_payload_reqId     (msix_io_msgTlpOut_payload_reqId[15:0]   ), //o
    .io_msgTlpOut_payload_tag       (msix_io_msgTlpOut_payload_tag[7:0]      ), //o
    .io_msgTlpOut_payload_addr      (msix_io_msgTlpOut_payload_addr[63:0]    ), //o
    .io_msgTlpOut_payload_length    (msix_io_msgTlpOut_payload_length[9:0]   ), //o
    .io_msgTlpOut_payload_firstBe   (msix_io_msgTlpOut_payload_firstBe[3:0]  ), //o
    .io_msgTlpOut_payload_lastBe    (msix_io_msgTlpOut_payload_lastBe[3:0]   ), //o
    .io_msgTlpOut_payload_tc        (msix_io_msgTlpOut_payload_tc[2:0]       ), //o
    .io_msgTlpOut_payload_attr      (msix_io_msgTlpOut_payload_attr[1:0]     ), //o
    .io_msgTlpOut_payload_data_0    (msix_io_msgTlpOut_payload_data_0[31:0]  ), //o
    .io_msgTlpOut_payload_data_1    (msix_io_msgTlpOut_payload_data_1[31:0]  ), //o
    .io_msgTlpOut_payload_data_2    (msix_io_msgTlpOut_payload_data_2[31:0]  ), //o
    .io_msgTlpOut_payload_data_3    (msix_io_msgTlpOut_payload_data_3[31:0]  ), //o
    .io_msgTlpOut_payload_dataValid (msix_io_msgTlpOut_payload_dataValid[2:0]), //o
    .io_busDevFunc                  (myBdf[15:0]                             ), //i
    .io_tableAddr                   (msix_io_tableAddr[11:0]                 ), //i
    .io_tableRdata                  (msix_io_tableRdata[31:0]                ), //o
    .io_tableWdata                  (rxEngine_io_memReq_payload_data_0[31:0] ), //i
    .io_tableWen                    (msix_io_tableWen                        ), //i
    .io_tableBe                     (rxEngine_io_memReq_payload_firstBe[3:0] ), //i
    .io_msixEnable                  (msix_io_msixEnable                      ), //i
    .io_funcMask                    (msix_io_funcMask                        ), //i
    .clk                            (clk                                     ), //i
    .reset                          (reset                                   )  //i
  );
  StreamArbiter streamArbiter_1 (
    .io_inputs_0_valid             (msix_io_msgTlpOut_valid                         ), //i
    .io_inputs_0_ready             (streamArbiter_1_io_inputs_0_ready               ), //o
    .io_inputs_0_payload_tlpType   (msix_io_msgTlpOut_payload_tlpType[3:0]          ), //i
    .io_inputs_0_payload_reqId     (msix_io_msgTlpOut_payload_reqId[15:0]           ), //i
    .io_inputs_0_payload_tag       (msix_io_msgTlpOut_payload_tag[7:0]              ), //i
    .io_inputs_0_payload_addr      (msix_io_msgTlpOut_payload_addr[63:0]            ), //i
    .io_inputs_0_payload_length    (msix_io_msgTlpOut_payload_length[9:0]           ), //i
    .io_inputs_0_payload_firstBe   (msix_io_msgTlpOut_payload_firstBe[3:0]          ), //i
    .io_inputs_0_payload_lastBe    (msix_io_msgTlpOut_payload_lastBe[3:0]           ), //i
    .io_inputs_0_payload_tc        (msix_io_msgTlpOut_payload_tc[2:0]               ), //i
    .io_inputs_0_payload_attr      (msix_io_msgTlpOut_payload_attr[1:0]             ), //i
    .io_inputs_0_payload_data_0    (msix_io_msgTlpOut_payload_data_0[31:0]          ), //i
    .io_inputs_0_payload_data_1    (msix_io_msgTlpOut_payload_data_1[31:0]          ), //i
    .io_inputs_0_payload_data_2    (msix_io_msgTlpOut_payload_data_2[31:0]          ), //i
    .io_inputs_0_payload_data_3    (msix_io_msgTlpOut_payload_data_3[31:0]          ), //i
    .io_inputs_0_payload_dataValid (msix_io_msgTlpOut_payload_dataValid[2:0]        ), //i
    .io_inputs_1_valid             (dma_io_memWrOut_valid                           ), //i
    .io_inputs_1_ready             (streamArbiter_1_io_inputs_1_ready               ), //o
    .io_inputs_1_payload_tlpType   (dma_io_memWrOut_payload_tlpType[3:0]            ), //i
    .io_inputs_1_payload_reqId     (dma_io_memWrOut_payload_reqId[15:0]             ), //i
    .io_inputs_1_payload_tag       (dma_io_memWrOut_payload_tag[7:0]                ), //i
    .io_inputs_1_payload_addr      (dma_io_memWrOut_payload_addr[63:0]              ), //i
    .io_inputs_1_payload_length    (dma_io_memWrOut_payload_length[9:0]             ), //i
    .io_inputs_1_payload_firstBe   (dma_io_memWrOut_payload_firstBe[3:0]            ), //i
    .io_inputs_1_payload_lastBe    (dma_io_memWrOut_payload_lastBe[3:0]             ), //i
    .io_inputs_1_payload_tc        (dma_io_memWrOut_payload_tc[2:0]                 ), //i
    .io_inputs_1_payload_attr      (dma_io_memWrOut_payload_attr[1:0]               ), //i
    .io_inputs_1_payload_data_0    (dma_io_memWrOut_payload_data_0[31:0]            ), //i
    .io_inputs_1_payload_data_1    (dma_io_memWrOut_payload_data_1[31:0]            ), //i
    .io_inputs_1_payload_data_2    (dma_io_memWrOut_payload_data_2[31:0]            ), //i
    .io_inputs_1_payload_data_3    (dma_io_memWrOut_payload_data_3[31:0]            ), //i
    .io_inputs_1_payload_dataValid (dma_io_memWrOut_payload_dataValid[2:0]          ), //i
    .io_inputs_2_valid             (ioHandler_io_cplOut_valid                       ), //i
    .io_inputs_2_ready             (streamArbiter_1_io_inputs_2_ready               ), //o
    .io_inputs_2_payload_tlpType   (ioHandler_io_cplOut_payload_tlpType[3:0]        ), //i
    .io_inputs_2_payload_reqId     (ioHandler_io_cplOut_payload_reqId[15:0]         ), //i
    .io_inputs_2_payload_tag       (ioHandler_io_cplOut_payload_tag[7:0]            ), //i
    .io_inputs_2_payload_addr      (ioHandler_io_cplOut_payload_addr[63:0]          ), //i
    .io_inputs_2_payload_length    (ioHandler_io_cplOut_payload_length[9:0]         ), //i
    .io_inputs_2_payload_firstBe   (ioHandler_io_cplOut_payload_firstBe[3:0]        ), //i
    .io_inputs_2_payload_lastBe    (ioHandler_io_cplOut_payload_lastBe[3:0]         ), //i
    .io_inputs_2_payload_tc        (ioHandler_io_cplOut_payload_tc[2:0]             ), //i
    .io_inputs_2_payload_attr      (ioHandler_io_cplOut_payload_attr[1:0]           ), //i
    .io_inputs_2_payload_data_0    (ioHandler_io_cplOut_payload_data_0[31:0]        ), //i
    .io_inputs_2_payload_data_1    (ioHandler_io_cplOut_payload_data_1[31:0]        ), //i
    .io_inputs_2_payload_data_2    (ioHandler_io_cplOut_payload_data_2[31:0]        ), //i
    .io_inputs_2_payload_data_3    (ioHandler_io_cplOut_payload_data_3[31:0]        ), //i
    .io_inputs_2_payload_dataValid (ioHandler_io_cplOut_payload_dataValid[2:0]      ), //i
    .io_output_valid               (streamArbiter_1_io_output_valid                 ), //o
    .io_output_ready               (memWrArb_ready                                  ), //i
    .io_output_payload_tlpType     (streamArbiter_1_io_output_payload_tlpType[3:0]  ), //o
    .io_output_payload_reqId       (streamArbiter_1_io_output_payload_reqId[15:0]   ), //o
    .io_output_payload_tag         (streamArbiter_1_io_output_payload_tag[7:0]      ), //o
    .io_output_payload_addr        (streamArbiter_1_io_output_payload_addr[63:0]    ), //o
    .io_output_payload_length      (streamArbiter_1_io_output_payload_length[9:0]   ), //o
    .io_output_payload_firstBe     (streamArbiter_1_io_output_payload_firstBe[3:0]  ), //o
    .io_output_payload_lastBe      (streamArbiter_1_io_output_payload_lastBe[3:0]   ), //o
    .io_output_payload_tc          (streamArbiter_1_io_output_payload_tc[2:0]       ), //o
    .io_output_payload_attr        (streamArbiter_1_io_output_payload_attr[1:0]     ), //o
    .io_output_payload_data_0      (streamArbiter_1_io_output_payload_data_0[31:0]  ), //o
    .io_output_payload_data_1      (streamArbiter_1_io_output_payload_data_1[31:0]  ), //o
    .io_output_payload_data_2      (streamArbiter_1_io_output_payload_data_2[31:0]  ), //o
    .io_output_payload_data_3      (streamArbiter_1_io_output_payload_data_3[31:0]  ), //o
    .io_output_payload_dataValid   (streamArbiter_1_io_output_payload_dataValid[2:0]), //o
    .io_chosen                     (streamArbiter_1_io_chosen[1:0]                  ), //o
    .io_chosenOH                   (streamArbiter_1_io_chosenOH[2:0]                ), //o
    .clk                           (clk                                             ), //i
    .reset                         (reset                                           )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_ltssState)
      LtssState_DETECT_QUIET : io_ltssState_string = "DETECT_QUIET           ";
      LtssState_DETECT_ACTIVE : io_ltssState_string = "DETECT_ACTIVE          ";
      LtssState_POLLING_ACTIVE : io_ltssState_string = "POLLING_ACTIVE         ";
      LtssState_POLLING_COMPLIANCE : io_ltssState_string = "POLLING_COMPLIANCE     ";
      LtssState_POLLING_CONFIG : io_ltssState_string = "POLLING_CONFIG         ";
      LtssState_CONFIG_LINKWIDTH_START : io_ltssState_string = "CONFIG_LINKWIDTH_START ";
      LtssState_CONFIG_LINKWIDTH_ACCEPT : io_ltssState_string = "CONFIG_LINKWIDTH_ACCEPT";
      LtssState_CONFIG_LANENUM_WAIT : io_ltssState_string = "CONFIG_LANENUM_WAIT    ";
      LtssState_CONFIG_LANENUM_ACCEPT : io_ltssState_string = "CONFIG_LANENUM_ACCEPT  ";
      LtssState_CONFIG_COMPLETE : io_ltssState_string = "CONFIG_COMPLETE        ";
      LtssState_CONFIG_IDLE : io_ltssState_string = "CONFIG_IDLE            ";
      LtssState_L0 : io_ltssState_string = "L0                     ";
      LtssState_RECOVERY_RCVRLOCK : io_ltssState_string = "RECOVERY_RCVRLOCK      ";
      LtssState_RECOVERY_RCVRCFG : io_ltssState_string = "RECOVERY_RCVRCFG       ";
      LtssState_RECOVERY_IDLE : io_ltssState_string = "RECOVERY_IDLE          ";
      LtssState_L0S : io_ltssState_string = "L0S                    ";
      LtssState_L1_ENTRY : io_ltssState_string = "L1_ENTRY               ";
      LtssState_L1_IDLE : io_ltssState_string = "L1_IDLE                ";
      LtssState_L1_EXIT : io_ltssState_string = "L1_EXIT                ";
      LtssState_L2_IDLE : io_ltssState_string = "L2_IDLE                ";
      LtssState_L2_TRANSMIT_WAKE : io_ltssState_string = "L2_TRANSMIT_WAKE       ";
      LtssState_L2_DETECT_WAKE : io_ltssState_string = "L2_DETECT_WAKE         ";
      LtssState_DISABLED : io_ltssState_string = "DISABLED               ";
      LtssState_HOT_RESET : io_ltssState_string = "HOT_RESET              ";
      LtssState_LOOPBACK_ENTRY : io_ltssState_string = "LOOPBACK_ENTRY         ";
      LtssState_LOOPBACK_ACTIVE : io_ltssState_string = "LOOPBACK_ACTIVE        ";
      LtssState_LOOPBACK_EXIT : io_ltssState_string = "LOOPBACK_EXIT          ";
      default : io_ltssState_string = "???????????????????????";
    endcase
  end
  always @(*) begin
    case(memWrArb_payload_tlpType)
      TlpType_MEM_RD : memWrArb_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : memWrArb_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : memWrArb_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : memWrArb_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : memWrArb_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : memWrArb_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : memWrArb_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : memWrArb_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : memWrArb_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : memWrArb_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : memWrArb_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : memWrArb_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : memWrArb_payload_tlpType_string = "INVALID";
      default : memWrArb_payload_tlpType_string = "???????";
    endcase
  end
  `endif

  assign when_PcieController_l99 = (phy_io_busNum != 8'h00);
  assign io_txSymbols = phy_io_txSymbols;
  assign io_phyTxEn = phy_io_phyTxEn;
  assign io_phyRxPolarity = phy_io_phyRxPolarity;
  assign io_linkUp = phy_io_linkUp;
  assign io_linkSpeed = 2'b01;
  assign io_ltssState = phy_io_ltssState;
  assign io_symbolAlign = phy_io_aligned;
  assign io_codeErr = phy_io_codeErr;
  assign io_dispErr = phy_io_disparityErr;
  assign dllpHandler_1_io_dllpIn_valid = 1'b0;
  assign dllpHandler_1_io_dllpIn_payload = 32'h00000000;
  assign dllpHandler_1_io_dllpValid = 1'b0;
  assign fcMgr_io_init = 1'b0;
  assign fcMgr_io_phConsumed = 8'h00;
  assign fcMgr_io_pdConsumed = 12'h000;
  assign fcMgr_io_nphConsumed = 8'h00;
  assign fcMgr_io_npdConsumed = 12'h000;
  assign fcMgr_io_cplhConsumed = 8'h00;
  assign fcMgr_io_cpldConsumed = 12'h000;
  assign cfgSpace_io_barCheckAddr = (rxEngine_io_memReq_valid ? rxEngine_io_memReq_payload_addr : 64'h0000000000000000);
  assign isBar1Req = (rxEngine_io_memReq_valid && cfgSpace_io_barHit[1]);
  assign msix_io_tableAddr = rxEngine_io_memReq_payload_addr[11 : 0];
  assign msix_io_tableWen = (isBar1Req && (rxEngine_io_memReq_payload_tlpType == TlpType_MEM_WR));
  assign msix_io_msixEnable = cfgSpace_io_cfgRegs_command[2];
  assign msix_io_funcMask = 1'b0;
  assign io_intAck = msix_io_intAck;
  assign memWrArb_valid = streamArbiter_1_io_output_valid;
  assign memWrArb_payload_tlpType = streamArbiter_1_io_output_payload_tlpType;
  assign memWrArb_payload_reqId = streamArbiter_1_io_output_payload_reqId;
  assign memWrArb_payload_tag = streamArbiter_1_io_output_payload_tag;
  assign memWrArb_payload_addr = streamArbiter_1_io_output_payload_addr;
  assign memWrArb_payload_length = streamArbiter_1_io_output_payload_length;
  assign memWrArb_payload_firstBe = streamArbiter_1_io_output_payload_firstBe;
  assign memWrArb_payload_lastBe = streamArbiter_1_io_output_payload_lastBe;
  assign memWrArb_payload_tc = streamArbiter_1_io_output_payload_tc;
  assign memWrArb_payload_attr = streamArbiter_1_io_output_payload_attr;
  assign memWrArb_payload_data_0 = streamArbiter_1_io_output_payload_data_0;
  assign memWrArb_payload_data_1 = streamArbiter_1_io_output_payload_data_1;
  assign memWrArb_payload_data_2 = streamArbiter_1_io_output_payload_data_2;
  assign memWrArb_payload_data_3 = streamArbiter_1_io_output_payload_data_3;
  assign memWrArb_payload_dataValid = streamArbiter_1_io_output_payload_dataValid;
  assign memWrArb_ready = txEngine_io_memWrIn_ready;
  assign rxEngine_io_memReq_ready = 1'b1;
  assign io_ioRegAddr = ioHandler_io_regAddr;
  assign io_ioRegWrData = ioHandler_io_regWrData;
  assign io_ioRegWrEn = ioHandler_io_regWrEn;
  assign io_ioRegRdEn = ioHandler_io_regRdEn;
  assign io_userCtrl_ar_ready = dma_io_ctrl_ar_ready;
  assign io_userCtrl_aw_ready = dma_io_ctrl_aw_ready;
  assign io_userCtrl_w_ready = dma_io_ctrl_w_ready;
  assign io_userCtrl_r_valid = dma_io_ctrl_r_valid;
  assign io_userCtrl_r_payload_data = dma_io_ctrl_r_payload_data;
  assign io_userCtrl_r_payload_last = dma_io_ctrl_r_payload_last;
  assign io_userCtrl_r_payload_id = dma_io_ctrl_r_payload_id;
  assign io_userCtrl_r_payload_resp = dma_io_ctrl_r_payload_resp;
  assign io_userCtrl_b_valid = dma_io_ctrl_b_valid;
  assign io_userCtrl_b_payload_id = dma_io_ctrl_b_payload_id;
  assign io_userCtrl_b_payload_resp = dma_io_ctrl_b_payload_resp;
  assign io_localMem_ar_valid = dma_io_localMem_ar_valid;
  assign io_localMem_ar_payload_addr = dma_io_localMem_ar_payload_addr;
  assign io_localMem_ar_payload_id = dma_io_localMem_ar_payload_id;
  assign io_localMem_ar_payload_region = dma_io_localMem_ar_payload_region;
  assign io_localMem_ar_payload_len = dma_io_localMem_ar_payload_len;
  assign io_localMem_ar_payload_size = dma_io_localMem_ar_payload_size;
  assign io_localMem_ar_payload_burst = dma_io_localMem_ar_payload_burst;
  assign io_localMem_ar_payload_lock = dma_io_localMem_ar_payload_lock;
  assign io_localMem_ar_payload_cache = dma_io_localMem_ar_payload_cache;
  assign io_localMem_ar_payload_qos = dma_io_localMem_ar_payload_qos;
  assign io_localMem_ar_payload_prot = dma_io_localMem_ar_payload_prot;
  assign io_localMem_r_ready = dma_io_localMem_r_ready;
  assign io_localMem_aw_valid = dma_io_localMem_aw_valid;
  assign io_localMem_aw_payload_addr = dma_io_localMem_aw_payload_addr;
  assign io_localMem_aw_payload_id = dma_io_localMem_aw_payload_id;
  assign io_localMem_aw_payload_region = dma_io_localMem_aw_payload_region;
  assign io_localMem_aw_payload_len = dma_io_localMem_aw_payload_len;
  assign io_localMem_aw_payload_size = dma_io_localMem_aw_payload_size;
  assign io_localMem_aw_payload_burst = dma_io_localMem_aw_payload_burst;
  assign io_localMem_aw_payload_lock = dma_io_localMem_aw_payload_lock;
  assign io_localMem_aw_payload_cache = dma_io_localMem_aw_payload_cache;
  assign io_localMem_aw_payload_qos = dma_io_localMem_aw_payload_qos;
  assign io_localMem_aw_payload_prot = dma_io_localMem_aw_payload_prot;
  assign io_localMem_w_valid = dma_io_localMem_w_valid;
  assign io_localMem_w_payload_data = dma_io_localMem_w_payload_data;
  assign io_localMem_w_payload_strb = dma_io_localMem_w_payload_strb;
  assign io_localMem_w_payload_last = dma_io_localMem_w_payload_last;
  assign io_localMem_b_ready = dma_io_localMem_b_ready;
  assign io_h2dDone = dma_io_h2dDone;
  assign io_d2hDone = dma_io_d2hDone;
  assign io_dmaErr = dma_io_dmaErr;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      myBdf <= 16'h0100;
    end else begin
      if(when_PcieController_l99) begin
        myBdf[15 : 8] <= phy_io_busNum;
      end
    end
  end


endmodule

module StreamArbiter (
  input  wire          io_inputs_0_valid,
  output wire          io_inputs_0_ready,
  input  wire [3:0]    io_inputs_0_payload_tlpType,
  input  wire [15:0]   io_inputs_0_payload_reqId,
  input  wire [7:0]    io_inputs_0_payload_tag,
  input  wire [63:0]   io_inputs_0_payload_addr,
  input  wire [9:0]    io_inputs_0_payload_length,
  input  wire [3:0]    io_inputs_0_payload_firstBe,
  input  wire [3:0]    io_inputs_0_payload_lastBe,
  input  wire [2:0]    io_inputs_0_payload_tc,
  input  wire [1:0]    io_inputs_0_payload_attr,
  input  wire [31:0]   io_inputs_0_payload_data_0,
  input  wire [31:0]   io_inputs_0_payload_data_1,
  input  wire [31:0]   io_inputs_0_payload_data_2,
  input  wire [31:0]   io_inputs_0_payload_data_3,
  input  wire [2:0]    io_inputs_0_payload_dataValid,
  input  wire          io_inputs_1_valid,
  output wire          io_inputs_1_ready,
  input  wire [3:0]    io_inputs_1_payload_tlpType,
  input  wire [15:0]   io_inputs_1_payload_reqId,
  input  wire [7:0]    io_inputs_1_payload_tag,
  input  wire [63:0]   io_inputs_1_payload_addr,
  input  wire [9:0]    io_inputs_1_payload_length,
  input  wire [3:0]    io_inputs_1_payload_firstBe,
  input  wire [3:0]    io_inputs_1_payload_lastBe,
  input  wire [2:0]    io_inputs_1_payload_tc,
  input  wire [1:0]    io_inputs_1_payload_attr,
  input  wire [31:0]   io_inputs_1_payload_data_0,
  input  wire [31:0]   io_inputs_1_payload_data_1,
  input  wire [31:0]   io_inputs_1_payload_data_2,
  input  wire [31:0]   io_inputs_1_payload_data_3,
  input  wire [2:0]    io_inputs_1_payload_dataValid,
  input  wire          io_inputs_2_valid,
  output wire          io_inputs_2_ready,
  input  wire [3:0]    io_inputs_2_payload_tlpType,
  input  wire [15:0]   io_inputs_2_payload_reqId,
  input  wire [7:0]    io_inputs_2_payload_tag,
  input  wire [63:0]   io_inputs_2_payload_addr,
  input  wire [9:0]    io_inputs_2_payload_length,
  input  wire [3:0]    io_inputs_2_payload_firstBe,
  input  wire [3:0]    io_inputs_2_payload_lastBe,
  input  wire [2:0]    io_inputs_2_payload_tc,
  input  wire [1:0]    io_inputs_2_payload_attr,
  input  wire [31:0]   io_inputs_2_payload_data_0,
  input  wire [31:0]   io_inputs_2_payload_data_1,
  input  wire [31:0]   io_inputs_2_payload_data_2,
  input  wire [31:0]   io_inputs_2_payload_data_3,
  input  wire [2:0]    io_inputs_2_payload_dataValid,
  output wire          io_output_valid,
  input  wire          io_output_ready,
  output wire [3:0]    io_output_payload_tlpType,
  output wire [15:0]   io_output_payload_reqId,
  output wire [7:0]    io_output_payload_tag,
  output wire [63:0]   io_output_payload_addr,
  output wire [9:0]    io_output_payload_length,
  output wire [3:0]    io_output_payload_firstBe,
  output wire [3:0]    io_output_payload_lastBe,
  output wire [2:0]    io_output_payload_tc,
  output wire [1:0]    io_output_payload_attr,
  output wire [31:0]   io_output_payload_data_0,
  output wire [31:0]   io_output_payload_data_1,
  output wire [31:0]   io_output_payload_data_2,
  output wire [31:0]   io_output_payload_data_3,
  output wire [2:0]    io_output_payload_dataValid,
  output wire [1:0]    io_chosen,
  output wire [2:0]    io_chosenOH,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  wire       [5:0]    _zz__zz_maskProposal_0_2;
  wire       [5:0]    _zz__zz_maskProposal_0_2_1;
  wire       [2:0]    _zz__zz_maskProposal_0_2_2;
  reg        [3:0]    _zz__zz_io_output_payload_tlpType;
  reg        [15:0]   _zz_io_output_payload_reqId_1;
  reg        [7:0]    _zz_io_output_payload_tag;
  reg        [63:0]   _zz_io_output_payload_addr;
  reg        [9:0]    _zz_io_output_payload_length;
  reg        [3:0]    _zz_io_output_payload_firstBe;
  reg        [3:0]    _zz_io_output_payload_lastBe;
  reg        [2:0]    _zz_io_output_payload_tc;
  reg        [1:0]    _zz_io_output_payload_attr;
  reg        [31:0]   _zz_io_output_payload_data_0;
  reg        [31:0]   _zz_io_output_payload_data_1;
  reg        [31:0]   _zz_io_output_payload_data_2;
  reg        [31:0]   _zz_io_output_payload_data_3;
  reg        [2:0]    _zz_io_output_payload_dataValid;
  reg                 locked;
  wire                maskProposal_0;
  wire                maskProposal_1;
  wire                maskProposal_2;
  reg                 maskLocked_0;
  reg                 maskLocked_1;
  reg                 maskLocked_2;
  wire                maskRouted_0;
  wire                maskRouted_1;
  wire                maskRouted_2;
  wire       [2:0]    _zz_maskProposal_0;
  wire       [5:0]    _zz_maskProposal_0_1;
  wire       [5:0]    _zz_maskProposal_0_2;
  wire       [2:0]    _zz_maskProposal_0_3;
  wire                io_output_fire;
  wire       [1:0]    _zz_io_output_payload_reqId;
  wire       [3:0]    _zz_io_output_payload_tlpType;
  wire                _zz_io_chosen;
  wire                _zz_io_chosen_1;
  `ifndef SYNTHESIS
  reg [55:0] io_inputs_0_payload_tlpType_string;
  reg [55:0] io_inputs_1_payload_tlpType_string;
  reg [55:0] io_inputs_2_payload_tlpType_string;
  reg [55:0] io_output_payload_tlpType_string;
  reg [55:0] _zz_io_output_payload_tlpType_string;
  `endif


  assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
  assign _zz__zz_maskProposal_0_2_2 = {maskLocked_1,{maskLocked_0,maskLocked_2}};
  assign _zz__zz_maskProposal_0_2_1 = {3'd0, _zz__zz_maskProposal_0_2_2};
  always @(*) begin
    case(_zz_io_output_payload_reqId)
      2'b00 : begin
        _zz__zz_io_output_payload_tlpType = io_inputs_0_payload_tlpType;
        _zz_io_output_payload_reqId_1 = io_inputs_0_payload_reqId;
        _zz_io_output_payload_tag = io_inputs_0_payload_tag;
        _zz_io_output_payload_addr = io_inputs_0_payload_addr;
        _zz_io_output_payload_length = io_inputs_0_payload_length;
        _zz_io_output_payload_firstBe = io_inputs_0_payload_firstBe;
        _zz_io_output_payload_lastBe = io_inputs_0_payload_lastBe;
        _zz_io_output_payload_tc = io_inputs_0_payload_tc;
        _zz_io_output_payload_attr = io_inputs_0_payload_attr;
        _zz_io_output_payload_data_0 = io_inputs_0_payload_data_0;
        _zz_io_output_payload_data_1 = io_inputs_0_payload_data_1;
        _zz_io_output_payload_data_2 = io_inputs_0_payload_data_2;
        _zz_io_output_payload_data_3 = io_inputs_0_payload_data_3;
        _zz_io_output_payload_dataValid = io_inputs_0_payload_dataValid;
      end
      2'b01 : begin
        _zz__zz_io_output_payload_tlpType = io_inputs_1_payload_tlpType;
        _zz_io_output_payload_reqId_1 = io_inputs_1_payload_reqId;
        _zz_io_output_payload_tag = io_inputs_1_payload_tag;
        _zz_io_output_payload_addr = io_inputs_1_payload_addr;
        _zz_io_output_payload_length = io_inputs_1_payload_length;
        _zz_io_output_payload_firstBe = io_inputs_1_payload_firstBe;
        _zz_io_output_payload_lastBe = io_inputs_1_payload_lastBe;
        _zz_io_output_payload_tc = io_inputs_1_payload_tc;
        _zz_io_output_payload_attr = io_inputs_1_payload_attr;
        _zz_io_output_payload_data_0 = io_inputs_1_payload_data_0;
        _zz_io_output_payload_data_1 = io_inputs_1_payload_data_1;
        _zz_io_output_payload_data_2 = io_inputs_1_payload_data_2;
        _zz_io_output_payload_data_3 = io_inputs_1_payload_data_3;
        _zz_io_output_payload_dataValid = io_inputs_1_payload_dataValid;
      end
      default : begin
        _zz__zz_io_output_payload_tlpType = io_inputs_2_payload_tlpType;
        _zz_io_output_payload_reqId_1 = io_inputs_2_payload_reqId;
        _zz_io_output_payload_tag = io_inputs_2_payload_tag;
        _zz_io_output_payload_addr = io_inputs_2_payload_addr;
        _zz_io_output_payload_length = io_inputs_2_payload_length;
        _zz_io_output_payload_firstBe = io_inputs_2_payload_firstBe;
        _zz_io_output_payload_lastBe = io_inputs_2_payload_lastBe;
        _zz_io_output_payload_tc = io_inputs_2_payload_tc;
        _zz_io_output_payload_attr = io_inputs_2_payload_attr;
        _zz_io_output_payload_data_0 = io_inputs_2_payload_data_0;
        _zz_io_output_payload_data_1 = io_inputs_2_payload_data_1;
        _zz_io_output_payload_data_2 = io_inputs_2_payload_data_2;
        _zz_io_output_payload_data_3 = io_inputs_2_payload_data_3;
        _zz_io_output_payload_dataValid = io_inputs_2_payload_dataValid;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_inputs_0_payload_tlpType)
      TlpType_MEM_RD : io_inputs_0_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_inputs_0_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_inputs_0_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_inputs_0_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_inputs_0_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_inputs_0_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_inputs_0_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_inputs_0_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_inputs_0_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_inputs_0_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_inputs_0_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_inputs_0_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_inputs_0_payload_tlpType_string = "INVALID";
      default : io_inputs_0_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_inputs_1_payload_tlpType)
      TlpType_MEM_RD : io_inputs_1_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_inputs_1_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_inputs_1_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_inputs_1_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_inputs_1_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_inputs_1_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_inputs_1_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_inputs_1_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_inputs_1_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_inputs_1_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_inputs_1_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_inputs_1_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_inputs_1_payload_tlpType_string = "INVALID";
      default : io_inputs_1_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_inputs_2_payload_tlpType)
      TlpType_MEM_RD : io_inputs_2_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_inputs_2_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_inputs_2_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_inputs_2_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_inputs_2_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_inputs_2_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_inputs_2_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_inputs_2_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_inputs_2_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_inputs_2_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_inputs_2_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_inputs_2_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_inputs_2_payload_tlpType_string = "INVALID";
      default : io_inputs_2_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_output_payload_tlpType)
      TlpType_MEM_RD : io_output_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_output_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_output_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_output_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_output_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_output_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_output_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_output_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_output_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_output_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_output_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_output_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_output_payload_tlpType_string = "INVALID";
      default : io_output_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_io_output_payload_tlpType)
      TlpType_MEM_RD : _zz_io_output_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_io_output_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : _zz_io_output_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : _zz_io_output_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_io_output_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_io_output_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_io_output_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_io_output_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : _zz_io_output_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : _zz_io_output_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : _zz_io_output_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : _zz_io_output_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : _zz_io_output_payload_tlpType_string = "INVALID";
      default : _zz_io_output_payload_tlpType_string = "???????";
    endcase
  end
  `endif

  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign maskRouted_2 = (locked ? maskLocked_2 : maskProposal_2);
  assign _zz_maskProposal_0 = {io_inputs_2_valid,{io_inputs_1_valid,io_inputs_0_valid}};
  assign _zz_maskProposal_0_1 = {_zz_maskProposal_0,_zz_maskProposal_0};
  assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~ _zz__zz_maskProposal_0_2));
  assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[5 : 3] | _zz_maskProposal_0_2[2 : 0]);
  assign maskProposal_0 = _zz_maskProposal_0_3[0];
  assign maskProposal_1 = _zz_maskProposal_0_3[1];
  assign maskProposal_2 = _zz_maskProposal_0_3[2];
  assign io_output_fire = (io_output_valid && io_output_ready);
  assign io_output_valid = (((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1)) || (io_inputs_2_valid && maskRouted_2));
  assign _zz_io_output_payload_reqId = {maskRouted_2,maskRouted_1};
  assign _zz_io_output_payload_tlpType = _zz__zz_io_output_payload_tlpType;
  assign io_output_payload_tlpType = _zz_io_output_payload_tlpType;
  assign io_output_payload_reqId = _zz_io_output_payload_reqId_1;
  assign io_output_payload_tag = _zz_io_output_payload_tag;
  assign io_output_payload_addr = _zz_io_output_payload_addr;
  assign io_output_payload_length = _zz_io_output_payload_length;
  assign io_output_payload_firstBe = _zz_io_output_payload_firstBe;
  assign io_output_payload_lastBe = _zz_io_output_payload_lastBe;
  assign io_output_payload_tc = _zz_io_output_payload_tc;
  assign io_output_payload_attr = _zz_io_output_payload_attr;
  assign io_output_payload_data_0 = _zz_io_output_payload_data_0;
  assign io_output_payload_data_1 = _zz_io_output_payload_data_1;
  assign io_output_payload_data_2 = _zz_io_output_payload_data_2;
  assign io_output_payload_data_3 = _zz_io_output_payload_data_3;
  assign io_output_payload_dataValid = _zz_io_output_payload_dataValid;
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_inputs_2_ready = (maskRouted_2 && io_output_ready);
  assign io_chosenOH = {maskRouted_2,{maskRouted_1,maskRouted_0}};
  assign _zz_io_chosen = io_chosenOH[1];
  assign _zz_io_chosen_1 = io_chosenOH[2];
  assign io_chosen = {_zz_io_chosen_1,_zz_io_chosen};
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      locked <= 1'b0;
      maskLocked_0 <= 1'b0;
      maskLocked_1 <= 1'b0;
      maskLocked_2 <= 1'b1;
    end else begin
      if(io_output_valid) begin
        maskLocked_0 <= maskRouted_0;
        maskLocked_1 <= maskRouted_1;
        maskLocked_2 <= maskRouted_2;
      end
      if(io_output_valid) begin
        locked <= 1'b1;
      end
      if(io_output_fire) begin
        locked <= 1'b0;
      end
    end
  end


endmodule

module MsixController (
  input  wire [31:0]   io_intReq,
  output reg  [31:0]   io_intAck,
  output reg           io_msgTlpOut_valid,
  input  wire          io_msgTlpOut_ready,
  output reg  [3:0]    io_msgTlpOut_payload_tlpType,
  output reg  [15:0]   io_msgTlpOut_payload_reqId,
  output reg  [7:0]    io_msgTlpOut_payload_tag,
  output reg  [63:0]   io_msgTlpOut_payload_addr,
  output reg  [9:0]    io_msgTlpOut_payload_length,
  output reg  [3:0]    io_msgTlpOut_payload_firstBe,
  output reg  [3:0]    io_msgTlpOut_payload_lastBe,
  output reg  [2:0]    io_msgTlpOut_payload_tc,
  output reg  [1:0]    io_msgTlpOut_payload_attr,
  output reg  [31:0]   io_msgTlpOut_payload_data_0,
  output reg  [31:0]   io_msgTlpOut_payload_data_1,
  output reg  [31:0]   io_msgTlpOut_payload_data_2,
  output reg  [31:0]   io_msgTlpOut_payload_data_3,
  output reg  [2:0]    io_msgTlpOut_payload_dataValid,
  input  wire [15:0]   io_busDevFunc,
  input  wire [11:0]   io_tableAddr,
  output reg  [31:0]   io_tableRdata,
  input  wire [31:0]   io_tableWdata,
  input  wire          io_tableWen,
  input  wire [3:0]    io_tableBe,
  input  wire          io_msixEnable,
  input  wire          io_funcMask,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;
  localparam IrqState_SCAN = 2'd0;
  localparam IrqState_SEND_MSG = 2'd1;
  localparam IrqState_ACK = 2'd2;

  wire       [31:0]   _zz_tableAddrLo_port0;
  wire       [31:0]   _zz_tableAddrLo_port1;
  wire       [31:0]   _zz_tableAddrLo_port3;
  wire       [31:0]   _zz_tableAddrHi_port0;
  wire       [31:0]   _zz_tableAddrHi_port1;
  wire       [31:0]   _zz_tableAddrHi_port3;
  wire       [31:0]   _zz_tableMsgData_port0;
  wire       [31:0]   _zz_tableMsgData_port1;
  wire       [31:0]   _zz_tableMsgData_port3;
  wire       [31:0]   _zz_tableVCtrl_port0;
  wire       [31:0]   _zz_tableVCtrl_port1;
  wire       [31:0]   _zz_tableVCtrl_port2;
  wire       [31:0]   _zz_tableVCtrl_port3;
  wire       [31:0]   _zz_tableVCtrl_port4;
  wire       [31:0]   _zz_tableVCtrl_port5;
  wire       [31:0]   _zz_tableVCtrl_port6;
  wire       [31:0]   _zz_tableVCtrl_port7;
  wire       [31:0]   _zz_tableVCtrl_port8;
  wire       [31:0]   _zz_tableVCtrl_port9;
  wire       [31:0]   _zz_tableVCtrl_port10;
  wire       [31:0]   _zz_tableVCtrl_port11;
  wire       [31:0]   _zz_tableVCtrl_port12;
  wire       [31:0]   _zz_tableVCtrl_port13;
  wire       [31:0]   _zz_tableVCtrl_port14;
  wire       [31:0]   _zz_tableVCtrl_port15;
  wire       [31:0]   _zz_tableVCtrl_port16;
  wire       [31:0]   _zz_tableVCtrl_port17;
  wire       [31:0]   _zz_tableVCtrl_port18;
  wire       [31:0]   _zz_tableVCtrl_port19;
  wire       [31:0]   _zz_tableVCtrl_port20;
  wire       [31:0]   _zz_tableVCtrl_port21;
  wire       [31:0]   _zz_tableVCtrl_port22;
  wire       [31:0]   _zz_tableVCtrl_port23;
  wire       [31:0]   _zz_tableVCtrl_port24;
  wire       [31:0]   _zz_tableVCtrl_port25;
  wire       [31:0]   _zz_tableVCtrl_port26;
  wire       [31:0]   _zz_tableVCtrl_port27;
  wire       [31:0]   _zz_tableVCtrl_port28;
  wire       [31:0]   _zz_tableVCtrl_port29;
  wire       [31:0]   _zz_tableVCtrl_port30;
  wire       [31:0]   _zz_tableVCtrl_port31;
  wire       [31:0]   _zz_tableVCtrl_port32;
  wire       [31:0]   _zz_tableVCtrl_port33;
  wire       [4:0]    _zz_tableVCtrl_port;
  wire       [4:0]    _zz_maskedBits;
  wire       [4:0]    _zz_tableVCtrl_port_1;
  wire       [4:0]    _zz_maskedBits_1;
  wire       [4:0]    _zz_tableVCtrl_port_2;
  wire       [4:0]    _zz_maskedBits_2;
  wire       [4:0]    _zz_tableVCtrl_port_3;
  wire       [4:0]    _zz_maskedBits_3;
  wire       [4:0]    _zz_tableVCtrl_port_4;
  wire       [4:0]    _zz_maskedBits_4;
  wire       [4:0]    _zz_tableVCtrl_port_5;
  wire       [4:0]    _zz_maskedBits_5;
  wire       [4:0]    _zz_tableVCtrl_port_6;
  wire       [4:0]    _zz_maskedBits_6;
  wire       [4:0]    _zz_tableVCtrl_port_7;
  wire       [4:0]    _zz_maskedBits_7;
  wire       [4:0]    _zz_tableVCtrl_port_8;
  wire       [4:0]    _zz_maskedBits_8;
  wire       [4:0]    _zz_tableVCtrl_port_9;
  wire       [4:0]    _zz_maskedBits_9;
  wire       [4:0]    _zz_tableVCtrl_port_10;
  wire       [4:0]    _zz_maskedBits_10;
  wire       [4:0]    _zz_tableVCtrl_port_11;
  wire       [4:0]    _zz_maskedBits_11;
  wire       [4:0]    _zz_tableVCtrl_port_12;
  wire       [4:0]    _zz_maskedBits_12;
  wire       [4:0]    _zz_tableVCtrl_port_13;
  wire       [4:0]    _zz_maskedBits_13;
  wire       [4:0]    _zz_tableVCtrl_port_14;
  wire       [4:0]    _zz_maskedBits_14;
  wire       [4:0]    _zz_tableVCtrl_port_15;
  wire       [4:0]    _zz_maskedBits_15;
  wire       [4:0]    _zz_tableVCtrl_port_16;
  wire       [4:0]    _zz_maskedBits_16;
  wire       [4:0]    _zz_tableVCtrl_port_17;
  wire       [4:0]    _zz_maskedBits_17;
  wire       [4:0]    _zz_tableVCtrl_port_18;
  wire       [4:0]    _zz_maskedBits_18;
  wire       [4:0]    _zz_tableVCtrl_port_19;
  wire       [4:0]    _zz_maskedBits_19;
  wire       [4:0]    _zz_tableVCtrl_port_20;
  wire       [4:0]    _zz_maskedBits_20;
  wire       [4:0]    _zz_tableVCtrl_port_21;
  wire       [4:0]    _zz_maskedBits_21;
  wire       [4:0]    _zz_tableVCtrl_port_22;
  wire       [4:0]    _zz_maskedBits_22;
  wire       [4:0]    _zz_tableVCtrl_port_23;
  wire       [4:0]    _zz_maskedBits_23;
  wire       [4:0]    _zz_tableVCtrl_port_24;
  wire       [4:0]    _zz_maskedBits_24;
  wire       [4:0]    _zz_tableVCtrl_port_25;
  wire       [4:0]    _zz_maskedBits_25;
  wire       [4:0]    _zz_tableVCtrl_port_26;
  wire       [4:0]    _zz_maskedBits_26;
  wire       [4:0]    _zz_tableVCtrl_port_27;
  wire       [4:0]    _zz_maskedBits_27;
  wire       [4:0]    _zz_tableVCtrl_port_28;
  wire       [4:0]    _zz_maskedBits_28;
  wire       [4:0]    _zz_tableVCtrl_port_29;
  wire       [4:0]    _zz_maskedBits_29;
  wire       [4:0]    _zz_tableVCtrl_port_30;
  wire       [4:0]    _zz_maskedBits_30;
  wire       [4:0]    _zz_tableVCtrl_port_31;
  wire       [4:0]    _zz_maskedBits_31;
  wire       [7:0]    _zz_rdVecIdx;
  wire       [4:0]    _zz_scanIdx;
  reg                 _zz_1;
  reg                 _zz_2;
  reg                 _zz_3;
  reg                 _zz_4;
  reg        [31:0]   pendingBits;
  reg        [31:0]   maskedBits;
  wire       [31:0]   newPending;
  wire       [4:0]    rdVecIdx;
  wire       [1:0]    rdDwOff;
  reg        [31:0]   _zz_41;
  wire                when_MsixController_l71;
  wire                when_MsixController_l71_1;
  wire                when_MsixController_l71_2;
  wire                when_MsixController_l71_3;
  reg        [31:0]   _zz_42;
  wire                when_MsixController_l71_4;
  wire                when_MsixController_l71_5;
  wire                when_MsixController_l71_6;
  wire                when_MsixController_l71_7;
  reg        [31:0]   _zz_43;
  wire                when_MsixController_l71_8;
  wire                when_MsixController_l71_9;
  wire                when_MsixController_l71_10;
  wire                when_MsixController_l71_11;
  reg        [31:0]   _zz_44;
  wire                when_MsixController_l71_12;
  wire                when_MsixController_l71_13;
  wire                when_MsixController_l71_14;
  wire                when_MsixController_l71_15;
  reg        [1:0]    irqState_1;
  reg        [4:0]    activeVec;
  reg        [4:0]    scanIdx;
  wire                when_MsixController_l107;
  `ifndef SYNTHESIS
  reg [55:0] io_msgTlpOut_payload_tlpType_string;
  reg [63:0] irqState_1_string;
  `endif

  (* ram_style = "distributed" *) reg [31:0] tableAddrLo [0:31];
  (* ram_style = "distributed" *) reg [31:0] tableAddrHi [0:31];
  (* ram_style = "distributed" *) reg [31:0] tableMsgData [0:31];
  (* ram_style = "distributed" *) reg [31:0] tableVCtrl [0:31];

  assign _zz_rdVecIdx = io_tableAddr[11 : 4];
  assign _zz_scanIdx = (scanIdx + 5'h01);
  assign _zz_maskedBits = 5'h00;
  assign _zz_maskedBits_1 = 5'h01;
  assign _zz_maskedBits_2 = 5'h02;
  assign _zz_maskedBits_3 = 5'h03;
  assign _zz_maskedBits_4 = 5'h04;
  assign _zz_maskedBits_5 = 5'h05;
  assign _zz_maskedBits_6 = 5'h06;
  assign _zz_maskedBits_7 = 5'h07;
  assign _zz_maskedBits_8 = 5'h08;
  assign _zz_maskedBits_9 = 5'h09;
  assign _zz_maskedBits_10 = 5'h0a;
  assign _zz_maskedBits_11 = 5'h0b;
  assign _zz_maskedBits_12 = 5'h0c;
  assign _zz_maskedBits_13 = 5'h0d;
  assign _zz_maskedBits_14 = 5'h0e;
  assign _zz_maskedBits_15 = 5'h0f;
  assign _zz_maskedBits_16 = 5'h10;
  assign _zz_maskedBits_17 = 5'h11;
  assign _zz_maskedBits_18 = 5'h12;
  assign _zz_maskedBits_19 = 5'h13;
  assign _zz_maskedBits_20 = 5'h14;
  assign _zz_maskedBits_21 = 5'h15;
  assign _zz_maskedBits_22 = 5'h16;
  assign _zz_maskedBits_23 = 5'h17;
  assign _zz_maskedBits_24 = 5'h18;
  assign _zz_maskedBits_25 = 5'h19;
  assign _zz_maskedBits_26 = 5'h1a;
  assign _zz_maskedBits_27 = 5'h1b;
  assign _zz_maskedBits_28 = 5'h1c;
  assign _zz_maskedBits_29 = 5'h1d;
  assign _zz_maskedBits_30 = 5'h1e;
  assign _zz_maskedBits_31 = 5'h1f;
  assign _zz_tableAddrLo_port0 = tableAddrLo[rdVecIdx];
  assign _zz_tableAddrLo_port1 = tableAddrLo[rdVecIdx];
  always @(posedge clk) begin
    if(_zz_4) begin
      tableAddrLo[rdVecIdx] <= _zz_41;
    end
  end

  assign _zz_tableAddrLo_port3 = tableAddrLo[activeVec];
  assign _zz_tableAddrHi_port0 = tableAddrHi[rdVecIdx];
  assign _zz_tableAddrHi_port1 = tableAddrHi[rdVecIdx];
  always @(posedge clk) begin
    if(_zz_3) begin
      tableAddrHi[rdVecIdx] <= _zz_42;
    end
  end

  assign _zz_tableAddrHi_port3 = tableAddrHi[activeVec];
  assign _zz_tableMsgData_port0 = tableMsgData[rdVecIdx];
  assign _zz_tableMsgData_port1 = tableMsgData[rdVecIdx];
  always @(posedge clk) begin
    if(_zz_2) begin
      tableMsgData[rdVecIdx] <= _zz_43;
    end
  end

  assign _zz_tableMsgData_port3 = tableMsgData[activeVec];
  assign _zz_tableVCtrl_port0 = tableVCtrl[_zz_maskedBits];
  assign _zz_tableVCtrl_port1 = tableVCtrl[_zz_maskedBits_1];
  assign _zz_tableVCtrl_port2 = tableVCtrl[_zz_maskedBits_2];
  assign _zz_tableVCtrl_port3 = tableVCtrl[_zz_maskedBits_3];
  assign _zz_tableVCtrl_port4 = tableVCtrl[_zz_maskedBits_4];
  assign _zz_tableVCtrl_port5 = tableVCtrl[_zz_maskedBits_5];
  assign _zz_tableVCtrl_port6 = tableVCtrl[_zz_maskedBits_6];
  assign _zz_tableVCtrl_port7 = tableVCtrl[_zz_maskedBits_7];
  assign _zz_tableVCtrl_port8 = tableVCtrl[_zz_maskedBits_8];
  assign _zz_tableVCtrl_port9 = tableVCtrl[_zz_maskedBits_9];
  assign _zz_tableVCtrl_port10 = tableVCtrl[_zz_maskedBits_10];
  assign _zz_tableVCtrl_port11 = tableVCtrl[_zz_maskedBits_11];
  assign _zz_tableVCtrl_port12 = tableVCtrl[_zz_maskedBits_12];
  assign _zz_tableVCtrl_port13 = tableVCtrl[_zz_maskedBits_13];
  assign _zz_tableVCtrl_port14 = tableVCtrl[_zz_maskedBits_14];
  assign _zz_tableVCtrl_port15 = tableVCtrl[_zz_maskedBits_15];
  assign _zz_tableVCtrl_port16 = tableVCtrl[_zz_maskedBits_16];
  assign _zz_tableVCtrl_port17 = tableVCtrl[_zz_maskedBits_17];
  assign _zz_tableVCtrl_port18 = tableVCtrl[_zz_maskedBits_18];
  assign _zz_tableVCtrl_port19 = tableVCtrl[_zz_maskedBits_19];
  assign _zz_tableVCtrl_port20 = tableVCtrl[_zz_maskedBits_20];
  assign _zz_tableVCtrl_port21 = tableVCtrl[_zz_maskedBits_21];
  assign _zz_tableVCtrl_port22 = tableVCtrl[_zz_maskedBits_22];
  assign _zz_tableVCtrl_port23 = tableVCtrl[_zz_maskedBits_23];
  assign _zz_tableVCtrl_port24 = tableVCtrl[_zz_maskedBits_24];
  assign _zz_tableVCtrl_port25 = tableVCtrl[_zz_maskedBits_25];
  assign _zz_tableVCtrl_port26 = tableVCtrl[_zz_maskedBits_26];
  assign _zz_tableVCtrl_port27 = tableVCtrl[_zz_maskedBits_27];
  assign _zz_tableVCtrl_port28 = tableVCtrl[_zz_maskedBits_28];
  assign _zz_tableVCtrl_port29 = tableVCtrl[_zz_maskedBits_29];
  assign _zz_tableVCtrl_port30 = tableVCtrl[_zz_maskedBits_30];
  assign _zz_tableVCtrl_port31 = tableVCtrl[_zz_maskedBits_31];
  assign _zz_tableVCtrl_port32 = tableVCtrl[rdVecIdx];
  assign _zz_tableVCtrl_port33 = tableVCtrl[rdVecIdx];
  always @(posedge clk) begin
    if(_zz_1) begin
      tableVCtrl[rdVecIdx] <= _zz_44;
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_msgTlpOut_payload_tlpType)
      TlpType_MEM_RD : io_msgTlpOut_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_msgTlpOut_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_msgTlpOut_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_msgTlpOut_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_msgTlpOut_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_msgTlpOut_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_msgTlpOut_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_msgTlpOut_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_msgTlpOut_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_msgTlpOut_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_msgTlpOut_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_msgTlpOut_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_msgTlpOut_payload_tlpType_string = "INVALID";
      default : io_msgTlpOut_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(irqState_1)
      IrqState_SCAN : irqState_1_string = "SCAN    ";
      IrqState_SEND_MSG : irqState_1_string = "SEND_MSG";
      IrqState_ACK : irqState_1_string = "ACK     ";
      default : irqState_1_string = "????????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    if(io_tableWen) begin
      case(rdDwOff)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
          _zz_1 = 1'b1;
        end
      endcase
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(io_tableWen) begin
      case(rdDwOff)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
          _zz_2 = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    _zz_3 = 1'b0;
    if(io_tableWen) begin
      case(rdDwOff)
        2'b00 : begin
        end
        2'b01 : begin
          _zz_3 = 1'b1;
        end
        2'b10 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    _zz_4 = 1'b0;
    if(io_tableWen) begin
      case(rdDwOff)
        2'b00 : begin
          _zz_4 = 1'b1;
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    maskedBits[0] = (io_funcMask || _zz_tableVCtrl_port0[0]);
    maskedBits[1] = (io_funcMask || _zz_tableVCtrl_port1[0]);
    maskedBits[2] = (io_funcMask || _zz_tableVCtrl_port2[0]);
    maskedBits[3] = (io_funcMask || _zz_tableVCtrl_port3[0]);
    maskedBits[4] = (io_funcMask || _zz_tableVCtrl_port4[0]);
    maskedBits[5] = (io_funcMask || _zz_tableVCtrl_port5[0]);
    maskedBits[6] = (io_funcMask || _zz_tableVCtrl_port6[0]);
    maskedBits[7] = (io_funcMask || _zz_tableVCtrl_port7[0]);
    maskedBits[8] = (io_funcMask || _zz_tableVCtrl_port8[0]);
    maskedBits[9] = (io_funcMask || _zz_tableVCtrl_port9[0]);
    maskedBits[10] = (io_funcMask || _zz_tableVCtrl_port10[0]);
    maskedBits[11] = (io_funcMask || _zz_tableVCtrl_port11[0]);
    maskedBits[12] = (io_funcMask || _zz_tableVCtrl_port12[0]);
    maskedBits[13] = (io_funcMask || _zz_tableVCtrl_port13[0]);
    maskedBits[14] = (io_funcMask || _zz_tableVCtrl_port14[0]);
    maskedBits[15] = (io_funcMask || _zz_tableVCtrl_port15[0]);
    maskedBits[16] = (io_funcMask || _zz_tableVCtrl_port16[0]);
    maskedBits[17] = (io_funcMask || _zz_tableVCtrl_port17[0]);
    maskedBits[18] = (io_funcMask || _zz_tableVCtrl_port18[0]);
    maskedBits[19] = (io_funcMask || _zz_tableVCtrl_port19[0]);
    maskedBits[20] = (io_funcMask || _zz_tableVCtrl_port20[0]);
    maskedBits[21] = (io_funcMask || _zz_tableVCtrl_port21[0]);
    maskedBits[22] = (io_funcMask || _zz_tableVCtrl_port22[0]);
    maskedBits[23] = (io_funcMask || _zz_tableVCtrl_port23[0]);
    maskedBits[24] = (io_funcMask || _zz_tableVCtrl_port24[0]);
    maskedBits[25] = (io_funcMask || _zz_tableVCtrl_port25[0]);
    maskedBits[26] = (io_funcMask || _zz_tableVCtrl_port26[0]);
    maskedBits[27] = (io_funcMask || _zz_tableVCtrl_port27[0]);
    maskedBits[28] = (io_funcMask || _zz_tableVCtrl_port28[0]);
    maskedBits[29] = (io_funcMask || _zz_tableVCtrl_port29[0]);
    maskedBits[30] = (io_funcMask || _zz_tableVCtrl_port30[0]);
    maskedBits[31] = (io_funcMask || _zz_tableVCtrl_port31[0]);
  end

  assign newPending = (io_msixEnable ? (io_intReq & (~ maskedBits)) : 32'h00000000);
  assign rdVecIdx = _zz_rdVecIdx[4:0];
  assign rdDwOff = io_tableAddr[3 : 2];
  always @(*) begin
    case(rdDwOff)
      2'b00 : begin
        io_tableRdata = _zz_tableAddrLo_port0;
      end
      2'b01 : begin
        io_tableRdata = _zz_tableAddrHi_port0;
      end
      2'b10 : begin
        io_tableRdata = _zz_tableMsgData_port0;
      end
      default : begin
        io_tableRdata = _zz_tableVCtrl_port32;
      end
    endcase
  end

  always @(*) begin
    _zz_41 = _zz_tableAddrLo_port1;
    if(when_MsixController_l71) begin
      _zz_41[7 : 0] = io_tableWdata[7 : 0];
    end
    if(when_MsixController_l71_1) begin
      _zz_41[15 : 8] = io_tableWdata[15 : 8];
    end
    if(when_MsixController_l71_2) begin
      _zz_41[23 : 16] = io_tableWdata[23 : 16];
    end
    if(when_MsixController_l71_3) begin
      _zz_41[31 : 24] = io_tableWdata[31 : 24];
    end
  end

  assign when_MsixController_l71 = io_tableBe[0];
  assign when_MsixController_l71_1 = io_tableBe[1];
  assign when_MsixController_l71_2 = io_tableBe[2];
  assign when_MsixController_l71_3 = io_tableBe[3];
  always @(*) begin
    _zz_42 = _zz_tableAddrHi_port1;
    if(when_MsixController_l71_4) begin
      _zz_42[7 : 0] = io_tableWdata[7 : 0];
    end
    if(when_MsixController_l71_5) begin
      _zz_42[15 : 8] = io_tableWdata[15 : 8];
    end
    if(when_MsixController_l71_6) begin
      _zz_42[23 : 16] = io_tableWdata[23 : 16];
    end
    if(when_MsixController_l71_7) begin
      _zz_42[31 : 24] = io_tableWdata[31 : 24];
    end
  end

  assign when_MsixController_l71_4 = io_tableBe[0];
  assign when_MsixController_l71_5 = io_tableBe[1];
  assign when_MsixController_l71_6 = io_tableBe[2];
  assign when_MsixController_l71_7 = io_tableBe[3];
  always @(*) begin
    _zz_43 = _zz_tableMsgData_port1;
    if(when_MsixController_l71_8) begin
      _zz_43[7 : 0] = io_tableWdata[7 : 0];
    end
    if(when_MsixController_l71_9) begin
      _zz_43[15 : 8] = io_tableWdata[15 : 8];
    end
    if(when_MsixController_l71_10) begin
      _zz_43[23 : 16] = io_tableWdata[23 : 16];
    end
    if(when_MsixController_l71_11) begin
      _zz_43[31 : 24] = io_tableWdata[31 : 24];
    end
  end

  assign when_MsixController_l71_8 = io_tableBe[0];
  assign when_MsixController_l71_9 = io_tableBe[1];
  assign when_MsixController_l71_10 = io_tableBe[2];
  assign when_MsixController_l71_11 = io_tableBe[3];
  always @(*) begin
    _zz_44 = _zz_tableVCtrl_port33;
    if(when_MsixController_l71_12) begin
      _zz_44[7 : 0] = io_tableWdata[7 : 0];
    end
    if(when_MsixController_l71_13) begin
      _zz_44[15 : 8] = io_tableWdata[15 : 8];
    end
    if(when_MsixController_l71_14) begin
      _zz_44[23 : 16] = io_tableWdata[23 : 16];
    end
    if(when_MsixController_l71_15) begin
      _zz_44[31 : 24] = io_tableWdata[31 : 24];
    end
  end

  assign when_MsixController_l71_12 = io_tableBe[0];
  assign when_MsixController_l71_13 = io_tableBe[1];
  assign when_MsixController_l71_14 = io_tableBe[2];
  assign when_MsixController_l71_15 = io_tableBe[3];
  always @(*) begin
    io_msgTlpOut_valid = 1'b0;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_valid = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_tlpType = (4'bxxxx);
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_tlpType = TlpType_MSG_D;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_reqId = 16'bxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_reqId = io_busDevFunc;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_tag = 8'bxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_tag = 8'h00;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_addr = 64'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_addr = {_zz_tableAddrHi_port3,_zz_tableAddrLo_port3};
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_length = 10'bxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_length = 10'h001;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_firstBe = 4'bxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_firstBe = 4'b1111;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_lastBe = 4'bxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_lastBe = 4'b1111;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_tc = 3'bxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_tc = 3'b000;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_attr = 2'bxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_attr = 2'b00;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_data_0 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_data_0 = _zz_tableMsgData_port3;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_data_1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_data_1 = 32'h00000000;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_data_2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_data_2 = 32'h00000000;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_data_3 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_data_3 = 32'h00000000;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_msgTlpOut_payload_dataValid = 3'bxxx;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
        io_msgTlpOut_payload_dataValid = 3'b001;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_intAck = 32'h00000000;
    case(irqState_1)
      IrqState_SCAN : begin
      end
      IrqState_SEND_MSG : begin
      end
      default : begin
        io_intAck[activeVec] = 1'b1;
      end
    endcase
  end

  assign when_MsixController_l107 = pendingBits[scanIdx];
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      pendingBits <= 32'h00000000;
      irqState_1 <= IrqState_SCAN;
      activeVec <= 5'h00;
      scanIdx <= 5'h00;
    end else begin
      pendingBits <= (pendingBits | newPending);
      case(irqState_1)
        IrqState_SCAN : begin
          if(io_msixEnable) begin
            if(when_MsixController_l107) begin
              activeVec <= scanIdx;
              irqState_1 <= IrqState_SEND_MSG;
            end
            scanIdx <= ((scanIdx == 5'h1f) ? 5'h00 : _zz_scanIdx);
          end
        end
        IrqState_SEND_MSG : begin
          if(io_msgTlpOut_ready) begin
            irqState_1 <= IrqState_ACK;
          end
        end
        default : begin
          pendingBits[activeVec] <= 1'b0;
          irqState_1 <= IrqState_SCAN;
        end
      endcase
    end
  end


endmodule

module DmaEngine (
  input  wire          io_ctrl_aw_valid,
  output wire          io_ctrl_aw_ready,
  input  wire [31:0]   io_ctrl_aw_payload_addr,
  input  wire [3:0]    io_ctrl_aw_payload_id,
  input  wire [7:0]    io_ctrl_aw_payload_len,
  input  wire [2:0]    io_ctrl_aw_payload_size,
  input  wire [1:0]    io_ctrl_aw_payload_burst,
  input  wire          io_ctrl_w_valid,
  output wire          io_ctrl_w_ready,
  input  wire [31:0]   io_ctrl_w_payload_data,
  input  wire          io_ctrl_w_payload_last,
  output wire          io_ctrl_b_valid,
  input  wire          io_ctrl_b_ready,
  output wire [3:0]    io_ctrl_b_payload_id,
  output wire [1:0]    io_ctrl_b_payload_resp,
  input  wire          io_ctrl_ar_valid,
  output wire          io_ctrl_ar_ready,
  input  wire [31:0]   io_ctrl_ar_payload_addr,
  input  wire [3:0]    io_ctrl_ar_payload_id,
  input  wire [7:0]    io_ctrl_ar_payload_len,
  input  wire [2:0]    io_ctrl_ar_payload_size,
  input  wire [1:0]    io_ctrl_ar_payload_burst,
  output wire          io_ctrl_r_valid,
  input  wire          io_ctrl_r_ready,
  output wire [31:0]   io_ctrl_r_payload_data,
  output wire [3:0]    io_ctrl_r_payload_id,
  output wire [1:0]    io_ctrl_r_payload_resp,
  output wire          io_ctrl_r_payload_last,
  output reg           io_memWrOut_valid,
  input  wire          io_memWrOut_ready,
  output reg  [3:0]    io_memWrOut_payload_tlpType,
  output reg  [15:0]   io_memWrOut_payload_reqId,
  output reg  [7:0]    io_memWrOut_payload_tag,
  output reg  [63:0]   io_memWrOut_payload_addr,
  output reg  [9:0]    io_memWrOut_payload_length,
  output reg  [3:0]    io_memWrOut_payload_firstBe,
  output reg  [3:0]    io_memWrOut_payload_lastBe,
  output reg  [2:0]    io_memWrOut_payload_tc,
  output reg  [1:0]    io_memWrOut_payload_attr,
  output reg  [31:0]   io_memWrOut_payload_data_0,
  output reg  [31:0]   io_memWrOut_payload_data_1,
  output reg  [31:0]   io_memWrOut_payload_data_2,
  output reg  [31:0]   io_memWrOut_payload_data_3,
  output reg  [2:0]    io_memWrOut_payload_dataValid,
  output reg           io_memRdOut_valid,
  input  wire          io_memRdOut_ready,
  output wire [3:0]    io_memRdOut_payload_tlpType,
  output wire [15:0]   io_memRdOut_payload_reqId,
  output wire [7:0]    io_memRdOut_payload_tag,
  output wire [63:0]   io_memRdOut_payload_addr,
  output wire [9:0]    io_memRdOut_payload_length,
  output wire [3:0]    io_memRdOut_payload_firstBe,
  output wire [3:0]    io_memRdOut_payload_lastBe,
  output wire [2:0]    io_memRdOut_payload_tc,
  output wire [1:0]    io_memRdOut_payload_attr,
  output wire [31:0]   io_memRdOut_payload_data_0,
  output wire [31:0]   io_memRdOut_payload_data_1,
  output wire [31:0]   io_memRdOut_payload_data_2,
  output wire [31:0]   io_memRdOut_payload_data_3,
  output wire [2:0]    io_memRdOut_payload_dataValid,
  input  wire          io_cplIn_valid,
  output wire          io_cplIn_ready,
  input  wire [3:0]    io_cplIn_payload_tlpType,
  input  wire [15:0]   io_cplIn_payload_reqId,
  input  wire [7:0]    io_cplIn_payload_tag,
  input  wire [63:0]   io_cplIn_payload_addr,
  input  wire [9:0]    io_cplIn_payload_length,
  input  wire [3:0]    io_cplIn_payload_firstBe,
  input  wire [3:0]    io_cplIn_payload_lastBe,
  input  wire [2:0]    io_cplIn_payload_tc,
  input  wire [1:0]    io_cplIn_payload_attr,
  input  wire [31:0]   io_cplIn_payload_data_0,
  input  wire [31:0]   io_cplIn_payload_data_1,
  input  wire [31:0]   io_cplIn_payload_data_2,
  input  wire [31:0]   io_cplIn_payload_data_3,
  input  wire [2:0]    io_cplIn_payload_dataValid,
  output reg           io_localMem_aw_valid,
  input  wire          io_localMem_aw_ready,
  output reg  [31:0]   io_localMem_aw_payload_addr,
  output wire [3:0]    io_localMem_aw_payload_id,
  output wire [3:0]    io_localMem_aw_payload_region,
  output wire [7:0]    io_localMem_aw_payload_len,
  output wire [2:0]    io_localMem_aw_payload_size,
  output wire [1:0]    io_localMem_aw_payload_burst,
  output wire [0:0]    io_localMem_aw_payload_lock,
  output wire [3:0]    io_localMem_aw_payload_cache,
  output wire [3:0]    io_localMem_aw_payload_qos,
  output wire [2:0]    io_localMem_aw_payload_prot,
  output reg           io_localMem_w_valid,
  input  wire          io_localMem_w_ready,
  output reg  [63:0]   io_localMem_w_payload_data,
  output reg  [7:0]    io_localMem_w_payload_strb,
  output wire          io_localMem_w_payload_last,
  input  wire          io_localMem_b_valid,
  output wire          io_localMem_b_ready,
  input  wire [3:0]    io_localMem_b_payload_id,
  input  wire [1:0]    io_localMem_b_payload_resp,
  output reg           io_localMem_ar_valid,
  input  wire          io_localMem_ar_ready,
  output reg  [31:0]   io_localMem_ar_payload_addr,
  output wire [3:0]    io_localMem_ar_payload_id,
  output wire [3:0]    io_localMem_ar_payload_region,
  output reg  [7:0]    io_localMem_ar_payload_len,
  output wire [2:0]    io_localMem_ar_payload_size,
  output wire [1:0]    io_localMem_ar_payload_burst,
  output wire [0:0]    io_localMem_ar_payload_lock,
  output wire [3:0]    io_localMem_ar_payload_cache,
  output wire [3:0]    io_localMem_ar_payload_qos,
  output wire [2:0]    io_localMem_ar_payload_prot,
  input  wire          io_localMem_r_valid,
  output wire          io_localMem_r_ready,
  input  wire [63:0]   io_localMem_r_payload_data,
  input  wire [3:0]    io_localMem_r_payload_id,
  input  wire [1:0]    io_localMem_r_payload_resp,
  input  wire          io_localMem_r_payload_last,
  output wire          io_h2dDone,
  output wire          io_d2hDone,
  output wire          io_dmaErr,
  input  wire [15:0]   io_busDevFunc,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;
  localparam DmaState_IDLE = 4'd0;
  localparam DmaState_FETCH_DESC = 4'd1;
  localparam DmaState_H2D_RD_REQ = 4'd2;
  localparam DmaState_H2D_WAIT_CPL = 4'd3;
  localparam DmaState_H2D_WR_LOCAL = 4'd4;
  localparam DmaState_D2H_RD_LOCAL = 4'd5;
  localparam DmaState_D2H_WR_PCIE = 4'd6;
  localparam DmaState_NEXT_DESC = 4'd7;
  localparam DmaState_DONE = 4'd8;
  localparam DmaState_ERROR = 4'd9;

  wire       [255:0]  _zz_descriptorMem_port0;
  wire       [15:0]   _zz_rData;
  wire       [15:0]   _zz_rData_1;
  wire       [63:0]   _zz_addrLower32;
  wire       [31:0]   _zz_maxReadDw;
  wire       [31:0]   _zz_maxReadDw_1;
  wire       [63:0]   _zz_memWrPkt_addr;
  wire       [63:0]   _zz_memRdPkt_addr;
  wire       [29:0]   _zz__zz_remaining;
  wire       [29:0]   _zz__zz_remaining_1;
  wire       [31:0]   _zz_offset;
  wire       [31:0]   _zz_totalBytes_1;
  wire       [33:0]   _zz_totalBytes_2;
  wire       [7:0]    _zz_io_localMem_ar_payload_len;
  wire       [31:0]   _zz_io_localMem_ar_payload_len_1;
  wire       [63:0]   _zz_io_memWrOut_payload_addr;
  wire       [31:0]   _zz_offset_1;
  wire       [31:0]   _zz_totalBytes_3;
  wire       [33:0]   _zz_totalBytes_4;
  wire       [15:0]   _zz_when_DmaEngine_l496;
  reg        [31:0]   ctrlReg;
  reg        [31:0]   statusReg;
  reg        [31:0]   srcAddrLo;
  reg        [31:0]   srcAddrHi;
  reg        [31:0]   dstAddrLo;
  reg        [31:0]   dstAddrHi;
  reg        [31:0]   lengthReg;
  reg        [31:0]   descTableLo;
  reg        [31:0]   descTableHi;
  reg        [15:0]   descCount;
  reg        [15:0]   descCurrent;
  reg        [31:0]   totalBytes;
  reg                 rValid;
  reg        [3:0]    rId;
  reg        [31:0]   rData;
  wire                io_ctrl_ar_fire;
  wire       [5:0]    switch_DmaEngine_l111;
  wire                io_ctrl_r_fire;
  reg                 awPending;
  reg        [31:0]   awAddrReg;
  reg        [3:0]    awIdReg;
  reg                 wPending;
  reg        [31:0]   wDataReg;
  wire                io_ctrl_aw_fire;
  wire                io_ctrl_w_fire;
  reg                 bValid;
  reg        [3:0]    bId;
  wire                doWrite;
  wire       [5:0]    switch_DmaEngine_l165;
  wire                io_ctrl_b_fire;
  reg        [63:0]   activeDesc_srcAddr;
  reg        [63:0]   activeDesc_dstAddr;
  reg        [31:0]   activeDesc_length;
  reg        [31:0]   activeDesc_control;
  reg        [63:0]   activeDesc_nextDesc;
  wire                startBit;
  reg                 startPrev;
  wire                startPulse;
  wire                direction;
  wire                sgMode;
  wire                intEnable;
  reg        [3:0]    dmaState_1;
  reg        [31:0]   remaining;
  reg        [31:0]   offset;
  reg        [7:0]    tagCtr;
  reg        [7:0]    reqTag;
  reg        [15:0]   descIdx;
  reg        [31:0]   outstandingDw;
  reg                 waitingCpl;
  reg        [23:0]   cplTimeout;
  reg        [31:0]   mrrsDw;
  wire       [31:0]   maxPayloadDw;
  wire       [63:0]   srcAddrFull;
  wire       [63:0]   offsetExtended;
  wire       [31:0]   addrLower32;
  wire       [31:0]   bytesTo4k;
  wire       [29:0]   boundaryDw;
  wire       [31:0]   maxReadDw;
  wire       [31:0]   chunkDw;
  wire       [31:0]   d2hChunkDw;
  wire       [3:0]    memWrPkt_tlpType;
  wire       [15:0]   memWrPkt_reqId;
  wire       [7:0]    memWrPkt_tag;
  wire       [63:0]   memWrPkt_addr;
  wire       [9:0]    memWrPkt_length;
  wire       [3:0]    memWrPkt_firstBe;
  wire       [3:0]    memWrPkt_lastBe;
  wire       [2:0]    memWrPkt_tc;
  wire       [1:0]    memWrPkt_attr;
  wire       [31:0]   memWrPkt_data_0;
  wire       [31:0]   memWrPkt_data_1;
  wire       [31:0]   memWrPkt_data_2;
  wire       [31:0]   memWrPkt_data_3;
  wire       [2:0]    memWrPkt_dataValid;
  wire       [3:0]    memRdPkt_tlpType;
  wire       [15:0]   memRdPkt_reqId;
  wire       [7:0]    memRdPkt_tag;
  wire       [63:0]   memRdPkt_addr;
  wire       [9:0]    memRdPkt_length;
  wire       [3:0]    memRdPkt_firstBe;
  wire       [3:0]    memRdPkt_lastBe;
  wire       [2:0]    memRdPkt_tc;
  wire       [1:0]    memRdPkt_attr;
  wire       [31:0]   memRdPkt_data_0;
  wire       [31:0]   memRdPkt_data_1;
  wire       [31:0]   memRdPkt_data_2;
  wire       [31:0]   memRdPkt_data_3;
  wire       [2:0]    memRdPkt_dataValid;
  reg        [31:0]   h2dWriteAddr;
  reg        [63:0]   h2dWriteData;
  reg        [7:0]    h2dWriteStrb;
  wire       [7:0]    _zz_descReadData_srcAddr;
  wire       [63:0]   descReadData_srcAddr;
  wire       [63:0]   descReadData_dstAddr;
  wire       [31:0]   descReadData_length;
  wire       [31:0]   descReadData_control;
  wire       [63:0]   descReadData_nextDesc;
  wire       [255:0]  _zz_descReadData_srcAddr_1;
  wire                when_DmaEngine_l314;
  wire                when_DmaEngine_l320;
  wire       [31:0]   _zz_remaining;
  wire                when_DmaEngine_l333;
  wire                when_DmaEngine_l335;
  wire                when_DmaEngine_l346;
  wire       [31:0]   _zz_remaining_1;
  wire                when_DmaEngine_l360;
  wire                when_DmaEngine_l362;
  wire                io_cplIn_fire;
  wire                when_DmaEngine_l393;
  wire       [31:0]   _zz_totalBytes;
  wire                when_DmaEngine_l408;
  wire                when_DmaEngine_l423;
  wire                when_DmaEngine_l424;
  wire       [31:0]   _zz_remaining_2;
  wire                when_DmaEngine_l476;
  wire                when_DmaEngine_l496;
  `ifndef SYNTHESIS
  reg [55:0] io_memWrOut_payload_tlpType_string;
  reg [55:0] io_memRdOut_payload_tlpType_string;
  reg [55:0] io_cplIn_payload_tlpType_string;
  reg [95:0] dmaState_1_string;
  reg [55:0] memWrPkt_tlpType_string;
  reg [55:0] memRdPkt_tlpType_string;
  `endif

  reg [255:0] descriptorMem [0:255];

  assign _zz_rData = descCount;
  assign _zz_rData_1 = descCurrent;
  assign _zz_addrLower32 = (srcAddrFull + offsetExtended);
  assign _zz_maxReadDw = {2'd0, boundaryDw};
  assign _zz_maxReadDw_1 = {2'd0, boundaryDw};
  assign _zz_memWrPkt_addr = {32'd0, offset};
  assign _zz_memRdPkt_addr = {32'd0, offset};
  assign _zz__zz_remaining = (lengthReg >>> 2'd2);
  assign _zz__zz_remaining_1 = (descReadData_length >>> 2'd2);
  assign _zz_offset = (_zz_totalBytes <<< 2);
  assign _zz_totalBytes_2 = ({2'd0,_zz_totalBytes} <<< 2'd2);
  assign _zz_totalBytes_1 = _zz_totalBytes_2[31:0];
  assign _zz_io_localMem_ar_payload_len_1 = (d2hChunkDw - 32'h00000001);
  assign _zz_io_localMem_ar_payload_len = _zz_io_localMem_ar_payload_len_1[7:0];
  assign _zz_io_memWrOut_payload_addr = {32'd0, offset};
  assign _zz_offset_1 = (d2hChunkDw <<< 2);
  assign _zz_totalBytes_4 = ({2'd0,d2hChunkDw} <<< 2'd2);
  assign _zz_totalBytes_3 = _zz_totalBytes_4[31:0];
  assign _zz_when_DmaEngine_l496 = (descIdx + 16'h0001);
  assign _zz_descriptorMem_port0 = descriptorMem[_zz_descReadData_srcAddr];
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_memWrOut_payload_tlpType)
      TlpType_MEM_RD : io_memWrOut_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memWrOut_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memWrOut_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memWrOut_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memWrOut_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memWrOut_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memWrOut_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memWrOut_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memWrOut_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memWrOut_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memWrOut_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memWrOut_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memWrOut_payload_tlpType_string = "INVALID";
      default : io_memWrOut_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_memRdOut_payload_tlpType)
      TlpType_MEM_RD : io_memRdOut_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memRdOut_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memRdOut_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memRdOut_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memRdOut_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memRdOut_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memRdOut_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memRdOut_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memRdOut_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memRdOut_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memRdOut_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memRdOut_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memRdOut_payload_tlpType_string = "INVALID";
      default : io_memRdOut_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cplIn_payload_tlpType)
      TlpType_MEM_RD : io_cplIn_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cplIn_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cplIn_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cplIn_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cplIn_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cplIn_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cplIn_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cplIn_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cplIn_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cplIn_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cplIn_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cplIn_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cplIn_payload_tlpType_string = "INVALID";
      default : io_cplIn_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(dmaState_1)
      DmaState_IDLE : dmaState_1_string = "IDLE        ";
      DmaState_FETCH_DESC : dmaState_1_string = "FETCH_DESC  ";
      DmaState_H2D_RD_REQ : dmaState_1_string = "H2D_RD_REQ  ";
      DmaState_H2D_WAIT_CPL : dmaState_1_string = "H2D_WAIT_CPL";
      DmaState_H2D_WR_LOCAL : dmaState_1_string = "H2D_WR_LOCAL";
      DmaState_D2H_RD_LOCAL : dmaState_1_string = "D2H_RD_LOCAL";
      DmaState_D2H_WR_PCIE : dmaState_1_string = "D2H_WR_PCIE ";
      DmaState_NEXT_DESC : dmaState_1_string = "NEXT_DESC   ";
      DmaState_DONE : dmaState_1_string = "DONE        ";
      DmaState_ERROR : dmaState_1_string = "ERROR       ";
      default : dmaState_1_string = "????????????";
    endcase
  end
  always @(*) begin
    case(memWrPkt_tlpType)
      TlpType_MEM_RD : memWrPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : memWrPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : memWrPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : memWrPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : memWrPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : memWrPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : memWrPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : memWrPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : memWrPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : memWrPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : memWrPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : memWrPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : memWrPkt_tlpType_string = "INVALID";
      default : memWrPkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(memRdPkt_tlpType)
      TlpType_MEM_RD : memRdPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : memRdPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : memRdPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : memRdPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : memRdPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : memRdPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : memRdPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : memRdPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : memRdPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : memRdPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : memRdPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : memRdPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : memRdPkt_tlpType_string = "INVALID";
      default : memRdPkt_tlpType_string = "???????";
    endcase
  end
  `endif

  assign io_ctrl_ar_ready = (! rValid);
  assign io_ctrl_r_valid = rValid;
  assign io_ctrl_r_payload_id = rId;
  assign io_ctrl_r_payload_data = rData;
  assign io_ctrl_r_payload_resp = 2'b00;
  assign io_ctrl_r_payload_last = 1'b1;
  assign io_ctrl_ar_fire = (io_ctrl_ar_valid && io_ctrl_ar_ready);
  assign switch_DmaEngine_l111 = io_ctrl_ar_payload_addr[7 : 2];
  assign io_ctrl_r_fire = (io_ctrl_r_valid && io_ctrl_r_ready);
  assign io_ctrl_aw_ready = (! awPending);
  assign io_ctrl_w_ready = (! wPending);
  assign io_ctrl_aw_fire = (io_ctrl_aw_valid && io_ctrl_aw_ready);
  assign io_ctrl_w_fire = (io_ctrl_w_valid && io_ctrl_w_ready);
  assign io_ctrl_b_valid = bValid;
  assign io_ctrl_b_payload_id = bId;
  assign io_ctrl_b_payload_resp = 2'b00;
  assign doWrite = ((awPending && wPending) && (! bValid));
  assign switch_DmaEngine_l165 = awAddrReg[7 : 2];
  assign io_ctrl_b_fire = (io_ctrl_b_valid && io_ctrl_b_ready);
  assign startBit = ctrlReg[0];
  assign startPulse = (startBit && (! startPrev));
  assign direction = ctrlReg[1];
  assign sgMode = ctrlReg[4];
  assign intEnable = ctrlReg[2];
  assign maxPayloadDw = 32'h00000040;
  assign srcAddrFull = {srcAddrHi,srcAddrLo};
  assign offsetExtended = {32'd0, offset};
  assign addrLower32 = _zz_addrLower32[31 : 0];
  assign bytesTo4k = (32'h00001000 - (addrLower32 & 32'h00000fff));
  assign boundaryDw = (bytesTo4k >>> 2'd2);
  assign maxReadDw = ((mrrsDw < _zz_maxReadDw) ? mrrsDw : _zz_maxReadDw_1);
  assign chunkDw = ((remaining < maxReadDw) ? remaining : maxReadDw);
  assign d2hChunkDw = ((remaining < 32'h00000002) ? remaining : 32'h00000002);
  assign memWrPkt_tlpType = TlpType_MEM_WR;
  assign memWrPkt_tc = 3'b000;
  assign memWrPkt_attr = 2'b00;
  assign memWrPkt_firstBe = 4'b1111;
  assign memWrPkt_lastBe = 4'b1111;
  assign memWrPkt_reqId = io_busDevFunc;
  assign memWrPkt_tag = tagCtr;
  assign memWrPkt_addr = ({dstAddrHi,dstAddrLo} + _zz_memWrPkt_addr);
  assign memWrPkt_length = d2hChunkDw[9:0];
  assign memWrPkt_dataValid = d2hChunkDw[2:0];
  assign memWrPkt_data_0 = 32'h00000000;
  assign memWrPkt_data_1 = 32'h00000000;
  assign memWrPkt_data_2 = 32'h00000000;
  assign memWrPkt_data_3 = 32'h00000000;
  assign memRdPkt_tlpType = TlpType_MEM_RD;
  assign memRdPkt_tc = 3'b000;
  assign memRdPkt_attr = 2'b00;
  assign memRdPkt_firstBe = 4'b1111;
  assign memRdPkt_lastBe = 4'b1111;
  assign memRdPkt_reqId = io_busDevFunc;
  assign memRdPkt_tag = tagCtr;
  assign memRdPkt_addr = ({srcAddrHi,srcAddrLo} + _zz_memRdPkt_addr);
  assign memRdPkt_length = chunkDw[9:0];
  assign memRdPkt_dataValid = 3'b000;
  assign memRdPkt_data_0 = 32'h00000000;
  assign memRdPkt_data_1 = 32'h00000000;
  assign memRdPkt_data_2 = 32'h00000000;
  assign memRdPkt_data_3 = 32'h00000000;
  always @(*) begin
    io_memWrOut_valid = 1'b0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_valid = 1'b1;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_tlpType = memWrPkt_tlpType;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_tlpType = TlpType_MEM_WR;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_reqId = memWrPkt_reqId;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_reqId = io_busDevFunc;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_tag = memWrPkt_tag;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_tag = tagCtr;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_addr = memWrPkt_addr;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_addr = ({dstAddrHi,dstAddrLo} + _zz_io_memWrOut_payload_addr);
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_length = memWrPkt_length;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_length = d2hChunkDw[9:0];
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_firstBe = memWrPkt_firstBe;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_firstBe = 4'b1111;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_lastBe = memWrPkt_lastBe;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_lastBe = 4'b1111;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_tc = memWrPkt_tc;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_tc = 3'b000;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_attr = memWrPkt_attr;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_attr = 2'b00;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_data_0 = memWrPkt_data_0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_data_0 = io_localMem_r_payload_data[31 : 0];
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_data_1 = memWrPkt_data_1;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_data_1 = ((32'h00000001 < d2hChunkDw) ? io_localMem_r_payload_data[63 : 32] : 32'h00000000);
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_data_2 = memWrPkt_data_2;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_data_2 = 32'h00000000;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_data_3 = memWrPkt_data_3;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_data_3 = 32'h00000000;
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memWrOut_payload_dataValid = memWrPkt_dataValid;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
        if(io_localMem_r_valid) begin
          io_memWrOut_payload_dataValid = d2hChunkDw[2:0];
        end
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memRdOut_valid = 1'b0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
        io_memRdOut_valid = 1'b1;
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  assign io_memRdOut_payload_tlpType = memRdPkt_tlpType;
  assign io_memRdOut_payload_reqId = memRdPkt_reqId;
  assign io_memRdOut_payload_tag = memRdPkt_tag;
  assign io_memRdOut_payload_addr = memRdPkt_addr;
  assign io_memRdOut_payload_length = memRdPkt_length;
  assign io_memRdOut_payload_firstBe = memRdPkt_firstBe;
  assign io_memRdOut_payload_lastBe = memRdPkt_lastBe;
  assign io_memRdOut_payload_tc = memRdPkt_tc;
  assign io_memRdOut_payload_attr = memRdPkt_attr;
  assign io_memRdOut_payload_data_0 = memRdPkt_data_0;
  assign io_memRdOut_payload_data_1 = memRdPkt_data_1;
  assign io_memRdOut_payload_data_2 = memRdPkt_data_2;
  assign io_memRdOut_payload_data_3 = memRdPkt_data_3;
  assign io_memRdOut_payload_dataValid = memRdPkt_dataValid;
  assign io_cplIn_ready = 1'b1;
  assign io_h2dDone = statusReg[0];
  assign io_d2hDone = statusReg[0];
  assign io_dmaErr = statusReg[2];
  always @(*) begin
    io_localMem_ar_valid = 1'b0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
        io_localMem_ar_valid = 1'b1;
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_localMem_ar_payload_addr = 32'h00000000;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
        io_localMem_ar_payload_addr = (srcAddrLo + offset);
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  assign io_localMem_ar_payload_id = 4'b0000;
  always @(*) begin
    io_localMem_ar_payload_len = 8'h00;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
      end
      DmaState_D2H_RD_LOCAL : begin
        io_localMem_ar_payload_len = ((d2hChunkDw == 32'h00000000) ? 8'h00 : _zz_io_localMem_ar_payload_len);
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  assign io_localMem_ar_payload_size = 3'b011;
  assign io_localMem_ar_payload_burst = 2'b01;
  assign io_localMem_ar_payload_region = 4'b0000;
  assign io_localMem_ar_payload_lock = 1'b0;
  assign io_localMem_ar_payload_cache = 4'b0000;
  assign io_localMem_ar_payload_qos = 4'b0000;
  assign io_localMem_ar_payload_prot = 3'b000;
  assign io_localMem_r_ready = 1'b1;
  always @(*) begin
    io_localMem_aw_valid = 1'b0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
        io_localMem_aw_valid = 1'b1;
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_localMem_aw_payload_addr = 32'h00000000;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
        io_localMem_aw_payload_addr = h2dWriteAddr;
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  assign io_localMem_aw_payload_id = 4'b0000;
  assign io_localMem_aw_payload_len = 8'h00;
  assign io_localMem_aw_payload_size = 3'b011;
  assign io_localMem_aw_payload_burst = 2'b01;
  assign io_localMem_aw_payload_region = 4'b0000;
  assign io_localMem_aw_payload_lock = 1'b0;
  assign io_localMem_aw_payload_cache = 4'b0000;
  assign io_localMem_aw_payload_qos = 4'b0000;
  assign io_localMem_aw_payload_prot = 3'b000;
  always @(*) begin
    io_localMem_w_valid = 1'b0;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
        io_localMem_w_valid = 1'b1;
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_localMem_w_payload_data = 64'h0000000000000000;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
        io_localMem_w_payload_data = h2dWriteData;
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_localMem_w_payload_strb = 8'h00;
    case(dmaState_1)
      DmaState_IDLE : begin
      end
      DmaState_FETCH_DESC : begin
      end
      DmaState_H2D_RD_REQ : begin
      end
      DmaState_H2D_WAIT_CPL : begin
      end
      DmaState_H2D_WR_LOCAL : begin
        io_localMem_w_payload_strb = h2dWriteStrb;
      end
      DmaState_D2H_RD_LOCAL : begin
      end
      DmaState_D2H_WR_PCIE : begin
      end
      DmaState_NEXT_DESC : begin
      end
      DmaState_DONE : begin
      end
      default : begin
      end
    endcase
  end

  assign io_localMem_w_payload_last = 1'b1;
  assign io_localMem_b_ready = 1'b1;
  assign _zz_descReadData_srcAddr = descIdx[7:0];
  assign _zz_descReadData_srcAddr_1 = _zz_descriptorMem_port0;
  assign descReadData_srcAddr = _zz_descReadData_srcAddr_1[63 : 0];
  assign descReadData_dstAddr = _zz_descReadData_srcAddr_1[127 : 64];
  assign descReadData_length = _zz_descReadData_srcAddr_1[159 : 128];
  assign descReadData_control = _zz_descReadData_srcAddr_1[191 : 160];
  assign descReadData_nextDesc = _zz_descReadData_srcAddr_1[255 : 192];
  assign when_DmaEngine_l314 = (startPulse && (statusReg[1] == 1'b0));
  assign when_DmaEngine_l320 = (16'h0100 < descCount);
  assign _zz_remaining = {2'd0, _zz__zz_remaining};
  assign when_DmaEngine_l333 = (_zz_remaining == 32'h00000000);
  assign when_DmaEngine_l335 = (direction == 1'b0);
  assign when_DmaEngine_l346 = ((descIdx < descCount) && (descIdx < 16'h0100));
  assign _zz_remaining_1 = {2'd0, _zz__zz_remaining_1};
  assign when_DmaEngine_l360 = (_zz_remaining_1 == 32'h00000000);
  assign when_DmaEngine_l362 = (descReadData_control[1] == 1'b0);
  assign io_cplIn_fire = (io_cplIn_valid && io_cplIn_ready);
  assign when_DmaEngine_l393 = ((io_cplIn_fire && (io_cplIn_payload_tag == reqTag)) && waitingCpl);
  assign _zz_totalBytes = {22'd0, io_cplIn_payload_length};
  assign when_DmaEngine_l408 = (cplTimeout == 24'h989680);
  assign when_DmaEngine_l423 = (io_localMem_aw_ready && io_localMem_w_ready);
  assign when_DmaEngine_l424 = (remaining == 32'h00000000);
  assign _zz_remaining_2 = (remaining - d2hChunkDw);
  assign when_DmaEngine_l476 = (_zz_remaining_2 == 32'h00000000);
  assign when_DmaEngine_l496 = (descCount <= _zz_when_DmaEngine_l496);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ctrlReg <= 32'h00000000;
      statusReg <= 32'h00000000;
      srcAddrLo <= 32'h00000000;
      srcAddrHi <= 32'h00000000;
      dstAddrLo <= 32'h00000000;
      dstAddrHi <= 32'h00000000;
      lengthReg <= 32'h00000000;
      descTableLo <= 32'h00000000;
      descTableHi <= 32'h00000000;
      descCount <= 16'h0000;
      descCurrent <= 16'h0000;
      totalBytes <= 32'h00000000;
      rValid <= 1'b0;
      rId <= 4'b0000;
      rData <= 32'h00000000;
      awPending <= 1'b0;
      awAddrReg <= 32'h00000000;
      awIdReg <= 4'b0000;
      wPending <= 1'b0;
      wDataReg <= 32'h00000000;
      bValid <= 1'b0;
      bId <= 4'b0000;
      activeDesc_srcAddr <= 64'h0000000000000000;
      activeDesc_dstAddr <= 64'h0000000000000000;
      activeDesc_length <= 32'h00000000;
      activeDesc_control <= 32'h00000000;
      activeDesc_nextDesc <= 64'h0000000000000000;
      startPrev <= 1'b0;
      dmaState_1 <= DmaState_IDLE;
      remaining <= 32'h00000000;
      offset <= 32'h00000000;
      tagCtr <= 8'h00;
      reqTag <= 8'h00;
      descIdx <= 16'h0000;
      outstandingDw <= 32'h00000000;
      waitingCpl <= 1'b0;
      cplTimeout <= 24'h000000;
      mrrsDw <= 32'h00000080;
      h2dWriteAddr <= 32'h00000000;
      h2dWriteData <= 64'h0000000000000000;
      h2dWriteStrb <= 8'h00;
    end else begin
      if(io_ctrl_ar_fire) begin
        rValid <= 1'b1;
        rId <= io_ctrl_ar_payload_id;
        case(switch_DmaEngine_l111)
          6'h00 : begin
            rData <= ctrlReg;
          end
          6'h01 : begin
            rData <= statusReg;
          end
          6'h02 : begin
            rData <= srcAddrLo;
          end
          6'h03 : begin
            rData <= srcAddrHi;
          end
          6'h04 : begin
            rData <= dstAddrLo;
          end
          6'h05 : begin
            rData <= dstAddrHi;
          end
          6'h06 : begin
            rData <= lengthReg;
          end
          6'h07 : begin
            rData <= descTableLo;
          end
          6'h08 : begin
            rData <= descTableHi;
          end
          6'h09 : begin
            rData <= {16'd0, _zz_rData};
          end
          6'h0a : begin
            rData <= {16'd0, _zz_rData_1};
          end
          6'h0b : begin
            rData <= totalBytes;
          end
          default : begin
            rData <= 32'hffffffff;
          end
        endcase
      end
      if(io_ctrl_r_fire) begin
        rValid <= 1'b0;
      end
      if(io_ctrl_aw_fire) begin
        awPending <= 1'b1;
        awAddrReg <= io_ctrl_aw_payload_addr;
        awIdReg <= io_ctrl_aw_payload_id;
      end
      if(io_ctrl_w_fire) begin
        wPending <= 1'b1;
        wDataReg <= io_ctrl_w_payload_data;
      end
      if(doWrite) begin
        bValid <= 1'b1;
        bId <= awIdReg;
        awPending <= 1'b0;
        wPending <= 1'b0;
        case(switch_DmaEngine_l165)
          6'h00 : begin
            ctrlReg <= wDataReg;
          end
          6'h02 : begin
            srcAddrLo <= wDataReg;
          end
          6'h03 : begin
            srcAddrHi <= wDataReg;
          end
          6'h04 : begin
            dstAddrLo <= wDataReg;
          end
          6'h05 : begin
            dstAddrHi <= wDataReg;
          end
          6'h06 : begin
            lengthReg <= wDataReg;
          end
          6'h07 : begin
            descTableLo <= wDataReg;
          end
          6'h08 : begin
            descTableHi <= wDataReg;
          end
          6'h09 : begin
            descCount <= wDataReg[15 : 0];
          end
          6'h0a : begin
            descCurrent <= wDataReg[15 : 0];
          end
          default : begin
          end
        endcase
      end
      if(io_ctrl_b_fire) begin
        bValid <= 1'b0;
      end
      startPrev <= startBit;
      mrrsDw <= mrrsDw;
      case(dmaState_1)
        DmaState_IDLE : begin
          if(when_DmaEngine_l314) begin
            totalBytes <= 32'h00000000;
            descIdx <= 16'h0000;
            if(sgMode) begin
              if(when_DmaEngine_l320) begin
                statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000004);
                dmaState_1 <= DmaState_ERROR;
              end else begin
                dmaState_1 <= DmaState_FETCH_DESC;
              end
            end else begin
              remaining <= _zz_remaining;
              offset <= 32'h00000000;
              statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000002);
              if(when_DmaEngine_l333) begin
                dmaState_1 <= DmaState_DONE;
              end else begin
                if(when_DmaEngine_l335) begin
                  dmaState_1 <= DmaState_H2D_RD_REQ;
                end else begin
                  dmaState_1 <= DmaState_D2H_RD_LOCAL;
                end
              end
            end
          end
        end
        DmaState_FETCH_DESC : begin
          if(when_DmaEngine_l346) begin
            activeDesc_srcAddr <= descReadData_srcAddr;
            activeDesc_dstAddr <= descReadData_dstAddr;
            activeDesc_length <= descReadData_length;
            activeDesc_control <= descReadData_control;
            activeDesc_nextDesc <= descReadData_nextDesc;
            statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000002);
            remaining <= _zz_remaining_1;
            offset <= 32'h00000000;
            srcAddrLo <= descReadData_srcAddr[31 : 0];
            srcAddrHi <= descReadData_srcAddr[63 : 32];
            dstAddrLo <= descReadData_dstAddr[31 : 0];
            dstAddrHi <= descReadData_dstAddr[63 : 32];
            if(when_DmaEngine_l360) begin
              dmaState_1 <= DmaState_NEXT_DESC;
            end else begin
              if(when_DmaEngine_l362) begin
                dmaState_1 <= DmaState_H2D_RD_REQ;
              end else begin
                dmaState_1 <= DmaState_D2H_RD_LOCAL;
              end
            end
          end else begin
            dmaState_1 <= DmaState_DONE;
          end
        end
        DmaState_H2D_RD_REQ : begin
          if(io_memRdOut_ready) begin
            outstandingDw <= chunkDw;
            reqTag <= tagCtr;
            tagCtr <= (tagCtr + 8'h01);
            waitingCpl <= 1'b1;
            cplTimeout <= 24'h000000;
            dmaState_1 <= DmaState_H2D_WAIT_CPL;
          end
        end
        DmaState_H2D_WAIT_CPL : begin
          cplTimeout <= (cplTimeout + 24'h000001);
          if(when_DmaEngine_l393) begin
            h2dWriteAddr <= (dstAddrLo + offset);
            h2dWriteData <= {io_cplIn_payload_data_1,io_cplIn_payload_data_0};
            h2dWriteStrb <= ((((io_cplIn_payload_dataValid == 3'b000) ? 3'b001 : io_cplIn_payload_dataValid) == 3'b001) ? 8'h0f : 8'hff);
            offset <= (offset + _zz_offset);
            remaining <= (remaining - _zz_totalBytes);
            totalBytes <= (totalBytes + _zz_totalBytes_1);
            waitingCpl <= 1'b0;
            dmaState_1 <= DmaState_H2D_WR_LOCAL;
          end else begin
            if(when_DmaEngine_l408) begin
              statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000004);
              waitingCpl <= 1'b0;
              dmaState_1 <= DmaState_ERROR;
            end
          end
        end
        DmaState_H2D_WR_LOCAL : begin
          if(when_DmaEngine_l423) begin
            if(when_DmaEngine_l424) begin
              if(sgMode) begin
                dmaState_1 <= DmaState_NEXT_DESC;
              end else begin
                dmaState_1 <= DmaState_DONE;
              end
            end else begin
              dmaState_1 <= DmaState_H2D_RD_REQ;
            end
          end
        end
        DmaState_D2H_RD_LOCAL : begin
          if(io_localMem_ar_ready) begin
            dmaState_1 <= DmaState_D2H_WR_PCIE;
          end
        end
        DmaState_D2H_WR_PCIE : begin
          if(io_localMem_r_valid) begin
            if(io_memWrOut_ready) begin
              offset <= (offset + _zz_offset_1);
              remaining <= _zz_remaining_2;
              totalBytes <= (totalBytes + _zz_totalBytes_3);
              if(when_DmaEngine_l476) begin
                if(sgMode) begin
                  dmaState_1 <= DmaState_NEXT_DESC;
                end else begin
                  dmaState_1 <= DmaState_DONE;
                end
              end else begin
                tagCtr <= (tagCtr + 8'h01);
                dmaState_1 <= DmaState_D2H_RD_LOCAL;
              end
            end
          end
        end
        DmaState_NEXT_DESC : begin
          descIdx <= (descIdx + 16'h0001);
          descCurrent <= (descIdx + 16'h0001);
          statusReg[3] <= 1'b1;
          if(when_DmaEngine_l496) begin
            dmaState_1 <= DmaState_DONE;
          end else begin
            dmaState_1 <= DmaState_FETCH_DESC;
          end
        end
        DmaState_DONE : begin
          statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000001);
          dmaState_1 <= DmaState_IDLE;
        end
        default : begin
          statusReg <= ((statusReg & 32'hfffffff8) | 32'h00000004);
          dmaState_1 <= DmaState_IDLE;
        end
      endcase
    end
  end


endmodule

module PcieConfigSpaceCtrl (
  input  wire          io_cfgReq_valid,
  output wire          io_cfgReq_ready,
  input  wire [3:0]    io_cfgReq_payload_tlpType,
  input  wire [15:0]   io_cfgReq_payload_reqId,
  input  wire [7:0]    io_cfgReq_payload_tag,
  input  wire [63:0]   io_cfgReq_payload_addr,
  input  wire [9:0]    io_cfgReq_payload_length,
  input  wire [3:0]    io_cfgReq_payload_firstBe,
  input  wire [3:0]    io_cfgReq_payload_lastBe,
  input  wire [2:0]    io_cfgReq_payload_tc,
  input  wire [1:0]    io_cfgReq_payload_attr,
  input  wire [31:0]   io_cfgReq_payload_data_0,
  input  wire [31:0]   io_cfgReq_payload_data_1,
  input  wire [31:0]   io_cfgReq_payload_data_2,
  input  wire [31:0]   io_cfgReq_payload_data_3,
  input  wire [2:0]    io_cfgReq_payload_dataValid,
  output wire          io_cfgResp_valid,
  input  wire          io_cfgResp_ready,
  output wire [3:0]    io_cfgResp_payload_tlpType,
  output wire [15:0]   io_cfgResp_payload_reqId,
  output wire [7:0]    io_cfgResp_payload_tag,
  output wire [63:0]   io_cfgResp_payload_addr,
  output wire [9:0]    io_cfgResp_payload_length,
  output wire [3:0]    io_cfgResp_payload_firstBe,
  output wire [3:0]    io_cfgResp_payload_lastBe,
  output wire [2:0]    io_cfgResp_payload_tc,
  output wire [1:0]    io_cfgResp_payload_attr,
  output wire [31:0]   io_cfgResp_payload_data_0,
  output wire [31:0]   io_cfgResp_payload_data_1,
  output wire [31:0]   io_cfgResp_payload_data_2,
  output wire [31:0]   io_cfgResp_payload_data_3,
  output wire [2:0]    io_cfgResp_payload_dataValid,
  output reg  [5:0]    io_barHit,
  input  wire [63:0]   io_barCheckAddr,
  input  wire [15:0]   io_busDevFunc,
  output wire [15:0]   io_cfgRegs_vendorId,
  output wire [15:0]   io_cfgRegs_deviceId,
  output wire [15:0]   io_cfgRegs_command,
  output wire [15:0]   io_cfgRegs_status,
  output wire [7:0]    io_cfgRegs_revisionId,
  output wire [23:0]   io_cfgRegs_classCode,
  output wire [7:0]    io_cfgRegs_cacheLineSize,
  output wire [7:0]    io_cfgRegs_latencyTimer,
  output wire [7:0]    io_cfgRegs_headerType,
  output wire [7:0]    io_cfgRegs_bist,
  output wire [31:0]   io_cfgRegs_bar_0,
  output wire [31:0]   io_cfgRegs_bar_1,
  output wire [31:0]   io_cfgRegs_bar_2,
  output wire [31:0]   io_cfgRegs_bar_3,
  output wire [31:0]   io_cfgRegs_bar_4,
  output wire [31:0]   io_cfgRegs_bar_5,
  output wire [15:0]   io_cfgRegs_subVendorId,
  output wire [15:0]   io_cfgRegs_subSystemId,
  output wire [7:0]    io_cfgRegs_capPointer,
  output wire [7:0]    io_cfgRegs_intLine,
  output wire [7:0]    io_cfgRegs_intPin,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  wire       [31:0]   _zz_extConfigMem_port0;
  wire       [9:0]    _zz__zz_respPkt_data_0_8;
  wire       [9:0]    _zz_extConfigMem_port;
  wire       [9:0]    _zz_extConfigMem_port_1;
  reg                 _zz_1;
  reg        [15:0]   regs_vendorIdReg;
  reg        [15:0]   regs_deviceIdReg;
  reg        [15:0]   regs_command;
  reg        [15:0]   regs_status;
  reg        [7:0]    regs_revisionId;
  reg        [23:0]   regs_classCodeReg;
  reg        [7:0]    regs_cacheLineSize;
  reg        [7:0]    regs_latencyTimer;
  reg        [31:0]   regs_bar_0;
  reg        [31:0]   regs_bar_1;
  reg        [31:0]   regs_bar_2;
  reg        [31:0]   regs_bar_3;
  reg        [31:0]   regs_bar_4;
  reg        [31:0]   regs_bar_5;
  wire       [31:0]   regs_barMask_0;
  wire       [31:0]   regs_barMask_1;
  wire       [31:0]   regs_barMask_2;
  wire       [31:0]   regs_barMask_3;
  wire       [31:0]   regs_barMask_4;
  wire       [31:0]   regs_barMask_5;
  reg        [15:0]   regs_subVendorId;
  reg        [15:0]   regs_subSystemId;
  reg        [7:0]    regs_capPointer;
  reg        [7:0]    regs_intLine;
  reg        [7:0]    regs_intPin;
  reg                 regs_barProbe_0;
  reg                 regs_barProbe_1;
  reg                 regs_barProbe_2;
  reg                 regs_barProbe_3;
  reg                 regs_barProbe_4;
  reg                 regs_barProbe_5;
  wire       [7:0]    msixCap_capId;
  reg        [7:0]    msixCap_nextCap;
  reg        [15:0]   msixCap_msgCtrl;
  reg        [2:0]    msixCap_tableBIR;
  reg        [28:0]   msixCap_tableOff;
  reg        [2:0]    msixCap_pbaBIR;
  reg        [28:0]   msixCap_pbaOff;
  wire       [7:0]    pmCap_capId;
  reg        [7:0]    pmCap_nextCap;
  reg        [15:0]   pmCap_pmCapReg;
  reg        [15:0]   pmCap_pmCtrlStat;
  reg        [7:0]    pmCap_pmData;
  reg        [7:0]    pmCap_pmBridgeExt;
  wire       [7:0]    pcieCap_capId;
  reg        [7:0]    pcieCap_nextCap;
  reg        [15:0]   pcieCap_pcieCapReg;
  reg        [31:0]   pcieCap_devCap;
  reg        [15:0]   pcieCap_devCtrl;
  reg        [15:0]   pcieCap_devStat;
  reg        [31:0]   pcieCap_linkCap;
  reg        [15:0]   pcieCap_linkCtrl;
  reg        [15:0]   pcieCap_linkStat;
  wire                memDecodeEn;
  wire       [15:0]   COMMAND_WR_MASK;
  reg                 respValid;
  reg        [3:0]    respPkt_tlpType;
  reg        [15:0]   respPkt_reqId;
  reg        [7:0]    respPkt_tag;
  reg        [63:0]   respPkt_addr;
  reg        [9:0]    respPkt_length;
  reg        [3:0]    respPkt_firstBe;
  reg        [3:0]    respPkt_lastBe;
  reg        [2:0]    respPkt_tc;
  reg        [1:0]    respPkt_attr;
  reg        [31:0]   respPkt_data_0;
  reg        [31:0]   respPkt_data_1;
  reg        [31:0]   respPkt_data_2;
  reg        [31:0]   respPkt_data_3;
  reg        [2:0]    respPkt_dataValid;
  wire                io_cfgResp_fire;
  wire                io_cfgReq_fire;
  wire       [9:0]    switch_ConfigSpaceCtrl_l212;
  reg        [3:0]    _zz_respPkt_tlpType;
  wire       [15:0]   _zz_respPkt_reqId;
  wire       [7:0]    _zz_respPkt_tag;
  reg        [31:0]   _zz_respPkt_data_0;
  reg        [31:0]   _zz_respPkt_data_0_1;
  reg        [31:0]   _zz_respPkt_data_0_2;
  reg        [31:0]   _zz_respPkt_data_0_3;
  reg        [31:0]   _zz_respPkt_data_0_4;
  reg        [31:0]   _zz_respPkt_data_0_5;
  reg        [31:0]   _zz_respPkt_data_0_6;
  reg        [31:0]   _zz_respPkt_data_0_7;
  wire                when_ConfigSpaceCtrl_l253;
  wire       [9:0]    _zz_respPkt_data_0_8;
  reg        [31:0]   _zz_regs_command;
  wire                when_ConfigSpaceCtrl_l184;
  wire                when_ConfigSpaceCtrl_l184_1;
  wire                when_ConfigSpaceCtrl_l184_2;
  wire                when_ConfigSpaceCtrl_l184_3;
  wire                when_ConfigSpaceCtrl_l325;
  reg        [31:0]   _zz_regs_bar_0;
  wire                when_ConfigSpaceCtrl_l184_4;
  wire                when_ConfigSpaceCtrl_l184_5;
  wire                when_ConfigSpaceCtrl_l184_6;
  wire                when_ConfigSpaceCtrl_l184_7;
  wire                when_ConfigSpaceCtrl_l335;
  reg        [31:0]   _zz_regs_bar_1;
  wire                when_ConfigSpaceCtrl_l184_8;
  wire                when_ConfigSpaceCtrl_l184_9;
  wire                when_ConfigSpaceCtrl_l184_10;
  wire                when_ConfigSpaceCtrl_l184_11;
  wire                when_ConfigSpaceCtrl_l362;
  `ifndef SYNTHESIS
  reg [55:0] io_cfgReq_payload_tlpType_string;
  reg [55:0] io_cfgResp_payload_tlpType_string;
  reg [55:0] respPkt_tlpType_string;
  reg [55:0] _zz_respPkt_tlpType_string;
  `endif

  (* ram_style = "distributed" *) reg [31:0] extConfigMem [0:959];

  assign _zz__zz_respPkt_data_0_8 = (switch_ConfigSpaceCtrl_l212 - 10'h040);
  assign _zz_extConfigMem_port_1 = (switch_ConfigSpaceCtrl_l212 - 10'h040);
  assign _zz_extConfigMem_port = _zz_extConfigMem_port_1;
  assign _zz_extConfigMem_port0 = extConfigMem[_zz_respPkt_data_0_8];
  always @(posedge clk) begin
    if(_zz_1) begin
      extConfigMem[_zz_extConfigMem_port] <= io_cfgReq_payload_data_0;
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_cfgReq_payload_tlpType)
      TlpType_MEM_RD : io_cfgReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cfgReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cfgReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cfgReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cfgReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cfgReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cfgReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cfgReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cfgReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cfgReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cfgReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cfgReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cfgReq_payload_tlpType_string = "INVALID";
      default : io_cfgReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cfgResp_payload_tlpType)
      TlpType_MEM_RD : io_cfgResp_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cfgResp_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cfgResp_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cfgResp_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cfgResp_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cfgResp_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cfgResp_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cfgResp_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cfgResp_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cfgResp_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cfgResp_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cfgResp_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cfgResp_payload_tlpType_string = "INVALID";
      default : io_cfgResp_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(respPkt_tlpType)
      TlpType_MEM_RD : respPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : respPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : respPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : respPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : respPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : respPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : respPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : respPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : respPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : respPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : respPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : respPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : respPkt_tlpType_string = "INVALID";
      default : respPkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_respPkt_tlpType)
      TlpType_MEM_RD : _zz_respPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_respPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : _zz_respPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : _zz_respPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_respPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_respPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_respPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_respPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : _zz_respPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : _zz_respPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : _zz_respPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : _zz_respPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : _zz_respPkt_tlpType_string = "INVALID";
      default : _zz_respPkt_tlpType_string = "???????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    if(io_cfgReq_fire) begin
      case(io_cfgReq_payload_tlpType)
        TlpType_CFG_RD0, TlpType_CFG_RD1 : begin
        end
        TlpType_CFG_WR0, TlpType_CFG_WR1 : begin
          case(switch_ConfigSpaceCtrl_l212)
            10'h001 : begin
            end
            10'h003 : begin
            end
            10'h004 : begin
            end
            10'h005 : begin
            end
            10'h00f : begin
            end
            10'h011 : begin
            end
            10'h012 : begin
            end
            10'h013 : begin
            end
            10'h01b : begin
            end
            10'h01d : begin
            end
            default : begin
              if(when_ConfigSpaceCtrl_l362) begin
                _zz_1 = 1'b1;
              end
            end
          endcase
        end
        default : begin
        end
      endcase
    end
  end

  assign regs_barMask_0 = 32'hfffff000;
  assign regs_barMask_1 = 32'hffff0000;
  assign regs_barMask_2 = 32'h00000000;
  assign regs_barMask_3 = 32'h00000000;
  assign regs_barMask_4 = 32'h00000000;
  assign regs_barMask_5 = 32'h00000000;
  assign msixCap_capId = 8'h11;
  assign pmCap_capId = 8'h01;
  assign pcieCap_capId = 8'h10;
  assign io_cfgRegs_vendorId = regs_vendorIdReg;
  assign io_cfgRegs_deviceId = regs_deviceIdReg;
  assign io_cfgRegs_command = regs_command;
  assign io_cfgRegs_status = regs_status;
  assign io_cfgRegs_revisionId = regs_revisionId;
  assign io_cfgRegs_classCode = regs_classCodeReg;
  assign io_cfgRegs_cacheLineSize = regs_cacheLineSize;
  assign io_cfgRegs_latencyTimer = regs_latencyTimer;
  assign io_cfgRegs_headerType = 8'h00;
  assign io_cfgRegs_bist = 8'h00;
  assign io_cfgRegs_bar_0 = regs_bar_0;
  assign io_cfgRegs_bar_1 = regs_bar_1;
  assign io_cfgRegs_bar_2 = regs_bar_2;
  assign io_cfgRegs_bar_3 = regs_bar_3;
  assign io_cfgRegs_bar_4 = regs_bar_4;
  assign io_cfgRegs_bar_5 = regs_bar_5;
  assign io_cfgRegs_subVendorId = regs_subVendorId;
  assign io_cfgRegs_subSystemId = regs_subSystemId;
  assign io_cfgRegs_capPointer = regs_capPointer;
  assign io_cfgRegs_intLine = regs_intLine;
  assign io_cfgRegs_intPin = regs_intPin;
  assign memDecodeEn = regs_command[1];
  always @(*) begin
    io_barHit[0] = ((memDecodeEn && (regs_barMask_0 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_0) == (regs_bar_0 & regs_barMask_0)));
    io_barHit[1] = ((memDecodeEn && (regs_barMask_1 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_1) == (regs_bar_1 & regs_barMask_1)));
    io_barHit[2] = ((memDecodeEn && (regs_barMask_2 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_2) == (regs_bar_2 & regs_barMask_2)));
    io_barHit[3] = ((memDecodeEn && (regs_barMask_3 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_3) == (regs_bar_3 & regs_barMask_3)));
    io_barHit[4] = ((memDecodeEn && (regs_barMask_4 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_4) == (regs_bar_4 & regs_barMask_4)));
    io_barHit[5] = ((memDecodeEn && (regs_barMask_5 != 32'h00000000)) && ((io_barCheckAddr[31 : 0] & regs_barMask_5) == (regs_bar_5 & regs_barMask_5)));
  end

  assign COMMAND_WR_MASK = 16'h0447;
  assign io_cfgResp_valid = respValid;
  assign io_cfgResp_payload_tlpType = respPkt_tlpType;
  assign io_cfgResp_payload_reqId = respPkt_reqId;
  assign io_cfgResp_payload_tag = respPkt_tag;
  assign io_cfgResp_payload_addr = respPkt_addr;
  assign io_cfgResp_payload_length = respPkt_length;
  assign io_cfgResp_payload_firstBe = respPkt_firstBe;
  assign io_cfgResp_payload_lastBe = respPkt_lastBe;
  assign io_cfgResp_payload_tc = respPkt_tc;
  assign io_cfgResp_payload_attr = respPkt_attr;
  assign io_cfgResp_payload_data_0 = respPkt_data_0;
  assign io_cfgResp_payload_data_1 = respPkt_data_1;
  assign io_cfgResp_payload_data_2 = respPkt_data_2;
  assign io_cfgResp_payload_data_3 = respPkt_data_3;
  assign io_cfgResp_payload_dataValid = respPkt_dataValid;
  assign io_cfgReq_ready = (! respValid);
  assign io_cfgResp_fire = (io_cfgResp_valid && io_cfgResp_ready);
  assign io_cfgReq_fire = (io_cfgReq_valid && io_cfgReq_ready);
  assign switch_ConfigSpaceCtrl_l212 = io_cfgReq_payload_addr[11 : 2];
  always @(*) begin
    _zz_respPkt_tlpType = TlpType_CPL;
    case(io_cfgReq_payload_tlpType)
      TlpType_CFG_RD0, TlpType_CFG_RD1 : begin
        _zz_respPkt_tlpType = TlpType_CPL_D;
      end
      TlpType_CFG_WR0, TlpType_CFG_WR1 : begin
        _zz_respPkt_tlpType = TlpType_CPL;
      end
      default : begin
      end
    endcase
  end

  assign _zz_respPkt_reqId = io_cfgReq_payload_reqId;
  assign _zz_respPkt_tag = io_cfgReq_payload_tag;
  always @(*) begin
    _zz_respPkt_data_0 = 32'h00000000;
    case(io_cfgReq_payload_tlpType)
      TlpType_CFG_RD0, TlpType_CFG_RD1 : begin
        _zz_respPkt_data_0 = _zz_respPkt_data_0_1;
      end
      TlpType_CFG_WR0, TlpType_CFG_WR1 : begin
        _zz_respPkt_data_0 = 32'h00000000;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    case(switch_ConfigSpaceCtrl_l212)
      10'h000 : begin
        _zz_respPkt_data_0_1 = {regs_deviceIdReg,regs_vendorIdReg};
      end
      10'h001 : begin
        _zz_respPkt_data_0_1 = {regs_status,regs_command};
      end
      10'h002 : begin
        _zz_respPkt_data_0_1 = {regs_classCodeReg,regs_revisionId};
      end
      10'h003 : begin
        _zz_respPkt_data_0_1 = {{{8'h00,8'h00},regs_latencyTimer},regs_cacheLineSize};
      end
      10'h004 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_2;
      end
      10'h005 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_3;
      end
      10'h006 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_4;
      end
      10'h007 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_5;
      end
      10'h008 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_6;
      end
      10'h009 : begin
        _zz_respPkt_data_0_1 = _zz_respPkt_data_0_7;
      end
      10'h00a : begin
        _zz_respPkt_data_0_1 = 32'h00000000;
      end
      10'h00b : begin
        _zz_respPkt_data_0_1 = {regs_subSystemId,regs_subVendorId};
      end
      10'h00c : begin
        _zz_respPkt_data_0_1 = 32'h00000000;
      end
      10'h00d : begin
        _zz_respPkt_data_0_1 = {24'h000000,regs_capPointer};
      end
      10'h00e : begin
        _zz_respPkt_data_0_1 = 32'h00000000;
      end
      10'h00f : begin
        _zz_respPkt_data_0_1 = {{{8'h00,regs_intPin},8'h00},regs_intLine};
      end
      10'h010 : begin
        _zz_respPkt_data_0_1 = {{16'h0000,msixCap_nextCap},msixCap_capId};
      end
      10'h011 : begin
        _zz_respPkt_data_0_1 = {msixCap_msgCtrl,16'h0000};
      end
      10'h012 : begin
        _zz_respPkt_data_0_1 = {msixCap_tableOff,msixCap_tableBIR};
      end
      10'h013 : begin
        _zz_respPkt_data_0_1 = {msixCap_pbaOff,msixCap_pbaBIR};
      end
      10'h014 : begin
        _zz_respPkt_data_0_1 = {{16'h0000,pmCap_nextCap},pmCap_capId};
      end
      10'h015 : begin
        _zz_respPkt_data_0_1 = {pmCap_pmCapReg,16'h0000};
      end
      10'h016 : begin
        _zz_respPkt_data_0_1 = {{pmCap_pmData,pmCap_pmBridgeExt},pmCap_pmCtrlStat};
      end
      10'h018 : begin
        _zz_respPkt_data_0_1 = {{16'h0000,pcieCap_nextCap},pcieCap_capId};
      end
      10'h019 : begin
        _zz_respPkt_data_0_1 = {pcieCap_pcieCapReg,16'h0000};
      end
      10'h01a : begin
        _zz_respPkt_data_0_1 = pcieCap_devCap;
      end
      10'h01b : begin
        _zz_respPkt_data_0_1 = {pcieCap_devStat,pcieCap_devCtrl};
      end
      10'h01c : begin
        _zz_respPkt_data_0_1 = pcieCap_linkCap;
      end
      10'h01d : begin
        _zz_respPkt_data_0_1 = {pcieCap_linkStat,pcieCap_linkCtrl};
      end
      default : begin
        if(when_ConfigSpaceCtrl_l253) begin
          _zz_respPkt_data_0_1 = _zz_extConfigMem_port0;
        end else begin
          _zz_respPkt_data_0_1 = 32'h00000000;
        end
      end
    endcase
  end

  always @(*) begin
    _zz_respPkt_data_0_2 = regs_bar_0;
    if(regs_barProbe_0) begin
      _zz_respPkt_data_0_2 = regs_barMask_0;
    end
  end

  always @(*) begin
    _zz_respPkt_data_0_3 = regs_bar_1;
    if(regs_barProbe_1) begin
      _zz_respPkt_data_0_3 = regs_barMask_1;
    end
  end

  always @(*) begin
    _zz_respPkt_data_0_4 = regs_bar_2;
    if(regs_barProbe_2) begin
      _zz_respPkt_data_0_4 = regs_barMask_2;
    end
  end

  always @(*) begin
    _zz_respPkt_data_0_5 = regs_bar_3;
    if(regs_barProbe_3) begin
      _zz_respPkt_data_0_5 = regs_barMask_3;
    end
  end

  always @(*) begin
    _zz_respPkt_data_0_6 = regs_bar_4;
    if(regs_barProbe_4) begin
      _zz_respPkt_data_0_6 = regs_barMask_4;
    end
  end

  always @(*) begin
    _zz_respPkt_data_0_7 = regs_bar_5;
    if(regs_barProbe_5) begin
      _zz_respPkt_data_0_7 = regs_barMask_5;
    end
  end

  assign when_ConfigSpaceCtrl_l253 = (10'h040 <= switch_ConfigSpaceCtrl_l212);
  assign _zz_respPkt_data_0_8 = _zz__zz_respPkt_data_0_8;
  always @(*) begin
    _zz_regs_command = {regs_status,regs_command};
    if(when_ConfigSpaceCtrl_l184) begin
      _zz_regs_command[7 : 0] = io_cfgReq_payload_data_0[7 : 0];
    end
    if(when_ConfigSpaceCtrl_l184_1) begin
      _zz_regs_command[15 : 8] = io_cfgReq_payload_data_0[15 : 8];
    end
    if(when_ConfigSpaceCtrl_l184_2) begin
      _zz_regs_command[23 : 16] = io_cfgReq_payload_data_0[23 : 16];
    end
    if(when_ConfigSpaceCtrl_l184_3) begin
      _zz_regs_command[31 : 24] = io_cfgReq_payload_data_0[31 : 24];
    end
  end

  assign when_ConfigSpaceCtrl_l184 = io_cfgReq_payload_firstBe[0];
  assign when_ConfigSpaceCtrl_l184_1 = io_cfgReq_payload_firstBe[1];
  assign when_ConfigSpaceCtrl_l184_2 = io_cfgReq_payload_firstBe[2];
  assign when_ConfigSpaceCtrl_l184_3 = io_cfgReq_payload_firstBe[3];
  assign when_ConfigSpaceCtrl_l325 = ((io_cfgReq_payload_firstBe == 4'b1111) && (io_cfgReq_payload_data_0 == 32'hffffffff));
  always @(*) begin
    _zz_regs_bar_0 = regs_bar_0;
    if(when_ConfigSpaceCtrl_l184_4) begin
      _zz_regs_bar_0[7 : 0] = io_cfgReq_payload_data_0[7 : 0];
    end
    if(when_ConfigSpaceCtrl_l184_5) begin
      _zz_regs_bar_0[15 : 8] = io_cfgReq_payload_data_0[15 : 8];
    end
    if(when_ConfigSpaceCtrl_l184_6) begin
      _zz_regs_bar_0[23 : 16] = io_cfgReq_payload_data_0[23 : 16];
    end
    if(when_ConfigSpaceCtrl_l184_7) begin
      _zz_regs_bar_0[31 : 24] = io_cfgReq_payload_data_0[31 : 24];
    end
  end

  assign when_ConfigSpaceCtrl_l184_4 = io_cfgReq_payload_firstBe[0];
  assign when_ConfigSpaceCtrl_l184_5 = io_cfgReq_payload_firstBe[1];
  assign when_ConfigSpaceCtrl_l184_6 = io_cfgReq_payload_firstBe[2];
  assign when_ConfigSpaceCtrl_l184_7 = io_cfgReq_payload_firstBe[3];
  assign when_ConfigSpaceCtrl_l335 = ((io_cfgReq_payload_firstBe == 4'b1111) && (io_cfgReq_payload_data_0 == 32'hffffffff));
  always @(*) begin
    _zz_regs_bar_1 = regs_bar_1;
    if(when_ConfigSpaceCtrl_l184_8) begin
      _zz_regs_bar_1[7 : 0] = io_cfgReq_payload_data_0[7 : 0];
    end
    if(when_ConfigSpaceCtrl_l184_9) begin
      _zz_regs_bar_1[15 : 8] = io_cfgReq_payload_data_0[15 : 8];
    end
    if(when_ConfigSpaceCtrl_l184_10) begin
      _zz_regs_bar_1[23 : 16] = io_cfgReq_payload_data_0[23 : 16];
    end
    if(when_ConfigSpaceCtrl_l184_11) begin
      _zz_regs_bar_1[31 : 24] = io_cfgReq_payload_data_0[31 : 24];
    end
  end

  assign when_ConfigSpaceCtrl_l184_8 = io_cfgReq_payload_firstBe[0];
  assign when_ConfigSpaceCtrl_l184_9 = io_cfgReq_payload_firstBe[1];
  assign when_ConfigSpaceCtrl_l184_10 = io_cfgReq_payload_firstBe[2];
  assign when_ConfigSpaceCtrl_l184_11 = io_cfgReq_payload_firstBe[3];
  assign when_ConfigSpaceCtrl_l362 = (10'h040 <= switch_ConfigSpaceCtrl_l212);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      regs_vendorIdReg <= 16'h10ee;
      regs_deviceIdReg <= 16'h7021;
      regs_command <= 16'h0000;
      regs_status <= 16'h0010;
      regs_revisionId <= 8'h01;
      regs_classCodeReg <= 24'h020000;
      regs_cacheLineSize <= 8'h00;
      regs_latencyTimer <= 8'h00;
      regs_bar_0 <= 32'h00000000;
      regs_bar_1 <= 32'h00000000;
      regs_bar_2 <= 32'h00000000;
      regs_bar_3 <= 32'h00000000;
      regs_bar_4 <= 32'h00000000;
      regs_bar_5 <= 32'h00000000;
      regs_subVendorId <= 16'h10ee;
      regs_subSystemId <= 16'h0001;
      regs_capPointer <= 8'h40;
      regs_intLine <= 8'hff;
      regs_intPin <= 8'h01;
      regs_barProbe_0 <= 1'b0;
      regs_barProbe_1 <= 1'b0;
      regs_barProbe_2 <= 1'b0;
      regs_barProbe_3 <= 1'b0;
      regs_barProbe_4 <= 1'b0;
      regs_barProbe_5 <= 1'b0;
      msixCap_nextCap <= 8'h50;
      msixCap_msgCtrl <= 16'h0020;
      msixCap_tableBIR <= 3'b001;
      msixCap_tableOff <= 29'h00000000;
      msixCap_pbaBIR <= 3'b001;
      msixCap_pbaOff <= 29'h00001000;
      pmCap_nextCap <= 8'h60;
      pmCap_pmCapReg <= 16'h0002;
      pmCap_pmCtrlStat <= 16'h0000;
      pmCap_pmData <= 8'h00;
      pmCap_pmBridgeExt <= 8'h00;
      pcieCap_nextCap <= 8'h00;
      pcieCap_pcieCapReg <= 16'h0142;
      pcieCap_devCap <= 32'h00000029;
      pcieCap_devCtrl <= 16'h0000;
      pcieCap_devStat <= 16'h0000;
      pcieCap_linkCap <= 32'h00012412;
      pcieCap_linkCtrl <= 16'h0000;
      pcieCap_linkStat <= 16'h0012;
      respValid <= 1'b0;
    end else begin
      regs_vendorIdReg <= regs_vendorIdReg;
      regs_deviceIdReg <= regs_deviceIdReg;
      regs_revisionId <= regs_revisionId;
      regs_classCodeReg <= regs_classCodeReg;
      regs_latencyTimer <= regs_latencyTimer;
      regs_bar_2 <= regs_bar_2;
      regs_bar_3 <= regs_bar_3;
      regs_bar_4 <= regs_bar_4;
      regs_bar_5 <= regs_bar_5;
      regs_subVendorId <= regs_subVendorId;
      regs_subSystemId <= regs_subSystemId;
      regs_capPointer <= regs_capPointer;
      regs_intLine <= regs_intLine;
      regs_intPin <= regs_intPin;
      regs_barProbe_0 <= regs_barProbe_0;
      regs_barProbe_1 <= regs_barProbe_1;
      regs_barProbe_2 <= regs_barProbe_2;
      regs_barProbe_3 <= regs_barProbe_3;
      regs_barProbe_4 <= regs_barProbe_4;
      regs_barProbe_5 <= regs_barProbe_5;
      msixCap_nextCap <= msixCap_nextCap;
      msixCap_msgCtrl <= msixCap_msgCtrl;
      msixCap_tableBIR <= msixCap_tableBIR;
      msixCap_tableOff <= msixCap_tableOff;
      msixCap_pbaBIR <= msixCap_pbaBIR;
      msixCap_pbaOff <= msixCap_pbaOff;
      pmCap_nextCap <= pmCap_nextCap;
      pmCap_pmCapReg <= pmCap_pmCapReg;
      pmCap_pmCtrlStat <= pmCap_pmCtrlStat;
      pmCap_pmData <= pmCap_pmData;
      pmCap_pmBridgeExt <= pmCap_pmBridgeExt;
      pcieCap_nextCap <= pcieCap_nextCap;
      pcieCap_pcieCapReg <= pcieCap_pcieCapReg;
      pcieCap_devCap <= pcieCap_devCap;
      pcieCap_devCtrl <= pcieCap_devCtrl;
      pcieCap_devStat <= pcieCap_devStat;
      pcieCap_linkCap <= pcieCap_linkCap;
      pcieCap_linkCtrl <= pcieCap_linkCtrl;
      pcieCap_linkStat <= pcieCap_linkStat;
      if(io_cfgResp_fire) begin
        respValid <= 1'b0;
      end
      if(io_cfgReq_fire) begin
        case(io_cfgReq_payload_tlpType)
          TlpType_CFG_RD0, TlpType_CFG_RD1 : begin
            respValid <= 1'b1;
          end
          TlpType_CFG_WR0, TlpType_CFG_WR1 : begin
            respValid <= 1'b1;
            case(switch_ConfigSpaceCtrl_l212)
              10'h001 : begin
                regs_command <= (_zz_regs_command[15 : 0] & COMMAND_WR_MASK);
                regs_status <= ((regs_status & (~ _zz_regs_command[31 : 16])) | 16'h0010);
              end
              10'h003 : begin
                regs_cacheLineSize <= io_cfgReq_payload_data_0[7 : 0];
              end
              10'h004 : begin
                if(when_ConfigSpaceCtrl_l325) begin
                  regs_barProbe_0 <= 1'b1;
                end else begin
                  regs_barProbe_0 <= 1'b0;
                  regs_bar_0 <= (_zz_regs_bar_0 & regs_barMask_0);
                end
              end
              10'h005 : begin
                if(when_ConfigSpaceCtrl_l335) begin
                  regs_barProbe_1 <= 1'b1;
                end else begin
                  regs_barProbe_1 <= 1'b0;
                  regs_bar_1 <= (_zz_regs_bar_1 & regs_barMask_1);
                end
              end
              10'h00f : begin
                regs_intLine <= io_cfgReq_payload_data_0[7 : 0];
                regs_intPin <= io_cfgReq_payload_data_0[15 : 8];
              end
              10'h011 : begin
                msixCap_msgCtrl <= io_cfgReq_payload_data_0[15 : 0];
              end
              10'h012 : begin
                msixCap_tableOff <= io_cfgReq_payload_data_0[31 : 3];
                msixCap_tableBIR <= io_cfgReq_payload_data_0[2 : 0];
              end
              10'h013 : begin
                msixCap_pbaOff <= io_cfgReq_payload_data_0[31 : 3];
                msixCap_pbaBIR <= io_cfgReq_payload_data_0[2 : 0];
              end
              10'h01b : begin
                pcieCap_devCtrl <= io_cfgReq_payload_data_0[15 : 0];
              end
              10'h01d : begin
                pcieCap_linkCtrl <= io_cfgReq_payload_data_0[15 : 0];
              end
              default : begin
              end
            endcase
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(posedge clk) begin
    if(io_cfgReq_fire) begin
      case(io_cfgReq_payload_tlpType)
        TlpType_CFG_RD0, TlpType_CFG_RD1 : begin
          respPkt_tlpType <= _zz_respPkt_tlpType;
          respPkt_reqId <= _zz_respPkt_reqId;
          respPkt_tag <= _zz_respPkt_tag;
          respPkt_addr <= 64'h0000000000000000;
          respPkt_length <= 10'h001;
          respPkt_firstBe <= 4'b1111;
          respPkt_lastBe <= 4'b0000;
          respPkt_tc <= 3'b000;
          respPkt_attr <= 2'b00;
          respPkt_data_0 <= _zz_respPkt_data_0;
          respPkt_data_1 <= 32'h00000000;
          respPkt_data_2 <= 32'h00000000;
          respPkt_data_3 <= 32'h00000000;
          respPkt_dataValid <= 3'b001;
        end
        TlpType_CFG_WR0, TlpType_CFG_WR1 : begin
          respPkt_tlpType <= _zz_respPkt_tlpType;
          respPkt_reqId <= _zz_respPkt_reqId;
          respPkt_tag <= _zz_respPkt_tag;
          respPkt_addr <= 64'h0000000000000000;
          respPkt_length <= 10'h001;
          respPkt_firstBe <= 4'b1111;
          respPkt_lastBe <= 4'b0000;
          respPkt_tc <= 3'b000;
          respPkt_attr <= 2'b00;
          respPkt_data_0 <= _zz_respPkt_data_0;
          respPkt_data_1 <= 32'h00000000;
          respPkt_data_2 <= 32'h00000000;
          respPkt_data_3 <= 32'h00000000;
          respPkt_dataValid <= 3'b001;
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module IoRequestHandler (
  input  wire          io_ioReq_valid,
  output wire          io_ioReq_ready,
  input  wire [3:0]    io_ioReq_payload_tlpType,
  input  wire [15:0]   io_ioReq_payload_reqId,
  input  wire [7:0]    io_ioReq_payload_tag,
  input  wire [63:0]   io_ioReq_payload_addr,
  input  wire [9:0]    io_ioReq_payload_length,
  input  wire [3:0]    io_ioReq_payload_firstBe,
  input  wire [3:0]    io_ioReq_payload_lastBe,
  input  wire [2:0]    io_ioReq_payload_tc,
  input  wire [1:0]    io_ioReq_payload_attr,
  input  wire [31:0]   io_ioReq_payload_data_0,
  input  wire [31:0]   io_ioReq_payload_data_1,
  input  wire [31:0]   io_ioReq_payload_data_2,
  input  wire [31:0]   io_ioReq_payload_data_3,
  input  wire [2:0]    io_ioReq_payload_dataValid,
  output reg           io_cplOut_valid,
  input  wire          io_cplOut_ready,
  output wire [3:0]    io_cplOut_payload_tlpType,
  output wire [15:0]   io_cplOut_payload_reqId,
  output wire [7:0]    io_cplOut_payload_tag,
  output wire [63:0]   io_cplOut_payload_addr,
  output wire [9:0]    io_cplOut_payload_length,
  output wire [3:0]    io_cplOut_payload_firstBe,
  output wire [3:0]    io_cplOut_payload_lastBe,
  output wire [2:0]    io_cplOut_payload_tc,
  output wire [1:0]    io_cplOut_payload_attr,
  output wire [31:0]   io_cplOut_payload_data_0,
  output wire [31:0]   io_cplOut_payload_data_1,
  output wire [31:0]   io_cplOut_payload_data_2,
  output wire [31:0]   io_cplOut_payload_data_3,
  output wire [2:0]    io_cplOut_payload_dataValid,
  output reg  [31:0]   io_regAddr,
  output reg  [31:0]   io_regWrData,
  input  wire [31:0]   io_regRdData,
  output reg           io_regWrEn,
  output reg           io_regRdEn,
  input  wire [1:0]    io_regWidth,
  output reg           io_ioErr,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;
  localparam IoState_IDLE = 2'd0;
  localparam IoState_PROCESS_1 = 2'd1;
  localparam IoState_RESPOND = 2'd2;

  reg        [1:0]    state;
  reg        [3:0]    reqPkt_tlpType;
  reg        [15:0]   reqPkt_reqId;
  reg        [7:0]    reqPkt_tag;
  reg        [63:0]   reqPkt_addr;
  reg        [9:0]    reqPkt_length;
  reg        [3:0]    reqPkt_firstBe;
  reg        [3:0]    reqPkt_lastBe;
  reg        [2:0]    reqPkt_tc;
  reg        [1:0]    reqPkt_attr;
  reg        [31:0]   reqPkt_data_0;
  reg        [31:0]   reqPkt_data_1;
  reg        [31:0]   reqPkt_data_2;
  reg        [31:0]   reqPkt_data_3;
  reg        [2:0]    reqPkt_dataValid;
  reg        [3:0]    respPkt_tlpType;
  reg        [15:0]   respPkt_reqId;
  reg        [7:0]    respPkt_tag;
  reg        [63:0]   respPkt_addr;
  reg        [9:0]    respPkt_length;
  reg        [3:0]    respPkt_firstBe;
  reg        [3:0]    respPkt_lastBe;
  reg        [2:0]    respPkt_tc;
  reg        [1:0]    respPkt_attr;
  reg        [31:0]   respPkt_data_0;
  reg        [31:0]   respPkt_data_1;
  reg        [31:0]   respPkt_data_2;
  reg        [31:0]   respPkt_data_3;
  reg        [2:0]    respPkt_dataValid;
  wire                io_ioReq_fire;
  wire                when_TlpRxEngine_l375;
  wire                when_TlpRxEngine_l383;
  `ifndef SYNTHESIS
  reg [55:0] io_ioReq_payload_tlpType_string;
  reg [55:0] io_cplOut_payload_tlpType_string;
  reg [71:0] state_string;
  reg [55:0] reqPkt_tlpType_string;
  reg [55:0] respPkt_tlpType_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(io_ioReq_payload_tlpType)
      TlpType_MEM_RD : io_ioReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_ioReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_ioReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_ioReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_ioReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_ioReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_ioReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_ioReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_ioReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_ioReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_ioReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_ioReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_ioReq_payload_tlpType_string = "INVALID";
      default : io_ioReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cplOut_payload_tlpType)
      TlpType_MEM_RD : io_cplOut_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cplOut_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cplOut_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cplOut_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cplOut_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cplOut_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cplOut_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cplOut_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cplOut_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cplOut_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cplOut_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cplOut_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cplOut_payload_tlpType_string = "INVALID";
      default : io_cplOut_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(state)
      IoState_IDLE : state_string = "IDLE     ";
      IoState_PROCESS_1 : state_string = "PROCESS_1";
      IoState_RESPOND : state_string = "RESPOND  ";
      default : state_string = "?????????";
    endcase
  end
  always @(*) begin
    case(reqPkt_tlpType)
      TlpType_MEM_RD : reqPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : reqPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : reqPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : reqPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : reqPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : reqPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : reqPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : reqPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : reqPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : reqPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : reqPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : reqPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : reqPkt_tlpType_string = "INVALID";
      default : reqPkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(respPkt_tlpType)
      TlpType_MEM_RD : respPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : respPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : respPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : respPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : respPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : respPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : respPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : respPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : respPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : respPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : respPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : respPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : respPkt_tlpType_string = "INVALID";
      default : respPkt_tlpType_string = "???????";
    endcase
  end
  `endif

  always @(*) begin
    io_regAddr = 32'h00000000;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
        io_regAddr = reqPkt_addr[31 : 0];
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_regWrData = 32'h00000000;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
        if(!when_TlpRxEngine_l375) begin
          if(when_TlpRxEngine_l383) begin
            io_regWrData = reqPkt_data_0;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_regWrEn = 1'b0;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
        if(!when_TlpRxEngine_l375) begin
          if(when_TlpRxEngine_l383) begin
            io_regWrEn = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_regRdEn = 1'b0;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
        if(when_TlpRxEngine_l375) begin
          io_regRdEn = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ioErr = 1'b0;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
        if(!when_TlpRxEngine_l375) begin
          if(!when_TlpRxEngine_l383) begin
            io_ioErr = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cplOut_valid = 1'b0;
    case(state)
      IoState_IDLE : begin
      end
      IoState_PROCESS_1 : begin
      end
      default : begin
        io_cplOut_valid = 1'b1;
      end
    endcase
  end

  assign io_cplOut_payload_tlpType = respPkt_tlpType;
  assign io_cplOut_payload_reqId = respPkt_reqId;
  assign io_cplOut_payload_tag = respPkt_tag;
  assign io_cplOut_payload_addr = respPkt_addr;
  assign io_cplOut_payload_length = respPkt_length;
  assign io_cplOut_payload_firstBe = respPkt_firstBe;
  assign io_cplOut_payload_lastBe = respPkt_lastBe;
  assign io_cplOut_payload_tc = respPkt_tc;
  assign io_cplOut_payload_attr = respPkt_attr;
  assign io_cplOut_payload_data_0 = respPkt_data_0;
  assign io_cplOut_payload_data_1 = respPkt_data_1;
  assign io_cplOut_payload_data_2 = respPkt_data_2;
  assign io_cplOut_payload_data_3 = respPkt_data_3;
  assign io_cplOut_payload_dataValid = respPkt_dataValid;
  assign io_ioReq_ready = (state == IoState_IDLE);
  assign io_ioReq_fire = (io_ioReq_valid && io_ioReq_ready);
  assign when_TlpRxEngine_l375 = (reqPkt_tlpType == TlpType_IO_RD);
  assign when_TlpRxEngine_l383 = (reqPkt_tlpType == TlpType_IO_WR);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= IoState_IDLE;
    end else begin
      case(state)
        IoState_IDLE : begin
          if(io_ioReq_fire) begin
            state <= IoState_PROCESS_1;
          end
        end
        IoState_PROCESS_1 : begin
          if(when_TlpRxEngine_l375) begin
            state <= IoState_RESPOND;
          end else begin
            if(when_TlpRxEngine_l383) begin
              state <= IoState_RESPOND;
            end else begin
              state <= IoState_RESPOND;
            end
          end
        end
        default : begin
          if(io_cplOut_ready) begin
            state <= IoState_IDLE;
          end
        end
      endcase
    end
  end

  always @(posedge clk) begin
    respPkt_tlpType <= TlpType_CPL;
    respPkt_reqId <= 16'h0000;
    respPkt_tag <= 8'h00;
    respPkt_addr <= 64'h0000000000000000;
    respPkt_length <= 10'h000;
    respPkt_firstBe <= 4'b0000;
    respPkt_lastBe <= 4'b0000;
    respPkt_tc <= 3'b000;
    respPkt_attr <= 2'b00;
    respPkt_data_0 <= 32'h00000000;
    respPkt_data_1 <= 32'h00000000;
    respPkt_data_2 <= 32'h00000000;
    respPkt_data_3 <= 32'h00000000;
    respPkt_dataValid <= 3'b000;
    case(state)
      IoState_IDLE : begin
        if(io_ioReq_fire) begin
          reqPkt_tlpType <= io_ioReq_payload_tlpType;
          reqPkt_reqId <= io_ioReq_payload_reqId;
          reqPkt_tag <= io_ioReq_payload_tag;
          reqPkt_addr <= io_ioReq_payload_addr;
          reqPkt_length <= io_ioReq_payload_length;
          reqPkt_firstBe <= io_ioReq_payload_firstBe;
          reqPkt_lastBe <= io_ioReq_payload_lastBe;
          reqPkt_tc <= io_ioReq_payload_tc;
          reqPkt_attr <= io_ioReq_payload_attr;
          reqPkt_data_0 <= io_ioReq_payload_data_0;
          reqPkt_data_1 <= io_ioReq_payload_data_1;
          reqPkt_data_2 <= io_ioReq_payload_data_2;
          reqPkt_data_3 <= io_ioReq_payload_data_3;
          reqPkt_dataValid <= io_ioReq_payload_dataValid;
        end
      end
      IoState_PROCESS_1 : begin
        if(when_TlpRxEngine_l375) begin
          respPkt_tlpType <= TlpType_CPL_D;
          respPkt_length <= 10'h001;
          respPkt_data_0 <= io_regRdData;
          respPkt_dataValid <= 3'b001;
        end else begin
          if(when_TlpRxEngine_l383) begin
            respPkt_tlpType <= TlpType_CPL;
            respPkt_length <= 10'h000;
            respPkt_dataValid <= 3'b000;
          end else begin
            respPkt_tlpType <= TlpType_CPL;
            respPkt_length <= 10'h000;
            respPkt_dataValid <= 3'b000;
          end
        end
        respPkt_reqId <= 16'h0000;
        respPkt_tag <= reqPkt_tag;
        respPkt_addr <= {48'd0, reqPkt_reqId};
        respPkt_firstBe <= reqPkt_firstBe;
        respPkt_lastBe <= reqPkt_lastBe;
        respPkt_tc <= 3'b000;
        respPkt_attr <= 2'b00;
      end
      default : begin
      end
    endcase
  end


endmodule

module TlpRxEngine (
  input  wire          io_tlpIn_valid,
  output reg           io_tlpIn_ready,
  input  wire [31:0]   io_tlpIn_payload,
  output reg           io_memReq_valid,
  input  wire          io_memReq_ready,
  output wire [3:0]    io_memReq_payload_tlpType,
  output wire [15:0]   io_memReq_payload_reqId,
  output wire [7:0]    io_memReq_payload_tag,
  output wire [63:0]   io_memReq_payload_addr,
  output wire [9:0]    io_memReq_payload_length,
  output wire [3:0]    io_memReq_payload_firstBe,
  output wire [3:0]    io_memReq_payload_lastBe,
  output wire [2:0]    io_memReq_payload_tc,
  output wire [1:0]    io_memReq_payload_attr,
  output wire [31:0]   io_memReq_payload_data_0,
  output wire [31:0]   io_memReq_payload_data_1,
  output wire [31:0]   io_memReq_payload_data_2,
  output wire [31:0]   io_memReq_payload_data_3,
  output wire [2:0]    io_memReq_payload_dataValid,
  output reg           io_cfgReq_valid,
  input  wire          io_cfgReq_ready,
  output wire [3:0]    io_cfgReq_payload_tlpType,
  output wire [15:0]   io_cfgReq_payload_reqId,
  output wire [7:0]    io_cfgReq_payload_tag,
  output wire [63:0]   io_cfgReq_payload_addr,
  output wire [9:0]    io_cfgReq_payload_length,
  output wire [3:0]    io_cfgReq_payload_firstBe,
  output wire [3:0]    io_cfgReq_payload_lastBe,
  output wire [2:0]    io_cfgReq_payload_tc,
  output wire [1:0]    io_cfgReq_payload_attr,
  output wire [31:0]   io_cfgReq_payload_data_0,
  output wire [31:0]   io_cfgReq_payload_data_1,
  output wire [31:0]   io_cfgReq_payload_data_2,
  output wire [31:0]   io_cfgReq_payload_data_3,
  output wire [2:0]    io_cfgReq_payload_dataValid,
  output reg           io_cplIn_valid,
  input  wire          io_cplIn_ready,
  output wire [3:0]    io_cplIn_payload_tlpType,
  output wire [15:0]   io_cplIn_payload_reqId,
  output wire [7:0]    io_cplIn_payload_tag,
  output wire [63:0]   io_cplIn_payload_addr,
  output wire [9:0]    io_cplIn_payload_length,
  output wire [3:0]    io_cplIn_payload_firstBe,
  output wire [3:0]    io_cplIn_payload_lastBe,
  output wire [2:0]    io_cplIn_payload_tc,
  output wire [1:0]    io_cplIn_payload_attr,
  output wire [31:0]   io_cplIn_payload_data_0,
  output wire [31:0]   io_cplIn_payload_data_1,
  output wire [31:0]   io_cplIn_payload_data_2,
  output wire [31:0]   io_cplIn_payload_data_3,
  output wire [2:0]    io_cplIn_payload_dataValid,
  output reg           io_ioReq_valid,
  input  wire          io_ioReq_ready,
  output wire [3:0]    io_ioReq_payload_tlpType,
  output wire [15:0]   io_ioReq_payload_reqId,
  output wire [7:0]    io_ioReq_payload_tag,
  output wire [63:0]   io_ioReq_payload_addr,
  output wire [9:0]    io_ioReq_payload_length,
  output wire [3:0]    io_ioReq_payload_firstBe,
  output wire [3:0]    io_ioReq_payload_lastBe,
  output wire [2:0]    io_ioReq_payload_tc,
  output wire [1:0]    io_ioReq_payload_attr,
  output wire [31:0]   io_ioReq_payload_data_0,
  output wire [31:0]   io_ioReq_payload_data_1,
  output wire [31:0]   io_ioReq_payload_data_2,
  output wire [31:0]   io_ioReq_payload_data_3,
  output wire [2:0]    io_ioReq_payload_dataValid,
  output wire          io_memDataOut_valid,
  input  wire          io_memDataOut_ready,
  output wire [31:0]   io_memDataOut_payload_data,
  output wire          io_memDataOut_payload_valid,
  output wire          io_memDataOut_payload_last,
  output wire [3:0]    io_memDataOut_payload_byteEn,
  output reg           io_memDataStart,
  output wire          io_parseErr,
  output wire          io_overflow,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;
  localparam RxState_IDLE = 3'd0;
  localparam RxState_HDR2 = 3'd1;
  localparam RxState_HDR3 = 3'd2;
  localparam RxState_HDR4 = 3'd3;
  localparam RxState_DATA = 3'd4;
  localparam RxState_DATA_STREAM = 3'd5;
  localparam RxState_EMIT = 3'd6;
  localparam RxState_DISCARD = 3'd7;

  wire       [1:0]    _zz__zz_1;
  wire       [2:0]    _zz_pkt_dataValid_1;
  wire       [10:0]   _zz_when_TlpRxEngine_l237;
  wire       [10:0]   _zz_when_TlpRxEngine_l237_1;
  wire       [10:0]   _zz_streamLast;
  wire       [10:0]   _zz_streamLast_1;
  wire       [1:0]    _zz__zz_2;
  wire       [2:0]    _zz_pkt_dataValid_2;
  wire       [10:0]   _zz_pkt_dataValid_3;
  wire       [10:0]   _zz_when_TlpRxEngine_l282;
  wire       [9:0]    _zz_when_TlpRxEngine_l282_1;
  reg        [2:0]    state;
  reg        [3:0]    pkt_tlpType;
  reg        [15:0]   pkt_reqId;
  reg        [7:0]    pkt_tag;
  reg        [63:0]   pkt_addr;
  reg        [9:0]    pkt_length;
  reg        [3:0]    pkt_firstBe;
  reg        [3:0]    pkt_lastBe;
  reg        [2:0]    pkt_tc;
  reg        [1:0]    pkt_attr;
  reg        [31:0]   pkt_data_0;
  reg        [31:0]   pkt_data_1;
  reg        [31:0]   pkt_data_2;
  reg        [31:0]   pkt_data_3;
  reg        [2:0]    pkt_dataValid;
  reg        [10:0]   dataIdx;
  reg                 is4DW;
  reg                 hasData;
  reg                 parseErrR;
  reg                 overflowR;
  reg                 outValid;
  reg        [1:0]    outChannel;
  reg        [3:0]    outPkt_tlpType;
  reg        [15:0]   outPkt_reqId;
  reg        [7:0]    outPkt_tag;
  reg        [63:0]   outPkt_addr;
  reg        [9:0]    outPkt_length;
  reg        [3:0]    outPkt_firstBe;
  reg        [3:0]    outPkt_lastBe;
  reg        [2:0]    outPkt_tc;
  reg        [1:0]    outPkt_attr;
  reg        [31:0]   outPkt_data_0;
  reg        [31:0]   outPkt_data_1;
  reg        [31:0]   outPkt_data_2;
  reg        [31:0]   outPkt_data_3;
  reg        [2:0]    outPkt_dataValid;
  reg                 streamValid;
  reg        [31:0]   streamData;
  reg                 streamLast;
  wire                io_tlpIn_fire;
  wire       [2:0]    _zz_is4DW;
  wire       [4:0]    switch_TlpRxEngine_l132;
  wire       [3:0]    _zz_pkt_tlpType;
  wire       [3:0]    _zz_pkt_tlpType_1;
  wire       [3:0]    _zz_pkt_tlpType_2;
  wire       [3:0]    _zz_pkt_tlpType_3;
  wire       [3:0]    _zz_pkt_tlpType_4;
  wire       [3:0]    _zz_pkt_tlpType_5;
  wire                when_TlpRxEngine_l158;
  wire                when_TlpRxEngine_l163;
  wire                when_TlpRxEngine_l174;
  wire                when_TlpRxEngine_l196;
  wire                when_TlpRxEngine_l214;
  wire       [10:0]   _zz_pkt_dataValid;
  wire                when_TlpRxEngine_l232;
  wire       [3:0]    _zz_1;
  wire                when_TlpRxEngine_l237;
  wire                when_TlpRxEngine_l254;
  wire       [3:0]    _zz_2;
  reg        [1:0]    _zz_outChannel;
  wire                when_TlpRxEngine_l298;
  wire                when_TlpRxEngine_l300;
  wire                when_TlpRxEngine_l301;
  wire                when_TlpRxEngine_l282;
  `ifndef SYNTHESIS
  reg [55:0] io_memReq_payload_tlpType_string;
  reg [55:0] io_cfgReq_payload_tlpType_string;
  reg [55:0] io_cplIn_payload_tlpType_string;
  reg [55:0] io_ioReq_payload_tlpType_string;
  reg [87:0] state_string;
  reg [55:0] pkt_tlpType_string;
  reg [55:0] outPkt_tlpType_string;
  reg [55:0] _zz_pkt_tlpType_string;
  reg [55:0] _zz_pkt_tlpType_1_string;
  reg [55:0] _zz_pkt_tlpType_2_string;
  reg [55:0] _zz_pkt_tlpType_3_string;
  reg [55:0] _zz_pkt_tlpType_4_string;
  reg [55:0] _zz_pkt_tlpType_5_string;
  `endif


  assign _zz__zz_1 = dataIdx[1:0];
  assign _zz_pkt_dataValid_1 = _zz_pkt_dataValid[2:0];
  assign _zz_when_TlpRxEngine_l237 = (((pkt_length == 10'h000) ? 11'h400 : _zz_when_TlpRxEngine_l237_1) - 11'h001);
  assign _zz_when_TlpRxEngine_l237_1 = {1'd0, pkt_length};
  assign _zz_streamLast = (((pkt_length == 10'h000) ? 11'h400 : _zz_streamLast_1) - 11'h001);
  assign _zz_streamLast_1 = {1'd0, pkt_length};
  assign _zz__zz_2 = dataIdx[1:0];
  assign _zz_pkt_dataValid_3 = (dataIdx + 11'h001);
  assign _zz_pkt_dataValid_2 = _zz_pkt_dataValid_3[2:0];
  assign _zz_when_TlpRxEngine_l282_1 = (pkt_length - 10'h001);
  assign _zz_when_TlpRxEngine_l282 = {1'd0, _zz_when_TlpRxEngine_l282_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_memReq_payload_tlpType)
      TlpType_MEM_RD : io_memReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memReq_payload_tlpType_string = "INVALID";
      default : io_memReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cfgReq_payload_tlpType)
      TlpType_MEM_RD : io_cfgReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cfgReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cfgReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cfgReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cfgReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cfgReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cfgReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cfgReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cfgReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cfgReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cfgReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cfgReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cfgReq_payload_tlpType_string = "INVALID";
      default : io_cfgReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cplIn_payload_tlpType)
      TlpType_MEM_RD : io_cplIn_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cplIn_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cplIn_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cplIn_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cplIn_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cplIn_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cplIn_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cplIn_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cplIn_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cplIn_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cplIn_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cplIn_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cplIn_payload_tlpType_string = "INVALID";
      default : io_cplIn_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_ioReq_payload_tlpType)
      TlpType_MEM_RD : io_ioReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_ioReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_ioReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_ioReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_ioReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_ioReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_ioReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_ioReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_ioReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_ioReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_ioReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_ioReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_ioReq_payload_tlpType_string = "INVALID";
      default : io_ioReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(state)
      RxState_IDLE : state_string = "IDLE       ";
      RxState_HDR2 : state_string = "HDR2       ";
      RxState_HDR3 : state_string = "HDR3       ";
      RxState_HDR4 : state_string = "HDR4       ";
      RxState_DATA : state_string = "DATA       ";
      RxState_DATA_STREAM : state_string = "DATA_STREAM";
      RxState_EMIT : state_string = "EMIT       ";
      RxState_DISCARD : state_string = "DISCARD    ";
      default : state_string = "???????????";
    endcase
  end
  always @(*) begin
    case(pkt_tlpType)
      TlpType_MEM_RD : pkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : pkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : pkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : pkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : pkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : pkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : pkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : pkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : pkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : pkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : pkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : pkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : pkt_tlpType_string = "INVALID";
      default : pkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(outPkt_tlpType)
      TlpType_MEM_RD : outPkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : outPkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : outPkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : outPkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : outPkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : outPkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : outPkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : outPkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : outPkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : outPkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : outPkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : outPkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : outPkt_tlpType_string = "INVALID";
      default : outPkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType)
      TlpType_MEM_RD : _zz_pkt_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_string = "INVALID";
      default : _zz_pkt_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType_1)
      TlpType_MEM_RD : _zz_pkt_tlpType_1_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_1_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_1_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_1_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_1_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_1_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_1_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_1_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_1_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_1_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_1_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_1_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_1_string = "INVALID";
      default : _zz_pkt_tlpType_1_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType_2)
      TlpType_MEM_RD : _zz_pkt_tlpType_2_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_2_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_2_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_2_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_2_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_2_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_2_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_2_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_2_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_2_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_2_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_2_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_2_string = "INVALID";
      default : _zz_pkt_tlpType_2_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType_3)
      TlpType_MEM_RD : _zz_pkt_tlpType_3_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_3_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_3_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_3_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_3_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_3_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_3_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_3_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_3_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_3_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_3_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_3_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_3_string = "INVALID";
      default : _zz_pkt_tlpType_3_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType_4)
      TlpType_MEM_RD : _zz_pkt_tlpType_4_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_4_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_4_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_4_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_4_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_4_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_4_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_4_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_4_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_4_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_4_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_4_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_4_string = "INVALID";
      default : _zz_pkt_tlpType_4_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_pkt_tlpType_5)
      TlpType_MEM_RD : _zz_pkt_tlpType_5_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_pkt_tlpType_5_string = "MEM_WR ";
      TlpType_IO_RD : _zz_pkt_tlpType_5_string = "IO_RD  ";
      TlpType_IO_WR : _zz_pkt_tlpType_5_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_pkt_tlpType_5_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_pkt_tlpType_5_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_pkt_tlpType_5_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_pkt_tlpType_5_string = "CFG_WR1";
      TlpType_CPL : _zz_pkt_tlpType_5_string = "CPL    ";
      TlpType_CPL_D : _zz_pkt_tlpType_5_string = "CPL_D  ";
      TlpType_MSG : _zz_pkt_tlpType_5_string = "MSG    ";
      TlpType_MSG_D : _zz_pkt_tlpType_5_string = "MSG_D  ";
      TlpType_INVALID : _zz_pkt_tlpType_5_string = "INVALID";
      default : _zz_pkt_tlpType_5_string = "???????";
    endcase
  end
  `endif

  assign io_parseErr = parseErrR;
  assign io_overflow = overflowR;
  assign io_memDataOut_valid = streamValid;
  assign io_memDataOut_payload_data = streamData;
  assign io_memDataOut_payload_last = streamLast;
  assign io_memDataOut_payload_byteEn = 4'b1111;
  assign io_memDataOut_payload_valid = 1'b1;
  always @(*) begin
    io_memDataStart = 1'b0;
    case(state)
      RxState_IDLE : begin
      end
      RxState_HDR2 : begin
      end
      RxState_HDR3 : begin
        if(io_tlpIn_fire) begin
          if(!is4DW) begin
            if(hasData) begin
              if(when_TlpRxEngine_l196) begin
                io_memDataStart = 1'b1;
              end
            end
          end
        end
      end
      RxState_HDR4 : begin
        if(io_tlpIn_fire) begin
          if(hasData) begin
            if(when_TlpRxEngine_l214) begin
              io_memDataStart = 1'b1;
            end
          end
        end
      end
      RxState_DATA : begin
      end
      RxState_DATA_STREAM : begin
      end
      RxState_EMIT : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memReq_valid = 1'b0;
    if(outValid) begin
      case(outChannel)
        2'b00 : begin
          io_memReq_valid = 1'b1;
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_cfgReq_valid = 1'b0;
    if(outValid) begin
      case(outChannel)
        2'b00 : begin
        end
        2'b01 : begin
          io_cfgReq_valid = 1'b1;
        end
        2'b10 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_cplIn_valid = 1'b0;
    if(outValid) begin
      case(outChannel)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
          io_cplIn_valid = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_ioReq_valid = 1'b0;
    if(outValid) begin
      case(outChannel)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
          io_ioReq_valid = 1'b1;
        end
      endcase
    end
  end

  assign io_memReq_payload_tlpType = outPkt_tlpType;
  assign io_memReq_payload_reqId = outPkt_reqId;
  assign io_memReq_payload_tag = outPkt_tag;
  assign io_memReq_payload_addr = outPkt_addr;
  assign io_memReq_payload_length = outPkt_length;
  assign io_memReq_payload_firstBe = outPkt_firstBe;
  assign io_memReq_payload_lastBe = outPkt_lastBe;
  assign io_memReq_payload_tc = outPkt_tc;
  assign io_memReq_payload_attr = outPkt_attr;
  assign io_memReq_payload_data_0 = outPkt_data_0;
  assign io_memReq_payload_data_1 = outPkt_data_1;
  assign io_memReq_payload_data_2 = outPkt_data_2;
  assign io_memReq_payload_data_3 = outPkt_data_3;
  assign io_memReq_payload_dataValid = outPkt_dataValid;
  assign io_cfgReq_payload_tlpType = outPkt_tlpType;
  assign io_cfgReq_payload_reqId = outPkt_reqId;
  assign io_cfgReq_payload_tag = outPkt_tag;
  assign io_cfgReq_payload_addr = outPkt_addr;
  assign io_cfgReq_payload_length = outPkt_length;
  assign io_cfgReq_payload_firstBe = outPkt_firstBe;
  assign io_cfgReq_payload_lastBe = outPkt_lastBe;
  assign io_cfgReq_payload_tc = outPkt_tc;
  assign io_cfgReq_payload_attr = outPkt_attr;
  assign io_cfgReq_payload_data_0 = outPkt_data_0;
  assign io_cfgReq_payload_data_1 = outPkt_data_1;
  assign io_cfgReq_payload_data_2 = outPkt_data_2;
  assign io_cfgReq_payload_data_3 = outPkt_data_3;
  assign io_cfgReq_payload_dataValid = outPkt_dataValid;
  assign io_cplIn_payload_tlpType = outPkt_tlpType;
  assign io_cplIn_payload_reqId = outPkt_reqId;
  assign io_cplIn_payload_tag = outPkt_tag;
  assign io_cplIn_payload_addr = outPkt_addr;
  assign io_cplIn_payload_length = outPkt_length;
  assign io_cplIn_payload_firstBe = outPkt_firstBe;
  assign io_cplIn_payload_lastBe = outPkt_lastBe;
  assign io_cplIn_payload_tc = outPkt_tc;
  assign io_cplIn_payload_attr = outPkt_attr;
  assign io_cplIn_payload_data_0 = outPkt_data_0;
  assign io_cplIn_payload_data_1 = outPkt_data_1;
  assign io_cplIn_payload_data_2 = outPkt_data_2;
  assign io_cplIn_payload_data_3 = outPkt_data_3;
  assign io_cplIn_payload_dataValid = outPkt_dataValid;
  assign io_ioReq_payload_tlpType = outPkt_tlpType;
  assign io_ioReq_payload_reqId = outPkt_reqId;
  assign io_ioReq_payload_tag = outPkt_tag;
  assign io_ioReq_payload_addr = outPkt_addr;
  assign io_ioReq_payload_length = outPkt_length;
  assign io_ioReq_payload_firstBe = outPkt_firstBe;
  assign io_ioReq_payload_lastBe = outPkt_lastBe;
  assign io_ioReq_payload_tc = outPkt_tc;
  assign io_ioReq_payload_attr = outPkt_attr;
  assign io_ioReq_payload_data_0 = outPkt_data_0;
  assign io_ioReq_payload_data_1 = outPkt_data_1;
  assign io_ioReq_payload_data_2 = outPkt_data_2;
  assign io_ioReq_payload_data_3 = outPkt_data_3;
  assign io_ioReq_payload_dataValid = outPkt_dataValid;
  always @(*) begin
    io_tlpIn_ready = (((! outValid) && (state != RxState_EMIT)) && (state != RxState_DISCARD));
    case(state)
      RxState_IDLE : begin
      end
      RxState_HDR2 : begin
      end
      RxState_HDR3 : begin
      end
      RxState_HDR4 : begin
      end
      RxState_DATA : begin
      end
      RxState_DATA_STREAM : begin
      end
      RxState_EMIT : begin
      end
      default : begin
        io_tlpIn_ready = 1'b1;
      end
    endcase
  end

  assign io_tlpIn_fire = (io_tlpIn_valid && io_tlpIn_ready);
  assign _zz_is4DW = io_tlpIn_payload[31 : 29];
  assign switch_TlpRxEngine_l132 = io_tlpIn_payload[28 : 24];
  assign _zz_pkt_tlpType = (_zz_is4DW[1] ? TlpType_MEM_WR : TlpType_MEM_RD);
  assign _zz_pkt_tlpType_1 = (_zz_is4DW[1] ? TlpType_IO_WR : TlpType_IO_RD);
  assign _zz_pkt_tlpType_2 = (_zz_is4DW[1] ? TlpType_CFG_WR0 : TlpType_CFG_RD0);
  assign _zz_pkt_tlpType_3 = (_zz_is4DW[1] ? TlpType_CFG_WR1 : TlpType_CFG_RD1);
  assign _zz_pkt_tlpType_4 = (_zz_is4DW[1] ? TlpType_CPL_D : TlpType_CPL);
  assign _zz_pkt_tlpType_5 = (_zz_is4DW[1] ? TlpType_MSG_D : TlpType_MSG);
  assign when_TlpRxEngine_l158 = ((10'h040 < pkt_length) && hasData);
  assign when_TlpRxEngine_l163 = (parseErrR || overflowR);
  assign when_TlpRxEngine_l174 = ((! parseErrR) && (! overflowR));
  assign when_TlpRxEngine_l196 = (10'h004 < pkt_length);
  assign when_TlpRxEngine_l214 = (10'h004 < pkt_length);
  assign _zz_pkt_dataValid = (dataIdx + 11'h001);
  assign when_TlpRxEngine_l232 = (dataIdx < 11'h004);
  assign _zz_1 = ({3'd0,1'b1} <<< _zz__zz_1);
  assign when_TlpRxEngine_l237 = (dataIdx == _zz_when_TlpRxEngine_l237);
  assign when_TlpRxEngine_l254 = (dataIdx < 11'h004);
  assign _zz_2 = ({3'd0,1'b1} <<< _zz__zz_2);
  always @(*) begin
    _zz_outChannel = 2'b11;
    if(when_TlpRxEngine_l298) begin
      _zz_outChannel = 2'b00;
    end
    if(when_TlpRxEngine_l300) begin
      _zz_outChannel = 2'b01;
    end
    if(when_TlpRxEngine_l301) begin
      _zz_outChannel = 2'b10;
    end
  end

  assign when_TlpRxEngine_l298 = ((pkt_tlpType == TlpType_MEM_RD) || (pkt_tlpType == TlpType_MEM_WR));
  assign when_TlpRxEngine_l300 = ((((pkt_tlpType == TlpType_CFG_RD0) || (pkt_tlpType == TlpType_CFG_WR0)) || (pkt_tlpType == TlpType_CFG_RD1)) || (pkt_tlpType == TlpType_CFG_WR1));
  assign when_TlpRxEngine_l301 = ((pkt_tlpType == TlpType_CPL) || (pkt_tlpType == TlpType_CPL_D));
  assign when_TlpRxEngine_l282 = ((! hasData) || (_zz_when_TlpRxEngine_l282 <= dataIdx));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= RxState_IDLE;
      dataIdx <= 11'h000;
      is4DW <= 1'b0;
      hasData <= 1'b0;
      parseErrR <= 1'b0;
      overflowR <= 1'b0;
      outValid <= 1'b0;
      outChannel <= 2'b00;
      streamValid <= 1'b0;
      streamLast <= 1'b0;
    end else begin
      if(outValid) begin
        case(outChannel)
          2'b00 : begin
            if(io_memReq_ready) begin
              outValid <= 1'b0;
            end
          end
          2'b01 : begin
            if(io_cfgReq_ready) begin
              outValid <= 1'b0;
            end
          end
          2'b10 : begin
            if(io_cplIn_ready) begin
              outValid <= 1'b0;
            end
          end
          default : begin
            if(io_ioReq_ready) begin
              outValid <= 1'b0;
            end
          end
        endcase
      end
      case(state)
        RxState_IDLE : begin
          if(io_tlpIn_fire) begin
            hasData <= _zz_is4DW[1];
            is4DW <= _zz_is4DW[0];
            parseErrR <= 1'b0;
            overflowR <= 1'b0;
            case(switch_TlpRxEngine_l132)
              5'h00 : begin
              end
              5'h02 : begin
              end
              5'h04 : begin
              end
              5'h05 : begin
              end
              5'h0a : begin
              end
              5'h10 : begin
              end
              default : begin
                parseErrR <= 1'b1;
              end
            endcase
            if(when_TlpRxEngine_l158) begin
              overflowR <= 1'b1;
            end
            if(when_TlpRxEngine_l163) begin
              state <= RxState_DISCARD;
            end else begin
              state <= RxState_HDR2;
            end
          end
        end
        RxState_HDR2 : begin
          if(io_tlpIn_fire) begin
            state <= RxState_HDR3;
          end
        end
        RxState_HDR3 : begin
          if(io_tlpIn_fire) begin
            if(is4DW) begin
              state <= RxState_HDR4;
            end else begin
              if(hasData) begin
                dataIdx <= 11'h000;
                if(when_TlpRxEngine_l196) begin
                  state <= RxState_DATA_STREAM;
                end else begin
                  state <= RxState_DATA;
                end
              end else begin
                state <= RxState_EMIT;
              end
            end
          end
        end
        RxState_HDR4 : begin
          if(io_tlpIn_fire) begin
            if(hasData) begin
              dataIdx <= 11'h000;
              if(when_TlpRxEngine_l214) begin
                state <= RxState_DATA_STREAM;
              end else begin
                state <= RxState_DATA;
              end
            end else begin
              state <= RxState_EMIT;
            end
          end
        end
        RxState_DATA : begin
          if(io_tlpIn_fire) begin
            if(when_TlpRxEngine_l237) begin
              state <= RxState_EMIT;
            end else begin
              dataIdx <= _zz_pkt_dataValid;
            end
          end
        end
        RxState_DATA_STREAM : begin
          streamValid <= io_tlpIn_valid;
          streamLast <= (dataIdx == _zz_streamLast);
          if(io_tlpIn_fire) begin
            if(streamLast) begin
              state <= RxState_EMIT;
            end else begin
              dataIdx <= (dataIdx + 11'h001);
            end
          end
        end
        RxState_EMIT : begin
          outChannel <= _zz_outChannel;
          outValid <= 1'b1;
          streamValid <= 1'b0;
          state <= RxState_IDLE;
        end
        default : begin
          streamValid <= 1'b0;
          if(io_tlpIn_fire) begin
            if(when_TlpRxEngine_l282) begin
              state <= RxState_IDLE;
              dataIdx <= 11'h000;
            end else begin
              dataIdx <= (dataIdx + 11'h001);
            end
          end
        end
      endcase
    end
  end

  always @(posedge clk) begin
    case(state)
      RxState_IDLE : begin
        if(io_tlpIn_fire) begin
          pkt_length <= io_tlpIn_payload[9 : 0];
          pkt_tc <= io_tlpIn_payload[22 : 20];
          pkt_attr <= io_tlpIn_payload[13 : 12];
          pkt_dataValid <= 3'b000;
          pkt_data_0 <= 32'h00000000;
          pkt_data_1 <= 32'h00000000;
          pkt_data_2 <= 32'h00000000;
          pkt_data_3 <= 32'h00000000;
          case(switch_TlpRxEngine_l132)
            5'h00 : begin
              pkt_tlpType <= _zz_pkt_tlpType;
            end
            5'h02 : begin
              pkt_tlpType <= _zz_pkt_tlpType_1;
            end
            5'h04 : begin
              pkt_tlpType <= _zz_pkt_tlpType_2;
            end
            5'h05 : begin
              pkt_tlpType <= _zz_pkt_tlpType_3;
            end
            5'h0a : begin
              pkt_tlpType <= _zz_pkt_tlpType_4;
            end
            5'h10 : begin
              pkt_tlpType <= _zz_pkt_tlpType_5;
            end
            default : begin
              pkt_tlpType <= TlpType_INVALID;
            end
          endcase
        end
      end
      RxState_HDR2 : begin
        if(io_tlpIn_fire) begin
          if(when_TlpRxEngine_l174) begin
            pkt_reqId <= io_tlpIn_payload[31 : 16];
            pkt_tag <= io_tlpIn_payload[15 : 8];
            pkt_lastBe <= io_tlpIn_payload[7 : 4];
            pkt_firstBe <= io_tlpIn_payload[3 : 0];
          end
        end
      end
      RxState_HDR3 : begin
        if(io_tlpIn_fire) begin
          if(is4DW) begin
            pkt_addr[63 : 32] <= io_tlpIn_payload;
          end else begin
            pkt_addr[31 : 0] <= io_tlpIn_payload;
            pkt_addr[63 : 32] <= 32'h00000000;
          end
        end
      end
      RxState_HDR4 : begin
        if(io_tlpIn_fire) begin
          pkt_addr[31 : 0] <= io_tlpIn_payload;
        end
      end
      RxState_DATA : begin
        if(io_tlpIn_fire) begin
          if(when_TlpRxEngine_l232) begin
            if(_zz_1[0]) begin
              pkt_data_0 <= io_tlpIn_payload;
            end
            if(_zz_1[1]) begin
              pkt_data_1 <= io_tlpIn_payload;
            end
            if(_zz_1[2]) begin
              pkt_data_2 <= io_tlpIn_payload;
            end
            if(_zz_1[3]) begin
              pkt_data_3 <= io_tlpIn_payload;
            end
          end
          pkt_dataValid <= ((11'h004 < _zz_pkt_dataValid) ? 3'b100 : _zz_pkt_dataValid_1);
        end
      end
      RxState_DATA_STREAM : begin
        streamData <= io_tlpIn_payload;
        if(when_TlpRxEngine_l254) begin
          if(_zz_2[0]) begin
            pkt_data_0 <= io_tlpIn_payload;
          end
          if(_zz_2[1]) begin
            pkt_data_1 <= io_tlpIn_payload;
          end
          if(_zz_2[2]) begin
            pkt_data_2 <= io_tlpIn_payload;
          end
          if(_zz_2[3]) begin
            pkt_data_3 <= io_tlpIn_payload;
          end
        end
        pkt_dataValid <= ((11'h003 <= dataIdx) ? 3'b100 : _zz_pkt_dataValid_2);
      end
      RxState_EMIT : begin
        outPkt_tlpType <= pkt_tlpType;
        outPkt_reqId <= pkt_reqId;
        outPkt_tag <= pkt_tag;
        outPkt_addr <= pkt_addr;
        outPkt_length <= pkt_length;
        outPkt_firstBe <= pkt_firstBe;
        outPkt_lastBe <= pkt_lastBe;
        outPkt_tc <= pkt_tc;
        outPkt_attr <= pkt_attr;
        outPkt_data_0 <= pkt_data_0;
        outPkt_data_1 <= pkt_data_1;
        outPkt_data_2 <= pkt_data_2;
        outPkt_data_3 <= pkt_data_3;
        outPkt_dataValid <= pkt_dataValid;
      end
      default : begin
      end
    endcase
  end


endmodule

module TlpTxFifoWrapper (
  input  wire          io_memWrIn_valid,
  output wire          io_memWrIn_ready,
  input  wire [3:0]    io_memWrIn_payload_tlpType,
  input  wire [15:0]   io_memWrIn_payload_reqId,
  input  wire [7:0]    io_memWrIn_payload_tag,
  input  wire [63:0]   io_memWrIn_payload_addr,
  input  wire [9:0]    io_memWrIn_payload_length,
  input  wire [3:0]    io_memWrIn_payload_firstBe,
  input  wire [3:0]    io_memWrIn_payload_lastBe,
  input  wire [2:0]    io_memWrIn_payload_tc,
  input  wire [1:0]    io_memWrIn_payload_attr,
  input  wire [31:0]   io_memWrIn_payload_data_0,
  input  wire [31:0]   io_memWrIn_payload_data_1,
  input  wire [31:0]   io_memWrIn_payload_data_2,
  input  wire [31:0]   io_memWrIn_payload_data_3,
  input  wire [2:0]    io_memWrIn_payload_dataValid,
  input  wire          io_memRdIn_valid,
  output wire          io_memRdIn_ready,
  input  wire [3:0]    io_memRdIn_payload_tlpType,
  input  wire [15:0]   io_memRdIn_payload_reqId,
  input  wire [7:0]    io_memRdIn_payload_tag,
  input  wire [63:0]   io_memRdIn_payload_addr,
  input  wire [9:0]    io_memRdIn_payload_length,
  input  wire [3:0]    io_memRdIn_payload_firstBe,
  input  wire [3:0]    io_memRdIn_payload_lastBe,
  input  wire [2:0]    io_memRdIn_payload_tc,
  input  wire [1:0]    io_memRdIn_payload_attr,
  input  wire [31:0]   io_memRdIn_payload_data_0,
  input  wire [31:0]   io_memRdIn_payload_data_1,
  input  wire [31:0]   io_memRdIn_payload_data_2,
  input  wire [31:0]   io_memRdIn_payload_data_3,
  input  wire [2:0]    io_memRdIn_payload_dataValid,
  input  wire          io_cplIn_valid,
  output wire          io_cplIn_ready,
  input  wire [3:0]    io_cplIn_payload_tlpType,
  input  wire [15:0]   io_cplIn_payload_reqId,
  input  wire [7:0]    io_cplIn_payload_tag,
  input  wire [63:0]   io_cplIn_payload_addr,
  input  wire [9:0]    io_cplIn_payload_length,
  input  wire [3:0]    io_cplIn_payload_firstBe,
  input  wire [3:0]    io_cplIn_payload_lastBe,
  input  wire [2:0]    io_cplIn_payload_tc,
  input  wire [1:0]    io_cplIn_payload_attr,
  input  wire [31:0]   io_cplIn_payload_data_0,
  input  wire [31:0]   io_cplIn_payload_data_1,
  input  wire [31:0]   io_cplIn_payload_data_2,
  input  wire [31:0]   io_cplIn_payload_data_3,
  input  wire [2:0]    io_cplIn_payload_dataValid,
  output wire          io_tlpOut_valid,
  input  wire          io_tlpOut_ready,
  output wire [31:0]   io_tlpOut_payload,
  input  wire [7:0]    io_fcCredits_phCredits,
  input  wire [11:0]   io_fcCredits_pdCredits,
  input  wire [7:0]    io_fcCredits_nphCredits,
  input  wire [11:0]   io_fcCredits_npdCredits,
  input  wire [7:0]    io_fcCredits_cplhCredits,
  input  wire [11:0]   io_fcCredits_cpldCredits,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  wire                memWrFifo_io_flush;
  wire                memRdFifo_io_flush;
  wire                cplFifo_io_flush;
  wire                memWrFifo_io_push_ready;
  wire                memWrFifo_io_pop_valid;
  wire       [3:0]    memWrFifo_io_pop_payload_tlpType;
  wire       [15:0]   memWrFifo_io_pop_payload_reqId;
  wire       [7:0]    memWrFifo_io_pop_payload_tag;
  wire       [63:0]   memWrFifo_io_pop_payload_addr;
  wire       [9:0]    memWrFifo_io_pop_payload_length;
  wire       [3:0]    memWrFifo_io_pop_payload_firstBe;
  wire       [3:0]    memWrFifo_io_pop_payload_lastBe;
  wire       [2:0]    memWrFifo_io_pop_payload_tc;
  wire       [1:0]    memWrFifo_io_pop_payload_attr;
  wire       [31:0]   memWrFifo_io_pop_payload_data_0;
  wire       [31:0]   memWrFifo_io_pop_payload_data_1;
  wire       [31:0]   memWrFifo_io_pop_payload_data_2;
  wire       [31:0]   memWrFifo_io_pop_payload_data_3;
  wire       [2:0]    memWrFifo_io_pop_payload_dataValid;
  wire       [6:0]    memWrFifo_io_occupancy;
  wire       [6:0]    memWrFifo_io_availability;
  wire                memRdFifo_io_push_ready;
  wire                memRdFifo_io_pop_valid;
  wire       [3:0]    memRdFifo_io_pop_payload_tlpType;
  wire       [15:0]   memRdFifo_io_pop_payload_reqId;
  wire       [7:0]    memRdFifo_io_pop_payload_tag;
  wire       [63:0]   memRdFifo_io_pop_payload_addr;
  wire       [9:0]    memRdFifo_io_pop_payload_length;
  wire       [3:0]    memRdFifo_io_pop_payload_firstBe;
  wire       [3:0]    memRdFifo_io_pop_payload_lastBe;
  wire       [2:0]    memRdFifo_io_pop_payload_tc;
  wire       [1:0]    memRdFifo_io_pop_payload_attr;
  wire       [31:0]   memRdFifo_io_pop_payload_data_0;
  wire       [31:0]   memRdFifo_io_pop_payload_data_1;
  wire       [31:0]   memRdFifo_io_pop_payload_data_2;
  wire       [31:0]   memRdFifo_io_pop_payload_data_3;
  wire       [2:0]    memRdFifo_io_pop_payload_dataValid;
  wire       [5:0]    memRdFifo_io_occupancy;
  wire       [5:0]    memRdFifo_io_availability;
  wire                cplFifo_io_push_ready;
  wire                cplFifo_io_pop_valid;
  wire       [3:0]    cplFifo_io_pop_payload_tlpType;
  wire       [15:0]   cplFifo_io_pop_payload_reqId;
  wire       [7:0]    cplFifo_io_pop_payload_tag;
  wire       [63:0]   cplFifo_io_pop_payload_addr;
  wire       [9:0]    cplFifo_io_pop_payload_length;
  wire       [3:0]    cplFifo_io_pop_payload_firstBe;
  wire       [3:0]    cplFifo_io_pop_payload_lastBe;
  wire       [2:0]    cplFifo_io_pop_payload_tc;
  wire       [1:0]    cplFifo_io_pop_payload_attr;
  wire       [31:0]   cplFifo_io_pop_payload_data_0;
  wire       [31:0]   cplFifo_io_pop_payload_data_1;
  wire       [31:0]   cplFifo_io_pop_payload_data_2;
  wire       [31:0]   cplFifo_io_pop_payload_data_3;
  wire       [2:0]    cplFifo_io_pop_payload_dataValid;
  wire       [5:0]    cplFifo_io_occupancy;
  wire       [5:0]    cplFifo_io_availability;
  wire                engine_io_memWrReq_ready;
  wire                engine_io_memRdReq_ready;
  wire                engine_io_cplReq_ready;
  wire                engine_io_tlpOut_valid;
  wire       [31:0]   engine_io_tlpOut_payload;
  `ifndef SYNTHESIS
  reg [55:0] io_memWrIn_payload_tlpType_string;
  reg [55:0] io_memRdIn_payload_tlpType_string;
  reg [55:0] io_cplIn_payload_tlpType_string;
  `endif


  StreamFifo memWrFifo (
    .io_push_valid             (io_memWrIn_valid                       ), //i
    .io_push_ready             (memWrFifo_io_push_ready                ), //o
    .io_push_payload_tlpType   (io_memWrIn_payload_tlpType[3:0]        ), //i
    .io_push_payload_reqId     (io_memWrIn_payload_reqId[15:0]         ), //i
    .io_push_payload_tag       (io_memWrIn_payload_tag[7:0]            ), //i
    .io_push_payload_addr      (io_memWrIn_payload_addr[63:0]          ), //i
    .io_push_payload_length    (io_memWrIn_payload_length[9:0]         ), //i
    .io_push_payload_firstBe   (io_memWrIn_payload_firstBe[3:0]        ), //i
    .io_push_payload_lastBe    (io_memWrIn_payload_lastBe[3:0]         ), //i
    .io_push_payload_tc        (io_memWrIn_payload_tc[2:0]             ), //i
    .io_push_payload_attr      (io_memWrIn_payload_attr[1:0]           ), //i
    .io_push_payload_data_0    (io_memWrIn_payload_data_0[31:0]        ), //i
    .io_push_payload_data_1    (io_memWrIn_payload_data_1[31:0]        ), //i
    .io_push_payload_data_2    (io_memWrIn_payload_data_2[31:0]        ), //i
    .io_push_payload_data_3    (io_memWrIn_payload_data_3[31:0]        ), //i
    .io_push_payload_dataValid (io_memWrIn_payload_dataValid[2:0]      ), //i
    .io_pop_valid              (memWrFifo_io_pop_valid                 ), //o
    .io_pop_ready              (engine_io_memWrReq_ready               ), //i
    .io_pop_payload_tlpType    (memWrFifo_io_pop_payload_tlpType[3:0]  ), //o
    .io_pop_payload_reqId      (memWrFifo_io_pop_payload_reqId[15:0]   ), //o
    .io_pop_payload_tag        (memWrFifo_io_pop_payload_tag[7:0]      ), //o
    .io_pop_payload_addr       (memWrFifo_io_pop_payload_addr[63:0]    ), //o
    .io_pop_payload_length     (memWrFifo_io_pop_payload_length[9:0]   ), //o
    .io_pop_payload_firstBe    (memWrFifo_io_pop_payload_firstBe[3:0]  ), //o
    .io_pop_payload_lastBe     (memWrFifo_io_pop_payload_lastBe[3:0]   ), //o
    .io_pop_payload_tc         (memWrFifo_io_pop_payload_tc[2:0]       ), //o
    .io_pop_payload_attr       (memWrFifo_io_pop_payload_attr[1:0]     ), //o
    .io_pop_payload_data_0     (memWrFifo_io_pop_payload_data_0[31:0]  ), //o
    .io_pop_payload_data_1     (memWrFifo_io_pop_payload_data_1[31:0]  ), //o
    .io_pop_payload_data_2     (memWrFifo_io_pop_payload_data_2[31:0]  ), //o
    .io_pop_payload_data_3     (memWrFifo_io_pop_payload_data_3[31:0]  ), //o
    .io_pop_payload_dataValid  (memWrFifo_io_pop_payload_dataValid[2:0]), //o
    .io_flush                  (memWrFifo_io_flush                     ), //i
    .io_occupancy              (memWrFifo_io_occupancy[6:0]            ), //o
    .io_availability           (memWrFifo_io_availability[6:0]         ), //o
    .clk                       (clk                                    ), //i
    .reset                     (reset                                  )  //i
  );
  StreamFifo_1 memRdFifo (
    .io_push_valid             (io_memRdIn_valid                       ), //i
    .io_push_ready             (memRdFifo_io_push_ready                ), //o
    .io_push_payload_tlpType   (io_memRdIn_payload_tlpType[3:0]        ), //i
    .io_push_payload_reqId     (io_memRdIn_payload_reqId[15:0]         ), //i
    .io_push_payload_tag       (io_memRdIn_payload_tag[7:0]            ), //i
    .io_push_payload_addr      (io_memRdIn_payload_addr[63:0]          ), //i
    .io_push_payload_length    (io_memRdIn_payload_length[9:0]         ), //i
    .io_push_payload_firstBe   (io_memRdIn_payload_firstBe[3:0]        ), //i
    .io_push_payload_lastBe    (io_memRdIn_payload_lastBe[3:0]         ), //i
    .io_push_payload_tc        (io_memRdIn_payload_tc[2:0]             ), //i
    .io_push_payload_attr      (io_memRdIn_payload_attr[1:0]           ), //i
    .io_push_payload_data_0    (io_memRdIn_payload_data_0[31:0]        ), //i
    .io_push_payload_data_1    (io_memRdIn_payload_data_1[31:0]        ), //i
    .io_push_payload_data_2    (io_memRdIn_payload_data_2[31:0]        ), //i
    .io_push_payload_data_3    (io_memRdIn_payload_data_3[31:0]        ), //i
    .io_push_payload_dataValid (io_memRdIn_payload_dataValid[2:0]      ), //i
    .io_pop_valid              (memRdFifo_io_pop_valid                 ), //o
    .io_pop_ready              (engine_io_memRdReq_ready               ), //i
    .io_pop_payload_tlpType    (memRdFifo_io_pop_payload_tlpType[3:0]  ), //o
    .io_pop_payload_reqId      (memRdFifo_io_pop_payload_reqId[15:0]   ), //o
    .io_pop_payload_tag        (memRdFifo_io_pop_payload_tag[7:0]      ), //o
    .io_pop_payload_addr       (memRdFifo_io_pop_payload_addr[63:0]    ), //o
    .io_pop_payload_length     (memRdFifo_io_pop_payload_length[9:0]   ), //o
    .io_pop_payload_firstBe    (memRdFifo_io_pop_payload_firstBe[3:0]  ), //o
    .io_pop_payload_lastBe     (memRdFifo_io_pop_payload_lastBe[3:0]   ), //o
    .io_pop_payload_tc         (memRdFifo_io_pop_payload_tc[2:0]       ), //o
    .io_pop_payload_attr       (memRdFifo_io_pop_payload_attr[1:0]     ), //o
    .io_pop_payload_data_0     (memRdFifo_io_pop_payload_data_0[31:0]  ), //o
    .io_pop_payload_data_1     (memRdFifo_io_pop_payload_data_1[31:0]  ), //o
    .io_pop_payload_data_2     (memRdFifo_io_pop_payload_data_2[31:0]  ), //o
    .io_pop_payload_data_3     (memRdFifo_io_pop_payload_data_3[31:0]  ), //o
    .io_pop_payload_dataValid  (memRdFifo_io_pop_payload_dataValid[2:0]), //o
    .io_flush                  (memRdFifo_io_flush                     ), //i
    .io_occupancy              (memRdFifo_io_occupancy[5:0]            ), //o
    .io_availability           (memRdFifo_io_availability[5:0]         ), //o
    .clk                       (clk                                    ), //i
    .reset                     (reset                                  )  //i
  );
  StreamFifo_1 cplFifo (
    .io_push_valid             (io_cplIn_valid                       ), //i
    .io_push_ready             (cplFifo_io_push_ready                ), //o
    .io_push_payload_tlpType   (io_cplIn_payload_tlpType[3:0]        ), //i
    .io_push_payload_reqId     (io_cplIn_payload_reqId[15:0]         ), //i
    .io_push_payload_tag       (io_cplIn_payload_tag[7:0]            ), //i
    .io_push_payload_addr      (io_cplIn_payload_addr[63:0]          ), //i
    .io_push_payload_length    (io_cplIn_payload_length[9:0]         ), //i
    .io_push_payload_firstBe   (io_cplIn_payload_firstBe[3:0]        ), //i
    .io_push_payload_lastBe    (io_cplIn_payload_lastBe[3:0]         ), //i
    .io_push_payload_tc        (io_cplIn_payload_tc[2:0]             ), //i
    .io_push_payload_attr      (io_cplIn_payload_attr[1:0]           ), //i
    .io_push_payload_data_0    (io_cplIn_payload_data_0[31:0]        ), //i
    .io_push_payload_data_1    (io_cplIn_payload_data_1[31:0]        ), //i
    .io_push_payload_data_2    (io_cplIn_payload_data_2[31:0]        ), //i
    .io_push_payload_data_3    (io_cplIn_payload_data_3[31:0]        ), //i
    .io_push_payload_dataValid (io_cplIn_payload_dataValid[2:0]      ), //i
    .io_pop_valid              (cplFifo_io_pop_valid                 ), //o
    .io_pop_ready              (engine_io_cplReq_ready               ), //i
    .io_pop_payload_tlpType    (cplFifo_io_pop_payload_tlpType[3:0]  ), //o
    .io_pop_payload_reqId      (cplFifo_io_pop_payload_reqId[15:0]   ), //o
    .io_pop_payload_tag        (cplFifo_io_pop_payload_tag[7:0]      ), //o
    .io_pop_payload_addr       (cplFifo_io_pop_payload_addr[63:0]    ), //o
    .io_pop_payload_length     (cplFifo_io_pop_payload_length[9:0]   ), //o
    .io_pop_payload_firstBe    (cplFifo_io_pop_payload_firstBe[3:0]  ), //o
    .io_pop_payload_lastBe     (cplFifo_io_pop_payload_lastBe[3:0]   ), //o
    .io_pop_payload_tc         (cplFifo_io_pop_payload_tc[2:0]       ), //o
    .io_pop_payload_attr       (cplFifo_io_pop_payload_attr[1:0]     ), //o
    .io_pop_payload_data_0     (cplFifo_io_pop_payload_data_0[31:0]  ), //o
    .io_pop_payload_data_1     (cplFifo_io_pop_payload_data_1[31:0]  ), //o
    .io_pop_payload_data_2     (cplFifo_io_pop_payload_data_2[31:0]  ), //o
    .io_pop_payload_data_3     (cplFifo_io_pop_payload_data_3[31:0]  ), //o
    .io_pop_payload_dataValid  (cplFifo_io_pop_payload_dataValid[2:0]), //o
    .io_flush                  (cplFifo_io_flush                     ), //i
    .io_occupancy              (cplFifo_io_occupancy[5:0]            ), //o
    .io_availability           (cplFifo_io_availability[5:0]         ), //o
    .clk                       (clk                                  ), //i
    .reset                     (reset                                )  //i
  );
  TlpTxEngine engine (
    .io_memWrReq_valid             (memWrFifo_io_pop_valid                 ), //i
    .io_memWrReq_ready             (engine_io_memWrReq_ready               ), //o
    .io_memWrReq_payload_tlpType   (memWrFifo_io_pop_payload_tlpType[3:0]  ), //i
    .io_memWrReq_payload_reqId     (memWrFifo_io_pop_payload_reqId[15:0]   ), //i
    .io_memWrReq_payload_tag       (memWrFifo_io_pop_payload_tag[7:0]      ), //i
    .io_memWrReq_payload_addr      (memWrFifo_io_pop_payload_addr[63:0]    ), //i
    .io_memWrReq_payload_length    (memWrFifo_io_pop_payload_length[9:0]   ), //i
    .io_memWrReq_payload_firstBe   (memWrFifo_io_pop_payload_firstBe[3:0]  ), //i
    .io_memWrReq_payload_lastBe    (memWrFifo_io_pop_payload_lastBe[3:0]   ), //i
    .io_memWrReq_payload_tc        (memWrFifo_io_pop_payload_tc[2:0]       ), //i
    .io_memWrReq_payload_attr      (memWrFifo_io_pop_payload_attr[1:0]     ), //i
    .io_memWrReq_payload_data_0    (memWrFifo_io_pop_payload_data_0[31:0]  ), //i
    .io_memWrReq_payload_data_1    (memWrFifo_io_pop_payload_data_1[31:0]  ), //i
    .io_memWrReq_payload_data_2    (memWrFifo_io_pop_payload_data_2[31:0]  ), //i
    .io_memWrReq_payload_data_3    (memWrFifo_io_pop_payload_data_3[31:0]  ), //i
    .io_memWrReq_payload_dataValid (memWrFifo_io_pop_payload_dataValid[2:0]), //i
    .io_memRdReq_valid             (memRdFifo_io_pop_valid                 ), //i
    .io_memRdReq_ready             (engine_io_memRdReq_ready               ), //o
    .io_memRdReq_payload_tlpType   (memRdFifo_io_pop_payload_tlpType[3:0]  ), //i
    .io_memRdReq_payload_reqId     (memRdFifo_io_pop_payload_reqId[15:0]   ), //i
    .io_memRdReq_payload_tag       (memRdFifo_io_pop_payload_tag[7:0]      ), //i
    .io_memRdReq_payload_addr      (memRdFifo_io_pop_payload_addr[63:0]    ), //i
    .io_memRdReq_payload_length    (memRdFifo_io_pop_payload_length[9:0]   ), //i
    .io_memRdReq_payload_firstBe   (memRdFifo_io_pop_payload_firstBe[3:0]  ), //i
    .io_memRdReq_payload_lastBe    (memRdFifo_io_pop_payload_lastBe[3:0]   ), //i
    .io_memRdReq_payload_tc        (memRdFifo_io_pop_payload_tc[2:0]       ), //i
    .io_memRdReq_payload_attr      (memRdFifo_io_pop_payload_attr[1:0]     ), //i
    .io_memRdReq_payload_data_0    (memRdFifo_io_pop_payload_data_0[31:0]  ), //i
    .io_memRdReq_payload_data_1    (memRdFifo_io_pop_payload_data_1[31:0]  ), //i
    .io_memRdReq_payload_data_2    (memRdFifo_io_pop_payload_data_2[31:0]  ), //i
    .io_memRdReq_payload_data_3    (memRdFifo_io_pop_payload_data_3[31:0]  ), //i
    .io_memRdReq_payload_dataValid (memRdFifo_io_pop_payload_dataValid[2:0]), //i
    .io_cplReq_valid               (cplFifo_io_pop_valid                   ), //i
    .io_cplReq_ready               (engine_io_cplReq_ready                 ), //o
    .io_cplReq_payload_tlpType     (cplFifo_io_pop_payload_tlpType[3:0]    ), //i
    .io_cplReq_payload_reqId       (cplFifo_io_pop_payload_reqId[15:0]     ), //i
    .io_cplReq_payload_tag         (cplFifo_io_pop_payload_tag[7:0]        ), //i
    .io_cplReq_payload_addr        (cplFifo_io_pop_payload_addr[63:0]      ), //i
    .io_cplReq_payload_length      (cplFifo_io_pop_payload_length[9:0]     ), //i
    .io_cplReq_payload_firstBe     (cplFifo_io_pop_payload_firstBe[3:0]    ), //i
    .io_cplReq_payload_lastBe      (cplFifo_io_pop_payload_lastBe[3:0]     ), //i
    .io_cplReq_payload_tc          (cplFifo_io_pop_payload_tc[2:0]         ), //i
    .io_cplReq_payload_attr        (cplFifo_io_pop_payload_attr[1:0]       ), //i
    .io_cplReq_payload_data_0      (cplFifo_io_pop_payload_data_0[31:0]    ), //i
    .io_cplReq_payload_data_1      (cplFifo_io_pop_payload_data_1[31:0]    ), //i
    .io_cplReq_payload_data_2      (cplFifo_io_pop_payload_data_2[31:0]    ), //i
    .io_cplReq_payload_data_3      (cplFifo_io_pop_payload_data_3[31:0]    ), //i
    .io_cplReq_payload_dataValid   (cplFifo_io_pop_payload_dataValid[2:0]  ), //i
    .io_tlpOut_valid               (engine_io_tlpOut_valid                 ), //o
    .io_tlpOut_ready               (io_tlpOut_ready                        ), //i
    .io_tlpOut_payload             (engine_io_tlpOut_payload[31:0]         ), //o
    .io_fcCredits_phCredits        (io_fcCredits_phCredits[7:0]            ), //i
    .io_fcCredits_pdCredits        (io_fcCredits_pdCredits[11:0]           ), //i
    .io_fcCredits_nphCredits       (io_fcCredits_nphCredits[7:0]           ), //i
    .io_fcCredits_npdCredits       (io_fcCredits_npdCredits[11:0]          ), //i
    .io_fcCredits_cplhCredits      (io_fcCredits_cplhCredits[7:0]          ), //i
    .io_fcCredits_cpldCredits      (io_fcCredits_cpldCredits[11:0]         ), //i
    .clk                           (clk                                    ), //i
    .reset                         (reset                                  )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_memWrIn_payload_tlpType)
      TlpType_MEM_RD : io_memWrIn_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memWrIn_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memWrIn_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memWrIn_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memWrIn_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memWrIn_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memWrIn_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memWrIn_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memWrIn_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memWrIn_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memWrIn_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memWrIn_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memWrIn_payload_tlpType_string = "INVALID";
      default : io_memWrIn_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_memRdIn_payload_tlpType)
      TlpType_MEM_RD : io_memRdIn_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memRdIn_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memRdIn_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memRdIn_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memRdIn_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memRdIn_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memRdIn_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memRdIn_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memRdIn_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memRdIn_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memRdIn_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memRdIn_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memRdIn_payload_tlpType_string = "INVALID";
      default : io_memRdIn_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cplIn_payload_tlpType)
      TlpType_MEM_RD : io_cplIn_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cplIn_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cplIn_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cplIn_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cplIn_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cplIn_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cplIn_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cplIn_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cplIn_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cplIn_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cplIn_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cplIn_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cplIn_payload_tlpType_string = "INVALID";
      default : io_cplIn_payload_tlpType_string = "???????";
    endcase
  end
  `endif

  assign io_memWrIn_ready = memWrFifo_io_push_ready;
  assign io_memRdIn_ready = memRdFifo_io_push_ready;
  assign io_cplIn_ready = cplFifo_io_push_ready;
  assign io_tlpOut_valid = engine_io_tlpOut_valid;
  assign io_tlpOut_payload = engine_io_tlpOut_payload;
  assign memWrFifo_io_flush = 1'b0;
  assign memRdFifo_io_flush = 1'b0;
  assign cplFifo_io_flush = 1'b0;

endmodule

module FlowControlMgr (
  input  wire          io_init,
  input  wire          io_linkUp,
  input  wire [7:0]    io_phConsumed,
  input  wire [11:0]   io_pdConsumed,
  input  wire [7:0]    io_nphConsumed,
  input  wire [11:0]   io_npdConsumed,
  input  wire [7:0]    io_cplhConsumed,
  input  wire [11:0]   io_cpldConsumed,
  input  wire          io_fcUpdateValid,
  input  wire [7:0]    io_fcUpdate_phCredits,
  input  wire [11:0]   io_fcUpdate_pdCredits,
  input  wire [7:0]    io_fcUpdate_nphCredits,
  input  wire [11:0]   io_fcUpdate_npdCredits,
  input  wire [7:0]    io_fcUpdate_cplhCredits,
  input  wire [11:0]   io_fcUpdate_cpldCredits,
  input  wire          io_fcInitValid,
  input  wire [7:0]    io_fcInit_phCredits,
  input  wire [11:0]   io_fcInit_pdCredits,
  input  wire [7:0]    io_fcInit_nphCredits,
  input  wire [11:0]   io_fcInit_npdCredits,
  input  wire [7:0]    io_fcInit_cplhCredits,
  input  wire [11:0]   io_fcInit_cpldCredits,
  output wire [7:0]    io_available_phCredits,
  output wire [11:0]   io_available_pdCredits,
  output wire [7:0]    io_available_nphCredits,
  output wire [11:0]   io_available_npdCredits,
  output wire [7:0]    io_available_cplhCredits,
  output wire [11:0]   io_available_cpldCredits,
  output wire          io_phExhausted,
  output wire          io_nphExhausted,
  output wire          io_cplhExhausted,
  input  wire          clk,
  input  wire          reset
);

  wire       [7:0]    _zz_ph;
  wire       [11:0]   _zz_pd;
  wire       [7:0]    _zz_nph;
  wire       [11:0]   _zz_npd;
  wire       [7:0]    _zz_cplh;
  wire       [11:0]   _zz_cpld;
  reg        [7:0]    ph;
  reg        [7:0]    nph;
  reg        [7:0]    cplh;
  reg        [11:0]   pd;
  reg        [11:0]   npd;
  reg        [11:0]   cpld;
  reg                 cplhInfinite;
  reg                 cpldInfinite;
  wire                when_DataLinkLayer_l203;
  wire                when_DataLinkLayer_l225;
  wire                when_DataLinkLayer_l230;
  wire                when_DataLinkLayer_l238;
  wire                when_DataLinkLayer_l241;
  wire                when_DataLinkLayer_l244;
  wire                when_DataLinkLayer_l247;
  wire                when_DataLinkLayer_l250;
  wire                when_DataLinkLayer_l253;

  assign _zz_ph = (ph - io_phConsumed);
  assign _zz_pd = (pd - io_pdConsumed);
  assign _zz_nph = (nph - io_nphConsumed);
  assign _zz_npd = (npd - io_npdConsumed);
  assign _zz_cplh = (cplh - io_cplhConsumed);
  assign _zz_cpld = (cpld - io_cpldConsumed);
  assign when_DataLinkLayer_l203 = (io_init || (! io_linkUp));
  assign when_DataLinkLayer_l225 = (! cplhInfinite);
  assign when_DataLinkLayer_l230 = (! cpldInfinite);
  assign when_DataLinkLayer_l238 = (8'h00 < io_phConsumed);
  assign when_DataLinkLayer_l241 = (12'h000 < io_pdConsumed);
  assign when_DataLinkLayer_l244 = (8'h00 < io_nphConsumed);
  assign when_DataLinkLayer_l247 = (12'h000 < io_npdConsumed);
  assign when_DataLinkLayer_l250 = ((8'h00 < io_cplhConsumed) && (! cplhInfinite));
  assign when_DataLinkLayer_l253 = ((12'h000 < io_cpldConsumed) && (! cpldInfinite));
  assign io_available_phCredits = ph;
  assign io_available_nphCredits = nph;
  assign io_available_cplhCredits = (cplhInfinite ? 8'hff : cplh);
  assign io_available_pdCredits = pd;
  assign io_available_npdCredits = npd;
  assign io_available_cpldCredits = (cpldInfinite ? 12'hfff : cpld);
  assign io_phExhausted = (ph == 8'h00);
  assign io_nphExhausted = (nph == 8'h00);
  assign io_cplhExhausted = ((cplh == 8'h00) && (! cplhInfinite));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      ph <= 8'h10;
      nph <= 8'h10;
      cplh <= 8'h10;
      pd <= 12'h200;
      npd <= 12'h200;
      cpld <= 12'h200;
      cplhInfinite <= 1'b0;
      cpldInfinite <= 1'b0;
    end else begin
      if(when_DataLinkLayer_l203) begin
        ph <= 8'h00;
        nph <= 8'h00;
        cplh <= 8'h00;
        pd <= 12'h000;
        npd <= 12'h000;
        cpld <= 12'h000;
        cplhInfinite <= 1'b0;
        cpldInfinite <= 1'b0;
      end
      if(io_fcInitValid) begin
        ph <= io_fcInit_phCredits;
        nph <= io_fcInit_nphCredits;
        cplh <= io_fcInit_cplhCredits;
        pd <= io_fcInit_pdCredits;
        npd <= io_fcInit_npdCredits;
        cpld <= io_fcInit_cpldCredits;
        cplhInfinite <= io_fcInit_cplhCredits[7];
        cpldInfinite <= io_fcInit_cpldCredits[11];
      end
      if(io_fcUpdateValid) begin
        if(when_DataLinkLayer_l225) begin
          ph <= (ph + io_fcUpdate_phCredits);
          nph <= (nph + io_fcUpdate_nphCredits);
          cplh <= (cplh + io_fcUpdate_cplhCredits);
        end
        if(when_DataLinkLayer_l230) begin
          pd <= (pd + io_fcUpdate_pdCredits);
          npd <= (npd + io_fcUpdate_npdCredits);
          cpld <= (cpld + io_fcUpdate_cpldCredits);
        end
      end
      if(when_DataLinkLayer_l238) begin
        ph <= ((io_phConsumed <= ph) ? _zz_ph : 8'h00);
      end
      if(when_DataLinkLayer_l241) begin
        pd <= ((io_pdConsumed <= pd) ? _zz_pd : 12'h000);
      end
      if(when_DataLinkLayer_l244) begin
        nph <= ((io_nphConsumed <= nph) ? _zz_nph : 8'h00);
      end
      if(when_DataLinkLayer_l247) begin
        npd <= ((io_npdConsumed <= npd) ? _zz_npd : 12'h000);
      end
      if(when_DataLinkLayer_l250) begin
        cplh <= ((io_cplhConsumed <= cplh) ? _zz_cplh : 8'h00);
      end
      if(when_DataLinkLayer_l253) begin
        cpld <= ((io_cpldConsumed <= cpld) ? _zz_cpld : 12'h000);
      end
    end
  end


endmodule

module DllpHandler (
  input  wire          io_dllpIn_valid,
  output wire          io_dllpIn_ready,
  input  wire [31:0]   io_dllpIn_payload,
  input  wire          io_dllpValid,
  output reg  [11:0]   io_ackSeq,
  output reg           io_ackValid,
  output reg  [11:0]   io_nakSeq,
  output reg           io_nakValid,
  output reg           io_fcInitValid,
  output reg  [7:0]    io_fcInit_phCredits,
  output reg  [11:0]   io_fcInit_pdCredits,
  output reg  [7:0]    io_fcInit_nphCredits,
  output reg  [11:0]   io_fcInit_npdCredits,
  output reg  [7:0]    io_fcInit_cplhCredits,
  output reg  [11:0]   io_fcInit_cpldCredits,
  output reg           io_fcUpdateValid,
  output reg  [7:0]    io_fcUpdate_phCredits,
  output reg  [11:0]   io_fcUpdate_pdCredits,
  output wire [7:0]    io_fcUpdate_nphCredits,
  output wire [11:0]   io_fcUpdate_npdCredits,
  output wire [7:0]    io_fcUpdate_cplhCredits,
  output wire [11:0]   io_fcUpdate_cpldCredits,
  output reg           io_pmEnterL1
);

  wire       [7:0]    _zz_io_fcInit_phCredits;
  wire       [7:0]    _zz_io_fcInit_nphCredits;
  wire       [7:0]    _zz_io_fcInit_cplhCredits;
  wire       [3:0]    _zz_io_fcUpdate_phCredits;
  wire       [3:0]    dllpType;
  wire       [23:0]   dllpData;
  wire                io_dllpIn_fire;
  wire                when_DataLinkLayer_l323;

  assign _zz_io_fcInit_phCredits = {dllpData[3 : 0],dllpData[7 : 4]};
  assign _zz_io_fcInit_nphCredits = {dllpData[3 : 0],dllpData[7 : 4]};
  assign _zz_io_fcInit_cplhCredits = {dllpData[3 : 0],dllpData[7 : 4]};
  assign _zz_io_fcUpdate_phCredits = dllpData[3 : 0];
  assign dllpType = io_dllpIn_payload[31 : 28];
  assign dllpData = io_dllpIn_payload[27 : 4];
  always @(*) begin
    io_ackValid = 1'b0;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b0000 : begin
          io_ackValid = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_nakValid = 1'b0;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b0001 : begin
          io_nakValid = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_ackSeq = 12'h000;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b0000 : begin
          io_ackSeq = dllpData[11 : 0];
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_nakSeq = 12'h000;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b0001 : begin
          io_nakSeq = dllpData[11 : 0];
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInitValid = 1'b0;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1011 : begin
          io_fcInitValid = 1'b1;
        end
        4'b1100 : begin
          io_fcInitValid = 1'b1;
        end
        4'b1101 : begin
          io_fcInitValid = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcUpdateValid = 1'b0;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1110 : begin
          io_fcUpdateValid = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_pmEnterL1 = 1'b0;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b0010 : begin
          io_pmEnterL1 = 1'b1;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_phCredits = 8'h00;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1011 : begin
          io_fcInit_phCredits = _zz_io_fcInit_phCredits;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_nphCredits = 8'h00;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1100 : begin
          io_fcInit_nphCredits = _zz_io_fcInit_nphCredits;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_cplhCredits = 8'h00;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1101 : begin
          io_fcInit_cplhCredits = _zz_io_fcInit_cplhCredits;
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_pdCredits = 12'h000;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1011 : begin
          io_fcInit_pdCredits = dllpData[19 : 8];
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_npdCredits = 12'h000;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1100 : begin
          io_fcInit_npdCredits = dllpData[19 : 8];
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcInit_cpldCredits = 12'h000;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1101 : begin
          io_fcInit_cpldCredits = dllpData[19 : 8];
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcUpdate_phCredits = io_fcInit_phCredits;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1110 : begin
          io_fcUpdate_phCredits = {4'd0, _zz_io_fcUpdate_phCredits};
        end
        default : begin
        end
      endcase
    end
  end

  always @(*) begin
    io_fcUpdate_pdCredits = io_fcInit_pdCredits;
    if(when_DataLinkLayer_l323) begin
      case(dllpType)
        4'b1110 : begin
          io_fcUpdate_pdCredits = dllpData[15 : 4];
        end
        default : begin
        end
      endcase
    end
  end

  assign io_fcUpdate_nphCredits = io_fcInit_nphCredits;
  assign io_fcUpdate_npdCredits = io_fcInit_npdCredits;
  assign io_fcUpdate_cplhCredits = io_fcInit_cplhCredits;
  assign io_fcUpdate_cpldCredits = io_fcInit_cpldCredits;
  assign io_dllpIn_fire = (io_dllpIn_valid && io_dllpIn_ready);
  assign when_DataLinkLayer_l323 = (io_dllpValid && io_dllpIn_fire);
  assign io_dllpIn_ready = 1'b1;

endmodule

module DlRxDeframer (
  input  wire          io_frameIn_valid,
  output wire          io_frameIn_ready,
  input  wire [31:0]   io_frameIn_payload,
  output reg           io_tlpOut_valid,
  input  wire          io_tlpOut_ready,
  output reg  [31:0]   io_tlpOut_payload,
  output reg  [11:0]   io_txAck,
  output reg  [11:0]   io_txNak,
  output reg           io_ackValid,
  output reg           io_nakValid,
  output reg           io_crcErr,
  input  wire          clk,
  input  wire          reset
);
  localparam St_1_IDLE = 2'd0;
  localparam St_1_RX_SEQ = 2'd1;
  localparam St_1_DATA = 2'd2;
  localparam St_1_CHECK = 2'd3;

  wire       [31:0]   _zz__zz_1_port0;
  wire       [31:0]   _zz__zz_3_port0;
  wire       [31:0]   _zz__zz_5_port0;
  wire       [31:0]   _zz__zz_7_port0;
  wire       [31:0]   _zz__zz_9_port0;
  wire       [31:0]   _zz__zz_11_port0;
  wire       [31:0]   _zz__zz_13_port0;
  wire       [31:0]   _zz__zz_15_port0;
  wire       [11:0]   _zz_rxSeq;
  wire       [7:0]    _zz__zz_crc;
  wire       [31:0]   _zz__zz_crc_1;
  wire       [23:0]   _zz__zz_crc_1_1;
  wire       [7:0]    _zz__zz_crc_2;
  wire       [31:0]   _zz__zz_crc_3;
  wire       [23:0]   _zz__zz_crc_3_1;
  wire       [7:0]    _zz__zz_crc_4;
  wire       [31:0]   _zz__zz_crc_5;
  wire       [23:0]   _zz__zz_crc_5_1;
  wire       [7:0]    _zz__zz_crc_6;
  wire       [31:0]   _zz_crc_14;
  wire       [23:0]   _zz_crc_15;
  wire       [7:0]    _zz__zz_crc_7;
  wire       [31:0]   _zz__zz_crc_8;
  wire       [23:0]   _zz__zz_crc_8_1;
  wire       [7:0]    _zz__zz_crc_9;
  wire       [31:0]   _zz__zz_crc_10;
  wire       [23:0]   _zz__zz_crc_10_1;
  wire       [7:0]    _zz__zz_crc_11;
  wire       [31:0]   _zz__zz_crc_12;
  wire       [23:0]   _zz__zz_crc_12_1;
  wire       [7:0]    _zz__zz_crc_13;
  wire       [31:0]   _zz_crc_16;
  wire       [23:0]   _zz_crc_17;
  reg        [1:0]    state;
  reg        [31:0]   crc;
  reg        [11:0]   rxSeq;
  reg        [11:0]   expSeq;
  reg        [31:0]   prevData;
  reg                 prevVld;
  wire                io_frameIn_fire;
  wire       [7:0]    _zz_crc;
  wire       [31:0]   _zz_crc_1;
  wire       [7:0]    _zz_crc_2;
  wire       [31:0]   _zz_crc_3;
  wire       [7:0]    _zz_crc_4;
  wire       [31:0]   _zz_crc_5;
  wire       [7:0]    _zz_crc_6;
  wire       [7:0]    _zz_crc_7;
  wire       [31:0]   _zz_crc_8;
  wire       [7:0]    _zz_crc_9;
  wire       [31:0]   _zz_crc_10;
  wire       [7:0]    _zz_crc_11;
  wire       [31:0]   _zz_crc_12;
  wire       [7:0]    _zz_crc_13;
  wire                when_DataLinkLayer_l148;
  `ifndef SYNTHESIS
  reg [47:0] state_string;
  `endif

  reg [31:0] _zz_1 [0:255];
  reg [31:0] _zz_3 [0:255];
  reg [31:0] _zz_5 [0:255];
  reg [31:0] _zz_7 [0:255];
  reg [31:0] _zz_9 [0:255];
  reg [31:0] _zz_11 [0:255];
  reg [31:0] _zz_13 [0:255];
  reg [31:0] _zz_15 [0:255];

  assign _zz_rxSeq = io_frameIn_payload[23 : 12];
  assign _zz__zz_crc = (crc[7 : 0] ^ io_frameIn_payload[7 : 0]);
  assign _zz__zz_crc_1_1 = (crc >>> 4'd8);
  assign _zz__zz_crc_1 = {8'd0, _zz__zz_crc_1_1};
  assign _zz__zz_crc_2 = (_zz_crc_1[7 : 0] ^ io_frameIn_payload[15 : 8]);
  assign _zz__zz_crc_3_1 = (_zz_crc_1 >>> 4'd8);
  assign _zz__zz_crc_3 = {8'd0, _zz__zz_crc_3_1};
  assign _zz__zz_crc_4 = (_zz_crc_3[7 : 0] ^ io_frameIn_payload[23 : 16]);
  assign _zz__zz_crc_5_1 = (_zz_crc_3 >>> 4'd8);
  assign _zz__zz_crc_5 = {8'd0, _zz__zz_crc_5_1};
  assign _zz__zz_crc_6 = (_zz_crc_5[7 : 0] ^ io_frameIn_payload[31 : 24]);
  assign _zz_crc_15 = (_zz_crc_5 >>> 4'd8);
  assign _zz_crc_14 = {8'd0, _zz_crc_15};
  assign _zz__zz_crc_7 = (crc[7 : 0] ^ io_frameIn_payload[7 : 0]);
  assign _zz__zz_crc_8_1 = (crc >>> 4'd8);
  assign _zz__zz_crc_8 = {8'd0, _zz__zz_crc_8_1};
  assign _zz__zz_crc_9 = (_zz_crc_8[7 : 0] ^ io_frameIn_payload[15 : 8]);
  assign _zz__zz_crc_10_1 = (_zz_crc_8 >>> 4'd8);
  assign _zz__zz_crc_10 = {8'd0, _zz__zz_crc_10_1};
  assign _zz__zz_crc_11 = (_zz_crc_10[7 : 0] ^ io_frameIn_payload[23 : 16]);
  assign _zz__zz_crc_12_1 = (_zz_crc_10 >>> 4'd8);
  assign _zz__zz_crc_12 = {8'd0, _zz__zz_crc_12_1};
  assign _zz__zz_crc_13 = (_zz_crc_12[7 : 0] ^ io_frameIn_payload[31 : 24]);
  assign _zz_crc_17 = (_zz_crc_12 >>> 4'd8);
  assign _zz_crc_16 = {8'd0, _zz_crc_17};
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_1.bin",_zz_1);
  end
  assign _zz__zz_1_port0 = _zz_1[_zz_crc];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_3.bin",_zz_3);
  end
  assign _zz__zz_3_port0 = _zz_3[_zz_crc_2];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_5.bin",_zz_5);
  end
  assign _zz__zz_5_port0 = _zz_5[_zz_crc_4];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_7.bin",_zz_7);
  end
  assign _zz__zz_7_port0 = _zz_7[_zz_crc_6];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_9.bin",_zz_9);
  end
  assign _zz__zz_9_port0 = _zz_9[_zz_crc_7];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_11.bin",_zz_11);
  end
  assign _zz__zz_11_port0 = _zz_11[_zz_crc_9];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_13.bin",_zz_13);
  end
  assign _zz__zz_13_port0 = _zz_13[_zz_crc_11];
  initial begin
    $readmemb("PcieController.v_toplevel_dlRx__zz_15.bin",_zz_15);
  end
  assign _zz__zz_15_port0 = _zz_15[_zz_crc_13];
  `ifndef SYNTHESIS
  always @(*) begin
    case(state)
      St_1_IDLE : state_string = "IDLE  ";
      St_1_RX_SEQ : state_string = "RX_SEQ";
      St_1_DATA : state_string = "DATA  ";
      St_1_CHECK : state_string = "CHECK ";
      default : state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    io_txAck = expSeq;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
      end
      default : begin
        if(when_DataLinkLayer_l148) begin
          io_txAck = rxSeq;
        end
      end
    endcase
  end

  always @(*) begin
    io_txNak = 12'h000;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
      end
      default : begin
        if(!when_DataLinkLayer_l148) begin
          io_txNak = rxSeq;
        end
      end
    endcase
  end

  always @(*) begin
    io_ackValid = 1'b0;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
      end
      default : begin
        if(when_DataLinkLayer_l148) begin
          io_ackValid = 1'b1;
        end
      end
    endcase
  end

  always @(*) begin
    io_nakValid = 1'b0;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
      end
      default : begin
        if(!when_DataLinkLayer_l148) begin
          io_nakValid = 1'b1;
        end
      end
    endcase
  end

  always @(*) begin
    io_crcErr = 1'b0;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
      end
      default : begin
        if(!when_DataLinkLayer_l148) begin
          io_crcErr = ((~ crc) != prevData);
        end
      end
    endcase
  end

  always @(*) begin
    io_tlpOut_valid = 1'b0;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
        if(io_frameIn_valid) begin
          if(prevVld) begin
            io_tlpOut_valid = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_tlpOut_payload = prevData;
    case(state)
      St_1_IDLE : begin
      end
      St_1_RX_SEQ : begin
      end
      St_1_DATA : begin
        if(io_frameIn_valid) begin
          if(prevVld) begin
            io_tlpOut_payload = prevData;
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign io_frameIn_ready = ((! io_tlpOut_valid) || io_tlpOut_ready);
  assign io_frameIn_fire = (io_frameIn_valid && io_frameIn_ready);
  assign _zz_crc = _zz__zz_crc;
  assign _zz_crc_1 = (_zz__zz_crc_1 ^ _zz__zz_1_port0);
  assign _zz_crc_2 = _zz__zz_crc_2;
  assign _zz_crc_3 = (_zz__zz_crc_3 ^ _zz__zz_3_port0);
  assign _zz_crc_4 = _zz__zz_crc_4;
  assign _zz_crc_5 = (_zz__zz_crc_5 ^ _zz__zz_5_port0);
  assign _zz_crc_6 = _zz__zz_crc_6;
  assign _zz_crc_7 = _zz__zz_crc_7;
  assign _zz_crc_8 = (_zz__zz_crc_8 ^ _zz__zz_9_port0);
  assign _zz_crc_9 = _zz__zz_crc_9;
  assign _zz_crc_10 = (_zz__zz_crc_10 ^ _zz__zz_11_port0);
  assign _zz_crc_11 = _zz__zz_crc_11;
  assign _zz_crc_12 = (_zz__zz_crc_12 ^ _zz__zz_13_port0);
  assign _zz_crc_13 = _zz__zz_crc_13;
  assign when_DataLinkLayer_l148 = (((~ crc) == prevData) && (rxSeq == expSeq));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= St_1_IDLE;
      crc <= 32'hffffffff;
      rxSeq <= 12'h000;
      expSeq <= 12'h000;
      prevData <= 32'h00000000;
      prevVld <= 1'b0;
    end else begin
      case(state)
        St_1_IDLE : begin
          if(io_frameIn_valid) begin
            crc <= 32'hffffffff;
            prevVld <= 1'b0;
            state <= St_1_RX_SEQ;
          end
        end
        St_1_RX_SEQ : begin
          if(io_frameIn_fire) begin
            rxSeq <= _zz_rxSeq;
            crc <= (_zz_crc_14 ^ _zz__zz_7_port0);
            state <= St_1_DATA;
          end
        end
        St_1_DATA : begin
          if(io_frameIn_valid) begin
            if(io_frameIn_ready) begin
              crc <= (_zz_crc_16 ^ _zz__zz_15_port0);
              prevData <= io_frameIn_payload;
              prevVld <= 1'b1;
            end
          end else begin
            if(prevVld) begin
              state <= St_1_CHECK;
            end
          end
        end
        default : begin
          if(when_DataLinkLayer_l148) begin
            expSeq <= (expSeq + 12'h001);
          end
          prevVld <= 1'b0;
          state <= St_1_IDLE;
        end
      endcase
    end
  end


endmodule

module DlTxFramer (
  input  wire          io_tlpIn_valid,
  output reg           io_tlpIn_ready,
  input  wire [31:0]   io_tlpIn_payload,
  output reg           io_frameOut_valid,
  input  wire          io_frameOut_ready,
  output reg  [31:0]   io_frameOut_payload,
  input  wire [11:0]   io_seqAck,
  output wire [11:0]   io_nextSeq,
  input  wire          clk,
  input  wire          reset
);
  localparam St_IDLE = 2'd0;
  localparam St_SEND_SEQ = 2'd1;
  localparam St_FWD = 2'd2;
  localparam St_LCRC = 2'd3;

  wire       [31:0]   _zz__zz_3_port0;
  wire       [31:0]   _zz__zz_5_port0;
  wire       [31:0]   _zz__zz_7_port0;
  wire       [31:0]   _zz__zz_9_port0;
  wire       [31:0]   _zz__zz_11_port0;
  wire       [31:0]   _zz__zz_13_port0;
  wire       [31:0]   _zz__zz_15_port0;
  wire       [31:0]   _zz__zz_17_port0;
  wire       [7:0]    _zz__zz_crc;
  wire       [31:0]   _zz__zz_crc_1;
  wire       [23:0]   _zz__zz_crc_1_1;
  wire       [7:0]    _zz__zz_crc_2;
  wire       [31:0]   _zz__zz_crc_3;
  wire       [23:0]   _zz__zz_crc_3_1;
  wire       [7:0]    _zz__zz_crc_4;
  wire       [31:0]   _zz__zz_crc_5;
  wire       [23:0]   _zz__zz_crc_5_1;
  wire       [7:0]    _zz__zz_crc_6;
  wire       [31:0]   _zz_crc_14;
  wire       [23:0]   _zz_crc_15;
  wire       [7:0]    _zz__zz_crc_7;
  wire       [31:0]   _zz__zz_crc_8;
  wire       [23:0]   _zz__zz_crc_8_1;
  wire       [7:0]    _zz__zz_crc_9;
  wire       [31:0]   _zz__zz_crc_10;
  wire       [23:0]   _zz__zz_crc_10_1;
  wire       [7:0]    _zz__zz_crc_11;
  wire       [31:0]   _zz__zz_crc_12;
  wire       [23:0]   _zz__zz_crc_12_1;
  wire       [7:0]    _zz__zz_crc_13;
  wire       [31:0]   _zz_crc_16;
  wire       [23:0]   _zz_crc_17;
  reg                 _zz_1;
  reg        [11:0]   txSeq;
  reg        [1:0]    state;
  reg        [31:0]   crc;
  reg        [7:0]    replayWPtr;
  wire       [31:0]   _zz_io_frameOut_payload;
  wire       [7:0]    _zz_crc;
  wire       [31:0]   _zz_crc_1;
  wire       [7:0]    _zz_crc_2;
  wire       [31:0]   _zz_crc_3;
  wire       [7:0]    _zz_crc_4;
  wire       [31:0]   _zz_crc_5;
  wire       [7:0]    _zz_crc_6;
  wire                io_tlpIn_fire;
  wire       [7:0]    _zz_crc_7;
  wire       [31:0]   _zz_crc_8;
  wire       [7:0]    _zz_crc_9;
  wire       [31:0]   _zz_crc_10;
  wire       [7:0]    _zz_crc_11;
  wire       [31:0]   _zz_crc_12;
  wire       [7:0]    _zz_crc_13;
  reg                 io_tlpIn_valid_regNext;
  wire                when_DataLinkLayer_l78;
  `ifndef SYNTHESIS
  reg [63:0] state_string;
  `endif

  reg [31:0] replayMem [0:255];
  reg [31:0] _zz_3 [0:255];
  reg [31:0] _zz_5 [0:255];
  reg [31:0] _zz_7 [0:255];
  reg [31:0] _zz_9 [0:255];
  reg [31:0] _zz_11 [0:255];
  reg [31:0] _zz_13 [0:255];
  reg [31:0] _zz_15 [0:255];
  reg [31:0] _zz_17 [0:255];

  assign _zz__zz_crc = (crc[7 : 0] ^ _zz_io_frameOut_payload[7 : 0]);
  assign _zz__zz_crc_1_1 = (crc >>> 4'd8);
  assign _zz__zz_crc_1 = {8'd0, _zz__zz_crc_1_1};
  assign _zz__zz_crc_2 = (_zz_crc_1[7 : 0] ^ _zz_io_frameOut_payload[15 : 8]);
  assign _zz__zz_crc_3_1 = (_zz_crc_1 >>> 4'd8);
  assign _zz__zz_crc_3 = {8'd0, _zz__zz_crc_3_1};
  assign _zz__zz_crc_4 = (_zz_crc_3[7 : 0] ^ _zz_io_frameOut_payload[23 : 16]);
  assign _zz__zz_crc_5_1 = (_zz_crc_3 >>> 4'd8);
  assign _zz__zz_crc_5 = {8'd0, _zz__zz_crc_5_1};
  assign _zz__zz_crc_6 = (_zz_crc_5[7 : 0] ^ _zz_io_frameOut_payload[31 : 24]);
  assign _zz_crc_15 = (_zz_crc_5 >>> 4'd8);
  assign _zz_crc_14 = {8'd0, _zz_crc_15};
  assign _zz__zz_crc_7 = (crc[7 : 0] ^ io_tlpIn_payload[7 : 0]);
  assign _zz__zz_crc_8_1 = (crc >>> 4'd8);
  assign _zz__zz_crc_8 = {8'd0, _zz__zz_crc_8_1};
  assign _zz__zz_crc_9 = (_zz_crc_8[7 : 0] ^ io_tlpIn_payload[15 : 8]);
  assign _zz__zz_crc_10_1 = (_zz_crc_8 >>> 4'd8);
  assign _zz__zz_crc_10 = {8'd0, _zz__zz_crc_10_1};
  assign _zz__zz_crc_11 = (_zz_crc_10[7 : 0] ^ io_tlpIn_payload[23 : 16]);
  assign _zz__zz_crc_12_1 = (_zz_crc_10 >>> 4'd8);
  assign _zz__zz_crc_12 = {8'd0, _zz__zz_crc_12_1};
  assign _zz__zz_crc_13 = (_zz_crc_12[7 : 0] ^ io_tlpIn_payload[31 : 24]);
  assign _zz_crc_17 = (_zz_crc_12 >>> 4'd8);
  assign _zz_crc_16 = {8'd0, _zz_crc_17};
  always @(posedge clk) begin
    if(_zz_1) begin
      replayMem[replayWPtr] <= io_tlpIn_payload;
    end
  end

  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_3.bin",_zz_3);
  end
  assign _zz__zz_3_port0 = _zz_3[_zz_crc];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_5.bin",_zz_5);
  end
  assign _zz__zz_5_port0 = _zz_5[_zz_crc_2];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_7.bin",_zz_7);
  end
  assign _zz__zz_7_port0 = _zz_7[_zz_crc_4];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_9.bin",_zz_9);
  end
  assign _zz__zz_9_port0 = _zz_9[_zz_crc_6];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_11.bin",_zz_11);
  end
  assign _zz__zz_11_port0 = _zz_11[_zz_crc_7];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_13.bin",_zz_13);
  end
  assign _zz__zz_13_port0 = _zz_13[_zz_crc_9];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_15.bin",_zz_15);
  end
  assign _zz__zz_15_port0 = _zz_15[_zz_crc_11];
  initial begin
    $readmemb("PcieController.v_toplevel_dlTx__zz_17.bin",_zz_17);
  end
  assign _zz__zz_17_port0 = _zz_17[_zz_crc_13];
  `ifndef SYNTHESIS
  always @(*) begin
    case(state)
      St_IDLE : state_string = "IDLE    ";
      St_SEND_SEQ : state_string = "SEND_SEQ";
      St_FWD : state_string = "FWD     ";
      St_LCRC : state_string = "LCRC    ";
      default : state_string = "????????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    case(state)
      St_IDLE : begin
      end
      St_SEND_SEQ : begin
      end
      St_FWD : begin
        if(io_tlpIn_fire) begin
          _zz_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign io_nextSeq = txSeq;
  always @(*) begin
    io_frameOut_valid = 1'b0;
    case(state)
      St_IDLE : begin
      end
      St_SEND_SEQ : begin
        io_frameOut_valid = 1'b1;
      end
      St_FWD : begin
        io_frameOut_valid = io_tlpIn_valid;
      end
      default : begin
        io_frameOut_valid = 1'b1;
      end
    endcase
  end

  always @(*) begin
    io_frameOut_payload = 32'h00000000;
    case(state)
      St_IDLE : begin
      end
      St_SEND_SEQ : begin
        io_frameOut_payload = _zz_io_frameOut_payload;
      end
      St_FWD : begin
        io_frameOut_payload = io_tlpIn_payload;
      end
      default : begin
        io_frameOut_payload = (~ crc);
      end
    endcase
  end

  always @(*) begin
    io_tlpIn_ready = 1'b0;
    case(state)
      St_IDLE : begin
      end
      St_SEND_SEQ : begin
      end
      St_FWD : begin
        io_tlpIn_ready = io_frameOut_ready;
      end
      default : begin
      end
    endcase
  end

  assign _zz_io_frameOut_payload = {{{{8'haa,4'b0000},txSeq[11 : 8]},txSeq[7 : 0]},8'h00};
  assign _zz_crc = _zz__zz_crc;
  assign _zz_crc_1 = (_zz__zz_crc_1 ^ _zz__zz_3_port0);
  assign _zz_crc_2 = _zz__zz_crc_2;
  assign _zz_crc_3 = (_zz__zz_crc_3 ^ _zz__zz_5_port0);
  assign _zz_crc_4 = _zz__zz_crc_4;
  assign _zz_crc_5 = (_zz__zz_crc_5 ^ _zz__zz_7_port0);
  assign _zz_crc_6 = _zz__zz_crc_6;
  assign io_tlpIn_fire = (io_tlpIn_valid && io_tlpIn_ready);
  assign _zz_crc_7 = _zz__zz_crc_7;
  assign _zz_crc_8 = (_zz__zz_crc_8 ^ _zz__zz_11_port0);
  assign _zz_crc_9 = _zz__zz_crc_9;
  assign _zz_crc_10 = (_zz__zz_crc_10 ^ _zz__zz_13_port0);
  assign _zz_crc_11 = _zz__zz_crc_11;
  assign _zz_crc_12 = (_zz__zz_crc_12 ^ _zz__zz_15_port0);
  assign _zz_crc_13 = _zz__zz_crc_13;
  assign when_DataLinkLayer_l78 = ((! io_tlpIn_valid) && io_tlpIn_valid_regNext);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      txSeq <= 12'h000;
      state <= St_IDLE;
      crc <= 32'hffffffff;
      replayWPtr <= 8'h00;
    end else begin
      case(state)
        St_IDLE : begin
          if(io_tlpIn_valid) begin
            crc <= 32'hffffffff;
            state <= St_SEND_SEQ;
          end
        end
        St_SEND_SEQ : begin
          if(io_frameOut_ready) begin
            crc <= (_zz_crc_14 ^ _zz__zz_9_port0);
            state <= St_FWD;
          end
        end
        St_FWD : begin
          if(io_tlpIn_fire) begin
            crc <= (_zz_crc_16 ^ _zz__zz_17_port0);
            replayWPtr <= (replayWPtr + 8'h01);
          end
          if(when_DataLinkLayer_l78) begin
            state <= St_LCRC;
          end
        end
        default : begin
          if(io_frameOut_ready) begin
            txSeq <= (txSeq + 12'h001);
            state <= St_IDLE;
          end
        end
      endcase
    end
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_tlpIn_valid_regNext <= 1'b0;
    end else begin
      io_tlpIn_valid_regNext <= io_tlpIn_valid;
    end
  end


endmodule

module PhysicalLayer (
  input  wire          io_txData_valid,
  output reg           io_txData_ready,
  input  wire [31:0]   io_txData_payload,
  output wire          io_rxData_valid,
  input  wire          io_rxData_ready,
  output wire [31:0]   io_rxData_payload,
  output wire [9:0]    io_txSymbols,
  input  wire [9:0]    io_rxSymbols,
  output wire          io_phyTxEn,
  output wire          io_phyRxPolarity,
  input  wire          io_phyRxElecIdle,
  input  wire          io_phyRxValid,
  output wire          io_linkUp,
  output wire [4:0]    io_ltssState,
  output wire          io_aligned,
  output wire          io_codeErr,
  output wire          io_disparityErr,
  output wire [7:0]    io_busNum,
  input  wire          clk,
  input  wire          reset
);
  localparam LtssState_DETECT_QUIET = 5'd0;
  localparam LtssState_DETECT_ACTIVE = 5'd1;
  localparam LtssState_POLLING_ACTIVE = 5'd2;
  localparam LtssState_POLLING_COMPLIANCE = 5'd3;
  localparam LtssState_POLLING_CONFIG = 5'd4;
  localparam LtssState_CONFIG_LINKWIDTH_START = 5'd5;
  localparam LtssState_CONFIG_LINKWIDTH_ACCEPT = 5'd6;
  localparam LtssState_CONFIG_LANENUM_WAIT = 5'd7;
  localparam LtssState_CONFIG_LANENUM_ACCEPT = 5'd8;
  localparam LtssState_CONFIG_COMPLETE = 5'd9;
  localparam LtssState_CONFIG_IDLE = 5'd10;
  localparam LtssState_L0 = 5'd11;
  localparam LtssState_RECOVERY_RCVRLOCK = 5'd12;
  localparam LtssState_RECOVERY_RCVRCFG = 5'd13;
  localparam LtssState_RECOVERY_IDLE = 5'd14;
  localparam LtssState_L0S = 5'd15;
  localparam LtssState_L1_ENTRY = 5'd16;
  localparam LtssState_L1_IDLE = 5'd17;
  localparam LtssState_L1_EXIT = 5'd18;
  localparam LtssState_L2_IDLE = 5'd19;
  localparam LtssState_L2_TRANSMIT_WAKE = 5'd20;
  localparam LtssState_L2_DETECT_WAKE = 5'd21;
  localparam LtssState_DISABLED = 5'd22;
  localparam LtssState_HOT_RESET = 5'd23;
  localparam LtssState_LOOPBACK_ENTRY = 5'd24;
  localparam LtssState_LOOPBACK_ACTIVE = 5'd25;
  localparam LtssState_LOOPBACK_EXIT = 5'd26;
  localparam PmState_D0 = 3'd0;
  localparam PmState_D1 = 3'd1;
  localparam PmState_D2 = 3'd2;
  localparam PmState_D3HOT = 3'd3;
  localparam PmState_D3COLD = 3'd4;
  localparam LinkWidth_X1 = 2'd0;
  localparam LinkWidth_X2 = 2'd1;
  localparam LinkWidth_X4 = 2'd2;
  localparam LinkWidth_X8 = 2'd3;

  wire       [3:0]    aligner_io_shift;
  reg        [7:0]    encoder_io_dataIn;
  reg                 encoder_io_kCode;
  wire                encoder_io_rdIn;
  wire                ltssm_io_rxValid;
  wire                ltssm_io_linkResetReq;
  wire                ltssm_io_pmReq;
  wire       [2:0]    ltssm_io_pmState;
  wire                ltssm_io_wakeReq;
  wire                ltssm_io_laneReversal;
  wire       [9:0]    aligner_io_dataOut;
  wire                aligner_io_aligned;
  wire       [7:0]    decoder_io_dataOut;
  wire                decoder_io_kCode;
  wire                decoder_io_codeErr;
  wire                decoder_io_rdErr;
  wire       [9:0]    encoder_io_dataOut;
  wire                encoder_io_rdOut;
  wire       [1:0]    ltssm_io_negotiatedWidth;
  wire                ltssm_io_linkUp;
  wire       [1:0]    ltssm_io_linkSpeed;
  wire       [4:0]    ltssm_io_linkWidth;
  wire                ltssm_io_txTs1;
  wire                ltssm_io_txTs2;
  wire                ltssm_io_txIdleOs;
  wire       [4:0]    ltssm_io_curState;
  wire       [7:0]    ltssm_io_busNum;
  wire                ltssm_io_inL1;
  wire                ltssm_io_inL2;
  wire                ltssm_io_pmAck;
  wire                tsDet_io_ts1Det;
  wire                tsDet_io_ts2Det;
  wire       [7:0]    tsDet_io_linkNum;
  wire       [4:0]    tsDet_io_laneNum;
  reg        [7:0]    _zz_io_dataIn;
  wire       [1:0]    txState_1;
  reg        [1:0]    txByte;
  reg        [31:0]   txBuf;
  reg                 txKCode;
  wire                io_txData_fire;
  wire                when_PhysicalLayer_l574;
  wire                when_PhysicalLayer_l581;
  wire                when_PhysicalLayer_l585;
  wire                when_PhysicalLayer_l583;
  reg        [31:0]   rxBuf;
  reg        [1:0]    rxByte;
  reg                 rxValid;
  wire                when_PhysicalLayer_l604;
  wire                when_PhysicalLayer_l608;
  wire       [3:0]    _zz_1;
  wire                when_PhysicalLayer_l613;
  wire                when_PhysicalLayer_l611;
  `ifndef SYNTHESIS
  reg [183:0] io_ltssState_string;
  `endif


  SymbolAligner aligner (
    .io_dataIn  (io_rxSymbols[9:0]      ), //i
    .io_dataOut (aligner_io_dataOut[9:0]), //o
    .io_aligned (aligner_io_aligned     ), //o
    .io_shift   (aligner_io_shift[3:0]  ), //i
    .clk        (clk                    ), //i
    .reset      (reset                  )  //i
  );
  Decoder8b10b decoder (
    .io_dataIn  (aligner_io_dataOut[9:0]), //i
    .io_dataOut (decoder_io_dataOut[7:0]), //o
    .io_kCode   (decoder_io_kCode       ), //o
    .io_codeErr (decoder_io_codeErr     ), //o
    .io_rdErr   (decoder_io_rdErr       ), //o
    .clk        (clk                    ), //i
    .reset      (reset                  )  //i
  );
  Encoder8b10b encoder (
    .io_dataIn  (encoder_io_dataIn[7:0] ), //i
    .io_kCode   (encoder_io_kCode       ), //i
    .io_dataOut (encoder_io_dataOut[9:0]), //o
    .io_rdOut   (encoder_io_rdOut       ), //o
    .io_rdIn    (encoder_io_rdIn        ), //i
    .clk        (clk                    ), //i
    .reset      (reset                  )  //i
  );
  LtssController ltssm (
    .io_rxDetected      (io_phyRxValid                ), //i
    .io_rxElecIdle      (io_phyRxElecIdle             ), //i
    .io_rxValid         (ltssm_io_rxValid             ), //i
    .io_ts1Rcvd         (tsDet_io_ts1Det              ), //i
    .io_ts2Rcvd         (tsDet_io_ts2Det              ), //i
    .io_linkResetReq    (ltssm_io_linkResetReq        ), //i
    .io_pmReq           (ltssm_io_pmReq               ), //i
    .io_pmState         (ltssm_io_pmState[2:0]        ), //i
    .io_wakeReq         (ltssm_io_wakeReq             ), //i
    .io_tsLinkNum       (tsDet_io_linkNum[7:0]        ), //i
    .io_tsLaneNum       (tsDet_io_laneNum[4:0]        ), //i
    .io_laneReversal    (ltssm_io_laneReversal        ), //i
    .io_negotiatedWidth (ltssm_io_negotiatedWidth[1:0]), //o
    .io_linkUp          (ltssm_io_linkUp              ), //o
    .io_linkSpeed       (ltssm_io_linkSpeed[1:0]      ), //o
    .io_linkWidth       (ltssm_io_linkWidth[4:0]      ), //o
    .io_txTs1           (ltssm_io_txTs1               ), //o
    .io_txTs2           (ltssm_io_txTs2               ), //o
    .io_txIdleOs        (ltssm_io_txIdleOs            ), //o
    .io_curState        (ltssm_io_curState[4:0]       ), //o
    .io_busNum          (ltssm_io_busNum[7:0]         ), //o
    .io_inL1            (ltssm_io_inL1                ), //o
    .io_inL2            (ltssm_io_inL2                ), //o
    .io_pmAck           (ltssm_io_pmAck               ), //o
    .clk                (clk                          ), //i
    .reset              (reset                        )  //i
  );
  TsDetector tsDet (
    .io_dataIn  (decoder_io_dataOut[7:0]), //i
    .io_kCodeIn (decoder_io_kCode       ), //i
    .io_validIn (aligner_io_aligned     ), //i
    .io_ts1Det  (tsDet_io_ts1Det        ), //o
    .io_ts2Det  (tsDet_io_ts2Det        ), //o
    .io_linkNum (tsDet_io_linkNum[7:0]  ), //o
    .io_laneNum (tsDet_io_laneNum[4:0]  ), //o
    .clk        (clk                    ), //i
    .reset      (reset                  )  //i
  );
  always @(*) begin
    case(txByte)
      2'b00 : _zz_io_dataIn = txBuf[7 : 0];
      2'b01 : _zz_io_dataIn = txBuf[15 : 8];
      2'b10 : _zz_io_dataIn = txBuf[23 : 16];
      default : _zz_io_dataIn = txBuf[31 : 24];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_ltssState)
      LtssState_DETECT_QUIET : io_ltssState_string = "DETECT_QUIET           ";
      LtssState_DETECT_ACTIVE : io_ltssState_string = "DETECT_ACTIVE          ";
      LtssState_POLLING_ACTIVE : io_ltssState_string = "POLLING_ACTIVE         ";
      LtssState_POLLING_COMPLIANCE : io_ltssState_string = "POLLING_COMPLIANCE     ";
      LtssState_POLLING_CONFIG : io_ltssState_string = "POLLING_CONFIG         ";
      LtssState_CONFIG_LINKWIDTH_START : io_ltssState_string = "CONFIG_LINKWIDTH_START ";
      LtssState_CONFIG_LINKWIDTH_ACCEPT : io_ltssState_string = "CONFIG_LINKWIDTH_ACCEPT";
      LtssState_CONFIG_LANENUM_WAIT : io_ltssState_string = "CONFIG_LANENUM_WAIT    ";
      LtssState_CONFIG_LANENUM_ACCEPT : io_ltssState_string = "CONFIG_LANENUM_ACCEPT  ";
      LtssState_CONFIG_COMPLETE : io_ltssState_string = "CONFIG_COMPLETE        ";
      LtssState_CONFIG_IDLE : io_ltssState_string = "CONFIG_IDLE            ";
      LtssState_L0 : io_ltssState_string = "L0                     ";
      LtssState_RECOVERY_RCVRLOCK : io_ltssState_string = "RECOVERY_RCVRLOCK      ";
      LtssState_RECOVERY_RCVRCFG : io_ltssState_string = "RECOVERY_RCVRCFG       ";
      LtssState_RECOVERY_IDLE : io_ltssState_string = "RECOVERY_IDLE          ";
      LtssState_L0S : io_ltssState_string = "L0S                    ";
      LtssState_L1_ENTRY : io_ltssState_string = "L1_ENTRY               ";
      LtssState_L1_IDLE : io_ltssState_string = "L1_IDLE                ";
      LtssState_L1_EXIT : io_ltssState_string = "L1_EXIT                ";
      LtssState_L2_IDLE : io_ltssState_string = "L2_IDLE                ";
      LtssState_L2_TRANSMIT_WAKE : io_ltssState_string = "L2_TRANSMIT_WAKE       ";
      LtssState_L2_DETECT_WAKE : io_ltssState_string = "L2_DETECT_WAKE         ";
      LtssState_DISABLED : io_ltssState_string = "DISABLED               ";
      LtssState_HOT_RESET : io_ltssState_string = "HOT_RESET              ";
      LtssState_LOOPBACK_ENTRY : io_ltssState_string = "LOOPBACK_ENTRY         ";
      LtssState_LOOPBACK_ACTIVE : io_ltssState_string = "LOOPBACK_ACTIVE        ";
      LtssState_LOOPBACK_EXIT : io_ltssState_string = "LOOPBACK_EXIT          ";
      default : io_ltssState_string = "???????????????????????";
    endcase
  end
  `endif

  assign aligner_io_shift = 4'b0000;
  assign ltssm_io_rxValid = (aligner_io_aligned && (! decoder_io_codeErr));
  assign ltssm_io_linkResetReq = 1'b0;
  assign ltssm_io_pmReq = 1'b0;
  assign ltssm_io_pmState = PmState_D0;
  assign ltssm_io_wakeReq = 1'b0;
  assign ltssm_io_laneReversal = 1'b0;
  assign txState_1 = 2'b00;
  assign encoder_io_rdIn = 1'b0;
  always @(*) begin
    encoder_io_kCode = txKCode;
    if(ltssm_io_txTs1) begin
      encoder_io_kCode = (txByte == 2'b00);
    end else begin
      if(ltssm_io_txTs2) begin
        encoder_io_kCode = (txByte == 2'b00);
      end else begin
        if(ltssm_io_txIdleOs) begin
          encoder_io_kCode = (txByte == 2'b00);
        end else begin
          if(ltssm_io_linkUp) begin
            if(when_PhysicalLayer_l574) begin
              encoder_io_kCode = 1'b0;
            end
          end
        end
      end
    end
  end

  always @(*) begin
    encoder_io_dataIn = 8'h00;
    if(ltssm_io_txTs1) begin
      encoder_io_dataIn = ((txByte == 2'b00) ? 8'hbc : 8'h00);
    end else begin
      if(ltssm_io_txTs2) begin
        encoder_io_dataIn = ((txByte == 2'b00) ? 8'hbc : 8'h80);
      end else begin
        if(ltssm_io_txIdleOs) begin
          encoder_io_dataIn = ((txByte == 2'b00) ? 8'hbc : 8'hb5);
        end else begin
          if(ltssm_io_linkUp) begin
            if(when_PhysicalLayer_l574) begin
              encoder_io_dataIn = _zz_io_dataIn;
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_txData_ready = 1'b0;
    if(!ltssm_io_txTs1) begin
      if(!ltssm_io_txTs2) begin
        if(!ltssm_io_txIdleOs) begin
          if(ltssm_io_linkUp) begin
            io_txData_ready = ((txByte == 2'b00) && io_txData_valid);
          end
        end
      end
    end
  end

  assign io_txData_fire = (io_txData_valid && io_txData_ready);
  assign when_PhysicalLayer_l574 = ((txByte != 2'b00) || io_txData_fire);
  assign when_PhysicalLayer_l581 = (! ltssm_io_linkUp);
  assign when_PhysicalLayer_l585 = (txByte == 2'b11);
  assign when_PhysicalLayer_l583 = (((ltssm_io_txTs1 || ltssm_io_txTs2) || ltssm_io_txIdleOs) || (txByte != 2'b00));
  assign io_txSymbols = encoder_io_dataOut;
  assign io_phyTxEn = ((ltssm_io_linkUp || ltssm_io_txTs1) || ltssm_io_txTs2);
  assign io_phyRxPolarity = 1'b0;
  assign io_rxData_valid = rxValid;
  assign io_rxData_payload = rxBuf;
  assign when_PhysicalLayer_l604 = (rxValid && io_rxData_ready);
  assign when_PhysicalLayer_l608 = (! ltssm_io_linkUp);
  assign _zz_1 = ({3'd0,1'b1} <<< rxByte);
  assign when_PhysicalLayer_l613 = (rxByte == 2'b11);
  assign when_PhysicalLayer_l611 = (((aligner_io_aligned && (! decoder_io_kCode)) && (! decoder_io_codeErr)) && ((! rxValid) || io_rxData_ready));
  assign io_linkUp = ltssm_io_linkUp;
  assign io_ltssState = ltssm_io_curState;
  assign io_aligned = aligner_io_aligned;
  assign io_codeErr = decoder_io_codeErr;
  assign io_disparityErr = decoder_io_rdErr;
  assign io_busNum = ltssm_io_busNum;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      txByte <= 2'b00;
      txKCode <= 1'b0;
      rxByte <= 2'b00;
      rxValid <= 1'b0;
    end else begin
      if(!ltssm_io_txTs1) begin
        if(!ltssm_io_txTs2) begin
          if(!ltssm_io_txIdleOs) begin
            if(ltssm_io_linkUp) begin
              if(io_txData_fire) begin
                txKCode <= 1'b0;
              end
            end
          end
        end
      end
      if(when_PhysicalLayer_l581) begin
        txByte <= 2'b00;
      end else begin
        if(when_PhysicalLayer_l583) begin
          txByte <= (txByte + 2'b01);
          if(when_PhysicalLayer_l585) begin
            txByte <= 2'b00;
          end
        end
      end
      if(when_PhysicalLayer_l604) begin
        rxValid <= 1'b0;
      end
      if(when_PhysicalLayer_l608) begin
        rxByte <= 2'b00;
        rxValid <= 1'b0;
      end else begin
        if(when_PhysicalLayer_l611) begin
          if(when_PhysicalLayer_l613) begin
            rxByte <= 2'b00;
            rxValid <= 1'b1;
          end else begin
            rxByte <= (rxByte + 2'b01);
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if(!ltssm_io_txTs1) begin
      if(!ltssm_io_txTs2) begin
        if(!ltssm_io_txIdleOs) begin
          if(ltssm_io_linkUp) begin
            if(io_txData_fire) begin
              txBuf <= io_txData_payload;
            end
          end
        end
      end
    end
    if(!when_PhysicalLayer_l608) begin
      if(when_PhysicalLayer_l611) begin
        if(_zz_1[0]) begin
          rxBuf[7 : 0] <= decoder_io_dataOut;
        end
        if(_zz_1[1]) begin
          rxBuf[15 : 8] <= decoder_io_dataOut;
        end
        if(_zz_1[2]) begin
          rxBuf[23 : 16] <= decoder_io_dataOut;
        end
        if(_zz_1[3]) begin
          rxBuf[31 : 24] <= decoder_io_dataOut;
        end
      end
    end
  end


endmodule

module TlpTxEngine (
  input  wire          io_memWrReq_valid,
  output reg           io_memWrReq_ready,
  input  wire [3:0]    io_memWrReq_payload_tlpType,
  input  wire [15:0]   io_memWrReq_payload_reqId,
  input  wire [7:0]    io_memWrReq_payload_tag,
  input  wire [63:0]   io_memWrReq_payload_addr,
  input  wire [9:0]    io_memWrReq_payload_length,
  input  wire [3:0]    io_memWrReq_payload_firstBe,
  input  wire [3:0]    io_memWrReq_payload_lastBe,
  input  wire [2:0]    io_memWrReq_payload_tc,
  input  wire [1:0]    io_memWrReq_payload_attr,
  input  wire [31:0]   io_memWrReq_payload_data_0,
  input  wire [31:0]   io_memWrReq_payload_data_1,
  input  wire [31:0]   io_memWrReq_payload_data_2,
  input  wire [31:0]   io_memWrReq_payload_data_3,
  input  wire [2:0]    io_memWrReq_payload_dataValid,
  input  wire          io_memRdReq_valid,
  output reg           io_memRdReq_ready,
  input  wire [3:0]    io_memRdReq_payload_tlpType,
  input  wire [15:0]   io_memRdReq_payload_reqId,
  input  wire [7:0]    io_memRdReq_payload_tag,
  input  wire [63:0]   io_memRdReq_payload_addr,
  input  wire [9:0]    io_memRdReq_payload_length,
  input  wire [3:0]    io_memRdReq_payload_firstBe,
  input  wire [3:0]    io_memRdReq_payload_lastBe,
  input  wire [2:0]    io_memRdReq_payload_tc,
  input  wire [1:0]    io_memRdReq_payload_attr,
  input  wire [31:0]   io_memRdReq_payload_data_0,
  input  wire [31:0]   io_memRdReq_payload_data_1,
  input  wire [31:0]   io_memRdReq_payload_data_2,
  input  wire [31:0]   io_memRdReq_payload_data_3,
  input  wire [2:0]    io_memRdReq_payload_dataValid,
  input  wire          io_cplReq_valid,
  output reg           io_cplReq_ready,
  input  wire [3:0]    io_cplReq_payload_tlpType,
  input  wire [15:0]   io_cplReq_payload_reqId,
  input  wire [7:0]    io_cplReq_payload_tag,
  input  wire [63:0]   io_cplReq_payload_addr,
  input  wire [9:0]    io_cplReq_payload_length,
  input  wire [3:0]    io_cplReq_payload_firstBe,
  input  wire [3:0]    io_cplReq_payload_lastBe,
  input  wire [2:0]    io_cplReq_payload_tc,
  input  wire [1:0]    io_cplReq_payload_attr,
  input  wire [31:0]   io_cplReq_payload_data_0,
  input  wire [31:0]   io_cplReq_payload_data_1,
  input  wire [31:0]   io_cplReq_payload_data_2,
  input  wire [31:0]   io_cplReq_payload_data_3,
  input  wire [2:0]    io_cplReq_payload_dataValid,
  output reg           io_tlpOut_valid,
  input  wire          io_tlpOut_ready,
  output reg  [31:0]   io_tlpOut_payload,
  input  wire [7:0]    io_fcCredits_phCredits,
  input  wire [11:0]   io_fcCredits_pdCredits,
  input  wire [7:0]    io_fcCredits_nphCredits,
  input  wire [11:0]   io_fcCredits_npdCredits,
  input  wire [7:0]    io_fcCredits_cplhCredits,
  input  wire [11:0]   io_fcCredits_cpldCredits,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;
  localparam ArbState_IDLE = 2'd0;
  localparam ArbState_SEL_CPL = 2'd1;
  localparam ArbState_SEL_MEM_WR = 2'd2;
  localparam ArbState_SEL_MEM_RD = 2'd3;
  localparam TxState_IDLE = 3'd0;
  localparam TxState_HDR1 = 3'd1;
  localparam TxState_HDR2 = 3'd2;
  localparam TxState_HDR3 = 3'd3;
  localparam TxState_HDR4 = 3'd4;
  localparam TxState_DATA = 3'd5;

  wire       [9:0]    _zz_cplDataCredits;
  wire       [9:0]    _zz_memWrDataCredits;
  wire       [11:0]   _zz_canSendCpl;
  wire       [11:0]   _zz_canSendMemWr;
  reg        [31:0]   _zz_io_tlpOut_payload_3;
  wire       [1:0]    _zz_io_tlpOut_payload_4;
  wire       [9:0]    _zz_when_TlpTxEngine_l237;
  wire       [2:0]    _zz_when_TlpTxEngine_l237_1;
  wire       [1:0]    arbState_1;
  reg        [3:0]    activeReq_tlpType;
  reg        [15:0]   activeReq_reqId;
  reg        [7:0]    activeReq_tag;
  reg        [63:0]   activeReq_addr;
  reg        [9:0]    activeReq_length;
  reg        [3:0]    activeReq_firstBe;
  reg        [3:0]    activeReq_lastBe;
  reg        [2:0]    activeReq_tc;
  reg        [1:0]    activeReq_attr;
  reg        [31:0]   activeReq_data_0;
  reg        [31:0]   activeReq_data_1;
  reg        [31:0]   activeReq_data_2;
  reg        [31:0]   activeReq_data_3;
  reg        [2:0]    activeReq_dataValid;
  reg        [3:0]    granted;
  reg        [1:0]    rrPtr;
  wire       [9:0]    cplDataCredits;
  wire       [9:0]    memWrDataCredits;
  wire                canSendCpl;
  wire                canSendMemWr;
  wire                canSendMemRd;
  reg        [2:0]    state;
  reg        [9:0]    dataIdx;
  reg                 needData;
  reg                 is4DW;
  wire                when_TlpTxEngine_l148;
  wire                when_TlpTxEngine_l155;
  wire                when_TlpTxEngine_l162;
  reg        [2:0]    _zz_io_tlpOut_payload;
  reg        [4:0]    _zz_io_tlpOut_payload_1;
  reg        [31:0]   _zz_io_tlpOut_payload_2;
  wire                _zz_when_TlpTxEngine_l88;
  wire                _zz_when_TlpTxEngine_l88_1;
  wire                when_TlpTxEngine_l88;
  wire                when_TlpTxEngine_l90;
  wire                when_TlpTxEngine_l92;
  wire       [2:0]    _zz_state;
  wire       [2:0]    _zz_state_1;
  wire       [2:0]    _zz_state_2;
  wire                when_TlpTxEngine_l237;
  `ifndef SYNTHESIS
  reg [55:0] io_memWrReq_payload_tlpType_string;
  reg [55:0] io_memRdReq_payload_tlpType_string;
  reg [55:0] io_cplReq_payload_tlpType_string;
  reg [79:0] arbState_1_string;
  reg [55:0] activeReq_tlpType_string;
  reg [55:0] granted_string;
  reg [31:0] state_string;
  reg [31:0] _zz_state_string;
  reg [31:0] _zz_state_1_string;
  reg [31:0] _zz_state_2_string;
  `endif


  assign _zz_cplDataCredits = {7'd0, io_cplReq_payload_dataValid};
  assign _zz_memWrDataCredits = {7'd0, io_memWrReq_payload_dataValid};
  assign _zz_canSendCpl = {2'd0, cplDataCredits};
  assign _zz_canSendMemWr = {2'd0, memWrDataCredits};
  assign _zz_io_tlpOut_payload_4 = dataIdx[1:0];
  assign _zz_when_TlpTxEngine_l237_1 = (((activeReq_dataValid == 3'b000) ? 3'b001 : activeReq_dataValid) - 3'b001);
  assign _zz_when_TlpTxEngine_l237 = {7'd0, _zz_when_TlpTxEngine_l237_1};
  always @(*) begin
    case(_zz_io_tlpOut_payload_4)
      2'b00 : _zz_io_tlpOut_payload_3 = activeReq_data_0;
      2'b01 : _zz_io_tlpOut_payload_3 = activeReq_data_1;
      2'b10 : _zz_io_tlpOut_payload_3 = activeReq_data_2;
      default : _zz_io_tlpOut_payload_3 = activeReq_data_3;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_memWrReq_payload_tlpType)
      TlpType_MEM_RD : io_memWrReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memWrReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memWrReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memWrReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memWrReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memWrReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memWrReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memWrReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memWrReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memWrReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memWrReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memWrReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memWrReq_payload_tlpType_string = "INVALID";
      default : io_memWrReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_memRdReq_payload_tlpType)
      TlpType_MEM_RD : io_memRdReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_memRdReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_memRdReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_memRdReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_memRdReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_memRdReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_memRdReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_memRdReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_memRdReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_memRdReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_memRdReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_memRdReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_memRdReq_payload_tlpType_string = "INVALID";
      default : io_memRdReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_cplReq_payload_tlpType)
      TlpType_MEM_RD : io_cplReq_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_cplReq_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_cplReq_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_cplReq_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_cplReq_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_cplReq_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_cplReq_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_cplReq_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_cplReq_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_cplReq_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_cplReq_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_cplReq_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_cplReq_payload_tlpType_string = "INVALID";
      default : io_cplReq_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(arbState_1)
      ArbState_IDLE : arbState_1_string = "IDLE      ";
      ArbState_SEL_CPL : arbState_1_string = "SEL_CPL   ";
      ArbState_SEL_MEM_WR : arbState_1_string = "SEL_MEM_WR";
      ArbState_SEL_MEM_RD : arbState_1_string = "SEL_MEM_RD";
      default : arbState_1_string = "??????????";
    endcase
  end
  always @(*) begin
    case(activeReq_tlpType)
      TlpType_MEM_RD : activeReq_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : activeReq_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : activeReq_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : activeReq_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : activeReq_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : activeReq_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : activeReq_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : activeReq_tlpType_string = "CFG_WR1";
      TlpType_CPL : activeReq_tlpType_string = "CPL    ";
      TlpType_CPL_D : activeReq_tlpType_string = "CPL_D  ";
      TlpType_MSG : activeReq_tlpType_string = "MSG    ";
      TlpType_MSG_D : activeReq_tlpType_string = "MSG_D  ";
      TlpType_INVALID : activeReq_tlpType_string = "INVALID";
      default : activeReq_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(granted)
      TlpType_MEM_RD : granted_string = "MEM_RD ";
      TlpType_MEM_WR : granted_string = "MEM_WR ";
      TlpType_IO_RD : granted_string = "IO_RD  ";
      TlpType_IO_WR : granted_string = "IO_WR  ";
      TlpType_CFG_RD0 : granted_string = "CFG_RD0";
      TlpType_CFG_WR0 : granted_string = "CFG_WR0";
      TlpType_CFG_RD1 : granted_string = "CFG_RD1";
      TlpType_CFG_WR1 : granted_string = "CFG_WR1";
      TlpType_CPL : granted_string = "CPL    ";
      TlpType_CPL_D : granted_string = "CPL_D  ";
      TlpType_MSG : granted_string = "MSG    ";
      TlpType_MSG_D : granted_string = "MSG_D  ";
      TlpType_INVALID : granted_string = "INVALID";
      default : granted_string = "???????";
    endcase
  end
  always @(*) begin
    case(state)
      TxState_IDLE : state_string = "IDLE";
      TxState_HDR1 : state_string = "HDR1";
      TxState_HDR2 : state_string = "HDR2";
      TxState_HDR3 : state_string = "HDR3";
      TxState_HDR4 : state_string = "HDR4";
      TxState_DATA : state_string = "DATA";
      default : state_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_state)
      TxState_IDLE : _zz_state_string = "IDLE";
      TxState_HDR1 : _zz_state_string = "HDR1";
      TxState_HDR2 : _zz_state_string = "HDR2";
      TxState_HDR3 : _zz_state_string = "HDR3";
      TxState_HDR4 : _zz_state_string = "HDR4";
      TxState_DATA : _zz_state_string = "DATA";
      default : _zz_state_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_state_1)
      TxState_IDLE : _zz_state_1_string = "IDLE";
      TxState_HDR1 : _zz_state_1_string = "HDR1";
      TxState_HDR2 : _zz_state_1_string = "HDR2";
      TxState_HDR3 : _zz_state_1_string = "HDR3";
      TxState_HDR4 : _zz_state_1_string = "HDR4";
      TxState_DATA : _zz_state_1_string = "DATA";
      default : _zz_state_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_state_2)
      TxState_IDLE : _zz_state_2_string = "IDLE";
      TxState_HDR1 : _zz_state_2_string = "HDR1";
      TxState_HDR2 : _zz_state_2_string = "HDR2";
      TxState_HDR3 : _zz_state_2_string = "HDR3";
      TxState_HDR4 : _zz_state_2_string = "HDR4";
      TxState_DATA : _zz_state_2_string = "DATA";
      default : _zz_state_2_string = "????";
    endcase
  end
  `endif

  assign arbState_1 = ArbState_IDLE;
  assign cplDataCredits = ((io_cplReq_payload_dataValid == 3'b000) ? 10'h001 : _zz_cplDataCredits);
  assign memWrDataCredits = ((io_memWrReq_payload_dataValid == 3'b000) ? 10'h001 : _zz_memWrDataCredits);
  assign canSendCpl = ((io_cplReq_valid && (8'h00 < io_fcCredits_cplhCredits)) && ((io_cplReq_payload_dataValid == 3'b000) || (_zz_canSendCpl <= io_fcCredits_cpldCredits)));
  assign canSendMemWr = ((io_memWrReq_valid && (8'h00 < io_fcCredits_phCredits)) && (_zz_canSendMemWr <= io_fcCredits_pdCredits));
  assign canSendMemRd = (io_memRdReq_valid && (8'h00 < io_fcCredits_nphCredits));
  always @(*) begin
    io_tlpOut_valid = 1'b0;
    case(state)
      TxState_IDLE : begin
      end
      TxState_HDR1 : begin
        io_tlpOut_valid = 1'b1;
      end
      TxState_HDR2 : begin
        io_tlpOut_valid = 1'b1;
      end
      TxState_HDR3 : begin
        io_tlpOut_valid = 1'b1;
      end
      TxState_HDR4 : begin
        io_tlpOut_valid = 1'b1;
      end
      default : begin
        io_tlpOut_valid = 1'b1;
      end
    endcase
  end

  always @(*) begin
    io_tlpOut_payload = 32'h00000000;
    case(state)
      TxState_IDLE : begin
      end
      TxState_HDR1 : begin
        io_tlpOut_payload = _zz_io_tlpOut_payload_2;
      end
      TxState_HDR2 : begin
        io_tlpOut_payload = {{{activeReq_reqId,activeReq_tag},activeReq_lastBe},activeReq_firstBe};
      end
      TxState_HDR3 : begin
        io_tlpOut_payload = (is4DW ? activeReq_addr[63 : 32] : activeReq_addr[31 : 0]);
      end
      TxState_HDR4 : begin
        io_tlpOut_payload = activeReq_addr[31 : 0];
      end
      default : begin
        io_tlpOut_payload = _zz_io_tlpOut_payload_3;
      end
    endcase
  end

  always @(*) begin
    io_memWrReq_ready = 1'b0;
    case(state)
      TxState_IDLE : begin
        if(!when_TlpTxEngine_l148) begin
          if(when_TlpTxEngine_l155) begin
            io_memWrReq_ready = 1'b1;
          end else begin
            if(!when_TlpTxEngine_l162) begin
              if(!canSendCpl) begin
                if(canSendMemWr) begin
                  io_memWrReq_ready = 1'b1;
                end
              end
            end
          end
        end
      end
      TxState_HDR1 : begin
      end
      TxState_HDR2 : begin
      end
      TxState_HDR3 : begin
      end
      TxState_HDR4 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_memRdReq_ready = 1'b0;
    case(state)
      TxState_IDLE : begin
        if(!when_TlpTxEngine_l148) begin
          if(!when_TlpTxEngine_l155) begin
            if(when_TlpTxEngine_l162) begin
              io_memRdReq_ready = 1'b1;
            end else begin
              if(!canSendCpl) begin
                if(!canSendMemWr) begin
                  if(canSendMemRd) begin
                    io_memRdReq_ready = 1'b1;
                  end
                end
              end
            end
          end
        end
      end
      TxState_HDR1 : begin
      end
      TxState_HDR2 : begin
      end
      TxState_HDR3 : begin
      end
      TxState_HDR4 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cplReq_ready = 1'b0;
    case(state)
      TxState_IDLE : begin
        if(when_TlpTxEngine_l148) begin
          io_cplReq_ready = 1'b1;
        end else begin
          if(!when_TlpTxEngine_l155) begin
            if(!when_TlpTxEngine_l162) begin
              if(canSendCpl) begin
                io_cplReq_ready = 1'b1;
              end
            end
          end
        end
      end
      TxState_HDR1 : begin
      end
      TxState_HDR2 : begin
      end
      TxState_HDR3 : begin
      end
      TxState_HDR4 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_TlpTxEngine_l148 = ((rrPtr == 2'b00) && canSendCpl);
  assign when_TlpTxEngine_l155 = ((rrPtr == 2'b01) && canSendMemWr);
  assign when_TlpTxEngine_l162 = ((rrPtr == 2'b10) && canSendMemRd);
  assign _zz_when_TlpTxEngine_l88 = (activeReq_dataValid != 3'b000);
  assign _zz_when_TlpTxEngine_l88_1 = (((((activeReq_tlpType == TlpType_MEM_RD) || (activeReq_tlpType == TlpType_MEM_WR)) || (activeReq_tlpType == TlpType_IO_RD)) || (activeReq_tlpType == TlpType_IO_WR)) && (activeReq_addr[63 : 32] != 32'h00000000));
  always @(*) begin
    _zz_io_tlpOut_payload = 3'b000;
    if(when_TlpTxEngine_l88) begin
      _zz_io_tlpOut_payload = 3'b011;
    end else begin
      if(when_TlpTxEngine_l90) begin
        _zz_io_tlpOut_payload = 3'b001;
      end else begin
        if(when_TlpTxEngine_l92) begin
          _zz_io_tlpOut_payload = 3'b010;
        end
      end
    end
  end

  assign when_TlpTxEngine_l88 = (_zz_when_TlpTxEngine_l88_1 && _zz_when_TlpTxEngine_l88);
  assign when_TlpTxEngine_l90 = (_zz_when_TlpTxEngine_l88_1 && (! _zz_when_TlpTxEngine_l88));
  assign when_TlpTxEngine_l92 = ((! _zz_when_TlpTxEngine_l88_1) && _zz_when_TlpTxEngine_l88);
  always @(*) begin
    _zz_io_tlpOut_payload_1 = 5'h1f;
    case(activeReq_tlpType)
      TlpType_MEM_RD, TlpType_MEM_WR : begin
        _zz_io_tlpOut_payload_1 = 5'h00;
      end
      TlpType_IO_RD, TlpType_IO_WR : begin
        _zz_io_tlpOut_payload_1 = 5'h02;
      end
      TlpType_CFG_RD0, TlpType_CFG_WR0 : begin
        _zz_io_tlpOut_payload_1 = 5'h04;
      end
      TlpType_CFG_RD1, TlpType_CFG_WR1 : begin
        _zz_io_tlpOut_payload_1 = 5'h05;
      end
      TlpType_CPL, TlpType_CPL_D : begin
        _zz_io_tlpOut_payload_1 = 5'h0a;
      end
      TlpType_MSG, TlpType_MSG_D : begin
        _zz_io_tlpOut_payload_1 = 5'h10;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    _zz_io_tlpOut_payload_2 = 32'h00000000;
    _zz_io_tlpOut_payload_2[31 : 29] = _zz_io_tlpOut_payload;
    _zz_io_tlpOut_payload_2[28 : 24] = _zz_io_tlpOut_payload_1;
    _zz_io_tlpOut_payload_2[22 : 20] = activeReq_tc;
    _zz_io_tlpOut_payload_2[13 : 12] = activeReq_attr;
    _zz_io_tlpOut_payload_2[9 : 0] = activeReq_length;
  end

  assign _zz_state = (needData ? TxState_DATA : TxState_IDLE);
  assign _zz_state_1 = (is4DW ? TxState_HDR4 : _zz_state);
  assign _zz_state_2 = (needData ? TxState_DATA : TxState_IDLE);
  assign when_TlpTxEngine_l237 = (dataIdx == _zz_when_TlpTxEngine_l237);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      rrPtr <= 2'b00;
      state <= TxState_IDLE;
      dataIdx <= 10'h000;
      needData <= 1'b0;
      is4DW <= 1'b0;
    end else begin
      case(state)
        TxState_IDLE : begin
          if(when_TlpTxEngine_l148) begin
            needData <= (io_cplReq_payload_dataValid != 3'b000);
            is4DW <= (((((io_cplReq_payload_tlpType == TlpType_MEM_RD) || (io_cplReq_payload_tlpType == TlpType_MEM_WR)) || (io_cplReq_payload_tlpType == TlpType_IO_RD)) || (io_cplReq_payload_tlpType == TlpType_IO_WR)) && (io_cplReq_payload_addr[63 : 32] != 32'h00000000));
            state <= TxState_HDR1;
            rrPtr <= 2'b01;
          end else begin
            if(when_TlpTxEngine_l155) begin
              needData <= (io_memWrReq_payload_dataValid != 3'b000);
              is4DW <= (((((io_memWrReq_payload_tlpType == TlpType_MEM_RD) || (io_memWrReq_payload_tlpType == TlpType_MEM_WR)) || (io_memWrReq_payload_tlpType == TlpType_IO_RD)) || (io_memWrReq_payload_tlpType == TlpType_IO_WR)) && (io_memWrReq_payload_addr[63 : 32] != 32'h00000000));
              state <= TxState_HDR1;
              rrPtr <= 2'b10;
            end else begin
              if(when_TlpTxEngine_l162) begin
                needData <= (io_memRdReq_payload_dataValid != 3'b000);
                is4DW <= (((((io_memRdReq_payload_tlpType == TlpType_MEM_RD) || (io_memRdReq_payload_tlpType == TlpType_MEM_WR)) || (io_memRdReq_payload_tlpType == TlpType_IO_RD)) || (io_memRdReq_payload_tlpType == TlpType_IO_WR)) && (io_memRdReq_payload_addr[63 : 32] != 32'h00000000));
                state <= TxState_HDR1;
                rrPtr <= 2'b00;
              end else begin
                if(canSendCpl) begin
                  needData <= (io_cplReq_payload_dataValid != 3'b000);
                  is4DW <= (((((io_cplReq_payload_tlpType == TlpType_MEM_RD) || (io_cplReq_payload_tlpType == TlpType_MEM_WR)) || (io_cplReq_payload_tlpType == TlpType_IO_RD)) || (io_cplReq_payload_tlpType == TlpType_IO_WR)) && (io_cplReq_payload_addr[63 : 32] != 32'h00000000));
                  state <= TxState_HDR1;
                  rrPtr <= 2'b01;
                end else begin
                  if(canSendMemWr) begin
                    needData <= (io_memWrReq_payload_dataValid != 3'b000);
                    is4DW <= (((((io_memWrReq_payload_tlpType == TlpType_MEM_RD) || (io_memWrReq_payload_tlpType == TlpType_MEM_WR)) || (io_memWrReq_payload_tlpType == TlpType_IO_RD)) || (io_memWrReq_payload_tlpType == TlpType_IO_WR)) && (io_memWrReq_payload_addr[63 : 32] != 32'h00000000));
                    state <= TxState_HDR1;
                    rrPtr <= 2'b10;
                  end else begin
                    if(canSendMemRd) begin
                      needData <= (io_memRdReq_payload_dataValid != 3'b000);
                      is4DW <= (((((io_memRdReq_payload_tlpType == TlpType_MEM_RD) || (io_memRdReq_payload_tlpType == TlpType_MEM_WR)) || (io_memRdReq_payload_tlpType == TlpType_IO_RD)) || (io_memRdReq_payload_tlpType == TlpType_IO_WR)) && (io_memRdReq_payload_addr[63 : 32] != 32'h00000000));
                      state <= TxState_HDR1;
                      rrPtr <= 2'b00;
                    end
                  end
                end
              end
            end
          end
        end
        TxState_HDR1 : begin
          if(io_tlpOut_ready) begin
            state <= TxState_HDR2;
          end
        end
        TxState_HDR2 : begin
          if(io_tlpOut_ready) begin
            state <= TxState_HDR3;
          end
        end
        TxState_HDR3 : begin
          if(io_tlpOut_ready) begin
            state <= _zz_state_1;
            dataIdx <= 10'h000;
          end
        end
        TxState_HDR4 : begin
          if(io_tlpOut_ready) begin
            state <= _zz_state_2;
            dataIdx <= 10'h000;
          end
        end
        default : begin
          if(io_tlpOut_ready) begin
            dataIdx <= (dataIdx + 10'h001);
            if(when_TlpTxEngine_l237) begin
              state <= TxState_IDLE;
            end
          end
        end
      endcase
    end
  end

  always @(posedge clk) begin
    case(state)
      TxState_IDLE : begin
        if(when_TlpTxEngine_l148) begin
          activeReq_tlpType <= io_cplReq_payload_tlpType;
          activeReq_reqId <= io_cplReq_payload_reqId;
          activeReq_tag <= io_cplReq_payload_tag;
          activeReq_addr <= io_cplReq_payload_addr;
          activeReq_length <= io_cplReq_payload_length;
          activeReq_firstBe <= io_cplReq_payload_firstBe;
          activeReq_lastBe <= io_cplReq_payload_lastBe;
          activeReq_tc <= io_cplReq_payload_tc;
          activeReq_attr <= io_cplReq_payload_attr;
          activeReq_data_0 <= io_cplReq_payload_data_0;
          activeReq_data_1 <= io_cplReq_payload_data_1;
          activeReq_data_2 <= io_cplReq_payload_data_2;
          activeReq_data_3 <= io_cplReq_payload_data_3;
          activeReq_dataValid <= io_cplReq_payload_dataValid;
        end else begin
          if(when_TlpTxEngine_l155) begin
            activeReq_tlpType <= io_memWrReq_payload_tlpType;
            activeReq_reqId <= io_memWrReq_payload_reqId;
            activeReq_tag <= io_memWrReq_payload_tag;
            activeReq_addr <= io_memWrReq_payload_addr;
            activeReq_length <= io_memWrReq_payload_length;
            activeReq_firstBe <= io_memWrReq_payload_firstBe;
            activeReq_lastBe <= io_memWrReq_payload_lastBe;
            activeReq_tc <= io_memWrReq_payload_tc;
            activeReq_attr <= io_memWrReq_payload_attr;
            activeReq_data_0 <= io_memWrReq_payload_data_0;
            activeReq_data_1 <= io_memWrReq_payload_data_1;
            activeReq_data_2 <= io_memWrReq_payload_data_2;
            activeReq_data_3 <= io_memWrReq_payload_data_3;
            activeReq_dataValid <= io_memWrReq_payload_dataValid;
          end else begin
            if(when_TlpTxEngine_l162) begin
              activeReq_tlpType <= io_memRdReq_payload_tlpType;
              activeReq_reqId <= io_memRdReq_payload_reqId;
              activeReq_tag <= io_memRdReq_payload_tag;
              activeReq_addr <= io_memRdReq_payload_addr;
              activeReq_length <= io_memRdReq_payload_length;
              activeReq_firstBe <= io_memRdReq_payload_firstBe;
              activeReq_lastBe <= io_memRdReq_payload_lastBe;
              activeReq_tc <= io_memRdReq_payload_tc;
              activeReq_attr <= io_memRdReq_payload_attr;
              activeReq_data_0 <= io_memRdReq_payload_data_0;
              activeReq_data_1 <= io_memRdReq_payload_data_1;
              activeReq_data_2 <= io_memRdReq_payload_data_2;
              activeReq_data_3 <= io_memRdReq_payload_data_3;
              activeReq_dataValid <= io_memRdReq_payload_dataValid;
            end else begin
              if(canSendCpl) begin
                activeReq_tlpType <= io_cplReq_payload_tlpType;
                activeReq_reqId <= io_cplReq_payload_reqId;
                activeReq_tag <= io_cplReq_payload_tag;
                activeReq_addr <= io_cplReq_payload_addr;
                activeReq_length <= io_cplReq_payload_length;
                activeReq_firstBe <= io_cplReq_payload_firstBe;
                activeReq_lastBe <= io_cplReq_payload_lastBe;
                activeReq_tc <= io_cplReq_payload_tc;
                activeReq_attr <= io_cplReq_payload_attr;
                activeReq_data_0 <= io_cplReq_payload_data_0;
                activeReq_data_1 <= io_cplReq_payload_data_1;
                activeReq_data_2 <= io_cplReq_payload_data_2;
                activeReq_data_3 <= io_cplReq_payload_data_3;
                activeReq_dataValid <= io_cplReq_payload_dataValid;
              end else begin
                if(canSendMemWr) begin
                  activeReq_tlpType <= io_memWrReq_payload_tlpType;
                  activeReq_reqId <= io_memWrReq_payload_reqId;
                  activeReq_tag <= io_memWrReq_payload_tag;
                  activeReq_addr <= io_memWrReq_payload_addr;
                  activeReq_length <= io_memWrReq_payload_length;
                  activeReq_firstBe <= io_memWrReq_payload_firstBe;
                  activeReq_lastBe <= io_memWrReq_payload_lastBe;
                  activeReq_tc <= io_memWrReq_payload_tc;
                  activeReq_attr <= io_memWrReq_payload_attr;
                  activeReq_data_0 <= io_memWrReq_payload_data_0;
                  activeReq_data_1 <= io_memWrReq_payload_data_1;
                  activeReq_data_2 <= io_memWrReq_payload_data_2;
                  activeReq_data_3 <= io_memWrReq_payload_data_3;
                  activeReq_dataValid <= io_memWrReq_payload_dataValid;
                end else begin
                  if(canSendMemRd) begin
                    activeReq_tlpType <= io_memRdReq_payload_tlpType;
                    activeReq_reqId <= io_memRdReq_payload_reqId;
                    activeReq_tag <= io_memRdReq_payload_tag;
                    activeReq_addr <= io_memRdReq_payload_addr;
                    activeReq_length <= io_memRdReq_payload_length;
                    activeReq_firstBe <= io_memRdReq_payload_firstBe;
                    activeReq_lastBe <= io_memRdReq_payload_lastBe;
                    activeReq_tc <= io_memRdReq_payload_tc;
                    activeReq_attr <= io_memRdReq_payload_attr;
                    activeReq_data_0 <= io_memRdReq_payload_data_0;
                    activeReq_data_1 <= io_memRdReq_payload_data_1;
                    activeReq_data_2 <= io_memRdReq_payload_data_2;
                    activeReq_data_3 <= io_memRdReq_payload_data_3;
                    activeReq_dataValid <= io_memRdReq_payload_dataValid;
                  end
                end
              end
            end
          end
        end
      end
      TxState_HDR1 : begin
      end
      TxState_HDR2 : begin
      end
      TxState_HDR3 : begin
      end
      TxState_HDR4 : begin
      end
      default : begin
      end
    endcase
  end


endmodule

//StreamFifo_2 replaced by StreamFifo_1

module StreamFifo_1 (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [3:0]    io_push_payload_tlpType,
  input  wire [15:0]   io_push_payload_reqId,
  input  wire [7:0]    io_push_payload_tag,
  input  wire [63:0]   io_push_payload_addr,
  input  wire [9:0]    io_push_payload_length,
  input  wire [3:0]    io_push_payload_firstBe,
  input  wire [3:0]    io_push_payload_lastBe,
  input  wire [2:0]    io_push_payload_tc,
  input  wire [1:0]    io_push_payload_attr,
  input  wire [31:0]   io_push_payload_data_0,
  input  wire [31:0]   io_push_payload_data_1,
  input  wire [31:0]   io_push_payload_data_2,
  input  wire [31:0]   io_push_payload_data_3,
  input  wire [2:0]    io_push_payload_dataValid,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [3:0]    io_pop_payload_tlpType,
  output wire [15:0]   io_pop_payload_reqId,
  output wire [7:0]    io_pop_payload_tag,
  output wire [63:0]   io_pop_payload_addr,
  output wire [9:0]    io_pop_payload_length,
  output wire [3:0]    io_pop_payload_firstBe,
  output wire [3:0]    io_pop_payload_lastBe,
  output wire [2:0]    io_pop_payload_tc,
  output wire [1:0]    io_pop_payload_attr,
  output wire [31:0]   io_pop_payload_data_0,
  output wire [31:0]   io_pop_payload_data_1,
  output wire [31:0]   io_pop_payload_data_2,
  output wire [31:0]   io_pop_payload_data_3,
  output wire [2:0]    io_pop_payload_dataValid,
  input  wire          io_flush,
  output wire [5:0]    io_occupancy,
  output wire [5:0]    io_availability,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  reg        [245:0]  _zz_logic_ram_port1;
  wire       [245:0]  _zz_logic_ram_port;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [5:0]    logic_ptr_push;
  reg        [5:0]    logic_ptr_pop;
  wire       [5:0]    logic_ptr_occupancy;
  wire       [5:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1205;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [4:0]    logic_push_onRam_write_payload_address;
  wire       [3:0]    logic_push_onRam_write_payload_data_tlpType;
  wire       [15:0]   logic_push_onRam_write_payload_data_reqId;
  wire       [7:0]    logic_push_onRam_write_payload_data_tag;
  wire       [63:0]   logic_push_onRam_write_payload_data_addr;
  wire       [9:0]    logic_push_onRam_write_payload_data_length;
  wire       [3:0]    logic_push_onRam_write_payload_data_firstBe;
  wire       [3:0]    logic_push_onRam_write_payload_data_lastBe;
  wire       [2:0]    logic_push_onRam_write_payload_data_tc;
  wire       [1:0]    logic_push_onRam_write_payload_data_attr;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_0;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_1;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_2;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_3;
  wire       [2:0]    logic_push_onRam_write_payload_data_dataValid;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [4:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [4:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [4:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l369;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [4:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [3:0]    logic_pop_sync_readPort_rsp_tlpType;
  wire       [15:0]   logic_pop_sync_readPort_rsp_reqId;
  wire       [7:0]    logic_pop_sync_readPort_rsp_tag;
  wire       [63:0]   logic_pop_sync_readPort_rsp_addr;
  wire       [9:0]    logic_pop_sync_readPort_rsp_length;
  wire       [3:0]    logic_pop_sync_readPort_rsp_firstBe;
  wire       [3:0]    logic_pop_sync_readPort_rsp_lastBe;
  wire       [2:0]    logic_pop_sync_readPort_rsp_tc;
  wire       [1:0]    logic_pop_sync_readPort_rsp_attr;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_0;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_1;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_2;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_3;
  wire       [2:0]    logic_pop_sync_readPort_rsp_dataValid;
  wire       [3:0]    _zz_logic_pop_sync_readPort_rsp_tlpType;
  wire       [245:0]  _zz_logic_pop_sync_readPort_rsp_reqId;
  wire       [3:0]    _zz_logic_pop_sync_readPort_rsp_tlpType_1;
  wire       [127:0]  _zz_logic_pop_sync_readPort_rsp_data_0;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_tlpType;
  wire       [15:0]   logic_pop_sync_readArbitation_translated_payload_reqId;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload_tag;
  wire       [63:0]   logic_pop_sync_readArbitation_translated_payload_addr;
  wire       [9:0]    logic_pop_sync_readArbitation_translated_payload_length;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_firstBe;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_lastBe;
  wire       [2:0]    logic_pop_sync_readArbitation_translated_payload_tc;
  wire       [1:0]    logic_pop_sync_readArbitation_translated_payload_attr;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_0;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_1;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_2;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_3;
  wire       [2:0]    logic_pop_sync_readArbitation_translated_payload_dataValid;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [5:0]    logic_pop_sync_popReg;
  `ifndef SYNTHESIS
  reg [55:0] io_push_payload_tlpType_string;
  reg [55:0] io_pop_payload_tlpType_string;
  reg [55:0] logic_push_onRam_write_payload_data_tlpType_string;
  reg [55:0] logic_pop_sync_readPort_rsp_tlpType_string;
  reg [55:0] _zz_logic_pop_sync_readPort_rsp_tlpType_string;
  reg [55:0] _zz_logic_pop_sync_readPort_rsp_tlpType_1_string;
  reg [55:0] logic_pop_sync_readArbitation_translated_payload_tlpType_string;
  `endif

  reg [245:0] logic_ram [0:31];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_dataValid,{{logic_push_onRam_write_payload_data_data_3,{logic_push_onRam_write_payload_data_data_2,{logic_push_onRam_write_payload_data_data_1,logic_push_onRam_write_payload_data_data_0}}},{logic_push_onRam_write_payload_data_attr,{logic_push_onRam_write_payload_data_tc,{logic_push_onRam_write_payload_data_lastBe,{logic_push_onRam_write_payload_data_firstBe,{logic_push_onRam_write_payload_data_length,{logic_push_onRam_write_payload_data_addr,{logic_push_onRam_write_payload_data_tag,{logic_push_onRam_write_payload_data_reqId,logic_push_onRam_write_payload_data_tlpType}}}}}}}}}};
  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= _zz_logic_ram_port;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      _zz_logic_ram_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_push_payload_tlpType)
      TlpType_MEM_RD : io_push_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_push_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_push_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_push_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_push_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_push_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_push_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_push_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_push_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_push_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_push_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_push_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_push_payload_tlpType_string = "INVALID";
      default : io_push_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_pop_payload_tlpType)
      TlpType_MEM_RD : io_pop_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_pop_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_pop_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_pop_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_pop_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_pop_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_pop_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_pop_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_pop_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_pop_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_pop_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_pop_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_pop_payload_tlpType_string = "INVALID";
      default : io_pop_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_push_onRam_write_payload_data_tlpType)
      TlpType_MEM_RD : logic_push_onRam_write_payload_data_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_push_onRam_write_payload_data_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_push_onRam_write_payload_data_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_push_onRam_write_payload_data_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_push_onRam_write_payload_data_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_push_onRam_write_payload_data_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_push_onRam_write_payload_data_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_push_onRam_write_payload_data_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_push_onRam_write_payload_data_tlpType_string = "INVALID";
      default : logic_push_onRam_write_payload_data_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readPort_rsp_tlpType)
      TlpType_MEM_RD : logic_pop_sync_readPort_rsp_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_pop_sync_readPort_rsp_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_pop_sync_readPort_rsp_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_pop_sync_readPort_rsp_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_pop_sync_readPort_rsp_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_pop_sync_readPort_rsp_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_pop_sync_readPort_rsp_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_pop_sync_readPort_rsp_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_pop_sync_readPort_rsp_tlpType_string = "INVALID";
      default : logic_pop_sync_readPort_rsp_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_tlpType)
      TlpType_MEM_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR1";
      TlpType_CPL : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CPL    ";
      TlpType_CPL_D : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CPL_D  ";
      TlpType_MSG : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MSG    ";
      TlpType_MSG_D : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MSG_D  ";
      TlpType_INVALID : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "INVALID";
      default : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_tlpType_1)
      TlpType_MEM_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MEM_WR ";
      TlpType_IO_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "IO_RD  ";
      TlpType_IO_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_WR1";
      TlpType_CPL : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CPL    ";
      TlpType_CPL_D : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CPL_D  ";
      TlpType_MSG : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MSG    ";
      TlpType_MSG_D : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MSG_D  ";
      TlpType_INVALID : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "INVALID";
      default : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readArbitation_translated_payload_tlpType)
      TlpType_MEM_RD : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "INVALID";
      default : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "???????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1205 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 6'h20) == 6'h00);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[4:0];
  assign logic_push_onRam_write_payload_data_tlpType = io_push_payload_tlpType;
  assign logic_push_onRam_write_payload_data_reqId = io_push_payload_reqId;
  assign logic_push_onRam_write_payload_data_tag = io_push_payload_tag;
  assign logic_push_onRam_write_payload_data_addr = io_push_payload_addr;
  assign logic_push_onRam_write_payload_data_length = io_push_payload_length;
  assign logic_push_onRam_write_payload_data_firstBe = io_push_payload_firstBe;
  assign logic_push_onRam_write_payload_data_lastBe = io_push_payload_lastBe;
  assign logic_push_onRam_write_payload_data_tc = io_push_payload_tc;
  assign logic_push_onRam_write_payload_data_attr = io_push_payload_attr;
  assign logic_push_onRam_write_payload_data_data_0 = io_push_payload_data_0;
  assign logic_push_onRam_write_payload_data_data_1 = io_push_payload_data_1;
  assign logic_push_onRam_write_payload_data_data_2 = io_push_payload_data_2;
  assign logic_push_onRam_write_payload_data_data_3 = io_push_payload_data_3;
  assign logic_push_onRam_write_payload_data_dataValid = io_push_payload_dataValid;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[4:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l369) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign _zz_logic_pop_sync_readPort_rsp_reqId = _zz_logic_ram_port1;
  assign _zz_logic_pop_sync_readPort_rsp_tlpType_1 = _zz_logic_pop_sync_readPort_rsp_reqId[3 : 0];
  assign _zz_logic_pop_sync_readPort_rsp_tlpType = _zz_logic_pop_sync_readPort_rsp_tlpType_1;
  assign _zz_logic_pop_sync_readPort_rsp_data_0 = _zz_logic_pop_sync_readPort_rsp_reqId[242 : 115];
  assign logic_pop_sync_readPort_rsp_tlpType = _zz_logic_pop_sync_readPort_rsp_tlpType;
  assign logic_pop_sync_readPort_rsp_reqId = _zz_logic_pop_sync_readPort_rsp_reqId[19 : 4];
  assign logic_pop_sync_readPort_rsp_tag = _zz_logic_pop_sync_readPort_rsp_reqId[27 : 20];
  assign logic_pop_sync_readPort_rsp_addr = _zz_logic_pop_sync_readPort_rsp_reqId[91 : 28];
  assign logic_pop_sync_readPort_rsp_length = _zz_logic_pop_sync_readPort_rsp_reqId[101 : 92];
  assign logic_pop_sync_readPort_rsp_firstBe = _zz_logic_pop_sync_readPort_rsp_reqId[105 : 102];
  assign logic_pop_sync_readPort_rsp_lastBe = _zz_logic_pop_sync_readPort_rsp_reqId[109 : 106];
  assign logic_pop_sync_readPort_rsp_tc = _zz_logic_pop_sync_readPort_rsp_reqId[112 : 110];
  assign logic_pop_sync_readPort_rsp_attr = _zz_logic_pop_sync_readPort_rsp_reqId[114 : 113];
  assign logic_pop_sync_readPort_rsp_data_0 = _zz_logic_pop_sync_readPort_rsp_data_0[31 : 0];
  assign logic_pop_sync_readPort_rsp_data_1 = _zz_logic_pop_sync_readPort_rsp_data_0[63 : 32];
  assign logic_pop_sync_readPort_rsp_data_2 = _zz_logic_pop_sync_readPort_rsp_data_0[95 : 64];
  assign logic_pop_sync_readPort_rsp_data_3 = _zz_logic_pop_sync_readPort_rsp_data_0[127 : 96];
  assign logic_pop_sync_readPort_rsp_dataValid = _zz_logic_pop_sync_readPort_rsp_reqId[245 : 243];
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_tlpType = logic_pop_sync_readPort_rsp_tlpType;
  assign logic_pop_sync_readArbitation_translated_payload_reqId = logic_pop_sync_readPort_rsp_reqId;
  assign logic_pop_sync_readArbitation_translated_payload_tag = logic_pop_sync_readPort_rsp_tag;
  assign logic_pop_sync_readArbitation_translated_payload_addr = logic_pop_sync_readPort_rsp_addr;
  assign logic_pop_sync_readArbitation_translated_payload_length = logic_pop_sync_readPort_rsp_length;
  assign logic_pop_sync_readArbitation_translated_payload_firstBe = logic_pop_sync_readPort_rsp_firstBe;
  assign logic_pop_sync_readArbitation_translated_payload_lastBe = logic_pop_sync_readPort_rsp_lastBe;
  assign logic_pop_sync_readArbitation_translated_payload_tc = logic_pop_sync_readPort_rsp_tc;
  assign logic_pop_sync_readArbitation_translated_payload_attr = logic_pop_sync_readPort_rsp_attr;
  assign logic_pop_sync_readArbitation_translated_payload_data_0 = logic_pop_sync_readPort_rsp_data_0;
  assign logic_pop_sync_readArbitation_translated_payload_data_1 = logic_pop_sync_readPort_rsp_data_1;
  assign logic_pop_sync_readArbitation_translated_payload_data_2 = logic_pop_sync_readPort_rsp_data_2;
  assign logic_pop_sync_readArbitation_translated_payload_data_3 = logic_pop_sync_readPort_rsp_data_3;
  assign logic_pop_sync_readArbitation_translated_payload_dataValid = logic_pop_sync_readPort_rsp_dataValid;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_tlpType = logic_pop_sync_readArbitation_translated_payload_tlpType;
  assign io_pop_payload_reqId = logic_pop_sync_readArbitation_translated_payload_reqId;
  assign io_pop_payload_tag = logic_pop_sync_readArbitation_translated_payload_tag;
  assign io_pop_payload_addr = logic_pop_sync_readArbitation_translated_payload_addr;
  assign io_pop_payload_length = logic_pop_sync_readArbitation_translated_payload_length;
  assign io_pop_payload_firstBe = logic_pop_sync_readArbitation_translated_payload_firstBe;
  assign io_pop_payload_lastBe = logic_pop_sync_readArbitation_translated_payload_lastBe;
  assign io_pop_payload_tc = logic_pop_sync_readArbitation_translated_payload_tc;
  assign io_pop_payload_attr = logic_pop_sync_readArbitation_translated_payload_attr;
  assign io_pop_payload_data_0 = logic_pop_sync_readArbitation_translated_payload_data_0;
  assign io_pop_payload_data_1 = logic_pop_sync_readArbitation_translated_payload_data_1;
  assign io_pop_payload_data_2 = logic_pop_sync_readArbitation_translated_payload_data_2;
  assign io_pop_payload_data_3 = logic_pop_sync_readArbitation_translated_payload_data_3;
  assign io_pop_payload_dataValid = logic_pop_sync_readArbitation_translated_payload_dataValid;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (6'h20 - logic_ptr_occupancy);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      logic_ptr_push <= 6'h00;
      logic_ptr_pop <= 6'h00;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 6'h00;
    end else begin
      if(when_Stream_l1205) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 6'h01);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 6'h01);
      end
      if(io_flush) begin
        logic_ptr_push <= 6'h00;
        logic_ptr_pop <= 6'h00;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 6'h00;
      end
    end
  end

  always @(posedge clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module StreamFifo (
  input  wire          io_push_valid,
  output wire          io_push_ready,
  input  wire [3:0]    io_push_payload_tlpType,
  input  wire [15:0]   io_push_payload_reqId,
  input  wire [7:0]    io_push_payload_tag,
  input  wire [63:0]   io_push_payload_addr,
  input  wire [9:0]    io_push_payload_length,
  input  wire [3:0]    io_push_payload_firstBe,
  input  wire [3:0]    io_push_payload_lastBe,
  input  wire [2:0]    io_push_payload_tc,
  input  wire [1:0]    io_push_payload_attr,
  input  wire [31:0]   io_push_payload_data_0,
  input  wire [31:0]   io_push_payload_data_1,
  input  wire [31:0]   io_push_payload_data_2,
  input  wire [31:0]   io_push_payload_data_3,
  input  wire [2:0]    io_push_payload_dataValid,
  output wire          io_pop_valid,
  input  wire          io_pop_ready,
  output wire [3:0]    io_pop_payload_tlpType,
  output wire [15:0]   io_pop_payload_reqId,
  output wire [7:0]    io_pop_payload_tag,
  output wire [63:0]   io_pop_payload_addr,
  output wire [9:0]    io_pop_payload_length,
  output wire [3:0]    io_pop_payload_firstBe,
  output wire [3:0]    io_pop_payload_lastBe,
  output wire [2:0]    io_pop_payload_tc,
  output wire [1:0]    io_pop_payload_attr,
  output wire [31:0]   io_pop_payload_data_0,
  output wire [31:0]   io_pop_payload_data_1,
  output wire [31:0]   io_pop_payload_data_2,
  output wire [31:0]   io_pop_payload_data_3,
  output wire [2:0]    io_pop_payload_dataValid,
  input  wire          io_flush,
  output wire [6:0]    io_occupancy,
  output wire [6:0]    io_availability,
  input  wire          clk,
  input  wire          reset
);
  localparam TlpType_MEM_RD = 4'd0;
  localparam TlpType_MEM_WR = 4'd1;
  localparam TlpType_IO_RD = 4'd2;
  localparam TlpType_IO_WR = 4'd3;
  localparam TlpType_CFG_RD0 = 4'd4;
  localparam TlpType_CFG_WR0 = 4'd5;
  localparam TlpType_CFG_RD1 = 4'd6;
  localparam TlpType_CFG_WR1 = 4'd7;
  localparam TlpType_CPL = 4'd8;
  localparam TlpType_CPL_D = 4'd9;
  localparam TlpType_MSG = 4'd10;
  localparam TlpType_MSG_D = 4'd11;
  localparam TlpType_INVALID = 4'd12;

  reg        [245:0]  _zz_logic_ram_port1;
  wire       [245:0]  _zz_logic_ram_port;
  reg                 _zz_1;
  wire                logic_ptr_doPush;
  wire                logic_ptr_doPop;
  wire                logic_ptr_full;
  wire                logic_ptr_empty;
  reg        [6:0]    logic_ptr_push;
  reg        [6:0]    logic_ptr_pop;
  wire       [6:0]    logic_ptr_occupancy;
  wire       [6:0]    logic_ptr_popOnIo;
  wire                when_Stream_l1205;
  reg                 logic_ptr_wentUp;
  wire                io_push_fire;
  wire                logic_push_onRam_write_valid;
  wire       [5:0]    logic_push_onRam_write_payload_address;
  wire       [3:0]    logic_push_onRam_write_payload_data_tlpType;
  wire       [15:0]   logic_push_onRam_write_payload_data_reqId;
  wire       [7:0]    logic_push_onRam_write_payload_data_tag;
  wire       [63:0]   logic_push_onRam_write_payload_data_addr;
  wire       [9:0]    logic_push_onRam_write_payload_data_length;
  wire       [3:0]    logic_push_onRam_write_payload_data_firstBe;
  wire       [3:0]    logic_push_onRam_write_payload_data_lastBe;
  wire       [2:0]    logic_push_onRam_write_payload_data_tc;
  wire       [1:0]    logic_push_onRam_write_payload_data_attr;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_0;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_1;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_2;
  wire       [31:0]   logic_push_onRam_write_payload_data_data_3;
  wire       [2:0]    logic_push_onRam_write_payload_data_dataValid;
  wire                logic_pop_addressGen_valid;
  reg                 logic_pop_addressGen_ready;
  wire       [5:0]    logic_pop_addressGen_payload;
  wire                logic_pop_addressGen_fire;
  wire                logic_pop_sync_readArbitation_valid;
  wire                logic_pop_sync_readArbitation_ready;
  wire       [5:0]    logic_pop_sync_readArbitation_payload;
  reg                 logic_pop_addressGen_rValid;
  reg        [5:0]    logic_pop_addressGen_rData;
  wire                when_Stream_l369;
  wire                logic_pop_sync_readPort_cmd_valid;
  wire       [5:0]    logic_pop_sync_readPort_cmd_payload;
  wire       [3:0]    logic_pop_sync_readPort_rsp_tlpType;
  wire       [15:0]   logic_pop_sync_readPort_rsp_reqId;
  wire       [7:0]    logic_pop_sync_readPort_rsp_tag;
  wire       [63:0]   logic_pop_sync_readPort_rsp_addr;
  wire       [9:0]    logic_pop_sync_readPort_rsp_length;
  wire       [3:0]    logic_pop_sync_readPort_rsp_firstBe;
  wire       [3:0]    logic_pop_sync_readPort_rsp_lastBe;
  wire       [2:0]    logic_pop_sync_readPort_rsp_tc;
  wire       [1:0]    logic_pop_sync_readPort_rsp_attr;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_0;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_1;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_2;
  wire       [31:0]   logic_pop_sync_readPort_rsp_data_3;
  wire       [2:0]    logic_pop_sync_readPort_rsp_dataValid;
  wire       [3:0]    _zz_logic_pop_sync_readPort_rsp_tlpType;
  wire       [245:0]  _zz_logic_pop_sync_readPort_rsp_reqId;
  wire       [3:0]    _zz_logic_pop_sync_readPort_rsp_tlpType_1;
  wire       [127:0]  _zz_logic_pop_sync_readPort_rsp_data_0;
  wire                logic_pop_sync_readArbitation_translated_valid;
  wire                logic_pop_sync_readArbitation_translated_ready;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_tlpType;
  wire       [15:0]   logic_pop_sync_readArbitation_translated_payload_reqId;
  wire       [7:0]    logic_pop_sync_readArbitation_translated_payload_tag;
  wire       [63:0]   logic_pop_sync_readArbitation_translated_payload_addr;
  wire       [9:0]    logic_pop_sync_readArbitation_translated_payload_length;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_firstBe;
  wire       [3:0]    logic_pop_sync_readArbitation_translated_payload_lastBe;
  wire       [2:0]    logic_pop_sync_readArbitation_translated_payload_tc;
  wire       [1:0]    logic_pop_sync_readArbitation_translated_payload_attr;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_0;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_1;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_2;
  wire       [31:0]   logic_pop_sync_readArbitation_translated_payload_data_3;
  wire       [2:0]    logic_pop_sync_readArbitation_translated_payload_dataValid;
  wire                logic_pop_sync_readArbitation_fire;
  reg        [6:0]    logic_pop_sync_popReg;
  `ifndef SYNTHESIS
  reg [55:0] io_push_payload_tlpType_string;
  reg [55:0] io_pop_payload_tlpType_string;
  reg [55:0] logic_push_onRam_write_payload_data_tlpType_string;
  reg [55:0] logic_pop_sync_readPort_rsp_tlpType_string;
  reg [55:0] _zz_logic_pop_sync_readPort_rsp_tlpType_string;
  reg [55:0] _zz_logic_pop_sync_readPort_rsp_tlpType_1_string;
  reg [55:0] logic_pop_sync_readArbitation_translated_payload_tlpType_string;
  `endif

  reg [245:0] logic_ram [0:63];

  assign _zz_logic_ram_port = {logic_push_onRam_write_payload_data_dataValid,{{logic_push_onRam_write_payload_data_data_3,{logic_push_onRam_write_payload_data_data_2,{logic_push_onRam_write_payload_data_data_1,logic_push_onRam_write_payload_data_data_0}}},{logic_push_onRam_write_payload_data_attr,{logic_push_onRam_write_payload_data_tc,{logic_push_onRam_write_payload_data_lastBe,{logic_push_onRam_write_payload_data_firstBe,{logic_push_onRam_write_payload_data_length,{logic_push_onRam_write_payload_data_addr,{logic_push_onRam_write_payload_data_tag,{logic_push_onRam_write_payload_data_reqId,logic_push_onRam_write_payload_data_tlpType}}}}}}}}}};
  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_push_onRam_write_payload_address] <= _zz_logic_ram_port;
    end
  end

  always @(posedge clk) begin
    if(logic_pop_sync_readPort_cmd_valid) begin
      _zz_logic_ram_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
    end
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_push_payload_tlpType)
      TlpType_MEM_RD : io_push_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_push_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_push_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_push_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_push_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_push_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_push_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_push_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_push_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_push_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_push_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_push_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_push_payload_tlpType_string = "INVALID";
      default : io_push_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(io_pop_payload_tlpType)
      TlpType_MEM_RD : io_pop_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : io_pop_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : io_pop_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : io_pop_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : io_pop_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : io_pop_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : io_pop_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : io_pop_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : io_pop_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : io_pop_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : io_pop_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : io_pop_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : io_pop_payload_tlpType_string = "INVALID";
      default : io_pop_payload_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_push_onRam_write_payload_data_tlpType)
      TlpType_MEM_RD : logic_push_onRam_write_payload_data_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_push_onRam_write_payload_data_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_push_onRam_write_payload_data_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_push_onRam_write_payload_data_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_push_onRam_write_payload_data_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_push_onRam_write_payload_data_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_push_onRam_write_payload_data_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_push_onRam_write_payload_data_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_push_onRam_write_payload_data_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_push_onRam_write_payload_data_tlpType_string = "INVALID";
      default : logic_push_onRam_write_payload_data_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readPort_rsp_tlpType)
      TlpType_MEM_RD : logic_pop_sync_readPort_rsp_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_pop_sync_readPort_rsp_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_pop_sync_readPort_rsp_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_pop_sync_readPort_rsp_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_pop_sync_readPort_rsp_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_pop_sync_readPort_rsp_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_pop_sync_readPort_rsp_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_pop_sync_readPort_rsp_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_pop_sync_readPort_rsp_tlpType_string = "INVALID";
      default : logic_pop_sync_readPort_rsp_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_tlpType)
      TlpType_MEM_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CFG_WR1";
      TlpType_CPL : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CPL    ";
      TlpType_CPL_D : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "CPL_D  ";
      TlpType_MSG : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MSG    ";
      TlpType_MSG_D : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "MSG_D  ";
      TlpType_INVALID : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "INVALID";
      default : _zz_logic_pop_sync_readPort_rsp_tlpType_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_logic_pop_sync_readPort_rsp_tlpType_1)
      TlpType_MEM_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MEM_RD ";
      TlpType_MEM_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MEM_WR ";
      TlpType_IO_RD : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "IO_RD  ";
      TlpType_IO_WR : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "IO_WR  ";
      TlpType_CFG_RD0 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_RD0";
      TlpType_CFG_WR0 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_WR0";
      TlpType_CFG_RD1 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_RD1";
      TlpType_CFG_WR1 : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CFG_WR1";
      TlpType_CPL : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CPL    ";
      TlpType_CPL_D : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "CPL_D  ";
      TlpType_MSG : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MSG    ";
      TlpType_MSG_D : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "MSG_D  ";
      TlpType_INVALID : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "INVALID";
      default : _zz_logic_pop_sync_readPort_rsp_tlpType_1_string = "???????";
    endcase
  end
  always @(*) begin
    case(logic_pop_sync_readArbitation_translated_payload_tlpType)
      TlpType_MEM_RD : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MEM_RD ";
      TlpType_MEM_WR : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MEM_WR ";
      TlpType_IO_RD : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "IO_RD  ";
      TlpType_IO_WR : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "IO_WR  ";
      TlpType_CFG_RD0 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_RD0";
      TlpType_CFG_WR0 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_WR0";
      TlpType_CFG_RD1 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_RD1";
      TlpType_CFG_WR1 : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CFG_WR1";
      TlpType_CPL : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CPL    ";
      TlpType_CPL_D : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "CPL_D  ";
      TlpType_MSG : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MSG    ";
      TlpType_MSG_D : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "MSG_D  ";
      TlpType_INVALID : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "INVALID";
      default : logic_pop_sync_readArbitation_translated_payload_tlpType_string = "???????";
    endcase
  end
  `endif

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_push_onRam_write_valid) begin
      _zz_1 = 1'b1;
    end
  end

  assign when_Stream_l1205 = (logic_ptr_doPush != logic_ptr_doPop);
  assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 7'h40) == 7'h00);
  assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
  assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
  assign io_push_ready = (! logic_ptr_full);
  assign io_push_fire = (io_push_valid && io_push_ready);
  assign logic_ptr_doPush = io_push_fire;
  assign logic_push_onRam_write_valid = io_push_fire;
  assign logic_push_onRam_write_payload_address = logic_ptr_push[5:0];
  assign logic_push_onRam_write_payload_data_tlpType = io_push_payload_tlpType;
  assign logic_push_onRam_write_payload_data_reqId = io_push_payload_reqId;
  assign logic_push_onRam_write_payload_data_tag = io_push_payload_tag;
  assign logic_push_onRam_write_payload_data_addr = io_push_payload_addr;
  assign logic_push_onRam_write_payload_data_length = io_push_payload_length;
  assign logic_push_onRam_write_payload_data_firstBe = io_push_payload_firstBe;
  assign logic_push_onRam_write_payload_data_lastBe = io_push_payload_lastBe;
  assign logic_push_onRam_write_payload_data_tc = io_push_payload_tc;
  assign logic_push_onRam_write_payload_data_attr = io_push_payload_attr;
  assign logic_push_onRam_write_payload_data_data_0 = io_push_payload_data_0;
  assign logic_push_onRam_write_payload_data_data_1 = io_push_payload_data_1;
  assign logic_push_onRam_write_payload_data_data_2 = io_push_payload_data_2;
  assign logic_push_onRam_write_payload_data_data_3 = io_push_payload_data_3;
  assign logic_push_onRam_write_payload_data_dataValid = io_push_payload_dataValid;
  assign logic_pop_addressGen_valid = (! logic_ptr_empty);
  assign logic_pop_addressGen_payload = logic_ptr_pop[5:0];
  assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
  assign logic_ptr_doPop = logic_pop_addressGen_fire;
  always @(*) begin
    logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
    if(when_Stream_l369) begin
      logic_pop_addressGen_ready = 1'b1;
    end
  end

  assign when_Stream_l369 = (! logic_pop_sync_readArbitation_valid);
  assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
  assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
  assign _zz_logic_pop_sync_readPort_rsp_reqId = _zz_logic_ram_port1;
  assign _zz_logic_pop_sync_readPort_rsp_tlpType_1 = _zz_logic_pop_sync_readPort_rsp_reqId[3 : 0];
  assign _zz_logic_pop_sync_readPort_rsp_tlpType = _zz_logic_pop_sync_readPort_rsp_tlpType_1;
  assign _zz_logic_pop_sync_readPort_rsp_data_0 = _zz_logic_pop_sync_readPort_rsp_reqId[242 : 115];
  assign logic_pop_sync_readPort_rsp_tlpType = _zz_logic_pop_sync_readPort_rsp_tlpType;
  assign logic_pop_sync_readPort_rsp_reqId = _zz_logic_pop_sync_readPort_rsp_reqId[19 : 4];
  assign logic_pop_sync_readPort_rsp_tag = _zz_logic_pop_sync_readPort_rsp_reqId[27 : 20];
  assign logic_pop_sync_readPort_rsp_addr = _zz_logic_pop_sync_readPort_rsp_reqId[91 : 28];
  assign logic_pop_sync_readPort_rsp_length = _zz_logic_pop_sync_readPort_rsp_reqId[101 : 92];
  assign logic_pop_sync_readPort_rsp_firstBe = _zz_logic_pop_sync_readPort_rsp_reqId[105 : 102];
  assign logic_pop_sync_readPort_rsp_lastBe = _zz_logic_pop_sync_readPort_rsp_reqId[109 : 106];
  assign logic_pop_sync_readPort_rsp_tc = _zz_logic_pop_sync_readPort_rsp_reqId[112 : 110];
  assign logic_pop_sync_readPort_rsp_attr = _zz_logic_pop_sync_readPort_rsp_reqId[114 : 113];
  assign logic_pop_sync_readPort_rsp_data_0 = _zz_logic_pop_sync_readPort_rsp_data_0[31 : 0];
  assign logic_pop_sync_readPort_rsp_data_1 = _zz_logic_pop_sync_readPort_rsp_data_0[63 : 32];
  assign logic_pop_sync_readPort_rsp_data_2 = _zz_logic_pop_sync_readPort_rsp_data_0[95 : 64];
  assign logic_pop_sync_readPort_rsp_data_3 = _zz_logic_pop_sync_readPort_rsp_data_0[127 : 96];
  assign logic_pop_sync_readPort_rsp_dataValid = _zz_logic_pop_sync_readPort_rsp_reqId[245 : 243];
  assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
  assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
  assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
  assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
  assign logic_pop_sync_readArbitation_translated_payload_tlpType = logic_pop_sync_readPort_rsp_tlpType;
  assign logic_pop_sync_readArbitation_translated_payload_reqId = logic_pop_sync_readPort_rsp_reqId;
  assign logic_pop_sync_readArbitation_translated_payload_tag = logic_pop_sync_readPort_rsp_tag;
  assign logic_pop_sync_readArbitation_translated_payload_addr = logic_pop_sync_readPort_rsp_addr;
  assign logic_pop_sync_readArbitation_translated_payload_length = logic_pop_sync_readPort_rsp_length;
  assign logic_pop_sync_readArbitation_translated_payload_firstBe = logic_pop_sync_readPort_rsp_firstBe;
  assign logic_pop_sync_readArbitation_translated_payload_lastBe = logic_pop_sync_readPort_rsp_lastBe;
  assign logic_pop_sync_readArbitation_translated_payload_tc = logic_pop_sync_readPort_rsp_tc;
  assign logic_pop_sync_readArbitation_translated_payload_attr = logic_pop_sync_readPort_rsp_attr;
  assign logic_pop_sync_readArbitation_translated_payload_data_0 = logic_pop_sync_readPort_rsp_data_0;
  assign logic_pop_sync_readArbitation_translated_payload_data_1 = logic_pop_sync_readPort_rsp_data_1;
  assign logic_pop_sync_readArbitation_translated_payload_data_2 = logic_pop_sync_readPort_rsp_data_2;
  assign logic_pop_sync_readArbitation_translated_payload_data_3 = logic_pop_sync_readPort_rsp_data_3;
  assign logic_pop_sync_readArbitation_translated_payload_dataValid = logic_pop_sync_readPort_rsp_dataValid;
  assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
  assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
  assign io_pop_payload_tlpType = logic_pop_sync_readArbitation_translated_payload_tlpType;
  assign io_pop_payload_reqId = logic_pop_sync_readArbitation_translated_payload_reqId;
  assign io_pop_payload_tag = logic_pop_sync_readArbitation_translated_payload_tag;
  assign io_pop_payload_addr = logic_pop_sync_readArbitation_translated_payload_addr;
  assign io_pop_payload_length = logic_pop_sync_readArbitation_translated_payload_length;
  assign io_pop_payload_firstBe = logic_pop_sync_readArbitation_translated_payload_firstBe;
  assign io_pop_payload_lastBe = logic_pop_sync_readArbitation_translated_payload_lastBe;
  assign io_pop_payload_tc = logic_pop_sync_readArbitation_translated_payload_tc;
  assign io_pop_payload_attr = logic_pop_sync_readArbitation_translated_payload_attr;
  assign io_pop_payload_data_0 = logic_pop_sync_readArbitation_translated_payload_data_0;
  assign io_pop_payload_data_1 = logic_pop_sync_readArbitation_translated_payload_data_1;
  assign io_pop_payload_data_2 = logic_pop_sync_readArbitation_translated_payload_data_2;
  assign io_pop_payload_data_3 = logic_pop_sync_readArbitation_translated_payload_data_3;
  assign io_pop_payload_dataValid = logic_pop_sync_readArbitation_translated_payload_dataValid;
  assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
  assign logic_ptr_popOnIo = logic_pop_sync_popReg;
  assign io_occupancy = logic_ptr_occupancy;
  assign io_availability = (7'h40 - logic_ptr_occupancy);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      logic_ptr_push <= 7'h00;
      logic_ptr_pop <= 7'h00;
      logic_ptr_wentUp <= 1'b0;
      logic_pop_addressGen_rValid <= 1'b0;
      logic_pop_sync_popReg <= 7'h00;
    end else begin
      if(when_Stream_l1205) begin
        logic_ptr_wentUp <= logic_ptr_doPush;
      end
      if(io_flush) begin
        logic_ptr_wentUp <= 1'b0;
      end
      if(logic_ptr_doPush) begin
        logic_ptr_push <= (logic_ptr_push + 7'h01);
      end
      if(logic_ptr_doPop) begin
        logic_ptr_pop <= (logic_ptr_pop + 7'h01);
      end
      if(io_flush) begin
        logic_ptr_push <= 7'h00;
        logic_ptr_pop <= 7'h00;
      end
      if(logic_pop_addressGen_ready) begin
        logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
      end
      if(io_flush) begin
        logic_pop_addressGen_rValid <= 1'b0;
      end
      if(logic_pop_sync_readArbitation_fire) begin
        logic_pop_sync_popReg <= logic_ptr_pop;
      end
      if(io_flush) begin
        logic_pop_sync_popReg <= 7'h00;
      end
    end
  end

  always @(posedge clk) begin
    if(logic_pop_addressGen_ready) begin
      logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
    end
  end


endmodule

module TsDetector (
  input  wire [7:0]    io_dataIn,
  input  wire          io_kCodeIn,
  input  wire          io_validIn,
  output wire          io_ts1Det,
  output wire          io_ts2Det,
  output wire [7:0]    io_linkNum,
  output wire [4:0]    io_laneNum,
  input  wire          clk,
  input  wire          reset
);

  wire       [7:0]    _zz_laneNumReg;
  reg        [3:0]    symIdx;
  reg        [7:0]    linkNumReg;
  reg        [4:0]    laneNumReg;
  reg                 isTs2;
  reg                 tsValid;
  wire                when_PhysicalLayer_l80;
  wire                when_PhysicalLayer_l104;
  wire                when_PhysicalLayer_l84;

  assign _zz_laneNumReg = io_dataIn;
  assign io_ts1Det = (tsValid && (! isTs2));
  assign io_ts2Det = (tsValid && isTs2);
  assign io_linkNum = linkNumReg;
  assign io_laneNum = laneNumReg;
  assign when_PhysicalLayer_l80 = (io_kCodeIn && (io_dataIn == 8'hbc));
  assign when_PhysicalLayer_l104 = (io_dataIn == 8'h45);
  assign when_PhysicalLayer_l84 = (symIdx < 4'b1111);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      symIdx <= 4'b0000;
      linkNumReg <= 8'h00;
      laneNumReg <= 5'h00;
      isTs2 <= 1'b0;
      tsValid <= 1'b0;
    end else begin
      tsValid <= 1'b0;
      if(io_validIn) begin
        if(when_PhysicalLayer_l80) begin
          symIdx <= 4'b0000;
          isTs2 <= 1'b0;
        end else begin
          if(when_PhysicalLayer_l84) begin
            case(symIdx)
              4'b0000 : begin
                linkNumReg <= io_dataIn;
                symIdx <= 4'b0001;
              end
              4'b0001 : begin
                laneNumReg <= _zz_laneNumReg[4:0];
                symIdx <= 4'b0010;
              end
              4'b0010, 4'b0011, 4'b0100, 4'b0101 : begin
                symIdx <= (symIdx + 4'b0001);
              end
              4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101 : begin
                if(when_PhysicalLayer_l104) begin
                  isTs2 <= 1'b1;
                end
                symIdx <= (symIdx + 4'b0001);
              end
              4'b1110 : begin
                tsValid <= 1'b1;
                symIdx <= 4'b0000;
              end
              default : begin
              end
            endcase
          end
        end
      end else begin
        symIdx <= 4'b0000;
      end
    end
  end


endmodule

module LtssController (
  input  wire          io_rxDetected,
  input  wire          io_rxElecIdle,
  input  wire          io_rxValid,
  input  wire          io_ts1Rcvd,
  input  wire          io_ts2Rcvd,
  input  wire          io_linkResetReq,
  input  wire          io_pmReq,
  input  wire [2:0]    io_pmState,
  input  wire          io_wakeReq,
  input  wire [7:0]    io_tsLinkNum,
  input  wire [4:0]    io_tsLaneNum,
  input  wire          io_laneReversal,
  output wire [1:0]    io_negotiatedWidth,
  output wire          io_linkUp,
  output wire [1:0]    io_linkSpeed,
  output wire [4:0]    io_linkWidth,
  output reg           io_txTs1,
  output reg           io_txTs2,
  output reg           io_txIdleOs,
  output wire [4:0]    io_curState,
  output wire [7:0]    io_busNum,
  output wire          io_inL1,
  output wire          io_inL2,
  output reg           io_pmAck,
  input  wire          clk,
  input  wire          reset
);
  localparam PmState_D0 = 3'd0;
  localparam PmState_D1 = 3'd1;
  localparam PmState_D2 = 3'd2;
  localparam PmState_D3HOT = 3'd3;
  localparam PmState_D3COLD = 3'd4;
  localparam LinkWidth_X1 = 2'd0;
  localparam LinkWidth_X2 = 2'd1;
  localparam LinkWidth_X4 = 2'd2;
  localparam LinkWidth_X8 = 2'd3;
  localparam LtssState_DETECT_QUIET = 5'd0;
  localparam LtssState_DETECT_ACTIVE = 5'd1;
  localparam LtssState_POLLING_ACTIVE = 5'd2;
  localparam LtssState_POLLING_COMPLIANCE = 5'd3;
  localparam LtssState_POLLING_CONFIG = 5'd4;
  localparam LtssState_CONFIG_LINKWIDTH_START = 5'd5;
  localparam LtssState_CONFIG_LINKWIDTH_ACCEPT = 5'd6;
  localparam LtssState_CONFIG_LANENUM_WAIT = 5'd7;
  localparam LtssState_CONFIG_LANENUM_ACCEPT = 5'd8;
  localparam LtssState_CONFIG_COMPLETE = 5'd9;
  localparam LtssState_CONFIG_IDLE = 5'd10;
  localparam LtssState_L0 = 5'd11;
  localparam LtssState_RECOVERY_RCVRLOCK = 5'd12;
  localparam LtssState_RECOVERY_RCVRCFG = 5'd13;
  localparam LtssState_RECOVERY_IDLE = 5'd14;
  localparam LtssState_L0S = 5'd15;
  localparam LtssState_L1_ENTRY = 5'd16;
  localparam LtssState_L1_IDLE = 5'd17;
  localparam LtssState_L1_EXIT = 5'd18;
  localparam LtssState_L2_IDLE = 5'd19;
  localparam LtssState_L2_TRANSMIT_WAKE = 5'd20;
  localparam LtssState_L2_DETECT_WAKE = 5'd21;
  localparam LtssState_DISABLED = 5'd22;
  localparam LtssState_HOT_RESET = 5'd23;
  localparam LtssState_LOOPBACK_ENTRY = 5'd24;
  localparam LtssState_LOOPBACK_ACTIVE = 5'd25;
  localparam LtssState_LOOPBACK_EXIT = 5'd26;

  reg        [4:0]    state;
  reg        [23:0]   timer;
  reg        [7:0]    ts1Count;
  reg        [7:0]    ts2Count;
  reg        [7:0]    busNumReg;
  reg        [4:0]    linkWidthReg;
  reg        [1:0]    linkWidthEnum;
  reg                 inL1Reg;
  reg                 inL2Reg;
  wire                when_PhysicalLayer_l208;
  wire                when_PhysicalLayer_l218;
  wire                when_PhysicalLayer_l229;
  wire                when_PhysicalLayer_l233;
  wire                when_PhysicalLayer_l246;
  wire       [4:0]    switch_PhysicalLayer_l194;
  reg        [1:0]    _zz_linkWidthEnum;
  wire                when_PhysicalLayer_l281;
  wire                when_PhysicalLayer_l289;
  wire                when_PhysicalLayer_l300;
  wire                when_PhysicalLayer_l304;
  wire                when_PhysicalLayer_l307;
  wire                when_PhysicalLayer_l311;
  wire                when_PhysicalLayer_l322;
  wire                when_PhysicalLayer_l333;
  wire                when_PhysicalLayer_l362;
  wire                when_PhysicalLayer_l371;
  wire                when_PhysicalLayer_l379;
  wire                when_PhysicalLayer_l383;
  wire                when_PhysicalLayer_l405;
  wire                when_PhysicalLayer_l412;
  wire                when_PhysicalLayer_l416;
  wire                when_PhysicalLayer_l433;
  wire                when_PhysicalLayer_l436;
  wire                when_PhysicalLayer_l456;
  `ifndef SYNTHESIS
  reg [47:0] io_pmState_string;
  reg [15:0] io_negotiatedWidth_string;
  reg [183:0] io_curState_string;
  reg [183:0] state_string;
  reg [15:0] linkWidthEnum_string;
  reg [15:0] _zz_linkWidthEnum_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(io_pmState)
      PmState_D0 : io_pmState_string = "D0    ";
      PmState_D1 : io_pmState_string = "D1    ";
      PmState_D2 : io_pmState_string = "D2    ";
      PmState_D3HOT : io_pmState_string = "D3HOT ";
      PmState_D3COLD : io_pmState_string = "D3COLD";
      default : io_pmState_string = "??????";
    endcase
  end
  always @(*) begin
    case(io_negotiatedWidth)
      LinkWidth_X1 : io_negotiatedWidth_string = "X1";
      LinkWidth_X2 : io_negotiatedWidth_string = "X2";
      LinkWidth_X4 : io_negotiatedWidth_string = "X4";
      LinkWidth_X8 : io_negotiatedWidth_string = "X8";
      default : io_negotiatedWidth_string = "??";
    endcase
  end
  always @(*) begin
    case(io_curState)
      LtssState_DETECT_QUIET : io_curState_string = "DETECT_QUIET           ";
      LtssState_DETECT_ACTIVE : io_curState_string = "DETECT_ACTIVE          ";
      LtssState_POLLING_ACTIVE : io_curState_string = "POLLING_ACTIVE         ";
      LtssState_POLLING_COMPLIANCE : io_curState_string = "POLLING_COMPLIANCE     ";
      LtssState_POLLING_CONFIG : io_curState_string = "POLLING_CONFIG         ";
      LtssState_CONFIG_LINKWIDTH_START : io_curState_string = "CONFIG_LINKWIDTH_START ";
      LtssState_CONFIG_LINKWIDTH_ACCEPT : io_curState_string = "CONFIG_LINKWIDTH_ACCEPT";
      LtssState_CONFIG_LANENUM_WAIT : io_curState_string = "CONFIG_LANENUM_WAIT    ";
      LtssState_CONFIG_LANENUM_ACCEPT : io_curState_string = "CONFIG_LANENUM_ACCEPT  ";
      LtssState_CONFIG_COMPLETE : io_curState_string = "CONFIG_COMPLETE        ";
      LtssState_CONFIG_IDLE : io_curState_string = "CONFIG_IDLE            ";
      LtssState_L0 : io_curState_string = "L0                     ";
      LtssState_RECOVERY_RCVRLOCK : io_curState_string = "RECOVERY_RCVRLOCK      ";
      LtssState_RECOVERY_RCVRCFG : io_curState_string = "RECOVERY_RCVRCFG       ";
      LtssState_RECOVERY_IDLE : io_curState_string = "RECOVERY_IDLE          ";
      LtssState_L0S : io_curState_string = "L0S                    ";
      LtssState_L1_ENTRY : io_curState_string = "L1_ENTRY               ";
      LtssState_L1_IDLE : io_curState_string = "L1_IDLE                ";
      LtssState_L1_EXIT : io_curState_string = "L1_EXIT                ";
      LtssState_L2_IDLE : io_curState_string = "L2_IDLE                ";
      LtssState_L2_TRANSMIT_WAKE : io_curState_string = "L2_TRANSMIT_WAKE       ";
      LtssState_L2_DETECT_WAKE : io_curState_string = "L2_DETECT_WAKE         ";
      LtssState_DISABLED : io_curState_string = "DISABLED               ";
      LtssState_HOT_RESET : io_curState_string = "HOT_RESET              ";
      LtssState_LOOPBACK_ENTRY : io_curState_string = "LOOPBACK_ENTRY         ";
      LtssState_LOOPBACK_ACTIVE : io_curState_string = "LOOPBACK_ACTIVE        ";
      LtssState_LOOPBACK_EXIT : io_curState_string = "LOOPBACK_EXIT          ";
      default : io_curState_string = "???????????????????????";
    endcase
  end
  always @(*) begin
    case(state)
      LtssState_DETECT_QUIET : state_string = "DETECT_QUIET           ";
      LtssState_DETECT_ACTIVE : state_string = "DETECT_ACTIVE          ";
      LtssState_POLLING_ACTIVE : state_string = "POLLING_ACTIVE         ";
      LtssState_POLLING_COMPLIANCE : state_string = "POLLING_COMPLIANCE     ";
      LtssState_POLLING_CONFIG : state_string = "POLLING_CONFIG         ";
      LtssState_CONFIG_LINKWIDTH_START : state_string = "CONFIG_LINKWIDTH_START ";
      LtssState_CONFIG_LINKWIDTH_ACCEPT : state_string = "CONFIG_LINKWIDTH_ACCEPT";
      LtssState_CONFIG_LANENUM_WAIT : state_string = "CONFIG_LANENUM_WAIT    ";
      LtssState_CONFIG_LANENUM_ACCEPT : state_string = "CONFIG_LANENUM_ACCEPT  ";
      LtssState_CONFIG_COMPLETE : state_string = "CONFIG_COMPLETE        ";
      LtssState_CONFIG_IDLE : state_string = "CONFIG_IDLE            ";
      LtssState_L0 : state_string = "L0                     ";
      LtssState_RECOVERY_RCVRLOCK : state_string = "RECOVERY_RCVRLOCK      ";
      LtssState_RECOVERY_RCVRCFG : state_string = "RECOVERY_RCVRCFG       ";
      LtssState_RECOVERY_IDLE : state_string = "RECOVERY_IDLE          ";
      LtssState_L0S : state_string = "L0S                    ";
      LtssState_L1_ENTRY : state_string = "L1_ENTRY               ";
      LtssState_L1_IDLE : state_string = "L1_IDLE                ";
      LtssState_L1_EXIT : state_string = "L1_EXIT                ";
      LtssState_L2_IDLE : state_string = "L2_IDLE                ";
      LtssState_L2_TRANSMIT_WAKE : state_string = "L2_TRANSMIT_WAKE       ";
      LtssState_L2_DETECT_WAKE : state_string = "L2_DETECT_WAKE         ";
      LtssState_DISABLED : state_string = "DISABLED               ";
      LtssState_HOT_RESET : state_string = "HOT_RESET              ";
      LtssState_LOOPBACK_ENTRY : state_string = "LOOPBACK_ENTRY         ";
      LtssState_LOOPBACK_ACTIVE : state_string = "LOOPBACK_ACTIVE        ";
      LtssState_LOOPBACK_EXIT : state_string = "LOOPBACK_EXIT          ";
      default : state_string = "???????????????????????";
    endcase
  end
  always @(*) begin
    case(linkWidthEnum)
      LinkWidth_X1 : linkWidthEnum_string = "X1";
      LinkWidth_X2 : linkWidthEnum_string = "X2";
      LinkWidth_X4 : linkWidthEnum_string = "X4";
      LinkWidth_X8 : linkWidthEnum_string = "X8";
      default : linkWidthEnum_string = "??";
    endcase
  end
  always @(*) begin
    case(_zz_linkWidthEnum)
      LinkWidth_X1 : _zz_linkWidthEnum_string = "X1";
      LinkWidth_X2 : _zz_linkWidthEnum_string = "X2";
      LinkWidth_X4 : _zz_linkWidthEnum_string = "X4";
      LinkWidth_X8 : _zz_linkWidthEnum_string = "X8";
      default : _zz_linkWidthEnum_string = "??";
    endcase
  end
  `endif

  assign io_linkUp = (state == LtssState_L0);
  assign io_linkSpeed = 2'b01;
  assign io_linkWidth = linkWidthReg;
  always @(*) begin
    io_txTs1 = 1'b0;
    case(state)
      LtssState_DETECT_QUIET : begin
      end
      LtssState_DETECT_ACTIVE : begin
      end
      LtssState_POLLING_ACTIVE : begin
        io_txTs1 = 1'b1;
      end
      LtssState_POLLING_CONFIG : begin
      end
      LtssState_CONFIG_LINKWIDTH_START : begin
        io_txTs1 = 1'b1;
      end
      LtssState_CONFIG_LINKWIDTH_ACCEPT : begin
        io_txTs1 = 1'b1;
      end
      LtssState_CONFIG_LANENUM_WAIT : begin
      end
      LtssState_CONFIG_COMPLETE : begin
      end
      LtssState_CONFIG_IDLE : begin
      end
      LtssState_L0 : begin
      end
      LtssState_L0S : begin
      end
      LtssState_RECOVERY_RCVRLOCK : begin
        io_txTs1 = 1'b1;
      end
      LtssState_RECOVERY_RCVRCFG : begin
      end
      LtssState_RECOVERY_IDLE : begin
      end
      LtssState_L1_ENTRY : begin
      end
      LtssState_L1_IDLE : begin
      end
      LtssState_L1_EXIT : begin
        io_txTs1 = 1'b1;
      end
      LtssState_L2_IDLE : begin
      end
      LtssState_L2_TRANSMIT_WAKE : begin
      end
      LtssState_L2_DETECT_WAKE : begin
      end
      LtssState_HOT_RESET : begin
      end
      LtssState_LOOPBACK_ENTRY : begin
        io_txTs1 = 1'b1;
      end
      LtssState_LOOPBACK_ACTIVE : begin
      end
      LtssState_LOOPBACK_EXIT : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_txTs2 = 1'b0;
    case(state)
      LtssState_DETECT_QUIET : begin
      end
      LtssState_DETECT_ACTIVE : begin
      end
      LtssState_POLLING_ACTIVE : begin
      end
      LtssState_POLLING_CONFIG : begin
        io_txTs2 = 1'b1;
      end
      LtssState_CONFIG_LINKWIDTH_START : begin
      end
      LtssState_CONFIG_LINKWIDTH_ACCEPT : begin
      end
      LtssState_CONFIG_LANENUM_WAIT : begin
        io_txTs2 = 1'b1;
      end
      LtssState_CONFIG_COMPLETE : begin
        io_txTs2 = 1'b1;
      end
      LtssState_CONFIG_IDLE : begin
      end
      LtssState_L0 : begin
      end
      LtssState_L0S : begin
      end
      LtssState_RECOVERY_RCVRLOCK : begin
      end
      LtssState_RECOVERY_RCVRCFG : begin
        io_txTs2 = 1'b1;
      end
      LtssState_RECOVERY_IDLE : begin
      end
      LtssState_L1_ENTRY : begin
      end
      LtssState_L1_IDLE : begin
      end
      LtssState_L1_EXIT : begin
      end
      LtssState_L2_IDLE : begin
      end
      LtssState_L2_TRANSMIT_WAKE : begin
      end
      LtssState_L2_DETECT_WAKE : begin
      end
      LtssState_HOT_RESET : begin
      end
      LtssState_LOOPBACK_ENTRY : begin
      end
      LtssState_LOOPBACK_ACTIVE : begin
      end
      LtssState_LOOPBACK_EXIT : begin
        io_txTs2 = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_txIdleOs = 1'b0;
    case(state)
      LtssState_DETECT_QUIET : begin
      end
      LtssState_DETECT_ACTIVE : begin
      end
      LtssState_POLLING_ACTIVE : begin
      end
      LtssState_POLLING_CONFIG : begin
      end
      LtssState_CONFIG_LINKWIDTH_START : begin
      end
      LtssState_CONFIG_LINKWIDTH_ACCEPT : begin
      end
      LtssState_CONFIG_LANENUM_WAIT : begin
      end
      LtssState_CONFIG_COMPLETE : begin
      end
      LtssState_CONFIG_IDLE : begin
        io_txIdleOs = 1'b1;
      end
      LtssState_L0 : begin
      end
      LtssState_L0S : begin
        io_txIdleOs = 1'b1;
      end
      LtssState_RECOVERY_RCVRLOCK : begin
      end
      LtssState_RECOVERY_RCVRCFG : begin
      end
      LtssState_RECOVERY_IDLE : begin
        io_txIdleOs = 1'b1;
      end
      LtssState_L1_ENTRY : begin
        io_txIdleOs = 1'b1;
      end
      LtssState_L1_IDLE : begin
      end
      LtssState_L1_EXIT : begin
      end
      LtssState_L2_IDLE : begin
      end
      LtssState_L2_TRANSMIT_WAKE : begin
      end
      LtssState_L2_DETECT_WAKE : begin
      end
      LtssState_HOT_RESET : begin
      end
      LtssState_LOOPBACK_ENTRY : begin
      end
      LtssState_LOOPBACK_ACTIVE : begin
      end
      LtssState_LOOPBACK_EXIT : begin
      end
      default : begin
      end
    endcase
  end

  assign io_curState = state;
  assign io_busNum = busNumReg;
  assign io_negotiatedWidth = linkWidthEnum;
  assign io_inL1 = inL1Reg;
  assign io_inL2 = inL2Reg;
  always @(*) begin
    io_pmAck = 1'b0;
    case(state)
      LtssState_DETECT_QUIET : begin
      end
      LtssState_DETECT_ACTIVE : begin
      end
      LtssState_POLLING_ACTIVE : begin
      end
      LtssState_POLLING_CONFIG : begin
      end
      LtssState_CONFIG_LINKWIDTH_START : begin
      end
      LtssState_CONFIG_LINKWIDTH_ACCEPT : begin
      end
      LtssState_CONFIG_LANENUM_WAIT : begin
      end
      LtssState_CONFIG_COMPLETE : begin
      end
      LtssState_CONFIG_IDLE : begin
      end
      LtssState_L0 : begin
      end
      LtssState_L0S : begin
      end
      LtssState_RECOVERY_RCVRLOCK : begin
      end
      LtssState_RECOVERY_RCVRCFG : begin
      end
      LtssState_RECOVERY_IDLE : begin
      end
      LtssState_L1_ENTRY : begin
        io_pmAck = 1'b1;
      end
      LtssState_L1_IDLE : begin
      end
      LtssState_L1_EXIT : begin
      end
      LtssState_L2_IDLE : begin
        io_pmAck = 1'b1;
      end
      LtssState_L2_TRANSMIT_WAKE : begin
      end
      LtssState_L2_DETECT_WAKE : begin
      end
      LtssState_HOT_RESET : begin
      end
      LtssState_LOOPBACK_ENTRY : begin
      end
      LtssState_LOOPBACK_ACTIVE : begin
      end
      LtssState_LOOPBACK_EXIT : begin
      end
      default : begin
      end
    endcase
  end

  assign when_PhysicalLayer_l208 = (24'h002710 < timer);
  assign when_PhysicalLayer_l218 = (24'h002ee0 < timer);
  assign when_PhysicalLayer_l229 = (8'h08 <= ts1Count);
  assign when_PhysicalLayer_l233 = (24'h005dc0 < timer);
  assign when_PhysicalLayer_l246 = (8'h08 <= ts2Count);
  assign switch_PhysicalLayer_l194 = (io_tsLaneNum + 5'h01);
  always @(*) begin
    case(switch_PhysicalLayer_l194)
      5'h01 : begin
        _zz_linkWidthEnum = LinkWidth_X1;
      end
      5'h02 : begin
        _zz_linkWidthEnum = LinkWidth_X2;
      end
      5'h04 : begin
        _zz_linkWidthEnum = LinkWidth_X4;
      end
      5'h08 : begin
        _zz_linkWidthEnum = LinkWidth_X8;
      end
      default : begin
        _zz_linkWidthEnum = LinkWidth_X1;
      end
    endcase
  end

  assign when_PhysicalLayer_l281 = (io_ts2Rcvd && (24'h000002 < timer));
  assign when_PhysicalLayer_l289 = (io_rxValid && (24'h000004 < timer));
  assign when_PhysicalLayer_l300 = (io_pmReq && (io_pmState == PmState_D1));
  assign when_PhysicalLayer_l304 = ((! io_rxValid) && (24'h000064 < timer));
  assign when_PhysicalLayer_l307 = (io_pmReq && (io_pmState == PmState_D3HOT));
  assign when_PhysicalLayer_l311 = (io_pmReq && (io_pmState == PmState_D3COLD));
  assign when_PhysicalLayer_l322 = (((! io_pmReq) || io_rxDetected) || io_ts1Rcvd);
  assign when_PhysicalLayer_l333 = (24'h005dc0 < timer);
  assign when_PhysicalLayer_l362 = (24'h00000a < timer);
  assign when_PhysicalLayer_l371 = ((! io_pmReq) || io_rxDetected);
  assign when_PhysicalLayer_l379 = (io_ts1Rcvd && (24'h000064 < timer));
  assign when_PhysicalLayer_l383 = (24'h004e20 < timer);
  assign when_PhysicalLayer_l405 = (24'h0003e8 < timer);
  assign when_PhysicalLayer_l412 = (io_rxDetected && io_ts1Rcvd);
  assign when_PhysicalLayer_l416 = (24'h00c350 < timer);
  assign when_PhysicalLayer_l433 = (io_ts1Rcvd && (24'h000064 < timer));
  assign when_PhysicalLayer_l436 = (24'h005dc0 < timer);
  assign when_PhysicalLayer_l456 = (24'h005dc0 < timer);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      state <= LtssState_DETECT_QUIET;
      timer <= 24'h000000;
      ts1Count <= 8'h00;
      ts2Count <= 8'h00;
      busNumReg <= 8'h00;
      linkWidthReg <= 5'h01;
      linkWidthEnum <= LinkWidth_X1;
      inL1Reg <= 1'b0;
      inL2Reg <= 1'b0;
    end else begin
      timer <= (timer + 24'h000001);
      case(state)
        LtssState_DETECT_QUIET : begin
          inL1Reg <= 1'b0;
          inL2Reg <= 1'b0;
          if(when_PhysicalLayer_l208) begin
            state <= LtssState_DETECT_ACTIVE;
            timer <= 24'h000000;
          end
        end
        LtssState_DETECT_ACTIVE : begin
          if(io_rxDetected) begin
            state <= LtssState_POLLING_ACTIVE;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l218) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_POLLING_ACTIVE : begin
          if(io_ts1Rcvd) begin
            ts1Count <= (ts1Count + 8'h01);
          end
          if(when_PhysicalLayer_l229) begin
            state <= LtssState_POLLING_CONFIG;
            ts1Count <= 8'h00;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l233) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_POLLING_CONFIG : begin
          if(io_ts2Rcvd) begin
            ts2Count <= (ts2Count + 8'h01);
            busNumReg <= io_tsLinkNum;
          end
          if(when_PhysicalLayer_l246) begin
            state <= LtssState_CONFIG_LINKWIDTH_START;
            ts2Count <= 8'h00;
            timer <= 24'h000000;
          end
        end
        LtssState_CONFIG_LINKWIDTH_START : begin
          if(io_ts1Rcvd) begin
            state <= LtssState_CONFIG_LINKWIDTH_ACCEPT;
            timer <= 24'h000000;
          end
        end
        LtssState_CONFIG_LINKWIDTH_ACCEPT : begin
          if(io_ts2Rcvd) begin
            linkWidthReg <= (io_tsLaneNum + 5'h01);
            linkWidthEnum <= _zz_linkWidthEnum;
            state <= LtssState_CONFIG_LANENUM_WAIT;
            timer <= 24'h000000;
          end
        end
        LtssState_CONFIG_LANENUM_WAIT : begin
          if(io_ts2Rcvd) begin
            state <= LtssState_CONFIG_COMPLETE;
            timer <= 24'h000000;
          end
        end
        LtssState_CONFIG_COMPLETE : begin
          if(when_PhysicalLayer_l281) begin
            state <= LtssState_CONFIG_IDLE;
            timer <= 24'h000000;
          end
        end
        LtssState_CONFIG_IDLE : begin
          if(when_PhysicalLayer_l289) begin
            state <= LtssState_L0;
            timer <= 24'h000000;
          end
        end
        LtssState_L0 : begin
          inL1Reg <= 1'b0;
          inL2Reg <= 1'b0;
          if(io_linkResetReq) begin
            state <= LtssState_HOT_RESET;
          end else begin
            if(when_PhysicalLayer_l300) begin
              state <= LtssState_L0S;
              timer <= 24'h000000;
            end else begin
              if(when_PhysicalLayer_l304) begin
                state <= LtssState_RECOVERY_RCVRLOCK;
                timer <= 24'h000000;
              end else begin
                if(when_PhysicalLayer_l307) begin
                  state <= LtssState_L1_ENTRY;
                  timer <= 24'h000000;
                end else begin
                  if(when_PhysicalLayer_l311) begin
                    state <= LtssState_L2_IDLE;
                    timer <= 24'h000000;
                  end
                end
              end
            end
          end
        end
        LtssState_L0S : begin
          if(when_PhysicalLayer_l322) begin
            state <= LtssState_RECOVERY_RCVRCFG;
            timer <= 24'h000000;
          end
        end
        LtssState_RECOVERY_RCVRLOCK : begin
          if(io_ts1Rcvd) begin
            state <= LtssState_RECOVERY_RCVRCFG;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l333) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_RECOVERY_RCVRCFG : begin
          if(io_ts2Rcvd) begin
            state <= LtssState_RECOVERY_IDLE;
            timer <= 24'h000000;
          end
        end
        LtssState_RECOVERY_IDLE : begin
          if(io_rxValid) begin
            state <= LtssState_L0;
            timer <= 24'h000000;
          end
        end
        LtssState_L1_ENTRY : begin
          inL1Reg <= 1'b1;
          if(when_PhysicalLayer_l362) begin
            state <= LtssState_L1_IDLE;
            timer <= 24'h000000;
          end
        end
        LtssState_L1_IDLE : begin
          if(when_PhysicalLayer_l371) begin
            state <= LtssState_L1_EXIT;
            timer <= 24'h000000;
          end
        end
        LtssState_L1_EXIT : begin
          if(when_PhysicalLayer_l379) begin
            state <= LtssState_RECOVERY_RCVRCFG;
            inL1Reg <= 1'b0;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l383) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_L2_IDLE : begin
          inL2Reg <= 1'b1;
          if(io_wakeReq) begin
            state <= LtssState_L2_TRANSMIT_WAKE;
            timer <= 24'h000000;
          end
        end
        LtssState_L2_TRANSMIT_WAKE : begin
          if(when_PhysicalLayer_l405) begin
            state <= LtssState_L2_DETECT_WAKE;
            timer <= 24'h000000;
          end
        end
        LtssState_L2_DETECT_WAKE : begin
          if(when_PhysicalLayer_l412) begin
            state <= LtssState_POLLING_ACTIVE;
            inL2Reg <= 1'b0;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l416) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_HOT_RESET : begin
          timer <= 24'h000000;
          state <= LtssState_DETECT_QUIET;
        end
        LtssState_LOOPBACK_ENTRY : begin
          if(when_PhysicalLayer_l433) begin
            state <= LtssState_LOOPBACK_ACTIVE;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l436) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        LtssState_LOOPBACK_ACTIVE : begin
          if(io_linkResetReq) begin
            state <= LtssState_LOOPBACK_EXIT;
            timer <= 24'h000000;
          end
        end
        LtssState_LOOPBACK_EXIT : begin
          if(io_ts2Rcvd) begin
            state <= LtssState_DETECT_QUIET;
            timer <= 24'h000000;
          end else begin
            if(when_PhysicalLayer_l456) begin
              state <= LtssState_DETECT_QUIET;
              timer <= 24'h000000;
            end
          end
        end
        default : begin
          state <= LtssState_DETECT_QUIET;
        end
      endcase
    end
  end


endmodule

module Encoder8b10b (
  input  wire [7:0]    io_dataIn,
  input  wire          io_kCode,
  output wire [9:0]    io_dataOut,
  output wire          io_rdOut,
  input  wire          io_rdIn,
  input  wire          clk,
  input  wire          reset
);

  reg        [11:0]   _zz_encoded6b_1;
  wire       [2:0]    _zz_encoded6b_2;
  reg        [11:0]   _zz_encoded6b_3;
  wire       [2:0]    _zz_encoded6b_4;
  wire       [1:0]    _zz__zz_encoded6b;
  reg        [11:0]   _zz_encoded6b_5;
  reg        [11:0]   _zz_encoded6b_6;
  reg        [11:0]   _zz_encoded6b_7;
  wire       [4:0]    _zz_encoded6b_8;
  wire       [11:0]   _zz_encoded6b_9;
  wire       [11:0]   _zz_encoded6b_10;
  wire       [11:0]   _zz_encoded6b_11;
  wire       [11:0]   _zz_encoded6b_12;
  wire       [11:0]   _zz_encoded6b_13;
  wire       [11:0]   _zz_encoded6b_14;
  wire       [11:0]   _zz_encoded6b_15;
  wire       [11:0]   _zz_encoded6b_16;
  wire       [11:0]   _zz_encoded6b_17;
  wire       [11:0]   _zz_encoded6b_18;
  wire       [11:0]   _zz_encoded6b_19;
  wire       [11:0]   _zz_encoded6b_20;
  wire       [11:0]   _zz_encoded6b_21;
  wire       [11:0]   _zz_encoded6b_22;
  wire       [11:0]   _zz_encoded6b_23;
  wire       [11:0]   _zz_encoded6b_24;
  wire       [11:0]   _zz_encoded6b_25;
  wire       [11:0]   _zz_encoded6b_26;
  wire       [11:0]   _zz_encoded6b_27;
  wire       [11:0]   _zz_encoded6b_28;
  wire       [11:0]   _zz_encoded6b_29;
  wire       [11:0]   _zz_encoded6b_30;
  wire       [11:0]   _zz_encoded6b_31;
  wire       [11:0]   _zz_encoded6b_32;
  wire       [11:0]   _zz_encoded6b_33;
  wire       [11:0]   _zz_encoded6b_34;
  wire       [11:0]   _zz_encoded6b_35;
  wire       [11:0]   _zz_encoded6b_36;
  wire       [11:0]   _zz_encoded6b_37;
  wire       [11:0]   _zz_encoded6b_38;
  wire       [11:0]   _zz_encoded6b_39;
  wire       [11:0]   _zz_encoded6b_40;
  wire       [3:0]    _zz_disp6b;
  wire       [0:0]    _zz_disp6b_1;
  wire       [2:0]    _zz_data3bIdx;
  reg        [7:0]    _zz_encoded4b;
  reg        [7:0]    _zz_encoded4b_1;
  reg        [7:0]    _zz_encoded4b_2;
  reg        [7:0]    _zz_encoded4b_3;
  wire       [3:0]    _zz_disp4b;
  wire       [0:0]    _zz_disp4b_1;
  wire       [4:0]    data5b;
  wire       [2:0]    data3b;
  reg                 rd;
  wire                rdNext;
  reg        [5:0]    encoded6b;
  reg        [3:0]    encoded4b;
  wire       [9:0]    encoded10b;
  wire       [3:0]    disp6b;
  wire       [3:0]    disp4b;
  wire       [3:0]    totalDisp;
  wire                isD7;
  wire                isDxP07;
  wire                useAltEncoding;
  wire                when_Encoder8b10b_l133;
  wire       [2:0]    _zz_encoded6b;
  wire       [2:0]    data3bIdx;
  wire                when_Encoder8b10b_l157;
  wire                when_Encoder8b10b_l182;

  assign _zz__zz_encoded6b = data5b[1 : 0];
  assign _zz_disp6b_1 = (^encoded6b);
  assign _zz_disp6b = {{3{_zz_disp6b_1[0]}}, _zz_disp6b_1};
  assign _zz_data3bIdx = data3b;
  assign _zz_disp4b_1 = (^encoded4b);
  assign _zz_disp4b = {{3{_zz_disp4b_1[0]}}, _zz_disp4b_1};
  assign _zz_encoded6b_2 = 3'b011;
  assign _zz_encoded6b_4 = 3'b011;
  assign _zz_encoded6b_8 = data5b;
  assign _zz_encoded6b_9 = 12'h6e4;
  assign _zz_encoded6b_10 = 12'h8dc;
  assign _zz_encoded6b_11 = 12'h4ec;
  assign _zz_encoded6b_12 = 12'hc8d;
  assign _zz_encoded6b_13 = 12'h2f4;
  assign _zz_encoded6b_14 = 12'ha95;
  assign _zz_encoded6b_15 = 12'h6a5;
  assign _zz_encoded6b_16 = 12'h1f8;
  assign _zz_encoded6b_17 = 12'h1f8;
  assign _zz_encoded6b_18 = 12'h999;
  assign _zz_encoded6b_19 = 12'h5a9;
  assign _zz_encoded6b_20 = 12'hd0b;
  assign _zz_encoded6b_21 = 12'h3b1;
  assign _zz_encoded6b_22 = 12'hb13;
  assign _zz_encoded6b_23 = 12'h723;
  assign _zz_encoded6b_24 = 12'ha17;
  assign _zz_encoded6b_25 = 12'h95a;
  assign _zz_encoded6b_26 = 12'h8dc;
  assign _zz_encoded6b_27 = 12'h56a;
  assign _zz_encoded6b_28 = 12'hd0b;
  assign _zz_encoded6b_29 = 12'h372;
  assign _zz_encoded6b_30 = 12'hb13;
  assign _zz_encoded6b_31 = 12'h723;
  assign _zz_encoded6b_32 = 12'ha17;
  assign _zz_encoded6b_33 = 12'h95a;
  assign _zz_encoded6b_34 = 12'h4ec;
  assign _zz_encoded6b_35 = 12'hc8d;
  assign _zz_encoded6b_36 = 12'h2f4;
  assign _zz_encoded6b_37 = 12'ha95;
  assign _zz_encoded6b_38 = 12'h6a5;
  assign _zz_encoded6b_39 = 12'he85;
  assign _zz_encoded6b_40 = 12'hd4a;
  always @(*) begin
    case(_zz_encoded6b_2)
      3'b000 : _zz_encoded6b_1 = 12'h237;
      3'b001 : _zz_encoded6b_1 = 12'h91b;
      3'b010 : _zz_encoded6b_1 = 12'h52b;
      3'b011 : _zz_encoded6b_1 = 12'h333;
      3'b100 : _zz_encoded6b_1 = 12'h1b9;
      default : _zz_encoded6b_1 = 12'h4ad;
    endcase
  end

  always @(*) begin
    case(_zz_encoded6b_4)
      3'b000 : _zz_encoded6b_3 = 12'h237;
      3'b001 : _zz_encoded6b_3 = 12'h91b;
      3'b010 : _zz_encoded6b_3 = 12'h52b;
      3'b011 : _zz_encoded6b_3 = 12'h333;
      3'b100 : _zz_encoded6b_3 = 12'h1b9;
      default : _zz_encoded6b_3 = 12'h4ad;
    endcase
  end

  always @(*) begin
    case(_zz_encoded6b)
      3'b000 : begin
        _zz_encoded6b_5 = 12'h237;
        _zz_encoded6b_6 = 12'h237;
      end
      3'b001 : begin
        _zz_encoded6b_5 = 12'h91b;
        _zz_encoded6b_6 = 12'h91b;
      end
      3'b010 : begin
        _zz_encoded6b_5 = 12'h52b;
        _zz_encoded6b_6 = 12'h52b;
      end
      3'b011 : begin
        _zz_encoded6b_5 = 12'h333;
        _zz_encoded6b_6 = 12'h333;
      end
      3'b100 : begin
        _zz_encoded6b_5 = 12'h1b9;
        _zz_encoded6b_6 = 12'h1b9;
      end
      default : begin
        _zz_encoded6b_5 = 12'h4ad;
        _zz_encoded6b_6 = 12'h4ad;
      end
    endcase
  end

  always @(*) begin
    case(_zz_encoded6b_8)
      5'b00000 : _zz_encoded6b_7 = _zz_encoded6b_9;
      5'b00001 : _zz_encoded6b_7 = _zz_encoded6b_10;
      5'b00010 : _zz_encoded6b_7 = _zz_encoded6b_11;
      5'b00011 : _zz_encoded6b_7 = _zz_encoded6b_12;
      5'b00100 : _zz_encoded6b_7 = _zz_encoded6b_13;
      5'b00101 : _zz_encoded6b_7 = _zz_encoded6b_14;
      5'b00110 : _zz_encoded6b_7 = _zz_encoded6b_15;
      5'b00111 : _zz_encoded6b_7 = _zz_encoded6b_16;
      5'b01000 : _zz_encoded6b_7 = _zz_encoded6b_17;
      5'b01001 : _zz_encoded6b_7 = _zz_encoded6b_18;
      5'b01010 : _zz_encoded6b_7 = _zz_encoded6b_19;
      5'b01011 : _zz_encoded6b_7 = _zz_encoded6b_20;
      5'b01100 : _zz_encoded6b_7 = _zz_encoded6b_21;
      5'b01101 : _zz_encoded6b_7 = _zz_encoded6b_22;
      5'b01110 : _zz_encoded6b_7 = _zz_encoded6b_23;
      5'b01111 : _zz_encoded6b_7 = _zz_encoded6b_24;
      5'b10000 : _zz_encoded6b_7 = _zz_encoded6b_25;
      5'b10001 : _zz_encoded6b_7 = _zz_encoded6b_26;
      5'b10010 : _zz_encoded6b_7 = _zz_encoded6b_27;
      5'b10011 : _zz_encoded6b_7 = _zz_encoded6b_28;
      5'b10100 : _zz_encoded6b_7 = _zz_encoded6b_29;
      5'b10101 : _zz_encoded6b_7 = _zz_encoded6b_30;
      5'b10110 : _zz_encoded6b_7 = _zz_encoded6b_31;
      5'b10111 : _zz_encoded6b_7 = _zz_encoded6b_32;
      5'b11000 : _zz_encoded6b_7 = _zz_encoded6b_33;
      5'b11001 : _zz_encoded6b_7 = _zz_encoded6b_34;
      5'b11010 : _zz_encoded6b_7 = _zz_encoded6b_35;
      5'b11011 : _zz_encoded6b_7 = _zz_encoded6b_36;
      5'b11100 : _zz_encoded6b_7 = _zz_encoded6b_37;
      5'b11101 : _zz_encoded6b_7 = _zz_encoded6b_38;
      5'b11110 : _zz_encoded6b_7 = _zz_encoded6b_39;
      default : _zz_encoded6b_7 = _zz_encoded6b_40;
    endcase
  end

  always @(*) begin
    case(data3bIdx)
      3'b000 : begin
        _zz_encoded4b = 8'h4b;
        _zz_encoded4b_1 = 8'h4b;
        _zz_encoded4b_2 = 8'h4b;
        _zz_encoded4b_3 = 8'h4b;
      end
      3'b001 : begin
        _zz_encoded4b = 8'h96;
        _zz_encoded4b_1 = 8'h96;
        _zz_encoded4b_2 = 8'h96;
        _zz_encoded4b_3 = 8'h96;
      end
      3'b010 : begin
        _zz_encoded4b = 8'h5a;
        _zz_encoded4b_1 = 8'h5a;
        _zz_encoded4b_2 = 8'h5a;
        _zz_encoded4b_3 = 8'h5a;
      end
      3'b011 : begin
        _zz_encoded4b = 8'h3c;
        _zz_encoded4b_1 = 8'h3c;
        _zz_encoded4b_2 = 8'h3c;
        _zz_encoded4b_3 = 8'h3c;
      end
      3'b100 : begin
        _zz_encoded4b = 8'h3c;
        _zz_encoded4b_1 = 8'h3c;
        _zz_encoded4b_2 = 8'h3c;
        _zz_encoded4b_3 = 8'h3c;
      end
      3'b101 : begin
        _zz_encoded4b = 8'ha5;
        _zz_encoded4b_1 = 8'ha5;
        _zz_encoded4b_2 = 8'ha5;
        _zz_encoded4b_3 = 8'ha5;
      end
      3'b110 : begin
        _zz_encoded4b = 8'h69;
        _zz_encoded4b_1 = 8'h69;
        _zz_encoded4b_2 = 8'h69;
        _zz_encoded4b_3 = 8'h69;
      end
      default : begin
        _zz_encoded4b = 8'h17;
        _zz_encoded4b_1 = 8'h17;
        _zz_encoded4b_2 = 8'h17;
        _zz_encoded4b_3 = 8'h17;
      end
    endcase
  end

  assign data5b = io_dataIn[4 : 0];
  assign data3b = io_dataIn[7 : 5];
  assign isD7 = ((data5b == 5'h07) || (data5b == 5'h08));
  assign isDxP07 = ((((data5b == 5'h11) || (data5b == 5'h12)) || (data5b == 5'h14)) && (data3b == 3'b111));
  assign when_Encoder8b10b_l133 = (data5b == 5'h1c);
  always @(*) begin
    if(io_kCode) begin
      if(when_Encoder8b10b_l133) begin
        encoded6b = (rd ? _zz_encoded6b_1[5 : 0] : _zz_encoded6b_3[11 : 6]);
      end else begin
        encoded6b = (rd ? _zz_encoded6b_5[5 : 0] : _zz_encoded6b_6[11 : 6]);
      end
    end else begin
      encoded6b = _zz_encoded6b_7[5 : 0];
    end
  end

  assign _zz_encoded6b = {1'd0, _zz__zz_encoded6b};
  assign disp6b = ($signed(_zz_disp6b) - $signed(4'b0011));
  assign data3bIdx = _zz_data3bIdx;
  assign when_Encoder8b10b_l157 = (io_kCode && (data5b == 5'h1c));
  always @(*) begin
    if(when_Encoder8b10b_l157) begin
      encoded4b = (rd ? _zz_encoded4b[3 : 0] : _zz_encoded4b_1[7 : 4]);
    end else begin
      encoded4b = (rd ? _zz_encoded4b_2[3 : 0] : _zz_encoded4b_3[7 : 4]);
    end
  end

  assign disp4b = ($signed(_zz_disp4b) - $signed(4'b0010));
  assign encoded10b = {encoded6b,encoded4b};
  assign io_dataOut = encoded10b;
  assign totalDisp = ($signed(disp6b) + $signed(disp4b));
  assign rdNext = (($signed(4'b0000) < $signed(totalDisp)) ? 1'b0 : (($signed(totalDisp) < $signed(4'b0000)) ? 1'b1 : rd));
  assign io_rdOut = rdNext;
  assign when_Encoder8b10b_l182 = ((io_dataIn != 8'h00) || io_kCode);
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      rd <= 1'b0;
    end else begin
      if(when_Encoder8b10b_l182) begin
        rd <= rdNext;
      end
    end
  end


endmodule

module Decoder8b10b (
  input  wire [9:0]    io_dataIn,
  output wire [7:0]    io_dataOut,
  output wire          io_kCode,
  output wire          io_codeErr,
  output wire          io_rdErr,
  input  wire          clk,
  input  wire          reset
);

  wire       [3:0]    _zz_disp6b;
  wire       [3:0]    _zz_disp6b_1;
  wire       [0:0]    _zz_disp6b_2;
  wire       [3:0]    _zz_disp4b;
  wire       [3:0]    _zz_disp4b_1;
  wire       [0:0]    _zz_disp4b_2;
  wire       [3:0]    _zz_actualRd;
  wire       [5:0]    code6b;
  wire       [3:0]    code4b;
  reg                 rd;
  reg        [4:0]    decoded5b;
  reg        [2:0]    decoded3b;
  reg                 isKCode;
  reg                 invalid6b;
  reg                 invalid4b;
  wire                disparityError;
  wire                isK28_5;
  wire                isK28_0;
  wire                isK28_1;
  wire                isK28_2;
  wire                when_Encoder8b10b_l246;
  wire       [3:0]    disp6b;
  wire       [3:0]    disp4b;
  wire                actualRd;

  assign _zz_disp6b = (_zz_disp6b_1 - 4'b0011);
  assign _zz_disp6b_2 = (^code6b);
  assign _zz_disp6b_1 = {3'd0, _zz_disp6b_2};
  assign _zz_disp4b = (_zz_disp4b_1 - 4'b0010);
  assign _zz_disp4b_2 = (^code4b);
  assign _zz_disp4b_1 = {3'd0, _zz_disp4b_2};
  assign _zz_actualRd = ($signed(disp6b) + $signed(disp4b));
  assign code6b = io_dataIn[9 : 4];
  assign code4b = io_dataIn[3 : 0];
  assign isK28_5 = (((code6b == 6'h28) || (code6b == 6'h17)) && ((code4b == 4'b0101) || (code4b == 4'b1010)));
  assign isK28_0 = (((code6b == 6'h37) || (code6b == 6'h08)) && ((code4b == 4'b0100) || (code4b == 4'b1011)));
  assign isK28_1 = (((code6b == 6'h37) || (code6b == 6'h08)) && ((code4b == 4'b1001) || (code4b == 4'b0110)));
  assign isK28_2 = (((code6b == 6'h37) || (code6b == 6'h08)) && ((code4b == 4'b0101) || (code4b == 4'b1010)));
  always @(*) begin
    decoded5b = 5'h00;
    if(when_Encoder8b10b_l246) begin
      decoded5b = 5'h1c;
    end else begin
      case(code6b)
        6'h1b : begin
          decoded5b = 5'h00;
        end
        6'h23 : begin
          decoded5b = 5'h01;
        end
        6'h13 : begin
          decoded5b = 5'h02;
        end
        6'h32 : begin
          decoded5b = 5'h03;
        end
        6'h0b : begin
          decoded5b = 5'h04;
        end
        6'h2a : begin
          decoded5b = 5'h05;
        end
        6'h1a : begin
          decoded5b = 5'h06;
        end
        6'h07 : begin
          decoded5b = 5'h07;
        end
        6'h26 : begin
          decoded5b = 5'h09;
        end
        6'h16 : begin
          decoded5b = 5'h0a;
        end
        6'h34 : begin
          decoded5b = 5'h0b;
        end
        6'h0e : begin
          decoded5b = 5'h0c;
        end
        6'h2c : begin
          decoded5b = 5'h0d;
        end
        6'h1c : begin
          decoded5b = 5'h0e;
        end
        6'h28 : begin
          decoded5b = 5'h0f;
        end
        default : begin
          decoded5b = code6b[4 : 0];
        end
      endcase
    end
  end

  always @(*) begin
    decoded3b = 3'b000;
    if(when_Encoder8b10b_l246) begin
      if(isK28_5) begin
        decoded3b = 3'b101;
      end else begin
        if(isK28_0) begin
          decoded3b = 3'b000;
        end else begin
          if(isK28_1) begin
            decoded3b = 3'b001;
          end else begin
            decoded3b = 3'b010;
          end
        end
      end
    end else begin
      case(code4b)
        4'b0100 : begin
          decoded3b = 3'b000;
        end
        4'b1001 : begin
          decoded3b = 3'b001;
        end
        4'b0101 : begin
          decoded3b = 3'b010;
        end
        4'b0011 : begin
          decoded3b = 3'b011;
        end
        4'b1010 : begin
          decoded3b = 3'b101;
        end
        4'b0110 : begin
          decoded3b = 3'b110;
        end
        4'b0001 : begin
          decoded3b = 3'b111;
        end
        default : begin
          decoded3b = code4b[2 : 0];
        end
      endcase
    end
  end

  always @(*) begin
    isKCode = 1'b0;
    if(when_Encoder8b10b_l246) begin
      isKCode = 1'b1;
    end else begin
      isKCode = 1'b0;
    end
  end

  always @(*) begin
    invalid6b = 1'b0;
    if(!when_Encoder8b10b_l246) begin
      case(code6b)
        6'h1b : begin
        end
        6'h23 : begin
        end
        6'h13 : begin
        end
        6'h32 : begin
        end
        6'h0b : begin
        end
        6'h2a : begin
        end
        6'h1a : begin
        end
        6'h07 : begin
        end
        6'h26 : begin
        end
        6'h16 : begin
        end
        6'h34 : begin
        end
        6'h0e : begin
        end
        6'h2c : begin
        end
        6'h1c : begin
        end
        6'h28 : begin
        end
        default : begin
          invalid6b = 1'b1;
        end
      endcase
    end
  end

  always @(*) begin
    invalid4b = 1'b0;
    if(!when_Encoder8b10b_l246) begin
      case(code4b)
        4'b0100 : begin
        end
        4'b1001 : begin
        end
        4'b0101 : begin
        end
        4'b0011 : begin
        end
        4'b1010 : begin
        end
        4'b0110 : begin
        end
        4'b0001 : begin
        end
        default : begin
          invalid4b = 1'b1;
        end
      endcase
    end
  end

  assign when_Encoder8b10b_l246 = (((isK28_5 || isK28_0) || isK28_1) || isK28_2);
  assign disp6b = _zz_disp6b;
  assign disp4b = _zz_disp4b;
  assign actualRd = ($signed(4'b0000) < $signed(_zz_actualRd));
  assign disparityError = ((rd != actualRd) && (! isKCode));
  assign io_dataOut = {decoded3b,decoded5b};
  assign io_kCode = isKCode;
  assign io_codeErr = (invalid6b || invalid4b);
  assign io_rdErr = disparityError;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      rd <= 1'b0;
    end else begin
      rd <= (! rd);
    end
  end


endmodule

module SymbolAligner (
  input  wire [9:0]    io_dataIn,
  output wire [9:0]    io_dataOut,
  output wire          io_aligned,
  input  wire [3:0]    io_shift,
  input  wire          clk,
  input  wire          reset
);

  wire       [29:0]   _zz_buffer_1;
  wire       [19:0]   _zz_shiftedData;
  wire       [9:0]    COMMA_POS;
  wire       [9:0]    COMMA_NEG;
  reg        [3:0]    alignState;
  wire                commaDetected;
  reg                 alignedReg;
  reg        [19:0]   buffer_1;
  reg                 commaFound;
  reg        [3:0]    commaPos;
  wire       [9:0]    _zz_when_Encoder8b10b_l361;
  wire                when_Encoder8b10b_l361;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_1;
  wire                when_Encoder8b10b_l361_1;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_2;
  wire                when_Encoder8b10b_l361_2;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_3;
  wire                when_Encoder8b10b_l361_3;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_4;
  wire                when_Encoder8b10b_l361_4;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_5;
  wire                when_Encoder8b10b_l361_5;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_6;
  wire                when_Encoder8b10b_l361_6;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_7;
  wire                when_Encoder8b10b_l361_7;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_8;
  wire                when_Encoder8b10b_l361_8;
  wire       [9:0]    _zz_when_Encoder8b10b_l361_9;
  wire                when_Encoder8b10b_l361_9;
  wire                when_Encoder8b10b_l368;
  wire                when_Encoder8b10b_l376;
  wire       [9:0]    shiftedData;

  assign _zz_buffer_1 = {buffer_1,io_dataIn};
  assign _zz_shiftedData = (buffer_1 >>> alignState);
  assign COMMA_POS = 10'h105;
  assign COMMA_NEG = 10'h2fa;
  assign commaDetected = 1'b0;
  always @(*) begin
    commaFound = 1'b0;
    if(when_Encoder8b10b_l361) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_1) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_2) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_3) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_4) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_5) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_6) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_7) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_8) begin
      commaFound = 1'b1;
    end
    if(when_Encoder8b10b_l361_9) begin
      commaFound = 1'b1;
    end
  end

  always @(*) begin
    commaPos = 4'b0000;
    if(when_Encoder8b10b_l361) begin
      commaPos = 4'b0000;
    end
    if(when_Encoder8b10b_l361_1) begin
      commaPos = 4'b0001;
    end
    if(when_Encoder8b10b_l361_2) begin
      commaPos = 4'b0010;
    end
    if(when_Encoder8b10b_l361_3) begin
      commaPos = 4'b0011;
    end
    if(when_Encoder8b10b_l361_4) begin
      commaPos = 4'b0100;
    end
    if(when_Encoder8b10b_l361_5) begin
      commaPos = 4'b0101;
    end
    if(when_Encoder8b10b_l361_6) begin
      commaPos = 4'b0110;
    end
    if(when_Encoder8b10b_l361_7) begin
      commaPos = 4'b0111;
    end
    if(when_Encoder8b10b_l361_8) begin
      commaPos = 4'b1000;
    end
    if(when_Encoder8b10b_l361_9) begin
      commaPos = 4'b1001;
    end
  end

  assign _zz_when_Encoder8b10b_l361 = buffer_1[9 : 0];
  assign when_Encoder8b10b_l361 = ((_zz_when_Encoder8b10b_l361 == COMMA_POS) || (_zz_when_Encoder8b10b_l361 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_1 = buffer_1[10 : 1];
  assign when_Encoder8b10b_l361_1 = ((_zz_when_Encoder8b10b_l361_1 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_1 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_2 = buffer_1[11 : 2];
  assign when_Encoder8b10b_l361_2 = ((_zz_when_Encoder8b10b_l361_2 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_2 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_3 = buffer_1[12 : 3];
  assign when_Encoder8b10b_l361_3 = ((_zz_when_Encoder8b10b_l361_3 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_3 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_4 = buffer_1[13 : 4];
  assign when_Encoder8b10b_l361_4 = ((_zz_when_Encoder8b10b_l361_4 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_4 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_5 = buffer_1[14 : 5];
  assign when_Encoder8b10b_l361_5 = ((_zz_when_Encoder8b10b_l361_5 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_5 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_6 = buffer_1[15 : 6];
  assign when_Encoder8b10b_l361_6 = ((_zz_when_Encoder8b10b_l361_6 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_6 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_7 = buffer_1[16 : 7];
  assign when_Encoder8b10b_l361_7 = ((_zz_when_Encoder8b10b_l361_7 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_7 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_8 = buffer_1[17 : 8];
  assign when_Encoder8b10b_l361_8 = ((_zz_when_Encoder8b10b_l361_8 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_8 == COMMA_NEG));
  assign _zz_when_Encoder8b10b_l361_9 = buffer_1[18 : 9];
  assign when_Encoder8b10b_l361_9 = ((_zz_when_Encoder8b10b_l361_9 == COMMA_POS) || (_zz_when_Encoder8b10b_l361_9 == COMMA_NEG));
  assign when_Encoder8b10b_l368 = (! alignedReg);
  assign when_Encoder8b10b_l376 = (commaFound && (commaPos != alignState));
  assign shiftedData = _zz_shiftedData[9:0];
  assign io_dataOut = shiftedData;
  assign io_aligned = alignedReg;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      alignState <= 4'b0000;
      alignedReg <= 1'b0;
      buffer_1 <= 20'h00000;
    end else begin
      buffer_1 <= _zz_buffer_1[19 : 0];
      if(when_Encoder8b10b_l368) begin
        if(commaFound) begin
          alignState <= commaPos;
          alignedReg <= 1'b1;
        end
      end else begin
        if(when_Encoder8b10b_l376) begin
          alignedReg <= 1'b0;
        end
      end
    end
  end


endmodule
