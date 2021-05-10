#! /bin/csh -f

# 1) get dict.dat from Software Toolwork's Reference Library CD

# 2) separate into smaller files
#
gsplit --lines=40000 dict.dat dict_

# 3) convert new-entry chars (^B) to newlines and remove other special codes
#
perl -i.bak -p -e "s/\x02 */\n/; s/[^\x20-\x7F\x0D\x0A\x09]//g;" dict_a?

# 4) verify files and then remove backup files
#
