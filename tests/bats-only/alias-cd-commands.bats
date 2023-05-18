#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-163836/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $PS1\n' "=========="
	test-1-actual 
	echo "=========" $'[PEXP\\[\\]ECT_PROMPT>' "========="
	test-1-expected 
	echo "============================"
	# ???: 'echo $PS1\n'=$(test-1-actual)
	# ???: '[PEXP\\[\\]ECT_PROMPT>'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	echo $PS1

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[PEXP\[\]ECT_PROMPT>
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-163836/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-3-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0" "========="
	test-3-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-3-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0"=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	unalias -a

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias | wc -l
$ for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
$ typeset -f | egrep '^\w+' | wc -l
0
0
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-163836/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-cp-mv\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-cp-mv\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-cp-mv

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-163836/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-6869\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-cp-mv/test-6869' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-6869\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-cp-mv/test-6869'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-6869

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-cp-mv/test-6869
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-163836/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $'1' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-6-actual)
	# ???: '1'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-163836/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"typeset -f | egrep '^\\w+' | wc -l\n" "=========="
	test-7-actual 
	echo "=========" $'0' "========="
	test-7-expected 
	echo "============================"
	# ???: "typeset -f | egrep '^\\w+' | wc -l\n"=$(test-7-actual)
	# ???: '0'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	typeset -f | egrep '^\w+' | wc -l

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
0
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-163836/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-8-actual 
	echo "=========" $'' "========="
	test-8-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-8-actual)
	# ???: ''=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-163836/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-9-actual 
	echo "=========" $'/tmp/test-cp-mv/test-6869' "========="
	test-9-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-9-actual)
	# ???: '/tmp/test-cp-mv/test-6869'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/tmp/test-cp-mv/test-6869
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-163836/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'chdir ..\n' "=========="
	test-10-actual 
	echo "=========" $'$ chdir test-6869/\n\x1b]1;test-cp-mv [/tmp/test-cp-mv]\x07\x1b]2;test-cp-mv [/tmp/test-cp-mv]\x07/tmp/test-cp-mv/test-6869\n\x1b]1;test-6869 [/tmp/test-cp-mv/test-6869]\x07\x1b]2;test-6869 [/tmp/test-cp-mv/test-6869]\x07' "========="
	test-10-expected 
	echo "============================"
	# ???: 'chdir ..\n'=$(test-10-actual)
	# ???: '$ chdir test-6869/\n\x1b]1;test-cp-mv [/tmp/test-cp-mv]\x07\x1b]2;test-cp-mv [/tmp/test-cp-mv]\x07/tmp/test-cp-mv/test-6869\n\x1b]1;test-6869 [/tmp/test-cp-mv/test-6869]\x07\x1b]2;test-6869 [/tmp/test-cp-mv/test-6869]\x07'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	chdir ..

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ chdir test-6869/
]1;test-cp-mv [/tmp/test-cp-mv]]2;test-cp-mv [/tmp/test-cp-mv]/tmp/test-cp-mv/test-6869
]1;test-6869 [/tmp/test-cp-mv/test-6869]]2;test-6869 [/tmp/test-cp-mv/test-6869]
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-163836/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'chdir ..\n' "=========="
	test-11-actual 
	echo "=========" $'$ chdir test-6869/\n\x1b]1;test-cp-mv [/tmp/test-cp-mv]\x07\x1b]2;test-cp-mv [/tmp/test-cp-mv]\x07/tmp/test-cp-mv/test-6869\n\x1b]1;test-6869 [/tmp/test-cp-mv/test-6869]\x07\x1b]2;test-6869 [/tmp/test-cp-mv/test-6869]\x07' "========="
	test-11-expected 
	echo "============================"
	# ???: 'chdir ..\n'=$(test-11-actual)
	# ???: '$ chdir test-6869/\n\x1b]1;test-cp-mv [/tmp/test-cp-mv]\x07\x1b]2;test-cp-mv [/tmp/test-cp-mv]\x07/tmp/test-cp-mv/test-6869\n\x1b]1;test-6869 [/tmp/test-cp-mv/test-6869]\x07\x1b]2;test-6869 [/tmp/test-cp-mv/test-6869]\x07'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	chdir ..

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ chdir test-6869/
]1;test-cp-mv [/tmp/test-cp-mv]]2;test-cp-mv [/tmp/test-cp-mv]/tmp/test-cp-mv/test-6869
]1;test-6869 [/tmp/test-cp-mv/test-6869]]2;test-6869 [/tmp/test-cp-mv/test-6869]
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-163836/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-12-actual 
	echo "=========" $'$ mkdir testdir89 testdir90\n$ echo "Testfile1" > testdir89/f11.txt\n$ echo "Testfile2" > testdir89/f12.txt' "========="
	test-12-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-12-actual)
	# ???: '$ mkdir testdir89 testdir90\n$ echo "Testfile1" > testdir89/f11.txt\n$ echo "Testfile2" > testdir89/f12.txt'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir testdir89 testdir90
$ echo "Testfile1" > testdir89/f11.txt
$ echo "Testfile2" > testdir89/f12.txt
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-163836/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pushd-q testdir89\n' "=========="
	test-13-actual 
	echo "=========" $'$ ls\n$ linebr\n$ popd-q \n$ ls\nf11.txt  f12.txt\n--------------------------------------------------------------------------------\ntestdir89  testdir90' "========="
	test-13-expected 
	echo "============================"
	# ???: 'pushd-q testdir89\n'=$(test-13-actual)
	# ???: '$ ls\n$ linebr\n$ popd-q \n$ ls\nf11.txt  f12.txt\n--------------------------------------------------------------------------------\ntestdir89  testdir90'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	pushd-q testdir89

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ ls
$ linebr
$ popd-q 
$ ls
f11.txt  f12.txt
--------------------------------------------------------------------------------
testdir89  testdir90
END_EXPECTED
}
