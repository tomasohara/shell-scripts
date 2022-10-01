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

	BIN_DIR=$PWD/..
	actual=$(test1-assert2-actual)
	expected=$(test1-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert2-actual () {
	alias | wc -l
}
function test1-assert2-expected () {
	echo -e '11'
}

@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-3443
	cd "$temp_dir"
}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	export PYTHON_CMD="/usr/bin/time python -u"
	export PYTHON="$NICE $PYTHON_CMD"
	export PYTHONPATH="$HOME/python:$PYTHONPATH"
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	function add-python-path () {
	local package_path="$1"
	local parent_path=$(realpath "$package_path/..")
	# add package to path (e.g., $HOME/python/Mezcla/mezcla)
	prepend-path "$package_path"
	# add parent to python-path spec (e.g., $HOME/python/Mezcla)
	export PYTHONPATH="$parent_path:$PYTHONPATH"
	alias mezcla-devel='add-python-path $HOME/python/Mezcla/mezcla'
	alias mezcla-main='add-python-path $HOME/python/Mezcla-main/mezcla'
	if [[ ! "$PATH" =~ mezcla ]]; then
	## OLD: mezcla-devel
	## TODO: echo "Warning: mezcla not in PATH"
	true
	fi
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	function ps-all () { 
	local pattern="$1";
	local pager=cat;
	if [ "$pattern" = "" ]; then 
	pattern="."; 
	pager=$PAGER
	fi;
	ps_mine.sh --all | $EGREP -i "((^USER)|($pattern))" | $pager;
	function show-path-dir () { (echo "${1}:"; printenv "$1" | perl -pe "s/:/\n/g;") | $PAGER; }
	function append-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="${PATH}:$1"; fi }
	function append-python-path () { export PYTHONPATH=${PYTHONPATH}:"$1"; }
	function prepend-python-path () { export PYTHONPATH="$1":${PYTHONPATH}; }
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	add-python-path $temp_dir
	alias ps-python='ps-python-full | $EGREP -iv "(screenlet|ipython|egrep|update-manager|software-properties|networkd-dispatcher)"'
	alias show-python-path='show-path-dir PYTHONPATH'
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test7-assert1-actual)
	expected=$(test7-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert1-actual () {
	show-python-path
}
function test7-assert1-expected () {
	echo -e 'PYTHONPATH:/tmp/test-py-commands/home/aveey/python'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	function python-lint() { python-lint-work "$@" 2>&1 | $EGREP -v '(Exactly one space required)|\((bad-continuation|bad-whitespace|bad-indentation|bare-except|c-extension-no-member|consider-using-enumerate|consider-using-with|global-statement|global-variable-not-assigned|keyword-arg-before-vararg|len-as-condition|line-too-long|logging-not-lazy|misplaced-comparison-constant|missing-final-newline|redefined-variable-type|redundant-keyword-arg|superfluous-parens|too-many-arguments|too-many-instance-attributes|trailing-newlines|useless-\S+|wrong-import-order|wrong-import-position)\)' | $PAGER; }
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	function downcase-stdin { perl -pe "use open ':std', ':encoding(UTF-8)'; s/.*/\L$&/;"; }
	function get-python-lint-dir () {
	local python_version_major=$(pylint --version 2>&1 | extract_matches.perl "Python (\d)")
	local affix="py${python_version_major}"
	local out_dir="_pylint/$(todays-date)-$affix"
	echo "$out_dir"
	function run-python-lint-batched () {
	# TODO: support files with embedded spaces
	local file_spec="$@"
	if [ "$file_spec" = "" ]; then file_spec="*.py"; fi
	# Create output directory if needed
	local out_dir=$(get-python-lint-dir)
	mkdir -p "$out_dir"
	# Run pylint and pipe top section into less
	(for f in $($LS $file_spec); do
	# HACK: uses basename of parent prefix if invoked with path
	local b=$(basename "$f")
	local pre=""
		 # Note: uses directory name as prefix if file not in current dir
	if [[ $f =~ / ]]; then pre="$(basename $(dirname "$f"))-"; fi
	DEBUG_LEVEL=5 python-lint "$f" >| "$out_dir/$pre$b".log 2>&1
	head "$out_dir/$pre$b".log
	done) >| "$out_dir/summary.log"
	less -p '^\** Module' "$out_dir/summary.log";
	}
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	function python-import-path-all() { local module="$1"; python -u -v -c "import $module" 2>&1; }
	function python-import-path-full() { local module="$1"; python-import-path-all "$@" | extract_matches.perl "((matches (.*\W$module[^/]*[/\.][^/]*))|ModuleNotFoundError)"; }
	python-import-path 'mezcla'
	linebr
	python-import-path-full 'mezcla'
	linebr
	actual=$(test10-assert7-actual)
	expected=$(test10-assert7-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert7-actual () {
	python-import-path-all 'mezcla' | grep 'mezcla'
}
function test10-assert7-expected () {
	echo -e "matches /home/aveey/.local/lib/python3.10/site-packages/mezcla/__init__.py--------------------------------------------------------------------------------matches /home/aveey/.local/lib/python3.10/site-packages/mezcla/__init__.pymatches /home/aveey/.local/lib/python3.10/site-packages/mezcla/debug.pymatches /home/aveey/.local/lib/python3.10/site-packages/mezcla/sys_version_info_hack.pymatches /home/aveey/.local/lib/python3.10/site-packages/mezcla/glue_helpers.pymatches /home/aveey/.local/lib/python3.10/site-packages/mezcla/system.pymatches /home/aveey/.local/lib/python3.10/site-packages/mezcla/tpo_common.py--------------------------------------------------------------------------------# /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/__init__.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__init__.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/__init__.cpython-310.pyc'# /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/debug.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/debug.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/debug.cpython-310.pyc'# /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/sys_version_info_hack.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/sys_version_info_hack.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/sys_version_info_hack.cpython-310.pyc'import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.sys_version_info_hack' # <_frozen_importlib_external.SourceFileLoader object at 0x7f157fc5fee0>import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.debug' # <_frozen_importlib_external.SourceFileLoader object at 0x7f1580093ca0># /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/glue_helpers.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/glue_helpers.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/glue_helpers.cpython-310.pyc'# /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/system.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/system.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/system.cpython-310.pyc'import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.system' # <_frozen_importlib_external.SourceFileLoader object at 0x7f157fc558d0># /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/tpo_common.cpython-310.pyc matches /home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/tpo_common.py# code object from '/home/aveey/.local/lib/python3.10/site-packages/\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K/__pycache__/tpo_common.cpython-310.pyc'import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.tpo_common' # <_frozen_importlib_external.SourceFileLoader object at 0x7f157fc57e80>import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.glue_helpers' # <_frozen_importlib_external.SourceFileLoader object at 0x7f157fc5faf0>import '\x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K' # <_frozen_importlib_external.SourceFileLoader object at 0x7f1580093e50># cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.sys_version_info_hack# cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.debug# cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.system# cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.tpo_common# cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.glue_helpers# cleanup[2] removing \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.sys_version_info_hack# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.glue_helpers# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.system# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.tpo_common# destroy \x1b[01;31m\x1b[Kmezcla\x1b[m\x1b[K.debug"
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
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
	pip3 freeze
}
function test11-assert2-expected () {
	echo -e 'anyio==3.6.1appdirs==1.4.4apturl==0.5.2argon2-cffi==21.3.0argon2-cffi-bindings==21.2.0astroid==2.9.3asttokens==2.0.8attrs==22.1.0ayatana-settings==21.1.28Babel==2.10.3backcall==0.2.0bash_kernel==0.8.0batspp==2.1.4beautifulsoup4==4.11.1beniget==0.4.1bleach==5.0.1blinker==1.4Brlapi==0.8.3Brotli==1.0.9cajarename==21.11.24certifi==2022.9.14cffi==1.15.1chardet==4.0.0charset-normalizer==2.1.1click==8.0.3colorama==0.4.4command-not-found==0.3cryptography==3.4.8cupshelpers==1.0cycler==0.11.0dbus-python==1.2.18debugpy==1.6.3decorator==5.1.1defer==1.0.6defusedxml==0.7.1distro==1.7.0distro-info===1.1build1entrypoints==0.4executing==1.0.0fastjsonschema==2.16.1folder-color-caja==0.0.86folder-color-common==0.0.86fonttools==4.29.1fs==2.4.12gast==0.5.2gpg===1.16.0-unknowngreenlet==1.1.2html5lib==1.1httplib2==0.20.2idna==3.4importlib-metadata==4.6.4ipykernel==6.15.3ipython==8.5.0ipython_genutils==0.2.0ipywidgets==6.0.0isort==5.6.4jedi==0.18.1jeepney==0.7.1Jinja2==3.1.2json5==0.9.10jsonschema==4.16.0jupyter-core==4.11.1jupyter-server==1.18.1jupyter_client==7.3.5jupyterlab==3.4.7jupyterlab-pygments==0.2.2jupyterlab_server==2.15.1keyring==23.5.0kiwisolver==1.3.2language-selector==0.1launchpadlib==1.10.16lazr.restfulclient==0.14.4lazr.uri==1.0.6lazy-object-proxy==0.0.0logilab-common==1.8.2louis==3.20.0lxml==4.9.1lz4==3.1.3+dfsgMagnus==1.0.3MarkupSafe==2.1.1mate-hud==22.4.4mate-tweak==22.4.8matplotlib==3.5.1matplotlib-inline==0.1.6mccabe==0.6.1mercurial==6.1.1mezcla==1.3.1mistune==2.0.4more-itertools==8.10.0mpmath==0.0.0msgpack==1.0.3mypy-extensions==0.4.3nbclassic==0.4.3nbclient==0.6.8nbconvert==7.0.0nbformat==5.5.0nest-asyncio==1.5.5netifaces==0.11.0notebook==6.4.12notebook-shim==0.1.0numpy==1.21.5oauthlib==3.2.0olefile==0.46onboard==1.4.1packaging==21.3pandas==1.5.0pandocfilters==1.5.0parso==0.8.3pexpect==4.8.0pickleshare==0.7.5Pillow==9.0.1platformdirs==2.5.1ply==3.11prometheus-client==0.14.1prompt-toolkit==3.0.31psutil==5.9.0ptyprocess==0.7.0pulsemixer==1.5.1pure-eval==0.2.2py==1.10.0pycairo==1.20.1pycparser==2.21pycups==2.0.1Pygments==2.13.0PyGObject==3.42.1PyJWT==2.3.0pylint==2.12.2pynvim==0.4.2pyparsing==2.4.7pyrsistent==0.18.1python-apt==2.3.0+ubuntu2.1python-dateutil==2.8.2python-debian===0.1.43ubuntu1python-xlib==0.29pythran==0.10.0pytz==2022.2.1pyxdg==0.27PyYAML==5.4.1pyzmq==24.0.0reportlab==3.6.8requests==2.28.1scipy==1.8.0SecretStorage==3.3.1Send2Trash==1.8.0setproctitle==1.2.2six==1.12.0sniffio==1.3.0soupsieve==2.3.2.post1stack-data==0.5.0sympy==1.9systemd-python==234terminado==0.15.0testpath==0.5.0tinycss2==1.1.1toml==0.10.2tomli==2.0.1tornado==6.2traitlets==5.4.0typing-extensions==3.10.0.2ubuntu-advantage-tools==27.10ubuntu-drivers-common==0.0.0ufoLib2==0.13.1ufw==0.36.1unattended-upgrades==0.1unicodedata2==14.0.0urllib3==1.26.12wadllib==1.3.6wcwidth==0.2.5webencodings==0.5.1websocket-client==1.4.1widgetsnbextension==2.0.0wrapt==1.13.3xdg==5xkit==0.0.0zipp==1.0.0'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	function python-module-version { python-module-version-full "$@" 2> /dev/null; }
	python-module-version-full mezcla
	linebr
	python-module-version mezcla
	linebr
	python-package-members mezcla
	actual=$(test12-assert7-actual)
	expected=$(test12-assert7-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert7-actual () {
	linebr
}
function test12-assert7-expected () {
	echo -e "1.3.1--------------------------------------------------------------------------------1.3.1--------------------------------------------------------------------------------['PYTHON3_PLUS', 'TL', '__VERSION__', '__all__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', 'debug', 'gh', 'glue_helpers', 'mezcla', 'sys', 'sys_version_info_hack', 'system', 'tpo_common']--------------------------------------------------------------------------------"
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	function rename-with-file-date() {
	## DEBUG: set -o xtrace
	local f new_f
	local move_command="move"
	if [ "$1" = "--copy" ]; then
	## TODO: move_command="copy"
	move_command="command cp --interactive --verbose --preserve"
	shift
	fi
	for f in "$@"; do
	## DEBUG: echo "f=$f"
	if [ -e "$f" ]; then
	new_f=$(get-free-filename "$f".$(date --reference="$f" '+%d%b%y') ".")
	## DEBUG: echo
	eval "$move_command" "$f" "$new_f";
	fi
	done;
	## DEBUG: set - -o xtrace
	}
	function get-free-filename() {
	local base="$1"
	local sep="$2"
	local L=1
	local filename="$base"
	## DEBUG: local -p
	while [ -e "$filename" ]; do
	let L++
	filename="$base$sep$L"
	done;
	## DEBUG: local -p
	echo "$filename"
	}
	alias move='mv'
	export PAGER=less
	export PAGER_CHOPPED="less -S"
	export PAGER_NOEXIT="less -+F"
	function zhead () {
	local file="$1"
	shift
	zcat "$file" | head "$@"
	}
	alias less-='$PAGER_NOEXIT'
	alias less-clipped='$PAGER_NOEXIT -S'
	alias less-tail='$PAGER_NOEXIT +G'
	alias less-tail-clipped='$PAGER_NOEXIT +G -S'
	alias ltc=less-tail-clipped
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	alias set-xterm-window='set_xterm_title.bash'
	function ipython() { 
	local ipython=$(which ipython)
	if [ "$ipython" = "" ]; then echo "Error: install ipython first"; return; fi
	set-xterm-window "ipython [$PWD]"
	$ipython "$@"
	function python-trace {
	local script="$1"
	shift
	$PYTHON -m trace --trace $(which "$script") "$@"
	ipython --version
}


@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	alias which-python='which python'
	which-python
	alias which-py3='which python3' #(ADDED FOR PYTHON3)
}


@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	printf "print('THIS IS A TEST')" > atest.py
	printf "print('THIS IS A TEST')" > xyz.py
	printf "print('THIS IS A TEST11')" > abc1.py
}


@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	function kivy-win32-env {
	export PYTHONPATH='c:/cartera-de-tomas/python;c:/Program-Misc/python/kivy-1-9-0/kivy27'
	kivy_dir="/c/Program-Misc/python/kivy-1-9-0"
	python_dir="$kivy_dir/Python27"
	prepend-path "$kivy_dir:$kivy_dir/Python27:$kivy_dir/tools:$kivy_dir/Python27/Scripts:$kivy_dir/gstreamer/bin:$kivy_dir/MinGW/bin:$kivy_dir/SDL2/bin"
	}
}


@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	alias elide-data='python -m transpose_data --elide'
	alias kill-python="kill_em.sh --filter 'ipython|emacs' python"
	alias kill-python-all="kill_em.sh python"
}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	alias TODAY='date'
	alias extract-matches='extract_matches.perl'
	function run-jupyter-notebook () {
	local port="$1"; if [ "$port" = "" ]; then port=8888; fi
	local ip="$2"; if [ "$ip" = "" ]; then ip="127.0.0.1"; fi
	local log="$TEMP/jupyter-$(TODAY).log"
	jupyter notebook --NotebookApp.token='' --no-browser --port $port --ip $ip >> "$log" 2>&1 &
	echo "$log"
	# Let jupyter initialize
	local delay=5
	echo "sleeping $delay seconds for log to stabalize (effing jupyter)"
	sleep $delay
	# TODO: resolve problem extracting URL
	# TEMP:
	tail "$log"
	# Show URL
	echo -n "URL: "
	extract-matches 'http:\S+' "$log" | sort -u
	}
	alias jupyter-notebook-redir=run-jupyter-notebook
	alias jupyter-notebook-redir-open='run-jupyter-notebook 8888 0.0.0.0'
}


@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	function extract-text() { python -m extract_document_text "$@"; }
	alias xtract-text='extract-text'
}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

	function test-script () {
	local base=$(basename "$1" .py)
	local date=$(todays-date)
	# note: uses both Mercurial root and . (in case not in repository)
	local root=$(hg root)
	PYTHONPATH="$root:.:$SANDBOX/tests:$PYTHONPATH" $NICE $PYTHON tests/test_$base.py --verbose >| tests/_test_$base.$date.log 2>&1;
	less-tail tests/_test_$base.$date.log;
	alias test-script-debug='ALLOW_SUBCOMMAND_TRACING=1 DEBUG_LEVEL=5 MISC_TRACING_LEVEL=5 test-script'
}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	function randomize-datafile() {
	local file="$1"
	local num_lines="$2"
	if [ "$num_lines" = "" ]; then num_lines=$(wc -l "$file"); fi
	#
	head -1 "$file"
	tail --lines=+2 "$file" | python -m randomize_lines | head -$num_lines
	}
}


@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	printf "print('THIS IS A TEST10')\nprint('THIS IS A TEST11')\nprint('THIS IS A TEST12')\nprint('THIS IS A TEST13')" > random_line_test.py
	actual=$(test23-assert2-actual)
	expected=$(test23-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test23-assert2-actual () {
	ls
}
function test23-assert2-expected () {
	echo -e 'abc1.py  atest.py  random_line_test.py  xyz.py'
}

@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	function filter-random() {
	local pct="$1"
	local file="$2"
	local include_header="$3"
	if [ "$include_header" == "" ]; then include_header=1; fi
	# Derive settings from input arguments
	local ratio=$(perl -e "printf('%.3f', ($pct / 100.0));")
	local compressed=0
	if [[ $file =~ .gz ]]; then compressed=1; fi
	local dir=$(dirname $file)
	local base=$(basename $file)
	local type="cat"
	local result="$dir/_r${pct}pct-$base"
	# Filter the file, optionally uncompressing
	if [ "$compressed" = "1" ]; then 
	type="zcat"; 
	result=$(echo "$result" | perl -pe 's/.gz$//;')
	fi
	local opts=""
	if [ "$include_header" = "1" ]; then opts="$opt --include-header"; fi
	$type "$file" | $PYTHON -m filter_random $opts --ratio $ratio - > "$result" 2> "$result.log"
	# Compress result if original compressed
	if [ "$compressed" = "1" ]; then 
	gzip --force "$result"; 
	fi
	}
}


@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	function conditional-source () { if [ -e "$1" ]; then source "$1"; else echo "Warning: bash script file not found (so not sourced):"; echo "    $1"; fi; }
	function quiet-unalias {
	## HACK: do nothing if running under bats-core
	if [ "$BATS_TEST_FILENAME" != "" ]; then
	if [ "$BATCH_MODE" != "1" ]; then
	echo "Ignoring unalias over $* for sake of bats"
	fi
	return
	fi
	## OLD: unalias "$@" 2> /dev/null;
	unalias "$@" 2> /dev/null || true;
	## OLD: echo > /dev/null;
	}
	conditional-source $BIN_DIR/anaconda-aliases.bash
	conditional-source $BIN_DIR/git-aliases.bash
}


@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	function curl-dump () {
	local url="$1";
	local base=$(basename $url);
	curl $url > $base;
	function url-path () {
	local file="$1"
	echo $(realpath "$file") | perl -pe 's@^@file:///@;'
	curl-dump https://www.google.com
	linebr
	ls -l
	linebr
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	function invoke-browser() {
	local browser_executable="$1"
	local file="$2"
	if [ "$file" != "" ]; then
	if [[ ! $file =~ http ]]; then
	file=$(url-path "$file")
	fi
	fi
	## TODO?
	## if [ ! -e "$browser_executable" ]; then
	##     browser_executable_path=$(which "browser_executable")
	##     if [ "$browser_executable_path" = "" ]; then browser_executable="$_path"; fi   
	## fi
	local browser_base=$(basename "$browser_executable")
	$browser_executable "$file" >> $TEMP/$browser_base.$(TODAY).log 2>&1 &
	}
	alias firefox='invoke-browser "'"$(which firefox)"'"'
}


@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	pwd
}
