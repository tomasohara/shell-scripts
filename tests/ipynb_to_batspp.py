#! /usr/bin/env python

import sys
import os

filename_arg = sys.argv
file2convert = filename_arg[1]

RENAME_COMMAND = f"mv {file2convert} {file2convert}.batspp"