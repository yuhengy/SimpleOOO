
`include "OOO_v1/param.v"


module rf(
  input clk,
  input rst,

  input  [`RF_SIZE_LOG-1:0] rs1,
  output [`REG_LEN-1    :0] rs1_data,

  input  [`RF_SIZE_LOG-1:0] rs2,
  output [`REG_LEN-1    :0] rs2_data,

  input                     wen,
  input  [`RF_SIZE_LOG-1:0] rd,
  input  [`REG_LEN-1    :0] rd_data
);

  reg [`REG_LEN-1:0] array [`RF_SIZE-1:0];

  // STEP Read
  assign rs1_data = array[rs1];
  assign rs2_data = array[rs2];

  always @(posedge clk) begin
    // STEP Init
    if (rst) begin
`ifdef INIT_RF_CUSTOMIZED
      array[0] <= `REG_LEN'd0;
      array[1] <= `REG_LEN'd0;
      array[2] <= `REG_LEN'd0;
      array[3] <= `REG_LEN'd0;
`else
      integer i;
      for (i=0; i<`RF_SIZE; i=i+1)
        array[i] <= `REG_LEN'd0;
`endif
    end

    // STEP Write
    else if (wen) begin
      array[rd] <= rd_data;
    end
  end

endmodule

