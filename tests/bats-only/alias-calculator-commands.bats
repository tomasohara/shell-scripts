#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-200204/test-1"
	mkdir --parents "$testfolder"
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
	testfolder="/tmp/batspp-200204/test-3"
	mkdir --parents "$testfolder"
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
	testfolder="/tmp/batspp-200204/test-4"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-200204/test-5"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-calc\n' "=========="
	test-5-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-1210\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-calc/test-1210' "========="
	test-5-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-calc\n'=$(test-5-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-1210\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-calc/test-1210'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-calc

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
## temp_dir=$TMP/test-$$
$ temp_dir=$TMP/test-1210
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-calc/test-1210
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-200204/test-6"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $'1' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-6-actual)
	# ???: '1'=$(test-6-expected)
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
1
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-200204/test-7"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"typeset -f | egrep '^\\w+' | wc -l\n" "=========="
	test-7-actual 
	echo "=========" $'0' "========="
	test-7-expected 
	echo "============================"
	# ???: "typeset -f | egrep '^\\w+' | wc -l\n"=$(test-7-actual)
	# ???: '0'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	typeset -f | egrep '^\w+' | wc -l

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
0
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-200204/test-8"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnumhex="sed -r "s/[0-9,A-F,a-f]/N/g"" \n' "=========="
	test-8-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-8-expected 
	echo "============================"
	# ???: 'alias testnumhex="sed -r "s/[0-9,A-F,a-f]/N/g"" \n'=$(test-8-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	alias testnumhex="sed -r "s/[0-9,A-F,a-f]/N/g"" 

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-200204/test-9"
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
	testfolder="/tmp/batspp-200204/test-10"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'old-calc "24 / 4.0 - (35 / 7.0) * 5" \n' "=========="
	test-10-actual 
	echo "=========" $'$ linebr\n# returns 32\n$ old-calc "(2^3)*(2^2)"\n# returns 121\n$ linebr\n$ old-calc "5*4*3*2*1+1" \n-19.00000000000000000000\n--------------------------------------------------------------------------------\n32\n--------------------------------------------------------------------------------\n121' "========="
	test-10-expected 
	echo "============================"
	# ???: 'old-calc "24 / 4.0 - (35 / 7.0) * 5" \n'=$(test-10-actual)
	# ???: '$ linebr\n# returns 32\n$ old-calc "(2^3)*(2^2)"\n# returns 121\n$ linebr\n$ old-calc "5*4*3*2*1+1" \n-19.00000000000000000000\n--------------------------------------------------------------------------------\n32\n--------------------------------------------------------------------------------\n121'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	old-calc "24 / 4.0 - (35 / 7.0) * 5" 

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
# returns 32
$ old-calc "(2^3)*(2^2)"
# returns 121
$ linebr
$ old-calc "5*4*3*2*1+1" 
-19.00000000000000000000
--------------------------------------------------------------------------------
32
--------------------------------------------------------------------------------
121
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-200204/test-11"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'old-perl-calc "70 + 69 + 68"\n' "=========="
	test-11-actual 
	echo "=========" $'$ printf "\\n"\n$ linebr\n$ old-perl-calc "8/8/8/8/8"\n$ printf "\\n"\n$ linebr\n207' "========="
	test-11-expected 
	echo "============================"
	# ???: 'old-perl-calc "70 + 69 + 68"\n'=$(test-11-actual)
	# ???: '$ printf "\\n"\n$ linebr\n$ old-perl-calc "8/8/8/8/8"\n$ printf "\\n"\n$ linebr\n207'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	old-perl-calc "70 + 69 + 68"

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "\n"
$ linebr
$ old-perl-calc "8/8/8/8/8"
$ printf "\n"
$ linebr
207
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-200204/test-12"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'hex2dec 42Df5D144 \n' "=========="
	test-12-actual 
	echo "=========" $'#cases don\'t matter in the number\n$ linebr\n$ hex2dec "F"\n17950953796\n--------------------------------------------------------------------------------\n15' "========="
	test-12-expected 
	echo "============================"
	# ???: 'hex2dec 42Df5D144 \n'=$(test-12-actual)
	# ???: '#cases don\'t matter in the number\n$ linebr\n$ hex2dec "F"\n17950953796\n--------------------------------------------------------------------------------\n15'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	hex2dec 42Df5D144 

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#cases don't matter in the number
$ linebr
$ hex2dec "F"
17950953796
--------------------------------------------------------------------------------
15
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-200204/test-13"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'dec2hex "128"\n' "=========="
	test-13-actual 
	echo "=========" $'#inclusion of non-decimal numbers yield 0 as a result\n$ dec2hex "A12" \n80\n0' "========="
	test-13-expected 
	echo "============================"
	# ???: 'dec2hex "128"\n'=$(test-13-actual)
	# ???: '#inclusion of non-decimal numbers yield 0 as a result\n$ dec2hex "A12" \n80\n0'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	dec2hex "128"

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#inclusion of non-decimal numbers yield 0 as a result
$ dec2hex "A12" 
80
0
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-200204/test-14"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'bin2dec "11110011"\n' "=========="
	test-14-actual 
	echo "=========" $'$ linebr\n#inclusion of non-binary numbers leads to error\n$ bin2dec "0110" \n243\n--------------------------------------------------------------------------------\n6' "========="
	test-14-expected 
	echo "============================"
	# ???: 'bin2dec "11110011"\n'=$(test-14-actual)
	# ???: '$ linebr\n#inclusion of non-binary numbers leads to error\n$ bin2dec "0110" \n243\n--------------------------------------------------------------------------------\n6'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	bin2dec "11110011"

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
#inclusion of non-binary numbers leads to error
$ bin2dec "0110" 
243
--------------------------------------------------------------------------------
6
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-200204/test-15"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'dec2bin "70419"\n' "=========="
	test-15-actual 
	echo "=========" $'#inclusion of non-decimal number leads to error\n$ dec2bin "10" \n$ dec2bin "7" | testnumhex\n10001001100010011\n1010\nNNN' "========="
	test-15-expected 
	echo "============================"
	# ???: 'dec2bin "70419"\n'=$(test-15-actual)
	# ???: '#inclusion of non-decimal number leads to error\n$ dec2bin "10" \n$ dec2bin "7" | testnumhex\n10001001100010011\n1010\nNNN'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	dec2bin "70419"

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#inclusion of non-decimal number leads to error
$ dec2bin "10" 
$ dec2bin "7" | testnumhex
10001001100010011
1010
NNN
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-200204/test-16"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-16-actual 
	echo "=========" $'$ rm -rf ./* > /dev/null\n$ ps -l > testforhv.txt\n$ hv testforhv.txt | testnumhex\n/tmp/test-calc/test-1210\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N S   UIN     PI\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N    PPIN  N PRI\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NI NNNR SZ WNH\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NN  TTY         \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   TIMN NMN.N S  N\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN   NNNNN   NN\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN  N  NN   N -\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NNNN No_wNi pt\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  s/N    NN:NN:NN \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNsh.N R  NNNN  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   NNNNN   NNNNN  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N  NN   N -  NNN\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N -      pts/N  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN          NN:NN:NN ps.' "========="
	test-16-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-16-actual)
	# ???: '$ rm -rf ./* > /dev/null\n$ ps -l > testforhv.txt\n$ hv testforhv.txt | testnumhex\n/tmp/test-calc/test-1210\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N S   UIN     PI\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N    PPIN  N PRI\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NI NNNR SZ WNH\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NN  TTY         \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   TIMN NMN.N S  N\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN   NNNNN   NN\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN  N  NN   N -\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NNNN No_wNi pt\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  s/N    NN:NN:NN \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNsh.N R  NNNN  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   NNNNN   NNNNN  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N  NN   N -  NNN\nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N -      pts/N  \nNNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN          NN:NN:NN ps.'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ rm -rf ./* > /dev/null
$ ps -l > testforhv.txt
$ hv testforhv.txt | testnumhex
/tmp/test-calc/test-1210
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N S   UIN     PI
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N    PPIN  N PRI
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NI NNNR SZ WNH
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NN  TTY         
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   TIMN NMN.N S  N
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN   NNNNN   NN
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNN  N  NN   N -
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN    NNNN No_wNi pt
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  s/N    NN:NN:NN 
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  NNsh.N R  NNNN  
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN   NNNNN   NNNNN  
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N  NN   N -  NNN
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN NN NN  N -      pts/N  
NNNNNNNN  NN NN NN NN NN NN NN NN - NN NN NN NN NN NN          NN:NN:NN ps.
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-200204/test-17"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'calc "100/(24*5)"\n' "=========="
	test-17-actual 
	echo "=========" $'$ linebr\n$ calc-prec6 "49/3"\n$ linebr\n# NEED HELP\n$ calc-init "+" "100/3"\n$ linebr\n$ calc-int "100/23"\n0.833\n--------------------------------------------------------------------------------\n16.333333\n--------------------------------------------------------------------------------\n33.333\n--------------------------------------------------------------------------------\n4' "========="
	test-17-expected 
	echo "============================"
	# ???: 'calc "100/(24*5)"\n'=$(test-17-actual)
	# ???: '$ linebr\n$ calc-prec6 "49/3"\n$ linebr\n# NEED HELP\n$ calc-init "+" "100/3"\n$ linebr\n$ calc-int "100/23"\n0.833\n--------------------------------------------------------------------------------\n16.333333\n--------------------------------------------------------------------------------\n33.333\n--------------------------------------------------------------------------------\n4'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	calc "100/(24*5)"

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ calc-prec6 "49/3"
$ linebr
# NEED HELP
$ calc-init "+" "100/3"
$ linebr
$ calc-int "100/23"
0.833
--------------------------------------------------------------------------------
16.333333
--------------------------------------------------------------------------------
33.333
--------------------------------------------------------------------------------
4
END_EXPECTED
}
