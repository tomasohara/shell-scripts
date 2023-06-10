#! /usr/bin/env python
import os,subprocess
from stat import *
_rc = subprocess.call([os.popen("basename \""+str(FILENAME)+"\"").read()])
