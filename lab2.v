// finite state machine - FF block
module fsm (
  input clk,
  input rst_n,
  input flk,
  input [4:0] index,
  output reg [2:0] state
);

  localparam S0 = 3'b000,
             S1 = 3'b001,
             S2 = 3'b010,
             S3 = 3'b011,
             S4 = 3'b100,
             S5 = 3'b101,
             S6 = 3'b110;

  initial begin
      state = S0;
  end
  always @(rst_n) begin
      if (rst_n == 0) begin
          state <= S0;
      end
  end
  always @(posedge clk) begin
      case(state)
          S0: if(rst_n == 1 && flk == 1 && index == 0) begin
                  state <= S1;
              end
          S1: if(index == 14) begin // Check if index is 14 (before 15 to avoid double counting)
                  state <= S2;
              end
          S2: if(index == 6) begin
                  if(flk == 0) begin
                      state <= S3;
                  end else begin
                      state <= S1;
                  end
              end
          S3: if(index == 9) begin
                  state <= S4;
              end
          S4: if(index == 1 || index == 6) begin
                  if(flk == 0) begin
                      if(index == 1) begin
                          state <= S5;
                      end
                  end else begin 
                      state <= S3;
                  end
              end
          S5: if(index == 4) begin
                  state <= S6;
              end
          S6: if(index == 1) begin
                  state <= S0;
              end
          default: begin
              state <= S0;
          end
      endcase
  end

endmodule

// index_calculating block - FF block
module index_calculating (
  input [2:0] state,
  input clk,
  input rst_n,
  output reg [4:0] index
);
  localparam S0 = 3'b000,
             S1 = 3'b001,
             S2 = 3'b010,
             S3 = 3'b011,
             S4 = 3'b100,
             S5 = 3'b101,
             S6 = 3'b110;
  always @(rst_n) begin
      if (rst_n == 0) begin
          index <= 5'b00000;
      end
  end  
  always @(posedge clk) begin 
    if (rst_n == 1) begin
      case(state)
        S0: index <= 5'b0000;
        S1: index <= index + 1;
        S2: index <= index - 1;
        S3: index <= index + 1;
        S4: index <= index - 1;
        S5: index <= index + 1;
        S6: index <= index - 1;
        default: begin
          index <= 5'b0000;
        end
      endcase
    end
  end
endmodule

    
// decode block - combinational block
module decode (
  input [4:0] index,
  output reg [15:0] led
);

  always @(index) begin
      case (index)
          5'b00000 : led = 16'b00_00_00_00_00_00_00_01; //0
          5'b00001 : led = 16'b00_00_00_00_00_00_00_11; //1
          5'b00010 : led = 16'b00_00_00_00_00_00_01_11; //2 
          5'b00011 : led = 16'b00_00_00_00_00_00_11_11; //3
          5'b00100 : led = 16'b00_00_00_00_00_01_11_11; //4
          5'b00101 : led = 16'b00_00_00_00_00_11_11_11; //5
          5'b00110 : led = 16'b00_00_00_00_01_11_11_11; //6
          5'b00111 : led = 16'b00_00_00_00_11_11_11_11; //7
          5'b01000 : led = 16'b00_00_00_01_11_11_11_11; //8
          5'b01001 : led = 16'b00_00_00_11_11_11_11_11; //9
          5'b01010 : led = 16'b00_00_01_11_11_11_11_11; //10
          5'b01011 : led = 16'b00_00_11_11_11_11_11_11; //11
          5'b01100 : led = 16'b00_01_11_11_11_11_11_11; //12
          5'b01101 : led = 16'b00_11_11_11_11_11_11_11; //13
          5'b01110 : led = 16'b01_11_11_11_11_11_11_11; //14
          5'b01111 : led = 16'b11_11_11_11_11_11_11_11; //15
          5'b10000 : led = 16'b00_00_00_00_00_00_00_00; // Off all led
          default : begin
          led = 16'b00_00_00_00_00_00_00_00;
		  end
      endcase
  end

endmodule

module bound_flasher (
  input rst_n,
  input clk,
  input flk,
  output[15:0] led
);

  wire [2:0] state;
  wire [4:0] index;

  fsm fsm_run(
    .clk(clk),
    .rst_n(rst_n),
    .flk(flk),
    .index(index),
    .state(state)
  );

  index_calculating index_calculating_run(
    .state(state),
    .clk(clk),
    .rst_n(rst_n),
    .index(index)
  );
	
  decode decode_run(
    .index(index),
    .led(led)
  );

endmodule

