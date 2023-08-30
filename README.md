
## ISA

|      | op   | rs1  | rs2  | rd   |                                 |
| ---- | ---- | ---- | ---- | ---- | ------------------------------- |
| Li   | 0    |      | X    |      | Reg[rd] <- rs1                  |
| Add  | 1    |      |      |      | Reg[rd] <- Reg[rs1] + Reg[rs2]  |
| Mul  | 2    |      |      |      | Reg[rd] <- Reg[rs1] * Reg[rs2]  |
| Ld   | 3    |      | X    |      | Reg[rd] <- Mem[Reg[rs1]]        |
| Br   | 4    |      |      | X    | If (Reg[rs2]==0) PC <- PC + rs1 |




## Different versions of cpu_ooo

- OOO_v1:
  - [PIPELINE1] One inst is fetched each cycle
  - Always predict pc+4
  - The fetched inst is pushed into 8-entry ROB, the fetch is stalled if ROB is full
  - During the push, rename table will be checked to collect the operands in three ways:
    - read from register
    - forwared from ROB entries whose state is FINSIHED
    - mark the operand as STALL
  - [PIPELINE2] For each entry in the ROB, if the operands are ready, issue it.
  - Each ROB entry is connected to a separated ALU+mem module so that 8 entries will not has contention
  - Both ALU and MEM takes 0 cycle to finish.
  - [PIPELINE4] For each FINISHED ROB entry, check whether it can forward data to younger inst.
  - Commit the head of ROB


- OOO_v2:
  - All ROB entries share an alu and memory, prioritize ROB with small ID

