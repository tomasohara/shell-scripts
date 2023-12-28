# Bash aliases and functions for workinjg with the Perlfect indexing system

# NOTES:
# -  Indexing in a particular directory (e.g., ~/NOTES_INDEX) includes the
# parent directory during the search (see /home/tom/bin/perlfect/conf.perl).
#
# TODO: replace $2 ... $9 with $@ (or "$@")
# - Have index_dir invoke create_index if necessary
# - Show statistics on time taken and memory consumed (both via 'time <cmd>').
# - create variables for names of indexing directories (main-notes-index and all-notes-index)
#

if [ "$perlfectdir" = "" ]; then perlfectdir=~/bin/perlfect-3.30; fi

function aux-create-index () {
	mkdir -p $1; 
	copy $perlfectdir/conf/*.* $1;
	ls -dF $1;
	ls -alt $1
}

function aux-index-dir () {
	local dir=$1
	shift
	nice -19 $perlfectdir/do_indexing.sh --index-dir $dir "$@"
}

function aux-debug-index-dir () {
	local dir=$1
	shift
	nice -19 $perlfectdir/do_indexing.sh --dump --debug-level 5 --index-dir $dir "$@"
}

function aux-index-type-in-dir () { 
	local dir=$1
	export EXTENSIONS="$2"
	shift; shift
	aux-index-dir $dir "$@"
	unset EXTENSIONS
}

function aux-debug-index-type-in-dir () { 
	local dir=$1
	export EXTENSIONS="$2"
	shift; shift
	aux-debug-index-dir $dir "$@"
	unset EXTENSIONS
}

# TODO: address the problem with including symbolic links (infinite loop?)

function index-notes () {
	aux-debug-index-type-in-dir $HOME/main-notes-index "text" --document-root ~ --include-links 0 
}

function index-all-notes () { 
	aux-debug-index-type-in-dir $HOME/all-notes-index "txt text" --document-root ~ --include-links 1
}

# TODO: convert do_search.sh into Perl
function aux-search-dir () { 
	local index_dir=$1;
	shift; 
	$perlfectdir/do_search.sh --index-dir $index_dir "$@"
}
function aux-debug-search-dir () { 
	local debug_level=$DEBUG_LEVEL
	export DEBUG_LEVEL=5
	aux-search-dir "$@"
	export DEBUG_LEVEL=$debug_level
}


alias create-index-this-dir='aux-create-index $PWD/INDEX'
alias index-this-dir='aux-index-dir $PWD/INDEX'
alias debug-index-this-dir='aux-debug-index-dir $PWD/INDEX'
alias index-this-dir-by-type='aux-index-type-in-dir $PWD/INDEX'
alias debug-index-this-dir-by-type='aux-debug-index-type-in-dir $PWD/INDEX'

alias search-this-dir='aux-search-dir $PWD/INDEX'
alias debug-search-this-dir='aux-debug-search-dir $PWD/INDEX'

alias create-notes-indices='aux-create-index ~/main-notes-index; aux-create-index ~/all-notes-index'
alias search-notes='aux-search-dir ~/main-notes-index'
alias search-all-notes='aux-search-dir ~/all-notes-index'
