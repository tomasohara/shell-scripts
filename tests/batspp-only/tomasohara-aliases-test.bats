#!/usr/bin/env bats
#
# This test file was generated using Batspp
# https://github.com/LimaBD/batspp
#

# Constants
VERBOSE_DEBUG=""
TEMP_DIR="/tmp/batspp-106812"

# Setup function
# $1 -> test name
function run_setup () {
	test_folder=$(echo $TEMP_DIR/$1-$$)
	mkdir --parents "$test_folder"
	cd "$test_folder" || echo Warning: Unable to "cd $test_folder"
}

# Teardown function
function run_teardown () {
	: # Nothing here...
}

@test "test of line 1" {
	run_setup "test-of-line-1"

	# Assertion of line 1
	shopt -s expand_aliases
	print_debug "$(ls *.html)" "$(echo -e 'template.html\n')"
	[ "$(ls *.html)" == "$(echo -e 'template.html\n')" ]

	run_teardown
}

@test "test of line 4" {
	run_setup "test-of-line-4"

	# Assertion of line 4
	shopt -s expand_aliases
	print_debug "$(url-path template.html)" "$(echo -e 'file:////home/tomohara/bin/template.html\n')"
	[ "$(url-path template.html)" == "$(echo -e 'file:////home/tomohara/bin/template.html\n')" ]

	run_teardown
}

# This prints debug data when an assertion fail
# $1 -> actual value
# $2 -> expected value
function print_debug() {
	echo "=======  actual  ======="
	bash -c "echo \"$1\" $VERBOSE_DEBUG"
	echo "======= expected ======="
	bash -c "echo \"$2\" $VERBOSE_DEBUG"
	echo "========================"
}
