#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-137402/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'basename $PWD\n' "=========="
	test-1-actual 
	echo "=========" $'tests' "========="
	test-1-expected 
	echo "============================"
	# ???: 'basename $PWD\n'=$(test-1-actual)
	# ???: 'tests'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	basename $PWD

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
tests
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-137402/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'/bin/rm -rf "/tmp/test-dir-15485863"\n' "=========="
	test-3-actual 
	echo "=========" $'$ test_dir="/tmp/test-dir-15485863"\n$ mkdir -p "$test_dir"\n$ command cd "$test_dir"' "========="
	test-3-expected 
	echo "============================"
	# ???: '/bin/rm -rf "/tmp/test-dir-15485863"\n'=$(test-3-actual)
	# ???: '$ test_dir="/tmp/test-dir-15485863"\n$ mkdir -p "$test_dir"\n$ command cd "$test_dir"'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	/bin/rm -rf "/tmp/test-dir-15485863"

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ test_dir="/tmp/test-dir-15485863"
$ mkdir -p "$test_dir"
$ command cd "$test_dir"
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-137402/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ls ../*.html\n' "=========="
	test-4-actual 
	echo "=========" $'../template.html' "========="
	test-4-expected 
	echo "============================"
	# ???: 'ls ../*.html\n'=$(test-4-actual)
	# ???: '../template.html'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	ls ../*.html

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
../template.html
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-137402/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'dir=$(realpath "..")\n' "=========="
	test-5-actual 
	echo "=========" $'$ url-path ../template.html | perl -pe "s@$dir@/x/y/z@;"\nfile:////x/y/z/template.html' "========="
	test-5-expected 
	echo "============================"
	# ???: 'dir=$(realpath "..")\n'=$(test-5-actual)
	# ???: '$ url-path ../template.html | perl -pe "s@$dir@/x/y/z@;"\nfile:////x/y/z/template.html'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	dir=$(realpath "..")

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ url-path ../template.html | perl -pe "s@$dir@/x/y/z@;"
file:////x/y/z/template.html
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-137402/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'umask ug=rwx,o=r\n' "=========="
	test-6-actual 
	echo "=========" $'$ mkdir abc def\n$ touch ghi jkl\n$ echo > mno\n$ dir | perl -pe "s/ (\\d+) [\\w ]{2,8}/ \\1 username /; s/\\w\\w\\w \\d+ \\d\\d:\\d\\d/mon \\1 hh:mm/;";' "========="
	test-6-expected 
	echo "============================"
	# ???: 'umask ug=rwx,o=r\n'=$(test-6-actual)
	# ???: '$ mkdir abc def\n$ touch ghi jkl\n$ echo > mno\n$ dir | perl -pe "s/ (\\d+) [\\w ]{2,8}/ \\1 username /; s/\\w\\w\\w \\d+ \\d\\d:\\d\\d/mon \\1 hh:mm/;";'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	umask ug=rwx,o=r

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir abc def
$ touch ghi jkl
$ echo > mno
$ dir | perl -pe "s/ (\d+) [\w ]{2,8}/ \1 username /; s/\w\w\w \d+ \d\d:\d\d/mon \1 hh:mm/;";
END_EXPECTED
}
