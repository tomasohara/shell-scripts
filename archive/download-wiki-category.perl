# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# download-wiki-category.perl: download the HTML index pages for a given Wikipedia category (e.g., Living_people)
# TODO: download the individual pages as well (e.g., Jacob_Aagaard).
#
# This works by traversing the next-NNN links until the last index page 
# encountered.
#
# TODO:
# - Derive language from meta tag if unspecified such as attribute xml:lang of html tag.
#   ex: <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt" lang="pt" dir="ltr">
# - Add option for http proxy.
# - Handle subcategories recursively.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$infer_url $lang $max_pages $list $nosave $save $prefix $base/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-lang=label] [-infer_url] [-max_page=N] [-save] [-list] [-base=URL] [-prefix=label] category_name_or_URL";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name -url 'http://en.wikipedia.org/wiki/Category:Living_people'\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*infer_url, &FALSE);		# argument gives category URL not name
&init_var(*lang, "en");			# language for Wikipedia version to user
&init_var(*max_pages, 100);		# maxc index pages to download
&init_var(*list, &FALSE);		# list the entries in each page index
&init_var(*nosave, &FALSE);		# don't save the HTML index pages
&init_var(*save, ! $nosave);		# save the index pages
&init_var(*prefix, "cat");		# file prefix for downloaded index files
&init_var(*base,			# base URL for Wikipedia in language
	  "http://$lang.wikipedia.org");

my $url = $ARGV[0];

my $next_pattern = (($lang eq "en") ? "next \\d+" :
		    ($lang eq "es") ? "\\d+ siguientes" :
		    # Arabic التالية (following)
		    ($lang eq "ar") ? "\\d+ \xD8\xA7\xD9\x84\xD8\xAA\xD8\xA7\xD9\x84\xD9\x8A\xD8\xA9" :
		    ($lang eq "no") ? "neste \\d+" :
		    ($lang eq "pt") ? "\\d+ posteriores" :
		    (&warning("Unknown language '$lang'"), "next \\d+"));

# If name for category just given, try to infer URL from web search
if ($infer_url) {
    # TODO: get this to work
    &warning("Untested feature (-infer_url)\n");
    my $category = $url;
    my $web_search = &cmd("web_freq.perl -show_urls \'$category\" $lang wiki");
    if ($web_search =~ m@(http://$lang.wikipedia.org/\S+)@) {
	$url = $1;
    }
    else {
	&exit("Unable to infer URL: please provide it explicitly\n");
    }
}

# Download pages until no more NEXT-NNN link
my $page_num;
for ($page_num = 0; (($url ne "") && ($page_num < $max_pages)); $page_num++) {
    print "Checking page $page_num from $url\n" if ($verbose);
    my $page_source = &run_command("lynx -source '$url'");
    if ($save) {
	&write_file("$prefix-page-${page_num}.html", $page_source);
    }

    # Optionally extract entries from current page
    if ($list) {
	# NOTE: the lists are in the mw-pages division
	# ex: <div id="mw-pages">...<li><a href="/wiki/Garry_Adey" title="Garry Adey">Garry Adey</a></li>...<a href="/wiki/Adnan_Zahid_Abdulsamad" title="Adnan Zahid Abdulsamad">Adnan Zahid Abdulsamad</a></li></ul>...</div>

	# Isolate the list section proper
	my $listing = $page_source;
	$listing =~ s/.*(<div id="mw-pages">)/$1/;
	$listing =~ s/<\/div>.*//;

	while ($listing =~ m@<li><a href="[^"]+"[^<>]+>([^<>]+)</a></li>@) {
	    # TODO: use title if available (to minimize html decoding issues).
	    my $name = $1;
	    $listing = $`;	# `
	    print "$name\n";
	}
    }

    # Find next page
    # ex: (<a href="/w/index.php?title=Category:Living_people&amp;from=Aatre%2C+V.+K." title="Category:Living people">next 200</a>)
    $url = "";
    if ($page_source =~ /href=\"([^\"]+)\"[^<>]*>[^<>]*${next_pattern}/) {
	$url = $1;
	if ($url =~ m@^/@) {
	    $url = $base . $url;
	}
	$url =~ s/\&amp;/\&/g;
    }
}
if ($page_num == 0) {
    &warning("Stopping after download of $max_pages index pages");
}

&exit();


#------------------------------------------------------------------------------

# TODO: subroutine101(some_arg): What subroutine101 does
#
sub subroutine101 {
    ## my($arg) = @_;
    &debug_print(&TL_VERBOSE, "subroutine101(@_)\n");

    return;
}
