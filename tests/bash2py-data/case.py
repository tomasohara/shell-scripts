#! /usr/bin/env python
from stat import *
print("Which fruit do you like most?")
fruit = raw_input()

if ( fruit == 'apple'):
    print("Mmmmh... I like those!")
elif ( fruit == 'banana'):
    print("Hm, a bit awry, no?")
elif ( fruit == 'orange' or fruit == 'tangerine'):
    print("Eeeks! I dont like those! Go away!")
    exit(1)
else:
    print("Unknown fruit - sure it isn't toxic?")
