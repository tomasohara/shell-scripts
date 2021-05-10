#!/usr/bin/env bash
#
# Runs the Stanford English PCFG parser on one or more files, printing just
# the trees (n.b., no dependency output).
#
# Notes:
# - uses STANFORD_PARSER_HOME environment variable for distribution directory
# - PCFG standas for Probabilistic Context Free Grammar
# - based on lexparser.sh with extensions for Cygwin
#
#------------------------------------------------------------------------
# Sample usage:
#
#    $ STANFORD_PARSER_HOME="c:/Program-Misc/stanford-parser-2013-04-05" ./run-stanford-parser.sh /tmp/bad-grammar-example.txt
#    Loading parser from serialized file edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz ... done [9.2 sec].
#    Parsing file: C:\cygwin\tmp\bad-grammar-example.txt
#    Parsing [sent. 1 len. 8]: This be me car over over there .
#    (ROOT
#      (S
#        (NP (DT This))
#        (VP (VB be)
#          (NP
#            (NP (PRP me) (NN car))
#            (PP (IN over)
#              (PP (IN over)
#                (NP (RB there))))))
#        (. .)))
#    
#    Parsing [sent. 2 len. 4]: You seen it ?
#    (ROOT
#      (S
#        (NP (PRP You))
#        (VP (VBN seen)
#          (NP (PRP it)))
#        (. ?)))
#    
#    Parsed file: C:\cygwin\tmp\bad-grammar-example.txt [2 sentences].
#    Parsed 12 words in 2 sentences (17.88 wds/sec; 2.98 sents/sec).
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
    echo ""
    echo "Usage: `basename $0` [--trace] file"
    echo ""
    echo "Example:"
    echo ""
    echo "echo 'This be me car over over there.' > /tmp/bad-grammar-example.txt"
    echo "echo 'You seen it?' >> /tmp/bad-grammar-example.txt"
    echo "$0 /tmp/bad-grammar-example.txt"
    echo ""
    echo "Notes:"
    echo "- use STANFORD_PARSER_HOME environment variable for distribution directory"
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

# Derive distribution directory from 
script_dir=`dirname $0`
if [ "$STANFORD_PARSER_HOME" != "" ]; then script_dir="$STANFORD_PARSER_HOME"; fi
classpath="$script_dir/*:"
if [ "$OSTYPE" == "cygwin" ]; then 
    classpath="$script_dir/*;"; 
    file=`cygpath.exe -wa "$file"`
fi

# Invoke the parser
java -mx1400m -cp $classpath edu.stanford.nlp.parser.lexparser.LexicalizedParser -outputFormat "penn" edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz "$file"
