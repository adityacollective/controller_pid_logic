`timescale 1ns/1ps

module top (
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

  pid_controller u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .setpoint(setpoint),
    .feedback(feedback),
    .Kp(Kp),
    .Ki(Ki),
    .Kd(Kd),
    .clk_prescaler(clk_prescaler),
    .control_signal(control_signal)
  );

endmodule
