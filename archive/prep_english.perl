# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# Preprocess the English biblical text from
#    Library of the Future CD (3rd edition)
#
# Sample:
# 
#       Revelations|1:1  The Revelation of Jesus Christ, which God gave unto him, 
#     to show unto his servants things which must shortly come to pass; and he    
#     sent and signified [it] by his angel unto his servant John:                 
#       Revelations|1:2  Who bare record of the word of God, and of the testimony 
#     of Jesus Christ, and of all things that he saw.                             
#
# TODO:
#     make a version of the original with each verse on a single line
#         perl -i.bak1 -pn -e "s/\n//; s/^(  [^|]+\|)/\n\1/;" eng_rev.text 
#	  perl -i.bak2 -pn -e "s/ *\r */ /g;" *.text
#	  perl -i.bak3 -pn -e "s/\-\-\-\-\-.*/\n/;" *.text
#
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
	
	# Strip off the book from what should be "name|1:1 text",
	# but check for any section/version pair.
	# Print the first line of text
	if (/^ *([^|]+)\|\d+:\d+/) {
		$book = $1;
		print "$'\n";
		last;
	}

}
&debug_out(4, "book=$book\n");
if ($book eq "") {
    die "ERROR: Unable to determine English book name.\n";
}
if (eof()) {
    die "ERROR: Unexpected input format\n";
}


$last_verse = 1;
while (<>) {
	&dump_line($_);
	chop;

	# skip blank lines
	if (/^ *$/) {
		next;
	}

	# Remove section/version indicator 
	## s/^ *$book\|\d+:\d+ *//;
	if (/^ *$book\|\d+:(\d+) */) {
	    $verse = $1;
	    if (($verse - $last_verse) > 1) {
		printf STDERR "WARNING: verse skipped ($verse, $last_verse): $_\n";
	    }
	    $last_verse = $verse;
	    s/^ *$book\|\d+:\d+ *//;
	}

	# Remove the brackets around emhasized text
	s/[\[\]]//g;

	# Print the current line of text (note: first line printed above)
	print "$_\n";
}
