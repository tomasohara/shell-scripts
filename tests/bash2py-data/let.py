#! /usr/bin/env python
from stat import *
# int-or-string.sh
a=2334
# Integer.
"a +"= 1
print("a = " + str(a) + " ")
# a = 2335
print()
# Integer, still.
b=a/23/BB
# Substitute "BB" for "23".
# This transforms $b into a string.
print("b = " + str(b))
# b = BB35
b=""

# Declaring it an integer doesn't help.
print("b = " + str(b))
# b = BB35
"b +"= 1
# BB35 + 1
print("b = " + str(b))
# b = 1
print()
# Bash sets the "integer value" of a string to 0.
c="BB34"
print("c = " + str(c))
# c = BB34
d=c/BB/23
# Substitute "23" for "BB".
# This makes $d an integer.
print("d = " + str(d))
# d = 2334
"d +"= 1
# 2334 + 1
print("d = " + str(d))
# d = 2335
print()
# What about null variables?
e=""
# ... Or e="" ... Or e=
print("e = " + str(e))
# e =
"e +"= 1
# Arithmetic operations allowed on a null variable?
print("e = " + str(e))
# e = 1
print()
# Null variable transformed into an integer.
# What about undeclared variables?
print("f = " + str(f))
# f =
"f +"= 1
# Arithmetic operations allowed?
print("f = " + str(f))
# f = 1
print()
# Undeclared variable transformed into an integer.
#
# However ...
"f /"= undecl_var
# Divide by zero?
#   let: f /= : syntax error: operand expected (error token is " ")
# Syntax error! Variable $undecl_var is not set to zero here!
#
# But still ...
"f /"= 0
#   let: f /= 0: division by 0 (error token is "0")
# Expected behavior.
#  Bash (usually) sets the "integer value" of null to zero
#+ when performing an arithmetic operation.
#  But, don't try this at home, folks!
#  It's undocumented and probably non-portable behavior.
# Conclusion: Variables in Bash are untyped,
#+ with all attendant consequences.
exit(_rc)
