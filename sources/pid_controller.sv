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
    logic signed [31:0]  integral_s;     // widen integral (was wrong-width)
    logic signed [31:0]  derivative_s;

    // Clock divider / sampling pulse
    logic [15:0] clk_divider;
    logic        sampling_flag;

    // signed helpers for multiply (widen to avoid immediate overflow)
    logic signed [31:0] kp_mul, ki_mul;
    logic signed [31:0] kd_mul;
    logic signed [31:0] control_calc;

    // -------- Divider (creates 1-cycle sampling_flag pulse) --------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_divider    <= 16'h0000;
            sampling_flag  <= 1'b0;
        end else if (clk_divider == clk_prescaler) begin
            clk_divider    <= 16'h0000;
            sampling_flag  <= 1'b1;
        end else begin
            clk_divider    <= clk_divider + 16'd1;
            sampling_flag  <= 1'b0;
        end
    end

    // -------- Combinational math (based on current inputs/state) --------
    always_comb begin
        // signed error (treat setpoint/feedback as unsigned inputs but compute signed diff)
        error_s = $signed({1'b0, setpoint}) - $signed({1'b0, feedback});

        // products (still can overflow if huge gains, but at least deterministic)
        kp_mul = $signed({1'b0, Kp}) * error_s;
        ki_mul = $signed({1'b0, Ki}) * error_s;
        kd_mul = $signed({1'b0, Kd}) * (error_s - prev_error_s);

        control_calc = kp_mul + integral_s + kd_mul;
    end

    // -------- PID state update on sampling --------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_error_s   <= '0;
            integral_s     <= '0;
            derivative_s   <= '0;
            control_signal <= 16'h0000;
        end else if (sampling_flag) begin
            // integral update
            integral_s   <= integral_s + ki_mul;

            // derivative update (stored for debug; control uses kd_mul directly)
            derivative_s <= kd_mul;

            // output update (truncate to 16 bits like typical hardware wrap)
            control_signal <= control_calc[15:0];

            // update prev_error
            prev_error_s <= error_s;

        end
    end

endmodule