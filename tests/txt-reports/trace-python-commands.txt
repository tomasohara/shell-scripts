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

	TMP=/tmp/test-py-commands
	actual=$(test2-assert2-actual)
	expected=$(test2-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert2-actual () {
	alias | wc -l
}
function test2-assert2-expected () {
	echo -e '0'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-7766
	cd "$temp_dir"
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	alias testuser="sed -r "s/"$USER"+/userxf333/g""
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

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
	show-python-path | testuser
}
function test8-assert1-expected () {
	echo -e 'PYTHONPATH:/home/userxf333/python'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	python-import-path 'mezcla' | testnum
	linebr
	python-import-path-full 'mezcla' | testnum
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
	python-import-path-all 'mezcla' | grep mezcla | head -n 5 | testnum
}
function test13-assert4-expected () {
	echo -e "matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py--------------------------------------------------------------------------------matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.pymatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.pymatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.pymatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/glue_helpers.pymatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/system.pymatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/tpo_common.py--------------------------------------------------------------------------------# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc'# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc'# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/sys_version_info_hack.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py"
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	actual=$(test14-assert2-actual)
	expected=$(test14-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert2-actual () {
	pip3 freeze | grep ipython | wc -l
}
function test14-assert2-expected () {
	echo -e '2'
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	python-module-version-full mezcla | testnum
	linebr
	python-module-version mezcla | testnum
	linebr
	python-package-members mezcla | testnum
	actual=$(test15-assert6-actual)
	expected=$(test15-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert6-actual () {
	linebr
}
function test15-assert6-expected () {
	echo -e "N.N.N--------------------------------------------------------------------------------N.N.N--------------------------------------------------------------------------------['PYTHONN_PLUS', 'TL', '__VERSION__', '__all__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', 'debug', 'gh', 'glue_helpers', 'mezcla', 'sys', 'sys_version_info_hack', 'system', 'tpo_common']--------------------------------------------------------------------------------"
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	pwd 
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
	ltc testless.txt | testnum
}
function test17-assert1-expected () {
	echo -e 'THIS IS THE HEADNNNNNNNTHIS IS THE TAIL.'
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
	less-tail testless.txt | testnum
}
function test18-assert1-expected () {
	echo -e 'THIS IS THE HEADNNNNNNNTHIS IS THE TAIL.'
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
	less-tail-clipped testless.txt | testnum
}
function test19-assert1-expected () {
	echo -e 'THIS IS THE HEADNNNNNNNTHIS IS THE TAIL.'
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
	less-clipped testless.txt | testnum
}
function test20-assert1-expected () {
	echo -e 'THIS IS THE HEADNNNNNNNTHIS IS THE TAIL.'
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
	less- testless.txt | testnum
}
function test21-assert1-expected () {
	echo -e 'THIS IS THE HEADNNNNNNNTHIS IS THE TAIL.'
}

@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	ipython --version | testuser | testnum
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	alias which-py3='which python3' 
}


@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	printf "print('THIS IS A TEST')" > atest.py
	printf "print('THIS IS A TEST')" > xyz.py
	actual=$(test24-assert4-actual)
	expected=$(test24-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test24-assert4-actual () {
	py-diff atest.py xyz.py | testuser | testnum | awk '!($6="")'
}
function test24-assert4-expected () {
	echo -e "Assuming implicit --no-glob, as otherwise  would be in extensionabcN.py vs. atest.py   Differences: abcN.py atest.py   -rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN abcN.py-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN atest.pyNcN     < print('THIS IS A TESTNN') \\ No newline at end  file---     > print('THIS IS A TEST') \\ No newline at end  file------------------------------------------------------------------------     "
}

@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	printf "print('THIS IS A TEST10')\nprint('THIS IS A TEST11')\nprint('THIS IS A TEST12')\nprint('THIS IS A TEST13')" > random_line_test.py
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
	randomize-datafile random_line_test.py
}
function test27-assert1-expected () {
	echo -e "print('THIS IS A TEST10')print('THIS IS A TEST10')print('THIS IS A TEST11')print('THIS IS A TEST12')/usr/bin/python: No module named randomize_lines"
}

@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	conditional-source $BIN_DIR/tests/_dir-aliases.bash
	touch file1
	ln-symbolic file1 link1
	linebr
}


@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

	curl-dump https://www.example.com/
	linebr
	ls -l | testnum | testuser | awk '!($6="")'
	linebr
}


@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

	pwd |  sed -r "s/"$USER"+/user/g"
}
