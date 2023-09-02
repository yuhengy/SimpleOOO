
if __name__ == "__main__":


  import sys
  if len(sys.argv) <= 1:
    print("1 arguments needed!")
    print("Usage: " + sys.argv[0] + " experimentTag")
    exit()
  experimentTag = sys.argv[1]

  command  = "rsync -av --relative --exclude '__pycache__' --exclude '.DS_Store'"
  command += " scripts src results/%s mtlsim:PrjTheoreticalOOO/%s" \
             % (experimentTag, experimentTag)
  print("[command to run]: ", command)

  import os
  os.system(command)

