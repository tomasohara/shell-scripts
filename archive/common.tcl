#!/bin/sh
#-*-tcl-*-
# the next line restarts using wish \
exec wish "$0" -- ${1+"$@"}
#
#!/usr/local/bin/wish
#
# usage: source common.tcl
#        InitDebugging
#        ...
#           DebugOut "var=$var\n"
#        ...
#        EndDebugging

##	Initialize for debugging (or not)
#
#	global debug_level		debugging trace level
#	global debug_file		file handle for debug output
#	global use_stderr		debug output goes to stderr as well
#
# NOTE:
# - Set TCL_DEBUG to 1 to enable trace output to tcl-debug.out.
#
set debug_level 0
set debug_file ""
set use_stderr 1


# InitDebugging()
#
# Initialize settings for debugging. This opens the (optional) trace file.
#
proc InitDebugging {} {
    global debug_level debug_file use_stderr
    global env

    #	Set the defaults for debugging
    set tcl_debug 0
    set debug_file stderr
    if [info exists env(TCL_DEBUG)] {
	set tcl_debug $env(TCL_DEBUG)
	set debug_file [open "tcl-debug.out" w]
    }
    set debug_level $tcl_debug
    ## set use_stderr [expr [catch {puts stderr "Testing stderr"}] == 0]

    # Dump the debugging settings
    DebugOut "debug_level='$debug_level' debug_file='$debug_file' use_stderr='$use_stderr'"
}


# EndDebugging()
#
# Cleanup after debugging. This closes the (optional) trace file.
#
proc EndDebugging {} {
    global debug_level debug_file use_stderr

    close $debug_file
}


# DebugOut(debug_text)
#
# Display debugging text to stderr and optionally to a file
# 
# TODO: add optional time-stamp
#
proc DebugOut {text} {
    global debug_level debug_file use_stderr

    if {$debug_level > 0} {
	if {$use_stderr == 1} {
	    puts stderr "$text"
	}
	## puts $debug_file "$text"
    }

    # TEMP: If debug_file, set output to it
    if {$debug_file != "stderr"} {
	puts $debug_file "$text"
    }
}


# get_env(name, default_value)
#
# Get the value of the environment variable.
#
proc get_env {name default_value} {
    global env

    set value $default_value
    if {[info exists env($name)]} {
	set value $env($name)
    }
    DebugOut "get_env($name, $default_value) => $value"

    return $value
}


InitDebugging
