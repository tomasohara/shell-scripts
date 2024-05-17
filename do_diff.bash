#!/bin/bash
#
# translation of do_diff.sh into bash via ChatGPT and manual revision
#
# do_diff.sh: compare a subset of the files in two directories
#
# Notes:
# - Also see diff.sh for simpler version.
# - shellcheck filtering:
#   SC2016: Expressions don't expand in single quotes, use double quotes for that.
#   SC2049: =~ is for regex. Use == for globs.
#   SC2086: Double quote to prevent globbing and word splitting.
#
# TODO1:
# - Use --verbose to determine the level of detail for the usage
#   (see calc_entropy.pelr for an example.)
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

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
## DEBUG:
## echo "$@"
## set -o xtrace
## DETAILED: set -o verbose
#
# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Initialize
pattern=""
master="master"
diff_options=""
space_options="--ignore-space-change --ignore-blank-lines"
brief="0"
quiet="0"
diff_cmd="diff"
nopattern="0"
verbose_mode="1"
match_dot_files="0"
no_glob="0"
base_dir="."

# Show usage statement if insufficient arguments given
if [ -z "$2" ]; then
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [option] {--all | pattern} master_dir"
    echo ""
    echo "   options: [--check-space-changes | --ignore-spacing] [--brief] [--quiet] [--verbose] [--diff cmd] [--diff-options text] [--match-dot-files]"
    echo "   other options: [-side-by-side] [--ignore-all-space] [--no-pattern] [--no-glob] [--kdiff] [--trace] [--dir dir]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --ignore-spacing '*.[ch]*' MASTER-DIR"
    echo ""
    echo "$script '.py' .. >| _python_diff.list 2>&1"
    echo ""
    ## OLD:
    ## # shellcheck disable=SC2016
    ## echo '(for f in system.py main.py debug.py; do' "$script" '$f ~/mezcla-clone; done) 2>&1 | less'
    echo "find . -type d -exec \"$script\" --dir {} --verbose '*' ~/repo-main/{} \; > _main-diff.log 2>&1"
    echo ""
    
    echo ""
    ## OLD: echo "$script" '--match-dot-files ".*bash* .*emacs*" .. >| _bash-emacs-diff.list 2>&1'
    echo "$script" '--match-dot-files ".*bash*" .. >| _bash-diff.list 2>&1'
    echo ""
    echo "$script --ignore-spacing --diff-options '--context=1' '*.rb' vm-torre >| vm-torre.diff 2>&1"
    echo ""
    echo "$script --no-glob '*.py *.mako' ~/xfer"
    echo ""
    echo "Notes:"
    echo "- When . occurs in pattern, it is treated as a file extension:"
    echo "   'py' => '*py*' but '.py' => '*.py' (not '*.py*')"
    echo "- Use --match-dot-files, to ensure that . matches Unix dot files (e.g., .bashrc)"
    # TODO: interchange .bash and emacs here and in example above
    ## OLD: echo "   '.emacs' => '.emacs*' (not '*.emacs*')"
    echo "   '.git' => '.git*' (not '*.git*')"
    echo "- The --no-pattern option treats pattern as a file (and likewise for master_dir)"
    echo "- Changes due to whitespace are ignored by default (i.e., --ignore-space-change, and --ignore-blank-lines [diff -wB])."
    echo "- Specify --ignore-all-space [diff -a] to ignore spacing even within tokens"
    echo "- Use --check-space-changes to check for any changes in whitespace"
    echo "- The --dir option is useful with find to achieve recursive diff (see example above)"
    echo ""
    exit
fi

# Parse command-line arguments
# TODO: allows options after pattern (e.g., `while (("$1" =~ -*) || ("$2" =~ -*))`)
while [[ "$1" =~ ^- ]]; do
    if [ "$1" == "--all" ]; then
        pattern="*"
    elif [ "$1" == "--ignore-spacing" ]; then
        # Ignore all spacing-related differences (i.e., -wbB)
        space_options="--ignore-space-change --ignore-all-space --ignore-blank-lines"
    elif [ "$1" == "--check-space-changes" ]; then
        space_options=""
    elif [ "$1" == "--brief" ]; then
        brief="1"
    elif [ "$1" == "--diff" ]; then
        diff_cmd="$2"
        shift
    elif [ "$1" == "--diff-options" ]; then
        diff_options="$diff_options $2"
        shift
    elif [ "$1" == "--dir" ]; then
        base_dir="$2"
        shift
    elif [ "$1" == "--side-by-side" ]; then
        width=$((2 * ${COLUMNS:-132}))
        diff_options="$diff_options --side-by-side --suppress-common-lines --width=$width"
    elif [ "$1" == "--quiet" ]; then
        quiet="1"
        verbose_mode="0"
    elif [ "$1" == "--no-quiet" ]; then
        quiet="0"
        ## TODO3?: verbose_mode="1"
    elif [ "$1" == "--verbose" ]; then
        verbose_mode="1"
    elif [ "$1" == "--no-verbose" ]; then
        verbose_mode="0"
    elif [[ ("$1" == "--nopattern") || ("$1" == "--no-pattern") ]]; then
        nopattern="1"
        ## TODO3: reduce redundant flags
        no_glob="1"
    elif [ "$1" == "--no-glob" ]; then
        no_glob="1"
    elif [ "$1" == "--match-dot-files" ]; then
        match_dot_files="1"
    elif [ "$1" == "--ignore-all-space" ]; then
        diff_options="$diff_options --ignore-all-space"
    elif [[ ("$1" == "--kdiff") || ("$1" == "--vdiff") ]]; then
        # HACK: backdoor option for using kdiff
        diff_cmd="kdiff.sh"
        diff_options=""
        space_options=""
        brief="1"
    elif [ "$1" == "--trace" ]; then
        set -x
    else
        echo "ERROR: unknown option: $1"
        exit 1
    fi
    shift
done

# Get pattern from first argument
# shellcheck disable=SC2049
if [ -z "$pattern" ]; then
    if [ "$no_glob" == "1" ]; then
        # Treat first argument as pattern without * added
        pattern="$1"
    elif [[ "$1" =~ \*.*\ \*\. ]]; then
        # ex: "*.py *.mako"
        echo "Warning: Assuming implicit --no-glob, as otherwise space would be in extension"
        pattern="$1"
    elif [ -f "$1" ]; then
        # specific file (e.g., "README.txt")
        pattern="$1"
    elif [[ "$1" =~ \.* ]]; then
        # note: dot file (e.g., ".emacs") requires use of --match-dot-files
        if [ "$match_dot_files" == "1" ]; then
            # note: special case handling since can't use *.emacs* (i.e., substring case below)
            pattern="$1*"
        else
            # convenience so that '.py' gets treated as '*.py'
            pattern="*$1"
        fi
    elif [[ "$1" =~ \*\. ]]; then
        # extension (e.g., "*.py")
        pattern="*$1"
    else
        # substring of file
        pattern="*$1*"
    fi
    shift
fi

# Get master directory from second argument
master="$1"
if [ ! -d "$master" ]; then
    nopattern="1"
fi

# Note: nopattern flag only used for producing output labels
## TODO3: clarify intention
if [ "$nopattern" == "0" ]; then
    echo "checking files in pattern $pattern"
fi

# Optionally, change the directory
#
if [ "$base_dir" != "." ]; then
    if [ "$verbose_mode" == "1" ]; then
        echo in dir "$base_dir":
    fi
    cd "$base_dir"
fi

# Do the actual diff
count=0
# shellcheck disable=SC2086
for file in $pattern; do
    # Add line divider
    if [[ ("$verbose_mode" == "1") && ($count -ge 0) ]]; then
        echo "------------------------------------------------------------------------"
    fi
    let count++

    # Resolve path for other file
    if [[ "$file" =~ \$ ]]; then
        echo "Warning: Ignoring file '$file' with $ in name"
        continue
    fi
    # Derive base name for file, including relative directory (e.g., in case pattern specifies subdirectory)
    base=$(basename "$file")
    dir=$(dirname "$file")
    if [ "$dir" != "." ]; then
        base="$dir/$base"
    fi
    other_file="$master"
    #
    if [ -d "$file" ]; then
        # TODO: have option to recursively do diff's
        echo "Warning: Ignoring subdirectory '$file'"
        continue
    fi
    if [ -d "$other_file" ]; then
        other_file="$master/$base"
    fi
    if [ "$quiet" == "0" ]; then
        echo "$base_dir/$file vs. $other_file"
    fi
    if [ ! -e "$other_file" ]; then
        echo "Warning: missing other file: '$other_file'"
        continue
    fi

    # Show the timestamps if the files differ, unless in brief mode.
    # Note: Outputs 'Differences: {file1} {file2}' when files differ for convenient
    # grepping (e.g., `do_diff.sh ... | grep '^Differences:'`).
    files_differ=false
    if [ "$brief" == "0" ]; then
        log_file="${TMP:-/tmp}/_do_diff.$$.log"
        "$diff_cmd" --brief $space_options $diff_options "$file" "$other_file" >| "$log_file"
        status=$?
        ## OLD: perl -pe 's/Files (.*) and (.*) differ/Differences: $1 $2/;' < "$log_file"
        perl -e "\$bd='$base_dir';" -pe 's@Files (.*) and (.*) differ@Differences: $bd$d/$1 $2@;' < "$log_file"

        # Show file info with time and size if there are differences
        if [ "$status" != "0" ]; then
            files_differ=true
            ls -l "$file"
            ls -l "$other_file"
        fi
    fi
        
    # Perform the actual diff
    log_file="$TMP/do_diff.$$"
    "$diff_cmd" $space_options $diff_options "$file" "$other_file" > "$log_file" 2>&1
    
    # Show relative difference percent
    ## TODO?: if [[ "$brief" == "0") && $files_differ ]]; then
    if [ "$brief" == "0" ] && $files_differ; then
        num_lines1=$(wc -l < "$file")
        num_lines2=$(wc -l < "$other_file" || echo "0")
        num_lines=$(( $num_lines1 + $num_lines2 ))
        num_diffs=$(wc -l < "$log_file")
        relative_diff=-1
        if [ $num_lines -gt 0 ]; then
            relative_diff=$(( $num_diffs * 100 / $num_lines ))
        fi
        echo "${relative_diff}% differences for $base"
    fi

    # Show the actual file differences
    cat "$TMP/do_diff.$$"

    # Add space divider
    ## TEMP: for consistency with continue'd cases above omits space if verbose, becuase
    ## the divider provides separation.
    ## OLD: if [ "$quiet" == "0" ]; then
    if [[ ("$quiet" == "0") && ("$verbose_mode" != "1") ]]; then
        echo ""
    fi
done
