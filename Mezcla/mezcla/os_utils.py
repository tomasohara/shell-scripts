#! /usr/bin/env python
#
# Functions for operating system related access, such as running command or
# getting environment values.
#
# TODO:
# - Move functions from system.py here.
#

"""OS utilities: mainly wrappers around os package"""

# Standard modules
import os

# Local modules
from mezcla import debug
from mezcla import system


def split_extension(path):
    """Returns basename and extension for PATH"""
    result = os.path.splitext(path)
    try:
        filename_proper, ext = result
        debug.assertion(system.remove_extension(path) == filename_proper)
        debug.assertion(system.get_extension(path) == ext[1:])
    except:
        pass
    debug.trace(5, f"split_extension({path}) => {result}")
    return result
