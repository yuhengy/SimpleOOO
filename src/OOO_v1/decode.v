
`include "OOO_v1/param.v"


module decode(
  input  [`INST_LEN-1     :0] inst,

  output [`INST_SIZE_LOG-1:0] opcode,

  output                      rs1_used,
  output [`REG_LEN-1      :0] rs1_imm,
  output [`MEMI_SIZE_LOG-1:0] rs1_br_offset,
  output [`RF_SIZE_LOG-1  :0] rs1,

  output                      rs2_used,
  output [`RF_SIZE_LOG-1  :0] rs2,

  output                    wen,
  output [`RF_SIZE_LOG-1:0] rd,
  output                    rd_data_use_alu,

  output mem_valid,

  output is_br
);

  assign opcode = inst`OPCODE;

  assign rs1_used = (opcode==`INST_OP_ADD) || (opcode==`INST_OP_MUL) ||
                    (opcode==`INST_OP_LD);
  assign rs1_imm       = inst`RS1;
  assign rs1_br_offset = rs1_imm[`MEMI_SIZE_LOG-1:0];
  assign rs1           = rs1_imm[`RF_SIZE_LOG-1  :0];

  assign rs2_used = (opcode==`INST_OP_ADD) || (opcode==`INST_OP_MUL) ||
                    (opcode==`INST_OP_BR);
  assign rs2 = inst`RS2;

  assign wen = (opcode==`INST_OP_LI)  || (opcode==`INST_OP_ADD) ||
               (opcode==`INST_OP_MUL) || (opcode==`INST_OP_LD);
  assign rd = inst`RD;
  assign rd_data_use_alu = (opcode==`INST_OP_LI)  ||
                           (opcode==`INST_OP_ADD) ||
                           (opcode==`INST_OP_MUL);

  assign mem_valid = (opcode==`INST_OP_LD);

  assign is_br     = (opcode==`INST_OP_BR);

endmodule

