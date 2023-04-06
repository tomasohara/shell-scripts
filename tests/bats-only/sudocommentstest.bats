#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	TEMP_PATH="./temp/kernelinfo.txt"
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test1-assert1-actual)
	expected=$(test1-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert1-actual () {
	sudo -S apt search caffeine < ./temp/pass.txt
}
function test1-assert1-expected () {
	echo -e 'Sorting... 0%rd for aveey: Sorting... 0%Sorting... 0%Sorting... DoneFull Text Search... 50%Full Text Search... 50%Full Text Search... Done\x1b[32mcaffeine\x1b[0m/jammy,jammy,now 2.9.8-2 all [residual-config]prevent the desktop becoming idle in full-screen mode'
}
