#! /usr/bin/env python
#
## Miscellaneous mathplotlib utility functions
#

"""Plotting utility functions"""

# Standard modules
# TODO

# Installed modules
import matplotlib.pyplot as plt

# Local modules
from mezcla import debug
from mezcla import system


def reset_plot():
    """Reset the mathplotlib state"""
    debug.trace(4, "reset_plot()")
    # Note: See https://stackoverflow.com/questions/741877/how-do-i-tell-matplotlib-that-i-am-done-with-a-plot
    # TODO: Make sure no other state retained

    # Clear the axes
    plt.cla()

    # Clear the figure
    plt.clf()

    # Close all plot figures
    plt.close('all')
    
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    system.print_error("Warning: Not intended for direct invocation.")
