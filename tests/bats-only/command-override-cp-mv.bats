#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-159760/test-1"
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
	testfolder="/tmp/batspp-159760/test-3"
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
	testfolder="/tmp/batspp-159760/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-4-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g""' "========="
	test-4-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-4-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g""'=$(test-4-expected)
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
$ alias testnum="sed -r "s/[0-9]/N/g""
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-159760/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=./tmp/test-cp-mv\n' "=========="
	test-5-actual 
	echo "=========" $'$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-1210\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd | testuser\n$ alias | wc -l\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/home/userxf333/tom-project/shell-scripts/tests/tmp/test-cp-mv/test-1210\n2' "========="
	test-5-expected 
	echo "============================"
	# ???: 'TMP=./tmp/test-cp-mv\n'=$(test-5-actual)
	# ???: '$ BIN_DIR=$PWD/..\n## temp_dir=$TMP/test-$$\n$ temp_dir=$TMP/test-1210\n$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd | testuser\n$ alias | wc -l\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/home/userxf333/tom-project/shell-scripts/tests/tmp/test-cp-mv/test-1210\n2'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	TMP=./tmp/test-cp-mv

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ BIN_DIR=$PWD/..
## temp_dir=$TMP/test-$$
$ temp_dir=$TMP/test-1210
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd | testuser
$ alias | wc -l
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/home/userxf333/tom-project/shell-scripts/tests/tmp/test-cp-mv/test-1210
2
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-159760/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $'3' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-6-actual)
	# ???: '3'=$(test-6-expected)
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
3
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-159760/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-159760/test-8"
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
	testfolder="/tmp/batspp-159760/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'clear\n' "=========="
	test-9-actual 
	echo "=========" $'use cls instead (or /bin/clear)' "========="
	test-9-expected 
	echo "============================"
	# ???: 'clear\n'=$(test-9-actual)
	# ???: 'use cls instead (or /bin/clear)'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	clear

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
use cls instead (or /bin/clear)
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-159760/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./*\n' "=========="
	test-10-actual 
	echo "=========" $'$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir mvtest_dir1\n## WORK OF ALIASES\n$ mv abc ./mvtest_dir1\n$ move def ./mvtest_dir1\n$ move-force ghi ./mvtest_dir1\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ ls -l ./mvtest_dir1 | awk \'!($6="")\' | testnum | testuser\n$ linebr\nremoved \'./testdir1/.bashrc\'\nremoved directory \'./testdir1\'\n--------------------------------------------------------------------------------\nrenamed \'abc\' -> \'./mvtest_dir1/abc\'\nrenamed \'def\' -> \'./mvtest_dir1/def\'\nrenamed \'ghi\' -> \'./mvtest_dir1/ghi\'\n--------------------------------------------------------------------------------\ntotal N    \ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN mvtest_dirN\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------' "========="
	test-10-expected 
	echo "============================"
	# ???: 'rm -rf ./*\n'=$(test-10-actual)
	# ???: '$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir mvtest_dir1\n## WORK OF ALIASES\n$ mv abc ./mvtest_dir1\n$ move def ./mvtest_dir1\n$ move-force ghi ./mvtest_dir1\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ ls -l ./mvtest_dir1 | awk \'!($6="")\' | testnum | testuser\n$ linebr\nremoved \'./testdir1/.bashrc\'\nremoved directory \'./testdir1\'\n--------------------------------------------------------------------------------\nrenamed \'abc\' -> \'./mvtest_dir1/abc\'\nrenamed \'def\' -> \'./mvtest_dir1/def\'\nrenamed \'ghi\' -> \'./mvtest_dir1/ghi\'\n--------------------------------------------------------------------------------\ntotal N    \ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN mvtest_dirN\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./*

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
## CREATES TEST SUBJECTS
$ touch abc def ghi
$ mkdir mvtest_dir1
## WORK OF ALIASES
$ mv abc ./mvtest_dir1
$ move def ./mvtest_dir1
$ move-force ghi ./mvtest_dir1
$ linebr
## VIEWING THE CHANGES MADE
$ ls -l | awk '!($6="")' | testnum | testuser
$ linebr
$ ls -l ./mvtest_dir1 | awk '!($6="")' | testnum | testuser
$ linebr
removed './testdir1/.bashrc'
removed directory './testdir1'
--------------------------------------------------------------------------------
renamed 'abc' -> './mvtest_dir1/abc'
renamed 'def' -> './mvtest_dir1/def'
renamed 'ghi' -> './mvtest_dir1/ghi'
--------------------------------------------------------------------------------
total N    
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN mvtest_dirN
--------------------------------------------------------------------------------
total N    
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi
--------------------------------------------------------------------------------
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-159760/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./*\n' "=========="
	test-11-actual 
	echo "=========" $'$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir cptest_dir1\n## WORK OF ALIASES\n$ cp abc ./cptest_dir1\n$ copy def ./cptest_dir1\n$ copy-force ghi ./cptest_dir1\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ ls -l ./cptest_dir1 | awk \'!($6="")\' | testnum | testuser\n$ linebr\nremoved \'./mvtest_dir1/abc\'\nremoved \'./mvtest_dir1/ghi\'\nremoved \'./mvtest_dir1/def\'\nremoved directory \'./mvtest_dir1\'\n--------------------------------------------------------------------------------\n\'abc\' -> \'./cptest_dir1/abc\'\n\'def\' -> \'./cptest_dir1/def\'\n\'ghi\' -> \'./cptest_dir1/ghi\'\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN cptest_dirN\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------' "========="
	test-11-expected 
	echo "============================"
	# ???: 'rm -rf ./*\n'=$(test-11-actual)
	# ???: '$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir cptest_dir1\n## WORK OF ALIASES\n$ cp abc ./cptest_dir1\n$ copy def ./cptest_dir1\n$ copy-force ghi ./cptest_dir1\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ ls -l ./cptest_dir1 | awk \'!($6="")\' | testnum | testuser\n$ linebr\nremoved \'./mvtest_dir1/abc\'\nremoved \'./mvtest_dir1/ghi\'\nremoved \'./mvtest_dir1/def\'\nremoved directory \'./mvtest_dir1\'\n--------------------------------------------------------------------------------\n\'abc\' -> \'./cptest_dir1/abc\'\n\'def\' -> \'./cptest_dir1/def\'\n\'ghi\' -> \'./cptest_dir1/ghi\'\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN cptest_dirN\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./*

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
## CREATES TEST SUBJECTS
$ touch abc def ghi
$ mkdir cptest_dir1
## WORK OF ALIASES
$ cp abc ./cptest_dir1
$ copy def ./cptest_dir1
$ copy-force ghi ./cptest_dir1
$ linebr
## VIEWING THE CHANGES MADE
$ ls -l | awk '!($6="")' | testnum | testuser
$ linebr
$ ls -l ./cptest_dir1 | awk '!($6="")' | testnum | testuser
$ linebr
removed './mvtest_dir1/abc'
removed './mvtest_dir1/ghi'
removed './mvtest_dir1/def'
removed directory './mvtest_dir1'
--------------------------------------------------------------------------------
'abc' -> './cptest_dir1/abc'
'def' -> './cptest_dir1/def'
'ghi' -> './cptest_dir1/ghi'
--------------------------------------------------------------------------------
total N    
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN cptest_dirN
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi
--------------------------------------------------------------------------------
total N    
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi
--------------------------------------------------------------------------------
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-159760/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-12-actual 
	echo "=========" $'$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir TDIR1 TDIR2 TDIR3 TDIR4\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n## WORK OF ALIASES\n$ remove-dir "TDIR1"\n$ delete-dir "TDIR2"\n$ remove-dir-force TDIR3\n$ delete-dir-force TDIR4\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n--------------------------------------------------------------------------------\ntotal NN    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\n--------------------------------------------------------------------------------\nremoved directory \'TDIR1\'\nremoved directory \'TDIR2\'\nremoved directory \'TDIR3\'\nremoved directory \'TDIR4\'\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------' "========="
	test-12-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-12-actual)
	# ???: '$ linebr\n## CREATES TEST SUBJECTS\n$ touch abc def ghi\n$ mkdir TDIR1 TDIR2 TDIR3 TDIR4\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n## WORK OF ALIASES\n$ remove-dir "TDIR1"\n$ delete-dir "TDIR2"\n$ remove-dir-force TDIR3\n$ delete-dir-force TDIR4\n$ linebr\n## VIEWING THE CHANGES MADE\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n--------------------------------------------------------------------------------\ntotal NN    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN\n--------------------------------------------------------------------------------\nremoved directory \'TDIR1\'\nremoved directory \'TDIR2\'\nremoved directory \'TDIR3\'\nremoved directory \'TDIR4\'\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi\n--------------------------------------------------------------------------------'=$(test-12-expected)
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
$ linebr
## CREATES TEST SUBJECTS
$ touch abc def ghi
$ mkdir TDIR1 TDIR2 TDIR3 TDIR4
$ ls -l | awk '!($6="")' | testnum | testuser
$ linebr
## WORK OF ALIASES
$ remove-dir "TDIR1"
$ delete-dir "TDIR2"
$ remove-dir-force TDIR3
$ delete-dir-force TDIR4
$ linebr
## VIEWING THE CHANGES MADE
$ ls -l | awk '!($6="")' | testnum | testuser
$ linebr
--------------------------------------------------------------------------------
total NN    
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN TDIRN
--------------------------------------------------------------------------------
removed directory 'TDIR1'
removed directory 'TDIR2'
removed directory 'TDIR3'
removed directory 'TDIR4'
--------------------------------------------------------------------------------
total N    
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi
--------------------------------------------------------------------------------
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-159760/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'copy-readonly | testuser\n' "=========="
	test-13-actual 
	echo "=========" $'$ linebr\n# COPYING .bashrc TO TEST DIRECTORY\n$ rm -rf ./* > /dev/null\n$ mkdir testdir1\n$ linebr\n$ copy-readonly ~/.bashrc ./testdir1/ | awk \'!($6="")\' | testnum | testuser\n$ linebr\n# VIEWING THE COPIED FILE (IN DIR AND CAT)\n$ cat ./testdir1/.bashrc | head' "========="
	test-13-expected 
	echo "============================"
	# ???: 'copy-readonly | testuser\n'=$(test-13-actual)
	# ???: '$ linebr\n# COPYING .bashrc TO TEST DIRECTORY\n$ rm -rf ./* > /dev/null\n$ mkdir testdir1\n$ linebr\n$ copy-readonly ~/.bashrc ./testdir1/ | awk \'!($6="")\' | testnum | testuser\n$ linebr\n# VIEWING THE COPIED FILE (IN DIR AND CAT)\n$ cat ./testdir1/.bashrc | head'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	copy-readonly | testuser

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
# COPYING .bashrc TO TEST DIRECTORY
$ rm -rf ./* > /dev/null
$ mkdir testdir1
$ linebr
$ copy-readonly ~/.bashrc ./testdir1/ | awk '!($6="")' | testnum | testuser
$ linebr
# VIEWING THE COPIED FILE (IN DIR AND CAT)
$ cat ./testdir1/.bashrc | head
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-159760/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ ls -l  \n' "=========="
	test-14-actual 
	echo "=========" $'# | total 4\n# | drwxrwxr-x 2 xaea12 xaea12 4096 Jul  4 21:41 testdir1\n$ fix-dir-permissions\n# # AFTER fix-dir-permissions\n$ ls -l | awk \'!($6="")\' | testnum | testuser\ntotal N    \ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN testdirN' "========="
	test-14-expected 
	echo "============================"
	# ???: '# $ ls -l  \n'=$(test-14-actual)
	# ???: '# | total 4\n# | drwxrwxr-x 2 xaea12 xaea12 4096 Jul  4 21:41 testdir1\n$ fix-dir-permissions\n# # AFTER fix-dir-permissions\n$ ls -l | awk \'!($6="")\' | testnum | testuser\ntotal N    \ndrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN testdirN'=$(test-14-expected)
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
# | total 4
# | drwxrwxr-x 2 xaea12 xaea12 4096 Jul  4 21:41 testdir1
$ fix-dir-permissions
# # AFTER fix-dir-permissions
$ ls -l | awk '!($6="")' | testnum | testuser
total N    
drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN testdirN
END_EXPECTED
}
