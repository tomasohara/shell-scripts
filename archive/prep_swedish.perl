# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# Preprocess the Swedish biblical text from
#    gopher://gopher.lysator.liu.se:70/11/project-runeberg/txt/bibeln
#
# Sample:
#
#                  Johannes' uppenbarelse, 1 Kapitlet
#
#               Johannes h�lsar de sju f�rsamlingarna i
#                provinsen Asien, omtalar att Jesus har
#                 uppenbarat sig f�r honom och befallt
#               honom att nedskriva vad han i syner f�r
#                                sk�da.
#
#  1.  Detta �r en uppenbarelse f�n Jesus Kristus, en som Gud gav honom
#      f�r att visa sina tj�nare, vad som snart skall ske.  Och medelst
#      ett budskap genom sin �ngel gav han det till k�nna f�r sin
#      tj�nare Johannes,
#  2.  som h�r vittnar och framb�r Guds ord och Jesu Kristi
#      vittnesb�rd, allt vad han sj�lv har sett.
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

$include_nums = &FALSE unless defined($include_nums);

# Find the book header
$book = "";
while (<>) {
	&dump_line($_);
	chop;

	# skip blank lines
	s/^  *$//g;
	if (/^$/) {
		next;
	}

	s/^ *//;
	if (/^\-\-\-\-\-/ || /^_____/) {
		last;
	}

	# ex: # Johannes' uppenbarelse, 1 Kapitlet
	# 
	if (/(.*), .* Kapitlet/i) {
	    $book = $1;
	    last;
	}
}
&debug_out(4, "book=$book\n");
if ($book eq "") {
    die "ERROR: Unable to determine Swedish book name.\n";
}
if (eof()) {
    die "ERROR: Unexpected input format\n";
}


# Print each verse on a single line (excluding book synopsis)
#
$chapter = 1;			# current chapter number processed
$last_verse = 1;		# last verse number processed
$include_line = &FALSE;		# indicates text to be excluded
$first_chapter = &TRUE;		# indicates first time through loop

while (<>) {
	&dump_line($_);
	chop;

	# Skip blank lines
	s/^ *//;
	if (/^$/) {
		next;
	}
	
	# Skip section numbers
	if (/^ *$book, ([0-9]+) kapitlet/i) {
	    $chapter = $1;

	    # Exclude synopsis text
	    $include_line = &TRUE;
	    next;
	}

	# Skip verse numbers as given. Optionally, replace w/ "chapter:verse "
	#
	if (/^ *([0-9]+)\. /) {	
	    print "\n" unless ($first_chapter);
	    $first_chapter = &FALSE;
	    $verse = $1;
	    if (($verse - $last_verse) > 1) {
		printf STDERR "WARNING: verse skipped ($verse, $last_verse): $_\n";
	    }
	    $last_verse = $verse;
	    s/^ *([0-9]+)\. //;
	    print "$chapter:$verse " if ($include_nums);
	    $include_line = &TRUE;
	}

	# Collapse multiple spaces into one
	s/[ \t][ \t]+/ /g;
	s/\r//g;		# kill the CR character

	# Print the line without the newline
	if ($include_line) {
	    print "$_ ";
	}
}
print "\n";
