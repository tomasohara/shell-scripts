#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-93573/test-1"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'export TEMP_TOM_BIN=tmp/tomasohara-shell-scripts\n' "=========="
	test-1-actual 
	echo "=========" $'$ export TOM_ALIAS_FILE="$TEMP_TOM_BIN/tomohara-aliases.bash"\n$ mkdir -p "$TEMP_TOM_BIN"' "========="
	test-1-expected 
	echo "============================"
	# ???: 'export TEMP_TOM_BIN=tmp/tomasohara-shell-scripts\n'=$(test-1-actual)
	# ???: '$ export TOM_ALIAS_FILE="$TEMP_TOM_BIN/tomohara-aliases.bash"\n$ mkdir -p "$TEMP_TOM_BIN"'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	export TEMP_TOM_BIN=tmp/tomasohara-shell-scripts

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ export TOM_ALIAS_FILE="$TEMP_TOM_BIN/tomohara-aliases.bash"
$ mkdir -p "$TEMP_TOM_BIN"
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-93573/test-3"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'curl https://raw.githubusercontent.com/tomasohara/shell-scripts/main/tomohara-aliases.bash > "$TOM_ALIAS_FILE"\n' "=========="
	test-3-actual 
	echo "=========" $'% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n100  137k  100  137k    0     0   194k      0 --:--:-- --:--:-- --:--:--  194k' "========="
	test-3-expected 
	echo "============================"
	# ???: 'curl https://raw.githubusercontent.com/tomasohara/shell-scripts/main/tomohara-aliases.bash > "$TOM_ALIAS_FILE"\n'=$(test-3-actual)
	# ???: '% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n100  137k  100  137k    0     0   194k      0 --:--:-- --:--:-- --:--:--  194k'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	curl https://raw.githubusercontent.com/tomasohara/shell-scripts/main/tomohara-aliases.bash > "$TOM_ALIAS_FILE"

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  137k  100  137k    0     0   194k      0 --:--:-- --:--:-- --:--:--  194k
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-93573/test-4"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'file "$TOM_ALIAS_FILE"\n' "=========="
	test-4-actual 
	echo "=========" $'tmp/tomasohara-shell-scripts/tomohara-aliases.bash: Bourne-Again shell script, UTF-8 Unicode text executable, with very long lines' "========="
	test-4-expected 
	echo "============================"
	# ???: 'file "$TOM_ALIAS_FILE"\n'=$(test-4-actual)
	# ???: 'tmp/tomasohara-shell-scripts/tomohara-aliases.bash: Bourne-Again shell script, UTF-8 Unicode text executable, with very long lines'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	file "$TOM_ALIAS_FILE"

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
tmp/tomasohara-shell-scripts/tomohara-aliases.bash: Bourne-Again shell script, UTF-8 Unicode text executable, with very long lines
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-93573/test-5"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'export BATCH_MODE=1\n' "=========="
	test-5-actual 
	echo "=========" $'$ source "$TOM_ALIAS_FILE"' "========="
	test-5-expected 
	echo "============================"
	# ???: 'export BATCH_MODE=1\n'=$(test-5-actual)
	# ???: '$ source "$TOM_ALIAS_FILE"'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	export BATCH_MODE=1

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ source "$TOM_ALIAS_FILE"
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-93573/test-6"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'show-macros | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $'4161' "========="
	test-6-expected 
	echo "============================"
	# ???: 'show-macros | wc -l\n'=$(test-6-actual)
	# ???: '4161'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	show-macros | wc -l

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
4161
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-93573/test-7"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf "$TEMP_TOM_BIN"\n' "=========="
	test-7-actual 
	echo "=========" $"removed 'tmp/tomasohara-shell-scripts/tomohara-aliases.bash'\nremoved directory 'tmp/tomasohara-shell-scripts'" "========="
	test-7-expected 
	echo "============================"
	# ???: 'rm -rf "$TEMP_TOM_BIN"\n'=$(test-7-actual)
	# ???: "removed 'tmp/tomasohara-shell-scripts/tomohara-aliases.bash'\nremoved directory 'tmp/tomasohara-shell-scripts'"=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	rm -rf "$TEMP_TOM_BIN"

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
removed 'tmp/tomasohara-shell-scripts/tomohara-aliases.bash'
removed directory 'tmp/tomasohara-shell-scripts'
END_EXPECTED
}
