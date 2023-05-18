#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-156918/test-1"
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
	testfolder="/tmp/batspp-156918/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-3-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n# Setting a temp directory for tests\n$ TMP=/tmp/test-extensionless\n$ BIN_DIR=$PWD/..\n0\n0" "========="
	test-3-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-3-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n# Setting a temp directory for tests\n$ TMP=/tmp/test-extensionless\n$ BIN_DIR=$PWD/..\n0\n0"=$(test-3-expected)
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
0
0
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-156918/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-4-actual 
	echo "=========" $'0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-4-actual)
	# ???: '0'=$(test-4-expected)
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
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-156918/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-3570\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-extensionless/test-3570' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-3570\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-extensionless/test-3570'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-3570

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-extensionless/test-3570
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-156918/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9,A-F,a-f]/X/g"" \n' "=========="
	test-6-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/user/g""' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9,A-F,a-f]/X/g"" \n'=$(test-6-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/user/g""'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9,A-F,a-f]/X/g"" 

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/user/g""
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-156918/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-7-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0" "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-7-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0"=$(test-7-expected)
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
3
0
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-156918/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-8-actual 
	echo "=========" $'$ rm -rf ./*\n$ uname -r > version1.txt\n/tmp/test-extensionless/test-3570' "========="
	test-8-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-8-actual)
	# ???: '$ rm -rf ./*\n$ uname -r > version1.txt\n/tmp/test-extensionless/test-3570'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ rm -rf ./*
$ uname -r > version1.txt
/tmp/test-extensionless/test-3570
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-156918/test-9"
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
	testfolder="/tmp/batspp-156918/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'show-unicode-code-info-aux ./version1.txt | testnum \n' "=========="
	test-10-actual 
	echo "=========" $'XhXr\torX\toXXsXt\tXnXoXing\nX.XX.X-XX-gXnXriX: XX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\ng\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nn\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nr\tXXXX\tXX\tXX\ni\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX' "========="
	test-10-expected 
	echo "============================"
	# ???: 'show-unicode-code-info-aux ./version1.txt | testnum \n'=$(test-10-actual)
	# ???: 'XhXr\torX\toXXsXt\tXnXoXing\nX.XX.X-XX-gXnXriX: XX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\ng\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nn\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nr\tXXXX\tXX\tXX\ni\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	show-unicode-code-info-aux ./version1.txt | testnum 

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
XhXr	orX	oXXsXt	XnXoXing
X.XX.X-XX-gXnXriX: XX
X	XXXX	X	XX
.	XXXX	X	XX
X	XXXX	X	XX
X	XXXX	X	XX
.	XXXX	X	XX
X	XXXX	X	XX
-	XXXX	X	XX
X	XXXX	X	XX
X	XXXX	X	XX
-	XXXX	X	XX
g	XXXX	XX	XX
X	XXXX	XX	XX
n	XXXX	XX	XX
X	XXXX	XX	XX
r	XXXX	XX	XX
i	XXXX	XX	XX
X	XXXX	XX	XX
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-156918/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'show-unicode-code-info ./version1.txt | testnum\n' "=========="
	test-11-actual 
	echo "=========" $'XhXr\torX\toXXsXt\tXnXoXing\nX.XX.X-XX-gXnXriX: XX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\ng\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nn\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nr\tXXXX\tXX\tXX\ni\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX' "========="
	test-11-expected 
	echo "============================"
	# ???: 'show-unicode-code-info ./version1.txt | testnum\n'=$(test-11-actual)
	# ???: 'XhXr\torX\toXXsXt\tXnXoXing\nX.XX.X-XX-gXnXriX: XX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n.\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\nX\tXXXX\tX\tXX\n-\tXXXX\tX\tXX\ng\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nn\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX\nr\tXXXX\tXX\tXX\ni\tXXXX\tXX\tXX\nX\tXXXX\tXX\tXX'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	show-unicode-code-info ./version1.txt | testnum

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
XhXr	orX	oXXsXt	XnXoXing
X.XX.X-XX-gXnXriX: XX
X	XXXX	X	XX
.	XXXX	X	XX
X	XXXX	X	XX
X	XXXX	X	XX
.	XXXX	X	XX
X	XXXX	X	XX
-	XXXX	X	XX
X	XXXX	X	XX
X	XXXX	X	XX
-	XXXX	X	XX
g	XXXX	XX	XX
X	XXXX	XX	XX
n	XXXX	XX	XX
X	XXXX	XX	XX
r	XXXX	XX	XX
i	XXXX	XX	XX
X	XXXX	XX	XX
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-156918/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ show-unicode-code-info-stdin ./catmanual.txt\n' "=========="
	test-12-actual 
	echo "=========" $'# | bash: /show-unicode-code-info.5292: Permission denied\n# | bash: /show-unicode-code-info.5292: No such file or directory' "========="
	test-12-expected 
	echo "============================"
	# ???: '# $ show-unicode-code-info-stdin ./catmanual.txt\n'=$(test-12-actual)
	# ???: '# | bash: /show-unicode-code-info.5292: Permission denied\n# | bash: /show-unicode-code-info.5292: No such file or directory'=$(test-12-expected)
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
# | bash: /show-unicode-code-info.5292: Permission denied
# | bash: /show-unicode-code-info.5292: No such file or directory
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-156918/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "END"\n' "=========="
	test-13-actual 
	echo "=========" $'END' "========="
	test-13-expected 
	echo "============================"
	# ???: 'echo "END"\n'=$(test-13-actual)
	# ???: 'END'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	echo "END"

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
END
END_EXPECTED
}
