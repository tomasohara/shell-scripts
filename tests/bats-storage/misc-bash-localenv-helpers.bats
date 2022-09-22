#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

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

	BIN_DIR=$PWD/..
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
	echo -e '0'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-2800
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
	typeset -f | egrep '^\w+' | wc -l
}
function test5-assert1-expected () {
	echo -e '10'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	alias perlgrep='perlgrep.perl'
	function shell-check-full {
	shellcheck "$@";
	}
	function shell-check {
	# note: filters out following
	# - SC1090: Can't follow non-constant source. Use a directive to specify location.
	# - SC1091: Not following: ./my-git-credentials-etc.bash was not specified as input (see shellcheck -x).
	# - SC2009: Consider using pgrep instead of grepping ps output.
	# - SC2129: Consider using { cmd1; cmd2; } >> file instead of individual redirects.
	# - SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
	shell-check-full "$@" | perl-grep -para -v '(SC1090|SC1091|SC2009|SC2129|SC2164)';
	}
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test7-assert1-actual)
	expected=$(test7-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert1-actual () {
	shell-check --version
}
function test7-assert1-expected () {
	echo -e 'ShellCheck - shell script analysis toolversion: 0.8.0license: GNU General Public License, version 3website: https://www.shellcheck.net'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test8-assert1-actual)
	expected=$(test8-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert1-actual () {
	shell-check $BIN_DIR/tomohara-settings.bash
}
function test8-assert1-expected () {
	echo -e 'In /home/aveey/tom-project/shell-scripts/tests/../tomohara-settings.bash line 10:add-python-path $HOME/python/Mezcla/mezcla^---^ SC2086 (info): Double quote to prevent globbing and word splitting.'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test9-assert1-actual)
	expected=$(test9-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert1-actual () {
	shell-check $BIN_DIR/cs_setup.sh
}
function test9-assert1-expected () {
	echo -e 'In /home/aveey/tom-project/shell-scripts/tests/../cs_setup.sh line 1:#! /bin/csh -f^-- SC1071 (error): ShellCheck only supports sh/bash/dash/ksh scripts. Sorry!'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	function downcase-stdin { perl -pe "use open ':std', ':encoding(UTF-8)'; s/.*/\L$&/;"; }
	alias hoy=todays-date
	function sleepyhead() {
	log_file="$HOME/temp/sleepyhead.$(todays-date).log"
	echo "start: $(date)" >> "$log_file"
	command sleepyhead >> "$log_file" 2>&1 &
	echo "end: $(date)" $'\n' >> "$log_file"
	}
	alias sleepy='sleepyhead'
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

}
