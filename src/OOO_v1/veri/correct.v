
`include "ISA/param.v"
`include "ISA/ISA.v"
`include "OOO_v1/OOO.v"


module veri_corrrect(
  input clk,
  input rst
);
  genvar p;




  // STEP: instantiate OOO and ISA
  OOO OOO(.clk(clk)                 , .rst(rst));
  ISA ISA(.clk(stall_ISA? 1'b0: clk), .rst(rst));




  // STEP: synchronized simulation
  reg       stall_ISA;
  reg [3:0] stalled_cycle;
  always @(posedge clk)
    if (rst) begin
      stall_ISA     <= 0;
      stalled_cycle <= 0;
    end
    else if (OOO.veri_commit) begin
      stall_ISA     <= 0;
      stalled_cycle <= 0;
    end
    else begin
      stall_ISA     <= 1;
      stalled_cycle <= stalled_cycle + 1;
    end




  // STEP: same initial state
  wire same_init_state;


  // STEP.1: indicate init state
  reg init;
  always @(posedge clk)
    if (rst)
      init <= 1'b1;
    else
      init <= 1'b0;


  // STEP.2: rf
  wire [`RF_SIZE-1:0] same_rf_entry;
  generate for(p=0; p<`RF_SIZE; p=p+1) begin
    assign same_rf_entry[p] = OOO.veri_rf[p]==ISA.rf[p];
  end endgenerate
  wire same_rf = &same_rf_entry;
  wire same_init_rf = init? same_rf: 1'b1;


  // STEP.3: memi
  wire [`MEMI_SIZE-1:0] same_memi_entry;
  generate for(p=0; p<`MEMI_SIZE; p=p+1) begin
    assign same_memi_entry[p] = OOO.veri_memi[p]==ISA.memi[p];
  end endgenerate
  wire same_memi = &same_memi_entry;
  wire same_init_memi = init? same_memi: 1'b1;


  // STEP.4: memd
  wire [`MEMD_SIZE-1:0] same_memd_entry;
  generate for(p=0; p<`MEMD_SIZE; p=p+1) begin
    assign same_memd_entry[p] = OOO.veri_memd[p]==ISA.memd[p];
  end endgenerate
  wire same_memd = &same_memd_entry;
  wire same_init_memd = init? same_memd: 1'b1;


  // STEP.5: and together
  assign same_init_state = same_init_rf && same_init_memi && same_init_memd;




  // STEP: same pc and rf forever
  wire correct = same_pc && same_rf;
  
  wire same_pc = OOO.veri_pc_last==ISA.pc_last;




  // STEP: liveness
  wire live = stalled_cycle < 10;

endmodule

