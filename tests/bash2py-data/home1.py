#! /usr/bin/env python
import os,subprocess
from stat import *
SUBDIR="ijdavis"
os.environ['SUBDIR'] = SUBDIR
_rc = subprocess.call([os.path.expanduser("~/bin/args"),"abc"]) | _rc = subprocess.call(["grep","abc"])
