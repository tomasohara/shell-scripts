#! /usr/bin/env bash
#
# Invoke label studio, optionally with development version.
#
# Notes:
# - Invokes the default label-studio script, which in turn invokes the server:
#   #!/usr/local/misc/programs/anaconda3/envs/osr-py3-8/bin/python
#   # -*- coding: utf-8 -*-
#   import re
#   import sys
#   from label_studio.server import main
#   if __name__ == '__main__':
#       sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
#       sys.exit(main())
# - Manual startup steps:
#   normal:
#       label-studio start --log-level DEBUG --no-browser >> _run-$(TODAY).log 2>&1 &
#   alternative DB:
#       port=9999; label-studio start --log-level DEBUG --port $port --no-browser --data-dir . --database ./label_studio.sqlite3 >> _run-port$port-$(TODAY).log 2>&1 &
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Parse command-line options
#
show_usage=""
devel=0
debug=0
verbose=0
sqlite3="0"
other_args="--no-browser"
devel_dir="$HOME/programs/python/label-studio"
if [ -e "label_studio/server.py" ]; then
    devel=1
    debug=1
    devel_dir="$PWD"
    echo "Note: Invoking development version as in base directory."
fi
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    show_usage=0
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--verbose" ]; then
	verbose=1
    elif [ "$1" = "--help" ]; then
	show_usage=1
    elif [ "$1" = "--data-dir" ]; then
	# TODO: add support for postgresql equivalent
	# NOTE: --config is for default_config.json and --data-dir for location of DB
	other_args="$other_args --data-dir $2 --database $2/label_studio.sqlite3"
	shift
    elif [ "$1" = "--debug" ]; then
	debug=1
    elif [ "$1" = "--devel" ]; then
	devel=1
    elif [ "$1" = "--production" ]; then
	devel=0
    elif [ "$1" = "--devel-dir" ]; then
	devel_dir=$(realpath "$2")
	devel=1
	shift
    elif [ "$1" = "--port" ]; then
	other_args="$other_args --port $2"
	shift
    elif [ "$1" = "--sqlite3" ]; then
	sqlite3=1
    elif [ "$1" = "--postgresql" ]; then
	sqlite3=0
    elif [ "$1" = "--" ]; then
	show_usage=0
	shift
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
# note: usage assumed unless argument given
if [[ ($show_usage = "") ]]; then
    show_usage=1
fi

## TODO:
## # Put arguments after -- into #other_args
## if [ "$1" != "" ]; then
##     other_args="$other_args $@"
## fi
## NOTE: "$@" is used below

# Show usage statement
# NOTE: See sync-loop.sh for an example.
#
if [ "$show_usage" = "1" ]; then
   script=$(basename "$0")
    echo ""
    echo "Usage: $0 [[--devel | --production] [--devel-dir path] [--sqlite3 | --postgresql] [--debug] [--port n] [--data-dir path] [--trace] [--help]]  [--]  [label-studio-args]"
    echo ""
    echo "Examples:"
    echo ""
    echo "function TODAY { date '+%d%b%y'; }"
    echo ""
    echo "$script --postgresql --debug --verbose > _run-label-studio-postgresql-\$(TODAY).log 2>&1 &"
    echo ""
    echo "cd ~/programs/python/label-studio"
    echo "$script --devel > _run-label-studio-\$(TODAY).log 2>&1 &"
    echo ""
    echo "port=9999"
    echo "cp -p PRODUCTION_DIR/label_studio.sqlite3 ."
    echo "$script --debug --devel-dir \$PWD --port \$port --data-dir . >> _run-port\$port-\$(TODAY).log 2>&1 &"
    echo ""
    echo "Notes:"
    echo "- Arguments after -- passed along to label studio. Also use to skip usage."
    echo "- If in the base directory, then assume --devel, --devel-dir ., and --debug"
    echo "- PostgreSQL is the default DB."
    echo "- The --devel-dir option implies --devel."
    echo ""
    exit
fi

# Add development directory to path settings
if [ "$devel" = "1" ]; then
    export PATH="$devel_dir:$PATH"
    export PYTHONPATH="$devel_dir:$PYTHONPATH"
    if [ "$verbose" = "1" ]; then echo "new env: PATH=$PATH; PYTHONPATH=$PYTHONPATH"; fi
fi

# Add debug options
if [ "$debug" = "1" ]; then
    ## OLD: other_args="$other_args --debug --log-level DEBUG"
    other_args="$other_args --log-level DEBUG"
fi

# Add database option
if [ "$sqlite3" = "0" ]; then
    other_args="$other_args --database postgresql"
fi

# Run label studio
if [ "$verbose" = "1" ]; then echo "Issuing: label-studio $other_args $*"; fi
#
# TODO: resolve shellcheck warning about $other_args
#    SC2086: Double quote to prevent globbing and word splitting.
# note: Unfortunately, shellcheck only applies to the next line!
#   See https://github.com/koalaman/shellcheck/issues/1295 [Allow directives in trailing comments].
#
# shellcheck disable=SC2086
label-studio $other_args "$@"
