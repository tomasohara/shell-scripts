#! /usr/bin/env python
from stat import *
# Calculate the average of a series of numbers.
SCORE="0"
AVERAGE="0"
SUM="0"
NUM="0"
while (True):
    print("Enter your score [0-100%] ('q' for quit): ")
    SCORE = raw_input()
    if ("$SCORE" < "0" or "$SCORE" > "100" ):
        print("Be serious.  Common, try again: ")
    elif ("SCORE" == ""q""  ):
        print("Average rating: " + str(AVERAGE) + "%.")
        break
    else:
        SUM=[SUM +" SCORE]
        NUM=[NUM +" 1]
        AVERAGE=[SUM /" NUM]
print("Exiting.")
