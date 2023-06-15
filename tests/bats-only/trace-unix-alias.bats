#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-203637/test-1"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-203637/test-3"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-203637/test-4"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-unix-alias\n' "=========="
	test-4-actual 
	echo "=========" $'$ BIN_DIR=$PWD/..\n$ alias | wc -l\n$ temp_dir=$TMP/test-2899\n$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n0\n/tmp/test-unix-alias/test-2899' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-unix-alias\n'=$(test-4-actual)
	# ???: '$ BIN_DIR=$PWD/..\n$ alias | wc -l\n$ temp_dir=$TMP/test-2899\n$ mkdir -p "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n0\n/tmp/test-unix-alias/test-2899'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-unix-alias

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ BIN_DIR=$PWD/..
$ alias | wc -l
$ temp_dir=$TMP/test-2899
$ mkdir -p "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
0
/tmp/test-unix-alias/test-2899
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-203637/test-5"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-5-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0" "========="
	test-5-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-5-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0"=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
1
0
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-203637/test-6"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/N/g"" \n' "=========="
	test-6-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/N/g"" \n'=$(test-6-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/N/g"" 

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-203637/test-7"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-7-actual 
	echo "=========" $'' "========="
	test-7-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-7-actual)
	# ???: ''=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-203637/test-8"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ group-members\n' "=========="
	test-8-actual 
	echo "=========" $"# | ypcat: can't get local yp domain: Local domain name not set" "========="
	test-8-expected 
	echo "============================"
	# ???: '# $ group-members\n'=$(test-8-actual)
	# ???: "# | ypcat: can't get local yp domain: Local domain name not set"=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true


}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | ypcat: can't get local yp domain: Local domain name not set
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-203637/test-9"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-9-actual 
	echo "=========" $'$ mkdir testfolder\n$ echo "Hi Mom!" > himom.txt\n$ echo "Hi Dad!" > hidad.txt\n$ do-make "himom.txt"\n$ cat _make.log\n$ do-make "hidad.txt"\n$ cat _make.log\n$ ls -l | awk \'!($6="")\' | testuser | testnum\n/bin/mv: cannot stat \'_make.log\': No such file or directory\n\x1b[?1h\x1b=' "========="
	test-9-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-9-actual)
	# ???: '$ mkdir testfolder\n$ echo "Hi Mom!" > himom.txt\n$ echo "Hi Dad!" > hidad.txt\n$ do-make "himom.txt"\n$ cat _make.log\n$ do-make "hidad.txt"\n$ cat _make.log\n$ ls -l | awk \'!($6="")\' | testuser | testnum\n/bin/mv: cannot stat \'_make.log\': No such file or directory\n\x1b[?1h\x1b='=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir testfolder
$ echo "Hi Mom!" > himom.txt
$ echo "Hi Dad!" > hidad.txt
$ do-make "himom.txt"
$ cat _make.log
$ do-make "hidad.txt"
$ cat _make.log
$ ls -l | awk '!($6="")' | testuser | testnum
/bin/mv: cannot stat '_make.log': No such file or directory
[?1h=
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-203637/test-10"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "THIS IS THE 1ST FILE." > tf1.txt\n' "=========="
	test-10-actual 
	echo "=========" $'$ printf "THIS IS THE 2ND FILE." > tf2.txt\n$ printf "THIS IS THE 3RD FILE." > tf3.txt\n# MESSAGE SHOWN IF MERGE IS USED\n$ merge tf1.txt tf2.txt\ndo-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE tf1.txt tf2.txt' "========="
	test-10-expected 
	echo "============================"
	# ???: 'printf "THIS IS THE 1ST FILE." > tf1.txt\n'=$(test-10-actual)
	# ???: '$ printf "THIS IS THE 2ND FILE." > tf2.txt\n$ printf "THIS IS THE 3RD FILE." > tf3.txt\n# MESSAGE SHOWN IF MERGE IS USED\n$ merge tf1.txt tf2.txt\ndo-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE tf1.txt tf2.txt'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	printf "THIS IS THE 1ST FILE." > tf1.txt

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "THIS IS THE 2ND FILE." > tf2.txt
$ printf "THIS IS THE 3RD FILE." > tf3.txt
# MESSAGE SHOWN IF MERGE IS USED
$ merge tf1.txt tf2.txt
do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE tf1.txt tf2.txt
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-203637/test-11"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ do-merge tf1.txt tf2.txt tf3.txt\n' "=========="
	test-11-actual 
	echo "=========" $'# | <<<<<<< tf1.txt\n# | THIS IS THE 1ST FILE.=======\n# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt\n# | merge: warning: conflicts during merge' "========="
	test-11-expected 
	echo "============================"
	# ???: '# $ do-merge tf1.txt tf2.txt tf3.txt\n'=$(test-11-actual)
	# ???: '# | <<<<<<< tf1.txt\n# | THIS IS THE 1ST FILE.=======\n# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt\n# | merge: warning: conflicts during merge'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true


}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | <<<<<<< tf1.txt
# | THIS IS THE 1ST FILE.=======
# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt
# | merge: warning: conflicts during merge
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-203637/test-12"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ diff3-merge tf1.txt tf2.txt tf3.txt -A\n' "=========="
	test-12-actual 
	echo "=========" $'# | <<<<<<< tf1.txt\n# | THIS IS THE 1ST FILE.||||||| tf2.txt\n# | THIS IS THE 2ND FILE.=======\n# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt' "========="
	test-12-expected 
	echo "============================"
	# ???: '# $ diff3-merge tf1.txt tf2.txt tf3.txt -A\n'=$(test-12-actual)
	# ???: '# | <<<<<<< tf1.txt\n# | THIS IS THE 1ST FILE.||||||| tf2.txt\n# | THIS IS THE 2ND FILE.=======\n# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true


}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | <<<<<<< tf1.txt
# | THIS IS THE 1ST FILE.||||||| tf2.txt
# | THIS IS THE 2ND FILE.=======
# | THIS IS THE 3RD FILE.>>>>>>> tf3.txt
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-203637/test-13"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'which python\n' "=========="
	test-13-actual 
	echo "=========" $'# 3A) full-dirname RETURNS THE FULL PATH OF THE FILE\n$ full-dirname himom.txt | testuser\n# 3B) base-name-with-dir RETURNS THE BASENAME INCLUDING dir\n$ basename-with-dir himom.txt\n/usr/bin/python\n/tmp/test-unix-alias/test-2899/himom.txt\n./himom.txt' "========="
	test-13-expected 
	echo "============================"
	# ???: 'which python\n'=$(test-13-actual)
	# ???: '# 3A) full-dirname RETURNS THE FULL PATH OF THE FILE\n$ full-dirname himom.txt | testuser\n# 3B) base-name-with-dir RETURNS THE BASENAME INCLUDING dir\n$ basename-with-dir himom.txt\n/usr/bin/python\n/tmp/test-unix-alias/test-2899/himom.txt\n./himom.txt'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	which python

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# 3A) full-dirname RETURNS THE FULL PATH OF THE FILE
$ full-dirname himom.txt | testuser
# 3B) base-name-with-dir RETURNS THE BASENAME INCLUDING dir
$ basename-with-dir himom.txt
/usr/bin/python
/tmp/test-unix-alias/test-2899/himom.txt
./himom.txt
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-203637/test-14"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ gtime\n' "=========="
	test-14-actual 
	echo "=========" $"# | /usr/bin/time: missing program to run\n# | Try '/usr/bin/time --help' for more information\n$ gtime -V | testnum\ntime (GNU Time) UNKNOWN\nCopyright (C) NNNN Free Software Foundation, Inc.\nLicense GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law." "========="
	test-14-expected 
	echo "============================"
	# ???: '# $ gtime\n'=$(test-14-actual)
	# ???: "# | /usr/bin/time: missing program to run\n# | Try '/usr/bin/time --help' for more information\n$ gtime -V | testnum\ntime (GNU Time) UNKNOWN\nCopyright (C) NNNN Free Software Foundation, Inc.\nLicense GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.\nThis is free software: you are free to change and redistribute it.\nThere is NO WARRANTY, to the extent permitted by law."=$(test-14-expected)
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
# | /usr/bin/time: missing program to run
# | Try '/usr/bin/time --help' for more information
$ gtime -V | testnum
time (GNU Time) UNKNOWN
Copyright (C) NNNN Free Software Foundation, Inc.
License GPLvN+: GNU GPL version N or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-203637/test-15"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'linux-version | grep VERSION_ID | testnum\n' "=========="
	test-15-actual 
	echo "=========" $'# os-release ALSO WORKS SAME AS linux-version\nVERSION_ID="NN.NN"' "========="
	test-15-expected 
	echo "============================"
	# ???: 'linux-version | grep VERSION_ID | testnum\n'=$(test-15-actual)
	# ???: '# os-release ALSO WORKS SAME AS linux-version\nVERSION_ID="NN.NN"'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	linux-version | grep VERSION_ID | testnum

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# os-release ALSO WORKS SAME AS linux-version
VERSION_ID="NN.NN"
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-203637/test-16"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'system-status | testnum | testuser | tail -n +2 | awk \'!($8="")\'\n' "=========="
	test-16-actual 
	echo "=========" $'total used free shared buff/cache available  \nMem: NNNNNNN NNNNNNN NNNNNN NNNNNN NNNNNN NNNNNN \nSwap: NNNNNNN NNNNNNN NNNNNNN    \nNN:NN:NN up N:NN, N user, load average:  N.NN, N.NN\nUSER TTY FROM LOGIN@ IDLE JCPU PCPU \nuserxf333 ttyN :N NN:NN N:NNm NN:NN N.NNs' "========="
	test-16-expected 
	echo "============================"
	# ???: 'system-status | testnum | testuser | tail -n +2 | awk \'!($8="")\'\n'=$(test-16-actual)
	# ???: 'total used free shared buff/cache available  \nMem: NNNNNNN NNNNNNN NNNNNN NNNNNN NNNNNN NNNNNN \nSwap: NNNNNNN NNNNNNN NNNNNNN    \nNN:NN:NN up N:NN, N user, load average:  N.NN, N.NN\nUSER TTY FROM LOGIN@ IDLE JCPU PCPU \nuserxf333 ttyN :N NN:NN N:NNm NN:NN N.NNs'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	system-status | testnum | testuser | tail -n +2 | awk '!($8="")'

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
total used free shared buff/cache available  
Mem: NNNNNNN NNNNNNN NNNNNN NNNNNN NNNNNN NNNNNN 
Swap: NNNNNNN NNNNNNN NNNNNNN    
NN:NN:NN up N:NN, N user, load average:  N.NN, N.NN
USER TTY FROM LOGIN@ IDLE JCPU PCPU 
userxf333 ttyN :N NN:NN N:NNm NN:NN N.NNs
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-203637/test-17"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'apropos-command time | grep asctime | wc -l | testnum\n' "=========="
	test-17-actual 
	echo "=========" $'N' "========="
	test-17-expected 
	echo "============================"
	# ???: 'apropos-command time | grep asctime | wc -l | testnum\n'=$(test-17-actual)
	# ???: 'N'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	apropos-command time | grep asctime | wc -l | testnum

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
N
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-203637/test-18"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat hidad.txt\n' "=========="
	test-18-actual 
	echo "=========" $'$ linebr\n$ split-tokens hidad.txt\nHi Dad!\n--------------------------------------------------------------------------------\nHi\nDad!' "========="
	test-18-expected 
	echo "============================"
	# ???: 'cat hidad.txt\n'=$(test-18-actual)
	# ???: '$ linebr\n$ split-tokens hidad.txt\nHi Dad!\n--------------------------------------------------------------------------------\nHi\nDad!'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	cat hidad.txt

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ split-tokens hidad.txt
Hi Dad!
--------------------------------------------------------------------------------
Hi
Dad!
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-203637/test-19"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'tokenize _old_make.log\n' "=========="
	test-19-actual 
	echo "=========" $"make:\nNothing\nto\nbe\ndone\nfor\n'himom.txt'." "========="
	test-19-expected 
	echo "============================"
	# ???: 'tokenize _old_make.log\n'=$(test-19-actual)
	# ???: "make:\nNothing\nto\nbe\ndone\nfor\n'himom.txt'."=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	tokenize _old_make.log

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
make:
Nothing
to
be
done
for
'himom.txt'.
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-203637/test-20"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"PERL_PRINT='This is Ubuntu!'\n" "=========="
	test-20-actual 
	echo "=========" $'$ perl-echo $PERL_PRINT\n$ perl-echo-sans-newline $PERL_PRINT\nThis\nThis' "========="
	test-20-expected 
	echo "============================"
	# ???: "PERL_PRINT='This is Ubuntu!'\n"=$(test-20-actual)
	# ???: '$ perl-echo $PERL_PRINT\n$ perl-echo-sans-newline $PERL_PRINT\nThis\nThis'=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	PERL_PRINT='This is Ubuntu!'

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ perl-echo $PERL_PRINT
$ perl-echo-sans-newline $PERL_PRINT
This
This
END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-203637/test-21"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"perl-printf 'ONE KISS IS ALL IT TAKES\\n'\n" "=========="
	test-21-actual 
	echo "=========" $'$ perl-print \'2\\n3\\n5\\n7\\n11\'\n$ perl-print-n \'A B C D E F G\\n\'\n$ quote-tokens \'HELP ME!\'\nONE KISS IS ALL IT TAKES\n2\n3\n5\n7\n11\nA B C D E F G\n"HELP" "ME!"' "========="
	test-21-expected 
	echo "============================"
	# ???: "perl-printf 'ONE KISS IS ALL IT TAKES\\n'\n"=$(test-21-actual)
	# ???: '$ perl-print \'2\\n3\\n5\\n7\\n11\'\n$ perl-print-n \'A B C D E F G\\n\'\n$ quote-tokens \'HELP ME!\'\nONE KISS IS ALL IT TAKES\n2\n3\n5\n7\n11\nA B C D E F G\n"HELP" "ME!"'=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	perl-printf 'ONE KISS IS ALL IT TAKES\n'

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ perl-print '2\n3\n5\n7\n11'
$ perl-print-n 'A B C D E F G\n'
$ quote-tokens 'HELP ME!'
ONE KISS IS ALL IT TAKES
2
3
5
7
11
A B C D E F G
"HELP" "ME!"
END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-203637/test-22"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'set-display-local\n' "=========="
	test-22-actual 
	echo "=========" $'$ echo $DISPLAY | testnum\nlocalhost:N.N' "========="
	test-22-expected 
	echo "============================"
	# ???: 'set-display-local\n'=$(test-22-actual)
	# ???: '$ echo $DISPLAY | testnum\nlocalhost:N.N'=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true

	set-display-local

}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo $DISPLAY | testnum
localhost:N.N
END_EXPECTED
}


@test "test-23" {
	testfolder="/tmp/batspp-203637/test-23"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'bash-trace-on | testuser | testnum\n' "=========="
	test-23-actual 
	echo "=========" $'$ linebr\n## trace-cmd TRACES COMMANDS AND STATS (TIME) OF THE USER\n$ trace-cmd | testuser | testnum\n## bash-trace-on DISABLES bash tracing\n$ bash-trace-off | testuser | testnum\n$ linebr\n$ trace-cmd | testuser | testnum\n--------------------------------------------------------------------------------\nstart: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n+ eval\n+ set - -o xtrace\nend: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n--------------------------------------------------------------------------------\nstart: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n+ eval\n+ set - -o xtrace\nend: Thu Dec  N NN:NN:NN PM +NNNN NNNN' "========="
	test-23-expected 
	echo "============================"
	# ???: 'bash-trace-on | testuser | testnum\n'=$(test-23-actual)
	# ???: '$ linebr\n## trace-cmd TRACES COMMANDS AND STATS (TIME) OF THE USER\n$ trace-cmd | testuser | testnum\n## bash-trace-on DISABLES bash tracing\n$ bash-trace-off | testuser | testnum\n$ linebr\n$ trace-cmd | testuser | testnum\n--------------------------------------------------------------------------------\nstart: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n+ eval\n+ set - -o xtrace\nend: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n--------------------------------------------------------------------------------\nstart: Thu Dec  N NN:NN:NN PM +NNNN NNNN\n+ eval\n+ set - -o xtrace\nend: Thu Dec  N NN:NN:NN PM +NNNN NNNN'=$(test-23-expected)
	[ "$(test-23-actual)" == "$(test-23-expected)" ]
}

function test-23-actual () {
	# no-op in case content just a comment
	true

	bash-trace-on | testuser | testnum

}

function test-23-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
## trace-cmd TRACES COMMANDS AND STATS (TIME) OF THE USER
$ trace-cmd | testuser | testnum
## bash-trace-on DISABLES bash tracing
$ bash-trace-off | testuser | testnum
$ linebr
$ trace-cmd | testuser | testnum
--------------------------------------------------------------------------------
start: Thu Dec  N NN:NN:NN PM +NNNN NNNN
+ eval
+ set - -o xtrace
end: Thu Dec  N NN:NN:NN PM +NNNN NNNN
--------------------------------------------------------------------------------
start: Thu Dec  N NN:NN:NN PM +NNNN NNNN
+ eval
+ set - -o xtrace
end: Thu Dec  N NN:NN:NN PM +NNNN NNNN
END_EXPECTED
}


@test "test-24" {
	testfolder="/tmp/batspp-203637/test-24"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ls\n' "=========="
	test-24-actual 
	echo "=========" $"$ cp tf2.txt testfolder/\n$ linebr\n$ compress-this-dir ./testfolder | testnum\n$ linebr\n$ ls\n$ linebr\n$ ununcompress-this-dir ./testfolder | testnum\nhidad.txt  _make.log\t  testfolder  tf2.txt\nhimom.txt  _old_make.log  tf1.txt     tf3.txt\n'tf2.txt' -> 'testfolder/tf2.txt'\n--------------------------------------------------------------------------------\ngzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/hidad.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt.gz\n/tmp/test-unix-alias/test-NNNN/himom.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\ngzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/_old_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log.gz\n--------------------------------------------------------------------------------\nhidad.txt.gz  _make.log.gz\ttestfolder  tf2.txt.gz\nhimom.txt.gz  _old_make.log.gz\ttf1.txt.gz  tf3.txt.gz\n--------------------------------------------------------------------------------\ngzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt\n/tmp/test-unix-alias/test-NNNN/_old_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log\n/tmp/test-unix-alias/test-NNNN/himom.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt\n/tmp/test-unix-alias/test-NNNN/hidad.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt\ngzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt" "========="
	test-24-expected 
	echo "============================"
	# ???: 'ls\n'=$(test-24-actual)
	# ???: "$ cp tf2.txt testfolder/\n$ linebr\n$ compress-this-dir ./testfolder | testnum\n$ linebr\n$ ls\n$ linebr\n$ ununcompress-this-dir ./testfolder | testnum\nhidad.txt  _make.log\t  testfolder  tf2.txt\nhimom.txt  _old_make.log  tf1.txt     tf3.txt\n'tf2.txt' -> 'testfolder/tf2.txt'\n--------------------------------------------------------------------------------\ngzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/hidad.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt.gz\n/tmp/test-unix-alias/test-NNNN/himom.txt:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\ngzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/_old_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log.gz\n/tmp/test-unix-alias/test-NNNN/tfN.txt:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz\n/tmp/test-unix-alias/test-NNNN/_make.log:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log.gz\n--------------------------------------------------------------------------------\nhidad.txt.gz  _make.log.gz\ttestfolder  tf2.txt.gz\nhimom.txt.gz  _old_make.log.gz\ttf1.txt.gz  tf3.txt.gz\n--------------------------------------------------------------------------------\ngzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt\n/tmp/test-unix-alias/test-NNNN/_old_make.log.gz:\t -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log\n/tmp/test-unix-alias/test-NNNN/himom.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt\n/tmp/test-unix-alias/test-NNNN/hidad.txt.gz:\t-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt\ngzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored\n/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt\n/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:\t  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt"=$(test-24-expected)
	[ "$(test-24-actual)" == "$(test-24-expected)" ]
}

function test-24-actual () {
	# no-op in case content just a comment
	true

	ls

}

function test-24-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ cp tf2.txt testfolder/
$ linebr
$ compress-this-dir ./testfolder | testnum
$ linebr
$ ls
$ linebr
$ ununcompress-this-dir ./testfolder | testnum
hidad.txt  _make.log	  testfolder  tf2.txt
himom.txt  _old_make.log  tf1.txt     tf3.txt
'tf2.txt' -> 'testfolder/tf2.txt'
--------------------------------------------------------------------------------
gzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored
/tmp/test-unix-alias/test-NNNN/hidad.txt:	-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt.gz
/tmp/test-unix-alias/test-NNNN/himom.txt:	-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt.gz
/tmp/test-unix-alias/test-NNNN/tfN.txt:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz
/tmp/test-unix-alias/test-NNNN/tfN.txt:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz
gzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored
/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz
/tmp/test-unix-alias/test-NNNN/_old_make.log:	 -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log.gz
/tmp/test-unix-alias/test-NNNN/tfN.txt:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt.gz
/tmp/test-unix-alias/test-NNNN/_make.log:	 -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log.gz
--------------------------------------------------------------------------------
hidad.txt.gz  _make.log.gz	testfolder  tf2.txt.gz
himom.txt.gz  _old_make.log.gz	tf1.txt.gz  tf3.txt.gz
--------------------------------------------------------------------------------
gzip: /tmp/test-unix-alias/test-NNNN is a directory -- ignored
/tmp/test-unix-alias/test-NNNN/_make.log.gz:	 -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_make.log
/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt
/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt
/tmp/test-unix-alias/test-NNNN/_old_make.log.gz:	 -N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/_old_make.log
/tmp/test-unix-alias/test-NNNN/himom.txt.gz:	-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/himom.txt
/tmp/test-unix-alias/test-NNNN/hidad.txt.gz:	-NN.N% -- replaced with /tmp/test-unix-alias/test-NNNN/hidad.txt
gzip: /tmp/test-unix-alias/test-NNNN/testfolder is a directory -- ignored
/tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt.gz:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/testfolder/tfN.txt
/tmp/test-unix-alias/test-NNNN/tfN.txt.gz:	  N.N% -- replaced with /tmp/test-unix-alias/test-NNNN/tfN.txt
END_EXPECTED
}


@test "test-25" {
	testfolder="/tmp/batspp-203637/test-25"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ kill-iceweasel\n' "=========="
	test-25-actual 
	echo "=========" $'# | pattern=/:[0-9][0-9] [^ ]*iceweasel/\n# | filter=/($)(^)/\n# | Warning: No processes matched the pattern' "========="
	test-25-expected 
	echo "============================"
	# ???: '# $ kill-iceweasel\n'=$(test-25-actual)
	# ???: '# | pattern=/:[0-9][0-9] [^ ]*iceweasel/\n# | filter=/($)(^)/\n# | Warning: No processes matched the pattern'=$(test-25-expected)
	[ "$(test-25-actual)" == "$(test-25-expected)" ]
}

function test-25-actual () {
	# no-op in case content just a comment
	true


}

function test-25-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | pattern=/:[0-9][0-9] [^ ]*iceweasel/
# | filter=/($)(^)/
# | Warning: No processes matched the pattern
END_EXPECTED
}


@test "test-26" {
	testfolder="/tmp/batspp-203637/test-26"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'old-count-exts | testnum\n' "=========="
	test-26-actual 
	echo "=========" $'$ linebr\n$ count-exts | testnum\n.txt\tN\n.log\tN\n--------------------------------------------------------------------------------\n.txt\tN\n.log\tN' "========="
	test-26-expected 
	echo "============================"
	# ???: 'old-count-exts | testnum\n'=$(test-26-actual)
	# ???: '$ linebr\n$ count-exts | testnum\n.txt\tN\n.log\tN\n--------------------------------------------------------------------------------\n.txt\tN\n.log\tN'=$(test-26-expected)
	[ "$(test-26-actual)" == "$(test-26-expected)" ]
}

function test-26-actual () {
	# no-op in case content just a comment
	true

	old-count-exts | testnum

}

function test-26-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ count-exts | testnum
.txt	N
.log	N
--------------------------------------------------------------------------------
.txt	N
.log	N
END_EXPECTED
}


@test "test-27" {
	testfolder="/tmp/batspp-203637/test-27"
	mkdir --parents "$testfolder"
	builtin cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Done!"\n' "=========="
	test-27-actual 
	echo "=========" $'Done!' "========="
	test-27-expected 
	echo "============================"
	# ???: 'echo "Done!"\n'=$(test-27-actual)
	# ???: 'Done!'=$(test-27-expected)
	[ "$(test-27-actual)" == "$(test-27-expected)" ]
}

function test-27-actual () {
	# no-op in case content just a comment
	true

	echo "Done!"

}

function test-27-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Done!
END_EXPECTED
}
