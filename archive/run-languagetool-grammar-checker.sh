#! /bin/bash
#
# Invokes LanguageTool grammar check in batch mode. This invokes the grammar
# checker in the distribution directory, making sure path names are properly 
# resolved, including Cygwin support.
#
#------------------------------------------------------------------------
# Sample usage:
#    $ LANGUAGE_TOOL_HOME=c:/Program-Misc/OpenOffice/LanguageTool-2.1 run-languagetool-grammar-checker.sh badder-grammar-example.txt
#    No language specified, using English
#    Working on D:\cartera-de-tomas\apeters-essay-grading\badder-grammar-example.txt...
#    1.) Line 1, column 16, Rule ID: ENGLISH_WORD_REPEAT_RULE
#    Message: Possible typo: you repeated a word
#    Suggestion: over
#    This be me car over over there. You seen it?
#                   ^^^^^^^^^
#    
#    2.) Line 2, column 5, Rule ID: PRP_PAST_PART[1]
#    Message: Possible grammatical error. You used a past participle without using any required verb ('be' or 'have'). Did you mean 'saw'?
#    Suggestion: saw
#    This be me car over over there. You seen it?
#                                        ^^^^
#    Time: 203ms for 2 sentences (9.9 sentences/sec)
#------------------------------------------------------------------------
# Notes:
# - Download extension jar file (for OpenOffice) via:
#   https://extensions.openoffice.org/en/projectrelease/languagetool-21
# - Usage: java -jar LanguageTool.jar [OPTION]... FILE
#  FILE                      plain text file to be checked
#  Available options:
#   -r, --recursive          work recursively on directory, not on a single file
#   -c, --encoding ENC       character set of the input text, e.g. utf-8 or latin1
#   -b                       assume that a single line break marks the end of a paragraph
#   -l, --language LANG      the language code of the text, e.g. en for English, en-GB for British English
#   --list                   Print all available languages and exit
#   -adl, --autoDetect       auto-detect the language of the input text
#   -m, --mothertongue LANG  the language code of your first language, used to activate false-friend checking
#   -d, --disable RULES      a comma-separated list of rule ids to be disabled (use no spaces between ids)
#   -e, --enable RULES       a comma-separated list of rule ids to be enabled (use no spaces between ids)
#   -t, --taggeronly         don't check, but only print text analysis (sentences, part-of-speech tags)
#   -u, --list-unknown       also print a summary of words from the input that LanguageTool doesn't know
#   -b2, --bitext            check bilingual texts with a tab-separated input file,
#                            see http://languagetool.wikidot.com/checking-translations-bilingual-texts
#   --api                    print results as XML
#   -p, --profile            print performance measurements
#   -v, --verbose            print text analysis (sentences, part-of-speech tags) to STDERR
#   --version                print LanguageTool version number and exit
#   -a, --apply              automatically apply suggestions if available, printing result to STDOUT
#   --xmlfilter              remove XML/HTML elements from input before checking (this is deprecated)
# 


# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Show usage statement
#
if [ "$1" = "" ]; then
    script_name=$(basename $0)
    echo ""
    echo "Usage: $script_name [--trace] file"
    echo ""
    echo "Example:"
    echo ""
    echo "echo 'This be me car over over there.' > /tmp/bad-grammar-example.txt"
    echo "echo 'You seen it?' >> /tmp/bad-grammar-example.txt"
    echo "$0 /tmp/bad-grammar-example.txt"
    echo ""
    ## TODO: echo "echo 'My dawg have fleees' | export LANGUAGE_TOOL_HOME=/c/Program-Misc/OpenOffice/LanguageTool-2.1 $script_name --"
    echo "echo 'My dog have fleees' | export LANGUAGE_TOOL_HOME=/c/Program-Misc/OpenOffice/LanguageTool-2.1 $script_name --"
    echo ""
    echo "Notes:"
    echo "- use LANGUAGE_TOOL_HOME environment variable for distribution directory"
    echo "  ex: export LANGUAGE_TOOL_HOME=~/programs/java/LanguageTool-2.1"
    exit
fi

# Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--fubar" ]; then
	echo "fubar";
    elif [ "$1" = "--" ]; then
	shift 1;
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
file="$1"

# Make sure file pathname is absolute
script_dir=`dirname $0`
case $file in /*) ;; [a-zA-Z]:*) ;; *) file="$PWD/$file";; esac
if [ "$OSTYPE" = "cygwin" ]; then file=`cygpath.exe -wa "$file"`; fi

# The script must be run relative to the grammar checker directory
language_tool_home="$LANGUAGE_TOOL_HOME"
if [ "$language_tool_home" = "" ]; then language_tool_home=$script_dir; fi
cd "$language_tool_home"
## OLD: java -jar languagetool-commandline.jar "$file"
# Note: ignores MS Word smart quote check and English spelling
# TODO: try to use single invocation (e.g., one for both empty filename and actual one)
if [ "$file" != "" ]; then
    java -jar languagetool-commandline.jar --language en-US --disable 'EN_QUOTES[1],EN_QUOTES[2],MORFOLOGIK_RULE_EN_US' "$file";
else
    java -jar languagetool-commandline.jar --language en-US --disable 'EN_QUOTES[1],EN_QUOTES[2],MORFOLOGIK_RULE_EN_US';
fi
