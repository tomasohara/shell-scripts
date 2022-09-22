#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

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

	alias apt-install='apt-get install --yes --fix-missing --no-remove'
	alias apt-search='apt-cache search'
	alias apt-installed='apt list --installed'
	alias apt-uninstall='apt-get remove'
	alias dpkg-install='dpkg --install '
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
	apt-installed *python3*
}
function test7-assert1-expected () {
	echo -e 'Listing... Done\x1b[32mipython3\x1b[0m/jammy,jammy,now 7.31.1-1 all [installed]\x1b[32mlibpython3-dev\x1b[0m/jammy,now 3.10.4-0ubuntu2 amd64 [installed,automatic]\x1b[32mlibpython3-stdlib\x1b[0m/jammy,now 3.10.4-0ubuntu2 amd64 [installed,automatic]\x1b[32mlibpython3.10-dev\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mlibpython3.10-minimal\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mlibpython3.10-stdlib\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mlibpython3.10\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mpython3-appdirs\x1b[0m/jammy,jammy,now 1.4.4-2 all [installed,automatic]\x1b[32mpython3-apport\x1b[0m/jammy-updates,jammy-updates,jammy-security,jammy-security,now 2.20.11-0ubuntu82.1 all [installed,automatic]\x1b[32mpython3-apt\x1b[0m/jammy-updates,now 2.3.0ubuntu2.1 amd64 [installed,automatic]\x1b[32mpython3-aptdaemon\x1b[0m/jammy,jammy,now 1.1.1+bzr982-0ubuntu39 all [installed,automatic]\x1b[32mpython3-argon2\x1b[0m/jammy,now 21.1.0-1 amd64 [installed,automatic]\x1b[32mpython3-attr\x1b[0m/jammy,jammy,now 21.2.0-1 all [installed,automatic]\x1b[32mpython3-babel\x1b[0m/jammy,jammy,now 2.8.0+dfsg.1-7 all [installed,automatic]\x1b[32mpython3-backcall\x1b[0m/jammy,jammy,now 0.2.0-2 all [installed,automatic]\x1b[32mpython3-beniget\x1b[0m/jammy,jammy,now 0.4.1-2 all [installed,automatic]\x1b[32mpython3-bleach\x1b[0m/jammy,jammy,now 4.1.0-1 all [installed,automatic]\x1b[32mpython3-blinker\x1b[0m/jammy,jammy,now 1.4+dfsg1-0.4 all [installed,automatic]\x1b[32mpython3-brotli\x1b[0m/jammy,now 1.0.9-2build6 amd64 [installed,automatic]\x1b[32mpython3-bs4\x1b[0m/jammy,jammy,now 4.10.0-2 all [installed,automatic]\x1b[32mpython3-cairo\x1b[0m/jammy,now 1.20.1-3build1 amd64 [installed,automatic]\x1b[32mpython3-certifi\x1b[0m/jammy,jammy,now 2020.6.20-1 all [installed,automatic]\x1b[32mpython3-cffi-backend\x1b[0m/jammy,now 1.15.0-1build2 amd64 [installed,automatic]\x1b[32mpython3-chardet\x1b[0m/jammy,jammy,now 4.0.0-1 all [installed,automatic]\x1b[32mpython3-click\x1b[0m/jammy,jammy,now 8.0.3-1 all [installed,automatic]\x1b[32mpython3-colorama\x1b[0m/jammy,jammy,now 0.4.4-1 all [installed,automatic]\x1b[32mpython3-commandnotfound\x1b[0m/jammy,jammy,now 22.04.0 all [installed,automatic]\x1b[32mpython3-configobj\x1b[0m/jammy,jammy,now 5.0.6-5 all [installed,automatic]\x1b[32mpython3-cryptography\x1b[0m/jammy,now 3.4.8-1ubuntu2 amd64 [installed,automatic]\x1b[32mpython3-cups\x1b[0m/jammy,now 2.0.1-5build1 amd64 [installed,automatic]\x1b[32mpython3-cupshelpers\x1b[0m/jammy,jammy,now 1.5.16-0ubuntu3 all [installed,automatic]\x1b[32mpython3-cycler\x1b[0m/jammy,jammy,now 0.11.0-1 all [installed,automatic]\x1b[32mpython3-dateutil\x1b[0m/jammy,jammy,now 2.8.1-6 all [installed,automatic]\x1b[32mpython3-dbus.mainloop.pyqt5\x1b[0m/jammy,now 5.15.6+dfsg-1ubuntu3 amd64 [installed,automatic]\x1b[32mpython3-dbus\x1b[0m/jammy,now 1.2.18-3build1 amd64 [installed,automatic]\x1b[32mpython3-debconf\x1b[0m/jammy,jammy,now 1.5.79ubuntu1 all [installed,automatic]\x1b[32mpython3-debian\x1b[0m/jammy,jammy,now 0.1.43ubuntu1 all [installed,automatic]\x1b[32mpython3-decorator\x1b[0m/jammy,jammy,now 4.4.2-0ubuntu1 all [installed,automatic]\x1b[32mpython3-defer\x1b[0m/jammy,jammy,now 1.0.6-2.1ubuntu1 all [installed,automatic]\x1b[32mpython3-defusedxml\x1b[0m/jammy,jammy,now 0.7.1-1 all [installed,automatic]\x1b[32mpython3-dev\x1b[0m/jammy,now 3.10.4-0ubuntu2 amd64 [installed,automatic]\x1b[32mpython3-distro-info\x1b[0m/jammy,jammy,now 1.1build1 all [installed,automatic]\x1b[32mpython3-distro\x1b[0m/jammy,jammy,now 1.7.0-1 all [installed,automatic]\x1b[32mpython3-distupgrade\x1b[0m/now 1:22.04.12 all [installed,upgradable to: 1:22.04.13]\x1b[32mpython3-distutils\x1b[0m/jammy,jammy,now 3.10.4-0ubuntu1 all [installed,automatic]\x1b[32mpython3-entrypoints\x1b[0m/jammy,jammy,now 0.4-1 all [installed,automatic]\x1b[32mpython3-exif\x1b[0m/jammy,jammy,now 2.3.2-1 all [installed,automatic]\x1b[32mpython3-exifread\x1b[0m/jammy,jammy,now 2.3.2-1 all [installed,automatic]\x1b[32mpython3-flask\x1b[0m/jammy,jammy,now 2.0.1-2ubuntu1 all [installed,automatic]\x1b[32mpython3-fonttools\x1b[0m/jammy,now 4.29.1-2build1 amd64 [installed,automatic]\x1b[32mpython3-fs\x1b[0m/jammy,jammy,now 2.4.12-1 all [installed,automatic]\x1b[32mpython3-gast\x1b[0m/jammy,jammy,now 0.5.2-2 all [installed,automatic]\x1b[32mpython3-gdbm\x1b[0m/jammy,now 3.10.4-0ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-gi-cairo\x1b[0m/jammy-updates,now 3.42.1-0ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-gi\x1b[0m/jammy-updates,now 3.42.1-0ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-greenlet\x1b[0m/jammy,now 1.1.2-3build1 amd64 [installed,automatic]\x1b[32mpython3-html5lib\x1b[0m/jammy,jammy,now 1.1-3 all [installed,automatic]\x1b[32mpython3-httplib2\x1b[0m/jammy,jammy,now 0.20.2-2 all [installed,automatic]\x1b[32mpython3-idna\x1b[0m/jammy,jammy,now 3.3-1 all [installed,automatic]\x1b[32mpython3-importlib-metadata\x1b[0m/jammy,jammy,now 4.6.4-1 all [installed,automatic]\x1b[32mpython3-inifile\x1b[0m/jammy,jammy,now 0.4.1-1 all [installed,automatic]\x1b[32mpython3-ipykernel\x1b[0m/jammy,jammy,now 6.7.0-1 all [installed,automatic]\x1b[32mpython3-ipython-genutils\x1b[0m/jammy,jammy,now 0.2.0-5 all [installed,automatic]\x1b[32mpython3-ipython\x1b[0m/jammy,jammy,now 7.31.1-1 all [installed,automatic]\x1b[32mpython3-ipywidgets\x1b[0m/jammy,jammy,now 6.0.0-9 all [installed,automatic]\x1b[32mpython3-itsdangerous\x1b[0m/jammy,jammy,now 2.1.0-1 all [installed,automatic]\x1b[32mpython3-jedi\x1b[0m/jammy,jammy,now 0.18.0-1 all [installed,automatic]\x1b[32mpython3-jeepney\x1b[0m/jammy,jammy,now 0.7.1-3 all [installed,automatic]\x1b[32mpython3-jinja2\x1b[0m/jammy,jammy,now 3.0.3-1 all [installed,automatic]\x1b[32mpython3-jsonschema\x1b[0m/jammy,jammy,now 3.2.0-0ubuntu2 all [installed,automatic]\x1b[32mpython3-jupyter-client\x1b[0m/jammy,jammy,now 7.1.2-1 all [installed,automatic]\x1b[32mpython3-jupyter-console\x1b[0m/jammy,jammy,now 6.4.0-3 all [installed,automatic]\x1b[32mpython3-jupyter-core\x1b[0m/jammy,jammy,now 4.9.1-1 all [installed,automatic]\x1b[32mpython3-jupyterlab-pygments\x1b[0m/jammy,jammy,now 0.1.2-8 all [installed,automatic]\x1b[32mpython3-jwt\x1b[0m/jammy-updates,jammy-updates,jammy-security,jammy-security,now 2.3.0-1ubuntu0.2 all [installed,automatic]\x1b[32mpython3-keyring\x1b[0m/jammy,jammy,now 23.5.0-1 all [installed,automatic]\x1b[32mpython3-kiwisolver\x1b[0m/jammy,now 1.3.2-1build1 amd64 [installed,automatic]\x1b[32mpython3-launchpadlib\x1b[0m/jammy,jammy,now 1.10.16-1 all [installed]\x1b[32mpython3-lazr.restfulclient\x1b[0m/jammy,jammy,now 0.14.4-1 all [installed,automatic]\x1b[32mpython3-lazr.uri\x1b[0m/jammy,jammy,now 1.0.6-2 all [installed,automatic]\x1b[32mpython3-ldb\x1b[0m/jammy-updates,jammy-security,now 2:2.4.4-0ubuntu0.1 amd64 [installed,automatic]\x1b[32mpython3-lib2to3\x1b[0m/jammy,jammy,now 3.10.4-0ubuntu1 all [installed,automatic]\x1b[32mpython3-lxml\x1b[0m/jammy,now 4.8.0-1build1 amd64 [installed,automatic]\x1b[32mpython3-lz4\x1b[0m/jammy,now 3.1.3+dfsg-1build3 amd64 [installed,automatic]\x1b[32mpython3-markupsafe\x1b[0m/jammy,now 2.0.1-2build1 amd64 [installed,automatic]\x1b[32mpython3-matplotlib-inline\x1b[0m/jammy,jammy,now 0.1.3-1 all [installed,automatic]\x1b[32mpython3-matplotlib\x1b[0m/jammy,now 3.5.1-2build1 amd64 [installed,automatic]\x1b[32mpython3-minimal\x1b[0m/jammy,now 3.10.4-0ubuntu2 amd64 [installed,automatic]\x1b[32mpython3-mistune\x1b[0m/jammy,jammy,now 2.0.0-1+really0.8.4-1 all [installed,automatic]\x1b[32mpython3-more-itertools\x1b[0m/jammy,jammy,now 8.10.0-2 all [installed,automatic]\x1b[32mpython3-mpmath\x1b[0m/jammy,jammy,now 1.2.1-2 all [installed,automatic]\x1b[32mpython3-msgpack\x1b[0m/jammy,now 1.0.3-1build1 amd64 [installed,automatic]\x1b[32mpython3-nbclient\x1b[0m/jammy,jammy,now 0.5.6-2 all [installed,automatic]\x1b[32mpython3-nbconvert\x1b[0m/jammy,jammy,now 6.4.0-1 all [installed,automatic]\x1b[32mpython3-nbformat\x1b[0m/jammy,jammy,now 5.1.3-1 all [installed,automatic]\x1b[32mpython3-neovim\x1b[0m/jammy,jammy,now 0.4.2-1 all [installed,automatic]\x1b[32mpython3-nest-asyncio\x1b[0m/jammy,jammy,now 1.5.4-1 all [installed,automatic]\x1b[32mpython3-netifaces\x1b[0m/jammy,now 0.11.0-1build2 amd64 [installed,automatic]\x1b[32mpython3-notebook\x1b[0m/jammy-updates,jammy-updates,jammy-security,jammy-security,now 6.4.8-1ubuntu0.1 all [installed,automatic]\x1b[32mpython3-numpy\x1b[0m/jammy,now 1:1.21.5-1build2 amd64 [installed,automatic]\x1b[32mpython3-oauthlib\x1b[0m/jammy,jammy,now 3.2.0-1 all [installed,automatic]\x1b[32mpython3-olefile\x1b[0m/jammy,jammy,now 0.46-3 all [installed,automatic]\x1b[32mpython3-openssl\x1b[0m/jammy,jammy,now 21.0.0-1 all [installed,automatic]\x1b[32mpython3-packaging\x1b[0m/jammy,jammy,now 21.3-1 all [installed,automatic]\x1b[32mpython3-pandocfilters\x1b[0m/jammy,jammy,now 1.5.0-1 all [installed,automatic]\x1b[32mpython3-parso\x1b[0m/jammy,jammy,now 0.8.1-1 all [installed,automatic]\x1b[32mpython3-pexpect\x1b[0m/jammy,jammy,now 4.8.0-2ubuntu1 all [installed,automatic]\x1b[32mpython3-pickleshare\x1b[0m/jammy,jammy,now 0.7.5-5 all [installed,automatic]\x1b[32mpython3-pil.imagetk\x1b[0m/jammy,now 9.0.1-1build1 amd64 [installed,automatic]\x1b[32mpython3-pil\x1b[0m/jammy,now 9.0.1-1build1 amd64 [installed,automatic]\x1b[32mpython3-pip\x1b[0m/jammy,jammy,now 22.0.2+dfsg-1 all [installed]\x1b[32mpython3-pkg-resources\x1b[0m/jammy,jammy,now 59.6.0-1.2 all [installed,automatic]\x1b[32mpython3-ply\x1b[0m/jammy,jammy,now 3.11-5 all [installed,automatic]\x1b[32mpython3-problem-report\x1b[0m/jammy-updates,jammy-updates,jammy-security,jammy-security,now 2.20.11-0ubuntu82.1 all [installed,automatic]\x1b[32mpython3-prometheus-client\x1b[0m/jammy,jammy,now 0.9.0-1 all [installed,automatic]\x1b[32mpython3-prompt-toolkit\x1b[0m/jammy,jammy,now 3.0.28-1 all [installed,automatic]\x1b[32mpython3-psutil\x1b[0m/jammy,now 5.9.0-1build1 amd64 [installed,automatic]\x1b[32mpython3-ptyprocess\x1b[0m/jammy,jammy,now 0.7.0-3 all [installed,automatic]\x1b[32mpython3-py\x1b[0m/jammy,jammy,now 1.10.0-1 all [installed,automatic]\x1b[32mpython3-pygments\x1b[0m/jammy,jammy,now 2.11.2+dfsg-2 all [installed,automatic]\x1b[32mpython3-pyinotify\x1b[0m/jammy,jammy,now 0.9.6-1.3 all [installed,automatic]\x1b[32mpython3-pynvim\x1b[0m/jammy,jammy,now 0.4.2-1 all [installed,automatic]\x1b[32mpython3-pyparsing\x1b[0m/jammy,jammy,now 2.4.7-1 all [installed,automatic]\x1b[32mpython3-pyqt5.sip\x1b[0m/jammy,now 12.9.1-1build1 amd64 [installed,automatic]\x1b[32mpython3-pyqt5\x1b[0m/jammy,now 5.15.6+dfsg-1ubuntu3 amd64 [installed,automatic]\x1b[32mpython3-pyrsistent\x1b[0m/jammy,now 0.18.1-1build1 amd64 [installed,automatic]\x1b[32mpython3-pythran\x1b[0m/jammy,now 0.10.0+ds2-1 amd64 [installed,automatic]\x1b[32mpython3-renderpm\x1b[0m/jammy,now 3.6.8-1 amd64 [installed,automatic]\x1b[32mpython3-reportlab-accel\x1b[0m/jammy,now 3.6.8-1 amd64 [installed,automatic]\x1b[32mpython3-reportlab\x1b[0m/jammy,jammy,now 3.6.8-1 all [installed,automatic]\x1b[32mpython3-requests\x1b[0m/jammy,jammy,now 2.25.1+dfsg-2 all [installed,automatic]\x1b[32mpython3-scipy\x1b[0m/jammy,now 1.8.0-1exp2ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-secretstorage\x1b[0m/jammy,jammy,now 3.3.1-1 all [installed,automatic]\x1b[32mpython3-send2trash\x1b[0m/jammy,jammy,now 1.8.1~b0-1 all [installed,automatic]\x1b[32mpython3-setuptools\x1b[0m/jammy,jammy,now 59.6.0-1.2 all [installed,automatic]\x1b[32mpython3-simplejson\x1b[0m/jammy,now 3.17.6-1build1 amd64 [installed,automatic]\x1b[32mpython3-six\x1b[0m/jammy,jammy,now 1.16.0-3ubuntu1 all [installed,automatic]\x1b[32mpython3-software-properties\x1b[0m/now 0.99.22.2 all [installed,upgradable to: 0.99.22.3]\x1b[32mpython3-soupsieve\x1b[0m/jammy,jammy,now 2.3.1-1 all [installed,automatic]\x1b[32mpython3-sympy\x1b[0m/jammy,jammy,now 1.9-1 all [installed,automatic]\x1b[32mpython3-systemd\x1b[0m/jammy,now 234-3ubuntu2 amd64 [installed,automatic]\x1b[32mpython3-talloc\x1b[0m/jammy,now 2.3.3-2build1 amd64 [installed,automatic]\x1b[32mpython3-terminado\x1b[0m/jammy,jammy,now 0.13.1-1 all [installed,automatic]\x1b[32mpython3-testpath\x1b[0m/jammy,jammy,now 0.5.0+dfsg-1 all [installed,automatic]\x1b[32mpython3-tk\x1b[0m/jammy,now 3.10.4-0ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-tornado\x1b[0m/jammy,now 6.1.0-3build1 amd64 [installed,automatic]\x1b[32mpython3-traitlets\x1b[0m/jammy,jammy,now 5.1.1-1 all [installed,automatic]\x1b[32mpython3-tz\x1b[0m/jammy,jammy,now 2022.1-1 all [installed,automatic]\x1b[32mpython3-ufolib2\x1b[0m/jammy,jammy,now 0.13.1+dfsg1-1 all [installed,automatic]\x1b[32mpython3-unicodedata2\x1b[0m/jammy,now 14.0.0+ds-8 amd64 [installed,automatic]\x1b[32mpython3-uno\x1b[0m/jammy-updates,now 1:7.3.5-0ubuntu0.22.04.1 amd64 [installed,automatic]\x1b[32mpython3-update-manager\x1b[0m/jammy,jammy,now 1:22.04.9 all [installed,automatic]\x1b[32mpython3-urllib3\x1b[0m/jammy,jammy,now 1.26.5-1~exp1 all [installed,automatic]\x1b[32mpython3-wadllib\x1b[0m/jammy,jammy,now 1.3.6-1 all [installed,automatic]\x1b[32mpython3-watchdog\x1b[0m/jammy,jammy,now 2.1.6-1 all [installed,automatic]\x1b[32mpython3-wcwidth\x1b[0m/jammy,jammy,now 0.2.5+dfsg1-1 all [installed,automatic]\x1b[32mpython3-webencodings\x1b[0m/jammy,jammy,now 0.5.1-4 all [installed,automatic]\x1b[32mpython3-werkzeug\x1b[0m/jammy,jammy,now 2.0.2+dfsg1-1 all [installed,automatic]\x1b[32mpython3-wheel\x1b[0m/jammy,jammy,now 0.37.1-2 all [installed,automatic]\x1b[32mpython3-widgetsnbextension\x1b[0m/jammy,jammy,now 6.0.0-9 all [installed,automatic]\x1b[32mpython3-xapian\x1b[0m/jammy,now 1.4.18-2build3 amd64 [installed,automatic]\x1b[32mpython3-xdg\x1b[0m/jammy,jammy,now 0.27-2 all [installed,automatic]\x1b[32mpython3-xkit\x1b[0m/jammy,jammy,now 0.5.0ubuntu5 all [installed,automatic]\x1b[32mpython3-yaml\x1b[0m/jammy,now 5.4.1-1ubuntu1 amd64 [installed,automatic]\x1b[32mpython3-zipp\x1b[0m/jammy,jammy,now 1.0.0-3 all [installed,automatic]\x1b[32mpython3-zmq\x1b[0m/jammy,now 22.3.0-1build1 amd64 [installed,automatic]\x1b[32mpython3.10-dev\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mpython3.10-minimal\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mpython3.10\x1b[0m/jammy-updates,jammy-security,now 3.10.4-3ubuntu0.1 amd64 [installed,automatic]\x1b[32mpython3\x1b[0m/jammy,now 3.10.4-0ubuntu2 amd64 [installed]'
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
	apt-search rolldice
}
function test8-assert1-expected () {
	echo -e 'rolldice - virtual dice roller'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	alias restart-network='sudo ifdown eth0; sudo ifup eth0'
	alias hibernate-system='sudo systemctl hibernate'
	alias suspend-system='sudo systemctl suspend'
	alias blank-screen='xset dpms force off'
	alias stop-service='systemctl stop'
	alias start-service='systemctl start'
	alias list-all-service='systemctl --type=service'
	alias restart-service-sudoless='systemctl restart'
	alias status-service='systemctl status'
	alias service-status='status-service'
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
}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	printf "HELLO THERE,\nI AM EXTREMELY PLEASED TO USE UBUNTU." > abc.txt
	get-free-filename "abc.txt" 2      #DOUBT(?)
	linebr
	ls -l
	linebr
	actual=$(test14-assert6-actual)
	expected=$(test14-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert6-actual () {
	cat "abc.txt"
}
function test14-assert6-expected () {
	echo -e 'abc.txt22--------------------------------------------------------------------------------total 4-rw-rw-r-- 1 aveey aveey 50 Sep  8 22:05 abc.txt--------------------------------------------------------------------------------HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.'
}
