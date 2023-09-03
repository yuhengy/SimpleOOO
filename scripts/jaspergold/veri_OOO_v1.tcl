
# Input design
analyze -sv src/veri_OOO_v1.v
elaborate -top veri_OOO -bbox_mul 256
clock clk -both_edges
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
assert {!incorrect}


# find unlive example
assert {live}


prove -all

