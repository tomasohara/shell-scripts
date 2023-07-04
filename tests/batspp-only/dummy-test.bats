#!/usr/bin/env bats
#
# This test file was generated using Batspp
# https://github.com/LimaBD/batspp
#

# Constants
VERBOSE_DEBUG=""
TEMP_DIR="/tmp/batspp-107056"

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

@test "test of line 5" {
	run_setup "test-of-line-5"

	# Assertion of line 5
	shopt -s expand_aliases
	print_debug "$(echo dummy)" "$(echo -e 'dummy\n')"
	[ "$(echo dummy)" == "$(echo -e 'dummy\n')" ]

	run_teardown
}

@test "test of line 9" {
	run_setup "test-of-line-9"

	# Assertion of line 9
	shopt -s expand_aliases
	print_debug "$(date)" "$(echo -e 'Wed Jun 21 06:30:51 CDT 2023\n')"
	[ "$(date)" == "$(echo -e 'Wed Jun 21 06:30:51 CDT 2023\n')" ]

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
