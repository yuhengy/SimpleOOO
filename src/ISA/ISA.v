
`include "ISA/param.v"


module ISA(
  input clk,
  input rst
);
  integer i;
  



  // STEP: state
  reg [`MEMI_SIZE_LOG-1:0] pc;
  reg [`REG_LEN-1      :0] rf   [`RF_SIZE-1  :0];
  reg [`INST_LEN-1     :0] memi [`MEMI_SIZE-1:0];
  reg [`REG_LEN-1      :0] memd [`MEMD_SIZE-1:0];
  
  always @(posedge clk)
    if (rst) begin
      // STEP.1: memi
`ifdef INIT_MEMI_CUSTOMIZED
      memi[0] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[1] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[2] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[3] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[4] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[5] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[6] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
      memi[7] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};
`else
      for (i=0; i<`MEMI_SIZE; i=i+1)
        memi[i] <= 0;
`endif


      // STEP.2: memd
`ifdef INIT_MEMD_CUSTOMIZED
        memd[0] <= 1;
        memd[1] <= 0;
        memd[2] <= 0;
        memd[3] <= 0;
`else
      for (i=0; i<`MEMD_SIZE; i=i+1)
        memd[i] <= 0;
`endif
    end




  // STEP: PC
  always @(posedge clk)
    if (rst)
      pc <= 0;
    else
      pc <= next_pc;




  // STEP: Fetch
  wire [`INST_LEN-1:0] inst;
  assign inst = memi[pc];




  // STEP: Decode
  wire [`INST_SIZE_LOG-1:0] opcode;
  wire [`REG_LEN-1      :0] rs1_imm;
  wire [`RF_SIZE_LOG-1  :0] rs1;
  wire [`MEMI_SIZE_LOG-1:0] rs1_br_offset;
  wire [`RF_SIZE_LOG-1  :0] rs2;
  
  wire                    wen;
  wire [`RF_SIZE_LOG-1:0] rd;
  wire                    rd_data_use_alu;
  
  wire mem_valid;
  
  wire is_br;
  

  // STEP.1: operands
  assign opcode = inst`OPCODE;
  assign rs1_imm       = inst`RS1;
  assign rs1_br_offset = rs1_imm[`MEMI_SIZE_LOG-1:0];
  assign rs1           = rs1_imm[`RF_SIZE_LOG-1  :0];
  assign rs2           = inst`RS2;


  // STEP.2: writeback
  assign wen = (opcode==`INST_OP_LI)  || (opcode==`INST_OP_ADD) ||
               (opcode==`INST_OP_MUL) || (opcode==`INST_OP_LD);
  assign rd = inst`RD;
  assign rd_data_use_alu = (opcode==`INST_OP_LI)  ||
                           (opcode==`INST_OP_ADD) ||
                           (opcode==`INST_OP_MUL);


  // STEP.3: memory
  assign mem_valid = (opcode==`INST_OP_LD);


  // STEP.4: branch
  assign is_br     = (opcode==`INST_OP_BR);




  // STEP: rf Read Write
  wire [`REG_LEN-1:0] rs1_data;
  wire [`REG_LEN-1:0] rs2_data;
  assign rs1_data = rf[rs1];
  assign rs2_data = rf[rs2];
  
  always @(posedge clk)
    if (rst) begin
`ifdef INIT_RF_CUSTOMIZED
      rf[0] <= 1;
      rf[1] <= 0;
      rf[2] <= 0;
      rf[3] <= 0;
`else
      for (i=0; i<`RF_SIZE; i=i+1)
        rf[i] <= 0;
`endif
    end
    else
      if (wen)
        rf[rd] <= rd_data;




  // STEP: Execute
  wire [`REG_LEN-1      :0] rd_data;
  wire [`MEMI_SIZE_LOG-1:0] next_pc;


  // STEP.1: alu
  wire [`REG_LEN-1:0] alu_data;
  assign alu_data =
    {`REG_LEN{opcode==`INST_OP_LI }} & rs1_imm |
    {`REG_LEN{opcode==`INST_OP_ADD}} & (rs1_data + rs2_data) |
    {`REG_LEN{opcode==`INST_OP_MUL}} & (rs1_data * rs2_data);


  // STEP.2: memory read
  wire [`MEMD_SIZE_LOG-1:0] mem_addr;
  wire [`REG_LEN-1      :0] mem_data;
  assign mem_addr = rs1_data[`MEMD_SIZE_LOG-1:0];
  assign mem_data = memd[mem_addr];


  // STEP.3: rd
  assign rd_data = rd_data_use_alu? alu_data : mem_data;


  // STEP.4: branch
  wire                      taken;
  wire [`MEMI_SIZE_LOG-1:0] next_pc_branch;
  assign taken = (rs2_data==0);
  assign next_pc_branch = taken? (pc + rs1_br_offset) : (pc + 1);
  assign next_pc = is_br? next_pc_branch : (pc + 1);




  // STEP: for verification
  reg [`MEMI_SIZE_LOG-1:0] pc_last;
  always @(posedge clk)
      pc_last <= pc;

endmodule

