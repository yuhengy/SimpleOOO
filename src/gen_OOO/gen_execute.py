
def gen_execute(
):

  v  = ""
  v += "\n"

  v += "`include \"param.v\"\n"
  v += "\n"
  v += "\n"

  v += "module execute(\n"
  v += "  input  [`MEMI_SIZE_LOG-1:0] pc,\n"
  v += "  input  [`INST_SIZE_LOG-1:0] op,\n"
  v += "\n"
  v += "  input  [`REG_LEN-1      :0] rs1_imm,\n"
  v += "  input  [`MEMI_SIZE_LOG-1:0] rs1_br_offset,\n"
  v += "  input  [`REG_LEN-1      :0] rs1_data,\n"
  v += "\n"
  v += "  input  [`REG_LEN-1      :0] rs2_data,\n"
  v += "\n"
  v += "  output [`MEMD_SIZE_LOG-1:0] mem_addr,\n"
  v += "  input  [`REG_LEN-1      :0] mem_data,\n"
  v += "\n"
  v += "  input                       rd_data_use_alu,\n"
  v += "  output [`REG_LEN-1      :0] rd_data,\n"
  v += "\n"
  v += "  input                       is_br,\n"
  v += "  output                      taken,\n"
  v += "  output [`MEMI_SIZE_LOG-1:0] next_pc\n"
  v += ");\n"
  v += "\n"

  v += "  // alu\n"
  v += "  wire [`REG_LEN-1:0] alu_data;\n"
  v += "  assign alu_data =\n"
  v += "    {`REG_LEN{op==`INST_OP_LI }} & rs1_imm |\n"
  v += "    {`REG_LEN{op==`INST_OP_ADD}} & (rs1_data + rs2_data) |\n"
  v += "    {`REG_LEN{op==`INST_OP_MUL}} & (rs1_data * rs2_data);\n"
  v += "\n"

  v += "  // memory read\n"
  v += "  assign mem_addr = rs1_data[`MEMD_SIZE_LOG-1:0];\n"
  v += "\n"

  v += "  // rd\n"
  v += "  assign rd_data = rd_data_use_alu? alu_data : mem_data;\n"
  v += "\n"

  v += "  // branch\n"
  v += "  wire [`MEMI_SIZE_LOG-1:0] next_pc_branch;\n"
  v += "  assign taken = (rs2_data==0);\n"
  v += "  assign next_pc_branch = taken? (pc + rs1_br_offset) : (pc + 1);\n"
  v += "  assign next_pc = is_br? next_pc_branch : (pc + 1);\n"
  v += "\n"

  v += "endmodule\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_execute()
  with open("src/gen/execute.v", "w") as f:
    f.write(v)

