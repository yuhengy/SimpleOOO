
def gen_memd(
):

  v  = ""
  v += "\n"

  v += "`include \"param.v\"\n"
  v += "\n"
  v += "\n"

  v += "module memd(\n"
  v += "  input clk,\n"
  v += "  input rst,\n"
  v += "\n"
  v += "  input  [`MEMD_SIZE_LOG-1:0] req_addr,\n"
  v += "  output [`REG_LEN-1      :0] resp_data\n"
  v += ");\n"
  v += "\n"

  v += "  reg [`REG_LEN-1:0] array [`MEMD_SIZE-1:0];\n"
  v += "\n"

  v += "  // STEP Read\n"
  v += "  assign resp_data = array[req_addr];\n"
  v += "\n"

  v += "  // STEP Init\n"
  v += "  always @(posedge clk) begin\n"
  v += "    if (rst) begin\n"
  v += "`ifdef INIT_MEMD_CUSTOMIZED\n"
  v += "        array[0] <= 0;\n"
  v += "        array[1] <= 1;\n"
  v += "        array[2] <= 0;\n"
  v += "        array[3] <= 0;\n"
  v += "`else\n"
  v += "      integer i;\n"
  v += "      for (i=0; i<`MEMD_SIZE; i=i+1)\n"
  v += "        array[i] <= 0;\n"
  v += "`endif\n"
  v += "    end\n"
  v += "  end\n"
  v += "\n"

  v += "endmodule\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_memd()
  with open("src/gen/memd.v", "w") as f:
    f.write(v)

