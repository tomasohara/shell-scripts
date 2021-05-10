#! /bin/csh -f

set echo=1
my_rexec.sh w
grep -B1 load _w_.list | perl -pn -e 's/([a-z])\n/\1/; s/: /:\t/;' > temp_load.list
grep -v "\-\-" temp_load.list | perl -pn -e 's/([^\t]+)\t(.*)/\2 \1 \2/;'

