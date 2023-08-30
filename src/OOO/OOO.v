
`include "param.v"

`include "decode.v"
`include "execute.v"

`include "rf.v"
`include "memi.v"
`include "memd.v"


module OOO(
  input clk,
  input rst
);
  integer i, j;

  // STEP: PC
  reg  [`MEMI_SIZE_LOG-1:0] F_pc;
  wire [`MEMI_SIZE_LOG-1:0] F_next_pc;
  always @(posedge clk) begin
    if (rst) F_pc <= 0;
    else     F_pc <= F_next_pc;
  end




  // STEP: Fetch
  wire [`INST_LEN-1:0] F_inst;
  memi memi_instance(
    .clk(clk), .rst(rst),
    .req_addr(F_pc), .resp_data(F_inst)
  );




  // STEP: Decode
  wire [`INST_SIZE_LOG-1:0] F_opcode;

  wire                      F_rs1_used;
  wire [`REG_LEN-1      :0] F_rs1_imm;
  wire [`MEMI_SIZE_LOG-1:0] F_rs1_br_offset;
  wire [`RF_SIZE_LOG-1  :0] F_rs1;

  wire                      F_rs2_used;
  wire [`RF_SIZE_LOG-1  :0] F_rs2;

  wire                    F_wen;
  wire [`RF_SIZE_LOG-1:0] F_rd;
  wire                    F_rd_data_use_alu;

  wire F_mem_valid;

  wire F_is_br;

  decode decode_instance(
    .inst(F_inst),
    .opcode(F_opcode),
    .rs1_used(F_rs1_used), .rs1_imm(F_rs1_imm), .rs1_br_offset(F_rs1_br_offset), .rs1(F_rs1),
    .rs2_used(F_rs2_used), .rs2(F_rs2),
    .wen(F_wen), .rd(F_rd), .rd_data_use_alu(F_rd_data_use_alu),
    .mem_valid(F_mem_valid),
    .is_br(F_is_br)
  );




  // STEP: rf Read Write
  wire [`REG_LEN-1:0] F_rs1_data_rf;
  wire [`REG_LEN-1:0] F_rs2_data_rf;
  rf rf_instance(
    .clk(clk), .rst(rst),
    .rs1(F_rs1), .rs1_data(F_rs1_data_rf),
    .rs2(F_rs2), .rs2_data(F_rs2_data_rf),
    .wen(C_valid && C_wen), .rd(C_rd), .rd_data(C_rd_data)
  );




  // STEP: PC Prediction
  wire                      F_predicted_taken;
  wire [`MEMI_SIZE_LOG-1:0] F_next_pc;

  assign F_predicted_taken = 1'b0;
  assign F_next_pc = (C_valid && C_squash)?           C_next_pc :
                     ROB_full?                        F_pc :
                     (F_is_br && F_predicted_taken)?  F_pc+F_rs1_br_offset :
                                                      F_pc+1;




  // STEP: Rename Table
  reg  [`RF_SIZE-1     :0] renameTB_valid;
  reg  [`ROB_SIZE_LOG-1:0] renameTB_ROBlink [`RF_SIZE-1:0];

  wire                F_rs1_stall;
  wire [`REG_LEN-1:0] F_rs1_data;
  wire                F_rs2_stall;
  wire [`REG_LEN-1:0] F_rs2_data;

  // STEP.: update rename table entries
  wire renameTB_clearEntry, renameTB_addEntry, renameTB_clearAddConflict;
  assign renameTB_clearEntry = C_valid && C_wen && (renameTB_ROBlink[C_rd]==ROB_head);
  assign renameTB_addEntry   = !ROB_full && F_wen;
  assign renameTB_clearAddConflict = renameTB_addEntry && renameTB_clearEntry && F_rd==C_rd;
  always @(posedge clk) begin
    if (rst)        begin 
      for (i=0; i<`RF_SIZE; i=i+1) begin
        renameTB_valid[i]         <= 1'b0;
      end
    end

    else if (C_squash && C_valid)
      for (i=0; i<`RF_SIZE; i=i+1) begin
        renameTB_valid[i]         <= 1'b0;
      end

    else begin
      if (renameTB_clearEntry && !renameTB_clearAddConflict) begin
        renameTB_valid        [C_rd] <= 1'b0;
      end

      if (renameTB_addEntry) begin
        renameTB_valid[F_rd]         <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (!ROB_full && F_wen) renameTB_ROBlink[F_rd] <= ROB_tail;
  end


  // STEP.: use renameTB to read data from either reg or ROB or stall
  assign F_rs1_stall =
    F_rs1_used && renameTB_valid[F_rs1] &&
    !(ROB_state[renameTB_ROBlink[F_rs1]]==`FINISHED);
  assign F_rs2_stall =
    F_rs2_used && renameTB_valid[F_rs2] &&
    !(ROB_state[renameTB_ROBlink[F_rs2]]==`FINISHED);

  assign F_rs1_data = renameTB_valid[F_rs1]?
                      ROB_rd_data[renameTB_ROBlink[F_rs1]]:
                      F_rs1_data_rf;
  assign F_rs2_data = renameTB_valid[F_rs2]?
                      ROB_rd_data[renameTB_ROBlink[F_rs2]]:
                      F_rs2_data_rf;




  // STEP: ROB
  reg  [`ROB_STATE_LEN-1:0] ROB_state [`ROB_SIZE-1:0];

  reg  [`MEMI_SIZE_LOG-1:0] ROB_pc [`ROB_SIZE-1:0];
  reg  [`INST_SIZE_LOG-1:0] ROB_op [`ROB_SIZE-1:0];

  reg  [`ROB_SIZE-1     :0] ROB_rs1_stall;
  reg  [`REG_LEN-1      :0] ROB_rs1_imm       [`ROB_SIZE-1:0];
  reg  [`MEMI_SIZE_LOG-1:0] ROB_rs1_br_offset [`ROB_SIZE-1:0];
  reg  [`REG_LEN-1      :0] ROB_rs1_data      [`ROB_SIZE-1:0];
  reg  [`ROB_SIZE_LOG-1 :0] ROB_rs1_ROBlink   [`ROB_SIZE-1:0];

  reg  [`ROB_SIZE-1     :0] ROB_rs2_stall;
  reg  [`REG_LEN-1      :0] ROB_rs2_data      [`ROB_SIZE-1:0];
  reg  [`ROB_SIZE_LOG-1 :0] ROB_rs2_ROBlink   [`ROB_SIZE-1:0];

  reg  [`ROB_SIZE-1     :0] ROB_mem_valid;

  reg  [`ROB_SIZE-1     :0] ROB_wen;
  reg  [`RF_SIZE_LOG-1  :0] ROB_rd      [`ROB_SIZE-1:0];
  reg  [`ROB_SIZE-1     :0] ROB_rd_data_use_alu;
  reg  [`REG_LEN-1      :0] ROB_rd_data [`ROB_SIZE-1:0];

  reg  [`ROB_SIZE-1     :0] ROB_is_br;
  reg  [`ROB_SIZE-1     :0] ROB_predicted_taken;
  reg  [`ROB_SIZE-1     :0] ROB_taken;
  reg  [`MEMI_SIZE_LOG-1:0] ROB_next_pc [`ROB_SIZE-1:0];

  reg  [`ROB_SIZE_LOG-1:0] ROB_head;
  reg  [`ROB_SIZE_LOG-1:0] ROB_tail;

  wire ROB_full;
  wire ROB_empty;

  always@(posedge clk) begin
    if (rst) begin
      for (i=0; i<`ROB_SIZE; i=i+1) begin
        ROB_state[i] <= `IDLE;
      end
      ROB_head <= 0;
      ROB_tail <= 0;
    end

    // STEP.1: squash
    else if (C_valid && C_squash) begin
      for (i=0; i<`ROB_SIZE; i=i+1) begin
        ROB_state[i] <= `IDLE;
      end
      ROB_head <= 0;
      ROB_tail <= 0;
    end

    else begin
      // STEP.2: push
      if (!ROB_full) begin
        ROB_state[ROB_tail] <= `STALLED;

        ROB_pc[ROB_tail] <= F_pc;
        ROB_op[ROB_tail] <= F_opcode;

        ROB_rs1_stall      [ROB_tail] <= F_rs1_stall;
        ROB_rs1_imm        [ROB_tail] <= F_rs1_imm;
        ROB_rs1_br_offset  [ROB_tail] <= F_rs1_br_offset;
        ROB_rs1_data       [ROB_tail] <= F_rs1_data;
        ROB_rs1_ROBlink    [ROB_tail] <= renameTB_ROBlink[F_rs1];

        ROB_rs2_stall      [ROB_tail] <= F_rs2_stall;
        ROB_rs2_data       [ROB_tail] <= F_rs2_data;
        ROB_rs2_ROBlink    [ROB_tail] <= renameTB_ROBlink[F_rs2];

        ROB_wen            [ROB_tail] <= F_wen;
        ROB_rd             [ROB_tail] <= F_rd;
        ROB_rd_data_use_alu[ROB_tail] <= F_rd_data_use_alu;

        ROB_mem_valid      [ROB_tail] <= F_mem_valid;

        ROB_is_br          [ROB_tail] <= F_is_br;
        ROB_predicted_taken[ROB_tail] <= F_predicted_taken;

        ROB_tail <= ROB_tail + 1;
      end


      // STEP.3: wakeup
      for (i=0; i<`ROB_SIZE; i=i+1) begin
        if (ROB_state[i]==`STALLED &&
            !ROB_rs1_stall[i] && !ROB_rs2_stall[i])
          ROB_state [i] <= `READY;
      end


      // STEP.4: execute
      for (i=0; i<`ROB_SIZE; i=i+1) begin
        if (ROB_state[i]==`READY && ROB_exe_this_cycle[i]) begin
          ROB_rd_data [i] <= ROB_rd_data_wire;
          ROB_taken   [i] <= ROB_taken_wire;
          ROB_next_pc [i] <= ROB_next_pc_wire;

          ROB_state [i] <= `FINISHED;
        end
      end


      // STEP.5: forward
      for (i=0; i<`ROB_SIZE; i=i+1) begin
        if (ROB_state[i]==`FINISHED) begin
          for (j=0; j<`ROB_SIZE; j=j+1) begin
            if (ROB_state[j]==`STALLED && ROB_rs1_stall[j] &&
                ROB_rs1_ROBlink[j]==i[`ROB_SIZE_LOG-1:0]) begin
              ROB_rs1_stall[j] <= 1'b0;
              ROB_rs1_data[j] <= ROB_rd_data[i];
            end

            if (ROB_state[j]==`STALLED && ROB_rs2_stall[j] &&
                ROB_rs2_ROBlink[j]==i[`ROB_SIZE_LOG-1:0]) begin
              ROB_rs2_stall[j] <= 1'b0;
              ROB_rs2_data[j] <= ROB_rd_data[i];
            end
          end
        end
      end


      // STEP.6: pop
      if (C_valid) begin
        ROB_state[ROB_head] <= `IDLE;
        ROB_head <= ROB_head + 1;
      end
    end
  end

  assign ROB_full  = ROB_state[ROB_tail] != `IDLE;
  assign ROB_empty = ROB_state[ROB_head] == `IDLE;




  // STEP: Execute + Memory Read
  // STEP.X: arbitor to choose an entry in ROB
  reg [`ROB_SIZE-1:0] ROB_exe_this_cycle;
  always @(*) begin
    ROB_exe_this_cycle = 0;
    for (i=`ROB_SIZE-1; i >= 0; i=i-1)
      if (ROB_state[i]==`READY)
        ROB_exe_this_cycle = (1 << i);
  end


  // STEP.X: choose an input to execute unit
  reg [`MEMI_SIZE_LOG-1:0] ROB_pc_wire;
  reg [`INST_SIZE_LOG-1:0] ROB_op_wire;
  reg [`REG_LEN-1      :0] ROB_rs1_imm_wire;
  reg [`MEMI_SIZE_LOG-1:0] ROB_rs1_br_offset_wire;
  reg [`REG_LEN-1      :0] ROB_rs1_data_wire;
  reg [`REG_LEN-1      :0] ROB_rs2_data_wire;
  reg                      ROB_rd_data_use_alu_wire;
  reg                      ROB_is_br_wire;
  always @(*) begin
    ROB_pc_wire              = 0;
    ROB_op_wire              = 0;
    ROB_rs1_imm_wire         = 0;
    ROB_rs1_data_wire        = 0;
    ROB_rs1_br_offset_wire   = 0;
    ROB_rs2_data_wire        = 0;
    ROB_rd_data_use_alu_wire = 0;
    ROB_is_br_wire           = 0;
    for (i=0; i < `ROB_SIZE; i=i+1) begin
      ROB_pc_wire              = ROB_pc_wire              | {`MEMI_SIZE_LOG{ROB_exe_this_cycle[i]}} & ROB_pc[i];
      ROB_op_wire              = ROB_op_wire              | {`INST_SIZE_LOG{ROB_exe_this_cycle[i]}} & ROB_op[i];
      ROB_rs1_imm_wire         = ROB_rs1_imm_wire         | {`REG_LEN      {ROB_exe_this_cycle[i]}} & ROB_rs1_imm[i];
      ROB_rs1_data_wire        = ROB_rs1_data_wire        | {`REG_LEN      {ROB_exe_this_cycle[i]}} & ROB_rs1_data[i];
      ROB_rs1_br_offset_wire   = ROB_rs1_br_offset_wire   | {`MEMI_SIZE_LOG{ROB_exe_this_cycle[i]}} & ROB_rs1_br_offset[i];
      ROB_rs2_data_wire        = ROB_rs2_data_wire        | {`REG_LEN      {ROB_exe_this_cycle[i]}} & ROB_rs2_data[i];
      ROB_rd_data_use_alu_wire = ROB_rd_data_use_alu_wire |                 ROB_exe_this_cycle[i]   & ROB_rd_data_use_alu[i];
      ROB_is_br_wire           = ROB_is_br_wire           |                 ROB_exe_this_cycle[i]   & ROB_is_br[i];
    end
  end


  // STEP.X: Memory Read
  wire [`MEMD_SIZE_LOG-1:0] mem_addr;
  wire [`REG_LEN-1      :0] mem_data;
  memd memd_instance(
    .clk(clk), .rst(rst),
    .req_addr(mem_addr), .resp_data(mem_data)
  );


  // STEP.X: output from alu
  wire [`REG_LEN-1      :0] ROB_rd_data_wire;
  wire                      ROB_taken_wire;
  wire [`MEMI_SIZE_LOG-1:0] ROB_next_pc_wire;
  execute execute_instance(
    .pc(ROB_pc_wire),
    .op(ROB_op_wire),

    .rs1_imm(ROB_rs1_imm_wire),
    .rs1_br_offset(ROB_rs1_br_offset_wire),
    .rs1_data(ROB_rs1_data_wire),

    .rs2_data(ROB_rs2_data_wire),

    .mem_addr(mem_addr),
    .mem_data(mem_data),

    .rd_data_use_alu(ROB_rd_data_use_alu_wire),
    .rd_data(ROB_rd_data_wire),

    .is_br(ROB_is_br_wire),
    .taken(ROB_taken_wire),
    .next_pc(ROB_next_pc_wire)
  );




  // STEP: Commit
  wire                      C_valid;

  wire                      C_wen;
  wire [`RF_SIZE_LOG-1  :0] C_rd;
  wire [`REG_LEN-1      :0] C_rd_data;

  wire                      C_is_br;
  wire                      C_taken;
  wire                      C_squash;
  wire [`MEMI_SIZE_LOG-1:0] C_next_pc;

  assign C_valid = ROB_state[ROB_head]==`FINISHED;

  assign C_wen     = ROB_wen    [ROB_head];
  assign C_rd      = ROB_rd     [ROB_head];
  assign C_rd_data = ROB_rd_data[ROB_head];

  assign C_is_br   = ROB_is_br  [ROB_head];
  assign C_taken   = ROB_taken  [ROB_head];
  assign C_squash  = C_is_br && (ROB_predicted_taken[ROB_head] != ROB_taken[ROB_head]);
  assign C_next_pc = ROB_next_pc[ROB_head];

endmodule

