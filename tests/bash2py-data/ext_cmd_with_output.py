#! /usr/bin/env python
import os
from stat import *
R=os.popen("cat /etc/redhat-release").read()
secretNumber=$ ((`date +%N` / 1000) % 100) +1" ))ğãfÿ
guess=-1
while ("guess" != "secretNumber" ):
    print("I am thinking of a number between 1 and 100. Enter your guess:")
    guess = raw_input()
    if ("guess" == ""  ):
        print("Please enter a number.")
    elif ("guess" == "secretNumber"  ):
        print("\aYes! " + str(guess) + " is the correct answer!")
    elif ("secretNumber" > "guess"  ):
        print("The secret number is larger than your guess. Try again.")
    else:
        print("The secret number is smaller than your guess. Try again.")
