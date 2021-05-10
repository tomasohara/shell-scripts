#! /bin/sh
#
# reorganize-dir.sh: move the files in the directory into subdirectories
# named A through Z, based on the first letter of each file.
#
# NOTE:
# - Automates following steps:
#   foreach.perl 'mkdir -p $f' a b c d e f g h i j k l m n o p q r s t u v w x y z
#   foreach.perl 'mv $f*.* $f' a b c d e f g h i j k l m n o p q r s t u v w x y z  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
#
# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after): 
#
# set -o verbose
set -o xtrace

# Parse command-line arguments
if [ "$1" = "" ]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: `basename $0` -"
    echo ""
    exit
fi

moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "-" ]; then
	# No-op
	echo -n;
    elif [ "$1" = "--bar" ]; then
	echo "bar";
    else
	echo "unknown option: $1";
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Ensure the subdirectories exist
# TODO: use bash primitives
## for subdir in ${subdirs[@]}; do 
##    mkdir -p $subdir
## done
foreach.perl 'mkdir -p $f' a b c d e f g h i j k l m n o p q r s t u v w x y z

# Move files in current directory to appropriate subdirectory
# TODO: account for files w/o file extensions
foreach.perl 'mv $f*.* $f' a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
