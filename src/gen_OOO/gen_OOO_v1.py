
import sys, os

from gen import gen


if __name__ == "__main__":
  output_dir = "src/OOO_v1"
  
  if os.path.exists(output_dir):
    print("output_dir %s exists!" % output_dir)
    exit()
  
  command = "mkdir %s" % output_dir
  os.system(command)

  gen(output_dir, VERSION=1)

