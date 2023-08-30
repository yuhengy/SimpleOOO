
## ISA

|      | op   | rs1  | rs2  | rd   |                                 |
| ---- | ---- | ---- | ---- | ---- | ------------------------------- |
| Li   | 0    |      | X    |      | Reg[rd] <- rs1                  |
| Add  | 1    |      |      |      | Reg[rd] <- Reg[rs1] + Reg[rs2]  |
| Mul  | 2    |      |      |      | Reg[rd] <- Reg[rs1] * Reg[rs2]  |
| Ld   | 3    |      | X    |      | Reg[rd] <- Mem[Reg[rs1]]        |
| Br   | 4    |      |      | X    | If (Reg[rs2]==0) PC <- PC + rs1 |

