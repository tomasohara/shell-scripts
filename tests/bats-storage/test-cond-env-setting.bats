#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
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

	source _dir-aliases.bash
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
	echo -e '8'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-1710
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
	alias | wc -l
}
function test5-assert1-expected () {
	echo -e '9'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test6-assert1-actual)
	expected=$(test6-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test6-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test6-assert1-expected () {
	echo -e '2'
}

@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	function conditional-export () {
	local var value
	local args
	while [ "$1" != "" ]; do
	var="$1" value="$2";
	## DEBUG: echo "value for env. var. $var: $(printenv "$var")"
	if [ "$(printenv "$var")" == "" ]; then
		    # Note: ignores SC1066 (Don't use $ on the left side of assignments)
		    # shellcheck disable=SC1066      
	export $var="$value"
	fi
		args="$*"
	shift 2
		if [ "$args" = "$*" ]; then
		    echo "Error: Unexpected value in conditional-export (var='$var'; val='$value')"
		    return 
		fi
	done
	}
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	alias conditional-setenv='conditional-export'
	alias cond-export='conditional-export'
	alias cond-setenv='conditional-export'
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	cond-setenv COND_ENV_TEST_TEMP tmp/cond-env-test-temp
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
	echo $COND_ENV_TEST_TEMP
}
function test10-assert1-expected () {
	echo -e 'tmp/cond-env-test-temp'
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	mkdir -p $COND_ENV_TEST_TEMP
	actual=$(test11-assert2-actual)
	expected=$(test11-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert2-actual () {
	ls -l
}
function test11-assert2-expected () {
	echo -e 'total 4drwxrwxr-x 3 aveey aveey 4096 Sep  9 21:59 tmp'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	pwd
}


@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	cd $COND_ENV_TEST_TEMP
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
	cat temp-env-1
}
function test13-assert2-expected () {
	echo -e 'BASH=/usr/bin/bashBASHOPTS=checkwinsize:cmdhist:complete_fullquote:extquote:force_fignore:globasciiranges:hostcomplete:interactive_comments:progcomp:promptvars:sourcepathBASH_ALIASES=()BASH_ARGC=()BASH_ARGV=()BASH_CMDS=()BASH_LINENO=([0]="0")BASH_SOURCE=([0]="/home/aveey/bin/printenv.sh")BASH_VERSINFO=([0]="5" [1]="1" [2]="16" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")BASH_VERSION=\'5.1.16(1)-release\'BROWSER=firefoxCOLORTERM=truecolorCONDA_DEFAULT_ENV=baseCONDA_EXE=/home/aveey/miniconda3/bin/condaCONDA_PREFIX=/home/aveey/miniconda3CONDA_PROMPT_MODIFIER=\'(base) \'CONDA_PYTHON_EXE=/home/aveey/miniconda3/bin/pythonCONDA_SHLVL=1COND_ENV_TEST_TEMP=tmp/cond-env-test-tempDBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/busDESKTOP_SESSION=LubuntuDIRSTACK=()DISPLAY=:0EUID=1000GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1GROUPS=()GTK_CSD=0GTK_OVERLAY_SCROLLING=0HOME=/home/aveeyHOSTNAME=ASPIRE5742GLUBUHOSTTYPE=x86_64IFS=$\' \\t\\n\'JPY_PARENT_PID=35049LANG=en_US.UTF-8LC_ADDRESS=en_US.UTF-8LC_IDENTIFICATION=en_US.UTF-8LC_MEASUREMENT=en_US.UTF-8LC_MONETARY=en_US.UTF-8LC_NAME=en_US.UTF-8LC_NUMERIC=en_US.UTF-8LC_PAPER=en_US.UTF-8LC_TELEPHONE=en_US.UTF-8LC_TIME=en_US.UTF-8LESSCLOSE=\'/usr/bin/lesspipe %s %s\'LESSOPEN=\'| /usr/bin/lesspipe %s\'LOGNAME=aveeyLS_COLORS=\'rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:\'LXQT_SESSION_CONFIG=sessionMACHTYPE=x86_64-pc-linux-gnuOLDPWD=/home/aveey/tom-project/shell-scripts/testsOPTERR=1OPTIND=1OSTYPE=linux-gnuPAGER=catPATH=/home/aveey/miniconda3/bin:/home/aveey/miniconda3/condabin:/home/aveey/.local/bin:/home/aveey/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/binPIPESTATUS=([0]="0")PPID=45815PS4=\'+ \'PWD=/tmp/test-cond-env/test-1710QT_ACCESSIBILITY=1QT_PLATFORM_PLUGIN=lxqtQT_QPA_PLATFORMTHEME=lxqtSAL_USE_VCLPLUGIN=qt5SAL_VCL_QT5_USE_CAIRO=trueSHELL=/bin/bashSHELLOPTS=braceexpand:hashall:interactive-commentsSHLVL=3SSH_AGENT_PID=1054SSH_AUTH_SOCK=/tmp/ssh-XXXXXX5Kaad3/agent.1006TERM=xterm-256colorUID=1000USER=aveeyVTE_VERSION=6800WINDOWID=46137347XAUTHORITY=/home/aveey/.XauthorityXDG_CACHE_HOME=/home/aveey/.cacheXDG_CONFIG_DIRS=/etc/xdg/xdg-Lubuntu:/etc/xdg:/etc:/usr/shareXDG_CONFIG_HOME=/home/aveey/.configXDG_CURRENT_DESKTOP=LXQtXDG_DATA_DIRS=/usr/share/Lubuntu:/usr/local/share:/usr/share:/var/lib/snapd/desktopXDG_DATA_HOME=/home/aveey/.local/shareXDG_MENU_PREFIX=lxqt-XDG_RUNTIME_DIR=/run/user/1000XDG_SEAT=seat0XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0XDG_SESSION_CLASS=userXDG_SESSION_DESKTOP=XDG_SESSION_ID=3XDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session1XDG_SESSION_TYPE=x11XDG_VTNR=1_=\']\'_CE_CONDA=_CE_M='
}
