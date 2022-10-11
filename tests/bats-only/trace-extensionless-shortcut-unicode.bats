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
	TMP=/tmp/test-extensionless
	actual=$(test1-assert5-actual)
	expected=$(test1-assert5-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert5-actual () {
	BIN_DIR=$PWD/..
}
function test1-assert5-expected () {
	echo -e '00'
}

@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test2-assert1-actual)
	expected=$(test2-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert1-actual () {
	alias | wc -l
}
function test2-assert1-expected () {
	echo -e '0'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3570
	mkdir -p "$temp_dir"
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

	pwd
	rm -rf ./*
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	function show-unicode-code-info-aux() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < "$1"; }
	function show-unicode-code-info { show-unicode-code-info-aux "$@"; }
	function show-unicode-code-info-stdin() { in_file="$TEMP/show-unicode-code-info.$$"; cat >| $in_file;  show-unicode-code-info-aux $in_file; }
	function output-BOM { perl -e 'print "\xEF\xBB\xBF\n";'; }
	function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr(ord($&) + 0x2400)/eg;'; }
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
	show-unicode-code-info-aux ./version1.txt
}
function test7-assert1-expected () {
	echo -e 'char\tord\toffset\tencoding5.15.0-48-generic: 175\t0035\t0\t35.\t002E\t1\t2e1\t0031\t2\t315\t0035\t3\t35.\t002E\t4\t2e0\t0030\t5\t30-\t002D\t6\t2d4\t0034\t7\t348\t0038\t8\t38-\t002D\t9\t2dg\t0067\t10\t67e\t0065\t11\t65n\t006E\t12\t6ee\t0065\t13\t65r\t0072\t14\t72i\t0069\t15\t69c\t0063\t16\t63'
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
	show-unicode-code-info ./version1.txt
}
function test8-assert1-expected () {
	echo -e 'char\tord\toffset\tencoding5.15.0-48-generic: 175\t0035\t0\t35.\t002E\t1\t2e1\t0031\t2\t315\t0035\t3\t35.\t002E\t4\t2e0\t0030\t5\t30-\t002D\t6\t2d4\t0034\t7\t348\t0038\t8\t38-\t002D\t9\t2dg\t0067\t10\t67e\t0065\t11\t65n\t006E\t12\t6ee\t0065\t13\t65r\t0072\t14\t72i\t0069\t15\t69c\t0063\t16\t63'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

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
	echo "END"
}
function test10-assert1-expected () {
	echo -e 'END'
}
