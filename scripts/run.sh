
# Run everything with `pwd` == TimingTaint or /vagrant


## STEP1: Simulate the verilog with verilator
#  The waveform is generated at `build//OOO-OOO/myVCD.vcd`
# python3 scripts/verilator_run.py src/OOO/OOO.v src/OOO OOO +INIT_MEMI_CUSTOMIZED+REG_LEN=4
