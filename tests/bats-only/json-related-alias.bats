#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-68787/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"# $ echo 'Hi'\n" "=========="
	test-1-actual 
	echo "=========" $"# | Hi?2004l\n$ bind 'set enable-bracketed-paste off'" "========="
	test-1-expected 
	echo "============================"
	# ???: "# $ echo 'Hi'\n"=$(test-1-actual)
	# ???: "# | Hi?2004l\n$ bind 'set enable-bracketed-paste off'"=$(test-1-expected)
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
# | Hi?2004l
$ bind 'set enable-bracketed-paste off'
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-68787/test-3"
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
	testfolder="/tmp/batspp-68787/test-4"
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
	testfolder="/tmp/batspp-68787/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-json-alias\n' "=========="
	test-5-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-3214\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-json-alias/test-3214' "========="
	test-5-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-json-alias\n'=$(test-5-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-3214\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-json-alias/test-3214'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-json-alias

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
## temp_dir=$TMP/test-$$
$ temp_dir=$TMP/test-3214
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-json-alias/test-3214
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-68787/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0" "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-6-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0"=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
1
0
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-68787/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-7-actual 
	echo "=========" $'' "========="
	test-7-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-7-actual)
	# ???: ''=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-68787/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'perl -e \'print q|{"foo":"HI MOM!","bar":1234567890000000000000000}|\' | pp-json -f json -t dumper\n' "=========="
	test-8-actual 
	echo "=========" $'{\n  bar => "1234567890000000000000000",\n  foo => "HI MOM!"\n}' "========="
	test-8-expected 
	echo "============================"
	# ???: 'perl -e \'print q|{"foo":"HI MOM!","bar":1234567890000000000000000}|\' | pp-json -f json -t dumper\n'=$(test-8-actual)
	# ???: '{\n  bar => "1234567890000000000000000",\n  foo => "HI MOM!"\n}'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	perl -e 'print q|{"foo":"HI MOM!","bar":1234567890000000000000000}|' | pp-json -f json -t dumper

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
{
  bar => "1234567890000000000000000",
  foo => "HI MOM!"
}
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-68787/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'perl -e\'print q|{"foo":"あい","bar":1234567890000000000000000}|\' | json-pp -f json -t dumper -json_opt pretty,utf8,allow_bignum\n' "=========="
	test-9-actual 
	echo "=========" $'{\n  bar => bless( {\n    sign => "+",\n    value => bless( [\n      0,\n      890000000,\n      1234567\n    ], \'Math::BigInt::Calc\' )\n  }, \'Math::BigInt\' ),\n  foo => "\\x{3042}\\x{3044}"\n}' "========="
	test-9-expected 
	echo "============================"
	# ???: 'perl -e\'print q|{"foo":"あい","bar":1234567890000000000000000}|\' | json-pp -f json -t dumper -json_opt pretty,utf8,allow_bignum\n'=$(test-9-actual)
	# ???: '{\n  bar => bless( {\n    sign => "+",\n    value => bless( [\n      0,\n      890000000,\n      1234567\n    ], \'Math::BigInt::Calc\' )\n  }, \'Math::BigInt\' ),\n  foo => "\\x{3042}\\x{3044}"\n}'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	perl -e'print q|{"foo":"あい","bar":1234567890000000000000000}|' | json-pp -f json -t dumper -json_opt pretty,utf8,allow_bignum

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
{
  bar => bless( {
    sign => "+",
    value => bless( [
      0,
      890000000,
      1234567
    ], 'Math::BigInt::Calc' )
  }, 'Math::BigInt' ),
  foo => "\x{3042}\x{3044}"
}
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-68787/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'perl -e\'print q|{"foo":"あい","bar":1234567890000000000000000}|\' | pp-json-sorted -f json -t dumper\n' "=========="
	test-10-actual 
	echo "=========" $'{\n  bar => "1234567890000000000000000",\n  foo => "\\x{3042}\\x{3044}"\n}' "========="
	test-10-expected 
	echo "============================"
	# ???: 'perl -e\'print q|{"foo":"あい","bar":1234567890000000000000000}|\' | pp-json-sorted -f json -t dumper\n'=$(test-10-actual)
	# ???: '{\n  bar => "1234567890000000000000000",\n  foo => "\\x{3042}\\x{3044}"\n}'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	perl -e'print q|{"foo":"あい","bar":1234567890000000000000000}|' | pp-json-sorted -f json -t dumper

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
{
  bar => "1234567890000000000000000",
  foo => "\x{3042}\x{3044}"
}
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-68787/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-11-actual 
	echo "=========" $'/tmp/test-json-alias/test-3214' "========="
	test-11-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-11-actual)
	# ???: '/tmp/test-json-alias/test-3214'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/tmp/test-json-alias/test-3214
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-68787/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-12-actual 
	echo "=========" $'$ printf "This is Line A.\\n1 2 3 4 5" > file_a.txt\n$ printf "This is Line B.\\n1 3 5 7 9" > file_b.txt' "========="
	test-12-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-12-actual)
	# ???: '$ printf "This is Line A.\\n1 2 3 4 5" > file_a.txt\n$ printf "This is Line B.\\n1 3 5 7 9" > file_b.txt'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "This is Line A.\n1 2 3 4 5" > file_a.txt
$ printf "This is Line B.\n1 3 5 7 9" > file_b.txt
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-68787/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'intersection ./file_a.txt ./file_b.txt\n' "=========="
	test-13-actual 
	echo "=========" $'This\nis\nLine\n1\n3\n5' "========="
	test-13-expected 
	echo "============================"
	# ???: 'intersection ./file_a.txt ./file_b.txt\n'=$(test-13-actual)
	# ???: 'This\nis\nLine\n1\n3\n5'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	intersection ./file_a.txt ./file_b.txt

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
This
is
Line
1
3
5
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-68787/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'line-intersection ./file_b.txt ./file_a.txt \n' "=========="
	test-14-actual 
	echo "=========" $'' "========="
	test-14-expected 
	echo "============================"
	# ???: 'line-intersection ./file_b.txt ./file_a.txt \n'=$(test-14-actual)
	# ???: ''=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	line-intersection ./file_b.txt ./file_a.txt 

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-68787/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'difference ./file_a.txt ./file_b.txt\n' "=========="
	test-15-actual 
	echo "=========" $'2\n4\nA.' "========="
	test-15-expected 
	echo "============================"
	# ???: 'difference ./file_a.txt ./file_b.txt\n'=$(test-15-actual)
	# ???: '2\n4\nA.'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	difference ./file_a.txt ./file_b.txt

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
2
4
A.
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-68787/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'line-difference ./file_b.txt ./file_a.txt \n' "=========="
	test-16-actual 
	echo "=========" $'1 3 5 7 9\nThis is Line B.' "========="
	test-16-expected 
	echo "============================"
	# ???: 'line-difference ./file_b.txt ./file_a.txt \n'=$(test-16-actual)
	# ???: '1 3 5 7 9\nThis is Line B.'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	line-difference ./file_b.txt ./file_a.txt 

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1 3 5 7 9
This is Line B.
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-68787/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "Hi Mom, \\rI am using Ubuntu\\n"\n' "=========="
	test-17-actual 
	echo "=========" $'I am using Ubuntu' "========="
	test-17-expected 
	echo "============================"
	# ???: 'printf "Hi Mom, \\rI am using Ubuntu\\n"\n'=$(test-17-actual)
	# ???: 'I am using Ubuntu'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	printf "Hi Mom, \rI am using Ubuntu\n"

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
I am using Ubuntu
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-68787/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "Hi Mom,\\r I am using Ubuntu\\n" | remove-cr\n' "=========="
	test-18-actual 
	echo "=========" $'Hi Mom, I am using Ubuntu' "========="
	test-18-expected 
	echo "============================"
	# ???: 'printf "Hi Mom,\\r I am using Ubuntu\\n" | remove-cr\n'=$(test-18-actual)
	# ???: 'Hi Mom, I am using Ubuntu'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	printf "Hi Mom,\r I am using Ubuntu\n" | remove-cr

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Hi Mom, I am using Ubuntu
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-68787/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "Hi Mom,\\r I am using Ubuntu\\n" | alt-remove-cr\n' "=========="
	test-19-actual 
	echo "=========" $'Hi Mom, I am using Ubuntu' "========="
	test-19-expected 
	echo "============================"
	# ???: 'printf "Hi Mom,\\r I am using Ubuntu\\n" | alt-remove-cr\n'=$(test-19-actual)
	# ???: 'Hi Mom, I am using Ubuntu'=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	printf "Hi Mom,\r I am using Ubuntu\n" | alt-remove-cr

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Hi Mom, I am using Ubuntu
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-68787/test-20"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "Hi Mom,\\r I am using Ubuntu\\n" | perl-remove-cr\n' "=========="
	test-20-actual 
	echo "=========" $'-i used with no filenames on the command line, reading from STDIN.\nHi Mom, I am using Ubuntu' "========="
	test-20-expected 
	echo "============================"
	# ???: 'printf "Hi Mom,\\r I am using Ubuntu\\n" | perl-remove-cr\n'=$(test-20-actual)
	# ???: '-i used with no filenames on the command line, reading from STDIN.\nHi Mom, I am using Ubuntu'=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	printf "Hi Mom,\r I am using Ubuntu\n" | perl-remove-cr

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
-i used with no filenames on the command line, reading from STDIN.
Hi Mom, I am using Ubuntu
END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-68787/test-21"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-21-actual 
	echo "=========" $'$ rm -rf ./* > /dev/null\n$ printf "Hi Mom,\\nThs is the use of printf\\nI can use a backslash n to start a new line.\\n1\\n2\\n3"> abc-test.txt\n$ last-n-with-header 3 abc-test.txt\n/tmp/test-json-alias/test-3214\nHi Mom,\n1\n2\n3' "========="
	test-21-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-21-actual)
	# ???: '$ rm -rf ./* > /dev/null\n$ printf "Hi Mom,\\nThs is the use of printf\\nI can use a backslash n to start a new line.\\n1\\n2\\n3"> abc-test.txt\n$ last-n-with-header 3 abc-test.txt\n/tmp/test-json-alias/test-3214\nHi Mom,\n1\n2\n3'=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ rm -rf ./* > /dev/null
$ printf "Hi Mom,\nThs is the use of printf\nI can use a backslash n to start a new line.\n1\n2\n3"> abc-test.txt
$ last-n-with-header 3 abc-test.txt
/tmp/test-json-alias/test-3214
Hi Mom,
1
2
3
END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-68787/test-22"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'show-line 3 abc-test.txt\n' "=========="
	test-22-actual 
	echo "=========" $'I can use a backslash n to start a new line.' "========="
	test-22-expected 
	echo "============================"
	# ???: 'show-line 3 abc-test.txt\n'=$(test-22-actual)
	# ???: 'I can use a backslash n to start a new line.'=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true

	show-line 3 abc-test.txt

}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
I can use a backslash n to start a new line.
END_EXPECTED
}
