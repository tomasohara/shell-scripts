#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

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

	temp_dir=$TMP/test-9890
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

	function asc-it () { dobackup.sh "$1"; asc < BACKUP/"$1" >| "$1"; }
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	free -m > freemem_mb.txt
	linebr
	ls -l ./backup/
	linebr
	actual=$(test7-assert6-actual)
	expected=$(test7-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert6-actual () {
	cat ./backup/freemem_mb.txt
}
function test7-assert6-expected () {
	echo -e "Backing up 'freemem_mb.txt' to './backup/freemem_mb.txt'bash: BACKUP/freemem_mb.txt: No such file or directory--------------------------------------------------------------------------------total 4-r--r--r-- 1 aveey aveey 207 Sep  6 21:34 freemem_mb.txt--------------------------------------------------------------------------------total        used        free      shared  buff/cache   availableMem:            3597        2035         286         148        1275        1176Swap:            511          56         455"
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	alias remove-cr='tr -d "\r"'
	alias perl-slurp='perl -0777'
	alias alt-remove-cr='perl-slurp -pe "s/\r//g;"'
	function remove-cr-and-backup () { dobackup.sh "$1"; remove-cr < backup/"$1" >| "$1"; }
	alias perl-remove-cr='perl -i.bak -pn -e "s/\r//;"'
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	perl-slurp -v
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	function test-text () { printf "THIS IS A TEST. \rTHIS IS ALSO A TEST\r. THIS IS A TEST TOO."; }
	test-text
	printf "\n"
	linebr
	test-text | remove-cr
	printf "\n"
	linebr
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	ps -l > process_list.txt
	actual=$(test11-assert2-actual)
	expected=$(test11-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert2-actual () {
	remove-cr-and-backup process_list.txt
}
function test11-assert2-expected () {
	echo -e "Backing up 'process_list.txt' to './backup/process_list.txt'"
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	alias intersection='intersection.perl'
	alias difference='intersection.perl -diff'
	alias line-intersection='intersection.perl -line'
	alias line-difference='intersection.perl -diff -line'
	function last-n-with-header () { head --lines=1 "$2"; tail --lines="$1" "$2"; }
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	ps -u > ntest1.txt
	ps -l > ntest2.txt
	actual=$(test14-assert3-actual)
	expected=$(test14-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert3-actual () {
	intersection ntest1.txt ntest2.txt
}
function test14-assert3-expected () {
	echo -e 'PIDTTYTIMEbashbash11838pts/4pts/4ps'
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	free -m > free1.txt
	free > free2.txt
	actual=$(test16-assert3-actual)
	expected=$(test16-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert3-actual () {
	line-intersection free1.txt free2.txt
}
function test16-assert3-expected () {
	echo -e 'total        used        free      shared  buff/cache   available'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	line-difference free1.txt free2.txt
	linebr
	actual=$(test17-assert3-actual)
	expected=$(test17-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert3-actual () {
	line-difference free2.txt free1.txt
}
function test17-assert3-expected () {
	echo -e 'Mem:            3597        2048         273         148        1275        1163Swap:            511          56         455--------------------------------------------------------------------------------Mem:         3684144     2097148      281096      152028     1305900     1192428Swap:         524284       57948      466336'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	cat ntest1.txt
	linebr
	actual=$(test18-assert3-actual)
	expected=$(test18-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test18-assert3-actual () {
	show-line 4 ntest1.txt
}
function test18-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey       8355  0.0  0.1  11480  5700 pts/1    Ss   21:11   0:00 bashaveey       8510  0.6  2.0 390480 75972 pts/1    Sl+  21:12   0:08 /usr/bin/python3 /usr/bin/jupyter-notebookaveey      10268  0.0  0.1  11596  5812 pts/0    Ss+  21:20   0:00 bashaveey      10783  0.0  0.1  11480  5420 pts/2    Ss+  21:26   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11430  0.0  0.1  11480  5524 pts/3    Ss+  21:31   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11838  1.1  0.1  11480  5476 pts/4    Ss   21:34   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11905  0.0  0.0  12668  3408 pts/4    R+   21:34   0:00 ps -u--------------------------------------------------------------------------------aveey      10268  0.0  0.1  11596  5812 pts/0    Ss+  21:20   0:00 bash'
}

@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	last-n-with-header 4 ntest1.txt
	linebr
	actual=$(test19-assert3-actual)
	expected=$(test19-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test19-assert3-actual () {
	last-n-with-header 2 ntest2.txt
}
function test19-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey      10783  0.0  0.1  11480  5420 pts/2    Ss+  21:26   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11430  0.0  0.1  11480  5524 pts/3    Ss+  21:31   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11838  1.1  0.1  11480  5476 pts/4    Ss   21:34   0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.shaveey      11905  0.0  0.0  12668  3408 pts/4    R+   21:34   0:00 ps -u--------------------------------------------------------------------------------F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD0 S  1000   11838   11828  1  80   0 -  2870 do_wai pts/4    00:00:00 bash4 R  1000   11906   11838  0  80   0 -  3167 -      pts/4    00:00:00 ps'
}

@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
}
