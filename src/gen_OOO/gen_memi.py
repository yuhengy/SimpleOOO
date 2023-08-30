
def gen_memi(
):

  v  = ""
  v += "\n"

  v += "`include \"param.v\"\n"
  v += "\n"
  v += "\n"

  v += "module memi(\n"
  v += "  input clk,\n"
  v += "  input rst,\n"
  v += "\n"
  v += "  input  [`MEMI_SIZE_LOG-1:0] req_addr,\n"
  v += "  output [`INST_LEN-1     :0] resp_data\n"
  v += ");\n"
  v += "\n"

  v += "  reg [`INST_LEN-1:0] array [`MEMI_SIZE-1:0];\n"
  v += "\n"

  v += "  // STEP Read\n"
  v += "  assign resp_data = array[req_addr];\n"
  v += "\n"

  v += "  // STEP Init\n"
  v += "  always @(posedge clk) begin\n"
  v += "    if (rst) begin\n"
  v += "`ifdef INIT_MEMI_CUSTOMIZED\n"
  v += "      array[0] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[1] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[2] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[3] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[4] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[5] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[6] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "      array[7] <= {`INST_SIZE_LOG'd`INST_OP_ADD, `REG_LEN'd0, `RF_SIZE_LOG'd0, `RF_SIZE_LOG'd0};\n"
  v += "`else\n"
  v += "      integer i;\n"
  v += "      for (i=0; i<`MEMI_SIZE; i=i+1)\n"
  v += "        array[i] <= 0;\n"
  v += "`endif\n"
  v += "    end\n"
  v += "  end\n"
  v += "\n"

  v += "endmodule\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_memi()
  with open("src/gen/memi.v", "w") as f:
    f.write(v)

