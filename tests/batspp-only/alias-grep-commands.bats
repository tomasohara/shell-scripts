#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-96088/test-1"
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
	testfolder="/tmp/batspp-96088/test-3"
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
	testfolder="/tmp/batspp-96088/test-4"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-grep\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-grep\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-grep

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
## You will need to run jupyter from that directory.
$ alias | wc -l
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-96088/test-5"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/N/g"" \n' "=========="
	test-5-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-5-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/N/g"" \n'=$(test-5-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/N/g"" 

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-96088/test-6"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-7371\n' "=========="
	test-6-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-grep/test-7371' "========="
	test-6-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-7371\n'=$(test-6-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-grep/test-7371'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-7371

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-grep/test-7371
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-96088/test-7"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-7-actual 
	echo "=========" $'3' "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-7-actual)
	# ???: '3'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
3
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-96088/test-8"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"typeset -f | egrep '^\\w+' | wc -l\n" "=========="
	test-8-actual 
	echo "=========" $'0' "========="
	test-8-expected 
	echo "============================"
	# ???: "typeset -f | egrep '^\\w+' | wc -l\n"=$(test-8-actual)
	# ???: '0'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	typeset -f | egrep '^\w+' | wc -l

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
0
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-96088/test-9"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-96088/test-10"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ grep -V\n' "=========="
	test-10-actual 
	echo "=========" $'# grep (GNU grep) 2.4.2\n#\n# Copyright 1988, 1992-1999, 2000 Free Software Foundation, Inc.\n# ...\n$ grep -V | testnum\ngrep (GNU grep) N.N\nCopyright (C) NNNN Free Software Foundation, Inc.\nLicense GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law.' "========="
	test-10-expected 
	echo "============================"
	# ???: '# $ grep -V\n'=$(test-10-actual)
	# ???: '# grep (GNU grep) 2.4.2\n#\n# Copyright 1988, 1992-1999, 2000 Free Software Foundation, Inc.\n# ...\n$ grep -V | testnum\ngrep (GNU grep) N.N\nCopyright (C) NNNN Free Software Foundation, Inc.\nLicense GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law.'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true


}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# grep (GNU grep) 2.4.2
#
# Copyright 1988, 1992-1999, 2000 Free Software Foundation, Inc.
# ...
$ grep -V | testnum
grep (GNU grep) N.N
Copyright (C) NNNN Free Software Foundation, Inc.
License GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-96088/test-11"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-11-actual 
	echo "=========" $'# THE WORD TO BE TESTED - sensitive\n$ mkdir testdir1 testdir2\n$ echo "As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.\n$ " > testgrep1\n$ echo "sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum" > testgrep2\n$ echo "no mentions here" > testgrep3\n$ echo "Passwords are generally case sensitive" > testgrep4\n$ printf "Non ASCII: Ñ\\nNext\\nNon ASCII: §" > testgrep5' "========="
	test-11-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-11-actual)
	# ???: '# THE WORD TO BE TESTED - sensitive\n$ mkdir testdir1 testdir2\n$ echo "As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.\n$ " > testgrep1\n$ echo "sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum" > testgrep2\n$ echo "no mentions here" > testgrep3\n$ echo "Passwords are generally case sensitive" > testgrep4\n$ printf "Non ASCII: Ñ\\nNext\\nNon ASCII: §" > testgrep5'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# THE WORD TO BE TESTED - sensitive
$ mkdir testdir1 testdir2
$ echo "As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.
$ " > testgrep1
$ echo "sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum" > testgrep2
$ echo "no mentions here" > testgrep3
$ echo "Passwords are generally case sensitive" > testgrep4
$ printf "Non ASCII: Ñ\nNext\nNon ASCII: §" > testgrep5
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-96088/test-12"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'grep sensitive testgrep1 testgrep2 testgrep3 testgrep4\n' "=========="
	test-12-actual 
	echo "=========" $'$ linebr\n# A) gu (grep-unique i-)\n$ gu sensitive testgrep1 testgrep2 testgrep3 testgrep4\n$ linebr\n# B) gu- (grep-unique)\n$ gu- sensitive testgrep1 testgrep2 testgrep3 testgrep4\n$ linebr\n# C) grepl- (grep-to-less)\n$ grepl- "sensitive" testgrep1 testgrep2 testgrep3 testgrep4 | wc -l\n# NOTE: wc -l is pipelined as command goes to a loop\ntestgrep1:As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.\ntestgrep2:sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum\ntestgrep4:Passwords are generally case sensitive\n--------------------------------------------------------------------------------\ntestgrep4:1\ntestgrep2:1\ntestgrep1:1\n--------------------------------------------------------------------------------\ntestgrep4:1\ntestgrep2:1\ntestgrep1:1\n--------------------------------------------------------------------------------\n3' "========="
	test-12-expected 
	echo "============================"
	# ???: 'grep sensitive testgrep1 testgrep2 testgrep3 testgrep4\n'=$(test-12-actual)
	# ???: '$ linebr\n# A) gu (grep-unique i-)\n$ gu sensitive testgrep1 testgrep2 testgrep3 testgrep4\n$ linebr\n# B) gu- (grep-unique)\n$ gu- sensitive testgrep1 testgrep2 testgrep3 testgrep4\n$ linebr\n# C) grepl- (grep-to-less)\n$ grepl- "sensitive" testgrep1 testgrep2 testgrep3 testgrep4 | wc -l\n# NOTE: wc -l is pipelined as command goes to a loop\ntestgrep1:As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.\ntestgrep2:sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum\ntestgrep4:Passwords are generally case sensitive\n--------------------------------------------------------------------------------\ntestgrep4:1\ntestgrep2:1\ntestgrep1:1\n--------------------------------------------------------------------------------\ntestgrep4:1\ntestgrep2:1\ntestgrep1:1\n--------------------------------------------------------------------------------\n3'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	grep sensitive testgrep1 testgrep2 testgrep3 testgrep4

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
# A) gu (grep-unique i-)
$ gu sensitive testgrep1 testgrep2 testgrep3 testgrep4
$ linebr
# B) gu- (grep-unique)
$ gu- sensitive testgrep1 testgrep2 testgrep3 testgrep4
$ linebr
# C) grepl- (grep-to-less)
$ grepl- "sensitive" testgrep1 testgrep2 testgrep3 testgrep4 | wc -l
# NOTE: wc -l is pipelined as command goes to a loop
testgrep1:As grep commands are case sensitive, one of the most useful operators for grep searches as they are sensitive is -i. Instead of printing lowercase results only, the terminal displays both uppercase and lowercase results. The output includes lines with mixed case entries.
testgrep2:sensitive sensitive sensitive Sensitive SENSITIVE lorem ipsum
testgrep4:Passwords are generally case sensitive
--------------------------------------------------------------------------------
testgrep4:1
testgrep2:1
testgrep1:1
--------------------------------------------------------------------------------
testgrep4:1
testgrep2:1
testgrep1:1
--------------------------------------------------------------------------------
3
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-96088/test-13"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat testgrep2 | gr-less lorem\n' "=========="
	test-13-actual 
	echo "=========" $'\x1b[?1h\x1b=' "========="
	test-13-expected 
	echo "============================"
	# ???: 'cat testgrep2 | gr-less lorem\n'=$(test-13-actual)
	# ???: '\x1b[?1h\x1b='=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	cat testgrep2 | gr-less lorem

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[?1h=
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-96088/test-14"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat testgrep5 | grep-nonascii\n' "=========="
	test-14-actual 
	echo "=========" $'Non ASCII: Ñ\nNon ASCII: §' "========="
	test-14-expected 
	echo "============================"
	# ???: 'cat testgrep5 | grep-nonascii\n'=$(test-14-actual)
	# ???: 'Non ASCII: Ñ\nNon ASCII: §'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	cat testgrep5 | grep-nonascii

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Non ASCII: Ñ
Non ASCII: §
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-96088/test-15"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'prepare-find-files-here | testuser | testnum | awk \'!($6="")\'\n' "=========="
	test-15-actual 
	echo "=========" $'-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log' "========="
	test-15-expected 
	echo "============================"
	# ???: 'prepare-find-files-here | testuser | testnum | awk \'!($6="")\'\n'=$(test-15-actual)
	# ???: '-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	prepare-find-files-here | testuser | testnum | awk '!($6="")'

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log
-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-96088/test-16"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'mkdir backup/\n' "=========="
	test-16-actual 
	echo "=========" $'$ ls\nbackup\t     ls-alR.list.log  ls-R.list.log  testdir2\ttestgrep2  testgrep4\nls-alR.list  ls-R.list\t      testdir1\t     testgrep1\ttestgrep3  testgrep5' "========="
	test-16-expected 
	echo "============================"
	# ???: 'mkdir backup/\n'=$(test-16-actual)
	# ???: '$ ls\nbackup\t     ls-alR.list.log  ls-R.list.log  testdir2\ttestgrep2  testgrep4\nls-alR.list  ls-R.list\t      testdir1\t     testgrep1\ttestgrep3  testgrep5'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	mkdir backup/

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ ls
backup	     ls-alR.list.log  ls-R.list.log  testdir2	testgrep2  testgrep4
ls-alR.list  ls-R.list	      testdir1	     testgrep1	testgrep3  testgrep5
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-96088/test-17"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'find-files "ls*" | testuser | testnum | awk \'!($6="")\'\n' "=========="
	test-17-actual 
	echo "=========" $'.:     \ntotal NN    \n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log\n./testdirN:     \ntotal N    \n./testdirN:     \ntotal N' "========="
	test-17-expected 
	echo "============================"
	# ???: 'find-files "ls*" | testuser | testnum | awk \'!($6="")\'\n'=$(test-17-actual)
	# ???: '.:     \ntotal NN    \n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log\n./testdirN:     \ntotal N    \n./testdirN:     \ntotal N'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	find-files "ls*" | testuser | testnum | awk '!($6="")'

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
.:     
total NN    
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log
-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log
./testdirN:     
total N    
./testdirN:     
total N
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-96088/test-18"
	mkdir --parents "$testfolder"
	command cp ./*.* "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ find-files- "testgrep4" | wc -l\n' "=========="
	test-18-actual 
	echo "=========" $'' "========="
	test-18-expected 
	echo "============================"
	# ???: '# $ find-files- "testgrep4" | wc -l\n'=$(test-18-actual)
	# ???: ''=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true


}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}
