#! /usr/bin/env python
import os
from stat import *
exec(os.popen("prowler " + os.path.expanduser("~/owlFileSend.xml")).read())
print(DATADIODE_SPEED)
