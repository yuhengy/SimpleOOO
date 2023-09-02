
import sys, os


if __name__ == "__main__":

  # STEP
  if len(sys.argv) <= 3:
    print("3 arguments needed!")
    print("Usage: " + sys.argv[0] + " top_verilog.v includeDir topModule define")
    exit()
  
  top_verilog = sys.argv[1]
  build_folder_name = top_verilog[4:-2].replace("/", "-")

  includeDir  = "-I%s" % sys.argv[2]
  topModule   = "-top %s" % sys.argv[3]
  if len(sys.argv) == 4:
    define = ""
  else:
    define = "+define%s" % sys.argv[4]


  # STEP: clean up
  command = "mkdir -p build"
  print("[command to run]: ", command)
  os.system(command)
  command = "rm -r build/%s" % build_folder_name
  print("[command to run]: ", command)
  os.system(command)


  # STEP: compile
  command = "echo \"\\`include \\\"%s\\\"\" > scripts/verilator/top.v" % top_verilog
  print("[command to run]: ", command)
  os.system(command)

  command = "verilator --cc --Mdir build/%s %s %s %s --prefix Vtop -Wno-fatal --trace --exe --build -j 4 %s %s" \
            % (build_folder_name,
               includeDir,
               topModule,
               define,
               os.path.join(os.getcwd(), "scripts/verilator/top.v"),
               os.path.join(os.getcwd(), "scripts/verilator/main.cpp"))
  print("[command to run]: ", command)
  os.system(command)
  
  command = "rm scripts/verilator/top.v"
  print("[command to run]: ", command)
  os.system(command)


  # STEP: run
  command = "build/%s/Vtop %s" % (build_folder_name, build_folder_name)
  print("[command to run]: ", command)
  os.system(command)

