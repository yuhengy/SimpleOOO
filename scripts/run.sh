
# Run everything with `pwd` == SimpleOOO or /vagrant


## STEP1: Simulate the verilog with verilator
## ISA: The waveform is generated at `build/ISA-ISA/myVCD.vcd`
# python3 scripts/verilator/run.py src/ISA/ISA.v src ISA +INIT_RF_CUSTOMIZED+INIT_MEMI_CUSTOMIZED+REG_LEN=4
## OOO: The waveform is generated at `build/OOO_v1-OOO/myVCD.vcd`
# python3 scripts/verilator/run.py src/OOO_v1/OOO.v src OOO +INIT_RF_CUSTOMIZED+INIT_MEMI_CUSTOMIZED+REG_LEN=4


## STEP2: Verify the correctness and liveness of OOO_v1 against the ISA
# jg src/OOO_v1/veri/correct.tcl

