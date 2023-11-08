#! /bin/csh -f

# Set environment variables for use in other scripts
#
if ($?DEBUG_LEVEL == 0) then
    setenv DEBUG_LEVEL 2
endif
if ($DEBUG_LEVEL > 3) set time = 1    # if moderate, time each command


# Set command tracing on if the debugging level is high enough
#
if (($DEBUG_LEVEL > 3) && ("$0" !~ *csh)) then
    set echo = 1                         # command tracing
endif
