# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# spanish_lookup.perl: Looks up the word in the Collins Spanish-English
# dictionary. The spanish morpological analyzer (smorph) is used to produce
# plausible roots for the word

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*single_line, &TRUE);

# Parse the command-line arguments
#

$word = shift @ARGV;
if (!defined($word)) {
    die "usage: spanish_lookup.perl word\n";
}


# Run the morphological analyzer.
#
# Example:
#
# % smorph ofrezcan
# 
# nds_morph ofrezcan Spanish:
# ofrecer

$smorph_out = &run_command("smorph.tcl $word");
$smorph_out =~ s/[ \t\n]*nds_morph .*:\n//;


# Run the Collins dictionary lookup program.
#
# Example:
#
# % collins ofrecer
# /home/mleisher/look-tools/lexbase.new/lbformat -i -C -t $wh\t$D -w ofrecer
# ofrecer	to offer; 
# ofrecer	to present; 
# ofrecer	to give, offer; 
# ofrecer	to pay; 
# ofrecer	to extend; 
# ...
#

foreach $base_word (split(/[ \t\n]+/, $smorph_out)) {
    $collins_out = &run_command("collins_lookup.sh $base_word");
    if ($one_line) {
	$collins_out =~ s/$base_word\t//g;
	$collins_out =~ s/\n//g;
	print "$word\t($base_word) $collins_out\n";
    }
    else {
	print "$collins_out\n";
    }
}
