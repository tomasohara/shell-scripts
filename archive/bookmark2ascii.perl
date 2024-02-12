#!/usr/bin/perl -sw
#
# bookmark2ascii.perl: extract listing of Netscape bookmark file
# (as well as for Lynx)
#
# TODO:
# - handle Internet Explorer format for bookmarks (eg, subdirs & URL files)
#   EX: "E:\Documents and Settings\tomohara\Favorites"
#........................................................................
# Sample of netscape bookmarks:
#
#  <!DOCTYPE NETSCAPE-Bookmark-file-1>
#  <!-- This is an automatically generated file.
#  It will be read and overwritten.
#  Do Not Edit! -->
#  <TITLE>Bookmarks for Tom O'Hara</TITLE>
#  <H1>Bookmarks for Tom O'Hara</H1>
#
#  <DL><p>
#      <DT><H3 ADD_DATE="995479589">Reference</H3>
#      <DL><p>
#          <DT><A HREF="http://www.m-w.com/mw/table/metricsy.htm" ADD_DATE="995479605" LAST_VISIT="995479646" LAST_MODIFIED="995479557">http://www.m-w.com/mw/table/metricsy.htm</A>
#          <DT><A HREF="http://babel.uoregon.edu/yamada/guides.html" ADD_DATE="995855732" LAST_VISIT="995856044" LAST_MODIFIED="995855724">Yamada Language Center: Language Guides</A>
#      </DL><p>
#  ...
#      <DT><H3 FOLDED ADD_DATE="978550321">Active Indexing</H3>
#      <DL><p>
#          <DT><A HREF="file:/cyc/projects/active-indexing/data/words-to-annotate/annotation_steps/index.html" ADD_DATE="978584509" LAST_VISIT="982279570" LAST_MODIFIED="978584503">Steps in preparing a batch for CCAT</A>
#  ...
#          <DT><A HREF="file:/home/bertolo/actind/index.html" ADD_DATE="982698933" LAST_VISIT="982698928" LAST_MODIFIED="982698928">The Cycorp Active Indexing Project</A>
#      </DL><p>
#      <DT><H3 FOLDED ADD_DATE="938446055">Austin Stuff</H3>
#      <DL><p>
#          <DT><H3 FOLDED ADD_DATE="979929708">Old</H3>
#          <DL><p>
#              <DT><A HREF="http://www.tpwd.state.tx.us/plate/index.htm" ADD_DATE="973918679" LAST_VISIT="973919591" LAST_MODIFIED="973918661">Order your TXWLD license plate today</A>
#              <DT><A HREF="http://austinlyricopera.org/resources.html" ADD_DATE="976221385" LAST_VISIT="976221462" LAST_MODIFIED="976221377">Austin Lyric Opera - Opera Resources</A>
#
#      </DL><p>
#      <DT><A HREF="http://www.onelook.com/index.html" ADD_DATE="939489065" LAST_VISIT="997979071" LAST_MODIFIED="939489061">OneLook</A>
#  ...
#      <DT><A HREF="http://nazgul.cyc.com/bugzilla/show_bug.cgi?id=202" ADD_DATE="995059041" LAST_VISIT="995147843" LAST_MODIFIED="995057262">Bug 202 - lexical knowledge review section desireable</A>
#  </DL><p>
#
#........................................................................
# Sample of lynx bookmarks:
#
#  <head>
#  <META http-equiv="content-type" content="text/html;charset=iso-8859-1">
#  <title>Bookmark file</title>
#  </head>
#       You can delete links using the remove bookmark command.  It is usually
#  ...
#  <ol>
#  <LI><a href="http://www.HotBot.com/">HotBot</a>
#  <LI><a href="http://search.yahoo.com/search/options">Yahoo! Search Options</a>
#  <LI><a href="http://ciks.cbt.nist.gov/common/">NIST: Electronic Commerce of Technical Data</a>
#  ...
#  <LI><a href="http://www.sle.sharp.co.uk/senseval2/">SENSEVAL-2</a>
#

# Load in the common module, making sure the script dir is in Perl's lib path
$dir = `dirname $0`; chop $dir; unshift(@INC, $dir);
require 'common.perl';

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-indent_text=string]";
    my($example) = "examples:\n\n$script_name  ~/.netscape/bookmarks.html\n\n";
    ## $example .= "$0 example2\n\n";			        # TODO: revise example 2
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";			# TODO: add optional note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
}
&init_var(*indent_text, "   ");		# text to use for the indentation

my($category) = "";
my($indent_level) = -1;
my($indentation) = "";

while (<>) {
    &dump_line();
    chomp;

    # Print just the location and the description
    #  <DT><A HREF="http://www.cs.columbia.edu/~acl/home.html" ADD_DATE="852822809" LAST_VISIT="872111421" LAST_MODIFIED="852822804">Assoc. for Computational Linguistics</A>
    #
    if (m#<A.*HREF="([^\"]+)".*>([^<>]+)</A>#i) {
	my($location) = $1;
	my($description) = $2;

	print "$indentation$description\n";
	print "$indentation$location\n\n";
    }
    

    # Check for a new category name
    # ex: <H3 ADD_DATE="995479589">Reference</H3>
    if (m#<H3[^<>]*>([^<>]*)</H3>#i) {
	$category = $1;

	print "$indentation$category\n";
    }

    # Check for the start of a new bookmark folder (potentially embedded)
    # ex: <DL><p>
    if (m#<DL>#i) {
	$indent_level += 1;
	$indentation = $indent_text x $indent_level;
    }

    # Check for the end of a bookmark folder
    # ex: </DL><p>
    if (m#</DL>#i) {
	$indent_level -= 1;
	$indentation = $indent_text x $indent_level;
    }
}
