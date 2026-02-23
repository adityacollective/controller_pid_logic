`timescale 1ns / 1ps

module pid_controller(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [15:0] setpoint,
    input  logic [15:0] feedback,
    input  logic [15:0] Kp,
    input  logic [15:0] Ki,
    input  logic [15:0] Kd,
    input  logic [15:0] clk_prescaler,
    output logic [15:0] control_signal
);

    logic signed [16:0]  error_s;        // signed error (one extra bit)
    logic signed [16:0]  prev_error_s;
    logic signed [31:0]  integral_s;     // widen integral
    logic signed [31:0]  derivative_s;

    // Clock divider / sampling pulse
    // TODO: Implement a programmable sampling pulse using clk_prescaler.
    // Create a 16-bit counter that increments each clk.
    // When the counter reaches clk_prescaler, assert sampling_flag for exactly 1 cycle
    // and reset the counter to 0. Otherwise sampling_flag must be 0.
    logic [15:0] clk_divider;
    logic        sampling_flag;

    // signed helpers for multiply (widen to avoid immediate overflow)
    logic signed [31:0] kp_mul, ki_mul;
    logic signed [31:0] kd_mul;
    logic signed [31:0] control_calc;

    // -------- Divider (creates 1-cycle sampling_flag pulse) --------
    // TODO: Add clock divider logic here (removed in baseline).

    // -------- Combinational math (based on current inputs/state) --------
    // TODO: Add combinational math logic

    // -------- PID state update on sampling --------
    

endmodule
