#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-125540/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-125540/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-125540/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-setupsort\n' "=========="
	test-4-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-setupsort\n'=$(test-4-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-setupsort

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-125540/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-6411\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-setupsort/test-6411' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-6411\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-setupsort/test-6411'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-6411

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-setupsort/test-6411
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-125540/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-6-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0" "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-6-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n1\n0"=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
1
0
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-125540/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testnum="sed -r "s/[0-9]/H/g"" \n' "=========="
	test-7-actual 
	echo "=========" $'$ alias testuser="sed -r "s/"$USER"+/userxf333/g""' "========="
	test-7-expected 
	echo "============================"
	# ???: 'alias testnum="sed -r "s/[0-9]/H/g"" \n'=$(test-7-actual)
	# ???: '$ alias testuser="sed -r "s/"$USER"+/userxf333/g""'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	alias testnum="sed -r "s/[0-9]/H/g"" 

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testuser="sed -r "s/"$USER"+/userxf333/g""
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-125540/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-8-actual 
	echo "=========" $'' "========="
	test-8-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-8-actual)
	# ???: ''=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-125540/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd | testuser\n' "=========="
	test-9-actual 
	echo "=========" $'/tmp/test-setupsort/test-6411' "========="
	test-9-expected 
	echo "============================"
	# ???: 'pwd | testuser\n'=$(test-9-actual)
	# ???: '/tmp/test-setupsort/test-6411'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	pwd | testuser

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/tmp/test-setupsort/test-6411
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-125540/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-10-actual 
	echo "=========" $'$ man printf > pf_manual.txt\n$ cat pf_manual.txt | tab-sort | testnum | testuser' "========="
	test-10-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-10-actual)
	# ???: '$ man printf > pf_manual.txt\n$ cat pf_manual.txt | tab-sort | testnum | testuser'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ man printf > pf_manual.txt
$ cat pf_manual.txt | tab-sort | testnum | testuser
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-125540/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat pf_manual.txt | colon-sort | testnum | testuser\n' "=========="
	test-11-actual 
	echo "=========" $'' "========="
	test-11-expected 
	echo "============================"
	# ???: 'cat pf_manual.txt | colon-sort | testnum | testuser\n'=$(test-11-actual)
	# ???: ''=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	cat pf_manual.txt | colon-sort | testnum | testuser

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-125540/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat pf_manual.txt | colon-sort-rev-num | testnum | testuser\n' "=========="
	test-12-actual 
	echo "=========" $'\\xHH   byte with hexadecimal value HH (H to H digits)\n       Written by David MacKenzie.\n       \\v     vertical tab\n       --version\n              Unicode character with hex value HHHHHHHH (H digits)\n       umentation for details about the options it supports.\n       \\uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)\n       \\UHHHHHHHH\n       \\t     horizontal tab\n       This is free software: you are free  to  change  and  redistribute  it.\n       There is NO WARRANTY, to the extent permitted by law.\nSYNOPSIS\nSEE ALSO\nREPORTING BUGS\n       Report any translation bugs to <https://translationproject.org/team/>\n       \\r     carriage return\n       %q     ARGUMENT is printed in a format that can be reused as shell  in‐\n              put,  escaping  non-printable characters with the proposed POSIX\n       printf OPTION\n       printf FORMAT [ARGUMENT]...\n       printf - format and print data\n       printf(H)\nPRINTF(H)                        User Commands                       PRINTF(H)\n       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:\n       persedes the version described here.  Please refer to your shell\'s doc‐\n              output version information and exit\n       or available locally via: info \'(coreutils) printf invocation\'\n              octal escapes are of the form \\H or \\HNNN\n       NOTE:  your shell may have its own version of printf, which usually su‐\n       \\NNN   byte with octal value NNN (H to H digits)\n       \\n     new line\nNAME\n       --help display this help and exit\n       GPL version H or later <https://gnu.org/licenses/gpl.html>.\n       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>\nGNU coreutils H.HH               February HHHH                       PRINTF(H)\n       Full documentation <https://www.gnu.org/software/coreutils/printf>\n       FORMAT controls the output as in C printf.  Interpreted sequences are:\n       \\f     form feed\n       \\e     escape\n       \\"     double quote\nDESCRIPTION\n       \\c     produce no further output\n       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU\nCOPYRIGHT\n       \\b     backspace\n       %b     ARGUMENT  as  a string with \'\\\' escapes interpreted, except that\n       \\\\     backslash\nAUTHOR\n       %%     a single %\n       ARGUMENTs converted to proper type first.  Variable widths are handled.\n       and all C format specifications ending with one of diouxXfeEgGcs,  with\n       \\a     alert (BEL)\n              $\'\' syntax.' "========="
	test-12-expected 
	echo "============================"
	# ???: 'cat pf_manual.txt | colon-sort-rev-num | testnum | testuser\n'=$(test-12-actual)
	# ???: '\\xHH   byte with hexadecimal value HH (H to H digits)\n       Written by David MacKenzie.\n       \\v     vertical tab\n       --version\n              Unicode character with hex value HHHHHHHH (H digits)\n       umentation for details about the options it supports.\n       \\uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)\n       \\UHHHHHHHH\n       \\t     horizontal tab\n       This is free software: you are free  to  change  and  redistribute  it.\n       There is NO WARRANTY, to the extent permitted by law.\nSYNOPSIS\nSEE ALSO\nREPORTING BUGS\n       Report any translation bugs to <https://translationproject.org/team/>\n       \\r     carriage return\n       %q     ARGUMENT is printed in a format that can be reused as shell  in‐\n              put,  escaping  non-printable characters with the proposed POSIX\n       printf OPTION\n       printf FORMAT [ARGUMENT]...\n       printf - format and print data\n       printf(H)\nPRINTF(H)                        User Commands                       PRINTF(H)\n       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:\n       persedes the version described here.  Please refer to your shell\'s doc‐\n              output version information and exit\n       or available locally via: info \'(coreutils) printf invocation\'\n              octal escapes are of the form \\H or \\HNNN\n       NOTE:  your shell may have its own version of printf, which usually su‐\n       \\NNN   byte with octal value NNN (H to H digits)\n       \\n     new line\nNAME\n       --help display this help and exit\n       GPL version H or later <https://gnu.org/licenses/gpl.html>.\n       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>\nGNU coreutils H.HH               February HHHH                       PRINTF(H)\n       Full documentation <https://www.gnu.org/software/coreutils/printf>\n       FORMAT controls the output as in C printf.  Interpreted sequences are:\n       \\f     form feed\n       \\e     escape\n       \\"     double quote\nDESCRIPTION\n       \\c     produce no further output\n       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU\nCOPYRIGHT\n       \\b     backspace\n       %b     ARGUMENT  as  a string with \'\\\' escapes interpreted, except that\n       \\\\     backslash\nAUTHOR\n       %%     a single %\n       ARGUMENTs converted to proper type first.  Variable widths are handled.\n       and all C format specifications ending with one of diouxXfeEgGcs,  with\n       \\a     alert (BEL)\n              $\'\' syntax.'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	cat pf_manual.txt | colon-sort-rev-num | testnum | testuser

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
\xHH   byte with hexadecimal value HH (H to H digits)
       Written by David MacKenzie.
       \v     vertical tab
       --version
              Unicode character with hex value HHHHHHHH (H digits)
       umentation for details about the options it supports.
       \uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)
       \UHHHHHHHH
       \t     horizontal tab
       This is free software: you are free  to  change  and  redistribute  it.
       There is NO WARRANTY, to the extent permitted by law.
SYNOPSIS
SEE ALSO
REPORTING BUGS
       Report any translation bugs to <https://translationproject.org/team/>
       \r     carriage return
       %q     ARGUMENT is printed in a format that can be reused as shell  in‐
              put,  escaping  non-printable characters with the proposed POSIX
       printf OPTION
       printf FORMAT [ARGUMENT]...
       printf - format and print data
       printf(H)
PRINTF(H)                        User Commands                       PRINTF(H)
       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:
       persedes the version described here.  Please refer to your shell's doc‐
              output version information and exit
       or available locally via: info '(coreutils) printf invocation'
              octal escapes are of the form \H or \HNNN
       NOTE:  your shell may have its own version of printf, which usually su‐
       \NNN   byte with octal value NNN (H to H digits)
       \n     new line
NAME
       --help display this help and exit
       GPL version H or later <https://gnu.org/licenses/gpl.html>.
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
GNU coreutils H.HH               February HHHH                       PRINTF(H)
       Full documentation <https://www.gnu.org/software/coreutils/printf>
       FORMAT controls the output as in C printf.  Interpreted sequences are:
       \f     form feed
       \e     escape
       \"     double quote
DESCRIPTION
       \c     produce no further output
       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU
COPYRIGHT
       \b     backspace
       %b     ARGUMENT  as  a string with '\' escapes interpreted, except that
       \\     backslash
AUTHOR
       %%     a single %
       ARGUMENTs converted to proper type first.  Variable widths are handled.
       and all C format specifications ending with one of diouxXfeEgGcs,  with
       \a     alert (BEL)
              $'' syntax.
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-125540/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat pf_manual.txt | freq-sort | testnum | testuser\n' "=========="
	test-13-actual 
	echo "=========" $'\\xHH   byte with hexadecimal value HH (H to H digits)\n       Written by David MacKenzie.\n       \\v     vertical tab\n       --version\n              Unicode character with hex value HHHHHHHH (H digits)\n       umentation for details about the options it supports.\n       \\uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)\n       \\UHHHHHHHH\n       \\t     horizontal tab\n       This is free software: you are free  to  change  and  redistribute  it.\n       There is NO WARRANTY, to the extent permitted by law.\nSYNOPSIS\nSEE ALSO\nREPORTING BUGS\n       Report any translation bugs to <https://translationproject.org/team/>\n       \\r     carriage return\n       %q     ARGUMENT is printed in a format that can be reused as shell  in‐\n              put,  escaping  non-printable characters with the proposed POSIX\n       printf OPTION\n       printf FORMAT [ARGUMENT]...\n       printf - format and print data\n       printf(H)\nPRINTF(H)                        User Commands                       PRINTF(H)\n       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:\n       persedes the version described here.  Please refer to your shell\'s doc‐\n              output version information and exit\n       or available locally via: info \'(coreutils) printf invocation\'\n              octal escapes are of the form \\H or \\HNNN\n       NOTE:  your shell may have its own version of printf, which usually su‐\n       \\NNN   byte with octal value NNN (H to H digits)\n       \\n     new line\nNAME\n       --help display this help and exit\n       GPL version H or later <https://gnu.org/licenses/gpl.html>.\n       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>\nGNU coreutils H.HH               February HHHH                       PRINTF(H)\n       Full documentation <https://www.gnu.org/software/coreutils/printf>\n       FORMAT controls the output as in C printf.  Interpreted sequences are:\n       \\f     form feed\n       \\e     escape\n       \\"     double quote\nDESCRIPTION\n       \\c     produce no further output\n       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU\nCOPYRIGHT\n       \\b     backspace\n       %b     ARGUMENT  as  a string with \'\\\' escapes interpreted, except that\n       \\\\     backslash\nAUTHOR\n       %%     a single %\n       ARGUMENTs converted to proper type first.  Variable widths are handled.\n       and all C format specifications ending with one of diouxXfeEgGcs,  with\n       \\a     alert (BEL)\n              $\'\' syntax.' "========="
	test-13-expected 
	echo "============================"
	# ???: 'cat pf_manual.txt | freq-sort | testnum | testuser\n'=$(test-13-actual)
	# ???: '\\xHH   byte with hexadecimal value HH (H to H digits)\n       Written by David MacKenzie.\n       \\v     vertical tab\n       --version\n              Unicode character with hex value HHHHHHHH (H digits)\n       umentation for details about the options it supports.\n       \\uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)\n       \\UHHHHHHHH\n       \\t     horizontal tab\n       This is free software: you are free  to  change  and  redistribute  it.\n       There is NO WARRANTY, to the extent permitted by law.\nSYNOPSIS\nSEE ALSO\nREPORTING BUGS\n       Report any translation bugs to <https://translationproject.org/team/>\n       \\r     carriage return\n       %q     ARGUMENT is printed in a format that can be reused as shell  in‐\n              put,  escaping  non-printable characters with the proposed POSIX\n       printf OPTION\n       printf FORMAT [ARGUMENT]...\n       printf - format and print data\n       printf(H)\nPRINTF(H)                        User Commands                       PRINTF(H)\n       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:\n       persedes the version described here.  Please refer to your shell\'s doc‐\n              output version information and exit\n       or available locally via: info \'(coreutils) printf invocation\'\n              octal escapes are of the form \\H or \\HNNN\n       NOTE:  your shell may have its own version of printf, which usually su‐\n       \\NNN   byte with octal value NNN (H to H digits)\n       \\n     new line\nNAME\n       --help display this help and exit\n       GPL version H or later <https://gnu.org/licenses/gpl.html>.\n       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>\nGNU coreutils H.HH               February HHHH                       PRINTF(H)\n       Full documentation <https://www.gnu.org/software/coreutils/printf>\n       FORMAT controls the output as in C printf.  Interpreted sequences are:\n       \\f     form feed\n       \\e     escape\n       \\"     double quote\nDESCRIPTION\n       \\c     produce no further output\n       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU\nCOPYRIGHT\n       \\b     backspace\n       %b     ARGUMENT  as  a string with \'\\\' escapes interpreted, except that\n       \\\\     backslash\nAUTHOR\n       %%     a single %\n       ARGUMENTs converted to proper type first.  Variable widths are handled.\n       and all C format specifications ending with one of diouxXfeEgGcs,  with\n       \\a     alert (BEL)\n              $\'\' syntax.'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	cat pf_manual.txt | freq-sort | testnum | testuser

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
\xHH   byte with hexadecimal value HH (H to H digits)
       Written by David MacKenzie.
       \v     vertical tab
       --version
              Unicode character with hex value HHHHHHHH (H digits)
       umentation for details about the options it supports.
       \uHHHH Unicode (ISO/IEC HHHHH) character with hex value HHHH (H digits)
       \UHHHHHHHH
       \t     horizontal tab
       This is free software: you are free  to  change  and  redistribute  it.
       There is NO WARRANTY, to the extent permitted by law.
SYNOPSIS
SEE ALSO
REPORTING BUGS
       Report any translation bugs to <https://translationproject.org/team/>
       \r     carriage return
       %q     ARGUMENT is printed in a format that can be reused as shell  in‐
              put,  escaping  non-printable characters with the proposed POSIX
       printf OPTION
       printf FORMAT [ARGUMENT]...
       printf - format and print data
       printf(H)
PRINTF(H)                        User Commands                       PRINTF(H)
       Print ARGUMENT(s) according to FORMAT, or execute according to OPTION:
       persedes the version described here.  Please refer to your shell's doc‐
              output version information and exit
       or available locally via: info '(coreutils) printf invocation'
              octal escapes are of the form \H or \HNNN
       NOTE:  your shell may have its own version of printf, which usually su‐
       \NNN   byte with octal value NNN (H to H digits)
       \n     new line
NAME
       --help display this help and exit
       GPL version H or later <https://gnu.org/licenses/gpl.html>.
       GNU coreutils online help: <https://www.gnu.org/software/coreutils/>
GNU coreutils H.HH               February HHHH                       PRINTF(H)
       Full documentation <https://www.gnu.org/software/coreutils/printf>
       FORMAT controls the output as in C printf.  Interpreted sequences are:
       \f     form feed
       \e     escape
       \"     double quote
DESCRIPTION
       \c     produce no further output
       Copyright  ©  HHHH  Free Software Foundation, Inc.  License GPLvH+: GNU
COPYRIGHT
       \b     backspace
       %b     ARGUMENT  as  a string with '\' escapes interpreted, except that
       \\     backslash
AUTHOR
       %%     a single %
       ARGUMENTs converted to proper type first.  Variable widths are handled.
       and all C format specifications ending with one of diouxXfeEgGcs,  with
       \a     alert (BEL)
              $'' syntax.
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-125540/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'uname -r > linux-info.txt\n' "=========="
	test-14-actual 
	echo "=========" $'$ cat linux-info.txt | echoize | testnum | testuser\n# $ cat ~/.bashrc | echoize\nH.HH.H-HH-generic' "========="
	test-14-expected 
	echo "============================"
	# ???: 'uname -r > linux-info.txt\n'=$(test-14-actual)
	# ???: '$ cat linux-info.txt | echoize | testnum | testuser\n# $ cat ~/.bashrc | echoize\nH.HH.H-HH-generic'=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	uname -r > linux-info.txt

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ cat linux-info.txt | echoize | testnum | testuser
# $ cat ~/.bashrc | echoize
H.HH.H-HH-generic
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-125540/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat pf_manual.txt | para-sort | testnum | testuser\n' "=========="
	test-15-actual 
	echo "=========" $'%%     a single %' "========="
	test-15-expected 
	echo "============================"
	# ???: 'cat pf_manual.txt | para-sort | testnum | testuser\n'=$(test-15-actual)
	# ???: '%%     a single %'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	cat pf_manual.txt | para-sort | testnum | testuser

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
%%     a single %
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-125540/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'cat pf_manual.txt | echoize | head -n 5 | testuser | testnum\n' "=========="
	test-16-actual 
	echo "=========" $'PRINTF(H)                        User Commands                       PRINTF(H)' "========="
	test-16-expected 
	echo "============================"
	# ???: 'cat pf_manual.txt | echoize | head -n 5 | testuser | testnum\n'=$(test-16-actual)
	# ???: 'PRINTF(H)                        User Commands                       PRINTF(H)'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	cat pf_manual.txt | echoize | head -n 5 | testuser | testnum

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PRINTF(H)                        User Commands                       PRINTF(H)
END_EXPECTED
}
