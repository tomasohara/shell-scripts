#! /usr/bin/env python
import sys,os
from stat import *
FILE=sys.argv[1]
if ((os.path.isfile(FILE ) and S_ISREG(os.stat(FILE ).st_mode)) ):
    print("File " + str(FILE) + " exists.")
else:
    print("File " + str(FILE) + " does not exist.")
if (S_ISBLK(os.stat(FILE ).st_mode) ):
    print("File " + str(FILE) + " exists and is a block-special file.")
else:
    print("Not a block-special file")
