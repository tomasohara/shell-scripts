#! /usr/bin/env python
import os
from stat import *
x=os.popen("ls -la").read()
exec("ls -la")
exec(os.popen("prowler a.xml 1 2").read())
