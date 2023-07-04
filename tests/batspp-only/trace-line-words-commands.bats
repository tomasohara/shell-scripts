#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-92342/test-1"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $PS1\n' "=========="
	test-1-actual 
	echo "=========" $'[PEXP\\[\\]ECT_PROMPT>' "========="
	test-1-expected 
	echo "============================"
	# ???: 'echo $PS1\n'=$(test-1-actual)
	# ???: '[PEXP\\[\\]ECT_PROMPT>'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	echo $PS1

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[PEXP\[\]ECT_PROMPT>
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-92342/test-3"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-3-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0" "========="
	test-3-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-3-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0"=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	unalias -a

}

function test-3-expected () {
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


@test "test-4" {
	testfolder="/tmp/batspp-92342/test-4"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-linewords\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-linewords\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-linewords

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-92342/test-5"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-6439\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-linewords/test-6439' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-6439\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-linewords/test-6439'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-6439

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-linewords/test-6439
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-92342/test-6"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-92342/test-7"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/N/g"" \n' "=========="
	test-7-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/N/g"" \n'=$(test-7-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/N/g"" 

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-92342/test-8"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-8-actual 
	echo "=========" $'' "========="
	test-8-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-8-actual)
	# ???: ''=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-92342/test-9"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./*\n' "=========="
	test-9-actual 
	echo "=========" $'$ printf "Hi Mom,\\nThis is the use of printf\\nI can use a backslash n to start a new line\\n1\\n2\\n3" >> abc-test.txt\n$ printf "This is another-test file" >> test2.txt\n$ printf "This is test-file 3" >> test3.txt\n$ printf "This is a test-file 4" >> test4.txt' "========="
	test-9-expected 
	echo "============================"
	# ???: 'rm -rf ./*\n'=$(test-9-actual)
	# ???: '$ printf "Hi Mom,\\nThis is the use of printf\\nI can use a backslash n to start a new line\\n1\\n2\\n3" >> abc-test.txt\n$ printf "This is another-test file" >> test2.txt\n$ printf "This is test-file 3" >> test3.txt\n$ printf "This is a test-file 4" >> test4.txt'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./*

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "Hi Mom,\nThis is the use of printf\nI can use a backslash n to start a new line\n1\n2\n3" >> abc-test.txt
$ printf "This is another-test file" >> test2.txt
$ printf "This is test-file 3" >> test3.txt
$ printf "This is a test-file 4" >> test4.txt
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-92342/test-10"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"ls | count-it '\\.([^\\.]+)$'\n" "=========="
	test-10-actual 
	echo "=========" $'txt\t4' "========="
	test-10-expected 
	echo "============================"
	# ???: "ls | count-it '\\.([^\\.]+)$'\n"=$(test-10-actual)
	# ???: 'txt\t4'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	ls | count-it '\.([^\.]+)$'

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
txt	4
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-92342/test-11"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat abc-test.txt | line-wc\n' "=========="
	test-11-actual 
	echo "=========" $'2\tHi Mom,\n6\tThis is the use of printf\n11\tI can use a backslash n to start a new line\n1\t1\n1\t2\n1\t3' "========="
	test-11-expected 
	echo "============================"
	# ???: 'cat abc-test.txt | line-wc\n'=$(test-11-actual)
	# ???: '2\tHi Mom,\n6\tThis is the use of printf\n11\tI can use a backslash n to start a new line\n1\t1\n1\t2\n1\t3'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	cat abc-test.txt | line-wc

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
2	Hi Mom,
6	This is the use of printf
11	I can use a backslash n to start a new line
1	1
1	2
1	3
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-92342/test-12"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat abc-test.txt | line-len\n' "=========="
	test-12-actual 
	echo "=========" $'7\tHi Mom,\n25\tThis is the use of printf\n43\tI can use a backslash n to start a new line\n1\t1\n1\t2\n0\t3' "========="
	test-12-expected 
	echo "============================"
	# ???: 'cat abc-test.txt | line-len\n'=$(test-12-actual)
	# ???: '7\tHi Mom,\n25\tThis is the use of printf\n43\tI can use a backslash n to start a new line\n1\t1\n1\t2\n0\t3'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	cat abc-test.txt | line-len

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
7	Hi Mom,
25	This is the use of printf
43	I can use a backslash n to start a new line
1	1
1	2
0	3
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-92342/test-13"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat abc-test.txt | para-len\n' "=========="
	test-13-actual 
	echo "=========" $'82\tHi Mom,\nThis is the use of printf\nI can use a backslash n to start a new line\n1\n2\n3' "========="
	test-13-expected 
	echo "============================"
	# ???: 'cat abc-test.txt | para-len\n'=$(test-13-actual)
	# ???: '82\tHi Mom,\nThis is the use of printf\nI can use a backslash n to start a new line\n1\n2\n3'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	cat abc-test.txt | para-len

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
82	Hi Mom,
This is the use of printf
I can use a backslash n to start a new line
1
2
3
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-92342/test-14"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat abc-test.txt | line-word-len\n' "=========="
	test-14-actual 
	echo "=========" $'2\tHi Mom,\n6\tThis is the use of printf\n11\tI can use a backslash n to start a new line\n1\t1\n1\t2\n1\t3' "========="
	test-14-expected 
	echo "============================"
	# ???: 'cat abc-test.txt | line-word-len\n'=$(test-14-actual)
	# ???: '2\tHi Mom,\n6\tThis is the use of printf\n11\tI can use a backslash n to start a new line\n1\t1\n1\t2\n1\t3'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	cat abc-test.txt | line-word-len

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
2	Hi Mom,
6	This is the use of printf
11	I can use a backslash n to start a new line
1	1
1	2
1	3
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-92342/test-15"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ls-line-len\n' "=========="
	test-15-actual 
	echo "=========" $'\x1b[?1h\x1b=' "========="
	test-15-expected 
	echo "============================"
	# ???: 'ls-line-len\n'=$(test-15-actual)
	# ???: '\x1b[?1h\x1b='=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	ls-line-len

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[?1h=
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-92342/test-16"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ cat abc-test.txt | check-class-dist\n' "=========="
	test-16-actual 
	echo "=========" $"# | Can't open : No such file or directory at /home/xaea12/bin/count_it.perl line 171.\n# | WARNING: unexpected distribution for FREQ (all 0)" "========="
	test-16-expected 
	echo "============================"
	# ???: '# $ cat abc-test.txt | check-class-dist\n'=$(test-16-actual)
	# ???: "# | Can't open : No such file or directory at /home/xaea12/bin/count_it.perl line 171.\n# | WARNING: unexpected distribution for FREQ (all 0)"=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true


}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | Can't open : No such file or directory at /home/xaea12/bin/count_it.perl line 171.
# | WARNING: unexpected distribution for FREQ (all 0)
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-92342/test-17"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ cat abc-test.txt | 2bib\n' "=========="
	test-17-actual 
	echo "=========" $'# | bash: bibitem2bib: command not found\n# | cat: write error: Broken pipe' "========="
	test-17-expected 
	echo "============================"
	# ???: '# $ cat abc-test.txt | 2bib\n'=$(test-17-actual)
	# ???: '# | bash: bibitem2bib: command not found\n# | cat: write error: Broken pipe'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true


}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | bash: bibitem2bib: command not found
# | cat: write error: Broken pipe
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-92342/test-18"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-18-actual 
	echo "=========" $'$ echo "Done"\nDone' "========="
	test-18-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-18-actual)
	# ???: '$ echo "Done"\nDone'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo "Done"
Done
END_EXPECTED
}
