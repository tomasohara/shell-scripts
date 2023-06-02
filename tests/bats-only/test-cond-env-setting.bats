#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-55099/test-1"
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
	testfolder="/tmp/batspp-55099/test-3"
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
	testfolder="/tmp/batspp-55099/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-4-actual 
	echo "=========" $'' "========="
	test-4-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-4-actual)
	# ???: ''=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-55099/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-cond-env\n' "=========="
	test-5-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n## source $TEMP_BIN/_dir-aliases.bash\n$ source _dir-aliases.bash\n$ alias | wc -l\n9' "========="
	test-5-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-cond-env\n'=$(test-5-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n## source $TEMP_BIN/_dir-aliases.bash\n$ source _dir-aliases.bash\n$ alias | wc -l\n9'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-cond-env

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
## You will need to run jupyter from that directory.
## source $TEMP_BIN/_dir-aliases.bash
$ source _dir-aliases.bash
$ alias | wc -l
9
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-55099/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-1710\n' "=========="
	test-6-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-cond-env/test-1710' "========="
	test-6-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-1710\n'=$(test-6-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-cond-env/test-1710'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-1710

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
/tmp/test-cond-env/test-1710
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-55099/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-7-actual 
	echo "=========" $'10' "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-7-actual)
	# ???: '10'=$(test-7-expected)
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
10
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-55099/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"typeset -f | egrep '^\\w+' | wc -l\n" "=========="
	test-8-actual 
	echo "=========" $'2' "========="
	test-8-expected 
	echo "============================"
	# ???: "typeset -f | egrep '^\\w+' | wc -l\n"=$(test-8-actual)
	# ???: '2'=$(test-8-expected)
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
2
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-55099/test-9"
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
	testfolder="/tmp/batspp-55099/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cond-setenv COND_ENV_TEST_TEMP tmp/cond-env-test-temp\n' "=========="
	test-10-actual 
	echo "=========" $'' "========="
	test-10-expected 
	echo "============================"
	# ???: 'cond-setenv COND_ENV_TEST_TEMP tmp/cond-env-test-temp\n'=$(test-10-actual)
	# ???: ''=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	cond-setenv COND_ENV_TEST_TEMP tmp/cond-env-test-temp

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-55099/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $COND_ENV_TEST_TEMP\n' "=========="
	test-11-actual 
	echo "=========" $'tmp/cond-env-test-temp' "========="
	test-11-expected 
	echo "============================"
	# ???: 'echo $COND_ENV_TEST_TEMP\n'=$(test-11-actual)
	# ???: 'tmp/cond-env-test-temp'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	echo $COND_ENV_TEST_TEMP

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
tmp/cond-env-test-temp
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-55099/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-12-actual 
	echo "=========" $'$ mkdir -p $COND_ENV_TEST_TEMP\n$ ls -l | awk \'!($6=$7=$8="")\' | testuser\ntotal 4      \ndrwxrwxr-x 3 userxf333 userxf333 4096    tmp' "========="
	test-12-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-12-actual)
	# ???: '$ mkdir -p $COND_ENV_TEST_TEMP\n$ ls -l | awk \'!($6=$7=$8="")\' | testuser\ntotal 4      \ndrwxrwxr-x 3 userxf333 userxf333 4096    tmp'=$(test-12-expected)
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
$ mkdir -p $COND_ENV_TEST_TEMP
$ ls -l | awk '!($6=$7=$8="")' | testuser
total 4      
drwxrwxr-x 3 userxf333 userxf333 4096    tmp
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-55099/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-13-actual 
	echo "=========" $'$ printenv >> $COND_ENV_TEST_TEMP/temp-env-1.tmp\n/tmp/test-cond-env/test-1710' "========="
	test-13-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-13-actual)
	# ???: '$ printenv >> $COND_ENV_TEST_TEMP/temp-env-1.tmp\n/tmp/test-cond-env/test-1710'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printenv >> $COND_ENV_TEST_TEMP/temp-env-1.tmp
/tmp/test-cond-env/test-1710
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-55099/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat $COND_ENV_TEST_TEMP/temp-env-1.tmp | grep TOM_BIN | testuser\n' "=========="
	test-14-actual 
	echo "=========" $'TOM_BIN=/home/userxf333/bin' "========="
	test-14-expected 
	echo "============================"
	# ???: 'cat $COND_ENV_TEST_TEMP/temp-env-1.tmp | grep TOM_BIN | testuser\n'=$(test-14-actual)
	# ???: 'TOM_BIN=/home/userxf333/bin'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	cat $COND_ENV_TEST_TEMP/temp-env-1.tmp | grep TOM_BIN | testuser

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
TOM_BIN=/home/userxf333/bin
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-55099/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Done!"\n' "=========="
	test-15-actual 
	echo "=========" $'Done!' "========="
	test-15-expected 
	echo "============================"
	# ???: 'echo "Done!"\n'=$(test-15-actual)
	# ???: 'Done!'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	echo "Done!"

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Done!
END_EXPECTED
}
