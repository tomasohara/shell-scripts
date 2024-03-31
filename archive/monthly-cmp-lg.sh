#! /bin/csh
#
# monthly-cmp-lg.sh: stupid script to invoke monthly-cmp-lg.perl getting around
#  stupid environment problems with perl not being standard in path
#

set echo=1
perl -Ssw monthly-cmp-lg.perl -d=4 "$*"
