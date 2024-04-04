`timescale 1ns/1ns
`include "lab2.v"
module tb;

  // Declare signal
  reg clk = 0;
  reg rst_n = 0;
  reg flk = 0;
  wire [15:0] led;

  // Instance module main
  bound_flasher uut (
    .rst_n(rst_n),
    .clk(clk),
    .flk(flk),
    .led(led)
  );

  // Generate clock
  always #1 clk = ~clk;

  // Initial block for testbench
  initial begin
      $dumpfile("lab2_no2_tb.vcd");
      $dumpvars(0, tb);
      rst_n = 1;
      flk = 1;
      #5
      flk = 0;
      #10
      rst_n = 0;
      #20
      rst_n = 1;
      #30
      flk = 1;
      #500;
      $finish;
  end
endmodule

