
`include "ISA/ISA.v"
`include "OOO.v"


module veri_corrrect(
  input clk,
  input rst
);

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
    else if (OOO.C_valid) begin
      stall_ISA     <= 0;
      stalled_cycle <= 0;
    end
    else begin
      stall_ISA     <= 1;
      stalled_cycle <= stalled_cycle + 1;
    end


  // STEP: same initial state
  reg init;
  always @(posedge clk)
    if (rst)
      init <= 1'b1;
    else
      init <= 1'b0;

  wire same_pc = OOO.C_pc_last==ISA.pc_last;
  wire same_init_pc = init? same_pc: 1'b1;

  wire same_rf = OOO.rf_instance.array[0]==ISA.rf[0]
              && OOO.rf_instance.array[1]==ISA.rf[1]
              && OOO.rf_instance.array[2]==ISA.rf[2]
              && OOO.rf_instance.array[3]==ISA.rf[3];
  wire same_init_rf = init? same_rf: 1'b1;

  wire same_memi = OOO.memi_instance.array[0]==ISA.memi[0]
                && OOO.memi_instance.array[1]==ISA.memi[1]
                && OOO.memi_instance.array[2]==ISA.memi[2]
                && OOO.memi_instance.array[3]==ISA.memi[3]
                && OOO.memi_instance.array[4]==ISA.memi[4]
                && OOO.memi_instance.array[5]==ISA.memi[5]
                && OOO.memi_instance.array[6]==ISA.memi[6]
                && OOO.memi_instance.array[7]==ISA.memi[7];
  wire same_init_memi = init? same_memi: 1'b1;

  wire same_memd = OOO.memd[0]==ISA.memd[0]
                && OOO.memd[1]==ISA.memd[1]
                && OOO.memd[2]==ISA.memd[2]
                && OOO.memd[3]==ISA.memd[3];
  wire same_init_memd = init? same_memd: 1'b1;

  wire same_init_state = same_init_pc   && same_init_rf
                      && same_init_memi && same_init_memd;


  // STEP: same pc and rf forever
  wire incorrect = !(same_pc && same_rf);


  // STEP: same pc and rf forever
  wire live = stalled_cycle < 10;

endmodule

