// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

`include "prim_assert.sv"

module mbx_core_reg_top (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  // To HW
  output mbx_reg_pkg::mbx_core_reg2hw_t reg2hw, // Write
  input  mbx_reg_pkg::mbx_core_hw2reg_t hw2reg, // Read

  // Integrity check errors
  output logic intg_err_o
);

  import mbx_reg_pkg::* ;

  localparam int AW = 7;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    // Byte Width

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;

  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;


  // incoming payload check
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );

  // also check for spurious write enables
  logic reg_we_err;
  logic [16:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(17)
  ) u_prim_reg_we_check (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .oh_i  (reg_we_check),
    .en_i  (reg_we && !addrmiss),
    .err_o (reg_we_err)
  );

  logic err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= '0;
    end else if (intg_err || reg_we_err) begin
      err_q <= 1'b1;
    end
  end

  // integrity error output is permanent and should be used for alert generation
  // register errors are transactional
  assign intg_err_o = err_q | intg_err | reg_we_err;

  // outgoing integrity generation
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );

  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;

  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),

    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );

  // cdc oversampling signals

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = addrmiss | wr_err | intg_err;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic intr_state_we;
  logic intr_state_mbx_ready_qs;
  logic intr_state_mbx_ready_wd;
  logic intr_state_mbx_abort_qs;
  logic intr_state_mbx_abort_wd;
  logic intr_enable_we;
  logic intr_enable_mbx_ready_qs;
  logic intr_enable_mbx_ready_wd;
  logic intr_enable_mbx_abort_qs;
  logic intr_enable_mbx_abort_wd;
  logic intr_test_we;
  logic intr_test_mbx_ready_wd;
  logic intr_test_mbx_abort_wd;
  logic alert_test_we;
  logic alert_test_fatal_fault_wd;
  logic alert_test_recov_fault_wd;
  logic control_re;
  logic control_we;
  logic control_abort_qs;
  logic control_abort_wd;
  logic control_doe_intr_en_qs;
  logic control_doe_intr_en_wd;
  logic control_error_qs;
  logic control_error_wd;
  logic status_re;
  logic status_we;
  logic status_busy_qs;
  logic status_busy_wd;
  logic status_doe_intr_status_qs;
  logic status_doe_intr_status_wd;
  logic address_range_regwen_we;
  logic [3:0] address_range_regwen_qs;
  logic [3:0] address_range_regwen_wd;
  logic address_range_valid_we;
  logic address_range_valid_qs;
  logic address_range_valid_wd;
  logic inbound_base_address_we;
  logic [29:0] inbound_base_address_qs;
  logic [29:0] inbound_base_address_wd;
  logic inbound_limit_address_we;
  logic [29:0] inbound_limit_address_qs;
  logic [29:0] inbound_limit_address_wd;
  logic inbound_write_ptr_re;
  logic [29:0] inbound_write_ptr_qs;
  logic outbound_base_address_we;
  logic [29:0] outbound_base_address_qs;
  logic [29:0] outbound_base_address_wd;
  logic outbound_limit_address_we;
  logic [29:0] outbound_limit_address_qs;
  logic [29:0] outbound_limit_address_wd;
  logic outbound_read_ptr_re;
  logic [29:0] outbound_read_ptr_qs;
  logic outbound_object_size_we;
  logic [10:0] outbound_object_size_qs;
  logic [10:0] outbound_object_size_wd;
  logic doe_intr_msg_addr_re;
  logic [31:0] doe_intr_msg_addr_qs;
  logic doe_intr_msg_data_re;
  logic [31:0] doe_intr_msg_data_qs;

  // Register instances
  // R[intr_state]: V(False)
  //   F[mbx_ready]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_mbx_ready (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_mbx_ready_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.mbx_ready.de),
    .d      (hw2reg.intr_state.mbx_ready.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.mbx_ready.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_state_mbx_ready_qs)
  );

  //   F[mbx_abort]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_mbx_abort (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_state_we),
    .wd     (intr_state_mbx_abort_wd),

    // from internal hardware
    .de     (hw2reg.intr_state.mbx_abort.de),
    .d      (hw2reg.intr_state.mbx_abort.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_state.mbx_abort.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_state_mbx_abort_qs)
  );


  // R[intr_enable]: V(False)
  //   F[mbx_ready]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_mbx_ready (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_enable_we),
    .wd     (intr_enable_mbx_ready_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_enable.mbx_ready.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_enable_mbx_ready_qs)
  );

  //   F[mbx_abort]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_mbx_abort (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (intr_enable_we),
    .wd     (intr_enable_mbx_abort_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.intr_enable.mbx_abort.q),
    .ds     (),

    // to register interface (read)
    .qs     (intr_enable_mbx_abort_qs)
  );


  // R[intr_test]: V(True)
  logic intr_test_qe;
  logic [1:0] intr_test_flds_we;
  assign intr_test_qe = &intr_test_flds_we;
  //   F[mbx_ready]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_mbx_ready (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_mbx_ready_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[0]),
    .q      (reg2hw.intr_test.mbx_ready.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.mbx_ready.qe = intr_test_qe;

  //   F[mbx_abort]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_mbx_abort (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_mbx_abort_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[1]),
    .q      (reg2hw.intr_test.mbx_abort.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.mbx_abort.qe = intr_test_qe;


  // R[alert_test]: V(True)
  logic alert_test_qe;
  logic [1:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  //   F[fatal_fault]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_fatal_fault (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_fatal_fault_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.fatal_fault.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.fatal_fault.qe = alert_test_qe;

  //   F[recov_fault]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_recov_fault (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_recov_fault_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[1]),
    .q      (reg2hw.alert_test.recov_fault.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.recov_fault.qe = alert_test_qe;


  // R[control]: V(True)
  logic control_qe;
  logic [2:0] control_flds_we;
  assign control_qe = &control_flds_we;
  //   F[abort]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_control_abort (
    .re     (control_re),
    .we     (control_we),
    .wd     (control_abort_wd),
    .d      (hw2reg.control.abort.d),
    .qre    (),
    .qe     (control_flds_we[0]),
    .q      (reg2hw.control.abort.q),
    .ds     (),
    .qs     (control_abort_qs)
  );
  assign reg2hw.control.abort.qe = control_qe;

  //   F[doe_intr_en]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_control_doe_intr_en (
    .re     (control_re),
    .we     (control_we),
    .wd     (control_doe_intr_en_wd),
    .d      (hw2reg.control.doe_intr_en.d),
    .qre    (),
    .qe     (control_flds_we[1]),
    .q      (reg2hw.control.doe_intr_en.q),
    .ds     (),
    .qs     (control_doe_intr_en_qs)
  );
  assign reg2hw.control.doe_intr_en.qe = control_qe;

  //   F[error]: 2:2
  prim_subreg_ext #(
    .DW    (1)
  ) u_control_error (
    .re     (control_re),
    .we     (control_we),
    .wd     (control_error_wd),
    .d      (hw2reg.control.error.d),
    .qre    (),
    .qe     (control_flds_we[2]),
    .q      (reg2hw.control.error.q),
    .ds     (),
    .qs     (control_error_qs)
  );
  assign reg2hw.control.error.qe = control_qe;


  // R[status]: V(True)
  logic status_qe;
  logic [1:0] status_flds_we;
  assign status_qe = &status_flds_we;
  //   F[busy]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_status_busy (
    .re     (status_re),
    .we     (status_we),
    .wd     (status_busy_wd),
    .d      (hw2reg.status.busy.d),
    .qre    (),
    .qe     (status_flds_we[0]),
    .q      (reg2hw.status.busy.q),
    .ds     (),
    .qs     (status_busy_qs)
  );
  assign reg2hw.status.busy.qe = status_qe;

  //   F[doe_intr_status]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_status_doe_intr_status (
    .re     (status_re),
    .we     (status_we),
    .wd     (status_doe_intr_status_wd),
    .d      (hw2reg.status.doe_intr_status.d),
    .qre    (),
    .qe     (status_flds_we[1]),
    .q      (reg2hw.status.doe_intr_status.q),
    .ds     (),
    .qs     (status_doe_intr_status_qs)
  );
  assign reg2hw.status.doe_intr_status.qe = status_qe;


  // R[address_range_regwen]: V(False)
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (4'h6),
    .Mubi    (1'b1)
  ) u_address_range_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (address_range_regwen_we),
    .wd     (address_range_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.address_range_regwen.q),
    .ds     (),

    // to register interface (read)
    .qs     (address_range_regwen_qs)
  );


  // R[address_range_valid]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_address_range_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (address_range_valid_we),
    .wd     (address_range_valid_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.address_range_valid.q),
    .ds     (),

    // to register interface (read)
    .qs     (address_range_valid_qs)
  );


  // R[inbound_base_address]: V(False)
  logic inbound_base_address_qe;
  logic [0:0] inbound_base_address_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_inbound_base_address0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&inbound_base_address_flds_we),
    .q_o(inbound_base_address_qe)
  );
  // Create REGWEN-gated WE signal
  logic inbound_base_address_gated_we;
  assign inbound_base_address_gated_we =
    inbound_base_address_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(address_range_regwen_qs));
  prim_subreg #(
    .DW      (30),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (30'h0),
    .Mubi    (1'b0)
  ) u_inbound_base_address (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (inbound_base_address_gated_we),
    .wd     (inbound_base_address_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (inbound_base_address_flds_we[0]),
    .q      (reg2hw.inbound_base_address.q),
    .ds     (),

    // to register interface (read)
    .qs     (inbound_base_address_qs)
  );
  assign reg2hw.inbound_base_address.qe = inbound_base_address_qe;


  // R[inbound_limit_address]: V(False)
  logic inbound_limit_address_qe;
  logic [0:0] inbound_limit_address_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_inbound_limit_address0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&inbound_limit_address_flds_we),
    .q_o(inbound_limit_address_qe)
  );
  // Create REGWEN-gated WE signal
  logic inbound_limit_address_gated_we;
  assign inbound_limit_address_gated_we =
    inbound_limit_address_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(address_range_regwen_qs));
  prim_subreg #(
    .DW      (30),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (30'h0),
    .Mubi    (1'b0)
  ) u_inbound_limit_address (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (inbound_limit_address_gated_we),
    .wd     (inbound_limit_address_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (inbound_limit_address_flds_we[0]),
    .q      (reg2hw.inbound_limit_address.q),
    .ds     (),

    // to register interface (read)
    .qs     (inbound_limit_address_qs)
  );
  assign reg2hw.inbound_limit_address.qe = inbound_limit_address_qe;


  // R[inbound_write_ptr]: V(True)
  logic inbound_write_ptr_qe;
  logic [0:0] inbound_write_ptr_flds_we;
  // In case all fields are read-only the aggregated register QE will be zero as well.
  assign inbound_write_ptr_qe = &inbound_write_ptr_flds_we;
  prim_subreg_ext #(
    .DW    (30)
  ) u_inbound_write_ptr (
    .re     (inbound_write_ptr_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.inbound_write_ptr.d),
    .qre    (),
    .qe     (inbound_write_ptr_flds_we[0]),
    .q      (reg2hw.inbound_write_ptr.q),
    .ds     (),
    .qs     (inbound_write_ptr_qs)
  );
  assign reg2hw.inbound_write_ptr.qe = inbound_write_ptr_qe;


  // R[outbound_base_address]: V(False)
  logic outbound_base_address_qe;
  logic [0:0] outbound_base_address_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_outbound_base_address0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&outbound_base_address_flds_we),
    .q_o(outbound_base_address_qe)
  );
  // Create REGWEN-gated WE signal
  logic outbound_base_address_gated_we;
  assign outbound_base_address_gated_we =
    outbound_base_address_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(address_range_regwen_qs));
  prim_subreg #(
    .DW      (30),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (30'h0),
    .Mubi    (1'b0)
  ) u_outbound_base_address (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (outbound_base_address_gated_we),
    .wd     (outbound_base_address_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (outbound_base_address_flds_we[0]),
    .q      (reg2hw.outbound_base_address.q),
    .ds     (),

    // to register interface (read)
    .qs     (outbound_base_address_qs)
  );
  assign reg2hw.outbound_base_address.qe = outbound_base_address_qe;


  // R[outbound_limit_address]: V(False)
  logic outbound_limit_address_qe;
  logic [0:0] outbound_limit_address_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_outbound_limit_address0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&outbound_limit_address_flds_we),
    .q_o(outbound_limit_address_qe)
  );
  // Create REGWEN-gated WE signal
  logic outbound_limit_address_gated_we;
  assign outbound_limit_address_gated_we =
    outbound_limit_address_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(address_range_regwen_qs));
  prim_subreg #(
    .DW      (30),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (30'h0),
    .Mubi    (1'b0)
  ) u_outbound_limit_address (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (outbound_limit_address_gated_we),
    .wd     (outbound_limit_address_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (outbound_limit_address_flds_we[0]),
    .q      (reg2hw.outbound_limit_address.q),
    .ds     (),

    // to register interface (read)
    .qs     (outbound_limit_address_qs)
  );
  assign reg2hw.outbound_limit_address.qe = outbound_limit_address_qe;


  // R[outbound_read_ptr]: V(True)
  logic outbound_read_ptr_qe;
  logic [0:0] outbound_read_ptr_flds_we;
  // In case all fields are read-only the aggregated register QE will be zero as well.
  assign outbound_read_ptr_qe = &outbound_read_ptr_flds_we;
  prim_subreg_ext #(
    .DW    (30)
  ) u_outbound_read_ptr (
    .re     (outbound_read_ptr_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.outbound_read_ptr.d),
    .qre    (),
    .qe     (outbound_read_ptr_flds_we[0]),
    .q      (reg2hw.outbound_read_ptr.q),
    .ds     (),
    .qs     (outbound_read_ptr_qs)
  );
  assign reg2hw.outbound_read_ptr.qe = outbound_read_ptr_qe;


  // R[outbound_object_size]: V(False)
  logic outbound_object_size_qe;
  logic [0:0] outbound_object_size_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_outbound_object_size0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&outbound_object_size_flds_we),
    .q_o(outbound_object_size_qe)
  );
  prim_subreg #(
    .DW      (11),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (11'h0),
    .Mubi    (1'b0)
  ) u_outbound_object_size (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (outbound_object_size_we),
    .wd     (outbound_object_size_wd),

    // from internal hardware
    .de     (hw2reg.outbound_object_size.de),
    .d      (hw2reg.outbound_object_size.d),

    // to internal hardware
    .qe     (outbound_object_size_flds_we[0]),
    .q      (reg2hw.outbound_object_size.q),
    .ds     (),

    // to register interface (read)
    .qs     (outbound_object_size_qs)
  );
  assign reg2hw.outbound_object_size.qe = outbound_object_size_qe;


  // R[doe_intr_msg_addr]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_doe_intr_msg_addr (
    .re     (doe_intr_msg_addr_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.doe_intr_msg_addr.d),
    .qre    (),
    .qe     (),
    .q      (reg2hw.doe_intr_msg_addr.q),
    .ds     (),
    .qs     (doe_intr_msg_addr_qs)
  );


  // R[doe_intr_msg_data]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_doe_intr_msg_data (
    .re     (doe_intr_msg_data_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.doe_intr_msg_data.d),
    .qre    (),
    .qe     (),
    .q      (reg2hw.doe_intr_msg_data.q),
    .ds     (),
    .qs     (doe_intr_msg_data_qs)
  );



  logic [16:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == MBX_INTR_STATE_OFFSET);
    addr_hit[ 1] = (reg_addr == MBX_INTR_ENABLE_OFFSET);
    addr_hit[ 2] = (reg_addr == MBX_INTR_TEST_OFFSET);
    addr_hit[ 3] = (reg_addr == MBX_ALERT_TEST_OFFSET);
    addr_hit[ 4] = (reg_addr == MBX_CONTROL_OFFSET);
    addr_hit[ 5] = (reg_addr == MBX_STATUS_OFFSET);
    addr_hit[ 6] = (reg_addr == MBX_ADDRESS_RANGE_REGWEN_OFFSET);
    addr_hit[ 7] = (reg_addr == MBX_ADDRESS_RANGE_VALID_OFFSET);
    addr_hit[ 8] = (reg_addr == MBX_INBOUND_BASE_ADDRESS_OFFSET);
    addr_hit[ 9] = (reg_addr == MBX_INBOUND_LIMIT_ADDRESS_OFFSET);
    addr_hit[10] = (reg_addr == MBX_INBOUND_WRITE_PTR_OFFSET);
    addr_hit[11] = (reg_addr == MBX_OUTBOUND_BASE_ADDRESS_OFFSET);
    addr_hit[12] = (reg_addr == MBX_OUTBOUND_LIMIT_ADDRESS_OFFSET);
    addr_hit[13] = (reg_addr == MBX_OUTBOUND_READ_PTR_OFFSET);
    addr_hit[14] = (reg_addr == MBX_OUTBOUND_OBJECT_SIZE_OFFSET);
    addr_hit[15] = (reg_addr == MBX_DOE_INTR_MSG_ADDR_OFFSET);
    addr_hit[16] = (reg_addr == MBX_DOE_INTR_MSG_DATA_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(MBX_CORE_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(MBX_CORE_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(MBX_CORE_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(MBX_CORE_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(MBX_CORE_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(MBX_CORE_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(MBX_CORE_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(MBX_CORE_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(MBX_CORE_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(MBX_CORE_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(MBX_CORE_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(MBX_CORE_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(MBX_CORE_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(MBX_CORE_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(MBX_CORE_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(MBX_CORE_PERMIT[15] & ~reg_be))) |
               (addr_hit[16] & (|(MBX_CORE_PERMIT[16] & ~reg_be)))));
  end

  // Generate write-enables
  assign intr_state_we = addr_hit[0] & reg_we & !reg_error;

  assign intr_state_mbx_ready_wd = reg_wdata[0];

  assign intr_state_mbx_abort_wd = reg_wdata[1];
  assign intr_enable_we = addr_hit[1] & reg_we & !reg_error;

  assign intr_enable_mbx_ready_wd = reg_wdata[0];

  assign intr_enable_mbx_abort_wd = reg_wdata[1];
  assign intr_test_we = addr_hit[2] & reg_we & !reg_error;

  assign intr_test_mbx_ready_wd = reg_wdata[0];

  assign intr_test_mbx_abort_wd = reg_wdata[1];
  assign alert_test_we = addr_hit[3] & reg_we & !reg_error;

  assign alert_test_fatal_fault_wd = reg_wdata[0];

  assign alert_test_recov_fault_wd = reg_wdata[1];
  assign control_re = addr_hit[4] & reg_re & !reg_error;
  assign control_we = addr_hit[4] & reg_we & !reg_error;

  assign control_abort_wd = reg_wdata[0];

  assign control_doe_intr_en_wd = reg_wdata[1];

  assign control_error_wd = reg_wdata[2];
  assign status_re = addr_hit[5] & reg_re & !reg_error;
  assign status_we = addr_hit[5] & reg_we & !reg_error;

  assign status_busy_wd = reg_wdata[0];

  assign status_doe_intr_status_wd = reg_wdata[1];
  assign address_range_regwen_we = addr_hit[6] & reg_we & !reg_error;

  assign address_range_regwen_wd = reg_wdata[3:0];
  assign address_range_valid_we = addr_hit[7] & reg_we & !reg_error;

  assign address_range_valid_wd = reg_wdata[0];
  assign inbound_base_address_we = addr_hit[8] & reg_we & !reg_error;

  assign inbound_base_address_wd = reg_wdata[31:2];
  assign inbound_limit_address_we = addr_hit[9] & reg_we & !reg_error;

  assign inbound_limit_address_wd = reg_wdata[31:2];
  assign inbound_write_ptr_re = addr_hit[10] & reg_re & !reg_error;
  assign outbound_base_address_we = addr_hit[11] & reg_we & !reg_error;

  assign outbound_base_address_wd = reg_wdata[31:2];
  assign outbound_limit_address_we = addr_hit[12] & reg_we & !reg_error;

  assign outbound_limit_address_wd = reg_wdata[31:2];
  assign outbound_read_ptr_re = addr_hit[13] & reg_re & !reg_error;
  assign outbound_object_size_we = addr_hit[14] & reg_we & !reg_error;

  assign outbound_object_size_wd = reg_wdata[10:0];
  assign doe_intr_msg_addr_re = addr_hit[15] & reg_re & !reg_error;
  assign doe_intr_msg_data_re = addr_hit[16] & reg_re & !reg_error;

  // Assign write-enables to checker logic vector.
  always_comb begin
    reg_we_check = '0;
    reg_we_check[0] = intr_state_we;
    reg_we_check[1] = intr_enable_we;
    reg_we_check[2] = intr_test_we;
    reg_we_check[3] = alert_test_we;
    reg_we_check[4] = control_we;
    reg_we_check[5] = status_we;
    reg_we_check[6] = address_range_regwen_we;
    reg_we_check[7] = address_range_valid_we;
    reg_we_check[8] = inbound_base_address_gated_we;
    reg_we_check[9] = inbound_limit_address_gated_we;
    reg_we_check[10] = 1'b0;
    reg_we_check[11] = outbound_base_address_gated_we;
    reg_we_check[12] = outbound_limit_address_gated_we;
    reg_we_check[13] = 1'b0;
    reg_we_check[14] = outbound_object_size_we;
    reg_we_check[15] = 1'b0;
    reg_we_check[16] = 1'b0;
  end

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = intr_state_mbx_ready_qs;
        reg_rdata_next[1] = intr_state_mbx_abort_qs;
      end

      addr_hit[1]: begin
        reg_rdata_next[0] = intr_enable_mbx_ready_qs;
        reg_rdata_next[1] = intr_enable_mbx_abort_qs;
      end

      addr_hit[2]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      addr_hit[3]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      addr_hit[4]: begin
        reg_rdata_next[0] = control_abort_qs;
        reg_rdata_next[1] = control_doe_intr_en_qs;
        reg_rdata_next[2] = control_error_qs;
      end

      addr_hit[5]: begin
        reg_rdata_next[0] = status_busy_qs;
        reg_rdata_next[1] = status_doe_intr_status_qs;
      end

      addr_hit[6]: begin
        reg_rdata_next[3:0] = address_range_regwen_qs;
      end

      addr_hit[7]: begin
        reg_rdata_next[0] = address_range_valid_qs;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:2] = inbound_base_address_qs;
      end

      addr_hit[9]: begin
        reg_rdata_next[31:2] = inbound_limit_address_qs;
      end

      addr_hit[10]: begin
        reg_rdata_next[31:2] = inbound_write_ptr_qs;
      end

      addr_hit[11]: begin
        reg_rdata_next[31:2] = outbound_base_address_qs;
      end

      addr_hit[12]: begin
        reg_rdata_next[31:2] = outbound_limit_address_qs;
      end

      addr_hit[13]: begin
        reg_rdata_next[31:2] = outbound_read_ptr_qs;
      end

      addr_hit[14]: begin
        reg_rdata_next[10:0] = outbound_object_size_qs;
      end

      addr_hit[15]: begin
        reg_rdata_next[31:0] = doe_intr_msg_addr_qs;
      end

      addr_hit[16]: begin
        reg_rdata_next[31:0] = doe_intr_msg_data_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // shadow busy
  logic shadow_busy;
  assign shadow_busy = 1'b0;

  // register busy
  assign reg_busy = shadow_busy;

  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;

  // Assertions for Register Interface
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)

  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)

  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)

  // this is formulated as an assumption such that the FPV testbenches do disprove this
  // property by mistake
  //`ASSUME(reqParity, tl_reg_h2d.a_valid |-> tl_reg_h2d.a_user.chk_en == tlul_pkg::CheckDis)

endmodule
