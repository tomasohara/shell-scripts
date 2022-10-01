#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
	shopt -s expand_aliases
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test2-assert4-actual)
	expected=$(test2-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test2-assert4-expected () {
	echo -e '00'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	source _dir-aliases.bash
	actual=$(test3-assert2-actual)
	expected=$(test3-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert2-actual () {
	alias | wc -l
}
function test3-assert2-expected () {
	echo -e '8'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-7071
	cd "$temp_dir"
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test5-assert1-actual)
	expected=$(test5-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test5-assert1-actual () {
	alias | wc -l
}
function test5-assert1-expected () {
	echo -e '9'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test6-assert1-actual)
	expected=$(test6-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test6-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test6-assert1-expected () {
	echo -e '2'
}

@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	skip_dirs=""
	if [[ $(grep --version) =~ Copyright.*2[0-9][0-9][0-9] ]]; then skip_dirs="-d skip"; fi
	actual=$(test7-assert3-actual)
	expected=$(test7-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert3-actual () {
	grep -V
}
function test7-assert3-expected () {
	echo -e 'grep (GNU grep) 3.7Copyright (C) 2021 Free Software Foundation, Inc.License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.This is free software: you are free to change and redistribute it.There is NO WARRANTY, to the extent permitted by law.'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	GREP="/bin/grep"
	EGREP="$GREP -E"
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	{
	function gr () { $GREP $MY_GREP_OPTIONS -i "$@"; }
	function gr- () { $GREP $MY_GREP_OPTIONS "$@"; }
	function grep-missing () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP ":0"; }
	function grep-to-less () { $EGREP $MY_GREP_OPTIONS "$@" | $PAGER_NOEXIT -p"$1"; }
	alias grepl-='grep-to-less'
	function grepl () { pattern="$1"; shift; grep-to-less "$pattern" -i "$@"; }
	}
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	mkdir testdir1 testdir2
	echo "As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.
	" > testgrep1
	echo "sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum" > testgrep2
	echo "no mentions here" > testgrep3
	echo "Passwords are generally case sensitive" > testgrep4
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	grep sensitive testgrep1 testgrep2 testgrep3 testgrep4
	gu sensitive testgrep1 testgrep2 testgrep3 testgrep4
	gu- sensitive testgrep1 testgrep2 testgrep3 testgrep4
}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	function gr-less () { gr "$@" | $PAGER; }
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	alias grep-nonascii='perlgrep.perl "[\x80-\xFF]"'
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	function findspec-all () { /usr/bin/find "$1" -follow -iname \*"$2"\* "$3" "$4" "$5" "$6" "$7" "$8" "$9" -print 2>&1 | $GREP -v '^find: '; }
	function fs () { findspec . "$@" | $EGREP -iv '(/(backup|build)/)'; } 
	function fs-ls () { fs "$@" -exec ls -l {} \; ; }
	alias fs-='findspec-all .'
	function findgrep () { find "$1" -iname \*"$2"\* -exec $GREP $findgrep_opts "$3" "$4" "$5" "$6" "$7" "$8" "$9" \{\} /dev/null \;; }
	function findgrep- () { find "$1" -iname "$2" -print -exec $GREP $findgrep_opts "$3" "$4" "$5" "$6" "$7" "$8" "$9" \{\} \;; }
	function fgr () { findgrep . "$@" | $EGREP -v '((/backup)|(/build))'; }
	function fgr-ext () { findgrep-ext . "$@" | $EGREP -v '(/(backup)|(build)/)'; }
	alias fgr-py='fgr-ext py'
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	function prepare-find-files-here () {
	if [ "$1" != "" ]; then
	echo "Error: No arguments accepted; did you mean find-files-here?"
	return
	fi
	local brief_opts="R"
	local full_opts="alR"
	local brief_file="ls-$brief_opts.list"
	local full_file="ls-$full_opts.list"
	local current_files=($full_file $full_file.log $brief_file $brief_file.log)
	# Rename existing files with file date as suffix (TODO move into ./backup)
	# shellcheck disable=SC2068
	rename-with-file-date ${current_files[@]}
	# Perform the actual listings, putting errors in the .log file for each listing
	# Note: If root directory, filters out special directories (TODO: make optional and/or overridable).
	## TODO: use approach based on filter variable and to avoid redundant hard-coding
	## TODO: ** resolve intermittent problem when running under /
	if [ "$PWD" = "/" ]; then
	($NICE $LS -$brief_opts | $EGREP -v '^\.(/(cdrom|dev|media|mnt|proc|run|sys|snap)$)' | perl -pe 's/^\./\n$&/;' > "$brief_file") 2> "$brief_file".log
	($NICE $LS -$full_opts | $EGREP -v '^\.(/(cdrom|dev|media|mnt|proc|run|sys|snap)$)' | perl -pe 's/^\./\n$&/;' > "$full_file") 2> "$full_file".log
	else
	($NICE $LS -$brief_opts | perl -pe 's/^\./\n$&/;' > "$brief_file") 2> "$brief_file".log
	($NICE $LS -$full_opts | perl -pe 's/^\./\n$&/;' > "$full_file") 2> "$full_file".log
	fi;
	# shellcheck disable=SC2068
	$LS -lh ${current_files[@]}
	}
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	function find-files-there () { perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('"$1"'))' | $PAGER_NOEXIT -p "$1"; }
	alias find-files='find-files-here'
	alias make-file-listing='listing="ls-aR.list"; dobackup.sh "$listing"; $LS -aR >| "$listing" 2>&1'
}
