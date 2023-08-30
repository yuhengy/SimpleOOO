
`include "param.v"


module memd(
  input clk,
  input rst,

  input  [`MEMD_SIZE_LOG-1:0] req_addr,
  output [`REG_LEN-1      :0] resp_data
);

  reg [`REG_LEN-1:0] array [`MEMD_SIZE-1:0];

  // STEP Read
  assign resp_data = array[req_addr];

  // STEP Init
  always @(posedge clk) begin
    if (rst) begin
`ifdef INIT_MEMD_CUSTOMIZED
        array[0] <= 0;
        array[1] <= 1;
        array[2] <= 0;
        array[3] <= 0;
`else
      integer i;
      for (i=0; i<`MEMD_SIZE; i=i+1)
        array[i] <= 0;
`endif
    end
  end

endmodule

