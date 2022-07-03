# cyc_setup.bash: Bash initialization file for using Cyc
#
# TODO: convert $* to "$@" throughout, as appropriate
# 
# Uncomment the following line for tracing:
# set -o xtrace

export PERLLIB
alias perl_='perl -Ssw'
export MANPATH="$HOME/HELP:$MANPATH"
#
# Hack for problem under grampa with readkey
if [ "$HOST" = "grampa" ]; then export null_eof=1; fi

# Settings for Cyc perl scripts (also for some aliases/functions below)
# note: The port can either be the actual TCP port for the API (eg, 3641)
# or the port offset for the Cyc server (e.g., 40). The latter is now
# preferred to support the aliases involving localhostNN.
# Use port=0 for 3600 (i.e., localhost0).
#
## export port=3641
## if [ "$HOST" = "kyle" ]; then export port=3661; fi
export port=40
if [ "$HOST" = "kyle" ]; then export port=60; fi
if [ "$HOST" = "arahomot" ]; then export port=00; fi
export cyclist="OHara"

# Cyc related aliases
## export port=3641
alias odc='java -mx128m com.cyc.odke.Main $HOST 3614'
alias odc_='java -mx128m com.cyc.odke.Main $HOST'
alias odui='java -mx128m com.cyc.odke.Main $HOST 3654'
alias odui_='java -mx128m com.cyc.odke.Main $HOST'
#
alias od_0='java com.cyc.odke.Main localhost +0  OHara od' #OpenDir, offset 0
alias od40='java com.cyc.odke.Main localhost +40 OHara od' #OpenDir, offset 40
alias ls_0='java com.cyc.odke.Main localhost +0  OHara ls' #ProductLinking, offset 0
alias ls40='java com.cyc.odke.Main localhost +40 OHara ls' #ProductLinking, offset 40

function cyc_allegro_ () { emacs --eval "(setq *Port${1}* t)" -l /home/tom/.emacs.start_allegro_cyc & 
}
alias cyc_allegro='cyc_allegro_ 40'
alias cyc_allegro20='cyc_allegro_ 20'
alias cyc_allegro60='cyc_allegro_ 60'

function cyc_c_ () { emacs --eval "(setq *Port${1}* t)" -l /home/tom/.emacs.start_cyc & 
}
alias cyc_c='cyc_c_ 00'
alias cyc20='cyc_c_ 20'
alias cyc60='cyc_c_ 60'

# Aliases for dumping assertions in Cyc
#
# These are wrappers around lynx invocations of the Cyc browser.
#
# NOTE: http://$HOST/cgi-bin/cyccgi/localhost$port/cg?cb-start is used
# rather than http://localhost/cgi-bin/cyccgi/localhost$port/cg?cb-start
# to work around problem with not being able to disable word-wrap.
# This works for local machines where the user is typically logged in via
# localhost (i.e., 127.0.0.1 in the Login page) and thus customizations 
# only associated with that and not the real machine IP address
# (e.g., 207.207.8.123 for grampa.cyc.com).
#
function dump_assertions () { lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-total&"$1 >| .$1.data; less .$1.data 
}
function dump_assertions_ () { lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-total&"$2 >| .$2.data; less .$2.data 
}
function dump_mt () { lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-ist&"$1 >| .$1.data; less .$1.data 
}
function dump_mt_ () { lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-ist&"$2 >| .$2.data; less .$2.data 
}
#
# Variations for handling overly-large MT's
function dump_big_mt () { nice -19 lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-total&"$1 >| .$1.data; lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-ist&"$1 >> .$1.data; less .$1.data 
}
function dump_big_mt_ () { nice -19 lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-total&"$2 >| .$2.data; lynx -dump -nolist -width=512 "http://$HOST/cgi-bin/cyccgi/cg?cb-c-ist&"$2 >> .$2.data; less .$2.data 
}

# Aliases for accessing the System Information page
# NOTE: $HOST is used instead of localhost so that the system login is not required
# provided the-cyclist is set (which is done via cyc_eval.perl)
#
## function system_info () { lynx -dump -nolist 'http://localhost/cgi-bin/cyccgi/cg?cb-system' | less }
## function system_info_ () { lynx -dump -nolist 'http://localhost/cgi-bin/cyccgi/localhost'$1'/cg?cb-system' | less }
function system_info () { cyc_eval.perl 666 > /dev/null; lynx -dump -nolist 'http://localhost/cgi-bin/cyccgi/cg?cb-system' | less 
}
function system_info_ () { cyc_eval.perl -port=$1 666 > /dev/null; lynx -dump -nolist 'http://localhost/cgi-bin/cyccgi/localhost'$1'/cg?cb-system' | less 
}
function old_system_info () { lynx -dump -nolist 'http://'$HOST'/cgi-bin/cyccgi/cg?cb-system' | less 
}
function old_system_info_ () { lynx -dump -nolist 'http://'$HOST'/cgi-bin/cyccgi/localhost'$1'/cg?cb-system' | less 
}
function remote_system_info () { lynx -dump -nolist 'http://'$1'/cgi-bin/cyccgi/localhost'$2'/cg?cb-system' | less 
}
alias system_info40='system_info_ 40'
alias kyle_system_info='remote_system_info kyle 60'
alias kyle_telnet='telnet.sh kyle'

