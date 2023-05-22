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
	echo -e '20'
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
	echo -e '20'
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
	echo -e 'NNN'
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

	actual=$(test27-assert2-actual)
	expected=$(test27-assert2-expected)
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
	echo -e "to\tNand\tNstandard\tNoutput\tNcat\tNequivalent\tNfree\tNgnu\tNdisplay\tNis\tNor\tNcoreutils\tNthen\tN-\tNtab\tNcat(N)\tNbugs\tNnumber\tNno\tNoutput.\tNby\tNthe\tNthis\tNlines\tNconcatenate\tNexit\tNversion\tNcopyright\tNinput,\tNhelp\tN-b,\tNgpl\tN-vt\tN^i\tN-,\tNreporting\tN-n,\tNfor\tNgranlund\tNname\tNfile,\tNm-\tNfile(s)\tNdocumentation\tNdescription\tNwhen\tNfoundation,\tN--version\tNfebruary\tN--help\tNfiles\tNit.\tN--number\tNinput.\tN<https://translationproject.org/team/>\tNN\tNm.\tNinvocation'\tN-a,\tN--show-nonprinting\tNchange\tNnotation,\tNuse\tNN.NN\tNfull\tNgplvN+:\tN-u\tNnonempty\tN'(coreutils)\tNend\tNfile\tNextent\tNtac(N)\tNrepeated\tN<https://www.gnu.org/software/coreutils/cat>\tNtranslation\tN--number-nonblank\tNsuppress\tN-s,\tNhelp:\tNstallman.\tNsoftware\tNtorbjorn\tNvia:\tNpermitted\tNlater\tN^\tNrichard\tNinc.\tNsee\tNalso\tNwritten\tN-e\tNoverrides\tN-t,\tNlfd\tNsynopsis\tNlocally\tNinput\tNreport\tN<https://gnu.org/licenses/gpl.html>.\tNon\tNf's\tNcharacters\tNcommands\tN-n\tN-v,\tNwarranty,\tNsoftware:\tNread\tNcontents,\tNat\tNany\tN-vet\tNg\tNof\tNempty\tNexamples\tNline\tNprint\tNas\tN(ignored)\tNwith\tNlines,\tNcontents.\tN--show-ends\tNauthor\tNthere\tNonline\tN-ve\tN<https://www.gnu.org/software/coreutils/>\tNlicense\tN--show-all\tN[file]...\tNcopy\tNn/a\tNinformation\tN[option]...\tNredistribute\tNinfo\tNg's\tNlaw.\tN-e,\tNuser\tNexcept\tN-t\tNeach\tN©\tNall\tNNNNN\tN--show-tabs\tNavailable\tN--squeeze-blank\tN"
}
function test27-assert2-actual () {
		N
}
function test27-assert2-expected () {
	echo -e 'you\tNf\tNNNNN\tNare\tN'
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
	echo -e "to\tNand\tNstandard\tNoutput\tNcat\tNor\tNis\tNequivalent\tNfree\tNgnu\tNdisplay\tNcat(N)\tNcopyright\tNtab\tNlines\tNexit\tNoutput.\tNthis\tN-\tNnumber\tNthen\tNbugs\tNversion\tNcoreutils\tNconcatenate\tNno\tNthe\tNby\tNN.NN\tNgplvN+:\tNN\tN-,\tN<https://www.gnu.org/software/coreutils/cat>\tN--show-tabs\tNsynopsis\tN'(coreutils)\tNuse\tN^\tNgranlund\tNof\tNg\tNfile(s)\tNtac(N)\tNfull\tNcopy\tNnotation,\tN-b,\tNhelp\tNg's\tNthere\tNexcept\tNcontents,\tNpermitted\tNlicense\tN--show-ends\tNnonempty\tNfiles\tN©\tNfebruary\tN[file]...\tNat\tNend\tN--show-nonprinting\tNgpl\tNf's\tN-n\tNinput,\tNhelp:\tNcontents.\tNread\tNsee\tN--show-all\tN-e,\tNdescription\tNauthor\tN<https://gnu.org/licenses/gpl.html>.\tN--squeeze-blank\tNalso\tN-a,\tNon\tNname\tN-v,\tNreport\tNf\tNprint\tNlocally\tNredistribute\tNoverrides\tNsoftware\tNfor\tN-t,\tNwarranty,\tN--version\tNwritten\tN-vet\tNvia:\tN[option]...\tN-e\tNas\tN--number\tNonline\tNsuppress\tNinvocation'\tNall\tN-t\tNsoftware:\tN-vt\tNchange\tNNNNN\tN"
}
function test28-assert2-actual () {
		N
}
function test28-assert2-expected () {
	echo -e 'richard\tNinfo\tN<https://www.gnu.org/software/coreutils/>\tNlines,\tNinput\tNyou\tNm.\tNinput.\tN-n,\tN(ignored)\tNdocumentation\tNlaw.\tNinc.\tN^i\tNwith\tNNNNN\tNn/a\tN--help\tNm-\tNfile\tNtranslation\tNare\tNit.\tN-s,\tNreporting\tNcommands\tNempty\tN-ve\tNextent\tNcharacters\tNany\tN<https://translationproject.org/team/>\tNtorbjorn\tNlater\tNrepeated\tN--number-nonblank\tNfoundation,\tNstallman.\tNfile,\tNeach\tN-u\tNuser\tNinformation\tNavailable\tNlfd\tNline\tNwhen\tNexamples\tN'
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
	echo -e "equivalent:to\tNoutput:lines\tNto:standard\tNgnu:coreutils\tNand:exit\tNstandard:output.\tNor:later\tNNNNN:free\tN-n,:--number\tN--show-nonprinting:use\tN-:g\tN-v,:--show-nonprinting\tNpermitted:by\tNcopyright:copyright\tNcat:invocation'\tNand:m-\tNcopyright:©\tNoutput:lines,\tNoutput:synopsis\tNnumber:all\tNcoreutils:online\tNany:translation\tNf:-\tNgpl:version\tNm-:notation,\tNwith:no\tNtranslation:bugs\tN-t:equivalent\tNand:tab\tNreport:any\tNyou:are\tNsoftware::you\tN--version:output\tNname:cat\tN-e,:--show-ends\tNand:redistribute\tNstandard:input.\tNdisplay:$\tNfree:to\tNoutput.:with\tNgnu:gpl\tNeach:line\tN--show-tabs:display\tNversion:N\tN^:and\tNcat:[option]...\tN-,:read\tNthis:is\tNn/a:cat(N)\tNthe:standard\tNempty:output\tN-ve:-e,\tNlines,:overrides\tNcat:f\tN--squeeze-blank:suppress\tNfor:lfd\tNfoundation,:inc.\tNcontents.:cat\tNinput:to\tNthen:g's\tN[option]...:[file]...\tN-vet:-b,\tNis:free\tNtab:characters\tNno:warranty,\tNlocally:via:\tNtac(N):full\tNoutput:version\tN<https://translationproject.org/team/>:copyright\tNcat(N):name\tNor:when\tNno:file,\tNcopy:standard\tNfree:software:\tNis:no\tNprint:on\tN(ignored):-v,\tNthere:is\tNlfd:and\tNinformation:and\tNsoftware:foundation,\tNlicense:gplvN+:\tNexit:--version\tNavailable:locally\tNuse:^\tNlater:<https://gnu.org/licenses/gpl.html>.\tNstandard:input,\tNas:^i\tNcharacters:as\tN^i:-u\tNexamples:cat\tNlaw.:see\tNbugs:to\tNn/a:n/a\tNg:output\tNoutput:f's\tNat:end\tNline:-n,\tNlines:-s,\tNcoreutils:N.NN\tNbugs:gnu\tNcat:-\tNstandard:output\tNto:-ve\tN--number-nonblank:number\tNto:-vet\tNconcatenate:file(s)\tNare:free\tN<https://www.gnu.org/software/coreutils/cat>:or\tNoutput.:author\tNsuppress:repeated\tNcat(N):user\tN-a,:--show-all\tN-vt:-t,\tNcommands:cat(N)\tN-n:-e\tNsee:also\tNinvocation':gnu\tNredistribute:it.\tN'(coreutils):cat\tNstallman.:reporting\tNonline:help:\tNof:each\tNm.:stallman.\tNsynopsis:cat\tNfebruary:NNNN\tNthe:extent\tN"
}
function test29-assert2-actual () {
	:at	N
}
function test29-assert2-expected () {
	echo -e "user:commands\tNto:-vt\tN[file]...:description\tNreporting:bugs\tNread:standard\tN-b,:--number-nonblank\tN<https://www.gnu.org/software/coreutils/>:report\tN--show-all:equivalent\tN--number:number\tNg's:contents.\tNinput,:then\tNto:<https://translationproject.org/team/>\tN--show-ends:display\tNgranlund:and\tNby:law.\tNfree:software\tNor:available\tNthis:help\tNdisplay:this\tNend:of\tNhelp::<https://www.gnu.org/software/coreutils/>\tNconcatenate:files\tNcat:copy\tNnonempty:output\tN-t,:--show-tabs\tN--help:display\tN-:concatenate\tNis:-,\tNon:the\tNtab:--help\tNdisplay:tab\tN-e:equivalent\tNfile(s):to\tNhelp:and\tNto:change\tNdescription:concatenate\tNit.:there\tNvia::info\tNby:torbjorn\tNalso:tac(N)\tNlines:-t\tNrepeated:empty\tNwarranty,:to\tN-u:(ignored)\tN<https://gnu.org/licenses/gpl.html>.:this\tNnotation,:except\tN-s,:--squeeze-blank\tNall:output\tNextent:permitted\tNrichard:m.\tNand:richard\tNN:or\tNand:print\tNfile:is\tNexcept:for\tNchange:and\tNfile,:or\tNversion:information\tNinput.:-a,\tNthen:standard\tNto:the\tNinfo:'(coreutils)\tNfiles:and\tNnumber:nonempty\tNN.NN:february\tNinc.:license\tN©:NNNN\tNcontents,:then\tNauthor:written\tNoverrides:-n\tNf's:contents,\tNdocumentation:<https://www.gnu.org/software/coreutils/cat>\tNwhen:file\tNgplvN+::gnu\tNwritten:by\tNfull:documentation\tNtorbjorn:granlund\tNstandard:input\tNexit:examples\tN"
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
