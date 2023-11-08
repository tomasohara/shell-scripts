#! /bin/csh -f

if ("$1" == "") then
    echo "usage: $0 file[.text]"
    echo ""
    echo "ex: $0 como_dice"
    exit
endif
set file = $1
set base = `basename $file .text`

if ((! (-e "$file")) && (-e "${file}.text")) set file = "${file}.text"
if (! (-e $base)) ln -s $file $base

# See if the user wants a different version of spost
#
# ex: 
#      setenv SPOST /home/tipster/crl_tipster/Spanish/old_code 
#
set spost = "spost"
if ($?SPOST) then
    set spost = $SPOST
endif

$spost $base single
perl -Ssw spost2penn.perl $base.pos.single > $base.post

# TODO: add fixup's for common POST mistaggings
