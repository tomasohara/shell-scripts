# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# Preprocess the Spanish biblical text from
#    http://www.mit.edu:8001/afs/athena.mit.edu/activity/c/csa/www/documents/Spanish/Bible.html
#
# Sample (excluding blank lines):
# 
#    Revelation
#    ------------------------------------------------------------------------
#    Revelation 1
#    1
#    La Revelacin de Jesucristo, que Dios le dio para mostrar a sus siervos las cosas que deben suceder pronto; y que dio a conocer Envindola por medio de su ngel a su siervo Juan, 
#    2
#    quien ha dado testimonio de la palabra de Dios y del testimonio de Jesucristo, de todo lo que ha visto. 
#
# TODO:
#     Make a version of the original with each verse on the same line as the
#     verse number:
#       
#	perl -i.bak1 -pn -e 's/\n//; s/^ *([0-9]+) *$/\n\1: /; s/^ *$/\n/;' rev_sp.text
#       perl -i.bak2 -pn -e "s/  */ /g; s/_____ /\n/;" rev_sp.text
#	foreach.pe 'cat new_line.list >> $f' rev_sp.text
#
# old:
#	perl -i.bak1 -pn -e "s/(^[0-9]+)\n/\1/;" rev_sp.text
#	perl -i.bak2 -pn -e "s/(^[0-9]+)\n/\1 /;" rev_sp.text
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


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

	$book = $_;
}
&debug_out(4, "book=$book\n");
if ($book eq "") {
    die "ERROR: Unable to determine Spanish book name.\n";
}
if (eof()) {
    die "ERROR: Unexpected input format\n";
}

$last_verse = 0;
while (<>) {
	&dump_line($_);
	chop;

	# skip blank lines
	if (/^ *$/) {
		next;
	}
	
	# Skip section numbers
	if (/^$book [0-9]+$/i) {
		next;
	}
	# Skip verse numbers
	if (/^[0-9]+$/) {	# old format
		next;
	}
	## s/^[0-9]+: //;
	if (/^([0-9]+):/) {
	    $verse = $1;
	    if (($verse - $last_verse) > 1) {
		printf STDERR "WARNING: verse skipped ($verse, $last_verse): $_\n";
	    }
	    $last_verse = $verse;
	    s/^[0-9]+: //;
	}

	# Isolate words from punctuation
	s /([().:;,.?!¡¿\"\'])/ $1 /g;
	s/--/ -- /g;

	print "$_\n";
}
