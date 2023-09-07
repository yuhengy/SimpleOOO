
# Run everything with `pwd` == TheoreticalOOO or /vagrant


## STEP1: Simulate the verilog with verilator
#  The waveform is generated at `build//ISA-ISA/myVCD.vcd`
# python3 scripts/verilator/run.py src/ISA/ISA.v src/ISA ISA +INIT_RF_CUSTOMIZED+INIT_MEMI_CUSTOMIZED+REG_LEN=4

