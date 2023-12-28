#! /bin/csh -f
#
# soffice.sh: wrapper around soffice that enables the csh environment first
#

source /local/config/cshrc.staroffice
soffice $* &
