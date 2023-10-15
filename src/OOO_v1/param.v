
`ifndef OOO_V1_PARAM_V
`define OOO_V1_PARAM_V


`include "ISA/param.v"


// STEP: Micro-architecture states
`define ROB_SIZE 8
`define ROB_SIZE_LOG 3
`define ROB_STATE_LEN 2
`define IDLE        0
`define STALLED     1
`define READY       2
`define FINISHED    3

`endif

