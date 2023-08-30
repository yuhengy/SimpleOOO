
import sys, os

from gen_OOO     import gen_OOO

from gen_param   import gen_param

from gen_decode  import gen_decode
from gen_execute import gen_execute

from gen_rf      import gen_rf
from gen_memi    import gen_memi
from gen_memd    import gen_memd


def write_file(file, content):
  with open(file, "w") as f:
    f.write(content)




def gen(
  output_dir,
  VERSION=1
):

  v = gen_OOO(VERSION)
  write_file(output_dir + "/OOO.v", v)

  v = gen_param()
  write_file(output_dir + "/param.v", v)

  v = gen_decode()
  write_file(output_dir + "/decode.v", v)
  v = gen_execute()
  write_file(output_dir + "/execute.v", v)

  v = gen_rf()
  write_file(output_dir + "/rf.v", v)
  v = gen_memi()
  write_file(output_dir + "/memi.v", v)
  if VERSION==1:
    pass
  else:
    v = gen_memd()
    write_file(output_dir + "/memd.v", v)




if __name__ == "__main__":

  if len(sys.argv) <= 1:
    print("1 arguments needed!")
    print("Usage: " + sys.argv[0] + " output_dir")
    exit()
  
  output_dir = sys.argv[1]
  if os.path.exists(output_dir):
    print("output_dir %s exists!" % output_dir)
    exit()
  
  command = "mkdir %s" % output_dir
  os.system(command)

  gen(output_dir)

