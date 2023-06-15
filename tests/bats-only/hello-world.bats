#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-213970/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"echo 'Hello world' | wc -l\n" "=========="
	test-1-actual 
	echo "=========" $'1' "========="
	test-1-expected 
	echo "============================"
	# ???: "echo 'Hello world' | wc -l\n"=$(test-1-actual)
	# ???: '1'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	echo 'Hello world' | wc -l

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1
END_EXPECTED
}
