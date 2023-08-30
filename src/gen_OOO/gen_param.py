
def gen_param(
):

  v  = ""
  v += "\n"

  v += "// STEP: Arch States\n"
  v += "`define REG_LEN       4\n"
  v += "`define REG_LEN_LOG   2\n"
  v += "`define RF_SIZE       4\n"
  v += "`define RF_SIZE_LOG   2\n"
  v += "`define MEMI_SIZE     8\n"
  v += "`define MEMI_SIZE_LOG 3\n"
  v += "`define MEMD_SIZE     4\n"
  v += "`define MEMD_SIZE_LOG 2\n"
  v += "\n"
  v += "\n"
  v += "\n"
  v += "\n"




  v += "// STEP: Inst\n"
  v += "`define INST_SIZE     6\n"
  v += "`define INST_SIZE_LOG 3\n"
  v += "`define INST_OP_LI  0\n"
  v += "`define INST_OP_ADD 1\n"
  v += "`define INST_OP_MUL 2\n"
  v += "`define INST_OP_LD  3\n"
  v += "`define INST_OP_BR  4\n"
  v += "`define INST_LEN (`INST_SIZE_LOG + `REG_LEN + 2*`RF_SIZE_LOG)\n"
  v += "`define OPCODE [`INST_LEN-1:`INST_LEN-`INST_SIZE_LOG]\n"
  v += "`define RS1    [`INST_LEN-`INST_SIZE_LOG-1:`INST_LEN-`INST_SIZE_LOG-`REG_LEN]\n"
  v += "`define RS2    [2*`RF_SIZE_LOG-1:`RF_SIZE_LOG]\n"
  v += "`define RD     [`RF_SIZE_LOG-1:0]\n"
  v += "\n"
  v += "\n"
  v += "\n"
  v += "\n"




  v += "// STEP: Micro-architecture states\n"
  v += "`define ROB_SIZE 8\n"
  v += "`define ROB_SIZE_LOG 3\n"
  v += "`define ROB_STATE_LEN 2\n"
  v += "`define IDLE        0\n"
  v += "`define STALLED     1\n"
  v += "`define READY       2\n"
  v += "`define FINISHED    3\n"
  v += "\n"
  v += "\n"
  v += "\n"
  v += "\n"




  v += "// STEP: Init state\n"
  v += "// `define INIT_RF_CUSTOMIZED\n"
  v += "// `define INIT_MEMI_CUSTOMIZED\n"
  v += "// `define INIT_MEMD_CUSTOMIZED\n"
  v += "\n"

  return v




if __name__ == "__main__":
  v = gen_param()
  with open("src/gen/param.v", "w") as f:
    f.write(v)

