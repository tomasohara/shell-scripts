#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-160636/test-1"
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
	testfolder="/tmp/batspp-160636/test-3"
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
	testfolder="/tmp/batspp-160636/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'TMP=/tmp/test-py-commands\n' "=========="
	test-4-actual 
	echo "=========" $'$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n## source $TEMP_BIN/_dir-aliases.bash\n$ alias | wc -l\n0' "========="
	test-4-expected 
	echo "============================"
	# ???: 'TMP=/tmp/test-py-commands\n'=$(test-4-actual)
	# ???: '$ BIN_DIR=$PWD/..\n## You will need to run jupyter from that directory.\n## source $TEMP_BIN/_dir-aliases.bash\n$ alias | wc -l\n0'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	TMP=/tmp/test-py-commands

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ BIN_DIR=$PWD/..
## You will need to run jupyter from that directory.
## source $TEMP_BIN/_dir-aliases.bash
$ alias | wc -l
0
END_EXPECTED
}


@test "test-5" {
	testfolder="/tmp/batspp-160636/test-5"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'temp_dir=$TMP/test-7766\n' "=========="
	test-5-actual 
	echo "=========" $'$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-py-commands/test-7766' "========="
	test-5-expected 
	echo "============================"
	# ???: 'temp_dir=$TMP/test-7766\n'=$(test-5-actual)
	# ???: '$ mkdir -p "$temp_dir"\n# TODO: /bin/rm -rvf "$temp_dir"\n$ cd "$temp_dir"\n$ pwd\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\n$ alias linebr="printf \'%*s\\n\' "${COLUMNS:-$(tput cols)}" \'\' | tr \' \' -"\n/tmp/test-py-commands/test-7766'=$(test-5-expected)
	[ "$(test-5-actual)" == "$(test-5-expected)" ]
}

function test-5-actual () {
	# no-op in case content just a comment
	true

	temp_dir=$TMP/test-7766

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
/tmp/test-py-commands/test-7766
END_EXPECTED
}


@test "test-6" {
	testfolder="/tmp/batspp-160636/test-6"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n' "=========="
	test-6-actual 
	echo "=========" $'$ alias testnum="sed -r "s/[0-9]/N/g""\n# alias testmonth="sed -r "s/[\'Jan\',\'Feb\',\'Mar\',\'Apr\',\'May\',\'Jun\',\'Jul\',\'Aug\',\'Sep\',\'Oct\',\'Nov\',\'Dec\']/M/g""' "========="
	test-6-expected 
	echo "============================"
	# ???: 'alias testuser="sed -r "s/"$USER"+/userxf333/g""\n'=$(test-6-actual)
	# ???: '$ alias testnum="sed -r "s/[0-9]/N/g""\n# alias testmonth="sed -r "s/[\'Jan\',\'Feb\',\'Mar\',\'Apr\',\'May\',\'Jun\',\'Jul\',\'Aug\',\'Sep\',\'Oct\',\'Nov\',\'Dec\']/M/g""'=$(test-6-expected)
	[ "$(test-6-actual)" == "$(test-6-expected)" ]
}

function test-6-actual () {
	# no-op in case content just a comment
	true

	alias testuser="sed -r "s/"$USER"+/userxf333/g""

}

function test-6-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ alias testnum="sed -r "s/[0-9]/N/g""
# alias testmonth="sed -r "s/['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']/M/g""
END_EXPECTED
}


@test "test-7" {
	testfolder="/tmp/batspp-160636/test-7"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

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
	testfolder="/tmp/batspp-160636/test-8"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-python-full | wc -l | testnum\n' "=========="
	test-8-actual 
	echo "=========" $'# Sample Output: 23\nNN' "========="
	test-8-expected 
	echo "============================"
	# ???: 'ps-python-full | wc -l | testnum\n'=$(test-8-actual)
	# ???: '# Sample Output: 23\nNN'=$(test-8-expected)
	[ "$(test-8-actual)" == "$(test-8-expected)" ]
}

function test-8-actual () {
	# no-op in case content just a comment
	true

	ps-python-full | wc -l | testnum

}

function test-8-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Sample Output: 23
NN
END_EXPECTED
}


@test "test-9" {
	testfolder="/tmp/batspp-160636/test-9"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ps-python | wc -l | testnum\n' "=========="
	test-9-actual 
	echo "=========" $'# Sample Output: 22\nNN' "========="
	test-9-expected 
	echo "============================"
	# ???: 'ps-python | wc -l | testnum\n'=$(test-9-actual)
	# ???: '# Sample Output: 22\nNN'=$(test-9-expected)
	[ "$(test-9-actual)" == "$(test-9-expected)" ]
}

function test-9-actual () {
	# no-op in case content just a comment
	true

	ps-python | wc -l | testnum

}

function test-9-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# Sample Output: 22
NN
END_EXPECTED
}


@test "test-10" {
	testfolder="/tmp/batspp-160636/test-10"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'show-python-path | testuser\n' "=========="
	test-10-actual 
	echo "=========" $'PYTHONPATH:\n/home/userxf333/python' "========="
	test-10-expected 
	echo "============================"
	# ???: 'show-python-path | testuser\n'=$(test-10-actual)
	# ???: 'PYTHONPATH:\n/home/userxf333/python'=$(test-10-expected)
	[ "$(test-10-actual)" == "$(test-10-expected)" ]
}

function test-10-actual () {
	# no-op in case content just a comment
	true

	show-python-path | testuser

}

function test-10-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
PYTHONPATH:
/home/userxf333/python
END_EXPECTED
}


@test "test-11" {
	testfolder="/tmp/batspp-160636/test-11"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'python-lint os | testnum | testuser\n' "=========="
	test-11-actual 
	echo "=========" $'************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)' "========="
	test-11-expected 
	echo "============================"
	# ???: 'python-lint os | testnum | testuser\n'=$(test-11-actual)
	# ???: '************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)'=$(test-11-expected)
	[ "$(test-11-actual)" == "$(test-11-expected)" ]
}

function test-11-actual () {
	# no-op in case content just a comment
	true

	python-lint os | testnum | testuser

}

function test-11-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
************* Module os
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in 'open' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in 'str' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'error' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in 'dir' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter 'default' has been renamed to 'value' in overridden '_Environ.setdefault' method (arguments-renamed)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsencode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsdecode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable 'wpid' (unused-variable)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the 'from' keyword (raise-missing-from)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name 'nt' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)
END_EXPECTED
}


@test "test-12" {
	testfolder="/tmp/batspp-160636/test-12"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'python-lint-work os | testnum\n' "=========="
	test-12-actual 
	echo "=========" $'************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed at the top of the module (wrong-import-position)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import "from _collections_abc import MutableMapping, Mapping" should be placed at the top of the module (wrong-import-position)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: No exception type(s) specified (bare-except)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:NN: RNNNN: Consider using \'with\' for resource-allocating operations (consider-using-with)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Keyword argument before variable positional arguments list in the definition of fdopen function (keyword-arg-before-vararg)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: standard import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed before "from _collections_abc import _check_methods" (wrong-import-order)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)' "========="
	test-12-expected 
	echo "============================"
	# ???: 'python-lint-work os | testnum\n'=$(test-12-actual)
	# ???: '************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed at the top of the module (wrong-import-position)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import "from _collections_abc import MutableMapping, Mapping" should be placed at the top of the module (wrong-import-position)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: No exception type(s) specified (bare-except)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:NN: RNNNN: Consider using \'with\' for resource-allocating operations (consider-using-with)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Keyword argument before variable positional arguments list in the definition of fdopen function (keyword-arg-before-vararg)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: standard import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed before "from _collections_abc import _check_methods" (wrong-import-order)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)'=$(test-12-expected)
	[ "$(test-12-actual)" == "$(test-12-expected)" ]
}

function test-12-actual () {
	# no-op in case content just a comment
	true

	python-lint-work os | testnum

}

function test-12-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
************* Module os
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in 'open' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed at the top of the module (wrong-import-position)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in 'str' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'error' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in 'dir' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import "from _collections_abc import MutableMapping, Mapping" should be placed at the top of the module (wrong-import-position)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter 'default' has been renamed to 'value' in overridden '_Environ.setdefault' method (arguments-renamed)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsencode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsdecode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: No exception type(s) specified (bare-except)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable 'wpid' (unused-variable)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:NN: RNNNN: Consider using 'with' for resource-allocating operations (consider-using-with)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Keyword argument before variable positional arguments list in the definition of fdopen function (keyword-arg-before-vararg)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the 'from' keyword (raise-missing-from)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name 'nt' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: standard import "from os.path import curdir, pardir, sep, pathsep, defpath, extsep, altsep, devnull" should be placed before "from _collections_abc import _check_methods" (wrong-import-order)
/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)
END_EXPECTED
}


@test "test-13" {
	testfolder="/tmp/batspp-160636/test-13"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'python-lint os | testnum\n' "=========="
	test-13-actual 
	echo "=========" $'************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)' "========="
	test-13-expected 
	echo "============================"
	# ???: 'python-lint os | testnum\n'=$(test-13-actual)
	# ???: '************* Module os\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in \'open\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in \'str\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'error\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in \'dir\' (redefined-builtin)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter \'default\' has been renamed to \'value\' in overridden \'_Environ.setdefault\' method (arguments-renamed)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsencode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name \'fsdecode\' from outer scope (line NNN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)\n/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable \'wpid\' (unused-variable)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'name\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the \'from\' keyword (raise-missing-from)\n/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name \'path\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name \'nt\' from outer scope (line NN) (redefined-outer-name)\n/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)\n/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import \'nt\' (import-error)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)\n/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)\n/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)\n/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)'=$(test-13-expected)
	[ "$(test-13-actual)" == "$(test-13-expected)" ]
}

function test-13-actual () {
	# no-op in case content just a comment
	true

	python-lint os | testnum

}

function test-13-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
************* Module os
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Redefining built-in 'open' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import posix (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Wildcard import nt (wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining built-in 'str' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'error' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining built-in 'dir' (redefined-builtin)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (warnings) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Parameter 'default' has been renamed to 'value' in overridden '_Environ.setdefault' method (arguments-renamed)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Access to a protected member _data of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsencode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Redefining name 'fsdecode' from outer scope (line NNN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Either all return statements in a function should return an expression, or none of them should. (inconsistent-return-statements)
/usr/lib/pythonN.NN/os.py:NNN:NN: WNNNN: Unused variable 'wpid' (unused-variable)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Import outside toplevel (subprocess, io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Multiple imports on one line (subprocess, io) (multiple-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNN:N: WNNNN: Unused import io (unused-import)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'name' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (io) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Using open without explicitly specifying an encoding (unspecified-encoding)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "raise" (no-else-raise)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Consider explicitly re-raising using the 'from' keyword (raise-missing-from)
/usr/lib/pythonN.NN/os.py:NNNN:N: RNNNN: Unnecessary "else" after "return" (no-else-return)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Missing function or method docstring (missing-function-docstring)
/usr/lib/pythonN.NN/os.py:NNNN:NN: CNNNN: Formatting a regular string which could be a f-string (consider-using-f-string)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Redefining name 'path' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: WNNNN: Redefining name 'nt' from outer scope (line NN) (redefined-outer-name)
/usr/lib/pythonN.NN/os.py:NNNN:N: CNNNN: Import outside toplevel (nt) (import-outside-toplevel)
/usr/lib/pythonN.NN/os.py:NNNN:N: ENNNN: Unable to import 'nt' (import-error)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _add_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NNNN:NN: WNNNN: Access to a protected member _remove_dll_directory of a client class (protected-access)
/usr/lib/pythonN.NN/os.py:NN:N: WNNNN: Unused import(s) CLD_CONTINUED, CLD_DUMPED, CLD_EXITED, CLD_KILLED, CLD_STOPPED, CLD_TRAPPED, DirEntry, EFD_CLOEXEC, EFD_NONBLOCK, EFD_SEMAPHORE, EX_CANTCREAT, EX_CONFIG, EX_DATAERR, EX_IOERR, EX_NOHOST, EX_NOINPUT, EX_NOPERM, EX_NOUSER, EX_OK, EX_OSERR, EX_OSFILE, EX_PROTOCOL, EX_SOFTWARE, EX_TEMPFAIL, EX_UNAVAILABLE, EX_USAGE, F_LOCK, F_OK, F_TEST, F_TLOCK, F_ULOCK, GRND_NONBLOCK, GRND_RANDOM, MFD_ALLOW_SEALING, MFD_CLOEXEC, MFD_HUGETLB, MFD_HUGE_NNGB, MFD_HUGE_NNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNNMB, MFD_HUGE_NGB, MFD_HUGE_NMB, MFD_HUGE_NNMB, MFD_HUGE_NNNKB, MFD_HUGE_NNNMB, MFD_HUGE_NNKB, MFD_HUGE_NMB, MFD_HUGE_MASK, MFD_HUGE_SHIFT, NGROUPS_MAX, O_ACCMODE, O_APPEND, O_ASYNC, O_CLOEXEC, O_CREAT, O_DIRECT, O_DIRECTORY, O_DSYNC, O_EXCL, O_FSYNC, O_LARGEFILE, O_NDELAY, O_NOATIME, O_NOCTTY, O_NOFOLLOW, O_NONBLOCK, O_PATH, O_RDWR, O_RSYNC, O_SYNC, O_TMPFILE, O_TRUNC, O_WRONLY, POSIX_FADV_DONTNEED, POSIX_FADV_NOREUSE, POSIX_FADV_NORMAL, POSIX_FADV_RANDOM, POSIX_FADV_SEQUENTIAL, POSIX_FADV_WILLNEED, POSIX_SPAWN_CLOSE, POSIX_SPAWN_DUPN, POSIX_SPAWN_OPEN, PRIO_PGRP, PRIO_PROCESS, PRIO_USER, P_ALL, P_PGID, P_PID, P_PIDFD, RTLD_DEEPBIND, RTLD_GLOBAL, RTLD_LAZY, RTLD_LOCAL, RTLD_NODELETE, RTLD_NOLOAD, RTLD_NOW, RWF_APPEND, RWF_DSYNC, RWF_HIPRI, RWF_NOWAIT, RWF_SYNC, R_OK, SCHED_BATCH, SCHED_FIFO, SCHED_IDLE, SCHED_OTHER, SCHED_RESET_ON_FORK, SCHED_RR, SEEK_DATA, SEEK_HOLE, SPLICE_F_MORE, SPLICE_F_MOVE, SPLICE_F_NONBLOCK, ST_APPEND, ST_MANDLOCK, ST_NOATIME, ST_NODEV, ST_NODIRATIME, ST_NOEXEC, ST_NOSUID, ST_RDONLY, ST_RELATIME, ST_SYNCHRONOUS, ST_WRITE, TMP_MAX, WCONTINUED, WCOREDUMP, WEXITED, WEXITSTATUS, WIFCONTINUED, WIFEXITED, WIFSIGNALED, WNOHANG, WNOWAIT, WSTOPPED, WSTOPSIG, WTERMSIG, WUNTRACED, W_OK, XATTR_CREATE, XATTR_REPLACE, XATTR_SIZE_MAX, X_OK, abort, access, chdir, chmod, chown, chroot, closerange, confstr, confstr_names, copy_file_range, cpu_count, ctermid, device_encoding, dup, dupN, error, eventfd, eventfd_read, eventfd_write, fchdir, fchmod, fchown, fdatasync, forkpty, fpathconf, fstat, fstatvfs, fsync, ftruncate, get_blocking, get_inheritable, get_terminal_size, getcwd, getcwdb, getegid, geteuid, getgid, getgrouplist, getgroups, getloadavg, getlogin, getpgid, getpgrp, getpid, getppid, getpriority, getrandom, getresgid, getresuid, getsid, getuid, getxattr, initgroups, isatty, kill, killpg, lchown, link, listdir, listxattr, lockf, lseek, lstat, major, makedev, memfd_create, minor, mkfifo, mknod, nice, openpty, pathconf, pathconf_names, pidfd_open, pipe, pipeN, posix_fadvise, posix_fallocate, posix_spawn, posix_spawnp, pread, preadv, pwrite, pwritev, read, readlink, readv, register_at_fork, remove, removexattr, replace, sched_get_priority_max, sched_get_priority_min, sched_getaffinity, sched_getparam, sched_getscheduler, sched_param, sched_rr_get_interval, sched_setaffinity, sched_setparam, sched_setscheduler, sched_yield, sendfile, set_blocking, set_inheritable, setegid, seteuid, setgid, setgroups, setpgid, setpgrp, setpriority, setregid, setresgid, setresuid, setreuid, setsid, setuid, setxattr, splice, stat_result, statvfs, statvfs_result, strerror, symlink, sync, sysconf, sysconf_names, system, tcgetpgrp, tcsetpgrp, terminal_size, times, times_result, truncate, ttyname, umask, uname, uname_result, unlink, urandom, utime, wait, waitN, waitN, waitid, waitid_result, write and writev from wildcard import of posix (unused-wildcard-import)
/usr/lib/pythonN.NN/os.py:NN:N: CNNNN: Imports from package posix are not grouped (ungrouped-imports)
/usr/lib/pythonN.NN/os.py:NNN:N: CNNNN: Imports from package _collections_abc are not grouped (ungrouped-imports)
END_EXPECTED
}


@test "test-14" {
	testfolder="/tmp/batspp-160636/test-14"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'run-python-lint-batched $BIN_DIR/tests/auto_batspp.py | testuser | testnum\n' "=========="
	test-14-actual 
	echo "=========" $"************* Module auto_batspp\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''-n' or '-t' not in ARG' will always evaluate to ''-n'' (condition-evals-to-constant)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''n' or 't' not in ARG' will always evaluate to ''n'' (condition-evals-to-constant)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)" "========="
	test-14-expected 
	echo "============================"
	# ???: 'run-python-lint-batched $BIN_DIR/tests/auto_batspp.py | testuser | testnum\n'=$(test-14-actual)
	# ???: "************* Module auto_batspp\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''-n' or '-t' not in ARG' will always evaluate to ''-n'' (condition-evals-to-constant)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''n' or 't' not in ARG' will always evaluate to ''n'' (condition-evals-to-constant)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)\n/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)"=$(test-14-expected)
	[ "$(test-14-actual)" == "$(test-14-expected)" ]
}

function test-14-actual () {
	# no-op in case content just a comment
	true

	run-python-lint-batched $BIN_DIR/tests/auto_batspp.py | testuser | testnum

}

function test-14-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
************* Module auto_batspp
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''-n' or '-t' not in ARG' will always evaluate to ''-n'' (condition-evals-to-constant)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:NN: RNNNN: Boolean condition ''n' or 't' not in ARG' will always evaluate to ''n'' (condition-evals-to-constant)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)
/home/userxfNNN/tom-project/shell-scripts/tests/auto_batspp.py:NNN:N: WNNNN: Using an f-string that does not have any interpolated variables (f-string-without-interpolation)
END_EXPECTED
}


@test "test-15" {
	testfolder="/tmp/batspp-160636/test-15"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"python-import-path 'mezcla' | testnum\n" "=========="
	test-15-actual 
	echo "=========" $"$ linebr\n$ python-import-path-full 'mezcla' | testnum\n$ linebr\n# WORKS WELL, SHOWS SOME ISSUES ON BATSPP 2.1.X\n$ python-import-path-all 'mezcla' | grep mezcla | head -n 5 | testnum\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\n--------------------------------------------------------------------------------\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/glue_helpers.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/system.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/tpo_common.py\n--------------------------------------------------------------------------------\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\n# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc'\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py\n# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc'\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/sys_version_info_hack.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py" "========="
	test-15-expected 
	echo "============================"
	# ???: "python-import-path 'mezcla' | testnum\n"=$(test-15-actual)
	# ???: "$ linebr\n$ python-import-path-full 'mezcla' | testnum\n$ linebr\n# WORKS WELL, SHOWS SOME ISSUES ON BATSPP 2.1.X\n$ python-import-path-all 'mezcla' | grep mezcla | head -n 5 | testnum\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\n--------------------------------------------------------------------------------\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/glue_helpers.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/system.py\nmatches /usr/local/lib/pythonN.NN/dist-packages/mezcla/tpo_common.py\n--------------------------------------------------------------------------------\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py\n# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc'\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py\n# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc'\n# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/sys_version_info_hack.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py"=$(test-15-expected)
	[ "$(test-15-actual)" == "$(test-15-expected)" ]
}

function test-15-actual () {
	# no-op in case content just a comment
	true

	python-import-path 'mezcla' | testnum

}

function test-15-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ python-import-path-full 'mezcla' | testnum
$ linebr
# WORKS WELL, SHOWS SOME ISSUES ON BATSPP 2.1.X
$ python-import-path-all 'mezcla' | grep mezcla | head -n 5 | testnum
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py
--------------------------------------------------------------------------------
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/glue_helpers.py
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/system.py
matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/tpo_common.py
--------------------------------------------------------------------------------
# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/__init__.py
# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/__init__.cpython-NNN.pyc'
# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/debug.py
# code object from '/usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/debug.cpython-NNN.pyc'
# /usr/local/lib/pythonN.NN/dist-packages/mezcla/__pycache__/sys_version_info_hack.cpython-NNN.pyc matches /usr/local/lib/pythonN.NN/dist-packages/mezcla/sys_version_info_hack.py
END_EXPECTED
}


@test "test-16" {
	testfolder="/tmp/batspp-160636/test-16"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-16-actual 
	echo "=========" $'$ pip3 freeze | grep ipython | wc -l\n2' "========="
	test-16-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-16-actual)
	# ???: '$ pip3 freeze | grep ipython | wc -l\n2'=$(test-16-expected)
	[ "$(test-16-actual)" == "$(test-16-expected)" ]
}

function test-16-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-16-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ pip3 freeze | grep ipython | wc -l
2
END_EXPECTED
}


@test "test-17" {
	testfolder="/tmp/batspp-160636/test-17"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'python-module-version-full mezcla | testnum\n' "=========="
	test-17-actual 
	echo "=========" $"$ linebr\n$ python-module-version mezcla | testnum\n$ linebr\n$ python-package-members mezcla | testnum\n$ linebr\nN.N.N\n--------------------------------------------------------------------------------\nN.N.N\n--------------------------------------------------------------------------------\n['PYTHONN_PLUS', 'TL', '__VERSION__', '__all__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', 'debug', 'gh', 'glue_helpers', 'mezcla', 'sys', 'sys_version_info_hack', 'system', 'tpo_common']\n--------------------------------------------------------------------------------" "========="
	test-17-expected 
	echo "============================"
	# ???: 'python-module-version-full mezcla | testnum\n'=$(test-17-actual)
	# ???: "$ linebr\n$ python-module-version mezcla | testnum\n$ linebr\n$ python-package-members mezcla | testnum\n$ linebr\nN.N.N\n--------------------------------------------------------------------------------\nN.N.N\n--------------------------------------------------------------------------------\n['PYTHONN_PLUS', 'TL', '__VERSION__', '__all__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', 'debug', 'gh', 'glue_helpers', 'mezcla', 'sys', 'sys_version_info_hack', 'system', 'tpo_common']\n--------------------------------------------------------------------------------"=$(test-17-expected)
	[ "$(test-17-actual)" == "$(test-17-expected)" ]
}

function test-17-actual () {
	# no-op in case content just a comment
	true

	python-module-version-full mezcla | testnum

}

function test-17-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ python-module-version mezcla | testnum
$ linebr
$ python-package-members mezcla | testnum
$ linebr
N.N.N
--------------------------------------------------------------------------------
N.N.N
--------------------------------------------------------------------------------
['PYTHONN_PLUS', 'TL', '__VERSION__', '__all__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', 'debug', 'gh', 'glue_helpers', 'mezcla', 'sys', 'sys_version_info_hack', 'system', 'tpo_common']
--------------------------------------------------------------------------------
END_EXPECTED
}


@test "test-18" {
	testfolder="/tmp/batspp-160636/test-18"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd \n' "=========="
	test-18-actual 
	echo "=========" $'$ printf "THIS IS THE HEAD\\n1\\n2\\n3\\n4\\n5\\n6\\n7\\nTHIS IS THE TAIL." >> testless.txt\n/tmp/test-py-commands/test-7766' "========="
	test-18-expected 
	echo "============================"
	# ???: 'pwd \n'=$(test-18-actual)
	# ???: '$ printf "THIS IS THE HEAD\\n1\\n2\\n3\\n4\\n5\\n6\\n7\\nTHIS IS THE TAIL." >> testless.txt\n/tmp/test-py-commands/test-7766'=$(test-18-expected)
	[ "$(test-18-actual)" == "$(test-18-expected)" ]
}

function test-18-actual () {
	# no-op in case content just a comment
	true

	pwd 

}

function test-18-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "THIS IS THE HEAD\n1\n2\n3\n4\n5\n6\n7\nTHIS IS THE TAIL." >> testless.txt
/tmp/test-py-commands/test-7766
END_EXPECTED
}


@test "test-19" {
	testfolder="/tmp/batspp-160636/test-19"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ltc testless.txt | testnum\n' "=========="
	test-19-actual 
	echo "=========" $'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.' "========="
	test-19-expected 
	echo "============================"
	# ???: 'ltc testless.txt | testnum\n'=$(test-19-actual)
	# ???: 'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.'=$(test-19-expected)
	[ "$(test-19-actual)" == "$(test-19-expected)" ]
}

function test-19-actual () {
	# no-op in case content just a comment
	true

	ltc testless.txt | testnum

}

function test-19-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
THIS IS THE HEAD
N
N
N
N
N
N
N
THIS IS THE TAIL.
END_EXPECTED
}


@test "test-20" {
	testfolder="/tmp/batspp-160636/test-20"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'less-tail testless.txt | testnum\n' "=========="
	test-20-actual 
	echo "=========" $'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.' "========="
	test-20-expected 
	echo "============================"
	# ???: 'less-tail testless.txt | testnum\n'=$(test-20-actual)
	# ???: 'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.'=$(test-20-expected)
	[ "$(test-20-actual)" == "$(test-20-expected)" ]
}

function test-20-actual () {
	# no-op in case content just a comment
	true

	less-tail testless.txt | testnum

}

function test-20-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
THIS IS THE HEAD
N
N
N
N
N
N
N
THIS IS THE TAIL.
END_EXPECTED
}


@test "test-21" {
	testfolder="/tmp/batspp-160636/test-21"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'less-tail-clipped testless.txt | testnum\n' "=========="
	test-21-actual 
	echo "=========" $'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.' "========="
	test-21-expected 
	echo "============================"
	# ???: 'less-tail-clipped testless.txt | testnum\n'=$(test-21-actual)
	# ???: 'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.'=$(test-21-expected)
	[ "$(test-21-actual)" == "$(test-21-expected)" ]
}

function test-21-actual () {
	# no-op in case content just a comment
	true

	less-tail-clipped testless.txt | testnum

}

function test-21-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
THIS IS THE HEAD
N
N
N
N
N
N
N
THIS IS THE TAIL.
END_EXPECTED
}


@test "test-22" {
	testfolder="/tmp/batspp-160636/test-22"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'less-clipped testless.txt | testnum\n' "=========="
	test-22-actual 
	echo "=========" $'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.' "========="
	test-22-expected 
	echo "============================"
	# ???: 'less-clipped testless.txt | testnum\n'=$(test-22-actual)
	# ???: 'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.'=$(test-22-expected)
	[ "$(test-22-actual)" == "$(test-22-expected)" ]
}

function test-22-actual () {
	# no-op in case content just a comment
	true

	less-clipped testless.txt | testnum

}

function test-22-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
THIS IS THE HEAD
N
N
N
N
N
N
N
THIS IS THE TAIL.
END_EXPECTED
}


@test "test-23" {
	testfolder="/tmp/batspp-160636/test-23"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'less- testless.txt | testnum\n' "=========="
	test-23-actual 
	echo "=========" $'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.' "========="
	test-23-expected 
	echo "============================"
	# ???: 'less- testless.txt | testnum\n'=$(test-23-actual)
	# ???: 'THIS IS THE HEAD\nN\nN\nN\nN\nN\nN\nN\nTHIS IS THE TAIL.'=$(test-23-expected)
	[ "$(test-23-actual)" == "$(test-23-expected)" ]
}

function test-23-actual () {
	# no-op in case content just a comment
	true

	less- testless.txt | testnum

}

function test-23-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
THIS IS THE HEAD
N
N
N
N
N
N
N
THIS IS THE TAIL.
END_EXPECTED
}


@test "test-24" {
	testfolder="/tmp/batspp-160636/test-24"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'ipython --version | testuser | testnum\n' "=========="
	test-24-actual 
	echo "=========" $'$ linebr\n# STATEMENT TRACING WORKS WELL / ISSUES WITH TESTUSER\n$ python-trace l $BIN_DIR/tests/auto_batspp.py | testuser | testnum\n\x1b]N;ipython [/tmp/test-py-commands/test-NNNN]\x07\x1b]N;ipython [/tmp/test-py-commands/test-NNNN]\x07N.N.N\n--------------------------------------------------------------------------------\nCannot run file \'/home/aveey/tom-project/shell-scripts/tests/../tests/auto_batspp.py\' because: [Errno 2] No such file or directory: \'./batspp-only/\'\nCommand exited with non-zero status 1\n0.08user 0.00system 0:00.10elapsed 82%CPU (0avgtext+0avgdata 12548maxresident)k\n0inputs+0outputs (0major+1816minor)pagefaults 0swaps\n --- modulename: auto_batspp, funcname: <module>\nauto_batspp.py(N): """ \nauto_batspp.py(NN): import os\nauto_batspp.py(NN): import sys\nauto_batspp.py(NN): IPYNB = ".ipynb"\nauto_batspp.py(NN): BATSPP = ".batspp"\nauto_batspp.py(NN): BATS = ".bats"\nauto_batspp.py(NN): TXT = ".txt"\nauto_batspp.py(NN): BATSPP_STORE = r"batspp-only"\nauto_batspp.py(NN): BATS_STORE = r"bats-only"\nauto_batspp.py(NN): TXT_STORE = r"txt-reports"\nauto_batspp.py(NN): KCOV_STORE = r"kcov-output"\nauto_batspp.py(NN): files = os.listdir(r"./")\nauto_batspp.py(NN): filesys_bpp = os.listdir(r"./batspp-only/")' "========="
	test-24-expected 
	echo "============================"
	# ???: 'ipython --version | testuser | testnum\n'=$(test-24-actual)
	# ???: '$ linebr\n# STATEMENT TRACING WORKS WELL / ISSUES WITH TESTUSER\n$ python-trace l $BIN_DIR/tests/auto_batspp.py | testuser | testnum\n\x1b]N;ipython [/tmp/test-py-commands/test-NNNN]\x07\x1b]N;ipython [/tmp/test-py-commands/test-NNNN]\x07N.N.N\n--------------------------------------------------------------------------------\nCannot run file \'/home/aveey/tom-project/shell-scripts/tests/../tests/auto_batspp.py\' because: [Errno 2] No such file or directory: \'./batspp-only/\'\nCommand exited with non-zero status 1\n0.08user 0.00system 0:00.10elapsed 82%CPU (0avgtext+0avgdata 12548maxresident)k\n0inputs+0outputs (0major+1816minor)pagefaults 0swaps\n --- modulename: auto_batspp, funcname: <module>\nauto_batspp.py(N): """ \nauto_batspp.py(NN): import os\nauto_batspp.py(NN): import sys\nauto_batspp.py(NN): IPYNB = ".ipynb"\nauto_batspp.py(NN): BATSPP = ".batspp"\nauto_batspp.py(NN): BATS = ".bats"\nauto_batspp.py(NN): TXT = ".txt"\nauto_batspp.py(NN): BATSPP_STORE = r"batspp-only"\nauto_batspp.py(NN): BATS_STORE = r"bats-only"\nauto_batspp.py(NN): TXT_STORE = r"txt-reports"\nauto_batspp.py(NN): KCOV_STORE = r"kcov-output"\nauto_batspp.py(NN): files = os.listdir(r"./")\nauto_batspp.py(NN): filesys_bpp = os.listdir(r"./batspp-only/")'=$(test-24-expected)
	[ "$(test-24-actual)" == "$(test-24-expected)" ]
}

function test-24-actual () {
	# no-op in case content just a comment
	true

	ipython --version | testuser | testnum

}

function test-24-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
# STATEMENT TRACING WORKS WELL / ISSUES WITH TESTUSER
$ python-trace l $BIN_DIR/tests/auto_batspp.py | testuser | testnum
]N;ipython [/tmp/test-py-commands/test-NNNN]]N;ipython [/tmp/test-py-commands/test-NNNN]N.N.N
--------------------------------------------------------------------------------
Cannot run file '/home/aveey/tom-project/shell-scripts/tests/../tests/auto_batspp.py' because: [Errno 2] No such file or directory: './batspp-only/'
Command exited with non-zero status 1
0.08user 0.00system 0:00.10elapsed 82%CPU (0avgtext+0avgdata 12548maxresident)k
0inputs+0outputs (0major+1816minor)pagefaults 0swaps
 --- modulename: auto_batspp, funcname: <module>
auto_batspp.py(N): """ 
auto_batspp.py(NN): import os
auto_batspp.py(NN): import sys
auto_batspp.py(NN): IPYNB = ".ipynb"
auto_batspp.py(NN): BATSPP = ".batspp"
auto_batspp.py(NN): BATS = ".bats"
auto_batspp.py(NN): TXT = ".txt"
auto_batspp.py(NN): BATSPP_STORE = r"batspp-only"
auto_batspp.py(NN): BATS_STORE = r"bats-only"
auto_batspp.py(NN): TXT_STORE = r"txt-reports"
auto_batspp.py(NN): KCOV_STORE = r"kcov-output"
auto_batspp.py(NN): files = os.listdir(r"./")
auto_batspp.py(NN): filesys_bpp = os.listdir(r"./batspp-only/")
END_EXPECTED
}


@test "test-25" {
	testfolder="/tmp/batspp-160636/test-25"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'which-python\n' "=========="
	test-25-actual 
	echo "=========" $"#(ADDED FOR PYTHON3)\n$ alias which-py3='which python3' \n$ which-py3\n/usr/bin/python\n/usr/bin/python3" "========="
	test-25-expected 
	echo "============================"
	# ???: 'which-python\n'=$(test-25-actual)
	# ???: "#(ADDED FOR PYTHON3)\n$ alias which-py3='which python3' \n$ which-py3\n/usr/bin/python\n/usr/bin/python3"=$(test-25-expected)
	[ "$(test-25-actual)" == "$(test-25-expected)" ]
}

function test-25-actual () {
	# no-op in case content just a comment
	true

	which-python

}

function test-25-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#(ADDED FOR PYTHON3)
$ alias which-py3='which python3' 
$ which-py3
/usr/bin/python
/usr/bin/python3
END_EXPECTED
}


@test "test-26" {
	testfolder="/tmp/batspp-160636/test-26"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'rm -rf ./* > /dev/null\n' "=========="
	test-26-actual 
	echo "=========" $'$ printf "print(\'THIS IS A TEST\')" > atest.py\n$ printf "print(\'THIS IS A TEST\')" > xyz.py\n$ printf "print(\'THIS IS A TEST11\')" > abc1.py\n# SHOWS ALL THE DIFFERENCES BETWEEN THE PYTHON SCRIPTS\n# WORKS FINE - HALTS TESTS\n$ py-diff atest.py xyz.py | testuser | testnum | awk \'!($6="")\'\nAssuming implicit --no-glob, as otherwise  would be in extension\nabcN.py vs. atest.py   \nDifferences: abcN.py atest.py   \n-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN abcN.py\n-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN atest.py\nNcN     \n< print(\'THIS IS A TESTNN\') \n\\ No newline at end  file\n---     \n> print(\'THIS IS A TEST\') \n\\ No newline at end  file\n------------------------------------------------------------------------     \n     \natest.py vs. atest.py   \n------------------------------------------------------------------------     \n     \nxyz.py vs. atest.py   \n------------------------------------------------------------------------' "========="
	test-26-expected 
	echo "============================"
	# ???: 'rm -rf ./* > /dev/null\n'=$(test-26-actual)
	# ???: '$ printf "print(\'THIS IS A TEST\')" > atest.py\n$ printf "print(\'THIS IS A TEST\')" > xyz.py\n$ printf "print(\'THIS IS A TEST11\')" > abc1.py\n# SHOWS ALL THE DIFFERENCES BETWEEN THE PYTHON SCRIPTS\n# WORKS FINE - HALTS TESTS\n$ py-diff atest.py xyz.py | testuser | testnum | awk \'!($6="")\'\nAssuming implicit --no-glob, as otherwise  would be in extension\nabcN.py vs. atest.py   \nDifferences: abcN.py atest.py   \n-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN abcN.py\n-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN atest.py\nNcN     \n< print(\'THIS IS A TESTNN\') \n\\ No newline at end  file\n---     \n> print(\'THIS IS A TEST\') \n\\ No newline at end  file\n------------------------------------------------------------------------     \n     \natest.py vs. atest.py   \n------------------------------------------------------------------------     \n     \nxyz.py vs. atest.py   \n------------------------------------------------------------------------'=$(test-26-expected)
	[ "$(test-26-actual)" == "$(test-26-expected)" ]
}

function test-26-actual () {
	# no-op in case content just a comment
	true

	rm -rf ./* > /dev/null

}

function test-26-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ printf "print('THIS IS A TEST')" > atest.py
$ printf "print('THIS IS A TEST')" > xyz.py
$ printf "print('THIS IS A TEST11')" > abc1.py
# SHOWS ALL THE DIFFERENCES BETWEEN THE PYTHON SCRIPTS
# WORKS FINE - HALTS TESTS
$ py-diff atest.py xyz.py | testuser | testnum | awk '!($6="")'
Assuming implicit --no-glob, as otherwise  would be in extension
abcN.py vs. atest.py   
Differences: abcN.py atest.py   
-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN abcN.py
-rw-rw-r-- N userxfNNN userxfNNN NN  N NN:NN atest.py
NcN     
< print('THIS IS A TESTNN') 
\ No newline at end  file
---     
> print('THIS IS A TEST') 
\ No newline at end  file
------------------------------------------------------------------------     
     
atest.py vs. atest.py   
------------------------------------------------------------------------     
     
xyz.py vs. atest.py   
------------------------------------------------------------------------
END_EXPECTED
}


@test "test-27" {
	testfolder="/tmp/batspp-160636/test-27"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ echo $OSTYPE\n' "=========="
	test-27-actual 
	echo "=========" $'#   linebr\n#   elide-data $BIN_DIR/template.py\n#   linebr\n#   kill-python\n#   linebr\n#   kill-python-all\n# | linux-gnu\n# | --------------------------------------------------------------------------------\n# | /home/xaea12/miniconda3/bin/python: No module named transpose_data\n# | --------------------------------------------------------------------------------\n# | pattern=/:[0-9][0-9] [^ ]*python/\n# | filter=/ipython|emacs/\n# | OSTYPE: Undefined variable.\n# | --------------------------------------------------------------------------------\n# | pattern=/:[0-9][0-9] [^ ]*python/\n# | filter=/($)(^)/\n# | OSTYPE: Undefined variable.' "========="
	test-27-expected 
	echo "============================"
	# ???: '# $ echo $OSTYPE\n'=$(test-27-actual)
	# ???: '#   linebr\n#   elide-data $BIN_DIR/template.py\n#   linebr\n#   kill-python\n#   linebr\n#   kill-python-all\n# | linux-gnu\n# | --------------------------------------------------------------------------------\n# | /home/xaea12/miniconda3/bin/python: No module named transpose_data\n# | --------------------------------------------------------------------------------\n# | pattern=/:[0-9][0-9] [^ ]*python/\n# | filter=/ipython|emacs/\n# | OSTYPE: Undefined variable.\n# | --------------------------------------------------------------------------------\n# | pattern=/:[0-9][0-9] [^ ]*python/\n# | filter=/($)(^)/\n# | OSTYPE: Undefined variable.'=$(test-27-expected)
	[ "$(test-27-actual)" == "$(test-27-expected)" ]
}

function test-27-actual () {
	# no-op in case content just a comment
	true


}

function test-27-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#   linebr
#   elide-data $BIN_DIR/template.py
#   linebr
#   kill-python
#   linebr
#   kill-python-all
# | linux-gnu
# | --------------------------------------------------------------------------------
# | /home/xaea12/miniconda3/bin/python: No module named transpose_data
# | --------------------------------------------------------------------------------
# | pattern=/:[0-9][0-9] [^ ]*python/
# | filter=/ipython|emacs/
# | OSTYPE: Undefined variable.
# | --------------------------------------------------------------------------------
# | pattern=/:[0-9][0-9] [^ ]*python/
# | filter=/($)(^)/
# | OSTYPE: Undefined variable.
END_EXPECTED
}


@test "test-28" {
	testfolder="/tmp/batspp-160636/test-28"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ jupyter-notebook-redir-open\n' "=========="
	test-28-actual 
	echo "=========" $'# | [1] 5335\n# | /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log\n# | sleeping 5 seconds for log to stabalize (effing jupyter)\n# | bash: /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: Permission denied\n# | [1]+  Exit 1                  jupyter notebook --NotebookApp.token=\'\' --no-browser --port $port --ip $ip >> "$log" 2>&1\n# | tail: cannot open \'/jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log\' for reading: No such file or directory\n# | URL: Can\'t open /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: No such file or directory at /home/xaea12/bin/extract_matches.perl line 132.\n$ jupyter-notebook-redir-open | testnum | testuser | head -n 5\n/home/userxf333/temp/jupyter-NNdecNN.log\nsleeping N seconds for log to stabalize (effing jupyter)\n[I NNNN-NN-NN NN:NN:NN.NNN LabApp] JupyterLab application directory is /home/userxf333/.local/share/jupyter/lab\n[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.\n[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.' "========="
	test-28-expected 
	echo "============================"
	# ???: '# $ jupyter-notebook-redir-open\n'=$(test-28-actual)
	# ???: '# | [1] 5335\n# | /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log\n# | sleeping 5 seconds for log to stabalize (effing jupyter)\n# | bash: /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: Permission denied\n# | [1]+  Exit 1                  jupyter notebook --NotebookApp.token=\'\' --no-browser --port $port --ip $ip >> "$log" 2>&1\n# | tail: cannot open \'/jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log\' for reading: No such file or directory\n# | URL: Can\'t open /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: No such file or directory at /home/xaea12/bin/extract_matches.perl line 132.\n$ jupyter-notebook-redir-open | testnum | testuser | head -n 5\n/home/userxf333/temp/jupyter-NNdecNN.log\nsleeping N seconds for log to stabalize (effing jupyter)\n[I NNNN-NN-NN NN:NN:NN.NNN LabApp] JupyterLab application directory is /home/userxf333/.local/share/jupyter/lab\n[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.\n[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.'=$(test-28-expected)
	[ "$(test-28-actual)" == "$(test-28-expected)" ]
}

function test-28-actual () {
	# no-op in case content just a comment
	true


}

function test-28-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | [1] 5335
# | /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log
# | sleeping 5 seconds for log to stabalize (effing jupyter)
# | bash: /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: Permission denied
# | [1]+  Exit 1                  jupyter notebook --NotebookApp.token='' --no-browser --port $port --ip $ip >> "$log" 2>&1
# | tail: cannot open '/jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log' for reading: No such file or directory
# | URL: Can't open /jupyter-Sun Aug 28 08:13:40 AM +0545 2022.log: No such file or directory at /home/xaea12/bin/extract_matches.perl line 132.
$ jupyter-notebook-redir-open | testnum | testuser | head -n 5
/home/userxf333/temp/jupyter-NNdecNN.log
sleeping N seconds for log to stabalize (effing jupyter)
[I NNNN-NN-NN NN:NN:NN.NNN LabApp] JupyterLab application directory is /home/userxf333/.local/share/jupyter/lab
[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.
[I NN:NN:NN.NNN NotebookApp] The port NNNN is already in use, trying another port.
END_EXPECTED
}


@test "test-29" {
	testfolder="/tmp/batspp-160636/test-29"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ rm -rf ./*\n' "=========="
	test-29-actual 
	echo "=========" $'#   printf "print(\'THIS IS A TEST FOR TEXT EXTRACT ALIAS.\')" > textex.py\n#   xtract-text ./textex.py\n# | /home/xaea12/miniconda3/bin/python: No module named extract_document_text' "========="
	test-29-expected 
	echo "============================"
	# ???: '# $ rm -rf ./*\n'=$(test-29-actual)
	# ???: '#   printf "print(\'THIS IS A TEST FOR TEXT EXTRACT ALIAS.\')" > textex.py\n#   xtract-text ./textex.py\n# | /home/xaea12/miniconda3/bin/python: No module named extract_document_text'=$(test-29-expected)
	[ "$(test-29-actual)" == "$(test-29-expected)" ]
}

function test-29-actual () {
	# no-op in case content just a comment
	true


}

function test-29-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
#   printf "print('THIS IS A TEST FOR TEXT EXTRACT ALIAS.')" > textex.py
#   xtract-text ./textex.py
# | /home/xaea12/miniconda3/bin/python: No module named extract_document_text
END_EXPECTED
}


@test "test-30" {
	testfolder="/tmp/batspp-160636/test-30"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'# $ test-script ./textex.py\n' "=========="
	test-30-actual 
	echo "=========" $"# | abort: no repository found in '/tmp/test-py-commands/test-3443' (.hg not found)\n# | bash: tests/_test_textex.03sep22.log: No such file or directory\n# | tests/_test_textex.03sep22.log: No such file or directory" "========="
	test-30-expected 
	echo "============================"
	# ???: '# $ test-script ./textex.py\n'=$(test-30-actual)
	# ???: "# | abort: no repository found in '/tmp/test-py-commands/test-3443' (.hg not found)\n# | bash: tests/_test_textex.03sep22.log: No such file or directory\n# | tests/_test_textex.03sep22.log: No such file or directory"=$(test-30-expected)
	[ "$(test-30-actual)" == "$(test-30-expected)" ]
}

function test-30-actual () {
	# no-op in case content just a comment
	true


}

function test-30-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
# | abort: no repository found in '/tmp/test-py-commands/test-3443' (.hg not found)
# | bash: tests/_test_textex.03sep22.log: No such file or directory
# | tests/_test_textex.03sep22.log: No such file or directory
END_EXPECTED
}


@test "test-31" {
	testfolder="/tmp/batspp-160636/test-31"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'printf "print(\'THIS IS A TEST10\')\\nprint(\'THIS IS A TEST11\')\\nprint(\'THIS IS A TEST12\')\\nprint(\'THIS IS A TEST13\')" > random_line_test.py\n' "=========="
	test-31-actual 
	echo "=========" $'' "========="
	test-31-expected 
	echo "============================"
	# ???: 'printf "print(\'THIS IS A TEST10\')\\nprint(\'THIS IS A TEST11\')\\nprint(\'THIS IS A TEST12\')\\nprint(\'THIS IS A TEST13\')" > random_line_test.py\n'=$(test-31-actual)
	# ???: ''=$(test-31-expected)
	[ "$(test-31-actual)" == "$(test-31-expected)" ]
}

function test-31-actual () {
	# no-op in case content just a comment
	true

	printf "print('THIS IS A TEST10')\nprint('THIS IS A TEST11')\nprint('THIS IS A TEST12')\nprint('THIS IS A TEST13')" > random_line_test.py

}

function test-31-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED

END_EXPECTED
}


@test "test-32" {
	testfolder="/tmp/batspp-160636/test-32"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'randomize-datafile random_line_test.py\n' "=========="
	test-32-actual 
	echo "=========" $"print('THIS IS A TEST10')\nprint('THIS IS A TEST10')\nprint('THIS IS A TEST11')\nprint('THIS IS A TEST12')\n/usr/bin/python: No module named randomize_lines" "========="
	test-32-expected 
	echo "============================"
	# ???: 'randomize-datafile random_line_test.py\n'=$(test-32-actual)
	# ???: "print('THIS IS A TEST10')\nprint('THIS IS A TEST10')\nprint('THIS IS A TEST11')\nprint('THIS IS A TEST12')\n/usr/bin/python: No module named randomize_lines"=$(test-32-expected)
	[ "$(test-32-actual)" == "$(test-32-expected)" ]
}

function test-32-actual () {
	# no-op in case content just a comment
	true

	randomize-datafile random_line_test.py

}

function test-32-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
print('THIS IS A TEST10')
print('THIS IS A TEST10')
print('THIS IS A TEST11')
print('THIS IS A TEST12')
/usr/bin/python: No module named randomize_lines
END_EXPECTED
}


@test "test-33" {
	testfolder="/tmp/batspp-160636/test-33"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'conditional-source $BIN_DIR/tests/_dir-aliases.bash\n' "=========="
	test-33-actual 
	echo "=========" $"$ touch file1\n$ ln-symbolic file1 link1\n$ linebr\n$ ls\n'link1' -> 'file1'\n--------------------------------------------------------------------------------\nabc1.py  atest.py  file1  link1  random_line_test.py  xyz.py" "========="
	test-33-expected 
	echo "============================"
	# ???: 'conditional-source $BIN_DIR/tests/_dir-aliases.bash\n'=$(test-33-actual)
	# ???: "$ touch file1\n$ ln-symbolic file1 link1\n$ linebr\n$ ls\n'link1' -> 'file1'\n--------------------------------------------------------------------------------\nabc1.py  atest.py  file1  link1  random_line_test.py  xyz.py"=$(test-33-expected)
	[ "$(test-33-actual)" == "$(test-33-expected)" ]
}

function test-33-actual () {
	# no-op in case content just a comment
	true

	conditional-source $BIN_DIR/tests/_dir-aliases.bash

}

function test-33-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ touch file1
$ ln-symbolic file1 link1
$ linebr
$ ls
'link1' -> 'file1'
--------------------------------------------------------------------------------
abc1.py  atest.py  file1  link1  random_line_test.py  xyz.py
END_EXPECTED
}


@test "test-34" {
	testfolder="/tmp/batspp-160636/test-34"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'curl-dump https://www.example.com/\n' "=========="
	test-34-actual 
	echo "=========" $'$ linebr\n$ ls -l | testnum | testuser | awk \'!($6="")\'\n$ linebr\n$ url-path $BIN_DIR/tests/auto_batspp.py | testuser\n  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n100  1256  100  1256    0     0    615      0  0:00:02  0:00:02 --:--:--   615\n--------------------------------------------------------------------------------\ntotal NN    \n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN abcN.py\n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN atest.py\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN fileN\nlrwxrwxrwx N userxf333 userxf333 N  N NN:NN linkN -> fileN\n-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN random_line_test.py\n-rw-rw-r-- N userxf333 userxf333 NNNN  N NN:NN www.example.com\n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN xyz.py\n--------------------------------------------------------------------------------\nfile:////home/userxf333/tom-project/shell-scripts/tests/auto_batspp.py' "========="
	test-34-expected 
	echo "============================"
	# ???: 'curl-dump https://www.example.com/\n'=$(test-34-actual)
	# ???: '$ linebr\n$ ls -l | testnum | testuser | awk \'!($6="")\'\n$ linebr\n$ url-path $BIN_DIR/tests/auto_batspp.py | testuser\n  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current\n                                 Dload  Upload   Total   Spent    Left  Speed\n100  1256  100  1256    0     0    615      0  0:00:02  0:00:02 --:--:--   615\n--------------------------------------------------------------------------------\ntotal NN    \n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN abcN.py\n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN atest.py\n-rw-rw-r-- N userxf333 userxf333 N  N NN:NN fileN\nlrwxrwxrwx N userxf333 userxf333 N  N NN:NN linkN -> fileN\n-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN random_line_test.py\n-rw-rw-r-- N userxf333 userxf333 NNNN  N NN:NN www.example.com\n-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN xyz.py\n--------------------------------------------------------------------------------\nfile:////home/userxf333/tom-project/shell-scripts/tests/auto_batspp.py'=$(test-34-expected)
	[ "$(test-34-actual)" == "$(test-34-expected)" ]
}

function test-34-actual () {
	# no-op in case content just a comment
	true

	curl-dump https://www.example.com/

}

function test-34-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ linebr
$ ls -l | testnum | testuser | awk '!($6="")'
$ linebr
$ url-path $BIN_DIR/tests/auto_batspp.py | testuser
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1256  100  1256    0     0    615      0  0:00:02  0:00:02 --:--:--   615
--------------------------------------------------------------------------------
total NN    
-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN abcN.py
-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN atest.py
-rw-rw-r-- N userxf333 userxf333 N  N NN:NN fileN
lrwxrwxrwx N userxf333 userxf333 N  N NN:NN linkN -> fileN
-rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN random_line_test.py
-rw-rw-r-- N userxf333 userxf333 NNNN  N NN:NN www.example.com
-rw-rw-r-- N userxf333 userxf333 NN  N NN:NN xyz.py
--------------------------------------------------------------------------------
file:////home/userxf333/tom-project/shell-scripts/tests/auto_batspp.py
END_EXPECTED
}


@test "test-35" {
	testfolder="/tmp/batspp-160636/test-35"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'pwd |  sed -r "s/"$USER"+/user/g"\n' "=========="
	test-35-actual 
	echo "=========" $'$ rm -rf * > /dev/null\n/tmp/test-py-commands/test-7766' "========="
	test-35-expected 
	echo "============================"
	# ???: 'pwd |  sed -r "s/"$USER"+/user/g"\n'=$(test-35-actual)
	# ???: '$ rm -rf * > /dev/null\n/tmp/test-py-commands/test-7766'=$(test-35-expected)
	[ "$(test-35-actual)" == "$(test-35-expected)" ]
}

function test-35-actual () {
	# no-op in case content just a comment
	true

	pwd |  sed -r "s/"$USER"+/user/g"

}

function test-35-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ rm -rf * > /dev/null
/tmp/test-py-commands/test-7766
END_EXPECTED
}
