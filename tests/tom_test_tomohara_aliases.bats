#!/usr/bin/env bats
#
# Tests for tomohara-aliases.bash
#
# Note: uses new testing utility in the works batspp.py:
#    https://github.com/tomasohara/shell-scripts/blob/bruno-dev/batspp.py
#

setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

    # make executables in ../ visible to PATH
    PATH="$DIR/../:$PATH"

    # Load aliases
    shopt -s expand_aliases
    ## OLD: source tomohara-aliases.bash || true
    source tomohara-aliases.bash

    ## DEBUG: 
    ## echo "number of aliases and functions defined:" >| /tmp/_setup.$$.list
    ## alias | wc -l  >> /tmp/_setup.$$.list
    ## TODO: typeset -f | wc-l  >> /tmp/_setup.$$.list
    ## echo "aliases and functions defined:" >| /tmp/_setup.$$.log
    ## alias >> /tmp/_setup.$$.log
}


@test "alias count-it" {
    result=$(echo "12 34 56 78" | count-it "\\d\\d" | wc -l)
    [ $result -eq 4 ]
}


@test "alias copy-with-file-date" {
    FILENAME="date_rename_test.$$.txt"

    # Clean
    echo rm /tmp/${FILENAME}*

    # Create test file
    touch /tmp/$FILENAME
    ## DEBUG: rename-with-file-date --copy /tmp/$FILENAME
    copy-with-file-date /tmp/$FILENAME

    # Check
    [ $(ls /tmp/${FILENAME}.* | wc -l) -eq 1 ]
}


@test "rename-with-file-date" {
    FILENAME="date_rename_test.$$.txt"

    # Clean
    echo rm /tmp/${FILENAME}*

    # Create test file
    touch /tmp/$FILENAME
    rename-with-file-date /tmp/$FILENAME

    # Check
    [ $(ls /tmp/${FILENAME}.* | wc -l) -eq 1 ]
}
