// Define ALU command codes
`define CMD_ADD  3'd0
`define CMD_SUB  3'd1
`define CMD_XOR  3'd2
`define CMD_SLT  3'd3
`define CMD_AND  3'd4
`define CMD_NAND 3'd5
`define CMD_NOR  3'd6
`define CMD_OR   3'd7

// define gates with delays
`define NAND nand #20
`define NOR nor #20
`define NOT not #10
`define AND and #30
`define AND32 and #330
`define OR or #30
`define XNOR xnor #60
`define XOR xor #60

// Define the ALU look up table to return the control signals which determine
// the behavior of the ALU
module alu_cmd_lut
(
output reg[2:0] muxindex,
output reg      invert_b,
output reg      cin,
input[2:0]      cmd
);

  always @(cmd) begin
    case (cmd)
      `CMD_ADD:  begin muxindex = 0; invert_b = 0; cin = 0; end
      `CMD_SUB:  begin muxindex = 0; invert_b = 1; cin = 1; end
      // `CMD_XOR:  begin muxindex = 1; invert_b = 0; cin = 0; end
      // `CMD_SLT:  begin muxindex = 2; invert_b = ?; cin = 0; end
      // `CMD_AND:  begin muxindex = 3; invert_b = ?; cin = 0; end
      // `CMD_NAND: begin muxindex = 3; invert_b = ?; cin = 0; end
      // `CMD_NOR:  begin muxindex = ?; invert_b = ?; cin = 0; end
      // `CMD_OR:   begin muxindex = ?; invert_b = ?; cin = 0; end
    endcase
  end
endmodule

// ADDER

module adder_1_bit
(
    output sum,
    output cout,
    input a,
    input b,
    input cin
);
  wire AxorB;
  wire AandB;
  wire AxorBandCin;

  `XOR xorgate0(AxorB, a, b);
  `XOR xorgate1(sum, AxorB, cin);

  `AND andgate1(AandB, a, b);
  `AND andgate1(AxorBandCin, AxorB, cin);
  `OR orgate(cout, AandB, AxorBandCin);
endmodule

module adder_8_bit
(
  output[7:0] sum,
  output cout,
  input[7:0] a,
  input[7:0] b,
  input cin
);
  adder_1_bit a0(.sum(sum[0]), .cout(cout0), .a(a[0]), .b(b[0]), .cin(cin));
  adder_1_bit a1(.sum(sum[1]), .cout(cout1), .a(a[1]), .b(b[1]), .cin(cout0));
  adder_1_bit a2(.sum(sum[2]), .cout(cout2), .a(a[2]), .b(b[2]), .cin(cout1));
  adder_1_bit a3(.sum(sum[3]), .cout(cout3), .a(a[3]), .b(b[3]), .cin(cout2));
  adder_1_bit a4(.sum(sum[4]), .cout(cout4), .a(a[4]), .b(b[4]), .cin(cout3));
  adder_1_bit a5(.sum(sum[5]), .cout(cout5), .a(a[5]), .b(b[5]), .cin(cout4));
  adder_1_bit a6(.sum(sum[6]), .cout(cout6), .a(a[6]), .b(b[6]), .cin(cout5));
  adder_1_bit a7(.sum(sum[7]), .cout(cout), .a(a[7]), .b(b[7]), .cin(cout6));
endmodule

module adder_32_bit
(
  output[31:0] sum,
  output cout,
  output ofl,
  input[31:0] a,
  input[31:0] b,
  input cin
);
  adder_8_bit a0(.sum(sum[7:0]), .cout(cout0), .a(a[7:0]), .b(b[7:0]), .cin(cin));
  adder_8_bit a1(.sum(sum[15:8]), .cout(cout1), .a(a[15:8]), .b(b[15:8]), .cin(cout0));
  adder_8_bit a2(.sum(sum[23:16]), .cout(cout2), .a(a[23:16]), .b(b[23:16]), .cin(cout1));
  adder_8_bit a3(.sum(sum[31:24]), .cout(cout), .a(a[31:24]), .b(b[31:24]), .cin(cout2));
  // Overflow has occured if:
  //   The result of adding two positive numbers is negative
  //   The result of adding two negative numbers is positive
  wire same_sign, switched;
  `XNOR xnor0(same_sign, a[31], b[31]);
  `XOR xor0(switched, sum[31], a[31]);
  `AND and0(ofl, same_sign, switched);
endmodule

// INVERTER

module inverter_1_bit
(
  output out,
  input in
);
  `NOT not0(out, in);
endmodule

module inverter_8_bit
(
  output[7:0] out,
  input[7:0] in
);
  inverter_1_bit inv0(.out(out[0]), .in(in[0]));
  inverter_1_bit inv1(.out(out[1]), .in(in[1]));
  inverter_1_bit inv2(.out(out[2]), .in(in[2]));
  inverter_1_bit inv3(.out(out[3]), .in(in[3]));
  inverter_1_bit inv4(.out(out[4]), .in(in[4]));
  inverter_1_bit inv5(.out(out[5]), .in(in[5]));
  inverter_1_bit inv6(.out(out[6]), .in(in[6]));
  inverter_1_bit inv7(.out(out[7]), .in(in[7]));
endmodule

module inverter_32_bit
(
  output[31:0] out,
  input[31:0] in
);
  inverter_8_bit inv0(.out(out[7:0]), .in(in[7:0]));
  inverter_8_bit inv1(.out(out[15:8]), .in(in[15:8]));
  inverter_8_bit inv2(.out(out[23:16]), .in(in[23:16]));
  inverter_8_bit inv3(.out(out[31:24]), .in(in[31:24]));
endmodule

// MUX

module mux_1_bit
(
  output out,
  input a,
  input b,
  input s
);
  wire not_s, a_and_not_s, b_and_s;
  `NOT not0(not_s, s);
  `AND and0(a_and_not_s, a, not_s);
  `AND and1(b_and_s, b, s);
  `OR or0(out, a_and_not_s, b_and_s);
endmodule

module mux_8_bit
(
  output[7:0] out,
  input[7:0] a,
  input[7:0] b,
  input s
);
  mux_1_bit mux0(.out(out[0]), .a(a[0]), .b(b[0]), .s(s));
  mux_1_bit mux1(.out(out[1]), .a(a[1]), .b(b[1]), .s(s));
  mux_1_bit mux2(.out(out[2]), .a(a[2]), .b(b[2]), .s(s));
  mux_1_bit mux3(.out(out[3]), .a(a[3]), .b(b[3]), .s(s));
  mux_1_bit mux4(.out(out[4]), .a(a[4]), .b(b[4]), .s(s));
  mux_1_bit mux5(.out(out[5]), .a(a[5]), .b(b[5]), .s(s));
  mux_1_bit mux6(.out(out[6]), .a(a[6]), .b(b[6]), .s(s));
  mux_1_bit mux7(.out(out[7]), .a(a[7]), .b(b[7]), .s(s));
endmodule

module mux_32_bit
(
  output[31:0] out,
  input[31:0] a,
  input[31:0] b,
  input s
);
  mux_8_bit mux0(.out(out[7:0]), .a(a[7:0]), .b(b[7:0]), .s(s));
  mux_8_bit mux1(.out(out[15:8]), .a(a[15:8]), .b(b[15:8]), .s(s));
  mux_8_bit mux2(.out(out[23:16]), .a(a[23:16]), .b(b[23:16]), .s(s));
  mux_8_bit mux3(.out(out[31:24]), .a(a[31:24]), .b(b[31:24]), .s(s));
endmodule

// IS ZERO

module is_zero
(
  output out,
  input[31:0] num
);
  wire[31:0] not_num;
  inverter_32_bit inv(.out(not_num), .in(num));
  `AND32 and0(out, not_num[31:0]);
endmodule

// MAIN ALU

module ALU
(
  output[31:0] res,
  output cout,
  output ofl,
  output zero,
  input[31:0] a,
  input[31:0] b,
  input[2:0] cmd
);
  wire[2:0] muxindex;
  wire invert_b, cin;
  alu_cmd_lut lut(.muxindex(muxindex), .invert_b(invert_b), .cin(cin), .cmd(cmd));

  wire[31:0] not_b, adder_input;
  inverter_32_bit inverter(.out(not_b), .in(b));
  mux_32_bit mux0(.out(adder_input), .a(b), .b(not_b), .s(invert_b));

  adder_32_bit adder(.sum(res[31:0]), .cout(cout), .ofl(ofl), .a(a[31:0]), .b(adder_input[31:0]), .cin(cin));

  is_zero zero0(.out(zero), .num(res[31:0]));
endmodule