#! /bin/csh -f

# Record the current DISPLAY environment variable setting in .current_display
# so that .login can make the appropriate setting. (It will delete the file
# afterwards to avoid using a bad setting.)
#

# Revise the DISPLAY variable to reflect the host
if ($?DISPLAY) then
    if ($DISPLAY == ":0.0") setenv DISPLAY ${HOST}:0.0
endif

if (-w ~/.current_display) then
    printenv DISPLAY > ~/.current_display
endif

if ($DOMAINNAME == "crl.nmsu.edu") then
    rlogin $*
else 
    xhost +$*
    telnet.sh $*
endif

