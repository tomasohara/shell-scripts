#! /bin/csh -f
#
# make_aliases.sh: produce aliases for scripts use din GraphLing
#
# NOTE: The scripts have been renamed with a .sh extension to support
#       code maintenance.
#
# usage: source make_aliases.sh
#
# to reproduce the aliases given a directory of scripts:
#
#    % foreach f (*.sh)
#    foreach? echo alias `basename $f` $f
#    foreach? end
#

alias classify_all classify_all.sh
alias classify_all_dyn classify_all_dyn.sh
alias classify_dat_cond classify_dat_cond.sh
alias classify_dat_dyn classify_dat_dyn.sh
alias g2 g2.sh
alias maketest maketest.sh
alias prepare_dat prepare_dat.sh
alias split_table split_table.sh
