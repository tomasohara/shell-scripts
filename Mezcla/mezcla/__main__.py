#! /usr/bin/env python
#
# Note: Test for working around ":double import" issue. See
#    See https://stackoverflow.com/questions/43393764/python-3-6-project-structure-leads-to-runtimewarning
# Also see
#    https://stackoverflow.com/questions/4042905/what-is-main-py
#

"""Entry point for mezcla"""

# Standard module(s)
## OLD
## import os
## import re
## import sys

# Installed modules
import mezcla
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Contants
TL = debug.TL

if __name__ == '__main__':
    system.print_error(f"Warning: {__file__} is not intended as standalone.")
    file_path = system.real_path(gh.dirname(__file__))
    debug.trace(TL.USUAL, f"Version: {mezcla.__VERSION__}")
    debug.trace(TL.USUAL, f"Install path: {file_path}")

    # Derive module name
    # ex: /home/tomohara/python/Mezcla/mezcla/__main__.py => "mezcla"
    module = "module"
    sep = my_re.escape(system.path_separator())
    match = my_re.search(fr"([^{sep}]*){sep}[^{sep}]*$", __file__)
    if match:
        module = match.group(1)
    system.print_error(f"Likewise for the package (e.g., via 'python -m {module}')\n")
