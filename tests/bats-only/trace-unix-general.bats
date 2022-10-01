#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
	echo "BIND ON!"
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test2-assert4-actual)
	expected=$(test2-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test2-assert4-expected () {
	echo -e '00'
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
	echo -e '0'
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
	echo -e '10'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	function ps-all () { 
	local pattern="$1";
	local pager=cat;
	if [ "$pattern" = "" ]; then 
	pattern="."; 
	pager=$PAGER
	fi;
	ps_mine.sh --all | $EGREP -i "((^USER)|($pattern))" | $pager;
	}
	alias ps-script='ps-all "\\bscript\\b" | $GREP -v "(gnome-session)"'
	function ps-sort-once { ps_sort.perl -num_times=1 -by=time "$@" -; }
	alias ps-sort-time='ps-sort-once -by=time'
	alias ps-time=ps-sort-time
	alias ps-sort-mem='ps-sort-once -by=mem '
	alias ps-mem=ps-sort-mem
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	alias ps-script='ps-all "\\bscript\\b" | $GREP -v "(gnome-session)"'
	function ps-sort-once { ps_sort.perl -num_times=1 -by=time "$@" -; }
	alias ps-sort-time='ps-sort-once -by=time'
	alias ps-time=ps-sort-time
	alias ps-sort-mem='ps-sort-once -by=mem '
	alias ps-mem=ps-sort-mem
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
	ps-sort-time
}
function test8-assert1-expected () {
	echo -e 'Error: bad sort field (time): using cpuUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey       1940 16.5 11.8 3559492 437112 ?      Ssl  18:45   2:21 /snap/firefaveey       4358 10.7  1.4 672904 51964 ?        Ssl  18:59   0:00 /usr/bin/pyaveey       3552  6.2  5.2 2544272 195016 ?      Sl   18:46   0:51 /snap/firefaveey       1347  2.7  6.6 25834536 246060 ?     Sl   18:35   0:39 /opt/Upworkroot         866  1.9  2.8 683152 104852 tty1    Ssl+ 18:33   0:31 /usr/lib/xoaveey       4112  1.9  4.7 2536612 176300 ?      Sl   18:54   0:06 /snap/firefaveey       4368  1.0  0.1  11480  5544 pts/1    Ss   18:59   0:00 /usr/bin/baaveey       3526  0.8  5.0 19460268 186388 ?     Sl   18:46   0:07 /snap/firefaveey       1247  0.7  4.5 4788200 168432 ?      Sl   18:35   0:11 /opt/Upworkaveey       1549  0.7  2.0 241692 74828 pts/0    Sl+  18:45   0:06 /usr/bin/pyaveey       1326  0.2  1.9 286020 71776 ?        Sl   18:35   0:03 /opt/Upworkroot           1  0.1  0.3 166312 11708 ?        Ss   18:32   0:01 /sbin/init root         694  0.1  1.0 1096492 37308 ?       Ssl  18:32   0:02 /usr/lib/snaveey       1072  0.1  2.8 1206800 105556 ?      Sl   18:33   0:02 /usr/bin/lxaveey       2437  0.1  3.6 2856908 133092 ?      Sl   18:45   0:01 /snap/firefaveey       3062  0.1  2.9 2449764 107740 ?      Sl   18:46   0:01 /snap/firefroot           2  0.0  0.0      0     0 ?        S    18:32   0:00 [kthreadd]root           3  0.0  0.0      0     0 ?        I<   18:32   0:00 [rcu_gp]root           4  0.0  0.0      0     0 ?        I<   18:32   0:00 [rcu_par_gproot           5  0.0  0.0      0     0 ?        I<   18:32   0:00 [netns]root           6  0.0  0.0      0     0 ?        I    18:32   0:00 [kworker/0:root           7  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/0:root           9  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/0:root          10  0.0  0.0      0     0 ?        I<   18:32   0:00 [mm_percpu_root          11  0.0  0.0      0     0 ?        S    18:32   0:00 [rcu_tasks_root          12  0.0  0.0      0     0 ?        S    18:32   0:00 [rcu_tasks_root          13  0.0  0.0      0     0 ?        S    18:32   0:00 [ksoftirqd/root          14  0.0  0.0      0     0 ?        I    18:32   0:00 [rcu_sched]root          15  0.0  0.0      0     0 ?        S    18:32   0:00 [migration/root          16  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injecroot          18  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/0]root          19  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/1]root          20  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injecroot          21  0.0  0.0      0     0 ?        S    18:32   0:00 [migration/root          22  0.0  0.0      0     0 ?        S    18:32   0:00 [ksoftirqd/root          24  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/1:root          25  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/2]root          26  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injec'
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
	ps-time
}
function test9-assert1-expected () {
	echo -e 'Error: bad sort field (time): using cpuUSER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey       1940 16.5 11.8 3559492 438160 ?      Ssl  18:45   2:21 /snap/firefaveey       4358 11.0  1.4 672904 52020 ?        Ssl  18:59   0:00 /usr/bin/pyaveey       3552  6.2  5.3 2545296 195620 ?      Sl   18:46   0:52 /snap/firefaveey       1347  2.7  6.6 25834536 246060 ?     Sl   18:35   0:39 /opt/Upworkroot         866  1.9  2.8 683152 104852 tty1    Ssl+ 18:33   0:31 /usr/lib/xoaveey       4112  1.9  4.7 2536612 176300 ?      Sl   18:54   0:06 /snap/firefaveey       4368  1.0  0.1  11480  5544 pts/1    Ss   18:59   0:00 /usr/bin/baaveey       3526  0.8  5.0 19460268 186388 ?     Sl   18:46   0:07 /snap/firefaveey       1247  0.7  4.5 4788200 168432 ?      Sl   18:35   0:11 /opt/Upworkaveey       1549  0.7  2.0 241692 74828 pts/0    Sl+  18:45   0:06 /usr/bin/pyaveey       1326  0.2  1.9 286020 71776 ?        Sl   18:35   0:03 /opt/Upworkroot           1  0.1  0.3 166312 11708 ?        Ss   18:32   0:01 /sbin/init root         694  0.1  1.0 1096492 37308 ?       Ssl  18:32   0:02 /usr/lib/snaveey       1072  0.1  2.8 1206800 105556 ?      Sl   18:33   0:02 /usr/bin/lxaveey       2437  0.1  3.6 2856908 133092 ?      Sl   18:45   0:01 /snap/firefaveey       3062  0.1  2.9 2449764 107740 ?      Sl   18:46   0:01 /snap/firefroot           2  0.0  0.0      0     0 ?        S    18:32   0:00 [kthreadd]root           3  0.0  0.0      0     0 ?        I<   18:32   0:00 [rcu_gp]root           4  0.0  0.0      0     0 ?        I<   18:32   0:00 [rcu_par_gproot           5  0.0  0.0      0     0 ?        I<   18:32   0:00 [netns]root           6  0.0  0.0      0     0 ?        I    18:32   0:00 [kworker/0:root           7  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/0:root           9  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/0:root          10  0.0  0.0      0     0 ?        I<   18:32   0:00 [mm_percpu_root          11  0.0  0.0      0     0 ?        S    18:32   0:00 [rcu_tasks_root          12  0.0  0.0      0     0 ?        S    18:32   0:00 [rcu_tasks_root          13  0.0  0.0      0     0 ?        S    18:32   0:00 [ksoftirqd/root          14  0.0  0.0      0     0 ?        I    18:32   0:00 [rcu_sched]root          15  0.0  0.0      0     0 ?        S    18:32   0:00 [migration/root          16  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injecroot          18  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/0]root          19  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/1]root          20  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injecroot          21  0.0  0.0      0     0 ?        S    18:32   0:00 [migration/root          22  0.0  0.0      0     0 ?        S    18:32   0:00 [ksoftirqd/root          24  0.0  0.0      0     0 ?        I<   18:32   0:00 [kworker/1:root          25  0.0  0.0      0     0 ?        S    18:32   0:00 [cpuhp/2]root          26  0.0  0.0      0     0 ?        S    18:32   0:00 [idle_injec'
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
	ps-sort-mem
}
function test10-assert1-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey       1940 16.5 11.9 3559492 438964 ?      Ssl  18:45   2:21 /snap/firefaveey       1347  2.7  6.6 25834536 246060 ?     Sl   18:35   0:39 /opt/Upworkaveey       3552  6.2  5.3 2546320 197116 ?      Sl   18:46   0:52 /snap/firefaveey       3526  0.8  5.0 19460268 186388 ?     Sl   18:46   0:07 /snap/firefaveey       4112  1.9  4.7 2536612 176300 ?      Sl   18:54   0:06 /snap/firefaveey       1247  0.7  4.5 4788200 168432 ?      Sl   18:35   0:11 /opt/Upworkaveey       2437  0.1  3.6 2856908 133092 ?      Sl   18:45   0:01 /snap/firefaveey       3062  0.1  2.9 2449764 107740 ?      Sl   18:46   0:01 /snap/firefroot         866  1.9  2.8 683152 104852 tty1    Ssl+ 18:33   0:31 /usr/lib/xoaveey       1072  0.1  2.8 1206800 105556 ?      Sl   18:33   0:02 /usr/bin/lxaveey       1068  0.0  2.7 861112 101196 ?       Sl   18:33   0:00 /usr/bin/pcaveey       1251  0.0  2.4 755944 90968 ?        Sl   18:35   0:01 xfce4-termiaveey       3014  0.0  2.4 2425852 90816 ?       Sl   18:46   0:00 /snap/firefaveey       1549  0.7  2.0 241692 74828 pts/0    Sl+  18:45   0:06 /usr/bin/pyaveey       1326  0.2  1.9 286020 71776 ?        Sl   18:35   0:03 /opt/Upworkaveey       1382  0.0  1.8 4504348 68472 ?       Sl   18:36   0:00 /opt/Upworkaveey       1402  0.0  1.8 4502300 68556 ?       Sl   18:36   0:00 /opt/Upworkaveey       1436  0.0  1.8 4502300 67268 ?       Sl   18:36   0:00 /opt/Upworkaveey       4192  0.0  1.7 2407188 65208 ?       Sl   18:55   0:00 /snap/firefaveey       4152  0.0  1.6 2407168 62396 ?       Sl   18:54   0:00 /snap/firefaveey       4228  0.0  1.6 2407188 62356 ?       Sl   18:56   0:00 /snap/firefaveey       1313  0.0  1.5 273840 58480 ?        Sl   18:35   0:01 /opt/Upworkaveey       1074  0.0  1.4 576624 51908 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1424  0.0  1.4 522836 54084 ?        Sl   18:36   0:00 /opt/Upworkaveey       4358 11.5  1.4 672904 52020 ?        Ssl  18:59   0:00 /usr/bin/pyaveey       1222  0.0  1.3 504148 47980 ?        Sl   18:34   0:00 /usr/bin/lxaveey       1249  0.0  1.2 207348 46536 ?        S    18:35   0:00 /opt/Upworkaveey       1250  0.0  1.2 207348 46756 ?        S    18:35   0:00 /opt/Upworkaveey       1000  0.0  1.1 336628 41616 ?        Sl   18:33   0:00 lxqt-sessioaveey       1071  0.0  1.1 275848 43160 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1073  0.0  1.1 410024 41912 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1224  0.0  1.1 271432 41880 ?        Sl   18:34   0:00 /usr/bin/qlaveey       1226  0.0  1.1 272668 42228 ?        Sl   18:34   0:00 /usr/bin/nmroot         694  0.1  1.0 1096492 37308 ?       Ssl  18:32   0:02 /usr/lib/snaveey       1069  0.0  1.0 336148 39240 ?        Sl   18:33   0:00 /usr/bin/lxaveey       2948  0.0  1.0 268112 40356 ?        Ssl  18:46   0:00 /usr/lib/x8aveey       2993  0.0  0.9 218728 36768 ?        Sl   18:46   0:00 /snap/firefaveey       3160  0.0  0.9 218712 34876 ?        Sl   18:46   0:00 /snap/firef'
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
	ps-mem
}
function test11-assert1-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDaveey       1940 16.5 11.8 3559492 437464 ?      Ssl  18:45   2:21 /snap/firefaveey       1347  2.7  7.1 25852196 263732 ?     Sl   18:35   0:39 /opt/Upworkaveey       3552  6.2  5.3 2547344 198488 ?      Sl   18:46   0:52 /snap/firefaveey       3526  0.8  5.0 19460268 186388 ?     Sl   18:46   0:07 /snap/firefaveey       4112  1.9  4.7 2536612 176300 ?      Sl   18:54   0:06 /snap/firefaveey       1247  0.7  4.5 4788200 168432 ?      Sl   18:35   0:11 /opt/Upworkaveey       2437  0.1  3.6 2856908 133092 ?      Sl   18:45   0:01 /snap/firefaveey       3062  0.1  2.9 2449764 107740 ?      Sl   18:46   0:01 /snap/firefroot         866  1.9  2.8 683152 104852 tty1    Ssl+ 18:33   0:31 /usr/lib/xoaveey       1072  0.1  2.8 1206800 105556 ?      Sl   18:33   0:02 /usr/bin/lxaveey       1068  0.0  2.7 861112 101196 ?       Sl   18:33   0:00 /usr/bin/pcaveey       1251  0.0  2.4 755944 90968 ?        Sl   18:35   0:01 xfce4-termiaveey       3014  0.0  2.4 2425852 90816 ?       Sl   18:46   0:00 /snap/firefaveey       1549  0.7  2.0 241692 74828 pts/0    Sl+  18:45   0:06 /usr/bin/pyaveey       1326  0.2  1.9 286020 71776 ?        Sl   18:35   0:03 /opt/Upworkaveey       1382  0.0  1.8 4504348 68472 ?       Sl   18:36   0:00 /opt/Upworkaveey       1402  0.0  1.8 4502300 68556 ?       Sl   18:36   0:00 /opt/Upworkaveey       1436  0.0  1.8 4502300 67268 ?       Sl   18:36   0:00 /opt/Upworkaveey       4192  0.0  1.7 2407188 65208 ?       Sl   18:55   0:00 /snap/firefaveey       4152  0.0  1.6 2407168 62396 ?       Sl   18:54   0:00 /snap/firefaveey       4228  0.0  1.6 2407188 62356 ?       Sl   18:56   0:00 /snap/firefaveey       1313  0.0  1.5 273840 58480 ?        Sl   18:35   0:01 /opt/Upworkaveey       1074  0.0  1.4 576624 51908 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1424  0.0  1.4 522836 54084 ?        Sl   18:36   0:00 /opt/Upworkaveey       4358 11.8  1.4 672904 52020 ?        Ssl  18:59   0:00 /usr/bin/pyaveey       1222  0.0  1.3 504148 47980 ?        Sl   18:34   0:00 /usr/bin/lxaveey       1249  0.0  1.2 207348 46536 ?        S    18:35   0:00 /opt/Upworkaveey       1250  0.0  1.2 207348 46756 ?        S    18:35   0:00 /opt/Upworkaveey       1000  0.0  1.1 336628 41616 ?        Sl   18:33   0:00 lxqt-sessioaveey       1071  0.0  1.1 275848 43160 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1073  0.0  1.1 410024 41912 ?        Sl   18:33   0:00 /usr/bin/lxaveey       1224  0.0  1.1 271432 41880 ?        Sl   18:34   0:00 /usr/bin/qlaveey       1226  0.0  1.1 272668 42228 ?        Sl   18:34   0:00 /usr/bin/nmroot         694  0.1  1.0 1096492 37308 ?       Ssl  18:32   0:02 /usr/lib/snaveey       1069  0.0  1.0 336148 39240 ?        Sl   18:33   0:00 /usr/bin/lxaveey       2948  0.0  1.0 268112 40356 ?        Ssl  18:46   0:00 /usr/lib/x8aveey       2993  0.0  0.9 218728 36768 ?        Sl   18:46   0:00 /snap/firefaveey       3160  0.0  0.9 218712 34876 ?        Sl   18:46   0:00 /snap/firef'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	function get-process-parent() { local pid="$1"; if [ "$pid" = "" ]; then pid=$$; fi; ps al | perl -Ssw extract_matches.perl "^\d+\s+\d+\s+$pid\s+(\d+)"; }
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	ps al | egrep "(PID|$$)"
	actual=$(test13-assert2-actual)
	expected=$(test13-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert2-actual () {
	get-process-parent
}
function test13-assert2-expected () {
	echo -e 'F   UID     PID    PPID PRI  NI    VSZ   RSS WCHAN  STAT TTY        TIME COMMAND0  1000    4368    4358  20   0  11480  5544 do_wai Ss   pts/1      0:00 /usr/bin/bash --rcfile /usr/lib/python3/dist-packages/pexpect/bashrc.sh4  1000    4424    4368  20   0  12668  1656 -      R+   pts/1      0:00 ps al0  1000    4425    4368  20   0   9076  2356 pipe_r S+   pts/1      0:00 grep -E (PID|4368)--------------------------------------------------------------------------------4358'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	function script {
	## THIS FUNCTION IS BUGGY
	## Note: set_xterm_title.bash keeps track of titles for each process, so save copies of current ones
	local save_full=$(set-xterm-title --print-full)
	local save_icon=$(set-xterm-title --print-icon)
	## DEBUG: echo "save_full='$save_full'; save_icon='$save_icon'"
	# Change prompt
	local old_PS_symbol="$PS_symbol"
	export SCRIPT_PID=$$
	# Note: the prompt change is flakey
	reset-prompt "$PS_symbol\$"
	## DEBUG: echo "script: 1. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
	# Change xterm title to match
	set-title-to-current-dir
	## DEBUG: echo "script: 2. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
	# Run command
	command script --append "$@"
	# Restore prompt
	unset SCRIPT_PID
	reset-prompt "$old_PS_symbol"
	## DEBUG: echo "script: 3. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
	# Get rid of lingering 'script' in xterm title
	## DEBUG: echo "Restoring xterm title: full=$save_full save=$save_icon"
	set-xterm-title "$save_full" "$save_icon"
	}
	alias script-update='script _update-$(T).log'
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	function ansi-filter {
	local input_file="$1"
	if [ "$input_file" = "" ]; then
	input_file="$TMP/ansi-filter-in-$$.list"
	cat > "$input_file"
	fi
	local output_file="$TMP/ansi-filter-out-$$.list";
	ansifilter --input="$input_file" --output="$output_file"
	cat "$output_file"
	}
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	echo "How to use the ansi-filter?" > ansi-filter-test.txt
	actual=$(test16-assert2-actual)
	expected=$(test16-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert2-actual () {
	ansi-filter ansi-filter-test.txt
}
function test16-assert2-expected () {
	echo -e 'How to use the ansi-filter?'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	function pause-for-enter () {
	local message="$1"
	if [ "$message" = "" ]; then message="Press enter to continue"; fi
	read -p "$message "
	}
}
