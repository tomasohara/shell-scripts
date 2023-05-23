#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-140355/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-140355/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-140355/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-unix\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-unix\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-unix

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
	testfolder="/tmp/batspp-140355/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-3245\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-unix/test-3245' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-3245\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-unix/test-3245'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-3245

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
/tmp/test-unix/test-3245
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-140355/test-6"
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
	testfolder="/tmp/batspp-140355/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-140355/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-140355/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-all | wc -l | testnum\n' "=========="
	test-9-actual 
	echo "=========" $'NNN' "========="
	test-9-expected 
	echo "============================"
	# ???: 'ps-all | wc -l | testnum\n'=$(test-9-actual)
	# ???: 'NNN'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	ps-all | wc -l | testnum

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
NNN
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-140355/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-sort-time | head -n 10 | testnum | awk \'!($1=$7=$8=$11="")\'\n' "=========="
	test-10-actual 
	echo "=========" $'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN' "========="
	test-10-expected 
	echo "============================"
	# ???: 'ps-sort-time | head -n 10 | testnum | awk \'!($1=$7=$8=$11="")\'\n'=$(test-10-actual)
	# ???: 'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	ps-sort-time | head -n 10 | testnum | awk '!($1=$7=$8=$11="")'

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PID %CPU %MEM VSZ RSS   START TIME 
 NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN 
 NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-140355/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-time | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\'\n' "=========="
	test-11-actual 
	echo "=========" $'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN' "========="
	test-11-expected 
	echo "============================"
	# ???: 'ps-time | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\'\n'=$(test-11-actual)
	# ???: 'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	ps-time | head -n 10  | testnum | awk '!($1=$7=$8=$11="")'

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PID %CPU %MEM VSZ RSS   START TIME 
 NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN 
 NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-140355/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-sort-mem | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\' \n' "=========="
	test-12-actual 
	echo "=========" $'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN' "========="
	test-12-expected 
	echo "============================"
	# ???: 'ps-sort-mem | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\' \n'=$(test-12-actual)
	# ???: 'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	ps-sort-mem | head -n 10  | testnum | awk '!($1=$7=$8=$11="")' 

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PID %CPU %MEM VSZ RSS   START TIME 
 NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-140355/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-mem | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\'\n' "=========="
	test-13-actual 
	echo "=========" $'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN' "========="
	test-13-expected 
	echo "============================"
	# ???: 'ps-mem | head -n 10  | testnum | awk \'!($1=$7=$8=$11="")\'\n'=$(test-13-actual)
	# ???: 'PID %CPU %MEM VSZ RSS   START TIME \n NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN \n NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN \n NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	ps-mem | head -n 10  | testnum | awk '!($1=$7=$8=$11="")'

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PID %CPU %MEM VSZ RSS   START TIME 
 NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN 
 NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN 
 NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-140355/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ ps-script\n' "=========="
	test-14-actual 
	echo "=========" $'# | bash: -v: command not found\n# | bash: -i: command not found\n# | OSTYPE: Undefined variable.\n$ ps-script\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND' "========="
	test-14-expected 
	echo "============================"
	# ???: '# $ ps-script\n'=$(test-14-actual)
	# ???: '# | bash: -v: command not found\n# | bash: -i: command not found\n# | OSTYPE: Undefined variable.\n$ ps-script\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true


}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | bash: -v: command not found
# | bash: -i: command not found
# | OSTYPE: Undefined variable.
$ ps-script
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-140355/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps al | egrep "(PID|$$)" | head -n 10 | testnum | awk \'!($1="")\'\n' "=========="
	test-15-actual 
	echo "=========" $'$ linebr\n# get-process-parent : return parent process-id for PID\n$ get-process-parent | testnum\n UID PID PPID PRI NI VSZ RSS WCHAN STAT TTY TIME COMMAND\n NNNN NNNNN NNNNN NN N NNNNN NNNN do_wai Ss pts/NN N:NN /usr/bi\n NNNN NNNNN NNNNN NN N NNNNN NNNN - R+ pts/NN N:NN ps al\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN grep -E\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN head -n\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN sed -r\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN awk !($\n--------------------------------------------------------------------------------\nNNNNN' "========="
	test-15-expected 
	echo "============================"
	# ???: 'ps al | egrep "(PID|$$)" | head -n 10 | testnum | awk \'!($1="")\'\n'=$(test-15-actual)
	# ???: '$ linebr\n# get-process-parent : return parent process-id for PID\n$ get-process-parent | testnum\n UID PID PPID PRI NI VSZ RSS WCHAN STAT TTY TIME COMMAND\n NNNN NNNNN NNNNN NN N NNNNN NNNN do_wai Ss pts/NN N:NN /usr/bi\n NNNN NNNNN NNNNN NN N NNNNN NNNN - R+ pts/NN N:NN ps al\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN grep -E\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN head -n\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN sed -r\n NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN awk !($\n--------------------------------------------------------------------------------\nNNNNN'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	ps al | egrep "(PID|$$)" | head -n 10 | testnum | awk '!($1="")'

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
# get-process-parent : return parent process-id for PID
$ get-process-parent | testnum
 UID PID PPID PRI NI VSZ RSS WCHAN STAT TTY TIME COMMAND
 NNNN NNNNN NNNNN NN N NNNNN NNNN do_wai Ss pts/NN N:NN /usr/bi
 NNNN NNNNN NNNNN NN N NNNNN NNNN - R+ pts/NN N:NN ps al
 NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN grep -E
 NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN head -n
 NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN sed -r
 NNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN awk !($
--------------------------------------------------------------------------------
NNNNN
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-140355/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ script-update\n' "=========="
	test-16-actual 
	echo "=========" $"# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory\n# | \x1b]1;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]2;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]1;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]2;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07Script started, output log file is '_update-06dec22.log'." "========="
	test-16-expected 
	echo "============================"
	# ???: '# $ script-update\n'=$(test-16-actual)
	# ???: "# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory\n# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory\n# | \x1b]1;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]2;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]1;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07\x1b]2;script:5848 test-3245 [/tmp/test-unix/test-3245]\x07Script started, output log file is '_update-06dec22.log'."=$(test-16-expected)
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
# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory
# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory
# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.full.list: No such file or directory
# | cat: /home/xaea12/temp/tmp/_set_xterm_title.5848.icon.list: No such file or directory
# | ]1;script:5848 test-3245 [/tmp/test-unix/test-3245]]2;script:5848 test-3245 [/tmp/test-unix/test-3245]]1;script:5848 test-3245 [/tmp/test-unix/test-3245]]2;script:5848 test-3245 [/tmp/test-unix/test-3245]Script started, output log file is '_update-06dec22.log'.
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-140355/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-17-actual 
	echo "=========" $'$ echo "How to use the ansi-filter? " > ansi-filter-test.txt\n$ ansi-filter *.txt\nHow to use the ansi-filter?' "========="
	test-17-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-17-actual)
	# ???: '$ echo "How to use the ansi-filter? " > ansi-filter-test.txt\n$ ansi-filter *.txt\nHow to use the ansi-filter?'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo "How to use the ansi-filter? " > ansi-filter-test.txt
$ ansi-filter *.txt
How to use the ansi-filter?
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-140355/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ pause-for-enter\n' "=========="
	test-18-actual 
	echo "=========" $'# | Press enter to continue \n## (program terminates after pressing Enter Key)' "========="
	test-18-expected 
	echo "============================"
	# ???: '# $ pause-for-enter\n'=$(test-18-actual)
	# ???: '# | Press enter to continue \n## (program terminates after pressing Enter Key)'=$(test-18-expected)
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
# | Press enter to continue 
## (program terminates after pressing Enter Key)
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-140355/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Done"\n' "=========="
	test-19-actual 
	echo "=========" $'Done' "========="
	test-19-expected 
	echo "============================"
	# ???: 'echo "Done"\n'=$(test-19-actual)
	# ???: 'Done'=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	echo "Done"

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Done
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

	BIN_DIR=$PWD/..
	actual=$(test2-assert2-actual)
	expected=$(test2-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert2-actual () {
	alias | wc -l
}
function test2-assert2-expected () {
	echo -e '0'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3245
	cd "$temp_dir"
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test4-assert1-actual)
	expected=$(test4-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test4-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test4-assert1-expected () {
	echo -e '10'
}

@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	alias testnum="sed -r "s/[0-9]/N/g"" 
	alias testuser="sed -r "s/"$USER"+/userxf333/g""
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test7-assert1-actual)
	expected=$(test7-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert1-actual () {
	ps-all | wc -l | testnum
}
function test7-assert1-expected () {
	echo -e 'NNN'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test8-assert1-actual)
	expected=$(test8-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert1-actual () {
	ps-sort-time | head -n 10 | testnum | awk '!($1=$7=$8=$11="")'
}
function test8-assert1-expected () {
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN '
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test9-assert1-actual)
	expected=$(test9-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert1-actual () {
	ps-time | head -n 10  | testnum | awk '!($1=$7=$8=$11="")'
}
function test9-assert1-expected () {
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME NNNN N.N N.N NNNNNNN NNNNN   NN:NN NN:NN NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNN   NN:NN N:NN '
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test10-assert1-actual)
	expected=$(test10-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert1-actual () {
	ps-sort-mem | head -n 10  | testnum | awk '!($1=$7=$8=$11="")' 
}
function test10-assert1-expected () {
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN '
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test11-assert1-actual)
	expected=$(test11-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert1-actual () {
	ps-mem | head -n 10  | testnum | awk '!($1=$7=$8=$11="")'
}
function test11-assert1-expected () {
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME NNNN N.N NN.N NNNNNNN NNNNNN   NN:NN NN:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNNN N.N N.N NNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNNNN NNNNNN   NN:NN N:NN NNNN N.N N.N NNNNNN NNNNN   NN:NN N:NN NNNNN N.N N.N NNNNNNN NNNNN   NN:NN N:NN '
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test12-assert1-actual)
	expected=$(test12-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert1-actual () {
	ps-script
}
function test12-assert1-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	ps al | egrep "(PID|$$)" | head -n 10 | testnum | awk '!($1="")'
	actual=$(test13-assert2-actual)
	expected=$(test13-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert2-actual () {
	get-process-parent | testnum
}
function test13-assert2-expected () {
	echo -e 'UID PID PPID PRI NI VSZ RSS WCHAN STAT TTY TIME COMMANDNNNN NNNNN NNNNN NN N NNNNN NNNN do_wai Ss pts/NN N:NN /usr/biNNNN NNNNN NNNNN NN N NNNNN NNNN - R+ pts/NN N:NN ps alNNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN grep -ENNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN head -nNNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN sed -rNNNN NNNNN NNNNN NN N NNNNN NNNN pipe_r S+ pts/NN N:NN awk !($--------------------------------------------------------------------------------NNNNN'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	echo "How to use the ansi-filter? " > ansi-filter-test.txt
	actual=$(test14-assert3-actual)
	expected=$(test14-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert3-actual () {
	ansi-filter *.txt
}
function test14-assert3-expected () {
	echo -e 'How to use the ansi-filter? '
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test15-assert1-actual)
	expected=$(test15-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert1-actual () {
	echo "Done"
}
function test15-assert1-expected () {
	echo -e 'Done'
>>>>>>> integration-testing-3fa2c13
}
