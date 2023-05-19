#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-139228/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-1-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g""' "========="
	test-1-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-1-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g""'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/N/g""
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-139228/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Hi Mom!"\n' "=========="
	test-3-actual 
	echo "=========" $'Hi Mom!' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo "Hi Mom!"\n'=$(test-3-actual)
	# ???: 'Hi Mom!'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo "Hi Mom!"

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Hi Mom!
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-139228/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"echo 'Hello world' | wc -l\n" "=========="
	test-4-actual 
	echo "=========" $'1' "========="
	test-4-expected 
	echo "============================"
	# ???: "echo 'Hello world' | wc -l\n"=$(test-4-actual)
	# ???: '1'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	echo 'Hello world' | wc -l

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-139228/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd | testuser\n' "=========="
	test-5-actual 
	echo "=========" $'/home/userxf333/tom-project/shell-scripts/tests' "========="
	test-5-expected 
	echo "============================"
	# ???: 'pwd | testuser\n'=$(test-5-actual)
	# ???: '/home/userxf333/tom-project/shell-scripts/tests'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	pwd | testuser

}

function test-5-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/home/userxf333/tom-project/shell-scripts/tests
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-139228/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'which systemd\n' "=========="
	test-6-actual 
	echo "=========" $'/usr/bin/systemd' "========="
	test-6-expected 
	echo "============================"
	# ???: 'which systemd\n'=$(test-6-actual)
	# ???: '/usr/bin/systemd'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	which systemd

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
/usr/bin/systemd
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-139228/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'man date | head -n 10 | testnum\n' "=========="
	test-7-actual 
	echo "=========" $'DATE(N)                          User Commands                         DATE(N)' "========="
	test-7-expected 
	echo "============================"
	# ???: 'man date | head -n 10 | testnum\n'=$(test-7-actual)
	# ???: 'DATE(N)                          User Commands                         DATE(N)'=$(test-7-expected)
	[ "$(test-7-actual)" == "$(test-7-expected)" ]
}

function test-7-actual () {
	# no-op in case content just a comment
	true

	man date | head -n 10 | testnum

}

function test-7-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
DATE(N)                          User Commands                         DATE(N)
END_EXPECTED
}


@test "test-8" {
	testfolder="/tmp/batspp-139228/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps -l | awk \'!($3=$4=$5=$10=$13="")\' | testnum\n' "=========="
	test-8-actual 
	echo "=========" $'F S    C PRI NI ADDR  WCHAN TTY  CMD\nN S    N NN N -  do_wai pts/N  bash\nN R    N NN N -  - pts/N  ps\nN S    N NN N -  pipe_r pts/N  awk\nN S    N NN N -  pipe_r pts/N  sed' "========="
	test-8-expected 
	echo "============================"
	# ???: 'ps -l | awk \'!($3=$4=$5=$10=$13="")\' | testnum\n'=$(test-8-actual)
	# ???: 'F S    C PRI NI ADDR  WCHAN TTY  CMD\nN S    N NN N -  do_wai pts/N  bash\nN R    N NN N -  - pts/N  ps\nN S    N NN N -  pipe_r pts/N  awk\nN S    N NN N -  pipe_r pts/N  sed'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	ps -l | awk '!($3=$4=$5=$10=$13="")' | testnum

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
F S    C PRI NI ADDR  WCHAN TTY  CMD
N S    N NN N -  do_wai pts/N  bash
N R    N NN N -  - pts/N  ps
N S    N NN N -  pipe_r pts/N  awk
N S    N NN N -  pipe_r pts/N  sed
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-139228/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps | head -n 10 | testuser | testnum\n' "=========="
	test-9-actual 
	echo "=========" $'PID TTY          TIME CMD\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN ps\n  NNNNN pts/N    NN:NN:NN head\n  NNNNN pts/N    NN:NN:NN sed\n  NNNNN pts/N    NN:NN:NN sed' "========="
	test-9-expected 
	echo "============================"
	# ???: 'ps | head -n 10 | testuser | testnum\n'=$(test-9-actual)
	# ???: 'PID TTY          TIME CMD\n  NNNNN pts/N    NN:NN:NN bash\n  NNNNN pts/N    NN:NN:NN ps\n  NNNNN pts/N    NN:NN:NN head\n  NNNNN pts/N    NN:NN:NN sed\n  NNNNN pts/N    NN:NN:NN sed'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	ps | head -n 10 | testuser | testnum

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PID TTY          TIME CMD
  NNNNN pts/N    NN:NN:NN bash
  NNNNN pts/N    NN:NN:NN ps
  NNNNN pts/N    NN:NN:NN head
  NNNNN pts/N    NN:NN:NN sed
  NNNNN pts/N    NN:NN:NN sed
END_EXPECTED
}
