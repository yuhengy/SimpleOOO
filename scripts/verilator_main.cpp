#include <verilated.h>        // Defines common routines
#include "verilated_vcd_c.h"  // vcd
#include "Vtop.h"             // From Verilating "top.v"


#define SIMU_CYCLE 1000


uint64_t sc_time = 0;
double sc_time_stamp() {
    return sc_time;
}


int main(int argc, char** argv) {

  // STEP init module
  Vtop *top;
  top = new Vtop;

  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp;
  tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open(("build/" + (std::string)argv[1] + "/myVCD.vcd").c_str());


  // STEP reset
  top->clk = 0;
  top->rst = 1;
  for (int i = 0; i < 9; i++) {
    top->clk = top->clk ? 0 : 1;
    top->eval();
    sc_time++;
    tfp->dump((double)sc_time);
  }


  // STEP simu
  top->rst = 0;
  for (int i = 0; i < SIMU_CYCLE; i++) {
    top->clk = top->clk ? 0 : 1;
    top->eval();
    sc_time++;
    tfp->dump((double)sc_time);
  }


  // STEP finish
  tfp->close();
  top->final();
  delete top;
}

