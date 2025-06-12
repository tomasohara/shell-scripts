#! /bin/csh -f

# notify.sh: Issue (mail) notification to user as a message box
#            If the previous notification is active it is removed

# set echo = 1

# Kill the previous instance of notify.tcl (which uses the wish shell)
set previous = `ps_mine.sh | grep "notify.tcl" | grep "wish"`
if ("$previous" != "") then
    set pid = `echo $previous | sed -e "s/^[^ ]* //" -e "s/ .*//"`
    kill -9 $pid
endif

# Display the message box
set dir = `dirname $0`
wish -f $dir/notify.tcl $*
