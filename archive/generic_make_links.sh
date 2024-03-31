#!/bin/csh -f
#
# This script creates symbolic links to the scripts w/o the .sh extension.
# This faciliates working with the files in groups (eg, "grep coco *.sh").
#
# TODO: ignore backup files (eg, g2.BAK)

# Set command tracing
set echo=1

# Produce a list of all csh-based scripts w/o the fast load option
#
grep '#!\/bin\/csh *$' * > temp_scripts.list

# Convert the list into a series of symbolic link commands
#   g2:#!/bin/csh
#   maketest:#!/bin/csh
# =>
#   ln -s g2 g2.sh
#   ln -s maketest maktest.sh
#
perl -pn -e 's/([^:]+):.*#!\/bin\/csh *$/ln -s \1 \1.sh/g;' < temp_scripts.list > temp_make_links.sh

# Execute the symbolic link commands
#
source temp_make_links.sh

# Cleanup
#
# rm temp_scripts.list
# rm temp_make_links.sh
