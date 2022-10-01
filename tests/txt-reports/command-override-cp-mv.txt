#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
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

	temp_dir=$TMP/test-1210
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

	other_file_args="-v"
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	if [ "$OSTYPE" = "solaris" ]; then other_file_args=""; fi
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	alias clear="echo 'use cls instead (or /bin/clear)'"
	alias cls="command clear -x"
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test10-assert1-actual)
	expected=$(test10-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert1-actual () {
	clear
}
function test10-assert1-expected () {
	echo -e 'use cls instead (or /bin/clear)'
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test11-assert1-actual)
	expected=$(test11-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert1-actual () {
	alias | grep cls
}
function test11-assert1-expected () {
	echo -e "alias clear='echo '\\''use cls instead (or /bin/clear)'\\'''alias cls='command clear -x'"
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	{
	# TODO: see if this is a shellcheck bug
	#    SC2034: MV appears unused. Verify it or export it.
	# shellcheck disable=SC2034
	MV="/bin/mv -i $other_file_args"
	}
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	alias mv='$MV'
	alias move='mv'
	alias move-force='move -f'
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	alias copy='$CP'
	alias copy-force='/bin/cp -fp $other_file_args'
	alias cp='/bin/cp -i $other_file_args'
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	alias rm='/bin/rm -i $other_file_args'
	alias delete='/bin/rm -i $other_file_args'
	alias del="delete"
	alias delete-force='/bin/rm -f $other_file_args'
	alias remove-force='delete-force'
}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	alias remove-dir='/bin/rm -rv'
	alias delete-dir='remove-dir'
	alias remove-dir-force='/bin/rm -rfv'
	alias delete-dir-force='remove-dir-force'
}


@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	alias copy-readonly='copy-readonly.sh'
	function copy-readonly-spec () {
	local spec="$1"
	local dir="$2"
	if [[ ("$3" != "") || ($dir = "") || ($spec == "") ]]; then
	echo "Usage: copy-readonly-spec pattern dir";
	return
	fi
	# effing shellcheck (SC2086: Double quote to prevent globbing)
	# shellcheck disable=SC2086
	for f in $($LS $spec); do copy-readonly "$f" "$dir"; done
	function copy-readonly-to-dir () {
	local dir="$1"
	shift
	for f in "$@"; do copy-readonly "$f" "$dir"; done
	}
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	export NICE="nice -19"
	export TIME_CMD="/usr/bin/time"
}


@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"
}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	mv abc ./mvtest_dir1
	move def ./mvtest_dir1
	move-force ghi ./mvtest_dir1
	ls -l
	linebr
	ls -l ./mvtest_dir1
}


@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	cp abc ./cptest_dir1
	copy def ./cptest_dir1
	copy-force ghi ./cptest_dir1
	ls -l
	linebr
	ls -l ./cptest_dir1
	actual=$(test24-assert9-actual)
	expected=$(test24-assert9-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test24-assert9-actual () {
	linebr
}
function test24-assert9-expected () {
	echo -e "removed './mvtest_dir1/abc'removed './mvtest_dir1/ghi'removed './mvtest_dir1/def'removed directory './mvtest_dir1'--------------------------------------------------------------------------------'abc' -> './cptest_dir1/abc''def' -> './cptest_dir1/def''ghi' -> './cptest_dir1/ghi'--------------------------------------------------------------------------------total 4-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 abcdrwxrwxr-x 2 aveey aveey 4096 Sep 10 22:57 cptest_dir1-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 def-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 ghi--------------------------------------------------------------------------------total 0-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 abc-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 def-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 ghi--------------------------------------------------------------------------------"
}

@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	mkdir TDIR1 TDIR2 TDIR3 TDIR4
	ls -l
	remove-dir "TDIR1"
	delete-dir "TDIR2"
	remove-dir-force TDIR3
	delete-dir-force TDIR4
	ls -l
	actual=$(test25-assert10-actual)
	expected=$(test25-assert10-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test25-assert10-actual () {
	linebr
}
function test25-assert10-expected () {
	echo -e "removed './abc'removed './cptest_dir1/abc'removed './cptest_dir1/ghi'removed './cptest_dir1/def'removed directory './cptest_dir1'removed './def'removed './ghi'--------------------------------------------------------------------------------total 16-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 abc-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 def-rw-rw-r-- 1 aveey aveey    0 Sep 10 22:57 ghidrwxrwxr-x 2 aveey aveey 4096 Sep 10 22:57 TDIR1drwxrwxr-x 2 aveey aveey 4096 Sep 10 22:57 TDIR2drwxrwxr-x 2 aveey aveey 4096 Sep 10 22:57 TDIR3drwxrwxr-x 2 aveey aveey 4096 Sep 10 22:57 TDIR4--------------------------------------------------------------------------------removed directory 'TDIR1'removed directory 'TDIR2'removed directory 'TDIR3'removed directory 'TDIR4'--------------------------------------------------------------------------------total 0-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 abc-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 def-rw-rw-r-- 1 aveey aveey 0 Sep 10 22:57 ghi--------------------------------------------------------------------------------"
}

@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	alias copy-readonly='copy-readonly.sh'
	function copy-readonly-spec () {
	local spec="$1"
	local dir="$2"
	if [[ ("$3" != "") || ($dir = "") || ($spec == "") ]]; then
	echo "Usage: copy-readonly-spec pattern dir";
	return
	fi
	# effing shellcheck (SC2086: Double quote to prevent globbing)
	# shellcheck disable=SC2086
	for f in $($LS $spec); do copy-readonly "$f" "$dir"; done
	function copy-readonly-to-dir () {
	local dir="$1"
	shift
	for f in "$@"; do copy-readonly "$f" "$dir"; done
	}
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	copy-readonly
	rm -rf ./*
	mkdir testdir1
	copy-readonly ~/.bashrc ./testdir1
	ls -l 
	linebr
	cat ./testdir1/.bashrc
}


@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

	export NICE="nice -19"
	export TIME_CMD="/usr/bin/time"
	alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"
}


@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test30-assert1-actual)
	expected=$(test30-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test30-assert1-actual () {
	ls -l 
}
function test30-assert1-expected () {
	echo -e 'total 4drwxrwsr-x 2 aveey aveey 4096 Sep 10 22:57 testdir1'
}
