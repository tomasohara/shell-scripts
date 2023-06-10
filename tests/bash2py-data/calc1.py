#! /usr/bin/env python
import os,subprocess
from stat import *
_rc = subprocess.call(["clear"])
sum=0
i="y"
print(" Enter one no.")
n1 = raw_input()
print("Enter second no.")
n2 = raw_input()
while (i == ""y"" ):
    print("1.Addition")
    print("2.Subtraction")
    print("3.Multiplication")
    print("4.Division")
    print("Enter your choice")
    ch = raw_input()
    
    if ( ch == '1'):
        sum=os.popen("expr "+str(n1)++str(n2)).read()
        print("Sum = " + str(sum))
    elif ( ch == '2'):
        sum=os.popen("expr "+str(n1)+" - "+str(n2)).read()
        print("Sub = " + str(sum))
    elif ( ch == '3'):
        sum=os.popen("expr "+str(n1)+" * "+str(n2)).read()
        print("Mul = " + str(sum))
    elif ( ch == '4'):
        sum=os.popen("expr "+str(n1)+" / "+str(n2)).read()
        print("Div = " + str(sum))
    else:
        print("Invalid choice")
    print("Do u want to continue (y/n)) ?")
    i = raw_input()
    if (i != ""y""  ):
        exit()
