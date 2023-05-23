#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-129394/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ls *.html\n' "=========="
	test-1-actual 
	echo "=========" $'template.html' "========="
	test-1-expected 
	echo "============================"
	# ???: 'ls *.html\n'=$(test-1-actual)
	# ???: 'template.html'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	ls *.html

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
template.html
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-129394/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'url-path template.html\n' "=========="
	test-3-actual 
	echo "=========" $'file:////home/tomohara/bin/template.html' "========="
	test-3-expected 
	echo "============================"
	# ???: 'url-path template.html\n'=$(test-3-actual)
	# ???: 'file:////home/tomohara/bin/template.html'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	url-path template.html

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
file:////home/tomohara/bin/template.html
END_EXPECTED
=======
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
	ls *.html
}
function test0-assert1-expected () {
	echo -e 'template.html'
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
	url-path template.html
}
function test1-assert1-expected () {
	echo -e 'file:////home/tomohara/bin/template.html'
>>>>>>> integration-testing-3fa2c13
}
