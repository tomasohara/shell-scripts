#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-68048/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'function count-aliases { alias | wc -l; }\n' "=========="
	test-1-actual 
	echo "=========" $'$ function clear-aliases { unalias -a; }' "========="
	test-1-expected 
	echo "============================"
	# ???: 'function count-aliases { alias | wc -l; }\n'=$(test-1-actual)
	# ???: '$ function clear-aliases { unalias -a; }'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	function count-aliases { alias | wc -l; }

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ function clear-aliases { unalias -a; }
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-68048/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'clear-aliases\n' "=========="
	test-3-actual 
	echo "=========" $'$ count-aliases\n0' "========="
	test-3-expected 
	echo "============================"
	# ???: 'clear-aliases\n'=$(test-3-actual)
	# ???: '$ count-aliases\n0'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	clear-aliases

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ count-aliases
0
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-68048/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'function count-aliases { alias | wc -l; }\n' "=========="
	test-4-actual 
	echo "=========" $"$ function list-functions { typeset -f | egrep '^[A-ZZa-z_-]'; }\n$ function count-functions { list-functions | wc -l; }" "========="
	test-4-expected 
	echo "============================"
	# ???: 'function count-aliases { alias | wc -l; }\n'=$(test-4-actual)
	# ???: "$ function list-functions { typeset -f | egrep '^[A-ZZa-z_-]'; }\n$ function count-functions { list-functions | wc -l; }"=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	function count-aliases { alias | wc -l; }

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ function list-functions { typeset -f | egrep '^[A-ZZa-z_-]'; }
$ function count-functions { list-functions | wc -l; }
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-68048/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'BIN_DIR=$PWD/..\n' "=========="
	test-5-actual 
	echo "=========" $'$ echo $BIN_DIR\n# source $BIN_DIR/tomohara-aliases.bash\n/home/aveey/tom-project/shell-scripts/tests/..' "========="
	test-5-expected 
	echo "============================"
	# ???: 'BIN_DIR=$PWD/..\n'=$(test-5-actual)
	# ???: '$ echo $BIN_DIR\n# source $BIN_DIR/tomohara-aliases.bash\n/home/aveey/tom-project/shell-scripts/tests/..'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	BIN_DIR=$PWD/..

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo $BIN_DIR
# source $BIN_DIR/tomohara-aliases.bash
/home/aveey/tom-project/shell-scripts/tests/..
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-68048/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-6-actual 
	echo "=========" $'' "========="
	test-6-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-6-actual)
	# ???: ''=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-68048/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'clear\n' "=========="
	test-7-actual 
	echo "=========" $'use cls instead (or /bin/clear)' "========="
	test-7-expected 
	echo "============================"
	# ???: 'clear\n'=$(test-7-actual)
	# ???: 'use cls instead (or /bin/clear)'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	clear

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
use cls instead (or /bin/clear)
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-68048/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'help\n' "=========="
	test-8-actual 
	echo "=========" $"GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)\nThese shell commands are defined internally.  Type `help' to see this list.\nType `help name' to find out more about the function `name'.\nUse `info bash' to find out more about the shell in general.\nUse `man -k' or `info' to find out more about commands not in this list." "========="
	test-8-expected 
	echo "============================"
	# ???: 'help\n'=$(test-8-actual)
	# ???: "GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)\nThese shell commands are defined internally.  Type `help' to see this list.\nType `help name' to find out more about the function `name'.\nUse `info bash' to find out more about the shell in general.\nUse `man -k' or `info' to find out more about commands not in this list."=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	help

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
These shell commands are defined internally.  Type `help' to see this list.
Type `help name' to find out more about the function `name'.
Use `info bash' to find out more about the shell in general.
Use `man -k' or `info' to find out more about commands not in this list.
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-68048/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'history -c\n' "=========="
	test-9-actual 
	echo "=========" $'' "========="
	test-9-expected 
	echo "============================"
	# ???: 'history -c\n'=$(test-9-actual)
	# ???: ''=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	history -c

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-68048/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'hist\n' "=========="
	test-10-actual 
	echo "=========" $'1  [2023-04-06 20:32:50] echo $?\n    2  [2023-04-06 20:32:52] hist' "========="
	test-10-expected 
	echo "============================"
	# ???: 'hist\n'=$(test-10-actual)
	# ???: '1  [2023-04-06 20:32:50] echo $?\n    2  [2023-04-06 20:32:52] hist'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	hist

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1  [2023-04-06 20:32:50] echo $?
    2  [2023-04-06 20:32:52] hist
END_EXPECTED
}
