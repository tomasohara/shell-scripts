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

	alias testnum="sed -r "s/[0-9]/X/g"" 
	alias testuser="sed -r "s/"$USER"+/user/g""
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
	echo -e 'XXX'
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
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME XXXX XX.X XX.X XXXXXXX XXXXXX   XX:XX X:XX XXXX XX.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX '
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
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME XXXX XX.X XX.X XXXXXXX XXXXXX   XX:XX X:XX XXXX XX.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX XXXX X.X X.X XXXXXX XXXXX   XX:XX X:XX '
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
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME XXXX XX.X XX.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX XX.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX '
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
	echo -e 'PID %CPU %MEM VSZ RSS   START TIME XXXX XX.X XX.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX XX.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX XXXX X.X X.X XXXXXXXX XXXXXX   XX:XX X:XX '
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
	echo -e 'UID PID PPID PRI NI VSZ RSS WCHAN STAT TTY TIME COMMANDXXXX XXXX XXXX XX X XXXXX XXXX do_wai Ss pts/X X:XX /usr/biXXXX XXXX XXXX XX X XXXXX XXXX - R+ pts/X X:XX ps alXXXX XXXX XXXX XX X XXXXX XXXX pipe_r S+ pts/X X:XX grep -EXXXX XXXX XXXX XX X XXXXX XXXX pipe_r S+ pts/X X:XX head -nXXXX XXXX XXXX XX X XXXXX XXXX pipe_r S+ pts/X X:XX sed -rXXXX XXXX XXXX XX X XXXXX XXXX pipe_r S+ pts/X X:XX awk !($--------------------------------------------------------------------------------XXXX'
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
