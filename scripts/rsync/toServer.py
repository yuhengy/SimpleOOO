
if __name__ == "__main__":


  import sys
  if len(sys.argv) <= 2:
    print("2 arguments needed!")
    print("Usage: " + sys.argv[0] + " server_name experimentTag")
    exit()
  server_name = sys.argv[1]
  experimentTag = sys.argv[2]

  command  = "rsync -av --relative --exclude '__pycache__' --exclude '.DS_Store'"
  command += " scripts src results/%s %s:PrjSimpleOOO/%s" \
             % (experimentTag, server_name, experimentTag)
  print("[command to run]: ", command)

  import os
  os.system(command)

