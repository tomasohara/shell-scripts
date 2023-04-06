#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test0-assert1-actual)
	expected=$(test0-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test0-assert1-actual () {
	echo "Hello"
}
function test0-assert1-expected () {
	echo -e 'Hello'
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
	echo "This is a test" | wc -c
}
function test1-assert1-expected () {
	echo -e '15'
}

@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test2-assert1-actual)
	expected=$(test2-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert1-actual () {
	iwconfig | tee wireless_info.txt
}
function test2-assert1-expected () {
	echo -e 'lo        no wireless extensions.'
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
	cat wireless_info.txt
}
function test3-assert1-expected () {
	echo -e 'wlp4s0    IEEE 802.11  ESSID:"Sudhir_DHFibernet"  Mode:Managed  Frequency:2.432 GHz  Access Point: 6C:14:6E:5A:B7:58   Bit Rate=130 Mb/s   Tx-Power=3 dBm   Retry short limit:7   RTS thr:off   Fragment thr:offPower Management:onLink Quality=49/70  Signal level=-61 dBm  Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0Tx excessive retries:1  Invalid misc:1   Missed beacon:0'
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
	echo "Done"
}
function test4-assert1-expected () {
	echo -e 'Done'
}

@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

}
