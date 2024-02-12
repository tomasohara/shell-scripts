#!/bin/bash
# Make sure all directories readable and executable, accounting for
# quirks due to CygWin usage, etc.
#
#-------------------------------------------------------------------------------
# Example file ACL spec:
#
#    # owner: tomohara
#    # group: mkpasswd
#    user::rwx
#    group::rwx
#    mask:rwx
#    other:rwx
#
# Example directory ACL spec:
#
#    # owner: tomohara
#    # group: mkpasswd
#    user::rwx
#    group::rwx
#    mask:rwx
#    other:rwx
#    default:user::rwx
#    default:group::rwx
#    default:other:rwx
#
#-------------------------------------------------------------------------------
# TODO:
# - Add more support from GraphLing old_fix_permissions.sh utility:
#      cd /home/graphling
#      find . -type d -exec chmod g+xs {} \;
#      chgrp -R graphling .
#      chmod -R g+rw .
# - Change user to $USER.
# - Add option for making files writable except those in backup directories (and to ensure those in backup directories are non-writable).
# - Include support for making readable by Everyone (e.g., for transfers to different computers and/or users).
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
    echo "Usage: `basename $0` [options] {dir ...}|{file-spec}"
    echo ""
    echo "   options = [--recursive] [--fix-ACLs] [--writable] [-file-spec pattern] [--verbose] [--trace]"
    echo "             [--user-spec mode] [--group-spec mode] [--other-spec mode] [--just-user]"
    echo ""
    echo "Notes:"
    echo "- With --recursive, only a single drectory is supported."
    echo "- The --file-spec pattern is applied for each directory (e.g., recursively applied)."
    echo "  The argment should be quoted."
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --verbose ."
    echo ""
    echo "$script_name --fix-ACLs"
    echo ""
    echo "$script_name --fix-ACLs --file-spec 'bcbs-*'"
    echo ""
    echo "$script_name --recursive --fix-ACLs --trace > $log_base.log 2>&1"
    echo ""
    echo "$script_name --recursive --writable --trace > $log_base.log 2>&1"
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
writable="0"
executable="0"
file_spec=""
#
# TODO: chmod_user_spec="u"
chmod_user_spec="ugo"
chmod_perm_spec="rwx"
#
user_acl_spec="rwx"
group_acl_spec="rwx"
other_acl_spec="rwx"
#
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
	shift
    elif [ "$1" = "--file-spec" ]; then
	file_acl_spec="$2";
	shift
    elif [ "$1" = "--user-spec" ]; then
	user_acl_spec="$2";
	shift
    elif [ "$1" = "--group-spec" ]; then
	group_acl_spec="$2";
	shift
    elif [ "$1" = "--other-spec" ]; then
	other_acl_spec="$2";
	shift
    elif [ "$1" = "--just-user" ]; then
	chmod_user_spec="u"
	group_acl_spec="---";
	other_acl_spec="---";
    elif [ "$1" = "--include-group" ]; then
	chmod_user_spec="${chmod_user_spec}g"
    elif [ "$1" = "--include-group" ]; then
	chmod_user_spec="${chmod_user_spec}o"
    elif [ "$1" = "--writable" ]; then
	writable="1";
    elif [ "$1" = "--executable" ]; then
       executable="1";
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
dirs="$@"
if [ "$dirs" = "" ]; then dirs="."; fi

# Set up common options for chmod and chown
verbose_op=""
recurse_op=""
if [ "$verbose" = "1" ]; then verbose_op="-v"; fi
if [ "$recursive" = "1" ]; then recurse_op="-R"; fi

# Make sure files readable
# TODO: make writable except for files in backup directories
# TODO: make verbose listing optional
echo "Changing user permissions"
chown $recurse_op $verbose_op $user $dirs | grep -v 'ownership.*retained as'
chmod_permissions="r"
if [ "$writable" = "1" ]; then chmod_permissions="${chmod_permissions}w"; fi
if [ "$executable" = "1" ]; then chmod_permissions="${chmod_permissions}x"; fi
## OLD: chmod $recurse_op $verbose_op u+"$chmod_permissions" $dirs | grep -v 'mode.*retained as'
chmod $recurse_op $verbose_op "${chmod_user_spec}+$chmod_permissions" $dirs | grep -v 'mode.*retained as'
if [ "$file_spec" != "" ]; then
    chmod $recurse_op $verbose_op "${chmod_user_spec}+$chmod_permissions" $file_spec | grep -v 'mode.*retained as'
fi

# Make sure subdirectories are readable and executable (i.e., chdir-able).
echo "Changing directory permissions"
chmod $ch_options "${chmod_user_spec}+$chmod_permissions" .
if [ "$recursive" = "1" ]; then
    find $dirs -type d -exec chmod $verbose_op "${chmod_user_spec}+$chmod_permissions" {} \; | grep -v 'mode.*retained as'
    if [ "$file_spec" != "" ]; then
	find $dirs -type f -iname "$file_spec" -exec chmod $verbose_op "${chmod_user_spec}+$chmod_permissions" {} \; | grep -v 'mode.*retained as'
    fi
fi

# Optionally set ACL's
if [ "$fix_ACLs" = "1" ]; then
    echo "Changing access control lists (ACLs)"
    file_acl_file=/tmp/setfacl-file-template-$$.list
    dir_acl_file=/tmp/setfacl-dir-template-$$.list

    # TODO: make writeable optional, especially for group and others
    # TODO: apply to all subdirectories (and with find/chmod above)
    if [ -e "$file_acl_file" ]; then rm -f $file_acl_file; fi
    cat >$file_acl_file <<EOF_FILE_SPEC
        # owner: $USER
        # group: mkpasswd
        mask:rwx
        user::$user_acl_spec
        group::$group_acl_spec
        other::$other_acl_spec
EOF_FILE_SPEC

    # TODO: make RWX based on arguments (e.g., --others & --group)
    cp -pf $file_acl_file $dir_acl_file
    cat >>$dir_acl_file <<EOF_DIR_SPEC
        default:user::$user_acl_spec
        default:group::$group_acl_spec
        default:other:$other_acl_spec
EOF_DIR_SPEC
    if [ "$verbose" = "1" ]; then
	head $file_acl_file $dir_acl_file
    fi
    
    setfacl -f $dir_acl_file $dirs
    if [ "$file_spec" != "" ]; then
	setfacl -f $file_acl_file $file_spec
    fi
    if [ "$recursive" = "1" ]; then
	if [ "$file_spec" != "" ]; then
	    find $dirs -type d -exec setfacl -f $dir_acl_file {} \;
	    find $dirs -type f -iname "$file_spec" -exec chmod $verbose_op "${chmod_user_spec}+$chmod_permissions" {} \; | grep -v 'mode.*retained as'
	else
	    find $dirs -type d -exec setfacl -f $dir_acl_file {} \;
	    find $dirs -type f -exec setfacl -f $file_acl_file {} \;
	fi
    fi
fi
