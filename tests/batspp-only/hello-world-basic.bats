#!/usr/bin/env bats
#
# This test file was generated using Batspp
# https://github.com/LimaBD/batspp
#

# Constants
VERBOSE_DEBUG=""
TEMP_DIR="/tmp/batspp-106732"

# Setup function
# $1 -> test name
function run_setup () {
	test_folder=$(echo $TEMP_DIR/$1-$$)
	mkdir --parents "$test_folder"
	cd "$test_folder" || echo Warning: Unable to "cd $test_folder"
	bind 'set enable-bracketed-paste off'
	echo "BIND ON!"
}

# Teardown function
function run_teardown () {
	: # Nothing here...
}

@test "test of line 5" {
	run_setup "test-of-line-5"

	# Assertion of line 5
	shopt -s expand_aliases
	print_debug "$(echo "Hi Mom!")" "$(echo -e 'Hi Mom!\n')"
	[ "$(echo "Hi Mom!")" == "$(echo -e 'Hi Mom!\n')" ]

	run_teardown
}

@test "test of line 8" {
	run_setup "test-of-line-8"

	# Assertion of line 8
	shopt -s expand_aliases
	print_debug "$(echo 'Hello world' | wc -l)" "$(echo -e '1\n')"
	[ "$(echo 'Hello world' | wc -l)" == "$(echo -e '1\n')" ]

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
