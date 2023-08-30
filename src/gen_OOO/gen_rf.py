
def gen_rf(
):

  v  = ""
  v += "\n"

  v += "`include \"param.v\"\n"
  v += "\n"
  v += "\n"

  v += "module rf(\n"
  v += "  input clk,\n"
  v += "  input rst,\n"
  v += "\n"
  v += "  input  [`RF_SIZE_LOG-1:0] rs1,\n"
  v += "  output [`REG_LEN-1    :0] rs1_data,\n"
  v += "\n"
  v += "  input  [`RF_SIZE_LOG-1:0] rs2,\n"
  v += "  output [`REG_LEN-1    :0] rs2_data,\n"
  v += "\n"
  v += "  input                     wen,\n"
  v += "  input  [`RF_SIZE_LOG-1:0] rd,\n"
  v += "  input  [`REG_LEN-1    :0] rd_data\n"
  v += ");\n"
  v += "\n"

  v += "  reg [`REG_LEN-1:0] array [`RF_SIZE-1:0];\n"
  v += "\n"

  v += "  // STEP Read\n"
  v += "  assign rs1_data = array[rs1];\n"
  v += "  assign rs2_data = array[rs2];\n"
  v += "\n"
  v += "  always @(posedge clk) begin\n"
  v += "    // STEP Init\n"
  v += "    if (rst) begin\n"
  v += "`ifdef INIT_RF_CUSTOMIZED\n"
  v += "      array[0] <= `REG_LEN'd0;\n"
  v += "      array[1] <= `REG_LEN'd0;\n"
  v += "      array[2] <= `REG_LEN'd0;\n"
  v += "      array[3] <= `REG_LEN'd0;\n"
  v += "`else\n"
  v += "      integer i;\n"
  v += "      for (i=0; i<`RF_SIZE; i=i+1)\n"
  v += "        array[i] <= `REG_LEN'd0;\n"
  v += "`endif\n"
  v += "    end\n"
  v += "\n"
  
  v += "    // STEP Write\n"
  v += "    else if (wen) begin\n"
  v += "      array[rd] <= rd_data;\n"
  v += "    end\n"
  v += "  end\n"
  v += "\n"

  v += "endmodule\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_rf()
  with open("src/gen/rf.v", "w") as f:
    f.write(v)

