#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test2-assert4-actual)
	expected=$(test2-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test2-assert4-expected () {
	echo -e '00'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	source _dir-aliases.bash
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
	echo -e '8'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-1210
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
	alias | wc -l
}
function test5-assert1-expected () {
	echo -e '9'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test6-assert1-actual)
	expected=$(test6-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test6-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test6-assert1-expected () {
	echo -e '2'
}

@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	alias hist='history $LINES'
	actual=$(test7-assert2-actual)
	expected=$(test7-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert2-actual () {
	hist
}
function test7-assert2-expected () {
	echo -e '2013  source _dir-aliases.bash2014  alias | wc -l2015  echo $?2016  ## NOTE: For reproducability, the directory name needs to be fixed2017  ## In place of $$, use a psuedo random number (e,g., 1210)2018  ## *** All output from one run to the next needs to be the same ***2019  ## temp_dir=$TMP/test-$$2020  temp_dir=$TMP/test-12102021  mkdir -p "$temp_dir"2022  # TODO: /bin/rm -rvf "$temp_dir"2023  cd "$temp_dir"2024  pwd2025  #ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)2026  alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"2027  echo $?2028  # Count aliases proper2029  alias | wc -l2030  echo $?2031  # Count functions2032  typeset -f | egrep \'^\\w+\' | wc -l2033  echo $?2034  ##1 SHOWS HISTORY OF BASH COMMANDS2035  alias hist=\'history $LINES\'2036  hist'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	function h { hist | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
	actual=$(test8-assert2-actual)
	expected=$(test8-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert2-actual () {
	h
}
function test8-assert2-expected () {
	echo -e '2021  mkdir -p "$temp_dir"2022  # TODO: /bin/rm -rvf "$temp_dir"2023  cd "$temp_dir"2024  pwd2025  #ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)2026  alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"2027  echo $?2028  # Count aliases proper2029  alias | wc -l2030  echo $?2031  # Count functions2032  typeset -f | egrep \'^\\w+\' | wc -l2033  echo $?2034  ##1 SHOWS HISTORY OF BASH COMMANDS2035  alias hist=\'history $LINES\'2036  hist2037  echo $?2038  ##2 SHOWS HISTORY WITHOUT TIMESTAMPS2039  # Removes timestamp from history (e.g., " 1972  [2014-05-02 14:34:12] dir *py" => " 1972  dir *py")2040  # TEST: function hist { h | perl -pe \'s/^(\\s*\\d+\\s*)(\\[[^\\]]+\\])(.*)/$1$3/;\'; }2041  # note: funciton used to simplify specification of quotes2042  # quiet-unalias h #COMMAND NOT FOUND2043  function h { hist | perl -pe \'s/^(\\s*\\d+\\s*)(\\[[^\\]]+\\])(.*)/$1$3/;\'; }2044  h'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	function asctime() { perl -e "print (scalar localtime($1));"; echo ""; }
	actual=$(test9-assert2-actual)
	expected=$(test9-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert2-actual () {
	asctime | perl -pe 's/\d/N/g; s/\w+ \w+/DDD MMM/;'
}
function test9-assert2-expected () {
	echo -e 'DDD MMM NN NN:NN:NN NNNN'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	function filter-dirnames () { perl -pe 's/\/[^ \"]+\/([^ \/\"]+)/$1/g;'; }
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
	ps | filter-dirnames
}
function test10-assert2-expected () {
	echo -e 'PID TTY          TIME CMD27306 pts/2    00:00:00 bash27335 pts/2    00:00:00 ps27336 pts/2    00:00:00 bash27337 pts/2    00:00:00 perl'
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	function comma-ize-number () { perl -pe 'while (/\d\d\d\d/) { s/(\d)(\d\d\d)([^\d])/\1,\2\3/g; } '; }
	actual=$(test11-assert2-actual)
	expected=$(test11-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert2-actual () {
	echo "99012342305324254" | comma-ize-number
}
function test11-assert2-expected () {
	echo -e '99,012,342,305,324,254'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	function apply-numeric-suffixes () {
	local just_once="$1"
	local g="g";
	if [ "$just_once" = "1" ]; then g=""; fi
	# TODO: make only sure the first number is converted if just-once applies
	# NOTE: 3 args to sprintf: coefficient, KMGT suffix, and post-context
	## DEBUG; perl -pe '$suffixes="_KMGT";  s@\b(\d{4,15})(\s)@$pow = log($1)/log(1024);  $new_num=($1/1024**$pow);  $suffix=substr($suffixes, $pow, 1);  print STDERR ("s=$suffixes p=$pow nn=$new_num l=$suffix\n"); sprintf("%.3g%s%s", $new_num, $suffix, $2)@e'"$g;"
	perl -pe '$suffixes="_KMGT";  s@\b(\d{4,15})(\s)@$pow = int(log($1)/log(1024));  $new_num=($1/1024**$pow);  $suffix=substr($suffixes, $pow, 1);  sprintf("%.3g%s%s", $new_num, $suffix, $2)@e'"$g;"
	actual=$(test12-assert9-actual)
	expected=$(test12-assert9-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert9-actual () {
	echo "8000000000" | apply-numeric-suffixes
}
function test12-assert9-expected () {
	echo -e '7.45G'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	function apply-usage-numeric-suffixes() {
	perl -pe 's@^(\d+)(?=\s)@$1 * 1024@e;' | apply-numeric-suffixes 1
	echo "8000000000" | apply-usage-numeric-suffixes #G -> T
	actual=$(test13-assert4-actual)
	expected=$(test13-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert4-actual () {
	echo "8000000" | apply-usage-numeric-suffixes #M -> G
}
function test13-assert4-expected () {
	echo -e '7.45T7.63G'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	function usage {
	## TODO: output_file=(("$1"||"usage.list"));
	output_file=$(default_assignment "$1" "usage.list")
	rename-with-file-date "$output_file";
	$NICE du --block-size=1K --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| $output_file 2>&1;
	$PAGER $output_file;
	}
	function usage-alt {
	local output_file=$TEMP/$(basename $PWD)"-usage.list";
	usage "$output_file"
	}
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	function number-columns-comma () { head -1 "$1" | perl -pe 's/,/\t/g;' | number-columns -; }
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	mkdir backup
	printf "THIS IS THE START\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE END\n" > thisisatest.txt
	ps aux > process.txt
	number-columns thisisatest.txt
	actual=$(test16-assert6-actual)
	expected=$(test16-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert6-actual () {
	number-columns-comma process.txt
}
function test16-assert6-expected () {
	echo -e '1: THIS IS THE START1: USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	alias reverse='tac'
	cat thisisatest.txt
	linebr
	actual=$(test17-assert4-actual)
	expected=$(test17-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert4-actual () {
	reverse thisisatest.txt
}
function test17-assert4-expected () {
	echo -e 'THIS IS THE STARTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS THE END--------------------------------------------------------------------------------THIS IS THE ENDTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS THE START'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	function check-errors () { (DEBUG_LEVEL=1 check_errors.perl -context=5 "$@") 2>&1 | $PAGER; }
	function check-all-errors () { (DEBUG_LEVEL=1 check_errors.perl -warnings -relaxed -context=5 "$@") 2>&1 | $PAGER; }
	alias check-warnings='echo "*** Error: use check-all-errors instead ***"; echo "    check-all-errors"'
	function check-errors-excerpt () {
	local base="$TMP/check-errors-excerpt-$$"
	local head="$base.head"
	local tail="$base.tail"
	check-errors "$@" | head >| $head;
	cat "$head"
	check-errors "$@" | tail >| $tail;
	diff "$head" "$tail" >| /dev/null
	if [ $? != 0 ]; then
	echo "\$?=$?"
	cat "$tail";
	fi
	}
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	check-errors process.txt
	check-all-errors process.txt
	linebr
	check-warnings
	linebr
	check-all-warnings
	linebr
	actual=$(test23-assert8-actual)
	expected=$(test23-assert8-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test23-assert8-actual () {
	check-errors-excerpt process.txt
}
function test23-assert8-expected () {
	echo -e 'process.txtprocess.txt--------------------------------------------------------------------------------*** Error: use check-all-errors instead ***check-all-errors--------------------------------------------------------------------------------'
}

@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	function tkdiff () { wish -f $BIN_DIR/tkdiff.tcl "$@" & }
	alias rdiff='rev_vdiff.sh'
	alias tkdiff-='tkdiff -noopt'
	function kdiff () { kdiff.sh "$@" & }
	alias vdiff='kdiff'
}


@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	diff_options="--ignore-space-change --ignore-blank-lines"
	alias diff='command diff $diff_options'
	alias diff-default='command diff'
	function diff-rev () {
	local diff_program="diff"
	if [ "$1" = "--diff-prog" ]; then
	diff_program="$2"
	shift 2
	fi
	local right_file="$1"
	local left_file="$2"
	## OLD: if [ -d "$left_file" ]; then left_file="$left_file/$right_file"; fi
	if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi
	# TODO: create helper for resolving one file relative to dir of another
	## BAD: if [ ! -e "$left_file" ]; then left_file=$(dirname "$right_file")/"$left_file"; fi
	"$diff_program" "$left_file" "$right_file"
	}
	alias kdiff-rev='diff-rev --diff-prog kdiff'
	alias diff-log-output='compare-log-output.sh'
	alias vdiff-rev=kdiff-rev
}


@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	ps -u > process1.txt
	ps -u > process2.txt
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	echo "THIS IS A NOICE SIGNATURE" > $HOME/info/.noice-signature
}


@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	function signature () {
	if [ "$1" = "" ]; then
	$LS "$HOME/info/.$1-signature"
	echo "Usage: signature dotfile-prefix"
	echo "ex: signature scrappycito"
	return;
	fi
	## TODO: echo filename and then cat??
	local filename="$HOME/info/.$1-signature"
	echo "$filename:"
	cat "$filename"
	}
	alias cell-signature='signature cell'
	alias home-signature='signature home'
	alias po-signature='signature po'
	alias tpo-signature='signature tpo'
	alias tpo-scrappycito-signature='signature tpo-scrappycito'
	alias scrappycito-signature='signature scrappycito'
	alias farm-signature='signature farm'
}


@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

	function most-recent-backup {
	if [ "$1" = "" ]; then
	echo "usage: most-recent-backup filename"
	echo "use BACKUP_DIR=dir ... to override use of ./backup"
	return
	fi
	local file="$1";
	local dir="$BACKUP_DIR"; if [ "$dir" = "" ]; then dir=./backup; fi
	## TODO: $LS -t $dir/* | $EGREP "/$file(~|.~*)" | head -1;
	$LS -t $dir/* | /bin/egrep "/$file(~|.~*)?" | head -1;
	function diff-backup-helper {
	local diff="$1"; local file="$2"; 
	"$diff" $(most-recent-backup "$file") "$file";
	}
	alias diff-backup='diff-backup-helper diff'
	alias kdiff-backup='diff-backup-helper kdiff'
}


@test "test31" {
	test_folder=$(echo /tmp/test31-$$)
	mkdir $test_folder && cd $test_folder

	dobackup.sh process1.txt
	linebr
	most-recent-backup process1.txt
	linebr
	actual=$(test31-assert5-actual)
	expected=$(test31-assert5-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test31-assert5-actual () {
	ps -u > process1.txt
}
function test31-assert5-expected () {
	echo -e "Backing up 'process1.txt' to './backup/process1.txt'--------------------------------------------------------------------------------./backup/process1.txt--------------------------------------------------------------------------------"
}

@test "test32" {
	test_folder=$(echo /tmp/test32-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test32-assert1-actual)
	expected=$(test32-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test32-assert1-actual () {
	echo "Done"
}
function test32-assert1-expected () {
	echo -e 'Done'
}
