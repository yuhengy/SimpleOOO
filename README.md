
# TheoreticalOOO

Simplest Out-of-Order processors to demonstrate the re-ordering scheme for security analysis.
These processors only exist in theory because they are far from practical synthesizable processors.




## Why Do We Need TheoreticalOOO?

The re-ordering scheme in the Out-of-Order processors has been well-studied to improve the performance.
However, after Spectre came out, people started to re-understand the re-ordering scheme, with a mindset of security.
We wonder: **Could we systematically analyze the security of the re-ordering scheme?**

This repo provides Out-of-Order processors with the simplest re-ordering schemes, which highlight the most critical ideas of the re-ordering schemes.
We also apply state-of-art Spectre defenses (e.g., invisiSpec, STT, GhostMinion) on these processors, which also only highlights the most critical ideas of the defenses.
This could be a start point for researchers to study the security with various verification tools (e.g., formal verification, fuzzing).

**Only after we can efficiently analyze these theoretical processors, we could move on to more practical processors.**




## File Organization

- scripts
  - rsync: copy of the repo to a server
  - verilator: simulate the verilog modules
- src
  - ISA: the ISA specification
  - OOO_v1: simple Out-of-Order processor
    - veri: files to assist JasperGold verification




## Environment Setup & Run Examples

We provide Dockerfile to run verilator.
While, you need your own JasperGold server to run verifications.
Then, you can check `scripts/run.sh` for run examples.


### Docker

You can create a docker container (and delete it afterwards) with the following commands, while `pwd` == TheoreticalOOO:

1. Run `docker-compose up -d` to build up the container.
2. Run `docker-compose exec env bash` to log in to the container.
3. Run `docker-compose stop` to pause and `docker-compose up -d` to relaunch the container.
4. Run `docker-compose down --rmi all` to clean up. (`docker system prune` can further clean up the cache, including your cache for other projects.)






## ISA

|      | op   | rs1  | rs2  | rd   |                                 |
| ---- | ---- | ---- | ---- | ---- | ------------------------------- |
| Li   | 0    |      | X    |      | Reg[rd] <- rs1                  |
| Add  | 1    |      |      |      | Reg[rd] <- Reg[rs1] + Reg[rs2]  |
| Mul  | 2    |      |      |      | Reg[rd] <- Reg[rs1] * Reg[rs2]  |
| Ld   | 3    |      | X    |      | Reg[rd] <- Mem[Reg[rs1]]        |
| Br   | 4    |      |      | X    | If (Reg[rs2]==0) PC <- PC + rs1 |




## Different Versions of OOO

- OOO_v1:
  - [PIPELINE1] One inst is fetched each cycle
  - Always predict pc+4
  - The fetched inst is pushed into 8-entry ROB, the fetch is stalled if ROB is full
  - During the push, rename table will be checked to collect the operands in three ways:
    - read from register
    - forwared from ROB entries whose state is FINSIHED
    - mark the operand as STALL
  - [PIPELINE2] For each entry in the ROB, if the operands are ready, issue it by changing the state to READY.
  - [PIPELINE3] Execute READY entries
    - Each ROB entry is connected to a separated ALU+mem module so that 8 entries will not has contention
    - Both ALU and MEM takes 0 cycle to finish.
  - [PIPELINE4] For each FINISHED ROB entry, check whether it can forward data to younger inst.
  - Commit the head of ROB


- OOO_v2:
  - All ROB entries share an alu and memory, prioritize ROB with smaller ID




## Correctness Verification with JasperGold

We prove the correctness of a OOO processor against the ISA specification using JasperGold.

- File "src/OOO_v1/veri/correct.v" initiate ISA and OOO and compare the architectural states and generate signals to verify (e.g., `same_init_state`, `correct`, `live`)
- File "src/OOO_v1/veri/correct.tcl" includes commands send to jaspergold, such as:
  - arbitrary initial architectural states
  - assume the architectural state of ISA and OOO are the same
  - assert the correctness and liveness property
  - call JasperGold prove engine with `prove -all`
- Run `jg src/OOO_v1/veri/correct.tcl` will start the proof

