# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/local/bin/perl -sw
#
# bibitem2bib.perl: convert from bibitem entries into bibtex format.
# This also converts from an ascii representation into bibtex (but the
# format might be a little idiosyncratic).
#
# NOTES: This is designed around my bibitem style, so it must be adapted
# before being applied to others. Specifically, it assumes that all
# the references follow a specific format (comma-delimited):
#
#       LastName1, F[irstName1], F[irstName2] LastName2, ...,
#       and F[irstNamen], F[irstNamen] (19nn), Title, 
#       [Publisher: City | Journal, vol(num):x-y | Conference, pp. x-y].
#
# USAGE:
# Iterative invocations might be necessary. Suggestion: run to identify
# the enties not parsed ok, which are put in @Misc BibTeX entries.
# Then, manually fix these up in the source and rerun (or let through
# if not that many).
#
# *** Afterwards, manually fixup the BibTeX result ***
#
#........................................................................
# Sample input:
#
#   Barnbrook, Geoff (2002), Defining Language: A Local Grammar of Definition Sentences, John Benjamins Publishing Company
#   
#   Meijss, W. (1994), "Computerized lexicons and theoretical models", in N. Oostdijk and P. de Hanns, editors, {\em Corpus-based Research into Language: in honour of Jan Aarts}, pp 65-78, Amsterdam: Rodopi.
#   
#   Morin, Emmanuel, and Christian Jacquemin (1999), "Projecting Corpus-Based Semantic Links on a Thesaurus", in Proc. ACL.
#   
#   Chao, Gerald, and Michael G. Dyer (2000), "Word Sense Disambiguation of Adjectives Using Probabilistic Networks", in Proc. COLING-00, http://citeseer.nj.nec.com/427755.html.
#
# Sample output:
#  
#  @Book{Barnbrook-02,
#          title={Defining Language: A Local Grammar of Definition Sentences},
#          author={Geoff Barnbrook},
#          address={Amsterdam},
#          publisher={John Benjamins Publishing Company},
#          year={2002},
#  }
#  
#  @InCollection{Meijss-94,
#          author={W. Meijss},
#          title={Computerized lexicons and theoretical models},
#          pages={65-78},
#          booktitle={Corpus-based Research into Language: in honour of Jan Aarts},
#          title={Corpus-based Research into Language: in honour of Jan Aarts},
#          editor={N. Oostdijk and P. de Hanns},
#          publisher={Amsterdam},
#          address={Rodopi},
#          year={1994},
#  }
#  
#  @InProceedings{Morin-Jacquemin-99,
#          author={Emmanuel Morin and Christian Jacquemin},
#          title={Projecting Corpus-Based Semantic Links on a Thesaurus},
#          booktitle={Proc. ACL. },
#          year={1999},
#          pages={},
#  }
#  
#  @InProceedings{Chao-Dyer-00,
#          author={Gerald Chao and Michael G. Dyer},
#          title={Word Sense Disambiguation of Adjectives Using Probabilistic Networks},
#          booktitle={Proc. COLING-00, http://citeseer.nj.nec.com/427755.html. },
#          year={2000},
#          pages={},
#  }
#  
#........................................................................
# TODO:
# - put acronyms in braces (eg, title={The Lexicon in the Scheme of {KBMT} Things}) so that they won't be forced to lowercase
# - put other kinown proper names in braces (e.g. English => '{English}')
# - add sanity checks for common types of errors (eg. brace for paren)
# - have option to display the format for the input
# - make sure the author is shown first
# - fix problem with volume spec (eg, 'Shafer, Glenn (1987), "Probability Judegment in Artitifial Intelligence and Expert Systems", Statistical Science (2) 1:3-44')
# - fix problems with sample input (eg, Chao-Dyer-00)
# - add more flexible author parser (e.g., allowing first name first)
# - add more flexible date parsing (e.g., period sepators in addition to paren)
# - collapse runs of whitespace to single spaces in the field contents
# - drop periods at the end of fields
# - infer the KEYWORD value(s) based on title (eg., WSD)
# - handle non-ascii quotes, dashes, etc.
# - add option for creating short-author vs. full-author based on initials.
#
# MISC: full_reading.list produced using bibitem2bib as follows
#    bibitem2bib.perl -d=7 -force -line_mode full_reading_list.text |&  perlgrep "\]:\t"
# where full_reading_list.text derived from old comps_biblio.tex
#
# BUGS:
#    single quotes in booktitles (eg, "Webster's New World Dictionary")
#
# Tom O'Hara
# New Mexico State University
# Summer 2003
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); 
    require 'common.perl';
}
use English;

if (! defined($ARGV[0])) {
    $options = "options = [-force | -strict] [-inverted_names] [-full_year] [-line_mode] [-dummy_keywords] [-dummy_comments]";
    $example = "examples:\n\n$0 ANNOTATIONS/pearl_probabilistic.tex\n\n";
    $example .= "remove_carriage_returns.perl _it.list\n";
    $example .= "$script_name -dummy_keywords _it.list >| _it.bib\n\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$inverted_names $full_year $strict $force $line_mode $dummy_keywords $dummy_comments/;

&init_var(*inverted_names, &FALSE);	# all last names shown first in input
&init_var(*full_year, &FALSE);		# use four-digit year in key
&init_var(*strict, &FALSE);		# just convert \\bibitem tags
&init_var(*force, (! $strict));		# convert any bibliography-like text
my($relax) = $force;			# relaxed input mode (alias for -force)
&init_var(*line_mode, &FALSE);		# use line-input mode not paragraph
&init_var(*dummy_keywords, &FALSE);	# show keywords even if blank
&init_var(*dummy_comments, &FALSE);	# show comments even if blank

# Set constants for use in pattern matching
# NOTE: allows for '2001' and '1999a'
# TODO: define constants for other commonly used patterns '[\.\,]', etc.
my($YEAR) = "\\d\\d\\d\\d[a-z]?";

# Determine the routine to use for extracting author information.
# The difference is based on whether the first names come first, which is 
# the default, or whether the last names come first.
# ex: 'Doe, J., T. Smith, and M. Brown (1979)' versus
#     'Doe, J., Smith, T., and Brown, M. (1979)'
my($convert_authors_fn) = $inverted_names ? \&convert_authors_inverted : \&convert_authors_noninverted;

my($key, $author, $year, $title, $volume, $pages, $proceedings);
my($procs_misc, $journal, $publisher, $publish_loc, $editor, $book_title);
my($is_editor, $comments, $keywords, $notes, $cross_ref, $rest);

# Set paragraph input mode (unless user explicit specified line input)
$/ = ""
    unless ($line_mode);

while (<>) {
    &dump_line();
    chop;
    $key = "";
    my($entry) = $_;

    # Expand abbreviations that might confuse the pattern matching
    $_ =~ s/Intl?\./International/g;

    # Process the next bibliography-like entry in the text
    if (/^\\bibitem.*{(.*)}/ 
	|| ($relax 
	    && ($_ =~ /(in {\\em.*})|(\Wed\.)|(\(19\d\d|20\d\d\)|(\.\s*\(19\d\d|20\d\d\s*\.))/i))) {
	$key = defined($1) ? $1 : "";
	$_ = $POSTMATCH unless (!defined($1));
	$author = "";
	$year = "";
	$title = "";
	$volume = "";
	$pages = "";
	$proceedings = "";
	$procs_misc = "";
	$journal = "";
	$publisher = "";
	$publish_loc = "";
	$editor = "";
	$book_title = "";
	$comments = "";
	$keywords = "";
	$notes = "";
	$cross_ref = "";
	
	# Extract comments
	while (/%+(.*)\n/) {	# TODO: handle %'s in quotes, etc;
	    $comments .= "$1; ";
	    $_ = $PREMATCH . $POSTMATCH;
	}

	# Standardize the latex or plain ascii biblio listing
	s/\n/ /g;
	s/\\it /\\em /g;
	s/\\mbox\{([^\{\}]*)\}/$1/g;
	s/~/ /g;
	s/\\([\"\'\`])\{(.)\}/\\$1$2/g;	# ex: "Guill\'{e}n" => Guill\'en

	# Remove \bibitem extraneous markup
	# ex: {Charniak-93}E.~Charniak.\newblock 1993.\newblock {\em Statistical Language Learning}.
	#    => {Charniak-93}E. Charniak. 1993. {\em Statistical Language Learning}.
	s/\\newblock\s//g;
	$rest = $_;

	# Extract information common to all entries
	# TODO: put entry-specific stuff in separate routines

	# Get the optional keywords section (tpo-specific???)
	if (/\\keywords{([^{}]*)}/) {
	    $keywords = $1;
	}

	# Check for also-published info
	if ($rest =~ /[\,\.]\s+also\s+/i) {
	    $rest = $PREMATCH;
	    $notes = "also $POSTMATCH";
	}
	&debug_out(&TL_VERY_VERBOSE, "[after also in] rest='%s' notes='%s\n", $rest, $notes);

	# Get author name and year
	# NOTE: square bracktes in examples here and below indicate context
	# ex: [{Mitchell-97}] Tom M. Mitchell[. 1997.] 
	# ex: Keith Allan. 1980. [Nouns and countability. Language, 56(3):541-67]
	# ex: Palmer, F. (1971), [Grammar. Harmondsworth: Penguin.]
	$is_editor = &FALSE;
	if (($rest =~ /\}?\s*([^\{\}\"]*)\s+\(($YEAR)\)(\s*)/)
	    || ($rest =~ /\s*([^\{\}\"]*)\s*\.\s*($YEAR)(\s*\.\s*)/)) {
	    $author = $1; $year = $2; $rest = "($year)$3$POSTMATCH";
	    &debug_print(&TL_VERY_VERBOSE, "author=$author\n");

	    # Check for author(s) as editor(s)
	    if ($author =~ /[\,\.]\s*edi?t?o?r?s?\.?\s*$/) {
		$author = $PREMATCH;
		$is_editor = &TRUE;
		&debug_print(&TL_VERY_VERBOSE, "[after author editor fix] author=$author\n");
	    }

	    # Do all sorts of fix-ups for the author list
	    $author = &$convert_authors_fn($author);
	}
	&debug_print(&TL_VERY_VERBOSE, "[after author fix] rest=$rest\n");

	# Check for author(s) as editor(s)
	if (($rest =~ /(\($YEAR\))[\,\.]\s*editors?\s*/)
	    || ($rest =~ /(\($YEAR\))[\,\.]\s*eds?\.?\s*/)) {
	    $rest = "$PREMATCH$1$POSTMATCH";
	    $is_editor = &TRUE;
	    &debug_print(&TL_VERY_VERBOSE, "[after editor fix] rest=$rest\n");
	}
	
	# Get article or book title
	# TODO: use clustering operator (:? ) for optional '{\em ' sequences
	# NOTE: thesis's are treated here as books but differentiated below
	#
	# case 1: emphasized formatting: Jones, B. (2000), {\em Wombats}, ...
	my($is_book) = &FALSE;
	if ($rest =~ /\(?$YEAR\)?[\,\.]\s*{\\em ([^\`\'\"\000]+)}/) {
	    &debug_print(&TL_MOST_DETAILED, "title case 1: $&\n");
	    $title = $1; $rest = $POSTMATCH;
	    $is_book = &TRUE;
	}
	#
	# case 2: capitalized title after date: Jones, B. (2000), Windows for Wombats, ...
	# TODO: handle spacial characters (eg, accents)
	# NOTE: comma after title retained for subsequent pattern matching
	elsif ($rest =~ /\(?$YEAR\)?\s*[\,\.]?\s*(([A-Z]\w*\s*)([^\,\.\"]+)*)\s*([\,\.])/) {
	    &debug_print(&TL_MOST_DETAILED, "title case 2: $&\n");
	    $title = $1; $rest = "$PREMATCH $4 $POSTMATCH";
	    $is_book = &TRUE;
	}
	elsif (($rest =~ /\($YEAR\)\s*[\,\.]?\s*\`\`(.*)\'\'\s*/)
	    || ($rest =~ /\($YEAR\)\s*[\,\.]?\s*\"(.*)\"\s*/)) {
	    &debug_print(&TL_MOST_DETAILED, "title case 3: $&\n");
	    $title = $1; $rest = $POSTMATCH;
	}
	elsif ($rest =~ /\($YEAR\)\s*[\,\.]?\s*([^\.\,]+)/) {
	    &debug_print(&TL_MOST_DETAILED, "title case 4: $&\n");
	    $title = $1; $rest = $POSTMATCH;
	    $is_book = ($title !~ /^\s*[\"\']/);
	}
	elsif ($rest =~ /\($YEAR\)\s*[\,\.]?\s*(\{\\em ([^\}\(]+)\})\s*/) {
	    &debug_print(&TL_MOST_DETAILED, "title case 5: $&\n");
	    $title = $1; $rest = $POSTMATCH;
	    $is_book = &TRUE;
	}
	&debug_print(&TL_VERY_VERBOSE, "[after title] rest=$rest\n");

	# Get journal along with volume and pages: my format with pages
	# TODO: consolidate the different cases into one pattern with optional '{\em '
	#
	# ex: [Doe, John (2000), "Y2K Bugs",] {\em Y2K Computing} 1(1):1-10.
	#                        1                 23         4                   5
	if ($rest =~ /^\s*\{\\em ([^\}\(]+)\}[\,\.]\s+(([^,]+)\s*(\([^,]+\))?)\s*:\s*([^,]+--?[^,]+)[\,\.]/) {
	    &debug_print(&TL_MOST_DETAILED, "journal case 1: $&\n");
	    $journal = $1; $volume = $2; $pages = $5;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	# ex: [Doe, John (2000), "Y2K Bugs",] Y2K Computing 1(1):1-10.
	elsif ($rest =~ /^\s*[\,\.]?\s+([^\}\(]+)\s+(([-0-9]+)\s*(\([-0-9]+\))?)\s*:\s*([^,]+--?[^,]+)[\,\.]/) {
	    &debug_print(&TL_MOST_DETAILED, "journal case 2: $&\n");
	    $journal = $1; $volume = $2; $pages = $5;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	# ex: [Doe, John (2000), "Y2K Bugs",] {\em Y2K Computing} 1(1).
	elsif ($rest =~ /^\s*\{\\em ([^\}\(]+)\}[\,\.]\s+(([^,.]+)\s*(\([^,]+\))?)/) {
	    &debug_print(&TL_MOST_DETAILED, "journal case 3: $&\n");
	    $journal = $1; $volume = $2;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	# ex: [Doe, John (2000), "Y2K Bugs",] Y2K Computing 1(1).
	elsif ($rest =~ /^\s*[\,\.]?\s+([^,.]+)\s*(\([^,]+\))/) {
	    &debug_print(&TL_MOST_DETAILED, "journal case 4: $&\n");
	    $journal = $1; $volume = $2;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	$journal = &trim($journal);
	&debug_print(&TL_VERY_VERBOSE, "[after journal] journal='$journal' volume='$volume' pages='$pages' rest='$rest'\n");

	# Check for pages
	# ex: "Data, pp. 92-99."   "pages 92-99, New York,"  "Retrieval. 121-2."
	$rest = " $rest";	# ensure leading space
	# TODO: use non-grouping regex
	if (($rest =~ /\Wpp\.?\s*(\d+--?\d+)/) 
	    || ($rest =~ /\Wpages\.?\s*(\d+--?\d+)/)
	    || ($rest =~ /[.,]\s*(\d+\-\-?\d+)\s*[.,]\s*$/)) {
	    $pages = $1; $rest = "$PREMATCH,$POSTMATCH";
	}
	&debug_print(&TL_VERY_VERBOSE, "[after pages] rest=$rest\n");

	# Check for proceedings (eg, "in {\em Proceedings of the Twelfth")
	$rest = " $rest";	# ensure leading space
	if (($rest =~ /\Win\s*\{\\em (Proc.*)\}([\,\.]\s+(.*))?/i)
	    || ($rest =~ /\Win\s* (Proc.*)([\,\.]\s+(.*))?/i)) {
	    &debug_print(&TL_VERBOSE, "in proceedings (test 1)\n");
	    $proceedings = $1; $procs_misc = defined($3) ? $3 : "";
	    $rest = "$PREMATCH $POSTMATCH";
	}
	elsif ($rest =~ /\Win\s*\{\\em (.*)\}[\,\.]\s*(working notes\s*,\s*(.*)?)/i) {
	    &debug_print(&TL_VERBOSE, "in proceedings (test 2)\n");
	    $proceedings = $1; $procs_misc = defined($2) ? $2 : "";
	    $rest = "$PREMATCH $POSTMATCH";
	}
	elsif ($rest =~ /\Win\s*\{\\em ([^\}]+Conference[^\}]+)\}([\,\.]\s+(.*))?/i) {
	    &debug_print(&TL_VERBOSE, "in proceedings (test 1)\n");
	    $proceedings = $1; $procs_misc = defined($3) ? $3 : "";
	    $rest = "$PREMATCH $POSTMATCH";
	}
	&debug_print(&TL_DETAILED, "[after proceedings] rest='$rest'\n");

	# Check for works in collections
	#
	# ex: Fillmore, C. (1968), ``The Case for Case'', in {\em Universals
	#     in Linguistic Theory}, E. Bach and R. Harms, eds., ...
	#
	$rest = " $rest";	# ensure leading space
	if ($rest =~ /\Win\s*\{\\em (.*)\}[\,\.]\s*(.*)[\,\.\(]\s*edi?t?o?r?s?[\.\,\)]+/i) {
	    &debug_print(&TL_VERBOSE, "in collection\n");
	    $book_title = $1; $editor = $2;
	    $rest = "$PREMATCH $POSTMATCH";

	    # Do author fix-ups for the editor list
	    $editor = &$convert_authors_fn($editor);
	}
	#
	# ex:  Clark, H.H. (1977). Bridging.  In P.N. Johnson-Laird and 
        #      P.C. Wason, (editors), {\it Thinking}, ...
	#
	elsif ($rest =~ /\Win\s*(.*)[\,\.\(]\s*edi?t?o?r?s?\.?[\,\.\)]+\s*\{\\em (.*)\}/i) {
	    &debug_print(&TL_VERBOSE, "in collection\n");
	    $editor = $1; $book_title = $2;
	    $rest = "$PREMATCH $POSTMATCH";

	    # Do author fix-ups for the editor list
	    $editor = &$convert_authors_fn($editor);
	}
	#
	# ex:  [,] in N. Oostdijk and P. de Hanns, editors, Corpus-based Research into Language: in honour of Jan Aarts, [pp 65-78, Amsterdam: Rodopi.]
	# TODO: write better pattern for optional comma or period after paren than [\,\.\)]+
	elsif ($rest =~ /\Win\s*(.*)[\,\.\(]\s*edi?t?o?r?s?\.?[\,\.\)]+\s*([^\,\.]+)/i) {
	    &debug_print(&TL_VERBOSE, "in collection\n");
	    $editor = $1; $book_title = $2;
	    $rest = "$PREMATCH $POSTMATCH";

	    # Do author fix-ups for the editor list
	    $editor = &$convert_authors_fn($editor);
	}
	#
	# ex: Kayser, Daniel and Hocine Abir (1995), ``A non-monotonic approach
	#     to lexical semantics'', in (Saint-Dizier & Viegas 1995), ...
	#
	elsif ($rest =~ /\Win\s*\((.*) ($YEAR)\)\s*[\,\.]?\s*?/) {
	    &debug_print(&TL_VERBOSE, "in cross-ref\n");
	    $cross_ref = "$1-$2";
	    $rest = "$PREMATCH $POSTMATCH";

	    $cross_ref =~ s/ //g;
	    $cross_ref =~ s/\\?&/-/;
	    $cross_ref =~ s/19//; 	# TODO: make Y2K compliant
	}
	# ex: Briscoe, Ted, Ann Copestake, and Alex Lascarides (1995), 
	#     ``Blocking'', in [Saint-Dizier & Viegas 95], pp. 273-301.
	#
	elsif ($rest =~ /\Win\s*\[(.*) (\d\d)\]\s*[\,\.]?\s*?/) {
	    &debug_print(&TL_VERBOSE, "in cross-ref\n");
	    $cross_ref = "$1-$2";
	    $rest = "$PREMATCH $POSTMATCH";

	    $cross_ref =~ s/ //g;
	    $cross_ref =~ s/\\?&/-/;
	    $cross_ref =~ s/19//; 	# TODO: make Y2K compliant
	}
	&debug_print(&TL_VERY_VERBOSE, "[after collections] rest='$rest'\n");

	# Catch all for proceedings/workshops
	# TODO: make sure this doesn't conflict with other rules
	# EX: [... and Word Similarity",] Proc. ACL-03
	if (($rest =~ /[\,\.]\s*in\s+([^\.\,]+)/i)
	    || ($rest =~ /[\,\.]\s*([^\.\,]+\b((proc(\.|eedings)?)|(Workshop))\s+[^\.\,]+)/i)) {
	    $proceedings = $1;
	    $is_book = &FALSE;
	    $rest = "$PREMATCH $POSTMATCH";
	}

	# Catch all for journals
	# EX: [Computational Linguistics, ] 28(2) [, June 2002]
	elsif ($rest =~ /\d+\s*\(\d+\)\s*/) {
	    $journal = $PREMATCH; $volume = $@;
	    $is_book = &FALSE;
	    $rest = $POSTMATCH;
	}
	&debug_print(&TL_VERY_VERBOSE, "[after procs/workshop/journal fix] rest='$rest'\n");

	# Check for place of publication
	#
	# case 1: [Machine Learning ...] Morgan Kaufmann: San Mateo, CA.
	# TODO: check for known locations
	if ($rest =~ /[\,\.]\s*([-\.\,\w ]+)\s*:\s*([-\.\,\w ]+,\s*\w\w)\s*[\,\.]/) {
	    &debug_print(&TL_MOST_DETAILED, "publisher case 1: $&\n");
	    $publisher = $1;
	    $publish_loc = $2;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	#
	# case 2: [,] John Benjamins Publishing Company: Amsterdam.
	elsif ($rest =~ /[\,\.]\s*([^\.\,]+)\s*:\s*([^\.\,]+)\s*[\,\.]/) {
	    &debug_print(&TL_MOST_DETAILED, "publisher case 2: $&\n");
	    $publisher = $1;
	    $publish_loc = $2;
	    $rest = "$PREMATCH $POSTMATCH";
	}	
	# case 3: [Machine Learning ...] San Mateo, CA: Morgan Kaufmann
	# TODO: convert , to \, and . to \.
	elsif (($rest =~ /[\,\.]\s*([-\.\,\w ]+,\s*\w\w)\s*:\s*([-\.\.\w ]+)[\,\.]\s*/)
	    || ($rest =~ /[\,\.]\s*([-\.\,\w ]+)\s*:\s*([-\.\,\w ]+)[\,\.]\s*/)
	    || ($rest =~ /[\,\.]?\s*\(([-\.\.\w ]+)\s*:\s*([-\.\.\w ]+)\)[\,\.]\s*/)) {
	    &debug_print(&TL_MOST_DETAILED, "publisher case 3: $&\n");
	    $publish_loc = $1;
	    $publisher = $2;
	    $rest = "$PREMATCH $POSTMATCH";
	}
	#
	&debug_print(&TL_VERY_VERBOSE, "[after place of publication] rest='$rest'\n");

	# Make sure the names and year were extracted
	if ((($author eq "")  && ($editor eq ""))
	    || ($year eq "")) {
	    &warning("ignoring questionable entry: $entry author='$author' editor='$editor' year=$year\n");
	    next;
	}

	# Derive the BibTex key from the names unless already given
        if ($key eq "") {
            &derive_key();
        }

	# Print the BibTeX entry
	# TODO: check for field variables assigned but not used
	if ($rest =~ /(PhD)|(\bMS\b)|(Master\'?s)|(Thesis)|(Diss(ertation)?)/i) {
	    &print_thesis_entry();
	}
	elsif ($rest =~ /(Tech.*Report)|(\WTR\W)/i) {
	    $rest = $PREMATCH . " TR " . $POSTMATCH;
	    &print_tech_report_entry();
	}
	elsif ($is_book) {
	    &print_book_entry();
	}
	elsif ($journal ne "") {
	    &print_article_entry();
	}
	elsif ($proceedings ne "") {
	    &print_procs_entry();
	}
	elsif ($editor ne "") {
	    &print_collection_entry();
	}
	elsif ($cross_ref ne "") {
	    &print_collection_entry();
	}
	else {
	    &print_misc_entry();
	}

    }

    &debug_print(&TL_VERY_VERBOSE, "[$key]:\t$_\n");
}

#------------------------------------------------------------------------------

# print_bibtex_field(label, contents_ref)
#
# Prints the bibtex entry field using the specified contents and then
# blanks the field variable. The following format is used
#    <TAB><field-label>={<contents>},
# NOTE: This is used for catching unreferenced field variables in print_other_fields
#
sub print_bibtex_field {
    &debug_print(&TL_VERBOSE, "print_field(@_)\n");
    my($label, $contents_ref) = @_;

    # Trim extraneous whitespace in the contents
    my($value) = $$contents_ref;
    $value = &trim($value);
    $value =~ s/\s\s+/ /g;

    # Print the entry
    printf "\t%s={%s},\n", $label, $value;

    # Clear the field variable so that it is not printed twice 
    $$contents_ref = "";
}

sub print_book_entry {
    &debug_print(&TL_DETAILED, "print_book_entry(@_)\n");

    print "\@Book{$key,\n";
    ## print_bibtex_field("key", \$key);
    if ($is_editor) {
	my($booktitle) = $title;
	print_bibtex_field("booktitle", \$booktitle);
	print_bibtex_field("title", \$title);
	print_bibtex_field("editor", \$author);
    }
    else {
	print_bibtex_field("title", \$title);
	print_bibtex_field("author", \$author);
    }
    print_bibtex_field("address", \$publish_loc);
    print_bibtex_field("publisher", \$publisher);
    print_bibtex_field("year", \$year);
    &print_rest();
    print "}\n";
    print "\n";

    return;
}

sub print_article_entry {
    &debug_print(&TL_DETAILED, "print_article_entry(@_)\n");

    print "\@Article{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("journal", \$journal);
    print_bibtex_field("year", \$year);
    print_bibtex_field("volume", \$volume);
    print_bibtex_field("pages", \$pages);
    &print_rest();
    print "}\n";
    print "\n";

    return;
}

sub print_collection_entry {
    &debug_print(&TL_DETAILED, "print_collection_entry(@_)\n");

    print "\@InCollection{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("pages", \$pages);
    if ($cross_ref eq "") {
	print_bibtex_field("booktitle", \$book_title);
	print_bibtex_field("editor", \$editor);
	print_bibtex_field("publisher", \$publisher);
	print_bibtex_field("address", \$publish_loc);
	print_bibtex_field("year", \$year);
    }
    else {
	print_bibtex_field("crossref", \$cross_ref);
    }
    &print_rest();
    print "}\n";
    print "\n";

    return;
}

sub print_procs_entry {
    &debug_print(&TL_DETAILED, "print_procs_entry(@_)\n");
    &debug_out(&TL_VERY_DETAILED, "procs_misc='%s'\n", $procs_misc);

    $procs_misc = &remove_junk($procs_misc);
    print "\@InProceedings{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("booktitle", \$proceedings);
    ## print_bibtex_field("address", \$publish_loc);
    ## print_bibtex_field("month", \$publish_loc);
    print_bibtex_field("year", \$year);
    print_bibtex_field("pages", \$pages);
    ## print_bibtex_field("note", \$procs_misc);
    $notes = "$procs_misc, $notes";
    &print_rest();
    print "}\n";
    print "\n";

    return;
}


sub print_thesis_entry {
    &debug_print(&TL_DETAILED, "print_thesis_entry(@_): rest='$rest'\n");

    # Determine if PhD or Masters
    # TODO; remove 'PhD Thesis', etc. from REST field
    my($masters) = ($rest =~ /master\'?s|\bms\b/i);
    my($thesis_type) = ($masters ? "MastersThesis" : "PhDThesis");

    # Extract the school name
    my($school) = "University of ???";
    if (($rest =~ /(University of ([^.,]+))[\,\.]/i)
	|| ($rest =~ /(([^.,]+) University)/)) {
	$school = $1;
	$rest = "$PREMATCH $POSTMATCH";
    }
    
    # Extract the optional department name (put in note entry)
    if (($rest =~ /(Department\s+of\s+([^.,]+))[\,\.]/i)
        || ($rest =~ /(Dept\.?\s+of\s+([^.,]+))[\,\.]/i)) {
	$school = "$1, $school";
	$rest = "$PREMATCH $POSTMATCH";
    }

   
    printf "\@%s{%s,\n", $thesis_type, $key;
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("school", \$school);
    print_bibtex_field("year", \$year);
    &print_rest();
    print "}\n";
    print "\n";

    return;
}


sub print_misc_entry {
    &debug_print(&TL_DETAILED, "print_misc_entry(@_)\n");

    print "\@Misc{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("year", \$year);
    print "\tTODO={fix-up this entry or revise bibitem2bib.perl},\n";
    &print_rest($rest);
    print "}\n";
    print "\n";

    return;
}

sub print_tech_report_entry {
    &debug_print(&TL_DETAILED, "print_tech_report_entry(@_): rest='$rest'\n");

    my($number) = "";
    # note: assumed "TR" transformed from "Tech. Report", etc
    my($inst) = $rest;
    $rest = "";
    if ($inst =~ /\s+TR\s+([^,.]+)?/) {
	$number = defined($1) ? $1 : "";
	$inst = "$PREMATCH $POSTMATCH";
	$inst = &remove_junk($inst);
    }

    print "\@TechReport{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("year", \$year);
    print_bibtex_field("number", \$number) if ($number ne "");
    ## # Put the remainder in the institution field
    print_bibtex_field("institution", \$inst);	# TODO: extract report number, etc.
    &print_rest();
    print "}\n";
    print "\n";

    return;
}

sub print_x_entry {
    &debug_print(&TL_DETAILED, "print_x_entry(@_)\n");

    print "\@X{$key,\n";
    print_bibtex_field("author", \$author);
    print_bibtex_field("title", \$title);
    print_bibtex_field("year", \$year);
    &print_rest();
    print "}\n";
    print "\n";

    return;
}


# print_other_fields(): print fields that havent already been printed
# by print_bibtex_field. The labels are preceeded by underscores
# (e.g., '_author') to avoid conflicts with other fields (e.g., editor).
# NOTE: This is intended to avoid loosing information that was removed
# from $rest by the rules.
#
sub print_other_fields {
    print_bibtex_field("_author", \$author) if ($author ne "");
    print_bibtex_field("_editor", \$editor) if ($editor ne "");
    print_bibtex_field("_title", \$title) if ($title ne "");
    print_bibtex_field("_booktitle", \$book_title) if ($book_title ne "");
    print_bibtex_field("_year", \$year) if ($year ne "");
    print_bibtex_field("_journal", \$journal) if ($journal ne "");
    print_bibtex_field("_volume", \$volume) if ($volume ne "");
    print_bibtex_field("_pages", \$pages) if ($pages ne "");
    print_bibtex_field("_address", \$publish_loc) if ($publish_loc ne "");
    print_bibtex_field("_publisher", \$publisher) if ($publisher ne "");
    print_bibtex_field("_note", \$notes) if ($notes ne "");
    print_bibtex_field("_comments", \$comments) if ($comments ne "");
    print_bibtex_field("_keywords", \$keywords) if ($keywords ne "");
    print_bibtex_field("_PROCS", \$proceedings) if ($proceedings ne "");
    print_bibtex_field("_procs_misc", \$procs_misc) if ($procs_misc ne "");
    print_bibtex_field("_crossref", \$cross_ref) if ($cross_ref ne "");
}

# print_rest(text): print the text in the notes field of the bibtex entry.
# Also, if there are unreferenced label fields (e.g., $publisher), then 
# the placeholders for the corresponding bibtex fields are printed.
#
sub print_rest {
    my($text) = $rest;
    &debug_out(&TL_VERY_DETAILED, "rest='%s'\n", $rest);

    # Remove known-stuff from the remainder
    my($rest_cleaned) = &remove_junk($text);
    $notes =~ s/[.,]\s*$//;
    &print_other_fields();
    print_bibtex_field("note", \$notes) unless ($notes =~ /^\s*$/);
    print_bibtex_field("KEYWORDS", \$keywords) if (($keywords !~ /^\s*$/) || $dummy_keywords);
    print_bibtex_field("COMMENTS", \$comments) if (($comments !~ /^\s*$/) || $dummy_comments);
    print_bibtex_field("REST", \$rest_cleaned) if ($rest_cleaned !~ /^\s*$/);

    return;
}

#------------------------------------------------------------------------

# convert_authors_noninverted(author_text): extract the authors, assuming
# that all secondary author names are in the form '<first> <last>'
# example: 'Doe, J., T. Smith, and M. Brown (1979)'
#
# NOTE: This format is assumed buy default (ie. convert_authors resolves
# to convert_authors_noninverted)
# TODO:
# - fix off-by-one bug (ie, last author not always handled correctly)
# - fix problem w/ extraneous "and" between last persons names
# - reconcile with convert_authors_noninverted
#
sub convert_authors_noninverted {
    my($author) = @_;
    &debug_print(&TL_DETAILED, "convert_authors_noninverted(@_)\n");

    # Make sure comma occurs before the 'and'
    $author =~ s/([^,])\s+and\s+/$1, and /g;
    $author =~ s/ \\?& / and /;

    # Change first author from "last, first," to "first last,"
    # NOTE: if initials are used than the conversion is not done (ed, 'R. Quinlan')
    my($first_author) = "";
    if ($author =~ /^([^ \t,]+),\s*(([^ \t,]+\.? ?)+)/) {
	$first_author = $&;
	$author = $POSTMATCH;
	if ($first_author !~ /^\s*[A-Z]\./) {
	    $first_author =~ s/^([^ \t,]+),\s*(([^ \t,]+\.? ?)+)/$2 $1/;
	    &debug_print(&TL_VERY_VERBOSE, "[1st author switch] first_author='$first_author'\n");
	}
    }
    else {
	$first_author = $author;
	$author = "";
    }
    &debug_print(&TL_VERY_VERBOSE, "[1st author fix] first_author='$first_author' author='$author'\n");

    # Convert "Jones, T.," => "T. Jones," in other author list
    # NOTE: temporary markers are used to avoid conflating entries
    my($new_author, $temp_author);
    $new_author = "";
    $author .= ",";		# add comma after last author
    while ($author =~ /([^\s,.][^\s,.]+),\s*(([^\s,.]. ?)* ?[^\s,.]\.)\s*,/) {
	$new_author .= $PREMATCH;
	$temp_author = $&;
	$author = $POSTMATCH;
	$temp_author =~ s/([^\s,.][^\s,.]+),\s*(([^\s,.]. ?)* ?[^\s,.]\.)\s*,/$2 $1/g;
	&debug_print(&TL_VERY_VERBOSE, "[other authors fix] temp_author='${temp_author}'\n");
	$new_author .= $temp_author;
    }
    $author =~ s/,$//;		# remove trailing comma
    $new_author .= $author;
    $author = $new_author;
    &debug_print(&TL_VERY_VERBOSE, "[after other authors fix] author='$author'\n");

    # Rejoin first author to the list
    if ($author !~ /^\s*$/) {
	$author = $first_author . "," . $author;
	$author =~ s/,\s*,s/,/g; 	# join successive comma's
    }
    else {
	$author = $first_author;
    }
    &debug_print(&TL_VERY_VERBOSE, "[after author recombination] author='$author'\n");

    # Change comma's to and's
    $author =~ s/\s*,\s*,/,/g;	# collapse multiple commas
    $author =~ s/\s*,\s*$//; 	# remove trailing comma
    $author =~ s/,/ and /g;
    $author =~ s/\s+and\s+and\s+/ and /;
    &debug_print(&TL_VERY_VERBOSE, "[after author comma fix] author='$author'\n");

    return ($author);
}


# convert_authors_inverted(author_text): extract the authors, reverting 
# the names from last, first (or last, f.) to first, last.
# example: 'Doe, J., Smith, T., and Brown, M. (1979)'
#
# TODO:
# - fix off-by-one bug (ie, last author not always handled correctly)
# - fix problem w/ extraneous "and" between last persons names
# - reconcile with convert_authors_inverted
#
sub convert_authors_inverted {
    my($author) = @_;
    &debug_print(&TL_DETAILED, "convert_authors_inverted(@_)\n");

    # If there is a space before the first comma, assume non-inverted format
    if ($author =~ m/^\s*\S+\s+[\,\.]/) {
	return (&convert_authors_noninverted(@_));
    }

    # Make sure comma occurs before the and
    $author =~ s/([^,])\s+and\s+/$1, and /g;
    $author =~ s/\\?&/ , /;
    $author =~ s/,\s*,s/,/g; 	# join successive comma's

    # Convert "Jones, T.," => "T. Jones," in other author list
    # Also, "Jones, John" => "John Jones"
    my($new_author, $temp_author);
    $new_author = "";
    while ($author =~ /^([^,]+),([^,]+),?/) {
	$temp_author = $&;
	$author = $POSTMATCH;
	$temp_author =~ s/([^,]+),([^,]+),?/$2 $1/;
	$temp_author = &trim($temp_author);
	&debug_print(&TL_VERY_VERBOSE, "[during authors fix] temp_author=${temp_author}\n");
	$new_author .= " , " if ($new_author ne "");
	$new_author .= $temp_author;
    }
    $new_author .= $author;
    $author = $new_author;
    &debug_print(&TL_VERY_VERBOSE, "[after other authors fix] author=$author\n");

    # Change comma's to and's
    $author =~ s/,\s*,s/,/g; 	# join successive comma's
    $author =~ s/\s*,\s*$//; 	# remove trailing comma
    $author =~ s/,/ and /g;
    $author =~ s/\s+and\s+and\s+/ and /;
    $author =~ s/  +/ /g;	# convert multiples spaces to one space
    &debug_print(&TL_VERY_VERBOSE, "[after author comma fix] author='$author'\n");

    return ($author);
}


# delete_text(text, subtext): remove the first occurrence of SUBTEXT in TEXT
#
sub delete_text {
    my($text, $subtext) = @_;
    my($pos) = index($text, $subtext);

    if ($pos != -1) {
	substr($text, $pos, length($subtext)) = "";
    }

    return ($text);
}


# remove_junk(text): remove extraneous formatting information from the text,
# such as the optional \bibitem label, extra commans, and latex second quote
#
sub remove_junk {
    my($rest) = @_;

    $rest =~ s/\\bibitem.*\} //;
    $rest = &delete_text($rest, $author);
    $rest = &delete_text($rest, $title);
    $rest = &delete_text($rest, "($year)");
    $rest =~ s/\`\`\s*\'\'//;	# remove quoted strings (TeX format)
    $rest =~ s/[\,\.]\s*[\,\.]/,/g;	# collapse consecutive commas (or periods)
    $rest =~ s/[\,\.]\s*[\,\.]/,/g;	# do it again (in case of overlap)
    $rest =~ s/^\s*[,]\s*//;	# remove leading comma (or period)
    $rest =~ s/\s*[\,\.]\s*$//;	# remove trailing comma (or period)

    return ($rest);
}

# derive_key(): derive the entry key from the last names and the year
# NOTE: uses global $author, $editor, and $year variables
# result returned in $key
#
sub derive_key {
    my($names) = ($author ne "") ? $author : $editor;
    my($temp_year) = $year;
    &debug_print(&TL_DETAILED, "derive_key(): year=$year names=$names\n");

    if ($full_year == &FALSE) {
	$temp_year =~ s/^(19|20)//;
    }

    $names =~ s/\\?[\"\'\`]//g;
    my(@names) = split(/ and /, $names);
    $names[0] =~ s/.* //	# ignore all but last token in first name
	unless (!defined($names[0]));
    $names[1] =~ s/.* //	# ignore all but last token in second name
	unless (!defined($names[1]));
    if ($#names > 1) {
	$key = sprintf "%s-etal-%s", $names[0], $temp_year;
    }
    elsif ($#names > 0) {
	$key = sprintf "%s-%s-%s", $names[0], $names[1], $temp_year;
    }
    else {
	$key = sprintf "%s-%s", $names[0], $temp_year;
    }
    &debug_print(&TL_DETAILED, "key=$key\n");

    return;
}
