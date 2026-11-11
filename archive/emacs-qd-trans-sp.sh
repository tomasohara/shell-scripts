#! /bin/bash
#
# emacs-qd-trans-sp.sh: adhoc script to invoke Emacs w/ ~/.emacs.trans-sp
# TODO: record lookup to file

# note: uses tpo-invoke-emacs.sh for large font support (e.g., for under UHD)
EMACS="${EMACS:-tpo-invoke-emacs.sh}"
$EMACS -- --load $HOME/.emacs.trans-sp &
