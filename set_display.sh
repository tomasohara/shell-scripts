#! /bin/csh -f

# Revise the DISPLAY variable to reflect the host
if ($?DISPLAY) then
    if ($DISPLAY == ":0.0") setenv DISPLAY ${HOST}:0.0
endif

# Record the DISPLAY environment variable
printenv DISPLAY >! ~/.current_display

