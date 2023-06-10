#! /usr/bin/env python
from stat import *
#Define bash global variable
#This variable is global and can be used anywhere in this bash script
VAR="global variable"
def bash () :

    #Define bash local variable
    #This variable is local to bash function only
    VAR="local variable"
    
    print(VAR)

print(VAR)
bash()
# Note the bash global variable did not change
# "local" is bash reserved word
print(VAR)
