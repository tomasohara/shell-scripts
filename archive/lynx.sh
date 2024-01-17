#! /bin/csh -f

## echo "$*"
## set echo = 1

# Parse command line
set lynx = "lynx"
set config = ""
## set args = "-cookies"
set args = ""
set LYNXDIR=$HOME/bin
if (! (-e $LYNXDIR/lynx_2.8)) set LYNXDIR=~tomohara/bin
if ($OSTYPE == linux) then
    ## set lynx = $LYNXDIR/lynx_2.8
    ## set config = "-cfg=$LYNXDIR/lynx_linux.cfg"
    ## $LYNXDIR/lynx_2.8 -cookies -use_mouse -cfg=$LYNXDIR/lynx_linux.cfg $*
    ## $LYNXDIR/lynx_2.8 -cookies -cfg=$LYNXDIR/lynx_linux.cfg $args
    ## lynx -cookies $*
else if ($OSTYPE == solaris) then
    set lynx = $LYNXDIR/lynx_solaris
    set config = "-cfg=$LYNXDIR/lynx_solaris.cfg"    
endif

# Special processing of problematic links (those w/ shell metachars)
if ("$1" == "--weather") then
    shift
    $lynx $config $args $* http://www.wunderground.com/cgi-bin/findweather/getForecast\?query=Las+Cruces%2C+NM
    exit
endif

# Invoke lynx
# set echo=1
set args = "$args $*"
$lynx $config $args
