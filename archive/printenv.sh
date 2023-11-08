#! /bin/bash
#
# printenv.sh: display environment (in case /bin/printenv not available)
#
# TODO:
# - include templates for common bash expressions, for example:
#     if [ $x = value ]; then STMT; fi
#     if [[ (EXPR1) && (EXPR2) ]]; then STMT; fi
#

if [ "$1" = "" ]; then set "[^ ]+"; fi

while [ "$1" != "" ]; do
    set | egrep "^${1}="
    shift
done
