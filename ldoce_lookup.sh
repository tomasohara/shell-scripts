#! /bin/csh -f
#
# ldoce_lookup.sh: wrapper around the lexbase lookup script (lbformat.perl)
#
# TODO: handle patterns
#       lbformat.perl -i -t '$hw ($C)\t$I' -E -w "^scr.*" -si | & less
#       convert into perl
#
#------------------------------------------------------------------------------
# Lexbase field codes (see LexBase tech report)
#
#	$A	syllable	    	$M      usage               
#	$B	pronunciation		$N      spelling form       
#	$C	pos  			$O      synonym             
#	$D	grammar			$P      genus               
#	$E	subject_pref		$Q      parse               
#	$F	object_pref 		$R      derived forms etc.  
#	$G	io_pref			$S      pos rest            
#	$H	domain			$T      derived2            
#	$I	def			$U      parentheticals      
#	$J	example			$V      Derived forms field 
#	$K	idiom			$W      Morphological       
#	$L	boxcode		
#

## set echo = 1

## set ldoce_lookup = /home/mleisher/look-tools/lexbase.new/lbformat
set ldoce_lookup = "perl -S lbformat.perl"

## /home/mleisher/look-tools/lexbase.new/lbformat -r -i -t '($sq$wh $sq($P $C $dq$I$dq))' -w $*

if ("$1" == "") then
    echo "usage: `basename $0` [options] phrase"
    echo ""
    echo "options = [[--record|-r] | [--example|-x] [--phrase|-p] [--idiom|-i]] "
    echo ""
    echo "use -r to show whole record" 
    echo "    -p to do phrase lookup; now obsolete"
    echo "    -i to include idioms (implies --example due to prog. laziness)"
    echo "    --example to show examples
    exit
endif


if (("$1" == "--record") || ("$1" == "-r")) then
    # Display the entire LexBase record
    shift
    $ldoce_lookup -i -r -w "$*"
else
    # lbformat options used:
    # -i: ignore case; -t 'template'; -w phrase; -si skip-idioms
    set args=""
    set idioms = "-si"
    set template = '$hw ($C)\t$I'
    while ("$1" =~ -*) 
        # TODO: fix problem w/ different template options
	if (("$1" == "--phrase") || ("$1" == "-p")) then
	    # ignore the -p option since this is handled by default
	    # set phrase = "$*"
	else if (("$1" == "--idiom") || ("$1" == "-i")) then
	    # For now, -i imples --example
	    set idioms = ""
	    set template = '$hw $K ($C)\t$I\t\t$J'
        else if (("$1" == "--example") || ("$1" == "-x")) then
	    set template = '$hw ($C)\t$I\t\t$J'
	    ## set template = $template'\t\t$J'
	endif
        shift
    end
    set phrase="$*"
    set command = "$ldoce_lookup -i -t '$template' $args -w '$phrase' $idioms"
    if ($?DEBUG_LEVEL) then
	if ($DEBUG_LEVEL > 3) echo issuing: $command
    endif
    eval $command | sort -t_ -n +1 +2 | perl -pn -e "s/\t\t/\n\t/;"
endif
