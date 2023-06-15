#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-201382/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias count-words='wc -w'\n" "=========="
	test-1-actual 
	echo "=========" $'' "========="
	test-1-expected 
	echo "============================"
	# ???: "alias count-words='wc -w'\n"=$(test-1-actual)
	# ???: ''=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	alias count-words='wc -w'

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-201382/test-3"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo abc def ght | count-words\n' "=========="
	test-3-actual 
	echo "=========" $'3' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo abc def ght | count-words\n'=$(test-3-actual)
	# ???: '3'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo abc def ght | count-words

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
3
END_EXPECTED
}
