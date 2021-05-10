# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# web_freq.perl: check frequency of phrase on the web via search
# engine queries, currently Hotbot or Altavista. This works by
# invoking the search engine via lynx and then scanning the results
# for the hit count. Optionally, the text of the search results can
# be displayed, which is useful for co-occurrence checks. Other
# optional features include downloading of the URL documents,
# limiting the documents to particular languages, as well as
# special request feature for checking for particular URL's
# in the results (BillJ).
#
# NOTES:
#
# This is a generalization of hotbot_freq.perl.
#
# Hotbot queries:
#
# lynx -dump 'http://www.HotBot.com/text/default.asp?SM=phrase&MT=commonsense+knowledge&search=SEARCH&DC=10&DE=2&DV=0&RG=all&LG=any&BT=T'
#
# =>
#
#       HotBot: Text-only version | [1]Full graphics version
#     
#        look for: [exact phrase.....]   ______________________________
#     Search
#                      New  Revise  More Options
#                      [_] Search within these results.
#     
#      [2] Family Videos and MusicClick here! 
#     
#       Returned: 69 Matches
#       Results for "commonsense knowledge"
#       1 - 10 [3]next >>
#       
#       1.  [4]Ernest Davis
#       Ernest Davis Department of Computer Science Courant Institute of
#       Mathematical Sciences New York University Reaching Me Email is
#       best. email: davise@cs.nyu.edu phone: (212) 998-3123 fax: (212)
#       995-4121 Dept. of Computer Science New York University..
#       99%  3/9/99 http://www.cs.nyu.edu/cs/faculty/davise/
#       See results from [5]this site only.
#
#       ...
#
# "albanian orthodox religion" =>
# http://hotbot.lycos.com/?MT=albanian+orthodox+church&SM=SC&DV=0&LG=english&DC=100&DE=2&BT=L&submit.x=16&submit.y=6
#
# AltaVista:
#
# "my dog" =>
# http://www.altavista.com/cgi-bin/query?pg=q&sc=on&hl=on&act=2006&par=0&q=%22my+dog%22&kl=XX&stype=stext&search.x=24&search.y=12
#
# "my dog" (advanced search) =>
# http://www.altavista.com/cgi-bin/query?pg=aq&q=%22my+dog%22&r=&kl=XX&d0=&d1=&search.x=12&search.y=20
#
# "my dog" and "my cat" =>
# http://www.altavista.com/cgi-bin/query?pg=aq&q=%22my+dog%22+and+%22my+cat%22&r=&kl=XX&d0=&d1=&search.x=47&search.y=10
#
# "mi pero" (language=Spanish) =>
# http://www.altavista.com/cgi-bin/query?pg=aq&q=%22mi+pero%22&r=&kl=es&d0=&d1=&search.x=19&search.y=14
# 
# "mi pero" (language=English) =>
# http://www.altavista.com/cgi-bin/query?pg=aq&q=%22mi+pero%22&r=&kl=en&d0=&d1=&search.x=36&search.y=7
#
# http://www.altavista.com/cgi-bin/query?q=cat+and+mouse&kl=XX&pg=q&Translate=on&search.x=11&search.y=11
#
# Altavista Power search (50 results per page):
#
# "albanian orthodox religion" =>
#
# http://www.altavista.com/cgi-bin/query?q=albanian+orthodox+religion&sb=all&srin=all&d2=0&dt=dtrange&d0=&d1=&kl=XX&rc=rgn&sgr=all&swd=&lh=&nbq=50&pg=ps&Translate=on&search.x=37&search.y=15
# NOTE:
#
# The Hotbot URL was determined by using the -trace option of Lynx (along with -tlog).
# The AltaVista ones were determined the usual way (ie, via netscape).
#
#........................................................................
# Samples with AltaVista search result format (Fall 2002):
#
# June 1985 Report No.   
# William J. Clancey 1985. Abstract. 1. INTRODUCTION. 2. THE HEURISTIC CLASSIFICATION METHOD DEFINED. 2.1. Simple classification. 2.2. Data abstraction. 2.3. Heuristic classification. 3. EXAMPLES...
# www.aistudy.co.kr/expert%20system/heuristicclass.htm . Translate 
#
# spastyle.doc   
# IEEE P1484.12/D4.0. 5 February 2000. Draft Standard for Learning Object Metadata. Sponsored by the. Learning Technology Standardization Committee. of the. IEEE. Copyright 
# ltsc.ieee.org/doc/wg12/LOM_WD4.htm . Related pages  . Translate 
# More pages from ltsc.ieee.org  
#
#........................................................................
# Sample with latest AltaVista search result format (Summer 2007):
#
# all words:	wikipedia
# exact phrase:	Baton Rouge
#
# http://www.altavista.com/web/results?itag=ody&pg=aq&aqmode=s&aqa=wikipedia&aqp=Baton+Rouge&aqo=&aqn=&kgs=1&kls=0&dt=tmperiod&d2=0&dfr%5Bd%5D=1&dfr%5Bm%5D=1&dfr%5By%5D=1980&dto%5Bd%5D=25&dto%5Bm%5D=7&dto%5By%5D=2007&filetype=&rc=dmn&swd=&lh=&nbq=10
#........................................................................
# TODO:
# - Support the Google search engine.
# - Have option to download the text versions of PS & PDF documents.
# - Remove support for older versions of the search engines.
# - Use the html version of the result to allow for more structured matching.
# - Fix handling of phrases with parenthesis, quotes, and other odd punctuation (e.g., biolography items).
# - Fix -full processing (e.g., paging through query results).
#
# Portions Copyright (c) 2000 - 2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 2002 - 2004 NMSU.  All rights reserved.
# Portions Copyright (c) 2007 Convera, Inc.  All rights reserved.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose $timeout/;
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$altavista $hotbot $show_urls $alpha $entries $download_urls $all $any $boolean/;
use vars qw/$phrase $phrasal $lang $full $bare $results $desired_urls $search/;
use vars qw/$d/;	# See why version in common.perl not honored
use vars qw/$download $download_urls $files $download_dir $blurbs $simple $encode $inclusion/;


# Show usage statement if arguments given
if (!defined($ARGV[0])) {
    my($options) =  "options = [-altavista] [-hotbot] [-show_urls] [-alpha] [-entries=N] [-download_urls]\n";
    $options .= "          [-all | -any | -boolean | -phrase] [-lang=L] [-full] [-bare] [-search=type]\n";
    $options .= "          [-results=file] [-desired_urls=file] [-download_dir] [-files] [-alpha]\n";
    $options .= "          [-blurbs] [-phrasal=text] [-encode]";
    my($notes) =  "   show_urls:	display the URL's the query returns (first N)\n";
    $notes .= "   alpha:	the URL listing is alphabetized\n";
    $notes .= "   entries=N	the first N hits are used\n";
    $notes .= "   desired_urls=file	file contain list of desired URL's (one per line)\n";
    $notes .= "   search=type	where type in {all, any, phrase, title, name, url, boolean}\n";
    $notes .= "   lang=L	where L in {any dutch english finnish french german italian portuguese spanish swedish}\n";
    $notes .= "   full	show all of results (by paging througuh results)\n";

    my($example) = "examples:\n\n$script_name -entries=100 commonsense knowledge\n\n";
    $example .= "$script_name -desired_urls=commonsense_knowledge.url commonsense knowledge\n\n";
    $example .= "$script_name -all \"lat muscle\"\n\n";

    $example .= "$script_name -show_urls anti-viral | grep ^http >| anti-viral.url\n";
    $example .= "$script_name -desired_urls=anti-viral.url anti-viral software\n\n";
    $example .= "$script_name" . ' -full "Arab" | count_it -freq_first "Arab \w+" | sort -rn | less' . "\n\n";
    $example .= "$script_name" . ' -full "LONG TERM" | count_it -i -preserve "long.term"' . "\n";

    die "\nusage: $script_name [options] word ...\n\n$options\n\n$notes\n\n$example\n";
}

# Extract command-line arguments
&init_var(*show_urls, &FALSE);		# produce a list of the URL's
&init_var(*download, &FALSE);		# alias for -download_urls
&init_var(*download_urls, $download);	# download the document for each URL
&init_var(*download_dir, ".");		# directory for downloaded files
&init_var(*files, &FALSE);		# download as external files
&init_var(*alpha, &FALSE);		# alphabetize the URL list
&init_var(*entries, 100);		# number of entries to include
&init_var(*desired_urls, "");		# URLs to check for in the result
&init_var(*search, "phrase");		# search-type: phrase, boolean, all [words], any [words]
&init_var(*boolean, &FALSE);		# boolean search
&init_var(*all, &FALSE);		# all-words search
&init_var(*any, &FALSE);		# any-word search
&init_var(*phrase, &FALSE);		# use phrasal search
## &init_var(*simple, $all);		# simple all-words search
# TODO: use different option name for -phrasal=text since unintuitive
&init_var(*phrasal, "");		# specific phrase to check
&init_var(*results, "");		# results file
&init_var(*lang, "english");		# language for documents
&init_var(*full, &FALSE);		# show all of the results
&init_var(*blurbs, &FALSE);		# show the query result blurbs 
&init_var(*bare, &FALSE);		# just display the frequency
## The following are in extra.perl:
## &init_var(*altavista, &FALSE);		# use AltaVista's power search
## &init_var(*hotbot, (! $altavista));	# use Hotbot's search engine
&init_var(*encode, &FALSE);		# encode the phrase on URL
&init_var(*inclusion, "");		# inclusion filter regex
my($results_file) = $results;
$search = ($all ? "all" : ($any ? "any" : ($phrase ? "phrase" : ($boolean ? "boolean" : $search))));
my($user_search_type) = $search;
$boolean = &TRUE if (($search eq "boolean") || ($search eq "BOOLEAN") || ($search eq "Boolean"));
$all = &TRUE if (($search eq "all") || ($search eq "sc"));
my($simple) = $all;
$any = &TRUE if (($search eq "any") || ($search eq "mc"));
## OLD: $phrase = &TRUE if ($search eq "phrasal");

my($extract_urls) = ($show_urls || ($desired_urls ne "") || $download_urls);

my($engine) = $altavista ? "AltaVista" : "Hotbot";

if ($boolean && $altavista) {
    &warning("Boolean search no longer suported by AltaVista\n");
}

if (! &dir_exists($download_dir)) {
    &run_command("mkdir -p $download_dir");
}

# Prepare the hotbot query (defaults to an exact match on the phrase).
# TODO: rename $phrase as $search_phrase to avoid conflict with -phrase option
my($original_phrase) = (join(" ", @ARGV));
$original_phrase =~ s/\\\-/\-/g; # unescape dashes
$phrase = $original_phrase;
$phrase = "\"$phrase\"" if ($phrase !~ /^\w+$/);
$phrase =~ s/\s+/+/g;		# use + in place of spaces
$phrase =~ s/^\"(.*)\"$/$1/;	# remove surrounding double quotes
$phrase =~ s/\"/%22/g;		# use encoding of %22 for embedded double quote
$phrase =~ s/\'/%27/g; 		# use encoding of %27 for embedded single quote
$phrase =~ s/\&/%26/g;		# use encoding of %26 for ampersands
$phrase =~ s/\,/%2C/g;		# use encoding of %2C for commas
$phrase =~ s/:/%3A/g;		# use encoding of %3A for semicolons
$phrase =~ s/([&|])/\\$1/g;	# use shell escapes around special shell characters
if ($encode) {
    # Replace non-ascii-proper characters with %-hex representation of UTF-8 encoding
    my $new_phrase = "";
    foreach my $c (split(//, $phrase)) {
	my $repr = $c;
	if (ord($c) >= 0x80) {
	    $repr = sprintf "%%%02X", ord($c);
	}
	$new_phrase .= $repr;
    }
    &debug_print(&TL_VERBOSE, "old-phrase='$phrase'\n");
    $phrase = $new_phrase;
}
&debug_print(&TL_VERBOSE, "phrase='$phrase'\n");
$delim = "\'";

#........................................................................
# Generate the URL command for performing the search
my(@lynx_commands);
my($lynx) = "lynx -width=512 -dump -nolist";
if ($altavista) {
    # Set up AltaVista-specific options (using power search)
    ## OLD: my($page_max) = 50;
    my($page_max) = 10;
    my($hits_max) = 200;
    $search = ($boolean ? "bool" : $all ? "all" : $any ? "any" : "exact");
    &debug_out(&TL_VERBOSE, "search=%s\n", $search);
    my($advanced_query_type) = ($boolean ? "aqa" : $all ? "aqa" : $any ? "ano" : "aqp");
    my($lang_code) = &get_language_code($lang);
    my($quote_delim) = $delim;
    my $lynx_command = "";

    # By default all the words are searched as a phrase, but when -phrasal=p
    # specified, the command-line words treated as all-words type argument 
    # (i.e., order not relevant) and phasal argument treated as such.
    if ($simple) {		# note: -simple now an alias for -all
	&debug_print(&TL_VERBOSE, "simple search\n");
	# old EX ("dog cat"): http://www.altavista.com/web/results?itag=ody&q=dog+cat&kgs=1&kls=0
	# new EX ("junior nlp programmer."): http://www.altavista.com/yhs/search?fr=altavista&q=junior+nlp+programmer&nbq=50&kl=en
	my($query_spec) = &prep_url_phrase($phrase);
	
	$lynx_command = sprintf "http://www.altavista.com/web/results?q=%s&nbq=%d&kl=%s", $query_spec, $page_max, $lang_code;
	push (@lynx_commands, "${quote_delim}$lynx_command${quote_delim}");
    }
    elsif ($phrasal eq "") {
	&debug_print(&TL_VERBOSE, "other search\n");
	## OLD: push (@lynx_commands, sprintf "$lynx %shttp://www.altavista.com/cgi-bin/query?q=%s&pg=ps&sb=%s&nbq=%d&kl=%s%s", $delim, $phrase, $search, $page_max, $lang_code, $delim);
	my($search_words_spec) = &prep_url_phrase($phrase);
	$lynx_command = sprintf "http://www.altavista.com/web/results?%s=%s&pg=aq&aqmode=s&nbq=%d&kl=%s", $advanced_query_type, $search_words_spec, $page_max, $lang_code;
	push (@lynx_commands, "${quote_delim}$lynx_command${quote_delim}");
    }
    else {
	&debug_print(&TL_VERBOSE, "phrasal search\n");
	## http://www.altavista.com/web/results?itag=ody&pg=aq&aqmode=s&aqa=wikipedia&aqp=Baton+Rouge&aqo=&aqn=&kgs=1&kls=0&dt=tmperiod&d2=0&dfr%5Bd%5D=1&dfr%5Bm%5D=1&dfr%5By%5D=1980&dto%5Bd%5D=25&dto%5Bm%5D=7&dto%5By%5D=2007&filetype=&rc=dmn&swd=&lh=&nbq=10
	my($exact_phrase_spec) = &prep_url_phrase($phrasal);
	my($search_words_spec) = &prep_url_phrase($phrase);
	# TODO: see if some undocumented type for boolean (e.g., aqb)
	$lynx_command = sprintf "http://www.altavista.com/web/results?aqp=%s&%s=%s&pg=aq&aqmode=s&nbq=%d&kl=%s", $exact_phrase_spec, $advanced_query_type, $search_words_spec, $page_max, $lang_code;
	push (@lynx_commands, "${quote_delim}$lynx_command${quote_delim}");
    }

    # Generate queries to page through the list of results
    if ($full) {
	&debug_print(&TL_DETAILED, "Adding queries for subsequent pages\n");
	# old EX: http://www.altavista.com/cgi-bin/query?pg=aq&Translate=on&q=shintoism&stq=10
	#                                                                          ^^^^^^^
	# new EX ("junior nlp programmer."): http://www.altavista.com/yhs/search?fr=altavista&q=junior+nlp+programmer&b=11
	# note:
	#     full new EX: http://us.yhs4.search.yahoo.com/yhs/search;_ylt=A0oGdNoPxyRPRjIAMEcPxQt.?q=junior+nlp+programmer&fr=altavista&xargs=12KPjg1oduy5a3vOHvKvjFTfXBhg9O0JC25Is%5FWMQaRp8L%5FXNtR6AuOfa%5F3pgqGK5q7y%5Fg%5FQ%2E%2E&pstart=2&b=11
	#     starting query: http://www.altavista.com/yhs/search?fr=altavista&q=junior+nlp+programmer&nbq=50&kl=en
	#
	for (my $offset = $page_max; $offset < $entries; $offset += $page_max) {
	    ## OLD: my $next_lynx_command = $lynx_command . "&stq=$offset";
	    my $next_lynx_command = $lynx_command . "&b=$offset";
	    push (@lynx_commands, "${quote_delim}$next_lynx_command${quote_delim}");
	}
    }
}
else {
    # Setup Hotbot-specific options
    my($page_max) = 100;
    my($hits_max) = 1000;
    $search = ($boolean ? "B" : $all ? "MC" : $any ? "SC" : "phrase");
    &debug_out(&TL_VERBOSE, "search=%s\n", $search);
    if ($simple) {
	push (@lynx_commands, sprintf "%shttp://www.hotbot.com/?q=%s%s", $delim, $phrase, $delim);
    }
    else {
	&warning("Non-simple queries not supported for hotbot\n");
	push (@lynx_commands, sprintf "%shttp://hotbot.lycos.com/?SM=%s&MT=%s&DC=%s&LG=%s&BT=T%s", $delim, $search, $phrase, $page_max, $lang, $delim);
    }

    # Generate queries to page through the list of results
    # TODO: do this after initial query to avoid extraneous queries
    if ($full) {
	#  http://hotbot.lycos.com/?MT=smoking&LG=english&II=800&RPN=2&TR=463312&DC=100&BT=L
	#                                                ^^^^^^^^^^^^^
	my($page_num) = 2;
	for (my $offset = $page_max; $offset < $entries; $offset += $page_max) {
	    push (@lynx_commands, sprintf "%shttp://hotbot.lycos.com/?SM=%s&MT=%s&DC=%s&DE=2&DV=0&RG=all&LG=%s&BT=T&II=%s&RPN=%d%s", $delim, $search, $phrase, $page_max, $lang, $offset, $page_num++, $delim);
	}
    }
}

#........................................................................
# Invoke the query
my($result) = "";
my $lynx_command;
foreach $lynx_command (@lynx_commands) {
    $result .= &run_command("$lynx $lynx_command", &TL_DETAILED);
}
if ($blurbs) {
    print "Query: $original_phrase\n=>\n";
    print "$result\n";
}

# Save the results to a file if desired
if ($results_file ne "") {
    &write_file($results_file, $result);
}

#........................................................................
# Scan the result listing for the hit count
my($frequency) = "0";
if ($altavista) {
    if ($result =~ /Web Pages.*([0-9,]+)\s*pages found/i) {	# AltaVista
	$frequency = $1;
    }
    elsif ($result =~ /found ([0-9,]+)\s*results/i) {
	$frequency = $1;
    }
    elsif ($result =~ /([0-9,]+)\s*pages? found\./i) {
	$frequency = $1;
    }
    elsif ($result =~ /([0-9,]+)\s*results for/i) {
	$frequency = $1;
    }
    else {
	&warning("Warning: Unable to find results: new pattern needed for AltaVista???\n");
    }
}
else {
    if ($result =~ /Returned:\s*([0-9,]+)\s*Matches/i) {	# Hotbot
	$frequency = $1;
    }
    elsif ($result =~ /Returned:\s*(((more)|(less)|(fewer)) than)?\s*([0-9,]+)/i) {
	$frequency = $6;
    }
    elsif ($result =~ /Result\s*(((more)|(less)|(fewer)) than)?\s*([0-9,]+)/i) {
	$frequency = $6;
    }
    else {
	&warning("Warning: Unable to find results: new pattern needed for Hotbot???\n");
    }
}

# Display the frequency
$frequency =~ s/,//g;		# remove commas from frequency
$user_search_type =~ s/all/all-words/;
$user_search_type =~ s/any/any-word/;
$user_search_type =~ s/phrase/phrasal/;
$user_search_type .= " ";
$user_search_type = "" if (($search eq "phrase") && (index($original_phrase, " ") == -1));
my($search_phrase) = $original_phrase;
$search_phrase .= " '$phrasal'" if ($phrasal ne "");
&debug_out(&TL_VERBOSE, ";; %sfrequency of \"%s\":\t%s\n", $user_search_type, $search_phrase, $frequency);
if ($bare) {
    print "$frequency\n";
}
else {
    printf "The %sfrequency of \"%s\" in %s is %s\n", $user_search_type, $search_phrase, $engine, $frequency;
}

if ($blurbs) {
    printf "\n\n";
}

#........................................................................
# Read in the list of desired URL's
my(@desired_URL);
if ($desired_urls ne "") {
    @desired_URL = split("\n", &read_file($desired_urls));
    &trace_array(\@desired_URL, &TL_VERBOSE);
}

# Extract the list of URL's
# 
my(@return_URL);
if ($extract_urls) {
    @return_URL = &extract_URLs_from_results($result);
}
if ($show_urls) {
    print "-" x 72, "\n";
    my($order_indicator) = $alpha ? " alphabetized" : "";
    printf "URL's (first %s hits%s):\n%s\n", $entries, $order_indicator, join("\n", @return_URL);
}

# Show the overlap among URL's
if ($#desired_URL >= 0) {
    my(@overlap) = &intersection(\@desired_URL, \@return_URL);
    printf "Desired URL's (%d of %d):\n%s\n", ($#overlap + 1), ($#desired_URL + 1), join("\n", @overlap);
}

# Optionally download the documents returned from the query
# TODO: use a separate file for each link
if ($download_urls) {
    my($count) = 0;
    print "-" x 72, "\n" unless ($files);
    for (my $u = 0; $u <= $#return_URL; $u++) {
	my $url = $return_URL[$u];
	if ($files) {
	    my($url_file) = $download_dir . "/" . &remove_dir("$url");
	    printf "Downloading URL %s to %s:\n", $url, $url_file;
	    &issue_command("lynx -source -force_html \"$url\" > \"$url_file\"");
	}
	else {
	    print "." x 72, "\n" if ($count++);
	    printf "Downloading URL %s:\n", $url;
	    &issue_command("lynx -dump -width=512 -nolist \"$url\"");
	}
    }
    if ($files) {
	print "\n";
	&debug_print(&TL_DETAILED, "Warning: run anti-virus detection over downloaded web pages.\n");
    }
}

&exit();

#------------------------------------------------------------------------

# prep_url_phrase(text): make sure text is properly escaped for use
# in URL
#
sub prep_url_phrase {
    my($text) = @_;

    $text =~ s/ /\+/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    return ($text);
}

# extract_URLs_from_results(query_results) => list-of-URLS
#
# Hotbot format:
#     Results for "remained close"
#     1 - 100 [3]next >>
#     
#     1. [4]Larry Legend looks back
#     NBC video: Bird says he could have remained a town garbagema
#     6/15/2000 http://www.msnbc.com/news/420923.asp
#     See results from [5]this site only.
#
#     2. [6]Channel 4000 - 12/10/99 Market Close: Stocks Give Satisfying Friday Performance
#     ...
#
# Altavista format example:
#
#   Result Pages: 1  [4]2  [5]3   [6][Next >>]
#   
#   1. [7]Chip Hills falls to Central Montcalm
#          Chip Hills falls to Central Montcalm. By Sandy Gholston Pioneer Sports Writer. REMUS -- Although the game was a thriller, Chippewa Hills coach Lenny..
#          URL: www.pioneergroup.net/sports/chbb17.html
#          Last modified on: 25-Oct-1999 - 4K bytes - in English
#          [ [8]Translate ] [ [9]Company factsheet ]
#          
#   2. [10]Radio Islam - MOROCCO AND REVOLUTION - by Ahmed Rami - On the 10 July 1971 som
#   ...
#........................................................................
#
# Hotbot Format example:
#
#      2. Darwin, Charles - Voyage of the Beagle, The
#      Enjoy Charles Darwin's account of the voyage during which his evolutionary theory was born. Details his discoveries in the Galapagos
# Islands.
#      http://www.literature.org/Works/Charles-Darwin/voyage
#      See results from this site only.
#      3. beagle 2
#      http://www.beagle2.com/
#      See results from this site only.
#
#........................................................................
# TODO: resolve URL elipses (eg, AltaVista)
#     Amazon.com: Excerpt from Kevin McCloud's Complete Book of Paint and Decorative
#     Books. All Products. Explore this book. buying info. table of contents. read an excerpt. editorial reviews. customer reviews. See more by the...
#     URL: http://www.amazon.com/exec/obidos/tg/sto...874342/excerpt/ o Translate
#

sub extract_URLs_from_results {
    my($temp_result) = @_;
    my(@return_URL);
    &debug_out(&TL_VERY_VERBOSE, "extract_URLs_from_results(%s)\n", join(",", @_));
    my($last_entry_offset) = ($entries - 1);

    while (($altavista && $temp_result =~ /\s*URL: (\S+)\s*\n/ && _dpv("_p1 "))
	   || ($altavista && $temp_result =~ /\n\s*(\S+)\s*\n\s*More pages from\s*[^\n]+\n/i && _dpv("_p2 "))
	   || ($altavista && $temp_result =~ /\n\s*(\S+)\s*o[^\n]+Translate\s*\n/i && _dpv("_p3 "))
	   || ($altavista && $temp_result =~ /\n   ([^\n]+.\.html?)[^\n]*\n/i && _dpv("_p4 "))
	   || ($hotbot && $temp_result =~ /\s*\d+\/\d+\/\d+\s+(http:\S+)/i && _dpv("_p5 "))
   	   || ($hotbot && $temp_result =~ /\n\s*(http:\S+)\s*\n*See results from this site only/i && _dpv("_p6 "))
	   || ($altavista && $temp_result =~ /\n\s+(\S+)\s+\-\s+Cached[^\n]*\n/i && _dpv("_p7 "))
	   ) {
	$temp_result = $';	# remainder of text: $' gives text after pattern matched
	my($hit_url) = $1;
	&debug_out(&TL_VERY_DETAILED, "hit_url=%s remainder=%.80s...\n", $hit_url, $temp_result);

	if (($inclusion ne "") && ($hit_url !~ /$inclusion/)) {
	    &debug_print(&TL_DETAILED, "URL '$hit_url' doesn't match inclusion filter /$inclusion/");
	    next;
	}
	if (find(\@return_URL, $hit_url) != -1) {
	    &warning("Unexpected duplicate hit ($hit_url)\n");
	    next;
	}

	push (@return_URL, $hit_url);
	if ($#return_URL >= $last_entry_offset) {
	    &debug_print(&TL_VERBOSE, "Maximum number of URL's ($entries) reached\n");
	    last;
	}
    }
    if ($alpha) {
	@return_URL = (sort(@return_URL));
    }

    return (@return_URL);
}

# _dpv: shorthand for &debug_print(&TL_VERBOSE, ...)
# NOTE: Always returns true (1), so can be used in an expression (eg 'if (/regex1/ && _dpv("regex1"))')
#
sub _dpv {
    &debug_print(&TL_MOST_VERBOSE, "_dpv(@_)\n");
    &debug_print(&TL_VERBOSE, @_);
    return 1;
}

# init_language_codes(): initialize the table of language codes (for AltaVista)
#
# from altavista power search HTML source:
# 
# <tr><td valign=top>Search for Web pages published in this language:
#  </td><td></td><td><SELECT NAME=kl><OPTION VALUE=XX SELECTED>any language <OPTION VALUE=en>English<OPTION VALUE=zh>Chinese<OPTION VALUE=cs>Czech<OPTION VALUE=da>Danish<OPTION VALUE=nl>Dutch<OPTION VALUE=et>Estonian<OPTION VALUE=fi>Finnish<OPTION VALUE=fr>French<OPTION VALUE=de>German<OPTION VALUE=el>Greek<OPTION VALUE=he>Hebrew<OPTION VALUE=hu>Hungarian<OPTION VALUE=is>Icelandic<OPTION VALUE=it>Italian<OPTION VALUE=ja>Japanese<OPTION VALUE=ko>Korean<OPTION VALUE=lv>Latvian<OPTION VALUE=lt>Lithuanian<OPTION VALUE=no>Norwegian<OPTION VALUE=pl>Polish<OPTION VALUE=pt>Portuguese<OPTION VALUE=ro>Romanian<OPTION VALUE=ru>Russian<OPTION VALUE=es>Spanish<OPTION VALUE=sv>Swedish</SELECT>
#  </td></tr>
#
# TODO: use full set of language code
#
my(%lang_codes);
sub init_language_codes {
    %lang_codes = ("english" => "en",
		   "engl" => "en",
		   "eng" => "en",
		   "en" => "en",
		   "chinese" => "zh",
		   "czech" => "cs",
		   "danish" => "da",
		   "dutch" => "nl",
		   "estonian" => "et",
		   "finnish" => "fi",
		   "french" => "fr",
		   "german" => "de",
		   "greek" => "el",
		   "hebrew" => "he",
		   "hungarian" => "hu",
		   "icelandic" => "is",
		   "italian" => "it",
		   "japanese" => "ja",
		   "korean" => "ko",
		   "latvian" => "lv",
		   "lithuanian" => "lt",
		   "norwegian" => "no",
		   "polish" => "pl",
		   "portuguese" => "pt",
		   "romanian" => "ro",
		   "russian" => "ru",
		   "spanish" => "es",
		   "span" => "es",
		   "sp" => "es",
		   "swedish" => "sv"
		   );
}

# get_language_code(language): returns 2 letter code for the language
# or "??" if unknown
#
# get_language_code(english) => "en"; get_language_code(spanish) => "es"
#
sub get_language_code {
    my($language) = @_;
    $language = &to_lower($language);

    # Initialize the language mapping, if necessary
    # TODO: use pattern matching to account for prefixes
    if ((scalar (keys(%lang_codes))) == 0) {
	&init_language_codes();
    }

    return ($lang_codes{$language} || "XX");
}
