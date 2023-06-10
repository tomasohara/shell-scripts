#! /usr/bin/env python
import sys
from stat import *
# This script prints a message about your weight if you give it your
# weight in kilos and height in centimeters.
weight=str(sys.argv[1])
height=str(sys.argv[2])
idealweight=[height - 110]
if (weight <= idealweight  ):
    print("You should eat a bit more fat.")
else:
    print("You should eat a bit more fruit.")
