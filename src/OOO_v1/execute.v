
`include "OOO_v1/param.v"


module execute(
  input  [`MEMI_SIZE_LOG-1:0] pc,
  input  [`INST_SIZE_LOG-1:0] op,

  input  [`REG_LEN-1      :0] rs1_imm,
  input  [`MEMI_SIZE_LOG-1:0] rs1_br_offset,
  input  [`REG_LEN-1      :0] rs1_data,

  input  [`REG_LEN-1      :0] rs2_data,

  output [`MEMD_SIZE_LOG-1:0] mem_addr,
  input  [`REG_LEN-1      :0] mem_data,

  input                       rd_data_use_alu,
  output [`REG_LEN-1      :0] rd_data,

  input                       is_br,
  output                      taken,
  output [`MEMI_SIZE_LOG-1:0] next_pc
);

  // alu
  wire [`REG_LEN-1:0] alu_data;
  assign alu_data =
    {`REG_LEN{op==`INST_OP_LI }} & rs1_imm |
    {`REG_LEN{op==`INST_OP_ADD}} & (rs1_data + rs2_data) |
    {`REG_LEN{op==`INST_OP_MUL}} & (rs1_data * rs2_data);

  // memory read
  assign mem_addr = rs1_data[`MEMD_SIZE_LOG-1:0];

  // rd
  assign rd_data = rd_data_use_alu? alu_data : mem_data;

  // branch
  wire [`MEMI_SIZE_LOG-1:0] next_pc_branch;
  assign taken = (rs2_data==0);
  assign next_pc_branch = taken? (pc + rs1_br_offset) : (pc + 1);
  assign next_pc = is_br? next_pc_branch : (pc + 1);

endmodule

