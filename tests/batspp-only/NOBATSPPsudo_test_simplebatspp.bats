#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-87833/test-1"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/X/g"" \n' "=========="
	test-1-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/user/g""' "========="
	test-1-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/X/g"" \n'=$(test-1-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/user/g""'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/X/g"" 

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/user/g""
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-87833/test-3"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Hello"\n' "=========="
	test-3-actual 
	echo "=========" $'Hello' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo "Hello"\n'=$(test-3-actual)
	# ???: 'Hello'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo "Hello"

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Hello
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-87833/test-4"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "This is a test" | wc -c\n' "=========="
	test-4-actual 
	echo "=========" $'15' "========="
	test-4-expected 
	echo "============================"
	# ???: 'echo "This is a test" | wc -c\n'=$(test-4-actual)
	# ???: '15'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	echo "This is a test" | wc -c

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
15
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-87833/test-5"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'iwconfig | tee wireless_info.txt\n' "=========="
	test-5-actual 
	echo "=========" $'lo        no wireless extensions.' "========="
	test-5-expected 
	echo "============================"
	# ???: 'iwconfig | tee wireless_info.txt\n'=$(test-5-actual)
	# ???: 'lo        no wireless extensions.'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	iwconfig | tee wireless_info.txt

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
lo        no wireless extensions.
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-87833/test-6"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat wireless_info.txt\n' "=========="
	test-6-actual 
	echo "=========" $'wlp4s0    IEEE 802.11  ESSID:"Sudhir_DHFibernet"  \n          Mode:Managed  Frequency:2.447 GHz  Access Point: 6C:14:6E:5A:B7:58   \n          Bit Rate=78 Mb/s   Tx-Power=3 dBm   \n          Retry short limit:7   RTS thr:off   Fragment thr:off\n          Power Management:on\n          Link Quality=42/70  Signal level=-68 dBm  \n          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0\n          Tx excessive retries:0  Invalid misc:3   Missed beacon:0' "========="
	test-6-expected 
	echo "============================"
	# ???: 'cat wireless_info.txt\n'=$(test-6-actual)
	# ???: 'wlp4s0    IEEE 802.11  ESSID:"Sudhir_DHFibernet"  \n          Mode:Managed  Frequency:2.447 GHz  Access Point: 6C:14:6E:5A:B7:58   \n          Bit Rate=78 Mb/s   Tx-Power=3 dBm   \n          Retry short limit:7   RTS thr:off   Fragment thr:off\n          Power Management:on\n          Link Quality=42/70  Signal level=-68 dBm  \n          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0\n          Tx excessive retries:0  Invalid misc:3   Missed beacon:0'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	cat wireless_info.txt

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
wlp4s0    IEEE 802.11  ESSID:"Sudhir_DHFibernet"  
          Mode:Managed  Frequency:2.447 GHz  Access Point: 6C:14:6E:5A:B7:58   
          Bit Rate=78 Mb/s   Tx-Power=3 dBm   
          Retry short limit:7   RTS thr:off   Fragment thr:off
          Power Management:on
          Link Quality=42/70  Signal level=-68 dBm  
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:3   Missed beacon:0
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-87833/test-7"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Done"\n' "=========="
	test-7-actual 
	echo "=========" $'Done' "========="
	test-7-expected 
	echo "============================"
	# ???: 'echo "Done"\n'=$(test-7-actual)
	# ???: 'Done'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	echo "Done"

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Done
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-87833/test-8"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'sudo apt search libnoise \n' "=========="
	test-8-actual 
	echo "=========" $'' "========="
	test-8-expected 
	echo "============================"
	# ???: 'sudo apt search libnoise \n'=$(test-8-actual)
	# ???: ''=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	sudo apt search libnoise 

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}
