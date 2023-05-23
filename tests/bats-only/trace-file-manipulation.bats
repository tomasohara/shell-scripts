#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-136011/test-1"
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
	testfolder="/tmp/batspp-136011/test-3"
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
	testfolder="/tmp/batspp-136011/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/user/g""\n' "=========="
	test-4-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/X/g""' "========="
	test-4-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/user/g""\n'=$(test-4-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/X/g""'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/user/g""

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/X/g""
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-136011/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-file-manipulation\n' "=========="
	test-5-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2' "========="
	test-5-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-file-manipulation\n'=$(test-5-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-file-manipulation

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
2
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-136011/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-9890\n' "=========="
	test-6-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-file-manipulation/test-9890' "========="
	test-6-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-9890\n'=$(test-6-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-file-manipulation/test-9890'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-9890

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
/tmp/test-file-manipulation/test-9890
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-136011/test-7"
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
	testfolder="/tmp/batspp-136011/test-8"
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
	testfolder="/tmp/batspp-136011/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./*\n' "=========="
	test-9-actual 
	echo "=========" $'$ free -m > freemem_mb.txt\n$ linebr\n$ asc-it freemem_mb.txt \n#(NEED SOLUTION FOR bash: BACKUP/freemem_mb.txt: No such file or directory)\n#(IN CASE OF \'BACKUP\'->\'backup\' IN asc-it, ERROR = bash: asc: command not found)\n$ linebr\n$ ls -l ./backup/ | testuser | testnum | awk \'!($6="")\'\n$ linebr\n$ cat ./backup/freemem_mb.txt | testnum \n--------------------------------------------------------------------------------\nBacking up \'freemem_mb.txt\' to \'./backup/freemem_mb.txt\'\nbash: BACKUP/freemem_mb.txt: No such file or directory\n--------------------------------------------------------------------------------\ntotal X    \n-r--r--r-- X user user XXX  X XX:XX freemem_mb.txt\n--------------------------------------------------------------------------------\n               total        used        free      shared  buff/cache   available\nMem:            XXXX        XXXX         XXX         XXX         XXX         XXX\nSwap:           XXXX         XXX        XXXX' "========="
	test-9-expected 
	echo "============================"
	# ???: 'rm -rf ./*\n'=$(test-9-actual)
	# ???: '$ free -m > freemem_mb.txt\n$ linebr\n$ asc-it freemem_mb.txt \n#(NEED SOLUTION FOR bash: BACKUP/freemem_mb.txt: No such file or directory)\n#(IN CASE OF \'BACKUP\'->\'backup\' IN asc-it, ERROR = bash: asc: command not found)\n$ linebr\n$ ls -l ./backup/ | testuser | testnum | awk \'!($6="")\'\n$ linebr\n$ cat ./backup/freemem_mb.txt | testnum \n--------------------------------------------------------------------------------\nBacking up \'freemem_mb.txt\' to \'./backup/freemem_mb.txt\'\nbash: BACKUP/freemem_mb.txt: No such file or directory\n--------------------------------------------------------------------------------\ntotal X    \n-r--r--r-- X user user XXX  X XX:XX freemem_mb.txt\n--------------------------------------------------------------------------------\n               total        used        free      shared  buff/cache   available\nMem:            XXXX        XXXX         XXX         XXX         XXX         XXX\nSwap:           XXXX         XXX        XXXX'=$(test-9-expected)
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
$ free -m > freemem_mb.txt
$ linebr
$ asc-it freemem_mb.txt 
#(NEED SOLUTION FOR bash: BACKUP/freemem_mb.txt: No such file or directory)
#(IN CASE OF 'BACKUP'->'backup' IN asc-it, ERROR = bash: asc: command not found)
$ linebr
$ ls -l ./backup/ | testuser | testnum | awk '!($6="")'
$ linebr
$ cat ./backup/freemem_mb.txt | testnum 
--------------------------------------------------------------------------------
Backing up 'freemem_mb.txt' to './backup/freemem_mb.txt'
bash: BACKUP/freemem_mb.txt: No such file or directory
--------------------------------------------------------------------------------
total X    
-r--r--r-- X user user XXX  X XX:XX freemem_mb.txt
--------------------------------------------------------------------------------
               total        used        free      shared  buff/cache   available
Mem:            XXXX        XXXX         XXX         XXX         XXX         XXX
Swap:           XXXX         XXX        XXXX
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-136011/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'perl-slurp -v | testnum\n' "=========="
	test-10-actual 
	echo "=========" $'' "========="
	test-10-expected 
	echo "============================"
	# ???: 'perl-slurp -v | testnum\n'=$(test-10-actual)
	# ???: ''=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	perl-slurp -v | testnum

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-136011/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'function test-text () { printf "THIS IS A TEST. \\rTHIS IS ALSO A TEST\\r. THIS IS A TEST TOO."; }\n' "=========="
	test-11-actual 
	echo "=========" $'$ test-text\n$ printf "\\n"\n$ linebr\n$ test-text | remove-cr\n$ printf "\\n"\n$ linebr\n$ test-text | alt-remove-cr\n. THIS IS A TEST TOO.\n--------------------------------------------------------------------------------\nTHIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.\n--------------------------------------------------------------------------------\nTHIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.' "========="
	test-11-expected 
	echo "============================"
	# ???: 'function test-text () { printf "THIS IS A TEST. \\rTHIS IS ALSO A TEST\\r. THIS IS A TEST TOO."; }\n'=$(test-11-actual)
	# ???: '$ test-text\n$ printf "\\n"\n$ linebr\n$ test-text | remove-cr\n$ printf "\\n"\n$ linebr\n$ test-text | alt-remove-cr\n. THIS IS A TEST TOO.\n--------------------------------------------------------------------------------\nTHIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.\n--------------------------------------------------------------------------------\nTHIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	function test-text () { printf "THIS IS A TEST. \rTHIS IS ALSO A TEST\r. THIS IS A TEST TOO."; }

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ test-text
$ printf "\n"
$ linebr
$ test-text | remove-cr
$ printf "\n"
$ linebr
$ test-text | alt-remove-cr
. THIS IS A TEST TOO.
--------------------------------------------------------------------------------
THIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.
--------------------------------------------------------------------------------
THIS IS A TEST. THIS IS ALSO A TEST. THIS IS A TEST TOO.
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-136011/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps -l > process_list.txt\n' "=========="
	test-12-actual 
	echo "=========" $"$ remove-cr-and-backup process_list.txt\nBacking up 'process_list.txt' to './backup/process_list.txt'" "========="
	test-12-expected 
	echo "============================"
	# ???: 'ps -l > process_list.txt\n'=$(test-12-actual)
	# ???: "$ remove-cr-and-backup process_list.txt\nBacking up 'process_list.txt' to './backup/process_list.txt'"=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	ps -l > process_list.txt

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ remove-cr-and-backup process_list.txt
Backing up 'process_list.txt' to './backup/process_list.txt'
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-136011/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'test-text | perl-remove-cr\n' "=========="
	test-13-actual 
	echo "=========" $'-i used with no filenames on the command line, reading from STDIN.\n. THIS IS A TEST TOO.IS ALSO A TEST' "========="
	test-13-expected 
	echo "============================"
	# ???: 'test-text | perl-remove-cr\n'=$(test-13-actual)
	# ???: '-i used with no filenames on the command line, reading from STDIN.\n. THIS IS A TEST TOO.IS ALSO A TEST'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	test-text | perl-remove-cr

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
-i used with no filenames on the command line, reading from STDIN.
. THIS IS A TEST TOO.IS ALSO A TEST
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-136011/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps -u > ntest1.txt\n' "=========="
	test-14-actual 
	echo "=========" $'$ ps -l > ntest2.txt\n$ intersection ntest1.txt ntest2.txt | testnum\nPID\nTTY\nTIME\nbash\nbash\nbash\nXXXX\npts/X\npts/X\nps' "========="
	test-14-expected 
	echo "============================"
	# ???: 'ps -u > ntest1.txt\n'=$(test-14-actual)
	# ???: '$ ps -l > ntest2.txt\n$ intersection ntest1.txt ntest2.txt | testnum\nPID\nTTY\nTIME\nbash\nbash\nbash\nXXXX\npts/X\npts/X\nps'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	ps -u > ntest1.txt

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ ps -l > ntest2.txt
$ intersection ntest1.txt ntest2.txt | testnum
PID
TTY
TIME
bash
bash
bash
XXXX
pts/X
pts/X
ps
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-136011/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'difference ntest1.txt ntest2.txt | testuser | testnum\n' "=========="
	test-15-actual 
	echo "=========" $'%CPU\n%MEM\n-u\n/usr/bin/bash\n/usr/bin/pyth\nX.X\nX.X\nX.X\nX:XX\nX:XX\nX:XX\nX.X\nXXXXXX\nXXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nX.X\nX.X\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXXXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nCOMMAND\nR+\nRSS\nSTART\nSTAT\nSl+\nSs\nSs+\nUSER\nVSZ\nuser\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\ntomohara-a\nvi' "========="
	test-15-expected 
	echo "============================"
	# ???: 'difference ntest1.txt ntest2.txt | testuser | testnum\n'=$(test-15-actual)
	# ???: '%CPU\n%MEM\n-u\n/usr/bin/bash\n/usr/bin/pyth\nX.X\nX.X\nX.X\nX:XX\nX:XX\nX:XX\nX.X\nXXXXXX\nXXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXXXXX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nX.X\nX.X\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXX:XX\nXXXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nXXXX\nCOMMAND\nR+\nRSS\nSTART\nSTAT\nSl+\nSs\nSs+\nUSER\nVSZ\nuser\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\npts/X\ntomohara-a\nvi'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	difference ntest1.txt ntest2.txt | testuser | testnum

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
%CPU
%MEM
-u
/usr/bin/bash
/usr/bin/pyth
X.X
X.X
X.X
X:XX
X:XX
X:XX
X.X
XXXXXX
XXXXXX
XXXXX
XXXXX
XXXXX
XXXXX
XXXXX
XXXXX
XX:XX
XX:XX
XX:XX
XX:XX
X.X
X.X
XX:XX
XX:XX
XX:XX
XX:XX
XX:XX
XX:XX
XXXXXX
XXXX
XXXX
XXXX
XXXX
XXXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
XXXX
COMMAND
R+
RSS
START
STAT
Sl+
Ss
Ss+
USER
VSZ
user
pts/X
pts/X
pts/X
pts/X
pts/X
pts/X
pts/X
pts/X
pts/X
tomohara-a
vi
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-136011/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'free -m > free1.txt\n' "=========="
	test-16-actual 
	echo "=========" $'$ free > free2.txt\n$ line-intersection free1.txt free2.txt\n               total        used        free      shared  buff/cache   available' "========="
	test-16-expected 
	echo "============================"
	# ???: 'free -m > free1.txt\n'=$(test-16-actual)
	# ???: '$ free > free2.txt\n$ line-intersection free1.txt free2.txt\n               total        used        free      shared  buff/cache   available'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	free -m > free1.txt

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ free > free2.txt
$ line-intersection free1.txt free2.txt
               total        used        free      shared  buff/cache   available
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-136011/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'line-difference free1.txt free2.txt | testnum\n' "=========="
	test-17-actual 
	echo "=========" $'$ linebr\n$ line-difference free2.txt free1.txt | testnum\nMem:            XXXX        XXXX         XXX         XXX         XXX         XXX\nSwap:           XXXX         XXX        XXXX\n--------------------------------------------------------------------------------\nMem:         XXXXXXX     XXXXXXX      XXXXXX      XXXXXX     XXXXXXX      XXXXXX\nSwap:        XXXXXXX      XXXXXX     XXXXXXX' "========="
	test-17-expected 
	echo "============================"
	# ???: 'line-difference free1.txt free2.txt | testnum\n'=$(test-17-actual)
	# ???: '$ linebr\n$ line-difference free2.txt free1.txt | testnum\nMem:            XXXX        XXXX         XXX         XXX         XXX         XXX\nSwap:           XXXX         XXX        XXXX\n--------------------------------------------------------------------------------\nMem:         XXXXXXX     XXXXXXX      XXXXXX      XXXXXX     XXXXXXX      XXXXXX\nSwap:        XXXXXXX      XXXXXX     XXXXXXX'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	line-difference free1.txt free2.txt | testnum

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ line-difference free2.txt free1.txt | testnum
Mem:            XXXX        XXXX         XXX         XXX         XXX         XXX
Swap:           XXXX         XXX        XXXX
--------------------------------------------------------------------------------
Mem:         XXXXXXX     XXXXXXX      XXXXXX      XXXXXX     XXXXXXX      XXXXXX
Swap:        XXXXXXX      XXXXXX     XXXXXXX
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-136011/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat ntest1.txt | testuser | testnum\n' "=========="
	test-18-actual 
	echo "=========" $'$ linebr\n$ show-line 3 ntest1.txt | testuser | testnum\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash\nuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash\nuser       XXXX  X.X  X.X XXXXXX XXXXX pts/X    Sl+  XX:XX   X:XX vi tomohara-a\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u\n--------------------------------------------------------------------------------\nuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth' "========="
	test-18-expected 
	echo "============================"
	# ???: 'cat ntest1.txt | testuser | testnum\n'=$(test-18-actual)
	# ???: '$ linebr\n$ show-line 3 ntest1.txt | testuser | testnum\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash\nuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash\nuser       XXXX  X.X  X.X XXXXXX XXXXX pts/X    Sl+  XX:XX   X:XX vi tomohara-a\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u\n--------------------------------------------------------------------------------\nuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	cat ntest1.txt | testuser | testnum

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ show-line 3 ntest1.txt | testuser | testnum
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash
user       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bash
user       XXXX  X.X  X.X XXXXXX XXXXX pts/X    Sl+  XX:XX   X:XX vi tomohara-a
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u
--------------------------------------------------------------------------------
user       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-136011/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'last-n-with-header 4 ntest1.txt | testuser | testnum\n' "=========="
	test-19-actual 
	echo "=========" $'$ linebr\n$ last-n-with-header 2 ntest2.txt | testuser | testnum\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u\n--------------------------------------------------------------------------------\nF S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD\nX S  XXXX    XXXX    XXXX  X  XX   X -  XXXX do_wai pts/X    XX:XX:XX bash\nX R  XXXX    XXXX    XXXX  X  XX   X -  XXXX -      pts/X    XX:XX:XX ps' "========="
	test-19-expected 
	echo "============================"
	# ???: 'last-n-with-header 4 ntest1.txt | testuser | testnum\n'=$(test-19-actual)
	# ???: '$ linebr\n$ last-n-with-header 2 ntest2.txt | testuser | testnum\nUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash\nuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u\n--------------------------------------------------------------------------------\nF S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD\nX S  XXXX    XXXX    XXXX  X  XX   X -  XXXX do_wai pts/X    XX:XX:XX bash\nX R  XXXX    XXXX    XXXX  X  XX   X -  XXXX -      pts/X    XX:XX:XX ps'=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	last-n-with-header 4 ntest1.txt | testuser | testnum

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ last-n-with-header 2 ntest2.txt | testuser | testnum
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bash
user       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u
--------------------------------------------------------------------------------
F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
X S  XXXX    XXXX    XXXX  X  XX   X -  XXXX do_wai pts/X    XX:XX:XX bash
X R  XXXX    XXXX    XXXX  X  XX   X -  XXXX -      pts/X    XX:XX:XX ps
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-136011/test-20"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-20-actual 
	echo "=========" $'' "========="
	test-20-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-20-actual)
	# ???: ''=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

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

	alias testuser="sed -r "s/"$USER"+/user/g""
	alias testnum="sed -r "s/[0-9]/X/g""
}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	BIN_DIR=$PWD/..
	actual=$(test3-assert2-actual)
	expected=$(test3-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert2-actual () {
	alias | wc -l
}
function test3-assert2-expected () {
	echo -e '2'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-9890
	cd "$temp_dir"
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test5-assert1-actual)
	expected=$(test5-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test5-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test5-assert1-expected () {
	echo -e '30'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	free -m > freemem_mb.txt
	linebr
	linebr
	ls -l ./backup/ | testuser | testnum | awk '!($6="")'
	linebr
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	perl-slurp -v | testnum
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	function test-text () { printf "THIS IS A TEST. \rTHIS IS ALSO A TEST\r. THIS IS A TEST TOO."; }
	test-text
	printf "\n"
	linebr
	test-text | remove-cr
	printf "\n"
	linebr
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	ps -l > process_list.txt
	actual=$(test10-assert2-actual)
	expected=$(test10-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert2-actual () {
	remove-cr-and-backup process_list.txt
}
function test10-assert2-expected () {
	echo -e "Backing up 'process_list.txt' to './backup/process_list.txt'"
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	ps -u > ntest1.txt
	ps -l > ntest2.txt
	actual=$(test12-assert3-actual)
	expected=$(test12-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert3-actual () {
	intersection ntest1.txt ntest2.txt | testnum
}
function test12-assert3-expected () {
	echo -e 'PIDTTYTIMEbashbashbashXXXXpts/Xpts/Xps'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	free -m > free1.txt
	free > free2.txt
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
	line-intersection free1.txt free2.txt
}
function test14-assert3-expected () {
	echo -e 'total        used        free      shared  buff/cache   available'
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	line-difference free1.txt free2.txt | testnum
	linebr
	actual=$(test15-assert3-actual)
	expected=$(test15-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert3-actual () {
	line-difference free2.txt free1.txt | testnum
}
function test15-assert3-expected () {
	echo -e 'Mem:            XXXX        XXXX         XXX         XXX         XXX         XXXSwap:           XXXX         XXX        XXXX--------------------------------------------------------------------------------Mem:         XXXXXXX     XXXXXXX      XXXXXX      XXXXXX     XXXXXXX      XXXXXXSwap:        XXXXXXX      XXXXXX     XXXXXXX'
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	cat ntest1.txt | testuser | testnum
	linebr
	actual=$(test16-assert3-actual)
	expected=$(test16-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert3-actual () {
	show-line 3 ntest1.txt | testuser | testnum
}
function test16-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bashuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pythuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bashuser       XXXX  X.X  X.X XXXXXX XXXXX pts/X    Sl+  XX:XX   X:XX vi tomohara-auser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u--------------------------------------------------------------------------------user       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	last-n-with-header 4 ntest1.txt | testuser | testnum
	linebr
	actual=$(test17-assert3-actual)
	expected=$(test17-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert3-actual () {
	last-n-with-header 2 ntest2.txt | testuser | testnum
}
function test17-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u--------------------------------------------------------------------------------F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMDX S  XXXX    XXXX    XXXX  X  XX   X -  XXXX do_wai pts/X    XX:XX:XX bashX R  XXXX    XXXX    XXXX  X  XX   X -  XXXX -      pts/X    XX:XX:XX ps'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
>>>>>>> integration-testing-3fa2c13
}
