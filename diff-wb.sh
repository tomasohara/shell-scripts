#! /bin/sh
#
# diff-wb.sh: simple wrapper around diff that accounts for whitespace
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

diff -wb "$@"
