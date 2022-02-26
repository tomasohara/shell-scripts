# Example tests using BATSPP.
#
# Usage: $ batspp batspp_example.bash
#


# You can run tests using the command line 
# With '$ [command]' followed by the expected output.
#
# $ echo -e "hello\nworld"
# hello
# world
#
# $ echo "this is a test" | wc -c
# 15


# Also you can test bash functions:
#
# This test should work fine:
# fibonacci 9 => "0 1 1 2 3 5 8 13 21 34"
#
# This is a negative test:
# fibonacci 3 =/> "8 2 45 34 3 5"
#
function fibonacci () {
    result=""

    a=0
    b=1
    for (( i=0; i<=$1; i++ ))
    do
        result="$result$a "
        fn=$((a + b))
        a=$b
        b=$fn
    done

    echo $result
}


# And you can test aliases too:
#
# $ run-fibonacci 9
# The Fibonacci series is:
# 0 1 1 2 3 5 8 13 21 34
#
alias run-fibonacci='echo "The Fibonacci series is:"; fibonacci'
