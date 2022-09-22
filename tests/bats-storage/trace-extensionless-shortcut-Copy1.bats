#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
	shopt -s expand_aliases
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
	echo -e '0'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3573
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
	echo -e '10'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	alias perl-=""
	alias convert-termstrings='perl- convert_termstrings.perl'
	alias do-rcsdiff='do_rcsdiff.sh'
	alias dobackup='dobackup.sh'
	alias kill-em='kill_em.sh'
	alias kill-it='kill-em --pattern'
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	printf "TOP\nTHIS IS A TEST\nBOTTOM" > test.txt
	dobackup test.txt
	linebr
	actual=$(test7-assert5-actual)
	expected=$(test7-assert5-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert5-actual () {
	ls
}
function test7-assert5-expected () {
	echo -e "Backing up 'test.txt' to './backup/test.txt'--------------------------------------------------------------------------------backup\ttest.txt"
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	function ps-mine- { ps-mine "$@" | filter-dirnames; }
	alias ps-mine-all='ps-mine --all'
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	alias rename-files='perl- rename_files.perl'
	alias rename_files='rename-files'
	alias testwn='perl- testwn.perl'
	alias perlgrep='perl- perlgrep.perl'
	alias rename-spaces='rename-files -q global " " "_"'
	alias rename-quotes='rename-files -q -global "'"'"'" ""'   # where "'"'"'" is concatenated double quote, single quote, and double quote
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc.xyz def.xyz ooo.ppp
	touch 'abc nounderscore.txt' abcdef\\.txt
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	rename_files -q ooo.ppp ooo.qqq
	ls 
	rename_files -f .xyz .harry ./*
	ls
	rename-spaces -f
	ls
	rename-quotes -f 'abc nounderscore.txt'
	actual=$(test11-assert8-actual)
	expected=$(test11-assert8-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert8-actual () {
	ls
}
function test11-assert8-expected () {
	echo -e 'renaming "ooo.ppp" to "ooo.qqq"\'abcdef\\.txt\'  \'abc nounderscore.txt\'   abc.xyz   def.xyz   ooo.qqq--------------------------------------------------------------------------------renaming "./abc.xyz" to "./abc.harry"renaming "./def.xyz" to "./def.harry"\'abcdef\\.txt\'   abc.harry  \'abc nounderscore.txt\'   def.harry   ooo.qqq--------------------------------------------------------------------------------WARNING: Ignoring -quick mode as files specified\'abcdef\\.txt\'   abc.harry  \'abc nounderscore.txt\'   def.harry   ooo.qqq--------------------------------------------------------------------------------WARNING: Ignoring -quick mode as files specified\'abcdef\\.txt\'   abc.harry  \'abc nounderscore.txt\'   def.harry   ooo.qqq'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	alias rename-parens='rename-files -global -regex "[\(\)]" "" *[\(\)]*'
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	rename-parens
	linebr
	linebr
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
	ls
}
function test13-assert4-expected () {
	echo -e 'renaming "abc(1).111" to "abc1.111"renaming "abc(2).111" to "abc2.111"renaming "xyz(3).111" to "xyz3.111"renaming "xyz(4).111" to "xyz4.111"--------------------------------------------------------------------------------renaming "&*abcdefg.xyz" to "abcdefg.xyz"renaming "*abc.xyz" to "abc.xyz"--------------------------------------------------------------------------------abc1.111  abc2.111  abcdefg.xyz  abc.xyz  xyz3.111  xyz4.111'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	alias perl-grep='perl $BIN_DIR/perlgrep.perl'
	alias dir-rw='dir -rw'
	function move-versioned-files {
	local ext_pattern="$1"
	if [ "$ext_pattern" = "" ]; then ext_pattern="{list,log,txt}"; fi
	local dir="$2"
	if [ "$dir" = "" ]; then dir="versioned-files"; fi
	mkdir -p "$dir";
	## OLD: local D="[.]"
	local D="[-.]"
	# TODO: fix problem leading to hangup (verification piped to 2>&1)
	# Notes: eval needed for $ext_pattern resolution
	# - excludes read-only files (e.g., ls -l => "-r--r--r--   1 tomohara   11K Nov  2 16:30 _master-note-info.list.log")
	# EXs:              fu.log2                fu.2.log                  fu.log.14aug21    fu.14aug21.log
	local file_list="$TEMP/_move-versioned-files-$$.list"
	## TODO: dir-rw $(eval echo *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*  *$D*[0-9][0-9]*$D$ext_pattern) 2>| "$file_list.log" | perl -pe 's/(\S+\s+){6}\S+//;' >| "$file_list"
	## xargs -I "{}" $MV "{}" "$dir" < "$file_list"
	## OLD: move  $(eval dir-rw *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D$ext_pattern  2>&1 | perl-grep -v 'No such file' | perl -pe 's/(\S+\s+){6}\S+//;') "$dir"
	move  $(eval dir-rw *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D$ext_pattern  2>&1 | perl-grep -v 'No such file' | perl -pe 's/(\S+\s+){6}\S+//;' | sort -u) "$dir"
	}
	alias move-output-files='move-versioned-files "{csv,html,json,list,out,output,png,report,tsv,xml}" "output-files"'
	alias move-adhoc-files='move-log-files; move-output-files'
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	function get-free-filename() {
	local base="$1"
	local sep="$2"
	local L=1
	local filename="$base"
	## DEBUG: local -p
	while [ -e "$filename" ]; do
	let L++
	filename="$base$sep$L"
	done;
	## DEBUG: local -p
	echo "$filename"
	}
	function rename-with-file-date() {
	## DEBUG: set -o xtrace
	local f new_f
	local move_command="move"
	if [ "$1" = "--copy" ]; then
	## TODO: move_command="copy"
	move_command="command cp --interactive --verbose --preserve"
	shift
	fi
	for f in "$@"; do
	## DEBUG: echo "f=$f"
	if [ -e "$f" ]; then
	new_f=$(get-free-filename "$f".$(date --reference="$f" '+%d%b%y') ".")
	## DEBUG: echo
	eval "$move_command" "$f" "$new_f";
	fi
	done;
	## DEBUG: set - -o xtrace
	function copy-with-file-date { rename-with-file-date --copy "$@"; }
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc1.xyz abc2.xyz abc3.xyz abc4.xyz abc5.xyz.19Aug22 abc6.xyz.19Aug22
	ls
	linebr
	copy-with-file-date *.xyz 
	linebr
	actual=$(test16-assert7-actual)
	expected=$(test16-assert7-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert7-actual () {
	ls
}
function test16-assert7-expected () {
	echo -e "abc1.xyz  abc2.xyz  abc3.xyz  abc4.xyz\tabc5.xyz.19Aug22  abc6.xyz.19Aug22--------------------------------------------------------------------------------'abc1.xyz' -> 'abc1.xyz.20Sep22''abc2.xyz' -> 'abc2.xyz.20Sep22''abc3.xyz' -> 'abc3.xyz.20Sep22''abc4.xyz' -> 'abc4.xyz.20Sep22'--------------------------------------------------------------------------------abc1.xyz\t  abc2.xyz.20Sep22  abc4.xyz\t      abc6.xyz.19Aug22abc1.xyz.20Sep22  abc3.xyz\t    abc4.xyz.20Sep22abc2.xyz\t  abc3.xyz.20Sep22  abc5.xyz.19Aug22"
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	alias bigrams='perl -sw $BIN_DIR/count_bigrams.perl -N=2'
	alias unigrams='perl -sw $BIN_DIR/count_bigrams.perl -N=1'
	alias word-count=unigrams
}


@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	uname -r > catmanual.txt
	bigrams catmanual.txt
	ls
	word-count catmanual.txt
	actual=$(test18-assert6-actual)
	expected=$(test18-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test18-assert6-actual () {
	ls
}
function test18-assert6-expected () {
	echo -e 'n/a:n/a\t1catmanual.txtn/a\t1catmanual.txt'
}

@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	lynx-dump-stdout () { lynx -width=512 -dump "$@"; }
	lynx-dump () { 
	local in_file="$1"
	shift 1
	local base=$(basename "$file" .html)
	#    
	if [[ ("$out_file" = "" ) && (! "$1" =~ -*) ]]; then
	local out_file="$1"
	fi
	#
	if [ "$out_file" = "" ]; then out_file="$base.txt"; fi
	#
	lynx-dump-stdout "$@" "$file" > "$out_file" 2> "$out_file.log"
	if [ -s "$out_file.log" ]; then
	cat "$out_file.log"
	delete-force "$out_file.log"
	fi
	}
	if [ "$BAREBONES_HOST" = "1" ]; then export lynx_width=0; fi
	alias lynx-html='lynx -force_html'
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

	function setenv () { export $1="$2"; }
	alias unsetenv='unset'
	alias unexport='unset'
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	setenv MY_USERNAME aveey-temp
	echo $MY_USERNAME
	linebr
	unexport MY_USERNAME
	actual=$(test23-assert5-actual)
	expected=$(test23-assert5-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test23-assert5-actual () {
	echo $MY_USERNAME
}
function test23-assert5-expected () {
	echo -e 'aveey-temp--------------------------------------------------------------------------------'
}

@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	function show-unicode-code-info-aux() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < "$1"; }
	function show-unicode-code-info { show-unicode-code-info-aux "$@"; }
	function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr(ord($&) + 0x2400)/eg;'; }
}


@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test25-assert1-actual)
	expected=$(test25-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test25-assert1-actual () {
	show-unicode-code-info-aux ./catmanual.txt
}
function test25-assert1-expected () {
	echo -e 'char\tord\toffset\tencoding5.15.0-47-generic: 175\t0035\t0\t35.\t002E\t1\t2e1\t0031\t2\t315\t0035\t3\t35.\t002E\t4\t2e0\t0030\t5\t30-\t002D\t6\t2d4\t0034\t7\t347\t0037\t8\t37-\t002D\t9\t2dg\t0067\t10\t67e\t0065\t11\t65n\t006E\t12\t6ee\t0065\t13\t65r\t0072\t14\t72i\t0069\t15\t69c\t0063\t16\t63'
}

@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test26-assert1-actual)
	expected=$(test26-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test26-assert1-actual () {
	show-unicode-code-info ./catmanual.txt
}
function test26-assert1-expected () {
	echo -e 'char\tord\toffset\tencoding5.15.0-47-generic: 175\t0035\t0\t35.\t002E\t1\t2e1\t0031\t2\t315\t0035\t3\t35.\t002E\t4\t2e0\t0030\t5\t30-\t002D\t6\t2d4\t0034\t7\t347\t0037\t8\t37-\t002D\t9\t2dg\t0067\t10\t67e\t0065\t11\t65n\t006E\t12\t6ee\t0065\t13\t65r\t0072\t14\t72i\t0069\t15\t69c\t0063\t16\t63'
}

@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

}
