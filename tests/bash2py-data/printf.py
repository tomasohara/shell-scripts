#! /usr/bin/env python
import os
from stat import *
# printf demo
PI=3.14159265358979

# Read-only variable, i.e., a constant.
DecimalConstant=31373

Message1="Greetings,"
Message2="Earthling."
print()
print( "Pi to 2 decimal places = %1.2f" % (PI) )

print()
print( "Pi to 9 decimal places = %1.9f" % (PI) )

# It even rounds off correctly.
print( "\n" )

# Prints a line feed,
# Equivalent to 'echo' . . .
print( "Constant = \t%d\n" % (DecimalConstant) )

# Inserts tab (\t).
print( "%s %s \n" % (Message1, Message2) )

print()
# ==========================================#
# Simulation of C function, sprintf().
# Loading a variable with a formatted string.
print()
Pi12=os.popen("printf \"%1.12f\" "+str(PI)).read()
print("Pi to 12 decimal places = " + str(Pi12))
# Roundoff error!
Msg=os.popen("printf \"%s %s n\" "+str(Message1)+" "+str(Message2)).read()
print(Msg)
print(Msg)
#  As it happens, the 'sprintf' function can now be accessed
#+ as a loadable module to Bash,
#+ but this is not portable.
exit(0)
