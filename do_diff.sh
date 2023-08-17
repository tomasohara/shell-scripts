#!/bin/csh -f
#
# *** OBSOLETE: see do_diff.bash ***
#
# do_diff.sh: compare a subset of the files in two directories
#
# Notes:
# - Also see diff.sh for simpler version.
#
# TODO:
# - Reconcile with do_rcsdiff.sh (at least keep in synch put perhaps combine).
# - add sample input and output comments
# - Work in subdirectory tree comparison example into usage:
#     find -name '*.java' | foreach.perl 'do_diff.sh -b $f /tmp/$F' -
# - Make --ignore-all-space optional as ignores tokenization.
# - * Send all output to stdout (e.g., "No such file or directory" warning).
#
#-------------------------------------------------------------------------------
# via diff info page (GNU diffutils version 3.2):
# 
#    The `--ignore-space-change' (`-b') option is stronger than `-E' and
# `-Z' combined.  It ignores white space at line end, and considers all
# other sequences of one or more white space characters within a line to
# be equivalent.  With this option, `diff' considers the following two
# lines to be equivalent, where `$' denotes the line end:
# 
#      Here lyeth  muche rychnesse  in lytell space.   -- John Heywood$
#      Here lyeth muche rychnesse in lytell space. -- John Heywood   $
# 
#    The `--ignore-all-space' (`-w') option is stronger still.  It
# ignores differences even if one line has white space where the other
# line has none.  "White space" characters include tab, vertical tab,
# form feed, carriage return, and space; some locales may define
# additional characters to be white space.  With this option, `diff'
# considers the following two lines to be equivalent, where `$' denotes
# the line end and `^M' denotes a carriage return:
# 
#      Here lyeth  muche  rychnesse in lytell space.--  John Heywood$
#        He relyeth much erychnes  seinly tells pace.  --John Heywood   ^M$
# ...
#   The `--ignore-blank-lines' (`-B') option ignores changes that consist
# entirely of blank lines.
#

# set echo = 1
set pattern = ""
set master = "master"
set diff_options = ""
## set space_options="--ignore-space-change --ignore-all-space --ignore-blank-lines"
set space_options="--ignore-space-change --ignore-blank-lines"
set brief = "0"
set quiet = "0"
set diff_cmd = "diff"
set nopattern = "0"
set verbose_mode = "1"
set match_dot_files = "0"
set no_glob = "0"

# Show usage statement if insufficient arguments given
if ("$2" == "") then
    set script = `basename $0`
    echo ""
    echo "Usage: $script [option] {--all | pattern} master_dir"
    echo ""
    echo "   options: [-b | --ignore-spacing] [--check-space-changes] [-l] [--brief] [--quiet] [--verbose] [--nopattern] [--diff-options option-text] [--match-dot-files] [--ignore-all-space] [--no-glob] [-trace]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --ignore-spacing '*.[ch]*' MASTER-DIR"
    echo ""
    echo "$script '.py' .. >| _python_diff.list 2>&1"
    echo ""
    echo '(for f in master_delta_extraction.py main.py delta_posting_extraction.py tpo_common.py; do' $script '$f $SANDBOX; done) 2>&1 | less'
    echo ""
    ## OLD
    ## echo "$script .perl" '$SCRIPT_DIR >| _perl_diff.list 2>&1'
    ## echo ""
    ## OLD: cho "$script" '--match-dot-files ".*bash*" dot-file-archive >| _bash-dot-file-diff.list 2>&1'
    echo "$script" '--match-dot-files ".*bash* .*emacs*" .. >| _bash-emacs-diff.list 2>&1'
    echo ""
    ## echo "$script --diff diff.sh ./Parser/prune.lisp ../new-Full_Analyzer"
    ## echo ""
    echo "$script --ignore-spacing --diff-options '--context=1' '*.rb' vm-torre >| vm-torre.diff 2>&1"
    echo ""
    echo "$script --no-glob '*.py *.mako' ~/xfer"
    echo ""
    echo "Notes:"
    echo "- When . occurs in pattern, it is treated as a file extension:"
    echo "   'py' => '*py*' but '.py' => '*.py' (not '*.py*')"
    echo "- Use --match-dot-files, to ensure that . matches Unix dot files (e.g., .bashrc)"
    # TODO: interchange .bash and emacs here and in example above
    echo "   '.emacs' => '.emacs*' (not '*.emacs*')"
    echo "- The --nopattern option treats pattern as a file (and likewise for master_dir)"
    echo "- Changes due to whitespace are ignored by default (i.e., --ignore-space-change, and --ignore-blank-lines [diff -wB])."
    echo "- Specify --ignore-all-space [diff -a] to ignore spacing even within tokens"
    echo "- Use --check-space-changes to check for any changes in whitespace"
    echo ""
    exit
endif

# Parse command-line arguments
# TODO: allows options after pattern (e.g., `while (("$1" =~ -*) || ("$2" =~ -*))`)
while ("$1" =~ -*)
    if ("$1" == "--all") then
	set pattern = "*"
    else if (("$1" == "-b") || ("$1" == "-wb") || ("$1" == "--ignore-spacing")) then
        # Ignore all spacing-related differences (i.e., -wbB)
	## OLD: set diff_options = "$diff_options --ignore-space-change --ignore-all-space --ignore-blank-lines"
	set space_options = "--ignore-space-change --ignore-all-space --ignore-blank-lines"
    else if ("$1" == "--check-space-changes") then
	set space_options=""
    else if ("$1" == "--brief") then
	set brief = "1"
    else if ("$1" == "--diff") then
	set diff_cmd = "$2"
	shift
    else if ("$1" == "--diff-options") then
	set diff_options = "$diff_options $2"
	shift
    else if ("$1" == "--quiet") then
	set quiet = "1"
	set verbose_mode = "0"
    else if ("$1" == "--verbose") then
	set verbose_mode = "1"
    else if ("$1" == "--nopattern") then
	set nopattern = "1"
    else if ("$1" == "--no-glob") then
	set no_glob = "1"
    else if ("$1" == "--match-dot-files") then
	set match_dot_files = "1"
    else if ("$1" == "--ignore-all-space") then
	set diff_options = "$diff_options --ignore-all-space"
    else if ("$1" == "--trace") then
	set echo = 1
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end

# Get pattern from first argument
if ("$pattern" == "") then
    if ("$no_glob" == "1") then
        # Treat first argument as pattern without * added
	set pattern = "$1"
    else if ("$1" =~ \*.*\ \*\.*) then
        # ex: "*.py *.mako"
        echo "Assuming implicit --no-glob, as otherwise space would be in extension"
	set pattern = "$1"
    else if (-f "$1") then
        # specific file (e.g., "README.txt")
	set pattern = "$1"
    else if ("$1" =~ \.*) then
        # note: dot file (e.g., ".emacs") requires use of --match-dot-files
	if ("$match_dot_files" == "1") then
	    # note: special case handling since can't use *.emacs* (i.e., substring case below)
	    set pattern = "$1*"
	else
	    # convenience so that '.py' gets treated as '*.py'
	    set pattern = "*$1"
	endif
    else if ("$1" =~ \*\.*) then
        # extension (e.g., "*.py")
	set pattern = "*$1"
    else
        # substring of file
	set pattern = "*$1*"
    endif
    shift
endif

# Get master directory from second argument
set master="$1"
if (! -d "$master") then
    set nopattern = "1"
endif

# Note: nopattern flag only used for producing output labels
if ("$nopattern" == "0") then
    echo "checking files in pattern $pattern"
endif
#
foreach file ($pattern)
   if ("$file" =~ \*\$\*) then
	echo "Warning: Ignoring file with $ in name"
	continue
   endif
   # Derive base name for file, including relative directory (e.g., in case pattern specifies subdirectory)
   ## OLD: set base = `basename "$file"`
   set base = `basename "$file"`
   set dir = `dirname "$file"`
   if ("$dir" != ".")  set base = "$dir/$base"
   set other_file="$master"

   if (-d "$file") then
       # TODO: have option to recursively do diff's
       echo "Ignoring subdirectory $file"
       continue
   endif
   if (-d "$other_file") then
       set other_file="$master/$base"
   endif
   if ($quiet == 0) then
       echo "$file" vs. "$other_file"
   endif

   # Show the timestamps if the files differ
   # Note: Outputs 'Differences: {file1} {file2}' when files differ for convenient
   # grepping (e.g., `do_diff.sh ... | grep '^Differences:'`).
   if ($brief == "0") then
       ## OLD: $diff_cmd --brief $diff_options "$file" "$other_file" | perl -pe 's/Files (.*) and (.*) differ/Differences: $1 $2/;'
       $diff_cmd --brief $space_options $diff_options "$file" "$other_file" | perl -pe 's/Files (.*) and (.*) differ/Differences: $1 $2/;'
       ## OLD: if ($? == 1) then
       if ($status == 1) then
	   ls -l "$file"
	   ls -l "$other_file"
       endif
   endif
	
   # Show the actual file differences
   ## OLD: $diff_cmd $diff_options "$file" "$other_file"
   $diff_cmd $space_options $diff_options "$file" "$other_file"
   if ($verbose_mode == "1") then
       echo "------------------------------------------------------------------------"
   endif

   if ($quiet == 0) then
       echo ""
   endif
end
