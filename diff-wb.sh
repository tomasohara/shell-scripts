#! /bin/sh
#
# diff-wb.sh: very simple wrapper around diff that accounts for whitespace
#
# Notes:
# - See diff.sh for more flexible version.
# - Diff options:
#   -b  --ignore-space-change: Ignore changes in the amount of white space.
#   -w  --ignore-all-space: Ignore all white space.
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

diff -wb "$@"
