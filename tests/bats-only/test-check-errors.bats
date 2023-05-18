#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-164532/test-1"
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
	testfolder="/tmp/batspp-164532/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-3-actual 
	echo "=========" $"$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ BIN_DIR=$PWD/.." "========="
	test-3-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-3-actual)
	# ???: "$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ BIN_DIR=$PWD/.."=$(test-3-expected)
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
$ for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
$ BIN_DIR=$PWD/..
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-164532/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-check-errors\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-check-errors\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-check-errors

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-164532/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-2334\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-check-errors/test-2334' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-2334\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-check-errors/test-2334'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-2334

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
/tmp/test-check-errors/test-2334
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-164532/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/X/g"" \n' "=========="
	test-6-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/user/g""' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/X/g"" \n'=$(test-6-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/user/g""'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/X/g"" 

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/user/g""
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-164532/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd | testuser\n' "=========="
	test-7-actual 
	echo "=========" $'/tmp/test-check-errors/test-2334' "========="
	test-7-expected 
	echo "============================"
	# ???: 'pwd | testuser\n'=$(test-7-actual)
	# ???: '/tmp/test-check-errors/test-2334'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	pwd | testuser

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/tmp/test-check-errors/test-2334
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-164532/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'check_errors.py\n' "=========="
	test-8-actual 
	echo "=========" $'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]' "========="
	test-8-expected 
	echo "============================"
	# ???: 'check_errors.py\n'=$(test-8-actual)
	# ???: 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	check_errors.py

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]
                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]
                       [--strict] [--verbose] [--context CONTEXT]
                       [filename]
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-164532/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pip3 install mezcla | testnum > /dev/null\n' "=========="
	test-9-actual 
	echo "=========" $'' "========="
	test-9-expected 
	echo "============================"
	# ???: 'pip3 install mezcla | testnum > /dev/null\n'=$(test-9-actual)
	# ???: ''=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	pip3 install mezcla | testnum > /dev/null

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-164532/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'check_errors.py\n' "=========="
	test-10-actual 
	echo "=========" $'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]' "========="
	test-10-expected 
	echo "============================"
	# ???: 'check_errors.py\n'=$(test-10-actual)
	# ???: 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	check_errors.py

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]
                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]
                       [--strict] [--verbose] [--context CONTEXT]
                       [filename]
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-164532/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'python3 $BIN_DIR/check_errors.py -h\n' "=========="
	test-11-actual 
	echo "=========" $'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]' "========="
	test-11-expected 
	echo "============================"
	# ???: 'python3 $BIN_DIR/check_errors.py -h\n'=$(test-11-actual)
	# ???: 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]\n                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]\n                       [--strict] [--verbose] [--context CONTEXT]\n                       [filename]'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	python3 $BIN_DIR/check_errors.py -h

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings]
                       [--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed]
                       [--strict] [--verbose] [--context CONTEXT]
                       [filename]
END_EXPECTED
}
