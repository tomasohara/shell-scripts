# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# create-reuters-source.perl: Create a ReutersSource XML document for use
# with the R tm package. This is a workaround for incredibly awkard interface
# provided by the package. The input is a directory structure with one
# subdirectory per topic, each contained the associated text files for
# that category. The result is a single XML file with a separate <REUTERS>
# tag per file and the category name given by <TOPICS>.
#
# Output XML format:
#
#   <?xml version="1.0"?>
#   <!-- Dummy corpus file for use with R tm package (ReutersSource) -->
#   <LEWIS>
#   
#   <REUTERS>
#   <DATE></DATE>
#   <TOPICS><D>topic1</D></TOPICS>
#   <PLACES></PLACES>
#   <PEOPLE></PEOPLE>
#   <ORGS></ORGS>
#   <EXCHANGES></EXCHANGES>
#   <COMPANIES></COMPANIES>
#   <UNKNOWN></UNKNOWN>
#   <TEXT>
#   <TITLE></TITLE>
#   <DATELINE></DATELINE>
#   <BODY>
#   Document 1
#   </BODY>
#   </TEXT>
#   </REUTERS>
#   
#   ...
#   
#   </LEWIS>
#
# TODO:
# - convert encoding to UTF-8 (due to tm's lack of encoding tag recognition)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$show_id $newid/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (! defined($ARGV[0])) {
    my($options) = "main options = [-show_id]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name -newid insurance-docs >| insurance.xml\n\n"; 
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    $note .= "Notes:\n\n-newid is a alias for show_id.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options] directory\n\n$options\n\n$example\n$note";
    &exit();
}
my($directory) = $ARGV[0];


# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*newid, &FALSE);		# alias for $show_id
&init_var(*show_id, &FALSE);		# Use filename as NEWID atribute

# Print XML header
print '<?xml version="1.0" encoding="ISO-8859-1"?>', "\n";
print "<!-- ReutersSource corpus file for use with R tm package. -->\n";
print "<!-- Source directory: $directory -->\n";
print "<LEWIS>\n";
print "\n";


# Get directory categories (subdirectory names)
my($OK);
$OK = chdir "$directory";
&assert($OK);
foreach my $category (glob("*")) {
    if (! -d "$category") {
	&warning("Ignoring non-directory: $category\n");
	next;
    }

    # Print each file in subdirectory with topic label from directory name
    $OK = chdir "$category";
    &assert($OK);
    foreach my $file (glob("*")) {
	&output_reuters_xml_document($category, $file);
    }
    $OK = chdir "..";
}

# Print XML trailer
print "<\/LEWIS>\n";


# The end
&exit();


#------------------------------------------------------------------------------

# Add XML entities to text
# See http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
sub escape_xml {
    my($text) = @_;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/&/&amp;/g;
    $text =~ s/'/&apos;/g;
    $text =~ s/"/&quot;/g;
    &debug_print(&TL_VERY_DETAILED, "escape_text(@_) => $text\n");

    return ($text);
}

# Outputs <REUTERS> section for given document.
# Note: Only the <TOPICS> and <TEXT> tags are used.
#
sub output_reuters_xml_document {
    my($category, $file) = @_;
    &debug_print(&TL_VERBOSE, "output_reuters_xml_document(@_)\n");

    # Print header for XML document section
    my($spec) = "";
    $spec .= " NEWID=\"$file\"" if ($show_id);
    print "<REUTERS$spec>\n";
    print "<!-- $file -->\n";
    print "<DATE></DATE>\n";
    print "<TOPICS><D>$category</D></TOPICS>\n";
    print "<PLACES></PLACES>\n";
    print "<PEOPLE></PEOPLE>\n";
    print "<ORGS></ORGS>\n";
    print "<EXCHANGES></EXCHANGES>\n";
    print "<COMPANIES></COMPANIES>\n";
    print "<UNKNOWN></UNKNOWN>\n";
    print "<TEXT>\n";
    print "<TITLE></TITLE>\n";
    print "<DATELINE></DATELINE>\n";
    print "<BODY>\n";

    # Print text with XML entities added
    my($text) = &read_file($file);
    print &escape_xml("$text\n");

    # Print trailer
    print "</BODY>\n";
    print "</TEXT>\n";
    print "</REUTERS>\n";
    print "\n";

    return;
}
