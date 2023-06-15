#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-203528/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias count-words='wc -w'\n" "=========="
	test-1-actual 
	echo "=========" $"$ alias count-lines='wc -l'\n$ echo abc def ght | count-words\n$ echo abc def ght | count-lines\n3\n1" "========="
	test-1-expected 
	echo "============================"
	# ???: "alias count-words='wc -w'\n"=$(test-1-actual)
	# ???: "$ alias count-lines='wc -l'\n$ echo abc def ght | count-words\n$ echo abc def ght | count-lines\n3\n1"=$(test-1-expected)
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
$ alias count-lines='wc -l'
$ echo abc def ght | count-words
$ echo abc def ght | count-lines
3
1
END_EXPECTED
}
