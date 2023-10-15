
# Input design
analyze -incdir src -sv src/OOO_v1/veri/correct.v
elaborate -top veri_corrrect -bbox_mul 256
clock clk
reset rst -non_resettable_regs 0


# Symbolic states
abstract -init_value {OOO.rf_instance.array}
abstract -init_value {ISA.rf}
abstract -init_value {OOO.memi_instance.array}
abstract -init_value {ISA.memi}
abstract -init_value {OOO.memd}
abstract -init_value {ISA.memd}


# Same initial state
assume {same_init_state}


# find incorrect example
assert {correct}


# find unlive example
assert {live}


prove -all

