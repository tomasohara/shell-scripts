#!/usr/bin/env bats
#
# This test file was generated using Batspp
# https://github.com/LimaBD/batspp
#

# Constants
VERBOSE_DEBUG=""
TEMP_DIR="/tmp/batspp-107003"

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

@test "test of line 4" {
	run_setup "test-of-line-4"

	# Assertion of line 7
	alias count-words='wc -w'
	alias count-lines='wc -l'
	echo abc def ght | count-words
	shopt -s expand_aliases
	print_debug "$(echo abc def ght | count-lines)" "$(echo -e '3\n1\n')"
	[ "$(echo abc def ght | count-lines)" == "$(echo -e '3\n1\n')" ]

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
