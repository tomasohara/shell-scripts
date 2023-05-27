#! /usr/bin/env python
import os,subprocess
from stat import *
os.environ['x'] = "2asdfasdbxcb"
os.environ['y'] = "3asdfasdzsdgzs"
# Calculate the average of a series of numbers.
SCORE="0"
AVERAGE="0"
SUM="0"
# comment at end of line
# comment at beginning of line
NUM="0"
foo=os.popen("cat /tmp/baz").read()
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
# Cleanup
# Run as root, of course.
os.chdir("/var/log")
_rc = subprocess.call("cat /dev/null",shell=True,stdout=file('messages','wb'))

_rc = subprocess.call("cat /dev/null",shell=True,stdout=file('wtmp','wb'))

print("Log files cleaned up.")
Msg=os.popen("printf \"%s %s n\" "+str(Message1)+" "+str(Message2)).read()
print(Msg)
print(Msg)
