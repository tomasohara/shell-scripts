#! /bin/csh -f
#
# run_brill_tagger.sh: script to invoke the Brill part-of-speech tagger
#
# NOTE: this script just runs the tagger. That is, it does no preprocessing,
#       unlike do_tagger.sh
#
# usage: run_brill_tagger.sh file
#
# environment variables:
#    CORPUS: corpus data files to use (eg, WSJ or BROWN)
#
# TODO: add sanity checks (e.g., check for lines too long, make sure the tagger goes through all states)
#
#------------------------------------------------------------------------
# NOTES (from the Brill Tagger README):
#
# To execute the program, type:
# 
# tagger LEXICON YOUR-CORPUS BIGRAMS LEXICALRULEFULE CONTEXTUALRULEFILE 
# 
# where YOUR-CORPUS is the file name of the corpus you wish to have
# tagged, and the other files are all provided with the tagger.
# 
# Options (which are typed after the file names) are:
# 
# -h             :: help
# 
# -w wordlist    :: provide an extra set of words beyond those in LEXICON.
# 	          For more information about this, read README.LONG.
# 
# -i filename    :: writes intermediate results from start state tagger
# 		  into filename
# 
# -s number      :: processes the corpus to be tagged "number" lines at
# 		  a time.  This should be specified if memory problems
# 	          result from trying to process too large a corpus at
# 		  once.  For more information about this, read
# 		  README.LONG. 
# 
# -S 	       :: use start state tagger only.
# 
# -F             :: use final state tagger only.  In this case,
# 	         YOUR-CORPUS is a tagged corpus, whose taggings will
# 	         be changed according to the final-state-tagger
# 	         contextual rules.  YOUR-CORPUS should be a tagged
# 	         corpus ONLY when using this option.

# Set up the common GraphLing environment
if ($?BRILL_HOME == 0) setenv BRILL_HOME c:/Program-Misc/brill-tagger

# Uncomment the following to enable script tracing
## set echo = 1

# Show a usage statement if no arguments given
if ("$1" == "") then
    echo "usage: `basename $0` file"
    echo ""
    echo "examples:"
    echo ""
    echo "echo 'How now brown cow ?' >| how-now.text'"
    echo "$0 how-now.text"
    echo ""
    echo "prep_brill.perl file.text > file.prep"
    echo "$0 file.prep > file.tag"
    echo ""
    echo "note: use CORPUS environment variable to specify alternative corpus"
    exit
endif


# Determine where the source file is
set file_dir = `dirname $1`
set file = `basename $1`
if ($file_dir == ".") set file_dir = `pwd`/

# Convert relative pathnames to absolute
# ex: ".." => "/home/graphling/"
if ($file_dir =~ .*) set file_dir = `pwd`/$file_dir

# Determine the extension for the corpus-specific data files
set ext = ""
if ($?CORPUS != 0) then
    set ext = ".$CORPUS"
endif


# Change into the Brill bin directory, and verify that data files exist
set old_cwd = `pwd`
cd ${BRILL_HOME}/Bin_and_Data
if (! -e LEXICON$ext) then
    echo "WARNING: lexicon file (LEXICON$ext) not found for corpus $CORPUS"
endif

# Run the tagger (from within it's directory)
## tagger LEXICON.WSJ ${file_dir}/${file} BIGRAMS LEXICALRULEFILE CONTEXTUALRULEFILE
if (! -e BIGRAMS$ext) ln -s BIGRAMS BIGRAMS$ext
## set echo = 1
./tagger LEXICON$ext $file_dir/$file BIGRAMS$ext LEXICALRULEFILE$ext CONTEXTUALRULEFILE$ext

# Restore the directory (in case extensions for later processing needed)
# NOTE: pushd/popd not used since that write to stdout
cd $old_cwd
