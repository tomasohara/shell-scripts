#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

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

	TMP=/tmp/test-unix-alias
	BIN_DIR=$PWD/..
	alias | wc -l
	temp_dir=$TMP/test-2899
	mkdir -p "$temp_dir"
	cd "$temp_dir"
	actual=$(test2-assert7-actual)
	expected=$(test2-assert7-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert7-actual () {
	alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
}
function test2-assert7-expected () {
	echo -e '0/tmp/test-unix-alias/test-2899'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test3-assert1-actual)
	expected=$(test3-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test3-assert1-expected () {
	echo -e '10'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	alias testnum="sed -r "s/[0-9]/N/g"" 
	alias testuser="sed -r "s/"$USER"+/userxf333/g"" 
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	mkdir testfolder
	echo "Hi Mom!" > himom.txt
	echo "Hi Dad!" > hidad.txt
	do-make "himom.txt"
	cat _make.log
	do-make "hidad.txt"
	cat _make.log
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	printf "THIS IS THE 1ST FILE." > tf1.txt
	printf "THIS IS THE 2ND FILE." > tf2.txt
	actual=$(test7-assert3-actual)
	expected=$(test7-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert3-actual () {
	merge tf1.txt tf2.txt
}
function test7-assert3-expected () {
	echo -e 'do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE tf1.txt tf2.txt'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

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
	gtime -V | testnum
}
function test9-assert1-expected () {
	echo -e 'time (GNU Time) UNKNOWNCopyright (C) NNNN Free Software Foundation, Inc.License GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.This is free software: you are free to change and redistribute it.There is NO WARRANTY, to the extent permitted by law.'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

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
	system-status | testnum | testuser | tail -n +2 | awk '!($8="")'
}
function test11-assert1-expected () {
	echo -e 'total used free shared buff/cache available  Mem: NNNNNNN NNNNNNN NNNNNN NNNNNN NNNNNN NNNNNN Swap: NNNNNNN NNNNNNN NNNNNNN    NN:NN:NN up N:NN, N user, load average:  N.NN, N.NNUSER TTY FROM LOGIN@ IDLE JCPU PCPU userxf333 ttyN :N NN:NN N:NNm NN:NN N.NNs '
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
	apropos-command time | grep asctime | wc -l | testnum
}
function test12-assert1-expected () {
	echo -e 'N'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	cat hidad.txt
	linebr
	actual=$(test13-assert3-actual)
	expected=$(test13-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert3-actual () {
	split-tokens hidad.txt
}
function test13-assert3-expected () {
	echo -e 'Hi Dad!--------------------------------------------------------------------------------HiDad!'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test14-assert1-actual)
	expected=$(test14-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert1-actual () {
	tokenize _old_make.log
}
function test14-assert1-expected () {
	echo -e "make:Nothingtobedonefor'himom.txt'."
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	PERL_PRINT='This is Ubuntu!'
	perl-echo $PERL_PRINT
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
	perl-echo-sans-newline $PERL_PRINT
}
function test15-assert3-expected () {
	echo -e 'ThisThis'
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	perl-printf 'ONE KISS IS ALL IT TAKES\n'
	perl-print '2\n3\n5\n7\n11'
	perl-print-n 'A B C D E F G\n'
	actual=$(test16-assert4-actual)
	expected=$(test16-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert4-actual () {
	quote-tokens 'HELP ME!'
}
function test16-assert4-expected () {
	echo -e 'ONE KISS IS ALL IT TAKES235711A B C D E F G"HELP" "ME!"'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	set-display-local
	actual=$(test17-assert2-actual)
	expected=$(test17-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert2-actual () {
	echo $DISPLAY | testnum
}
function test17-assert2-expected () {
	echo -e 'localhost:N.N'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	bash-trace-on | testuser | testnum
	bash-trace-off | testuser | testnum
	linebr
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	ls
	cp tf2.txt testfolder/
	linebr
	compress-this-dir ./testfolder | testnum
	linebr
	ls
	linebr
	actual=$(test19-assert8-actual)
	expected=$(test19-assert8-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test19-assert8-actual () {
	ununcompress-this-dir ./testfolder | testnum
}
function test19-assert8-expected () {
	echo -e "hidad.txt  _make.log\t  testfolder  tf2.txthimom.txt  _old_make.log  tf1.txt     tf3.txt'tf2.txt' -> 'testfolder/tf2.txt'--------------------------------------------------------------------------------gzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored/tmp/test-unix-alias/test-NNNN/hidad.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt.gz/tmp/test-unix-alias/test-NNNN/himom.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt.gz/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gzgzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz/tmp/test-unix-alias/test-NNNN/_old_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log.gz/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz/tmp/test-unix-alias/test-NNNN/_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log.gz--------------------------------------------------------------------------------hidad.txt.gz  _make.log.gz\ttestfolder  tf2.txt.gzhimom.txt.gz  _old_make.log.gz\ttf1.txt.gz  tf3.txt.gz--------------------------------------------------------------------------------gzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored/tmp/test-unix-alias/test-NNNN/_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt/tmp/test-unix-alias/test-NNNN/_old_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log/tmp/test-unix-alias/test-NNNN/himom.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt/tmp/test-unix-alias/test-NNNN/hidad.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txtgzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt"
}

@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	old-count-exts | testnum
	linebr
}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test21-assert1-actual)
	expected=$(test21-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test21-assert1-actual () {
	echo "Done!"
}
function test21-assert1-expected () {
	echo -e 'Done!'
}
