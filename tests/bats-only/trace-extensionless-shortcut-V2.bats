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

	alias testuser="sed -r "s/"$USER"+/user/g""
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3570
	mkdir -p "$temp_dir"
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
	echo -e '20'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	alias testnum="sed -r "s/[0-9]/X/g"" 
	alias testuser="sed -r "s/"$USER"+/user/g""
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
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
	kill-em --test firefox | wc -l
}
function test8-assert1-expected () {
	echo -e '21'
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
	kill-it --test firefox | wc -l
}
function test9-assert1-expected () {
	echo -e '21'
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
	actual=$(test10-assert9-actual)
	expected=$(test10-assert9-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert9-actual () {
	ls
}
function test10-assert9-expected () {
	echo -e "renamed 'tomove.txt' -> './newdir1/tomove.txt'newdir1  test.txtBacking up 'test.txt' to './backup/test.txt'--------------------------------------------------------------------------------backup\tnewdir1  test.txt"
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
	ps-mine-all | wc -l | testnum 
}
function test11-assert1-expected () {
	echo -e 'XXX'
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
	rename-files -q test.txt harry.txt
}
function test14-assert1-expected () {
	echo -e 'renaming "test.txt" to "harry.txt"'
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
	perlgrep "print" ./grep_manual.txt
}
function test15-assert1-expected () {
	echo -e 'grep, egrep, fgrep, rgrep - print lines that match patternspatterns separated by newline characters, and  grep  prints  each  lineSuppress  normal output; instead print a count of matching linesSuppress normal output; instead print the  name  of  each  inputfile from which no output would normally have been printed.Suppress  normal  output;  instead  print the name of each inputfile  from  which  output  would  normally  have  been  printed.line of output.  If -o (--only-matching) is specified, print thebe printed in a minimum size field width.-print0,  perl  -0,  sort  -z, and xargs -0 to process arbitraryWhen  -A,  -B, or -C are in use, print SEP instead of -- betweenWhen -A, -B, or -C are in use, do not print a separator  between[:graph:], [:lower:], [:print:], [:punct:], [:space:],  [:upper:],  and'
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	foreach "echo $f" *.txt
}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test17-assert1-actual)
	expected=$(test17-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert1-actual () {
	rename-spaces
}
function test17-assert1-expected () {
	echo -e 'renaming "version none.txt" to "version_none.txt"'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test18-assert1-actual)
	expected=$(test18-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test18-assert1-actual () {
	rename-special-punct
}
function test18-assert1-expected () {
	echo -e 'renaming "version?.txt" to "version.txt"'
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

	actual=$(test20-assert1-actual)
	expected=$(test20-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test20-assert1-actual () {
	move-duplicates
}
function test20-assert1-expected () {
	echo -e "renamed 'psaux(1).txt' -> 'duplicates/psaux(1).txt'renamed 'psaux(2).txt' -> 'duplicates/psaux(2).txt'renamed 'psaux(3).txt' -> 'duplicates/psaux(3).txt'"
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
	rename-parens -v
}
function test21-assert1-expected () {
	echo -e 'renaming "process(L).md" to "processL.md"renaming "process(U).md" to "processU.md"renaming "process(X).md" to "processX.md"'
}

@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test22-assert1-actual)
	expected=$(test22-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test22-assert1-actual () {
	rename-quotes -v
}
function test22-assert1-expected () {
	echo -e 'WARNING: Ignoring -quick mode as files specified'
}

@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test23-assert1-actual)
	expected=$(test23-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test23-assert1-actual () {
	ls
}
function test23-assert1-expected () {
	echo -e 'backup\t\t   newdir1\t      processX.md\t versionR-1.txtduplicates\t  "process\'all\'.md"   versionA.txta\t versionR.txtgrep_manual.txt   processL.md\t      versionI.txt\t version.txtharry.txt\t   processU.md\t      version_none.txt\t versionV.txt'
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
	copy-with-file-date *.md | wc -l
}
function test25-assert1-expected () {
	echo -e "cp: cannot stat 'processall.md': No such file or directory3"
}

@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	man cat > man_cat.txt
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
	unigrams ./man_cat.txt | testuser | testnum
}
function test27-assert1-expected () {
	echo -e "to\tXand\tXstandard\tXoutput\tXcat\tXgnu\tXdisplay\tXfree\tXor\tXis\tXequivalent\tXoutput.\tXlines\tXthen\tXthis\tXconcatenate\tX-\tXby\tXbugs\tXtab\tXnumber\tXcat(X)\tXno\tXversion\tXcoreutils\tXcopyright\tXexit\tXthe\tXrepeated\tX-,\tX'(coreutils)\tXchange\tXg\tXf\tXinformation\tX--number\tXfebruary\tXreporting\tX[option]...\tXany\tXalso\tXend\tXfull\tXon\tXthere\tXof\tX--squeeze-blank\tX©\tX-b,\tX<https://translationproject.org/team/>\tX-t,\tXinfo\tXfile(s)\tXsynopsis\tXare\tX--show-nonprinting\tXas\tX[file]...\tXXXXX\tX^\tXyou\tXdescription\tXexcept\tXlfd\tX-t\tXprint\tXwhen\tXtorbjorn\tXinput.\tXXXXX\tX(ignored)\tX--version\tXhelp\tX--show-all\tXat\tXinput,\tXfile\tXavailable\tXpermitted\tX-a,\tXtac(X)\tXcontents,\tXfoundation,\tXwarranty,\tX-s,\tXread\tXcontents.\tXnotation,\tX-v,\tX-u\tXhelp:\tXgplvX+:\tXuser\tX^i\tX-vet\tX$\tX-ve\tXauthor\tXX.XX\tXX\tXall\tXtranslation\tXn/a\tX--help\tX--number-nonblank\tXuse\tXlaw.\tXfile,\tXlicense\tXextent\tXm.\tXgpl\tXnonempty\tXm-\tXonline\tXinput\tXlocally\tXg's\tXf's\tXit.\tXfiles\tX-e,\tXoverrides\tXsee\tX-n\tXwith\tXname\tXexamples\tX<https://gnu.org/licenses/gpl.html>.\tXlater\tXredistribute\tXdocumentation\tXempty\tX-e\tXsoftware\tXeach\tXgranlund\tXcharacters\tX-n,\tXsoftware:\tXcopy\tXsuppress\tXcommands\tX--show-ends\tXinvocation'\tX<https://www.gnu.org/software/coreutils/cat>\tXrichard\tXlines,\tXfor\tX<https://www.gnu.org/software/coreutils/>\tX-vt\tXstallman.\tXline\tXinc.\tX--show-tabs\tXvia:\tXreport\tXwritten\tX"
}

@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test28-assert1-actual)
	expected=$(test28-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

	actual=$(test28-assert2-actual)
	expected=$(test28-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test28-assert1-actual () {
	word-count ./man_cat.txt | testuser | testnum
}
function test28-assert1-expected () {
	echo -e "to\tXand\tXstandard\tXoutput\tXcat\tXor\tXfree\tXis\tXdisplay\tXequivalent\tXgnu\tXnumber\tXversion\tXcopyright\tXoutput.\tXbugs\tXthen\tXlines\tXexit\tXby\tXno\tXthis\tXtab\tXconcatenate\tXthe\tXcat(X)\tX-\tXcoreutils\tXlfd\tXsee\tXcontents,\tX^\tXXXXX\tX<https://translationproject.org/team/>\tX-ve\tXfor\tXeach\tX'(coreutils)\tXwritten\tXinfo\tXsuppress\tXcommands\tXm.\tXgranlund\tXat\tXline\tX[option]...\tXvia:\tXname\tX-n\tXcopy\tX-v,\tXhelp\tXit.\tX<https://www.gnu.org/software/coreutils/cat>\tXcharacters\tX-t\tXstallman.\tXall\tXdescription\tXon\tXnonempty\tX-b,\tXlocally\tXthere\tX-e,\tX-vet\tX--help\tX^i\tX-vt\tXfebruary\tXnotation,\tXinput.\tXwarranty,\tXuser\tXfile(s)\tXfull\tX--version\tXlaw.\tXauthor\tX-u\tXas\tXreport\tXf\tXpermitted\tXcontents.\tXhelp:\tXfoundation,\tXlines,\tXg\tXempty\tXm-\tX--show-ends\tXwhen\tX--show-tabs\tXinformation\tXf's\tXn/a\tXsoftware\tXinput,\tXinvocation'\tX-t,\tXend\tXrepeated\tX<https://www.gnu.org/software/coreutils/>\tX-a,\tX[file]...\tX-,\tX<https://gnu.org/licenses/gpl.html>.\tXuse\tXg's\tX--show-all\tX--number\tX-n,\tXof\tXreporting\tXfile,\tXtorbjorn\tXexcept\tXsoftware:\tXoverrides\tX--number-nonblank\tXredistribute\tX--show-nonprinting\tXtranslation\tXgplvX+:\tXalso\tX--squeeze-blank\tXX.XX\tX©\tX-s,\tXfile\tXchange\tXdocumentation\tX"
}
function test28-assert2-actual () {
		X
}
function test28-assert2-expected () {
	echo -e 'X\tXany\tXexamples\tXinc.\tXwith\tXextent\tXXXXX\tX(ignored)\tXonline\tXlater\tXlicense\tXgpl\tXread\tXinput\tX-e\tXavailable\tXyou\tXtac(X)\tXrichard\tXprint\tXfiles\tXare\tXsynopsis\tX'
}

@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test29-assert1-actual)
	expected=$(test29-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

	actual=$(test29-assert2-actual)
	expected=$(test29-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test29-assert1-actual () {
	bigrams ./man_cat.txt | testuser | testnum
}
function test29-assert1-expected () {
	echo -e "equivalent:to\tXoutput:lines\tXto:standard\tXstandard:output.\tXand:exit\tXgnu:coreutils\tXnotation,:except\tX--number:number\tXf:-\tXX.XX:february\tXread:standard\tXcontents.:cat\tX<https://translationproject.org/team/>:copyright\tX--show-ends:display\tXstallman.:reporting\tXline:-n,\tXcoreutils:X.XX\tXreporting:bugs\tX-e:equivalent\tXoutput:version\tX-s,:--squeeze-blank\tXfile(s):to\tXdisplay:tab\tXas:^i\tXlocally:via:\tXcommands:cat(X)\tXprint:on\tXlfd:and\tXg:output\tXor:later\tXoutput:synopsis\tXn/a:n/a\tXdisplay:$\tXavailable:locally\tXeach:line\tXhelp::<https://www.gnu.org/software/coreutils/>\tXyou:are\tXinput,:then\tXnumber:all\tX--number-nonblank:number\tXsoftware::you\tXare:free\tX--help:display\tXoutput:lines,\tX-vt:-t,\tXis:no\tXinformation:and\tXany:translation\tXgpl:version\tXthe:extent\tXsee:also\tXand:redistribute\tXm.:stallman.\tXoutput:f's\tXby:law.\tXexit:examples\tXf's:contents,\tXfile:is\tXcat:copy\tX-:concatenate\tXfoundation,:inc.\tXto:-vt\tXlater:<https://gnu.org/licenses/gpl.html>.\tXon:the\tX'(coreutils):cat\tXexamples:cat\tXX:or\tXstandard:input\tX-b,:--number-nonblank\tXall:output\tXno:warranty,\tXtab:characters\tX<https://gnu.org/licenses/gpl.html>.:this\tXgnu:gpl\tXredistribute:it.\tXcat(X):user\tXwith:no\tXfree:to\tXexit:--version\tXcat:invocation'\tX(ignored):-v,\tXis:free\tXthere:is\tXto:change\tXpermitted:by\tXinvocation':gnu\tXalso:tac(X)\tXand:print\tXn/a:cat(X)\tX-,:read\tX-u:(ignored)\tXinput:to\tXto:the\tXlicense:gplvX+:\tXfiles:and\tXcopyright:©\tXXXXX:free\tXfree:software\tXfile,:or\tXof:each\tXinc.:license\tXwritten:by\tXoutput.:author\tXat:end\tXand:m-\tX©:XXXX\tXlines:-s,\tXend:of\tXthen:g's\tX-v,:--show-nonprinting\tX--squeeze-blank:suppress\tXlaw.:see\tX--show-all:equivalent\tXfebruary:XXXX\tXoutput.:with\tXconcatenate:files\tX-:g\tX[file]...:description\tXg's:contents.\tX"
}
function test29-assert2-actual () {
	:at	X
}
function test29-assert2-expected () {
	echo -e "m-:notation,\tXfree:software:\tX-t,:--show-tabs\tXsoftware:foundation,\tXfull:documentation\tXto:<https://translationproject.org/team/>\tX<https://www.gnu.org/software/coreutils/cat>:or\tXor:when\tXhelp:and\tXsuppress:repeated\tX-ve:-e,\tXlines:-t\tXname:cat\tXrepeated:empty\tX-e,:--show-ends\tXthis:is\tX-n:-e\tXtac(X):full\tXinfo:'(coreutils)\tXby:torbjorn\tXuser:commands\tX-n,:--number\tXuse:^\tXcat:f\tXfor:lfd\tXno:file,\tXnumber:nonempty\tXauthor:written\tXconcatenate:file(s)\tXchange:and\tXwhen:file\tXinput.:-a,\tXdocumentation:<https://www.gnu.org/software/coreutils/cat>\tXbugs:to\tXstandard:output\tXversion:information\tXgplvX+::gnu\tXtorbjorn:granlund\tXextent:permitted\tXgranlund:and\tXcharacters:as\tXempty:output\tXto:-vet\tXto:-ve\tXsynopsis:cat\tXexcept:for\tXoverrides:-n\tX-a,:--show-all\tXcoreutils:online\tXcopy:standard\tXthis:help\tXor:available\tX-vet:-b,\tX--show-tabs:display\tXversion:X\tXcopyright:copyright\tXvia::info\tXand:tab\tXcontents,:then\tXwarranty,:to\tX[option]...:[file]...\tXis:-,\tXstandard:input.\tX^i:-u\tXdescription:concatenate\tX--show-nonprinting:use\tXcat:[option]...\tXlines,:overrides\tXdisplay:this\tXbugs:gnu\tXnonempty:output\tX^:and\tXthe:standard\tXand:richard\tXit.:there\tX--version:output\tXreport:any\tXtab:--help\tX<https://www.gnu.org/software/coreutils/>:report\tX-t:equivalent\tXstandard:input,\tXonline:help:\tXcat:-\tXcat(X):name\tXthen:standard\tXtranslation:bugs\tXrichard:m.\tX"
}

@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test31" {
	test_folder=$(echo /tmp/test31-$$)
	mkdir $test_folder && cd $test_folder

	setenv MY_USERNAME xaea12-temp
	actual=$(test31-assert2-actual)
	expected=$(test31-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test31-assert2-actual () {
	echo $MY_USERNAME
}
function test31-assert2-expected () {
	echo -e 'xaea12-temp'
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

	actual=$(test33-assert1-actual)
	expected=$(test33-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test33-assert1-actual () {
	echo "END"
}
function test33-assert1-expected () {
	echo -e 'END'
}
