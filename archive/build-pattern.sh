#! /bin/bash
#
# Adhoc script to build all pattern matching related projects.
#
# NOTES:
# - The main build directory for each project is determined as follows:
#   $ for p in fastlib juniper fastrtsearch fastserver fsoemfrontend; do find $p -name config_command.sh; done
#   fastlib/src/cpp/config_command.sh
#   juniper/config_command.sh
#   fastrtsearch/config_command.sh
#   fastserver/src/config_command.sh
#   fsoemfrontend/src/config_command.sh
#
# TODO:
# - Combine with checkout-pattern.sh.
# - Create table with project and main directory information.
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
    echo ""
    echo "usage: `basename $0` [--in-place | --dev] [--no-build] [--test] [--trace]"
    echo ""
    echo "examples:"
    echo ""
    echo "`basename $0` --in-place --check-out"
    echo ""
    echo "`basename $0` --in-place --test --no-config --no-build"
    echo ""
    exit
fi

# Parse command-line options
#
in_place=0
check_out=0
test=0
build=1
config=1
clean=0
script_ext="sh"
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--in-place" ]; then
        in_place=1;
        config=0;
    elif [ "$1" = "--dev" ]; then
        in_place=0;
    elif [ "$1" = "--clean" ]; then
        clean=1;
    elif [ "$1" = "--redo" ]; then
        config=1;
        check_out=1;
        build=1;
    elif [ "$1" = "--check-out" ]; then
        check_out=1;
    elif [ "$1" = "--no-build" ]; then
        build=0;
        config=0;
    elif [ "$1" = "--no-config" ]; then
        config=0;
    elif [ "$1" = "--win32" ]; then
        config_ext=".cmd";
    elif [ "$1" = "--test" ]; then
        test=1;
    elif [ "$1" = "--trace" ]; then
	set -o xtrace;
    else
	echo "Unknown option: $1";
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

#------------------------------------------------------------------------

# build-project(projname, devdir, makedir): Builds ESP project PROJNAME using
# develop version DEVDIR with main Makefile in MAKEDIR (i.e., DEVDIR/MAKEDIR).
#
function build-project {
    local PROJNAME=$1; local DEVDIR=$2; local MAKEDIR=$3;

    # If build is in separate directory, copy over configuration
    if [ "$in_place" = "1" ]; then 
	DEVDIR=$PROJNAME;
        cp -p $PROJNAME/$MAKEDIR/config_command$script_ext $DEVDIR/$MAKEDIR;
    fi;

    # Run the configuration script
    if [ "$config" = "1" ]; then
        echo "Configuring project $PROJNAME in dir $PROJNAME/$MAKEDIR";
        pushd $DEVDIR/$MAKEDIR;
        config_command$script_ext >| config_command.log 2>&1;
	popd
    fi;

    # Perform the build proper
    pushd $DEVDIR/$MAKEDIR;
    if [ "$build" = "1" ]; then
	echo "Building project $PROJNAME in dir $DEVDIR/$MAKEDIR";
	make --keep-going clean bootstrap install >| make.log 2>&1;
	check_errors.perl -skip_warnings -context=5 make.log;
    fi;

    # Optionally run the tests for the project
    if [ "$test" = "1" ]; then
	make test >| make-test.log 2>&1;
	check_errors.perl -skip_warnings -context=5 make-test.log;
	grep -i failed make-test.log;
    fi
    popd;
    echo "";
}

#------------------------------------------------------------------------

if [ "$check_out" = "1" ]; then
    ## script_dir=`dirname $0`
    ## $script_dir/checkout-pattern.sh
    if [ "$in_place" = "1" ]; then 
	## cvs update -A -r DEV_PATTERN fastlib juniper fastrtsearch fastserver fsoemfrontend
	for p in fastlib juniper fastrtsearch fastserver fsoemfrontend; do cvs update -A -r DEV_PATTERN $p; done
    else
	for p in fastlib juniper fastrtsearch fastserver4 fsoemfrontend; do cvs co -f -d $p.dev -r DEV_PATTERN $p; done
    fi
fi

build-project fastlib fastlib.dev ./src/cpp

build-project juniper juniper.dev .

build-project fastrtsearch fastrtsearch.dev .

build-project fastserver fastserver4.dev ./src

build-project fsoemfrontend fsoemfrontend.dev ./src


