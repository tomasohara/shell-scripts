#!/bin/csh -f
#
# This script creates symbolic links to the scripts w/o the .sh extension.
# This faciliates working with the files in groups (eg, "grep coco *.sh").

ln -s classify_all classify_all.sh
ln -s classify_all_dyn classify_all_dyn.sh
ln -s classify_dat_cond classify_dat_cond.sh
ln -s classify_dat_dyn classify_dat_dyn.sh
ln -s g2 g2.sh
ln -s g2_any g2_any.sh
ln -s g2_pat g2_pat.sh
ln -s g2_win g2_win.sh
ln -s incrtfrq incrtfrq.sh
ln -s incrtsen incrtsen.sh
ln -s maketest maketest.sh
ln -s prepare_dat prepare_dat.sh
ln -s scheme1 scheme1.sh
ln -s scheme1.1 scheme1.1.sh
ln -s schemeAny schemeAny.sh
ln -s schemeWin schemeWin.sh
ln -s split_table split_table.sh
