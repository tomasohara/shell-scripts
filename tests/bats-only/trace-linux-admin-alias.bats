#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-127412/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ jupyter notebook --allow-root\n' "=========="
	test-1-actual 
	echo "=========" $"## Bracketed Paste is disabled to prevent characters after output\n## Example: \n# $ echo 'Hi'\n# | Hi?2004l\n# bind 'set enable-bracketed-paste off'" "========="
	test-1-expected 
	echo "============================"
	# ???: '# $ jupyter notebook --allow-root\n'=$(test-1-actual)
	# ???: "## Bracketed Paste is disabled to prevent characters after output\n## Example: \n# $ echo 'Hi'\n# | Hi?2004l\n# bind 'set enable-bracketed-paste off'"=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true


}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## Bracketed Paste is disabled to prevent characters after output
## Example: 
# $ echo 'Hi'
# | Hi?2004l
# bind 'set enable-bracketed-paste off'
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-127412/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo $PS1\n' "=========="
	test-3-actual 
	echo "=========" $'[PEXP\\[\\]ECT_PROMPT>' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo $PS1\n'=$(test-3-actual)
	# ???: '[PEXP\\[\\]ECT_PROMPT>'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo $PS1

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
[PEXP\[\]ECT_PROMPT>
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-127412/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'unalias -a\n' "=========="
	test-4-actual 
	echo "=========" $"$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0" "========="
	test-4-expected 
	echo "============================"
	# ???: 'unalias -a\n'=$(test-4-actual)
	# ???: "$ alias | wc -l\n$ for f in $(typeset -f | egrep '^\\w+'); do unset -f $f; done\n$ typeset -f | egrep '^\\w+' | wc -l\n0\n0"=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	unalias -a

}

function test-4-expected () {
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


@test "test-5" {
	testfolder="/tmp/batspp-127412/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-5-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g""' "========="
	test-5-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-5-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g""'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/N/g""
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-127412/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-admin-commands\n' "=========="
	test-6-actual 
	echo "=========" $'## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2' "========="
	test-6-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-admin-commands\n'=$(test-6-actual)
	# ???: '## NOTE: Source it directly from the ./tests directory.\n$ BIN_DIR=$PWD/..\n$ alias | wc -l\n2'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-admin-commands

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
## NOTE: Source it directly from the ./tests directory.
$ BIN_DIR=$PWD/..
$ alias | wc -l
2
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-127412/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-3245\n' "=========="
	test-7-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-admin-commands/test-3245' "========="
	test-7-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-3245\n'=$(test-7-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-admin-commands/test-3245'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-3245

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ mkdir -p "$temp_dir"
# TODO: /bin/rm -rvf "$temp_dir"
$ cd "$temp_dir"
$ pwd
#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)
$ alias linebr="printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"
/tmp/test-admin-commands/test-3245
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-127412/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias | wc -l\n' "=========="
	test-8-actual 
	echo "=========" $"# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0" "========="
	test-8-expected 
	echo "============================"
	# ???: 'alias | wc -l\n'=$(test-8-actual)
	# ???: "# Count functions\n$ typeset -f | egrep '^\\w+' | wc -l\n3\n0"=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	alias | wc -l

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Count functions
$ typeset -f | egrep '^\w+' | wc -l
3
0
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-127412/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'source $BIN_DIR/tomohara-aliases.bash\n' "=========="
	test-9-actual 
	echo "=========" $'' "========="
	test-9-expected 
	echo "============================"
	# ???: 'source $BIN_DIR/tomohara-aliases.bash\n'=$(test-9-actual)
	# ???: ''=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	source $BIN_DIR/tomohara-aliases.bash

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-127412/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias apt-install='apt-get install --yes --fix-missing --no-remove'\n" "=========="
	test-10-actual 
	echo "=========" $"$ alias apt-search='apt-cache search'\n$ alias apt-installed='apt list --installed'\n$ alias apt-uninstall='apt-get remove'\n$ alias dpkg-install='dpkg --install '" "========="
	test-10-expected 
	echo "============================"
	# ???: "alias apt-install='apt-get install --yes --fix-missing --no-remove'\n"=$(test-10-actual)
	# ???: "$ alias apt-search='apt-cache search'\n$ alias apt-installed='apt list --installed'\n$ alias apt-uninstall='apt-get remove'\n$ alias dpkg-install='dpkg --install '"=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	alias apt-install='apt-get install --yes --fix-missing --no-remove'

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias apt-search='apt-cache search'
$ alias apt-installed='apt list --installed'
$ alias apt-uninstall='apt-get remove'
$ alias dpkg-install='dpkg --install '
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-127412/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'apt-installed *python3* | grep ipython | cut -d \\/ -f 1 | testnum\n' "=========="
	test-11-actual 
	echo "=========" $'' "========="
	test-11-expected 
	echo "============================"
	# ???: 'apt-installed *python3* | grep ipython | cut -d \\/ -f 1 | testnum\n'=$(test-11-actual)
	# ???: ''=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	apt-installed *python3* | grep ipython | cut -d \/ -f 1 | testnum

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-127412/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'apt-search rolldice\n' "=========="
	test-12-actual 
	echo "=========" $'rolldice - virtual dice roller' "========="
	test-12-expected 
	echo "============================"
	# ???: 'apt-search rolldice\n'=$(test-12-actual)
	# ???: 'rolldice - virtual dice roller'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	apt-search rolldice

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
rolldice - virtual dice roller
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-127412/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'apt-installed | grep acpi | wc -l\n' "=========="
	test-13-actual 
	echo "=========" $'' "========="
	test-13-expected 
	echo "============================"
	# ???: 'apt-installed | grep acpi | wc -l\n'=$(test-13-actual)
	# ???: ''=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	apt-installed | grep acpi | wc -l

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-127412/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ apt-uninstall rolldice\n' "=========="
	test-14-actual 
	echo "=========" $'# | E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)\n# | E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?' "========="
	test-14-expected 
	echo "============================"
	# ???: '# $ apt-uninstall rolldice\n'=$(test-14-actual)
	# ???: '# | E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)\n# | E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?'=$(test-14-expected)
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
# | E: Could not open lock file /var/lib/dpkg/lock-frontend - open (13: Permission denied)
# | E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), are you root?
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-127412/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ dpkg-install rolldice\n' "=========="
	test-15-actual 
	echo "=========" $'# | dpkg: error: requested operation requires superuser privilege' "========="
	test-15-expected 
	echo "============================"
	# ???: '# $ dpkg-install rolldice\n'=$(test-15-actual)
	# ???: '# | dpkg: error: requested operation requires superuser privilege'=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true


}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | dpkg: error: requested operation requires superuser privilege
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-127412/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"alias start-service='systemctl start'\n" "=========="
	test-16-actual 
	echo "=========" $"$ alias list-all-service='systemctl --type=service'\n$ alias restart-service-sudoless='systemctl restart'\n$ alias status-service='systemctl status'\n$ alias service-status='status-service'" "========="
	test-16-expected 
	echo "============================"
	# ???: "alias start-service='systemctl start'\n"=$(test-16-actual)
	# ???: "$ alias list-all-service='systemctl --type=service'\n$ alias restart-service-sudoless='systemctl restart'\n$ alias status-service='systemctl status'\n$ alias service-status='status-service'"=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	alias start-service='systemctl start'

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias list-all-service='systemctl --type=service'
$ alias restart-service-sudoless='systemctl restart'
$ alias status-service='systemctl status'
$ alias service-status='status-service'
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-127412/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'list-all-service | grep ufw\n' "=========="
	test-17-actual 
	echo "=========" $'ufw.service                                           loaded active exited  Uncomplicated firewall' "========="
	test-17-expected 
	echo "============================"
	# ???: 'list-all-service | grep ufw\n'=$(test-17-actual)
	# ???: 'ufw.service                                           loaded active exited  Uncomplicated firewall'=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	list-all-service | grep ufw

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
ufw.service                                           loaded active exited  Uncomplicated firewall
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-127412/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'stop-service unattended-upgrades\n' "=========="
	test-18-actual 
	echo "=========" $'# service-status OR status-service VIEWS STATUS OF THE SERVICE\n# status-service unattended-upgrades \n# # commented - tests halts after completion' "========="
	test-18-expected 
	echo "============================"
	# ???: 'stop-service unattended-upgrades\n'=$(test-18-actual)
	# ???: '# service-status OR status-service VIEWS STATUS OF THE SERVICE\n# status-service unattended-upgrades \n# # commented - tests halts after completion'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	stop-service unattended-upgrades

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# service-status OR status-service VIEWS STATUS OF THE SERVICE
# status-service unattended-upgrades 
# # commented - tests halts after completion
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-127412/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'start-service unattended-upgrades\n' "=========="
	test-19-actual 
	echo "=========" $'# service-status OR status-service VIEWS STATUS OF THE SERVICE\n$ service-status unattended-upgrades | head -n 1\n● unattended-upgrades.service - Unattended Upgrades Shutdown' "========="
	test-19-expected 
	echo "============================"
	# ???: 'start-service unattended-upgrades\n'=$(test-19-actual)
	# ???: '# service-status OR status-service VIEWS STATUS OF THE SERVICE\n$ service-status unattended-upgrades | head -n 1\n● unattended-upgrades.service - Unattended Upgrades Shutdown'=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	start-service unattended-upgrades

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# service-status OR status-service VIEWS STATUS OF THE SERVICE
$ service-status unattended-upgrades | head -n 1
● unattended-upgrades.service - Unattended Upgrades Shutdown
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-127412/test-20"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'restart-service-sudoless unattended-upgrades\n' "=========="
	test-20-actual 
	echo "=========" $'# service-status OR status-service VIEWS STATUS OF THE SERVICE\n$ service-status unattended-upgrades | grep Active | cut -d \\s -f 1\n# requires password but tests completes after (check need for batspp)\n     Active: active (running)' "========="
	test-20-expected 
	echo "============================"
	# ???: 'restart-service-sudoless unattended-upgrades\n'=$(test-20-actual)
	# ???: '# service-status OR status-service VIEWS STATUS OF THE SERVICE\n$ service-status unattended-upgrades | grep Active | cut -d \\s -f 1\n# requires password but tests completes after (check need for batspp)\n     Active: active (running)'=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	restart-service-sudoless unattended-upgrades

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# service-status OR status-service VIEWS STATUS OF THE SERVICE
$ service-status unattended-upgrades | grep Active | cut -d \s -f 1
# requires password but tests completes after (check need for batspp)
     Active: active (running)
END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-127412/test-21"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd\n' "=========="
	test-21-actual 
	echo "=========" $'/tmp/test-admin-commands/test-3245' "========="
	test-21-expected 
	echo "============================"
	# ???: 'pwd\n'=$(test-21-actual)
	# ???: '/tmp/test-admin-commands/test-3245'=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	pwd

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/tmp/test-admin-commands/test-3245
END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-127412/test-22"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "HELLO THERE,\\nI AM EXTREMELY PLEASED TO USE UBUNTU." >> abc.txt\n' "=========="
	test-22-actual 
	echo "=========" $'$ get-free-filename "abc.txt" 2      #DOUBT(?)\n$ linebr\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ cat "abc.txt"\nabc.txt22\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN abc.txt\n--------------------------------------------------------------------------------\nHELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.' "========="
	test-22-expected 
	echo "============================"
	# ???: 'printf "HELLO THERE,\\nI AM EXTREMELY PLEASED TO USE UBUNTU." >> abc.txt\n'=$(test-22-actual)
	# ???: '$ get-free-filename "abc.txt" 2      #DOUBT(?)\n$ linebr\n$ ls -l | awk \'!($6="")\' | testnum | testuser\n$ linebr\n$ cat "abc.txt"\nabc.txt22\n--------------------------------------------------------------------------------\ntotal N    \n-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN abc.txt\n--------------------------------------------------------------------------------\nHELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU.'=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true

	printf "HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU." >> abc.txt

}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ get-free-filename "abc.txt" 2      #DOUBT(?)
$ linebr
$ ls -l | awk '!($6="")' | testnum | testuser
$ linebr
$ cat "abc.txt"
abc.txt22
--------------------------------------------------------------------------------
total N    
-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN abc.txt
--------------------------------------------------------------------------------
HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,
I AM EXTREMELY PLEASED TO USE UBUNTU.
END_EXPECTED
}


@test "test-23" {
	testfolder="/tmp/batspp-127412/test-23"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'sync2\n' "=========="
	test-23-actual 
	echo "=========" $'' "========="
	test-23-expected 
	echo "============================"
	# ???: 'sync2\n'=$(test-23-actual)
	# ???: ''=$(test-23-expected)
	[ "$(test-23-actual)" == "$(test-23-expected)" ]
}

function test-23-actual () {
	# no-op in case content just a comment
	true

	sync2

}

function test-23-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-24" {
	testfolder="/tmp/batspp-127412/test-24"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'fix-sudoer-home-permission\n' "=========="
	test-24-actual 
	echo "=========" $'Warning: no sudo user for current shell' "========="
	test-24-expected 
	echo "============================"
	# ???: 'fix-sudoer-home-permission\n'=$(test-24-actual)
	# ???: 'Warning: no sudo user for current shell'=$(test-24-expected)
	[ "$(test-24-actual)" == "$(test-24-expected)" ]
}

function test-24-actual () {
	# no-op in case content just a comment
	true

	fix-sudoer-home-permission

}

function test-24-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Warning: no sudo user for current shell
END_EXPECTED
=======
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

	alias testuser="sed -r "s/"$USER"+/userxf333/g""
	alias testnum="sed -r "s/[0-9]/N/g"" 
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
	echo -e '2'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3245
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
	echo -e '30'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	alias apt-install='apt-get install --yes --fix-missing --no-remove'
	alias apt-search='apt-cache search'
	alias apt-installed='apt list --installed'
	alias apt-uninstall='apt-get remove'
	alias dpkg-install='dpkg --install '
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	apt-installed *python3* | grep ipython | cut -d \/ -f 1 | testnum
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
	apt-search rolldice
}
function test9-assert1-expected () {
	echo -e 'rolldice - virtual dice roller'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	apt-installed | grep acpi | wc -l
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	alias start-service='systemctl start'
	alias list-all-service='systemctl --type=service'
	alias restart-service-sudoless='systemctl restart'
	alias status-service='systemctl status'
	alias service-status='status-service'
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
	list-all-service | grep ufw
}
function test12-assert1-expected () {
	echo -e 'ufw.service                                           loaded active exited  Uncomplicated firewall'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	printf "HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU." >> abc.txt
	get-free-filename "abc.txt" 2      #DOUBT(?)
	linebr
	ls -l | awk '!($6="")' | testnum | testuser
	linebr
	actual=$(test17-assert6-actual)
	expected=$(test17-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert6-actual () {
	cat "abc.txt"
}
function test17-assert6-expected () {
	echo -e 'abc.txt22--------------------------------------------------------------------------------total N    -rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN abc.txt--------------------------------------------------------------------------------HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	sync2
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test19-assert1-actual)
	expected=$(test19-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test19-assert1-actual () {
	fix-sudoer-home-permission
}
function test19-assert1-expected () {
	echo -e 'Warning: no sudo user for current shell'
>>>>>>> integration-testing-3fa2c13
}
