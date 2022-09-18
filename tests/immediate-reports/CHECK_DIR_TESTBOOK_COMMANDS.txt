#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

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

	unalias -a
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	TMP=temp/tmp
	source $AVEE_BIN/_dir-aliases.bash
	actual=$(test2-assert3-actual)
	expected=$(test2-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert3-actual () {
	alias | wc -l
}
function test2-assert3-expected () {
	echo -e '8'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test3-assert1-actual)
	expected=$(test3-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert1-actual () {
	alias | wc -l
}
function test3-assert1-expected () {
	echo -e '8'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test4-assert1-actual)
	expected=$(test4-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test4-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test4-assert1-expected () {
	echo -e '2'
}

@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-$$
	cd "$temp_dir"
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	touch file1
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

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
	LS ${opts} "$@" 2>&1 | $PAGER;
}
function test8-assert1-expected () {
	echo -e 'function dir-proper () { $LS ${dir_options} --directory "$@" 2>&1 | $PAGER; }alias ls-full=\'$LS ${core_dir_options}\'function dir-full () { ls-full "$@" 2>&1 | $PAGER; }## TODO: WH with the grep (i.e., isn\'t there a simpler way)?function dir-sans-backups () { $LS ${dir_options} "$@" 2>&1 | $GREP -v \'~[0-9]*~\' | $PAGER; }# dir-ro/dir-rw(spec): show files that are read-only/read-write for the userfunction dir-ro () { $LS ${dir_options} "$@" 2>&1 | $GREP -v \'^..w\' | $PAGER; }function dir-rw () { $LS ${dir_options} "$@" 2>&1 | $GREP \'^..w\' | $PAGER; }'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	bash $AVEE_BIN/_dir-aliases.bash
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
	ls -l
}
function test10-assert1-expected () {
	echo -e 'total 0-rw-rw-r-- 1 aveey aveey 0 Sep 13 22:26 file1lrwxrwxrwx 1 aveey aveey 5 Sep 13 22:26 link1 -> file1'
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test12-assert1-actual)
	expected=$(test12-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert1-actual () {
	ls -l
}
function test12-assert1-expected () {
	echo -e 'total 0-rw-rw-r-- 1 aveey aveey 0 Sep 13 22:26 file1lrwxrwxrwx 1 aveey aveey 5 Sep 13 22:26 link1 -> file1lrwxrwxrwx 1 aveey aveey 4 Sep 13 22:26 temp-link -> /tmp'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test14-assert1-actual)
	expected=$(test14-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert1-actual () {
	ls -l
}
function test14-assert1-expected () {
	echo -e 'total 0-rw-rw-r-- 1 aveey aveey  0 Sep 13 22:26 file1lrwxrwxrwx 1 aveey aveey  5 Sep 13 22:26 link1 -> file1lrwxrwxrwx 1 aveey aveey 16 Sep 13 22:26 temp-link -> /home/aveey/temp'
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	alias ln-symbolic-force='ln-symbolic --force'
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test18-assert1-actual)
	expected=$(test18-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test18-assert1-actual () {
	ls -l
}
function test18-assert1-expected () {
	echo -e 'total 0-rw-rw-r-- 1 aveey aveey  0 Sep 13 22:26 file1lrwxrwxrwx 1 aveey aveey  5 Sep 13 22:26 link1 -> file1lrwxrwxrwx 1 aveey aveey 16 Sep 13 22:26 temp-link -> /home/aveey/temp'
}
