
def gen_decode(
):

  v  = ""
  v += "\n"

  v += "`include \"param.v\"\n"
  v += "\n"
  v += "\n"

  v += "module decode(\n"
  v += "  input  [`INST_LEN-1     :0] inst,\n"
  v += "\n"
  v += "  output [`INST_SIZE_LOG-1:0] opcode,\n"
  v += "\n"
  v += "  output                      rs1_used,\n"
  v += "  output [`REG_LEN-1      :0] rs1_imm,\n"
  v += "  output [`MEMI_SIZE_LOG-1:0] rs1_br_offset,\n"
  v += "  output [`RF_SIZE_LOG-1  :0] rs1,\n"
  v += "\n"
  v += "  output                      rs2_used,\n"
  v += "  output [`RF_SIZE_LOG-1  :0] rs2,\n"
  v += "\n"
  v += "  output                    wen,\n"
  v += "  output [`RF_SIZE_LOG-1:0] rd,\n"
  v += "  output                    rd_data_use_alu,\n"
  v += "\n"
  v += "  output mem_valid,\n"
  v += "\n"
  v += "  output is_br\n"
  v += ");\n"
  v += "\n"
  
  v += "  assign opcode = inst`OPCODE;\n"
  v += "\n"
  v += "  assign rs1_used = (opcode==`INST_OP_ADD) || (opcode==`INST_OP_MUL) ||\n"
  v += "                    (opcode==`INST_OP_LD);\n"
  v += "  assign rs1_imm       = inst`RS1;\n"
  v += "  assign rs1_br_offset = rs1_imm[`MEMI_SIZE_LOG-1:0];\n"
  v += "  assign rs1           = rs1_imm[`RF_SIZE_LOG-1  :0];\n"
  v += "\n"
  v += "  assign rs2_used = (opcode==`INST_OP_ADD) || (opcode==`INST_OP_MUL) ||\n"
  v += "                    (opcode==`INST_OP_BR);\n"
  v += "  assign rs2 = inst`RS2;\n"
  v += "\n"
  v += "  assign wen = (opcode==`INST_OP_LI)  || (opcode==`INST_OP_ADD) ||\n"
  v += "               (opcode==`INST_OP_MUL) || (opcode==`INST_OP_LD);\n"
  v += "  assign rd = inst`RD;\n"
  v += "  assign rd_data_use_alu = (opcode==`INST_OP_LI)  ||\n"
  v += "                           (opcode==`INST_OP_ADD) ||\n"
  v += "                           (opcode==`INST_OP_MUL);\n"
  v += "\n"
  v += "  assign mem_valid = (opcode==`INST_OP_LD);\n"
  v += "\n"
  v += "  assign is_br     = (opcode==`INST_OP_BR);\n"
  v += "\n"

  v += "endmodule\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_decode()
  with open("src/gen/decode.v", "w") as f:
    f.write(v)

