import os

path = 'E:\\ECE 554\\final\\hw'

files = os.listdir(path)

for f in files:
    if f.endswith(".sv") & ~f.endswith("_tb.sv"):
        print(f)