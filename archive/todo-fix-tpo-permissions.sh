#!/bin/bash
# Make sure all directories readable and executable, accounting for
# quirks due to CygWin usage, etc.
#
# TODO:
# - Add more support from GraphLing old_fix_permissions.sh utility:
#      cd /home/graphling
#      find . -type d -exec chmod g+xs {} \;
#      chgrp -R graphling .
#      chmod -R g+rw .
# - Change user to $USER.
# - Add option for making files writable except those in backup directories (and to ensure those in backup directories are non-writable).
# - Include support for making readable by Everyone (e.g., for transfers to different computers and/or users).
# - handle directory names with spaces
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# Show usage statement
#
if [ "$1" = "" ]; then
    script_name=`basename $0`
    log_base=`basename $script_name .sh`
    echo ""
    echo "usage: `basename $0` [options] [dir]"
    echo ""
    echo "   options = [--recursive] [--fix-ACLs] [--verbose] [--trace] [--multiple]" 
    echo ""
    echo "example(s):"
    echo ""
    echo "$0 --verbose ."
    echo ""
    echo "$script_name --fix-ACLs"
    echo ""
    echo "$script_name --recursive --fix-ACLs --trace >| $log_base.log 2>&1"
    echo ""
    echo "note: with --multiple, DIR is a list of directories (without embedded spaces)"
    echo ""
    exit
fi

# Parse command-line options
#
# TODO: add support for group
# $ groups tomohara
# tomohara : None Debugger Users HelpLibraryUpdaters Administrators
#
fix_ACLs=0
user="$USER"
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
verbose="0"
recursive="0"
multiple="0"
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--fix-ACLs" ]; then
	fix_ACLs=1;
    elif [ "$1" = "--verbose" ]; then
	verbose="1";
    elif [ "$1" = "--recursive" ]; then
	recursive="1";
    elif [ "$1" = "--user" ]; then
	user=$1;
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
dirs=($1)
if [ $multiple = "1"]; then dirs=($@); fi
# Set up common options for chmod and chown
verbose_op=""
recurse_op=""
if [ "$verbose" = "1" ]; then verbose_op="-v"; fi
if [ "$recursive" = "1" ]; then recurse_op="-R"; fi

# Make sure files readable
# TODO: make writable except for files in backup directories
# TODO: make verbose listing optional
echo "Changing user permissions"
for dir in ${dirs[*]}; do
   chown $recurse_op $verbose_op $user $dir | grep -v 'ownership.*retained as'
   chmod $recurse_op $verbose_op u+r $dir | grep -v 'mode.*retained as'
done

# Make sure subdirectories are readable and executable (i.e., chdir-able).
echo "Changing directory permissions"
chmod $ch_options ugo+rx .
if [ "$recursive" = "1" ]; then
    for dir in ${dirs[*]}; do
	find "$dir" -type d -exec chmod $verbose_op ugo+rx {} \; | grep -v 'mode.*retained as'
    done
fi

# Optionally set ACL's
if [ "$fix_ACLs" = "1" ]; then
    echo "Changing access control lists (ACLs)"
    acl_file=/tmp/setfacl-template-$$.list

    # TODO: make writeable optional, especially for group and others
    # TODO: apply to all subdirectories (and with find/chmod above)
    cat >$acl_file <<EOF
        # owner: tohara
        # group: mkpasswd
        user::rwx
        group::rwx
        mask:rwx
        other:rwx

        default:group::rwx
        default:other:rwx
EOF

    setfacl -f $acl_file $dirs
    if [ "$recursive" = "1" ]; then
	for dir in ${dirs[*]}; do
	    find "$dir" -type d -exec setfacl -f $acl_file {} \;
	done
    fi
fi
