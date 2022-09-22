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

	temp_dir=$TMP/test-6411
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

	alias tab-sort="sort -t $'\t'"
	alias colon-sort="sort $SORT_COL2 -t ':'"
	alias colon-sort-rev-num='colon-sort -rn'
	function echoize { perl -00 -pe 's/\n(.)/ $1/g;'; }
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	cat ~/.bashrc | tab-sort
	linebr
	cat ~/.bashrc | colon-sort
	linebr
	cat ~/.bashrc | colon-sort-rev-num
	linebr
	cat ~/.bashrc | freq-sort
	linebr
}


@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}


@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}


@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}


@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test13-assert1-actual)
	expected=$(test13-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert1-actual () {
	cat ~/.bashrc | para-sort
}
function test13-assert1-expected () {
	echo -e "alias grep='grep --color=auto'alias fgrep='fgrep --color=auto'alias egrep='egrep --color=auto'fi"
}

@test "-r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"" {
	test_folder=$(echo /tmp/-r-~/.dircolors-&&-eval-"$(dircolors--b-~/.dircolors)"-||-eval-"$(dircolors--b)"-$$)
	mkdir $test_folder && cd $test_folder

}
