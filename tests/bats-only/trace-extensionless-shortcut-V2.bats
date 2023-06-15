#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-207012/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $PS1\n' "=========="
	test-1-actual 
	echo "=========" $'' "========="
	test-1-expected 
	echo "============================"
	# ???: 'echo $PS1\n'=$(test-1-actual)
	# ???: ''=$(test-1-expected)
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

END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-207012/test-3"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-3-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n# Setting a temp directory for tests\n$ TMP=/tmp/test-extensionless\n$ BIN_DIR=$PWD/.." "========="
	test-3-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-3-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n# Setting a temp directory for tests\n$ TMP=/tmp/test-extensionless\n$ BIN_DIR=$PWD/.."=$(test-3-expected)
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
# Setting a temp directory for tests
$ TMP=/tmp/test-extensionless
$ BIN_DIR=$PWD/..
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-207012/test-4"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-4-actual 
	echo "=========" $'' "========="
	test-4-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-4-actual)
	# ???: ''=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-207012/test-5"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/user/g""\n' "=========="
	test-5-actual 
	echo "=========" $'' "========="
	test-5-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/user/g""\n'=$(test-5-actual)
	# ???: ''=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/user/g""

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-207012/test-6"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-3570\n' "=========="
	test-6-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"' "========="
	test-6-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-3570\n'=$(test-6-actual)
	# ???: '$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-3570

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-207012/test-7"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-7-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l" "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-7-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l"=$(test-7-expected)
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
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-207012/test-8"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/N/g"" \n' "=========="
	test-8-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-8-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/N/g"" \n'=$(test-8-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/N/g"" 

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-207012/test-9"
	mkdir --parents "$testfolder"
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
	testfolder="/tmp/batspp-207012/test-10"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'kill-em --test firefox | wc -l\n' "=========="
	test-10-actual 
	echo "=========" $'' "========="
	test-10-expected 
	echo "============================"
	# ???: 'kill-em --test firefox | wc -l\n'=$(test-10-actual)
	# ???: ''=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	kill-em --test firefox | wc -l

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-207012/test-11"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'kill-it --test firefox | wc -l\n' "=========="
	test-11-actual 
	echo "=========" $'' "========="
	test-11-expected 
	echo "============================"
	# ???: 'kill-it --test firefox | wc -l\n'=$(test-11-actual)
	# ???: ''=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	kill-it --test firefox | wc -l

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-207012/test-12"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ convert-termstrings\n' "=========="
	test-12-actual 
	echo "=========" $'# | Can\'t open perl script "convert_termstrings.perl": No such file or directory' "========="
	test-12-expected 
	echo "============================"
	# ???: '# $ convert-termstrings\n'=$(test-12-actual)
	# ???: '# | Can\'t open perl script "convert_termstrings.perl": No such file or directory'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true


}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | Can't open perl script "convert_termstrings.perl": No such file or directory
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-207012/test-13"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-13-actual 
	echo "=========" $'$ printf "TOP\\nTHIS IS A TEST\\nBOTTOM" > test.txt\n$ printf "THIS IS A FILE TO MOVE" > tomove.txt\n$ mkdir newdir1\n$ move tomove.txt ./newdir1/\n$ ls\n$ dobackup test.txt\n$ linebr\n$ ls' "========="
	test-13-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-13-actual)
	# ???: '$ printf "TOP\\nTHIS IS A TEST\\nBOTTOM" > test.txt\n$ printf "THIS IS A FILE TO MOVE" > tomove.txt\n$ mkdir newdir1\n$ move tomove.txt ./newdir1/\n$ ls\n$ dobackup test.txt\n$ linebr\n$ ls'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "TOP\nTHIS IS A TEST\nBOTTOM" > test.txt
$ printf "THIS IS A FILE TO MOVE" > tomove.txt
$ mkdir newdir1
$ move tomove.txt ./newdir1/
$ ls
$ dobackup test.txt
$ linebr
$ ls
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-207012/test-14"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-mine-all | wc -l | testnum \n' "=========="
	test-14-actual 
	echo "=========" $'' "========="
	test-14-expected 
	echo "============================"
	# ???: 'ps-mine-all | wc -l | testnum \n'=$(test-14-actual)
	# ???: ''=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	ps-mine-all | wc -l | testnum 

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-207012/test-15"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'do-rcsdiff\n' "=========="
	test-15-actual 
	echo "=========" $'' "========="
	test-15-expected 
	echo "============================"
	# ???: 'do-rcsdiff\n'=$(test-15-actual)
	# ???: ''=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	do-rcsdiff

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-207012/test-16"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'uname -r > versionR.txt\n' "=========="
	test-16-actual 
	echo "=========" $'$ uname -a > versionA.txta\n$ uname -v > versionV.txt\n$ uname -i > versionI.txt\n$ uname > "version none.txt"\n$ uname -ra > "version?.txt"\n$ man grep > grep_manual.txt\n$ cp ./versionR.txt ./versionR-1.txt\n$ ls' "========="
	test-16-expected 
	echo "============================"
	# ???: 'uname -r > versionR.txt\n'=$(test-16-actual)
	# ???: '$ uname -a > versionA.txta\n$ uname -v > versionV.txt\n$ uname -i > versionI.txt\n$ uname > "version none.txt"\n$ uname -ra > "version?.txt"\n$ man grep > grep_manual.txt\n$ cp ./versionR.txt ./versionR-1.txt\n$ ls'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	uname -r > versionR.txt

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ uname -a > versionA.txta
$ uname -v > versionV.txt
$ uname -i > versionI.txt
$ uname > "version none.txt"
$ uname -ra > "version?.txt"
$ man grep > grep_manual.txt
$ cp ./versionR.txt ./versionR-1.txt
$ ls
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-207012/test-17"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rename-files -q test.txt harry.txt\n' "=========="
	test-17-actual 
	echo "=========" $'' "========="
	test-17-expected 
	echo "============================"
	# ???: 'rename-files -q test.txt harry.txt\n'=$(test-17-actual)
	# ???: ''=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	rename-files -q test.txt harry.txt

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-207012/test-18"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ testwn\n' "=========="
	test-18-actual 
	echo "=========" $'# | Undefined subroutine &main::NO_OP called at /home/xaea12/bin/common.perl line 2172.' "========="
	test-18-expected 
	echo "============================"
	# ???: '# $ testwn\n'=$(test-18-actual)
	# ???: '# | Undefined subroutine &main::NO_OP called at /home/xaea12/bin/common.perl line 2172.'=$(test-18-expected)
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
# | Undefined subroutine &main::NO_OP called at /home/xaea12/bin/common.perl line 2172.
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-207012/test-19"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'perlgrep "print" ./grep_manual.txt\n' "=========="
	test-19-actual 
	echo "=========" $'' "========="
	test-19-expected 
	echo "============================"
	# ???: 'perlgrep "print" ./grep_manual.txt\n'=$(test-19-actual)
	# ???: ''=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	perlgrep "print" ./grep_manual.txt

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-207012/test-20"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'foreach "echo $f" *.txt\n' "=========="
	test-20-actual 
	echo "=========" $'' "========="
	test-20-expected 
	echo "============================"
	# ???: 'foreach "echo $f" *.txt\n'=$(test-20-actual)
	# ???: ''=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	foreach "echo $f" *.txt

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-207012/test-21"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rename-spaces\n' "=========="
	test-21-actual 
	echo "=========" $'' "========="
	test-21-expected 
	echo "============================"
	# ???: 'rename-spaces\n'=$(test-21-actual)
	# ???: ''=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	rename-spaces

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-207012/test-22"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rename-special-punct\n' "=========="
	test-22-actual 
	echo "=========" $'' "========="
	test-22-expected 
	echo "============================"
	# ???: 'rename-special-punct\n'=$(test-22-actual)
	# ???: ''=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true

	rename-special-punct

}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-23" {
	testfolder="/tmp/batspp-207012/test-23"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps -l >> "process(L).md"\n' "=========="
	test-23-actual 
	echo "=========" $'$ ps -u >> "process(U).md"\n$ ps -x >> "process(X).md"\n$ ps -al >> "process\'all\'.md"\n$ ps -aux >> \'psaux(1).txt\'\n$ ps -aux >> \'psaux(2).txt\'\n$ ps -aux >> \'psaux(3).txt\'' "========="
	test-23-expected 
	echo "============================"
	# ???: 'ps -l >> "process(L).md"\n'=$(test-23-actual)
	# ???: '$ ps -u >> "process(U).md"\n$ ps -x >> "process(X).md"\n$ ps -al >> "process\'all\'.md"\n$ ps -aux >> \'psaux(1).txt\'\n$ ps -aux >> \'psaux(2).txt\'\n$ ps -aux >> \'psaux(3).txt\''=$(test-23-expected)
	[ "$(test-23-actual)" == "$(test-23-expected)" ]
}

function test-23-actual () {
	# no-op in case content just a comment
	true

	ps -l >> "process(L).md"

}

function test-23-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ ps -u >> "process(U).md"
$ ps -x >> "process(X).md"
$ ps -al >> "process'all'.md"
$ ps -aux >> 'psaux(1).txt'
$ ps -aux >> 'psaux(2).txt'
$ ps -aux >> 'psaux(3).txt'
END_EXPECTED
}


@test "test-24" {
	testfolder="/tmp/batspp-207012/test-24"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'move-duplicates\n' "=========="
	test-24-actual 
	echo "=========" $'' "========="
	test-24-expected 
	echo "============================"
	# ???: 'move-duplicates\n'=$(test-24-actual)
	# ???: ''=$(test-24-expected)
	[ "$(test-24-actual)" == "$(test-24-expected)" ]
}

function test-24-actual () {
	# no-op in case content just a comment
	true

	move-duplicates

}

function test-24-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-25" {
	testfolder="/tmp/batspp-207012/test-25"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rename-parens -v\n' "=========="
	test-25-actual 
	echo "=========" $'' "========="
	test-25-expected 
	echo "============================"
	# ???: 'rename-parens -v\n'=$(test-25-actual)
	# ???: ''=$(test-25-expected)
	[ "$(test-25-actual)" == "$(test-25-expected)" ]
}

function test-25-actual () {
	# no-op in case content just a comment
	true

	rename-parens -v

}

function test-25-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-26" {
	testfolder="/tmp/batspp-207012/test-26"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rename-quotes -v\n' "=========="
	test-26-actual 
	echo "=========" $'' "========="
	test-26-expected 
	echo "============================"
	# ???: 'rename-quotes -v\n'=$(test-26-actual)
	# ???: ''=$(test-26-expected)
	[ "$(test-26-actual)" == "$(test-26-expected)" ]
}

function test-26-actual () {
	# no-op in case content just a comment
	true

	rename-quotes -v

}

function test-26-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-27" {
	testfolder="/tmp/batspp-207012/test-27"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ls\n' "=========="
	test-27-actual 
	echo "=========" $'' "========="
	test-27-expected 
	echo "============================"
	# ???: 'ls\n'=$(test-27-actual)
	# ???: ''=$(test-27-expected)
	[ "$(test-27-actual)" == "$(test-27-expected)" ]
}

function test-27-actual () {
	# no-op in case content just a comment
	true

	ls

}

function test-27-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-28" {
	testfolder="/tmp/batspp-207012/test-28"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'man sudo > sudo_manual.out\n' "=========="
	test-28-actual 
	echo "=========" $'$ man ansifilter > fakelog.log\n$ ps -aux > process_all.html' "========="
	test-28-expected 
	echo "============================"
	# ???: 'man sudo > sudo_manual.out\n'=$(test-28-actual)
	# ???: '$ man ansifilter > fakelog.log\n$ ps -aux > process_all.html'=$(test-28-expected)
	[ "$(test-28-actual)" == "$(test-28-expected)" ]
}

function test-28-actual () {
	# no-op in case content just a comment
	true

	man sudo > sudo_manual.out

}

function test-28-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ man ansifilter > fakelog.log
$ ps -aux > process_all.html
END_EXPECTED
}


@test "test-29" {
	testfolder="/tmp/batspp-207012/test-29"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ move-log-files\n' "=========="
	test-29-actual 
	echo "=========" $"# | /bin/mv: missing destination file operand after 'log-files'\n# | Try '/bin/mv --help' for more information." "========="
	test-29-expected 
	echo "============================"
	# ???: '# $ move-log-files\n'=$(test-29-actual)
	# ???: "# | /bin/mv: missing destination file operand after 'log-files'\n# | Try '/bin/mv --help' for more information."=$(test-29-expected)
	[ "$(test-29-actual)" == "$(test-29-expected)" ]
}

function test-29-actual () {
	# no-op in case content just a comment
	true


}

function test-29-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | /bin/mv: missing destination file operand after 'log-files'
# | Try '/bin/mv --help' for more information.
END_EXPECTED
}


@test "test-30" {
	testfolder="/tmp/batspp-207012/test-30"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ move-output-files\n' "=========="
	test-30-actual 
	echo "=========" $"# | mv: cannot stat '$eval_middle': No such file or directory" "========="
	test-30-expected 
	echo "============================"
	# ???: '# $ move-output-files\n'=$(test-30-actual)
	# ???: "# | mv: cannot stat '$eval_middle': No such file or directory"=$(test-30-expected)
	[ "$(test-30-actual)" == "$(test-30-expected)" ]
}

function test-30-actual () {
	# no-op in case content just a comment
	true


}

function test-30-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | mv: cannot stat '$eval_middle': No such file or directory
END_EXPECTED
}


@test "test-31" {
	testfolder="/tmp/batspp-207012/test-31"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'copy-with-file-date *.md | wc -l\n' "=========="
	test-31-actual 
	echo "=========" $'' "========="
	test-31-expected 
	echo "============================"
	# ???: 'copy-with-file-date *.md | wc -l\n'=$(test-31-actual)
	# ???: ''=$(test-31-expected)
	[ "$(test-31-actual)" == "$(test-31-expected)" ]
}

function test-31-actual () {
	# no-op in case content just a comment
	true

	copy-with-file-date *.md | wc -l

}

function test-31-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-32" {
	testfolder="/tmp/batspp-207012/test-32"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'man cat > man_cat.txt\n' "=========="
	test-32-actual 
	echo "=========" $'' "========="
	test-32-expected 
	echo "============================"
	# ???: 'man cat > man_cat.txt\n'=$(test-32-actual)
	# ???: ''=$(test-32-expected)
	[ "$(test-32-actual)" == "$(test-32-expected)" ]
}

function test-32-actual () {
	# no-op in case content just a comment
	true

	man cat > man_cat.txt

}

function test-32-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-33" {
	testfolder="/tmp/batspp-207012/test-33"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unigrams ./man_cat.txt | testuser | testnum\n' "=========="
	test-33-actual 
	echo "=========" $'' "========="
	test-33-expected 
	echo "============================"
	# ???: 'unigrams ./man_cat.txt | testuser | testnum\n'=$(test-33-actual)
	# ???: ''=$(test-33-expected)
	[ "$(test-33-actual)" == "$(test-33-expected)" ]
}

function test-33-actual () {
	# no-op in case content just a comment
	true

	unigrams ./man_cat.txt | testuser | testnum

}

function test-33-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-34" {
	testfolder="/tmp/batspp-207012/test-34"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'word-count ./man_cat.txt | testuser | testnum\n' "=========="
	test-34-actual 
	echo "=========" $'' "========="
	test-34-expected 
	echo "============================"
	# ???: 'word-count ./man_cat.txt | testuser | testnum\n'=$(test-34-actual)
	# ???: ''=$(test-34-expected)
	[ "$(test-34-actual)" == "$(test-34-expected)" ]
}

function test-34-actual () {
	# no-op in case content just a comment
	true

	word-count ./man_cat.txt | testuser | testnum

}

function test-34-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-35" {
	testfolder="/tmp/batspp-207012/test-35"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'bigrams ./man_cat.txt | testuser | testnum\n' "=========="
	test-35-actual 
	echo "=========" $'' "========="
	test-35-expected 
	echo "============================"
	# ???: 'bigrams ./man_cat.txt | testuser | testnum\n'=$(test-35-actual)
	# ???: ''=$(test-35-expected)
	[ "$(test-35-actual)" == "$(test-35-expected)" ]
}

function test-35-actual () {
	# no-op in case content just a comment
	true

	bigrams ./man_cat.txt | testuser | testnum

}

function test-35-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-36" {
	testfolder="/tmp/batspp-207012/test-36"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ lynx-html\n' "=========="
	test-36-actual 
	echo "=========" $'' "========="
	test-36-expected 
	echo "============================"
	# ???: '# $ lynx-html\n'=$(test-36-actual)
	# ???: ''=$(test-36-expected)
	[ "$(test-36-actual)" == "$(test-36-expected)" ]
}

function test-36-actual () {
	# no-op in case content just a comment
	true


}

function test-36-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-37" {
	testfolder="/tmp/batspp-207012/test-37"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'lynx-dump-stdout | head\n' "=========="
	test-37-actual 
	echo "=========" $'' "========="
	test-37-expected 
	echo "============================"
	# ???: 'lynx-dump-stdout | head\n'=$(test-37-actual)
	# ???: ''=$(test-37-expected)
	[ "$(test-37-actual)" == "$(test-37-expected)" ]
}

function test-37-actual () {
	# no-op in case content just a comment
	true

	lynx-dump-stdout | head

}

function test-37-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-38" {
	testfolder="/tmp/batspp-207012/test-38"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ lynx-dump\n' "=========="
	test-38-actual 
	echo "=========" $'# | bash: .txt: cannot overwrite existing file' "========="
	test-38-expected 
	echo "============================"
	# ???: '# $ lynx-dump\n'=$(test-38-actual)
	# ???: '# | bash: .txt: cannot overwrite existing file'=$(test-38-expected)
	[ "$(test-38-actual)" == "$(test-38-expected)" ]
}

function test-38-actual () {
	# no-op in case content just a comment
	true


}

function test-38-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | bash: .txt: cannot overwrite existing file
END_EXPECTED
}


@test "test-39" {
	testfolder="/tmp/batspp-207012/test-39"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'setenv MY_USERNAME xaea12-temp\n' "=========="
	test-39-actual 
	echo "=========" $'$ echo $MY_USERNAME' "========="
	test-39-expected 
	echo "============================"
	# ???: 'setenv MY_USERNAME xaea12-temp\n'=$(test-39-actual)
	# ???: '$ echo $MY_USERNAME'=$(test-39-expected)
	[ "$(test-39-actual)" == "$(test-39-expected)" ]
}

function test-39-actual () {
	# no-op in case content just a comment
	true

	setenv MY_USERNAME xaea12-temp

}

function test-39-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo $MY_USERNAME
END_EXPECTED
}


@test "test-40" {
	testfolder="/tmp/batspp-207012/test-40"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unexport MY_USERNAME\n' "=========="
	test-40-actual 
	echo "=========" $'$ echo $MY_USERNAME' "========="
	test-40-expected 
	echo "============================"
	# ???: 'unexport MY_USERNAME\n'=$(test-40-actual)
	# ???: '$ echo $MY_USERNAME'=$(test-40-expected)
	[ "$(test-40-actual)" == "$(test-40-expected)" ]
}

function test-40-actual () {
	# no-op in case content just a comment
	true

	unexport MY_USERNAME

}

function test-40-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo $MY_USERNAME
END_EXPECTED
}


@test "test-41" {
	testfolder="/tmp/batspp-207012/test-41"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "END"\n' "=========="
	test-41-actual 
	echo "=========" $'' "========="
	test-41-expected 
	echo "============================"
	# ???: 'echo "END"\n'=$(test-41-actual)
	# ???: ''=$(test-41-expected)
	[ "$(test-41-actual)" == "$(test-41-expected)" ]
}

function test-41-actual () {
	# no-op in case content just a comment
	true

	echo "END"

}

function test-41-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}
