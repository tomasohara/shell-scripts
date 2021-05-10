# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# makehead.pe: duplicate the headword & strip the accent marks
# (to facilitate grep's)
#
# ex:
#   ábrego 	m. south wind.
#   =>
#   abrego	ábrego 	m. south wind.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

binmode STDIN;

while (<>) {
    chop;
    if (/^([^\t]+) *\t/) {
	$head = $1;
	$def = $';
	$key = $head;

	# Remove diacritic marks from the key and make lowercase
	$key =~ tr/áíóúéñü/aiouenu/;
	$key =~ s/[¡!¿?]//g;
	$key =~ tr/A-ZÁÉÍÓÚÑÜ/a-záéíóúñü/;

	# Put the homonym indicator in with the definition:
	#     (1) ver 	m. sight, sense of sight. 2 aspect
	#     (2) ver  	tr. to see 
	if ($key =~ /^\(([0-9])\) (.*)/) {
	    $homonym = $1;
	    $key = $2;
	    $head =~ s/\($homonym\) //;
	    $def = "($homonym) $def";
	}

	# Remove any embedded tabs in the definition to facilitate
	# later parsing (eg, split(/\t/, $dict_line))
	$def =~ s/\t/ /g;

	print "$key\t$head\t$def\n";
    }
    else {
	&debug_out(4, "warning: ignoring '$_'\n");
    }
}

