#! /usr/bin/env python
from stat import *
secretNumber=$ ((`date +%N` / 1000) % 100) +1" ))	_‹ÿ
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
