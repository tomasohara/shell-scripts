#! /usr/bin/env python
import subprocess
from stat import *
count=1
done=0
while (count <= 9 ):
    _rc = subprocess.call(["sleep",1])
    count++ 
    if (count == 5  ):
        continue
    print(str(count))
print("Finished")
