#! /usr/bin/env python
import os,subprocess
from stat import *
# Cleanup
# Run as root, of course.
os.chdir("/var/log")
_rc = subprocess.call("cat /dev/null",shell=True,stdout=file('messages','wb'))

_rc = subprocess.call("cat /dev/null",shell=True,stdout=file('wtmp','wb'))

print("Log files cleaned up.")
