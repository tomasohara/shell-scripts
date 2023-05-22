#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	echo $PS1
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	TMP=/tmp/test-extensionless
	BIN_DIR=$PWD/..
}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	alias | wc -l
}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	alias testuser="sed -r "s/"$USER"+/user/g""
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3570
	mkdir -p "$temp_dir"
	cd "$temp_dir"
	alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	typeset -f | egrep '^\w+' | wc -l
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	alias testnum="sed -r "s/[0-9]/N/g"" 
	alias testuser="sed -r "s/"$USER"+/userxf333/g""
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	kill-em --test firefox | wc -l
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	kill-it --test firefox | wc -l
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	printf "TOP\nTHIS IS A TEST\nBOTTOM" > test.txt
	printf "THIS IS A FILE TO MOVE" > tomove.txt
	mkdir newdir1
	move tomove.txt ./newdir1/
	ls
	dobackup test.txt
	linebr
	ls
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	ps-mine-all | wc -l | testnum 
}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	do-rcsdiff
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	uname -r > versionR.txt
	uname -a > versionA.txta
	uname -v > versionV.txt
	uname -i > versionI.txt
	uname > "version none.txt"
	uname -ra > "version?.txt"
	man grep > grep_manual.txt
	cp ./versionR.txt ./versionR-1.txt
	ls
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	rename-files -q test.txt harry.txt
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	perlgrep "print" ./grep_manual.txt
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	foreach "echo $f" *.txt
}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	rename-spaces
}


@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	rename-special-punct
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	ps -l >> "process(L).md"
	ps -u >> "process(U).md"
	ps -x >> "process(X).md"
	ps -al >> "process'all'.md"
	ps -aux >> 'psaux(1).txt'
	ps -aux >> 'psaux(2).txt'
	ps -aux >> 'psaux(3).txt'
}


@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	move-duplicates
}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

	rename-parens -v
}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	rename-quotes -v
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	ls
}


@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	man sudo > sudo_manual.out
	man ansifilter > fakelog.log
	ps -aux > process_all.html
}


@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	copy-with-file-date *.md | wc -l
}


@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	man cat > man_cat.txt
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	unigrams ./man_cat.txt | testuser | testnum
}


@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	word-count ./man_cat.txt | testuser | testnum
}


@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

	bigrams ./man_cat.txt | testuser | testnum
}


@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

	lynx-dump-stdout | head
}


@test "test31" {
	test_folder=$(echo /tmp/test31-$$)
	mkdir $test_folder && cd $test_folder

	setenv MY_USERNAME xaea12-temp
	echo $MY_USERNAME
}


@test "test32" {
	test_folder=$(echo /tmp/test32-$$)
	mkdir $test_folder && cd $test_folder

	unexport MY_USERNAME
	echo $MY_USERNAME
}


@test "test33" {
	test_folder=$(echo /tmp/test33-$$)
	mkdir $test_folder && cd $test_folder

	echo "END"
}
