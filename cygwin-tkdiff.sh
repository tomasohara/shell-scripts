#! /bin/csh -f
#
# cygwin-tkdiff.sh: run cygwin-tkdiff.tcl after setting up required environment
# to account for cygwish80's lack of Unix support
#
# TODO:
# - Use automatic RCS extraction to workaround CygWin/Win32 path problem.
#   This is currently handled by having a separate alias for this case:
#      function cyg-rcsdiff() { co -p $1 >| /e/temp/$1; cygwin-tkdiff.sh "$1" /e/temp & }
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Remap the temporary directory environment settings
# TODO: remap the environment variables automatically (eg, via a perl script)
setenv TMP `remap_filename.perl $TMP`
setenv TEMP `remap_filename.perl $TEMP`
setenv TMPDIR `remap_filename.perl $TMPDIR`
## echo "TMP=${TMP} TEMP=${TEMP} TMPDIR=${TMPDIR}"

# Run cygwin-tkdiff.tcl
# TODO: use csh equivalent of "$@" to preserve quoted arguments
set dir = `dirname $0`
set script = `basename $0 .sh`.tcl
## echo "dir=$dir script=${script}"
set tcl_script = "$dir/$script"
if ($tcl_script !~ /*) set tcl_script = "$PWD/${tcl_script}"
set win_tcl_script = `remap_filename.perl -escape ${tcl_script}`
set win_args = `remap_filename.perl -escape "$*"`
## echo "tcl_script=${tcl_script} win_tcl_script=${win_tcl_script} win_args=${win_args}"
$win_tcl_script $win_args
