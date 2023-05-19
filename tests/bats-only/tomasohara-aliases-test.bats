#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

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
}
