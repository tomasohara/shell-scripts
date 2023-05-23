#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-128884/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ jupyter notebook --allow-root\n' "=========="
	test-1-actual 
	echo "=========" $"## Bracketed Paste is disabled to prevent characters after output\n## Example: \n# $ echo 'Hi'\n# | Hi?2004l\n# bind 'set enable-bracketed-paste off'" "========="
	test-1-expected 
	echo "============================"
	# ???: '# $ jupyter notebook --allow-root\n'=$(test-1-actual)
	# ???: "## Bracketed Paste is disabled to prevent characters after output\n## Example: \n# $ echo 'Hi'\n# | Hi?2004l\n# bind 'set enable-bracketed-paste off'"=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true


}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## Bracketed Paste is disabled to prevent characters after output
## Example: 
# $ echo 'Hi'
# | Hi?2004l
# bind 'set enable-bracketed-paste off'
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-128884/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $PS1\n' "=========="
	test-3-actual 
	echo "=========" $'[PEXP\\[\\]ECT_PROMPT>' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo $PS1\n'=$(test-3-actual)
	# ???: '[PEXP\\[\\]ECT_PROMPT>'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo $PS1

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[PEXP\[\]ECT_PROMPT>
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-128884/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-4-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0" "========="
	test-4-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-4-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0"=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	unalias -a

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias | wc -l
$ for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
$ typeset -f | egrep '^\w+' | wc -l
0
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-128884/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-5-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g""' "========="
	test-5-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-5-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g""'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/N/g""
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-128884/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-admin-commands\n' "=========="
	test-6-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2' "========="
	test-6-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-admin-commands\n'=$(test-6-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-admin-commands

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
2
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-128884/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-5400\n' "=========="
	test-7-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-admin-commands/test-5400' "========="
	test-7-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-5400\n'=$(test-7-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-admin-commands/test-5400'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-5400

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-admin-commands/test-5400
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-128884/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-8-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0" "========="
	test-8-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-8-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0"=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
3
0
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-128884/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-9-actual 
	echo "=========" $'' "========="
	test-9-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-9-actual)
	# ???: ''=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-128884/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-10-actual 
	echo "=========" $'$ printf "<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>" >> template1.html' "========="
	test-10-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-10-actual)
	# ???: '$ printf "<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>" >> template1.html'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>" >> template1.html
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-128884/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'check-html template1.html\n' "=========="
	test-11-actual 
	echo "=========" $'' "========="
	test-11-expected 
	echo "============================"
	# ???: 'check-html template1.html\n'=$(test-11-actual)
	# ???: ''=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	check-html template1.html

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-128884/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf \'<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id="demo"></p><script>var txt1 = "What a very";var txt2 = "nice day";document.getElementById("demo").innerHTML = txt1 + txt2;</script></body></html>\' >> template2.js\n' "=========="
	test-12-actual 
	echo "=========" $'' "========="
	test-12-expected 
	echo "============================"
	# ???: 'printf \'<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id="demo"></p><script>var txt1 = "What a very";var txt2 = "nice day";document.getElementById("demo").innerHTML = txt1 + txt2;</script></body></html>\' >> template2.js\n'=$(test-12-actual)
	# ???: ''=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	printf '<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id="demo"></p><script>var txt1 = "What a very";var txt2 = "nice day";document.getElementById("demo").innerHTML = txt1 + txt2;</script></body></html>' >> template2.js

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-128884/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ check-html-java-script template2.js\n' "=========="
	test-13-actual 
	echo "=========" $'# | bash: jsl: command not found' "========="
	test-13-expected 
	echo "============================"
	# ???: '# $ check-html-java-script template2.js\n'=$(test-13-actual)
	# ???: '# | bash: jsl: command not found'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true


}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | bash: jsl: command not found
END_EXPECTED
=======
# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test1-assert4-actual)
	expected=$(test1-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test1-assert4-expected () {
	echo -e '00'
}

@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	alias testuser="sed -r "s/"$USER"+/userxf333/g""
	alias testnum="sed -r "s/[0-9]/N/g"" 
}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	BIN_DIR=$PWD/..
	actual=$(test3-assert2-actual)
	expected=$(test3-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert2-actual () {
	alias | wc -l
}
function test3-assert2-expected () {
	echo -e '2'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-5400
	cd "$temp_dir"
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test5-assert1-actual)
	expected=$(test5-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test5-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test5-assert1-expected () {
	echo -e '30'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	printf "<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>" >> template1.html
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	check-html template1.html
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	printf '<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id="demo"></p><script>var txt1 = "What a very";var txt2 = "nice day";document.getElementById("demo").innerHTML = txt1 + txt2;</script></body></html>' >> template2.js
>>>>>>> integration-testing-3fa2c13
}
