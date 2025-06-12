#! /bin/csh -f
#
# remove_exp_junk.sh: place junk let over from an experiment in a subdirectory JUNK
#

if (! -e JUNK) mkdir JUNK
mv SAMPLE* JUNK/
mv *.t[0-9]* JUNK/
mv table* JUNK/
mv SIDFILE* JUNK/
mv senten* JUNK/
mv definition* JUNK/
mv feature.ini JUNK/
mv *.preproc* JUNK/
mv *.est_prob* JUNK/
mv temp_* JUNK/
mv *collset* JUNK/
mv *coco* JUNK/
