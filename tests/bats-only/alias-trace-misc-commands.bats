#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-152669/test-1"
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
	testfolder="/tmp/batspp-152669/test-3"
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
	testfolder="/tmp/batspp-152669/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-trace-misc\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-trace-misc\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-trace-misc

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
	testfolder="/tmp/batspp-152669/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-1210\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-trace-misc/test-1210' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-1210\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-trace-misc/test-1210'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-1210

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
/tmp/test-trace-misc/test-1210
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-152669/test-6"
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
	testfolder="/tmp/batspp-152669/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-7-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g"" \n$ alias testnumhex="sed -r "s/[0-9,a-f,A-F]/h/g""' "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-7-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g"" \n$ alias testnumhex="sed -r "s/[0-9,a-f,A-F]/h/g""'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/N/g"" 
$ alias testnumhex="sed -r "s/[0-9,a-f,A-F]/h/g""
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-152669/test-8"
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
	testfolder="/tmp/batspp-152669/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias hist='history $LINES'\n" "=========="
	test-9-actual 
	echo "=========" $"##2 SHOWS HISTORY WITHOUT TIMESTAMPS\n$ function h { hist | perl -pe 's/^(\\s*\\d+\\s*)(\\[[^\\]]+\\])(.*)/$1$3/;'; }\n## CREATES ERROR (INVALID SYNTAX)\n# $ hist\n# $ h" "========="
	test-9-expected 
	echo "============================"
	# ???: "alias hist='history $LINES'\n"=$(test-9-actual)
	# ???: "##2 SHOWS HISTORY WITHOUT TIMESTAMPS\n$ function h { hist | perl -pe 's/^(\\s*\\d+\\s*)(\\[[^\\]]+\\])(.*)/$1$3/;'; }\n## CREATES ERROR (INVALID SYNTAX)\n# $ hist\n# $ h"=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	alias hist='history $LINES'

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
##2 SHOWS HISTORY WITHOUT TIMESTAMPS
$ function h { hist | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
## CREATES ERROR (INVALID SYNTAX)
# $ hist
# $ h
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-152669/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"function asctime() { perl -e 'print (scalar localtime($1));'; echo ''; }\n" "=========="
	test-10-actual 
	echo "=========" $"$ asctime | perl -pe 's/\\d/N/g; s/\\w+ \\w+/DDD MMM/;'\nDDD MMM  N NN:NN:NN NNNN" "========="
	test-10-expected 
	echo "============================"
	# ???: "function asctime() { perl -e 'print (scalar localtime($1));'; echo ''; }\n"=$(test-10-actual)
	# ???: "$ asctime | perl -pe 's/\\d/N/g; s/\\w+ \\w+/DDD MMM/;'\nDDD MMM  N NN:NN:NN NNNN"=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	function asctime() { perl -e 'print (scalar localtime($1));'; echo ''; }

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ asctime | perl -pe 's/\d/N/g; s/\w+ \w+/DDD MMM/;'
DDD MMM  N NN:NN:NN NNNN
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-152669/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'function filter-dirnames () { perl -pe \'s/\\/[^ \\"]+\\/([^ \\/\\"]+)/$1/g;\'; }\n' "=========="
	test-11-actual 
	echo "=========" $'# awk is used for removing PID column (1st col)\n$ ps | filter-dirnames | testnum\n    PID TTY          TIME CMD\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN ps\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN sed\n  NNNNN pts/N    NN:NN:NN perl' "========="
	test-11-expected 
	echo "============================"
	# ???: 'function filter-dirnames () { perl -pe \'s/\\/[^ \\"]+\\/([^ \\/\\"]+)/$1/g;\'; }\n'=$(test-11-actual)
	# ???: '# awk is used for removing PID column (1st col)\n$ ps | filter-dirnames | testnum\n    PID TTY          TIME CMD\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN ps\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN sed\n  NNNNN pts/N    NN:NN:NN perl'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	function filter-dirnames () { perl -pe 's/\/[^ \"]+\/([^ \/\"]+)/$1/g;'; }

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# awk is used for removing PID column (1st col)
$ ps | filter-dirnames | testnum
    PID TTY          TIME CMD
  NNNNN pts/N    NN:NN:NN bash
  NNNNN pts/N    NN:NN:NN ps
  NNNNN pts/N    NN:NN:NN bash
  NNNNN pts/N    NN:NN:NN sed
  NNNNN pts/N    NN:NN:NN perl
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-152669/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"echo '99012342305324254' | comma-ize-number\n" "=========="
	test-12-actual 
	echo "=========" $'99,012,342,305,324,254' "========="
	test-12-expected 
	echo "============================"
	# ???: "echo '99012342305324254' | comma-ize-number\n"=$(test-12-actual)
	# ???: '99,012,342,305,324,254'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	echo '99012342305324254' | comma-ize-number

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
99,012,342,305,324,254
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-152669/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "8000000000" | apply-numeric-suffixes\n' "=========="
	test-13-actual 
	echo "=========" $'7.45G' "========="
	test-13-expected 
	echo "============================"
	# ???: 'echo "8000000000" | apply-numeric-suffixes\n'=$(test-13-actual)
	# ???: '7.45G'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	echo "8000000000" | apply-numeric-suffixes

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
7.45G
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-152669/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "8000000000" | apply-usage-numeric-suffixes\n' "=========="
	test-14-actual 
	echo "=========" $'$ echo "8000000" | apply-usage-numeric-suffixes \n7.45T\n7.63G' "========="
	test-14-expected 
	echo "============================"
	# ???: 'echo "8000000000" | apply-usage-numeric-suffixes\n'=$(test-14-actual)
	# ???: '$ echo "8000000" | apply-usage-numeric-suffixes \n7.45T\n7.63G'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	echo "8000000000" | apply-usage-numeric-suffixes

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo "8000000" | apply-usage-numeric-suffixes 
7.45T
7.63G
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-152669/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'byte-usage | testnum\n' "=========="
	test-15-actual 
	echo "=========" $"$ usage-pp | testnum\nBacking up 'usage.bytes.list' to './backup/usage.bytes.list'\nNN.NM\t.\nN.NNM\t./backup\nNNK\t.\nNNK\t./backup" "========="
	test-15-expected 
	echo "============================"
	# ???: 'byte-usage | testnum\n'=$(test-15-actual)
	# ???: "$ usage-pp | testnum\nBacking up 'usage.bytes.list' to './backup/usage.bytes.list'\nNN.NM\t.\nN.NNM\t./backup\nNNK\t.\nNNK\t./backup"=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	byte-usage | testnum

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ usage-pp | testnum
Backing up 'usage.bytes.list' to './backup/usage.bytes.list'
NN.NM	.
N.NNM	./backup
NNK	.
NNK	./backup
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-152669/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ ups a > psa.txt\n' "=========="
	test-16-actual 
	echo "=========" $"# $ usage psa.txt\n# | bash: ups: command not found\n# | bash: default_assignment: command not found\n# | bash: rename-with-file-date: command not found\n# | bash: $output_file: ambiguous redirect\n# | sort: fflush failed: 'standard output': Broken pipe\n# | sort: write error\n$ usage \nrenamed 'usage.list' -> 'usage.list.06Dec22'\n\x1b[?1h\x1b=" "========="
	test-16-expected 
	echo "============================"
	# ???: '# $ ups a > psa.txt\n'=$(test-16-actual)
	# ???: "# $ usage psa.txt\n# | bash: ups: command not found\n# | bash: default_assignment: command not found\n# | bash: rename-with-file-date: command not found\n# | bash: $output_file: ambiguous redirect\n# | sort: fflush failed: 'standard output': Broken pipe\n# | sort: write error\n$ usage \nrenamed 'usage.list' -> 'usage.list.06Dec22'\n\x1b[?1h\x1b="=$(test-16-expected)
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
# $ usage psa.txt
# | bash: ups: command not found
# | bash: default_assignment: command not found
# | bash: rename-with-file-date: command not found
# | bash: $output_file: ambiguous redirect
# | sort: fflush failed: 'standard output': Broken pipe
# | sort: write error
$ usage 
renamed 'usage.list' -> 'usage.list.06Dec22'
[?1h=
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-152669/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-17-actual 
	echo "=========" $'$ mkdir backup\n$ printf "THIS IS THE START\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS THE END\\n" > thisisatest.txt\n$ ps -aux > process.txt\n$ number-columns thisisatest.txt\n$ number-columns-comma process.txt\n1: THIS IS THE START\n1: USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND' "========="
	test-17-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-17-actual)
	# ???: '$ mkdir backup\n$ printf "THIS IS THE START\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS A TEST\\nTHIS IS THE END\\n" > thisisatest.txt\n$ ps -aux > process.txt\n$ number-columns thisisatest.txt\n$ number-columns-comma process.txt\n1: THIS IS THE START\n1: USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND'=$(test-17-expected)
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
$ mkdir backup
$ printf "THIS IS THE START\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE END\n" > thisisatest.txt
$ ps -aux > process.txt
$ number-columns thisisatest.txt
$ number-columns-comma process.txt
1: THIS IS THE START
1: USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-152669/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias reverse='tac'\n" "=========="
	test-18-actual 
	echo "=========" $'$ cat thisisatest.txt\n$ linebr\n$ reverse thisisatest.txt\nTHIS IS THE START\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE END\n--------------------------------------------------------------------------------\nTHIS IS THE END\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE START' "========="
	test-18-expected 
	echo "============================"
	# ???: "alias reverse='tac'\n"=$(test-18-actual)
	# ???: '$ cat thisisatest.txt\n$ linebr\n$ reverse thisisatest.txt\nTHIS IS THE START\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE END\n--------------------------------------------------------------------------------\nTHIS IS THE END\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE START'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	alias reverse='tac'

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ cat thisisatest.txt
$ linebr
$ reverse thisisatest.txt
THIS IS THE START
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS THE END
--------------------------------------------------------------------------------
THIS IS THE END
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS A TEST
THIS IS THE START
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-152669/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'backup-file thisisatest.txt\n' "=========="
	test-19-actual 
	echo "=========" $"Backing up 'thisisatest.txt' to './backup/thisisatest.txt'" "========="
	test-19-expected 
	echo "============================"
	# ???: 'backup-file thisisatest.txt\n'=$(test-19-actual)
	# ???: "Backing up 'thisisatest.txt' to './backup/thisisatest.txt'"=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	backup-file thisisatest.txt

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Backing up 'thisisatest.txt' to './backup/thisisatest.txt'
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-152669/test-20"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'byte-usage process.txt | testnum\n' "=========="
	test-20-actual 
	echo "=========" $'# (Same output for \'byte-usage "Hi Mom"\' and \'byte-usage thisisatest.txt\')\nNN.NM\t.\nN.NNM\t./backup' "========="
	test-20-expected 
	echo "============================"
	# ???: 'byte-usage process.txt | testnum\n'=$(test-20-actual)
	# ???: '# (Same output for \'byte-usage "Hi Mom"\' and \'byte-usage thisisatest.txt\')\nNN.NM\t.\nN.NNM\t./backup'=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	byte-usage process.txt | testnum

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# (Same output for 'byte-usage "Hi Mom"' and 'byte-usage thisisatest.txt')
NN.NM	.
N.NNM	./backup
END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-152669/test-21"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'check-errors process.txt\n' "=========="
	test-21-actual 
	echo "=========" $'$ linebr\n$ check-all-errors process.txt\n$ linebr\n$ check-warnings\n$ linebr\n$ check-all-warnings\n$ linebr\n$ check-errors-excerpt process.txt\n\x1b[?1h\x1b=' "========="
	test-21-expected 
	echo "============================"
	# ???: 'check-errors process.txt\n'=$(test-21-actual)
	# ???: '$ linebr\n$ check-all-errors process.txt\n$ linebr\n$ check-warnings\n$ linebr\n$ check-all-warnings\n$ linebr\n$ check-errors-excerpt process.txt\n\x1b[?1h\x1b='=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	check-errors process.txt

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ check-all-errors process.txt
$ linebr
$ check-warnings
$ linebr
$ check-all-warnings
$ linebr
$ check-errors-excerpt process.txt
[?1h=
END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-152669/test-22"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ rdiff process1.txt psa.txt | testnum\n' "=========="
	test-22-actual 
	echo "=========" $'# | Echo: Command not found.\n# | ???\n# | cvs: Command not found.\n# |\n# | echo: No match.\n# | echo: No match.\n# | issuing: tkdiff.tcl -r.-X processX.txt\n# | [X] XXXX\n# | tkdiff.tcl: Command not found.' "========="
	test-22-expected 
	echo "============================"
	# ???: '# $ rdiff process1.txt psa.txt | testnum\n'=$(test-22-actual)
	# ???: '# | Echo: Command not found.\n# | ???\n# | cvs: Command not found.\n# |\n# | echo: No match.\n# | echo: No match.\n# | issuing: tkdiff.tcl -r.-X processX.txt\n# | [X] XXXX\n# | tkdiff.tcl: Command not found.'=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true


}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | Echo: Command not found.
# | ???
# | cvs: Command not found.
# |
# | echo: No match.
# | echo: No match.
# | issuing: tkdiff.tcl -r.-X processX.txt
# | [X] XXXX
# | tkdiff.tcl: Command not found.
END_EXPECTED
}


@test "test-23" {
	testfolder="/tmp/batspp-152669/test-23"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ tkdiff- process.txt psa.txt\n' "=========="
	test-23-actual 
	echo "=========" $'# | [1] 5244' "========="
	test-23-expected 
	echo "============================"
	# ???: '# $ tkdiff- process.txt psa.txt\n'=$(test-23-actual)
	# ???: '# | [1] 5244'=$(test-23-expected)
	[ "$(test-23-actual)" == "$(test-23-expected)" ]
}

function test-23-actual () {
	# no-op in case content just a comment
	true


}

function test-23-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | [1] 5244
END_EXPECTED
}


@test "test-24" {
	testfolder="/tmp/batspp-152669/test-24"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ vdiff process.txt psa.txt\n' "=========="
	test-24-actual 
	echo "=========" $'# | Error in startup script: couldn\'t read file "/home/xaea12/bin/tkdiff.tcl": no such file or directory\n# | [2] 5251\n# | [1]   Exit 1                  wish -f $TOM_BIN/tkdiff.tcl "$@"' "========="
	test-24-expected 
	echo "============================"
	# ???: '# $ vdiff process.txt psa.txt\n'=$(test-24-actual)
	# ???: '# | Error in startup script: couldn\'t read file "/home/xaea12/bin/tkdiff.tcl": no such file or directory\n# | [2] 5251\n# | [1]   Exit 1                  wish -f $TOM_BIN/tkdiff.tcl "$@"'=$(test-24-expected)
	[ "$(test-24-actual)" == "$(test-24-expected)" ]
}

function test-24-actual () {
	# no-op in case content just a comment
	true


}

function test-24-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | Error in startup script: couldn't read file "/home/xaea12/bin/tkdiff.tcl": no such file or directory
# | [2] 5251
# | [1]   Exit 1                  wish -f $TOM_BIN/tkdiff.tcl "$@"
END_EXPECTED
}


@test "test-25" {
	testfolder="/tmp/batspp-152669/test-25"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'diff_options="--ignore-space-change --ignore-blank-lines"\n' "=========="
	test-25-actual 
	echo "=========" $'$ alias diff=\'command diff $diff_options\'\n$ alias diff-default=\'command diff\'\n$ alias diff-ignore-spacing=\'diff --ignore-all-space\'\n$ alias do-diff=\'do_diff.sh\'\n$ function diff-rev () {\n$     local diff_program="diff"\n$     if [ "$1" = "--diff-prog" ]; then\n$         diff_program="$2"\n$         shift 2\n$     fi\n$     local right_file="$1"\n$     local left_file="$2"\n$     if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi\n$     "$diff_program" "$left_file" "$right_file"\n$ }\n$ alias kdiff-rev=\'diff-rev --diff-prog kdiff\'\n$ alias diff-log-output=\'compare-log-output.sh\'\n$ alias vdiff-rev=kdiff-rev' "========="
	test-25-expected 
	echo "============================"
	# ???: 'diff_options="--ignore-space-change --ignore-blank-lines"\n'=$(test-25-actual)
	# ???: '$ alias diff=\'command diff $diff_options\'\n$ alias diff-default=\'command diff\'\n$ alias diff-ignore-spacing=\'diff --ignore-all-space\'\n$ alias do-diff=\'do_diff.sh\'\n$ function diff-rev () {\n$     local diff_program="diff"\n$     if [ "$1" = "--diff-prog" ]; then\n$         diff_program="$2"\n$         shift 2\n$     fi\n$     local right_file="$1"\n$     local left_file="$2"\n$     if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi\n$     "$diff_program" "$left_file" "$right_file"\n$ }\n$ alias kdiff-rev=\'diff-rev --diff-prog kdiff\'\n$ alias diff-log-output=\'compare-log-output.sh\'\n$ alias vdiff-rev=kdiff-rev'=$(test-25-expected)
	[ "$(test-25-actual)" == "$(test-25-expected)" ]
}

function test-25-actual () {
	# no-op in case content just a comment
	true

	diff_options="--ignore-space-change --ignore-blank-lines"

}

function test-25-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias diff='command diff $diff_options'
$ alias diff-default='command diff'
$ alias diff-ignore-spacing='diff --ignore-all-space'
$ alias do-diff='do_diff.sh'
$ function diff-rev () {
$     local diff_program="diff"
$     if [ "$1" = "--diff-prog" ]; then
$         diff_program="$2"
$         shift 2
$     fi
$     local right_file="$1"
$     local left_file="$2"
$     if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi
$     "$diff_program" "$left_file" "$right_file"
$ }
$ alias kdiff-rev='diff-rev --diff-prog kdiff'
$ alias diff-log-output='compare-log-output.sh'
$ alias vdiff-rev=kdiff-rev
END_EXPECTED
}


@test "test-26" {
	testfolder="/tmp/batspp-152669/test-26"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps -u > process1.txt\n' "=========="
	test-26-actual 
	echo "=========" $'$ ps -u > process2.txt' "========="
	test-26-expected 
	echo "============================"
	# ???: 'ps -u > process1.txt\n'=$(test-26-actual)
	# ???: '$ ps -u > process2.txt'=$(test-26-expected)
	[ "$(test-26-actual)" == "$(test-26-expected)" ]
}

function test-26-actual () {
	# no-op in case content just a comment
	true

	ps -u > process1.txt

}

function test-26-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ ps -u > process2.txt
END_EXPECTED
}


@test "test-27" {
	testfolder="/tmp/batspp-152669/test-27"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ diff process1.txt process2.txt #(DIFFERENTIATING PROCESSES FOR DIFFERENT INSTANCES)\n' "=========="
	test-27-actual 
	echo "=========" $'$ diff process1.txt process2.txt | testuser | testnumhex\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u' "========="
	test-27-expected 
	echo "============================"
	# ???: '# $ diff process1.txt process2.txt #(DIFFERENTIATING PROCESSES FOR DIFFERENT INSTANCES)\n'=$(test-27-actual)
	# ???: '$ diff process1.txt process2.txt | testuser | testnumhex\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u'=$(test-27-expected)
	[ "$(test-27-actual)" == "$(test-27-expected)" ]
}

function test-27-actual () {
	# no-op in case content just a comment
	true


}

function test-27-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ diff process1.txt process2.txt | testuser | testnumhex
hhhhhhhhhhh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
---
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
END_EXPECTED
}


@test "test-28" {
	testfolder="/tmp/batspp-152669/test-28"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ diff-default process1.txt process2.txt\n' "=========="
	test-28-actual 
	echo "=========" $'$ diff-default process1.txt process2.txt | testuser | testnumhex\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u' "========="
	test-28-expected 
	echo "============================"
	# ???: '# $ diff-default process1.txt process2.txt\n'=$(test-28-actual)
	# ???: '$ diff-default process1.txt process2.txt | testuser | testnumhex\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u'=$(test-28-expected)
	[ "$(test-28-actual)" == "$(test-28-expected)" ]
}

function test-28-actual () {
	# no-op in case content just a comment
	true


}

function test-28-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ diff-default process1.txt process2.txt | testuser | testnumhex
hhhhhhhhhhh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
---
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
END_EXPECTED
}


@test "test-29" {
	testfolder="/tmp/batspp-152669/test-29"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'diff-ignore-spacing process1.txt process2.txt | testuser | testnumhex\n' "=========="
	test-29-actual 
	echo "=========" $'hhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u' "========="
	test-29-expected 
	echo "============================"
	# ???: 'diff-ignore-spacing process1.txt process2.txt | testuser | testnumhex\n'=$(test-29-actual)
	# ???: 'hhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u'=$(test-29-expected)
	[ "$(test-29-actual)" == "$(test-29-expected)" ]
}

function test-29-actual () {
	# no-op in case content just a comment
	true

	diff-ignore-spacing process1.txt process2.txt | testuser | testnumhex

}

function test-29-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
hhhhhhhhhhh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
---
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
END_EXPECTED
}


@test "test-30" {
	testfolder="/tmp/batspp-152669/test-30"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'do-diff process1.txt process2.txt | testuser | testnumhex\n' "=========="
	test-30-actual 
	echo "=========" $'prohhssh.txt vs. prohhssh.txt\nhihhhrhnhhs: prohhssh.txt prohhssh.txt\n-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt\n-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n------------------------------------------------------------------------' "========="
	test-30-expected 
	echo "============================"
	# ???: 'do-diff process1.txt process2.txt | testuser | testnumhex\n'=$(test-30-actual)
	# ???: 'prohhssh.txt vs. prohhssh.txt\nhihhhrhnhhs: prohhssh.txt prohhssh.txt\n-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt\n-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt\nhhhhhhhhhhh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n---\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh\n> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u\n------------------------------------------------------------------------'=$(test-30-expected)
	[ "$(test-30-actual)" == "$(test-30-expected)" ]
}

function test-30-actual () {
	# no-op in case content just a comment
	true

	do-diff process1.txt process2.txt | testuser | testnumhex

}

function test-30-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
prohhssh.txt vs. prohhssh.txt
hihhhrhnhhs: prohhssh.txt prohhssh.txt
-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt
-rw-rw-r-- h ushrxhhhh ushrxhhhh hhhh hhh  h hh:hh prohhssh.txt
hhhhhhhhhhh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
< ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
---
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    Ss   hh:hh   h:hh /usr/hin/hhsh
> ushrxhhhh      hhhhh  h.h  h.h  hhhhh  hhhh pts/h    R+   hh:hh   h:hh ps -u
------------------------------------------------------------------------
END_EXPECTED
}


@test "test-31" {
	testfolder="/tmp/batspp-152669/test-31"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ kdiff-rev process1.txt process2.txt\n' "=========="
	test-31-actual 
	echo "=========" $'# $ linebr\n# $ vdiff-rev process1.txt process2.txt\n# | [1] 7234\n# | --------------------------------------------------------------------------------\n# | [1]+  Done                    kdiff.sh "$@"\n# | [1] 7238' "========="
	test-31-expected 
	echo "============================"
	# ???: '# $ kdiff-rev process1.txt process2.txt\n'=$(test-31-actual)
	# ???: '# $ linebr\n# $ vdiff-rev process1.txt process2.txt\n# | [1] 7234\n# | --------------------------------------------------------------------------------\n# | [1]+  Done                    kdiff.sh "$@"\n# | [1] 7238'=$(test-31-expected)
	[ "$(test-31-actual)" == "$(test-31-expected)" ]
}

function test-31-actual () {
	# no-op in case content just a comment
	true


}

function test-31-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# $ linebr
# $ vdiff-rev process1.txt process2.txt
# | [1] 7234
# | --------------------------------------------------------------------------------
# | [1]+  Done                    kdiff.sh "$@"
# | [1] 7238
END_EXPECTED
}


@test "test-32" {
	testfolder="/tmp/batspp-152669/test-32"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "TESTFILE1\\nNEXT LINE" > testtxt1.txt\n' "=========="
	test-32-actual 
	echo "=========" $'$ printf "TESTFILE2\\nNEXT LINE2" > testtxt2.txt\n$ prepare-find-files-here | testuser | testnum | awk \'!($6="")\'\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log' "========="
	test-32-expected 
	echo "============================"
	# ???: 'printf "TESTFILE1\\nNEXT LINE" > testtxt1.txt\n'=$(test-32-actual)
	# ???: '$ printf "TESTFILE2\\nNEXT LINE2" > testtxt2.txt\n$ prepare-find-files-here | testuser | testnum | awk \'!($6="")\'\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log\n-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list\n-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log'=$(test-32-expected)
	[ "$(test-32-actual)" == "$(test-32-expected)" ]
}

function test-32-actual () {
	# no-op in case content just a comment
	true

	printf "TESTFILE1\nNEXT LINE" > testtxt1.txt

}

function test-32-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "TESTFILE2\nNEXT LINE2" > testtxt2.txt
$ prepare-find-files-here | testuser | testnum | awk '!($6="")'
-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-alR.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-alR.list.log
-rw-rw-r-- N userxfNNN userxfNNN NNN  N NN:NN ls-R.list
-rw-rw-r-- N userxfNNN userxfNNN N  N NN:NN ls-R.list.log
END_EXPECTED
}


@test "test-33" {
	testfolder="/tmp/batspp-152669/test-33"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'diff-log-output ls-alR.list.log ls-R.list.log\n' "=========="
	test-33-actual 
	echo "=========" $'' "========="
	test-33-expected 
	echo "============================"
	# ???: 'diff-log-output ls-alR.list.log ls-R.list.log\n'=$(test-33-actual)
	# ???: ''=$(test-33-expected)
	[ "$(test-33-actual)" == "$(test-33-expected)" ]
}

function test-33-actual () {
	# no-op in case content just a comment
	true

	diff-log-output ls-alR.list.log ls-R.list.log

}

function test-33-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-34" {
	testfolder="/tmp/batspp-152669/test-34"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf $HOME/info > /dev/null\n' "=========="
	test-34-actual 
	echo "=========" $'$ mkdir -p $HOME/info\n$ echo "THIS IS A NOICE SIGNATURE" > $HOME/info/.noice-signature' "========="
	test-34-expected 
	echo "============================"
	# ???: 'rm -rf $HOME/info > /dev/null\n'=$(test-34-actual)
	# ???: '$ mkdir -p $HOME/info\n$ echo "THIS IS A NOICE SIGNATURE" > $HOME/info/.noice-signature'=$(test-34-expected)
	[ "$(test-34-actual)" == "$(test-34-expected)" ]
}

function test-34-actual () {
	# no-op in case content just a comment
	true

	rm -rf $HOME/info > /dev/null

}

function test-34-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p $HOME/info
$ echo "THIS IS A NOICE SIGNATURE" > $HOME/info/.noice-signature
END_EXPECTED
}


@test "test-35" {
	testfolder="/tmp/batspp-152669/test-35"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'signature noice | testuser\n' "=========="
	test-35-actual 
	echo "=========" $'/home/userxf333/info/.noice-signature:\nTHIS IS A NOICE SIGNATURE' "========="
	test-35-expected 
	echo "============================"
	# ???: 'signature noice | testuser\n'=$(test-35-actual)
	# ???: '/home/userxf333/info/.noice-signature:\nTHIS IS A NOICE SIGNATURE'=$(test-35-expected)
	[ "$(test-35-actual)" == "$(test-35-expected)" ]
}

function test-35-actual () {
	# no-op in case content just a comment
	true

	signature noice | testuser

}

function test-35-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/home/userxf333/info/.noice-signature:
THIS IS A NOICE SIGNATURE
END_EXPECTED
}


@test "test-36" {
	testfolder="/tmp/batspp-152669/test-36"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'dobackup process1.txt\n' "=========="
	test-36-actual 
	echo "=========" $"Backing up 'process1.txt' to './backup/process1.txt'" "========="
	test-36-expected 
	echo "============================"
	# ???: 'dobackup process1.txt\n'=$(test-36-actual)
	# ???: "Backing up 'process1.txt' to './backup/process1.txt'"=$(test-36-expected)
	[ "$(test-36-actual)" == "$(test-36-expected)" ]
}

function test-36-actual () {
	# no-op in case content just a comment
	true

	dobackup process1.txt

}

function test-36-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Backing up 'process1.txt' to './backup/process1.txt'
END_EXPECTED
}


@test "test-37" {
	testfolder="/tmp/batspp-152669/test-37"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ diff-backup process1.txt\n' "=========="
	test-37-actual 
	echo "=========" $'$ diff-backup process1.txt' "========="
	test-37-expected 
	echo "============================"
	# ???: '# $ diff-backup process1.txt\n'=$(test-37-actual)
	# ???: '$ diff-backup process1.txt'=$(test-37-expected)
	[ "$(test-37-actual)" == "$(test-37-expected)" ]
}

function test-37-actual () {
	# no-op in case content just a comment
	true


}

function test-37-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ diff-backup process1.txt
END_EXPECTED
}


@test "test-38" {
	testfolder="/tmp/batspp-152669/test-38"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'kdiff-backup process1.txt\n' "=========="
	test-38-actual 
	echo "=========" $'[1] 24771\n[1]+  Done                    kdiff.sh "$@"' "========="
	test-38-expected 
	echo "============================"
	# ???: 'kdiff-backup process1.txt\n'=$(test-38-actual)
	# ???: '[1] 24771\n[1]+  Done                    kdiff.sh "$@"'=$(test-38-expected)
	[ "$(test-38-actual)" == "$(test-38-expected)" ]
}

function test-38-actual () {
	# no-op in case content just a comment
	true

	kdiff-backup process1.txt

}

function test-38-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[1] 24771
[1]+  Done                    kdiff.sh "$@"
END_EXPECTED
}


@test "test-39" {
	testfolder="/tmp/batspp-152669/test-39"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Done"\n' "=========="
	test-39-actual 
	echo "=========" $'Done' "========="
	test-39-expected 
	echo "============================"
	# ???: 'echo "Done"\n'=$(test-39-actual)
	# ???: 'Done'=$(test-39-expected)
	[ "$(test-39-actual)" == "$(test-39-expected)" ]
}

function test-39-actual () {
	# no-op in case content just a comment
	true

	echo "Done"

}

function test-39-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Done
END_EXPECTED
}
