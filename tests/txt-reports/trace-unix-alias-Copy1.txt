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
	pwd
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
	echo -e '00'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	function group-members () { ypcat group | $GREP -i "$1"; }
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	function do-make () { /bin/mv -f _make.log _old_make.log; make "$@" >| _make.log 2>&1; $PAGER _make.log; }
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
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

	alias merge='echo "do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE"'
	function kdiff-merge() {
	if [ "$3" = "" ]; then
	echo "usage: $0 changed1 old changed2 output"
	return
	fi
	kdiff3 --merge --output "$4" "$1" "$2" "$3"
	}
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	printf "THIS IS THE 1ST FILE." > tf1.txt
	printf "THIS IS THE 2ND FILE." > tf2.txt
	actual=$(test8-assert3-actual)
	expected=$(test8-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert3-actual () {
	merge tf1.txt tf2.txt
}
function test8-assert3-expected () {
	echo -e 'do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE tf1.txt tf2.txt'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	function basename-with-dir {
	local file="$1"
	local suffix="$2"
	echo $(dirname "$file")/$(basename "$file" "$suffix");
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	alias linux-version="cat /etc/os-release"
	alias os-release=linux-version
}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test13-assert1-actual)
	expected=$(test13-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert1-actual () {
	os-release
}
function test13-assert1-expected () {
	echo -e 'PRETTY_NAME="Ubuntu 22.04.1 LTS"NAME="Ubuntu"VERSION_ID="22.04"VERSION="22.04.1 LTS (Jammy Jellyfish)"VERSION_CODENAME=jammyID=ubuntuID_LIKE=debianHOME_URL="https://www.ubuntu.com/"SUPPORT_URL="https://help.ubuntu.com/"BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"UBUNTU_CODENAME=jammyPRETTY_NAME="Ubuntu 22.04.1 LTS"NAME="Ubuntu"VERSION_ID="22.04"VERSION="22.04.1 LTS (Jammy Jellyfish)"VERSION_CODENAME=jammyID=ubuntuID_LIKE=debianHOME_URL="https://www.ubuntu.com/"SUPPORT_URL="https://help.ubuntu.com/"BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"UBUNTU_CODENAME=jammy'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	function split-tokens () { perl -pe "s/\s+/\n/g;" "$@"; }
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test15-assert1-actual)
	expected=$(test15-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert1-actual () {
	tokenize _old_make.log
}
function test15-assert1-expected () {
	echo -e "make:Nothingtobedonefor'himom.txt'."
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	PERL_PRINT="This is Ubuntu!"
	perl-echo $PERL_PRINT
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
	perl-echo-sans-newline $PERL_PRINT
}
function test17-assert3-expected () {
	echo -e 'ThisThis'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	function quote-tokens () { echo "$@" | perl -pe 's/(\S+)/"\1"/g;'; }
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	perl-printf "ONE KISS IS ALL IT TAKES\n"
	perl-print "2\n3\n5\n7\n11"
	perl-print-n "A B C D E F G\n"
	actual=$(test19-assert4-actual)
	expected=$(test19-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test19-assert4-actual () {
	quote-tokens "HELP ME!"
}
function test19-assert4-expected () {
	echo -e 'ONE KISS IS ALL IT TAKES235711A B C D E F G"HELP" "ME!"'
}

@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	if [ "$OSTYPE" != "cygwin" ]; then alias ipconfig=ifconfig; fi
	alias set-display-local='export DISPLAY=localhost:0.0'
	set-display-local
	actual=$(test20-assert4-actual)
	expected=$(test20-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test20-assert4-actual () {
	echo $DISPLAY
}
function test20-assert4-expected () {
	echo -e 'localhost:0.0'
}

@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

	alias bash-trace-on='set -o xtrace'
	function trace-cmd() {
	(
	echo "start: $(date)";
	bash-trace-on; 
	eval "$@"; 
	bash-trace-off;
	echo "end: $(date)";
	) 2>&1 | $PAGER;
	alias cmd-trace='trace-cmd'
}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	bash-trace-off
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	function cmd-usage () {
	local command="$@"
	local usage_file="_$(echo "$command" | tr ' ' '_')-usage.list"
	$command --help  2>&1 | ansifilter > "$usage_file"
	$PAGER_NOEXIT "$usage_file"
}


@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	function compress-dir() {
	log_file=$TEMP/compress_$(basename "$1").log;
	find "$1" \( -not -type l \) -exec gzip -vf {} \; >| "$log_file" 2>&1; 
	$PAGER "$log_file";
	function uncompress-dir() {
	log_file=$TEMP/uncompress_$(basename "$1").log;
	find "$1" \( -not -type l \) \( -not -name \*.tar.gz \) -exec gunzip -vf {} \; >| "$log_file" 2>&1; $PAGER "$log_file";
	}
	alias compress-this-dir='compress-dir $PWD'
	alias ununcompress-this-dir='uncompress-dir $PWD'
}


@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	alias old-count-exts='$LS | count-it "\.[^.]*\w" | sort $SORT_COL2 -rn | $PAGER'
	function count-exts () { $LS | count-it '\.[^.]+$' | sort $SORT_COL2 -rn | $PAGER; }
	alias kill-iceweasel='kill_em.sh iceweasel'
}


@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	function cmd-usage () {
	local command="$@"
	local usage_file="_$(echo "$command" | tr ' ' '_')-usage.list"
	$command --help  2>&1 | ansifilter > "$usage_file"
	$PAGER_NOEXIT "$usage_file"
	}
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test27-assert1-actual)
	expected=$(test27-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test27-assert1-actual () {
	echo "Done!"
}
function test27-assert1-expected () {
	echo -e 'Done!'
}
