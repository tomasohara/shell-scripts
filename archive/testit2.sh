#! /bin/csh -f

echo "in testit2"
set echo = 1
echo "?0 = $?0"
echo '$0 = ' $0
set script_dir = `dirname $0`
source ${script_dir}/testit.sh
echo "stupid = $stupid"
