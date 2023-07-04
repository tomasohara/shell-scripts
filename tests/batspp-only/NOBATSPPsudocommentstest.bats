#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-85745/test-1"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TEMP_PATH="./temp/kernelinfo.txt"\n' "=========="
	test-1-actual 
	echo "=========" $'' "========="
	test-1-expected 
	echo "============================"
	# ???: 'TEMP_PATH="./temp/kernelinfo.txt"\n'=$(test-1-actual)
	# ???: ''=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	TEMP_PATH="./temp/kernelinfo.txt"

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-85745/test-3"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'sudo -S apt search caffeine < ./temp/pass.txt\n' "=========="
	test-3-actual 
	echo "=========" $'Sorting... 0%rd for aveey: Sorting... 0%Sorting... 0%Sorting... Done\nFull Text Search... 50%Full Text Search... 50%Full Text Search... Done\n\x1b[32mcaffeine\x1b[0m/jammy,jammy,now 2.9.8-2 all [residual-config]\n  prevent the desktop becoming idle in full-screen mode' "========="
	test-3-expected 
	echo "============================"
	# ???: 'sudo -S apt search caffeine < ./temp/pass.txt\n'=$(test-3-actual)
	# ???: 'Sorting... 0%rd for aveey: Sorting... 0%Sorting... 0%Sorting... Done\nFull Text Search... 50%Full Text Search... 50%Full Text Search... Done\n\x1b[32mcaffeine\x1b[0m/jammy,jammy,now 2.9.8-2 all [residual-config]\n  prevent the desktop becoming idle in full-screen mode'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	sudo -S apt search caffeine < ./temp/pass.txt

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Sorting... 0%rd for aveey: Sorting... 0%Sorting... 0%Sorting... Done
Full Text Search... 50%Full Text Search... 50%Full Text Search... Done
[32mcaffeine[0m/jammy,jammy,now 2.9.8-2 all [residual-config]
  prevent the desktop becoming idle in full-screen mode
END_EXPECTED
}
