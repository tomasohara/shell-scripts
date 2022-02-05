#!/usr/bin/env bats
#
# Tests for tomohara-aliases.bash


setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

    # make executables in ../ visible to PATH
    PATH="$DIR/../:$PATH"

    # Load aliases
    shopt -s expand_aliases
    source tomohara-aliases.bash || true
}


@test "alias count-it" {
    result=$(echo "12 34 56 78" | count-it "\\d\\d" | wc -l)
    [ $result -eq 4 ]
}


@test "alias copy-with-file-date" {
    FILENAME=$(echo copy-test-"$$".txt)

    # Create test file
    touch /tmp/$FILENAME
    copy-with-file-date /tmp/$FILENAME

    # Check
    [ $(ls /tmp/${FILENAME}.* | wc -l) -eq 1 ]
}
