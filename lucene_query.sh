#! /bin/csh -f
#
# lucene_query.sh: run query through lucene search engine
#
# TODO:
# - Add indexing notes.
# - Add query format specification.
#
#------------------------------------------------------------------------
# Indexing example:
# $ pwd
# /c/cartera-de-tomas/convera/categorization# $ 
# $ export LUCENE_HOME="C:\cygwin\home\graphling\TOOLS\LUCENE"
#
#------------------------------------------------------------------------
# Query examples from queryparsersyntax.html:
#
# field search:
#   title:"The Right Way" AND text:go
# wildcard:
#    te?t 
#    test*
#    te*t
# proximity search:
#    "jakarta apache"~10
# boolean search:
#    "jakarta apache" OR jakarta
#    "jakarta apache" AND "jakarta lucene"
#    "jakarta apache" NOT "jakarta lucene"
# grouping:
#    (jakarta OR apache) AND website
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1
set corpus_dir = .

# Parse command-line arguments
if ("$1" == "") then
    set script_name = `basename $0`
    ## set log_name = `echo "$script_name" | perl -pe "s/.sh/.log/;"`
    echo ""
    echo "usage: `basename $0` [--corpus-dir]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "-") then
	echo "Using default options"
    else if ("$1" == "--corpus-dir") then
	set corpus_dir = "$2"
	shift
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end
set query = "$*"

set lucene_dir = `printenv LUCENE_HOME`
if ("$lucene_dir" == "") set lucene_dir = /home/graphling/TOOLS/LUCENE/lucene-1.3-final/build
if ("$OSTYPE" == "cygwin") set lucene_dir = `winpath "$lucene_dir"`

# Set environment
setenv CLASSPATH $lucene_dir/lucene-demos-1.4-rc1-dev.jar:$lucene_dir/lucene-1.4-rc1-dev.jar

# Run the query
cd $corpus_dir
echo "$query" | java org.apache.lucene.demo.BatchSearchFiles
