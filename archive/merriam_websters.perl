# *-*-perl-*-*
eval 'exec perl -Sw $0 "$@"'
    if 0;
#!/usr/bin/perl -w
#
# merriam_websters.perl: Displays Merriam-Webster definition(s) for the word
#
# customization of mw2.0.0.perl from CPAN
#
# TODO: eliminate redundant display of first entry when -all option selected
#

use Socket;
use strict;
use Getopt::Long;
# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$debug_level/;

# Parse the command-line options: --all to show all entries
# NOTE: To pass in words starting with dashes, the -- delimiter must be used
# after the argument 
#       ex: ~/BIN/merriam_websters.perl -all -- -ic
my $show_all = 0;
&GetOptions("all" => \$show_all,
	    "d=n" => \$debug_level);

my $word = $ARGV[0] or die "Usage: $0 [--all] word\n";
my $host = "www.m-w.com";
my $port = 80;
my $socketaddr;
my $content = "jump=$word"; # This seems to work with white space in word
my $wholePage = "";
my $form = "";
my $buf = "";
my @listvalue = ();
my @option = ();
my $selections = 0;
my $finished_selections = 0;
my $reentry = 0;
my $count = 0;
my ($current_selection) = 0;

while ($content) {
    &debug_out(&TL_VERBOSE, "content='%s'\n", $content);

    openSock();
    post ($content);

    $wholePage = "";
    while ( <SOCK> ) {
	s/\r//;			# drop carriage return  (eg, <CR><NL> => <NL>)
	$wholePage .= $_;
    }
    close SOCK;
    &debug_out(&TL_VERY_VERBOSE, "wholePage={\n%s\n}\n", &indent($wholePage));

    if (! $show_all) {
	print "****************************************";
    }

# pick out the form, /s matches newline with '.' /g is greedy
# /m matches internal newline

    if ( $wholePage =~ /The word you've entered isn't in the dictionary.*(<PRE>.*<\/PRE>)/gs ) {
	print "\nCan't find $word, but here are some suggestions\n";
	$form = $1;
    }
    elsif ($wholePage =~ /(<form .*<\/form>)/gs ) {
	$form = $1;
    }
    else {
	die "Don't know what to do with $word\n";
    }
    &debug_out(&TL_VERY_VERBOSE, "form={\n%s\n}\n", &indent($form));
    

    # this is heavy duty kludge, geared toward www.m-w.com, needs maintenance
    # find out if the form has a selection of options
    #  8 entries found for <b>like</b>.<br>
    #  To select an entry, click on it. (Click 'Go' if nothing happens.)
    #  <form name="entry"  method=post action="/cgi-bin/dictionary"><table border="0" cellpadding="0" cellspacing="0" valign="top"><tr><td>
    #  <input type=hidden name=hdwd value="like"><input type=hidden name=book value=Dictionary> <select style="font-family:arial;font-size:9pt;" name=jump size=6 onChange="document.entry.submit(this.form)">
    #  <option>like[1,verb]
    #  <option>like[2,noun]
    #  <option>like[3,adjective]
    #  <option>like[4,preposition]
    #  <option>like[5,noun]
    #  <option>like[6,adverb]
    #  <option>like[7,conjunction]
    #  <option>like[8,verbal auxiliary]
    #  </select><input type=hidden name=list value="like[1,verb]=615354;like[2,noun]=615373;like[3,adjective]=615390;like[4,preposition]=615424;like[5,noun]=615453;like[6,adverb]=615470;like[7,conjunction]=615489;like[8,verbal auxiliary]=615513"></td><td valign="top">
    #
    $selections = 0;
    if (($form =~ s/^To view.*?GO TO.$//m)
	|| ($form =~ s/^.*To select.*?Click.$//m)
	|| ($wholePage =~ s/To select an entry, click on it.//i)) {
	$selections = 1;
	@option = ($form =~ /^<option.*>(.*)$/mg);
	@listvalue = ($form =~ /name=list value="(.*)">/g);
    }
    &trace_array(\@option, &TL_VERBOSE, "options");

# convert html into something more readable
    $form =~ s/<br>/\n/g;       # change html linebreak to newline
    $form =~ s/<option.*?\n//mg;# delete the selection list, to be shown later
	$form =~ s/<[^>]*>//g;      # delete all the other html tags
    $form =~ s/\n+/\n/g;        # delete multiple newlines

# visualize non-alpha-numerical ANSI characters
    convert_char ();

    print $form;
    print "\n";

# prompt the user for further actions: look up another word or stop here
    $content = "";
    if ($selections | $reentry) {
	do {
	    if (! $show_all) {
		print "----------------------------------------\n";
		print "Here are the related words:\n";
		for (my $i=0, my $j = 1;$i<@option;$i++, $j++){
		    print "$j: $option[$i]\n";
		}
		print "\nEnter a number to select from the list, or enter . to quit\n";
		$buf = <STDIN>;
		chomp $buf;
	    }
	    else {
		$current_selection++;
		$buf = ($current_selection <= @option) ? "$current_selection" : ".";
	    }

	    &debug_out(&TL_VERBOSE, "buf='%s'\n", $buf);
	    if ($buf eq '.') {
		$content = "";
		$finished_selections = 1;
	    }
	    elsif ($buf !~ /\d/ or $buf > @option or $buf <= 0) {
		print "What did you just do? Enter . to end the session\n";
		$content = "";
		$finished_selections = 0;
	    }
	    else {
		$buf -= 1;
		$content = "hdwd=$word&book=Dictionary&jump=";
		$content .= urlencode ($option[$buf]);
		$content .= "&list=";
		$content .= urlencode ($listvalue[0]);
		$reentry = 1;
		$finished_selections = 1;
	    }

	} until ( $finished_selections )

	} # end of if selections

} # end of while content


###########
# subroutine: open a socket at SOCK
###########

sub openSock {
    $socketaddr= sockaddr_in $port, inet_aton $host or die "Bad hostname\n";
    socket SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp') or die "Bad socket\n";
    connect SOCK, $socketaddr or die "Bad connection\n";
    select((select(SOCK), $| = 1)[0]);
}


###########
# subroutine: urlencode a string
###########

sub urlencode {

    my $ask = shift @_;
    my @a2 = unpack "C*", $ask;
    my $s2 = "";
    while (@a2) {
	$s2 .= sprintf "%%%X", shift @a2;
    }
    return $s2;

}


###########
# subroutine: send post request to target web site
###########

sub post {

    my $content = shift @_;
    print SOCK "POST http://www.m-w.com/cgi-bin/dictionary HTTP/1.0\r\n";
    print SOCK "Content-type: application/x-www-form-urlencoded\r\n";
    my $contentLength = length $content;
    print SOCK "Content-length: $contentLength\r\n";
    print SOCK "\r\n";
    print SOCK "$content";

}

###########
# subroutine: make those non-English characters visible
###########
# uses the global variable $form
# the character codes are iso8859-1

sub convert_char {

    $form =~ s/&quot;/chr(34)/eg;
    $form =~ s/&amp;/chr(38)/eg;
    $form =~ s/&lt;/chr(60)/eg;
    $form =~ s/&gt;/chr(62)/eg;
    $form =~ s/&nbsp;/chr(160)/eg;
    $form =~ s/&iexcl;/chr(161)/eg;
    $form =~ s/&cent;/chr(162)/eg;
    $form =~ s/&pound;/chr(163)/eg;
    $form =~ s/&curren;/chr(164)/eg;
    $form =~ s/&yen;/chr(165)/eg;
    $form =~ s/&brvbar;/chr(166)/eg;
    $form =~ s/&sect;/chr(167)/eg;
    $form =~ s/&uml;/chr(168)/eg;
    $form =~ s/&copy;/chr(169)/eg;
    $form =~ s/&ordf;/chr(170)/eg;
    $form =~ s/&laquo;/chr(171)/eg;
    $form =~ s/&not;/chr(172)/eg;
    $form =~ s/&shy;/chr(173)/eg;
    $form =~ s/&reg;/chr(174)/eg;
    $form =~ s/&macr;/chr(175)/eg;
    $form =~ s/&deg;/chr(176)/eg;
    $form =~ s/&plusmn;/chr(177)/eg;
    $form =~ s/&sup2;/chr(178)/eg;
    $form =~ s/&sup3;/chr(179)/eg;
    $form =~ s/&acute;/chr(180)/eg;
    $form =~ s/&micro;/chr(181)/eg;
    $form =~ s/&para;/chr(182)/eg;
    $form =~ s/&middot;/chr(183)/eg;
    $form =~ s/&cedil;/chr(184)/eg;
    $form =~ s/&sup1;/chr(185)/eg;
    $form =~ s/&ordm;/chr(186)/eg;
    $form =~ s/&raquo;/chr(187)/eg;
    $form =~ s/&frac14;/chr(188)/eg;
    $form =~ s/&frac12;/chr(189)/eg;
    $form =~ s/&frac34;/chr(190)/eg;
    $form =~ s/&iquest;/chr(191)/eg;
    $form =~ s/&Agrave;/chr(192)/eg;
    $form =~ s/&Aacute;/chr(193)/eg;
    $form =~ s/&Acirc;/chr(194)/eg;
    $form =~ s/&Atilde;/chr(195)/eg;
    $form =~ s/&Auml;/chr(196)/eg;
    $form =~ s/&Aring;/chr(197)/eg;
    $form =~ s/&AElig;/chr(198)/eg;
    $form =~ s/&Ccedil;/chr(199)/eg;
    $form =~ s/&Egrave;/chr(200)/eg;
    $form =~ s/&Eacute;/chr(201)/eg;
    $form =~ s/&Ecirc;/chr(202)/eg;
    $form =~ s/&Euml;/chr(203)/eg;
    $form =~ s/&Igrave;/chr(204)/eg;
    $form =~ s/&Iacute;/chr(205)/eg;
    $form =~ s/&Icirc;/chr(206)/eg;
    $form =~ s/&Iuml;/chr(207)/eg;
    $form =~ s/&ETH;/chr(208)/eg;
    $form =~ s/&Ntilde;/chr(209)/eg;
    $form =~ s/&Ograve;/chr(210)/eg;
    $form =~ s/&Oacute;/chr(211)/eg;
    $form =~ s/&Ocirc;/chr(212)/eg;
    $form =~ s/&Otilde;/chr(213)/eg;
    $form =~ s/&Ouml;/chr(214)/eg;
    $form =~ s/&times;/chr(215)/eg;
    $form =~ s/&Oslash;/chr(216)/eg;
    $form =~ s/&Ugrave;/chr(217)/eg;
    $form =~ s/&Uacute;/chr(218)/eg;
    $form =~ s/&Ucirc;/chr(219)/eg;
    $form =~ s/&Uuml;/chr(220)/eg;
    $form =~ s/&Yacute;/chr(221)/eg;
    $form =~ s/&THORN;/chr(222)/eg;
    $form =~ s/&szlig;/chr(223)/eg;
    $form =~ s/&agrave;/chr(224)/eg;
    $form =~ s/&aacute;/chr(225)/eg;
    $form =~ s/&acirc;/chr(226)/eg;
    $form =~ s/&atilde;/chr(227)/eg;
    $form =~ s/&auml;/chr(228)/eg;
    $form =~ s/&aring;/chr(229)/eg;
    $form =~ s/&aelig;/chr(230)/eg;
    $form =~ s/&ccedil;/chr(231)/eg;
    $form =~ s/&egrave;/chr(232)/eg;
    $form =~ s/&eacute;/chr(233)/eg;
    $form =~ s/&ecirc;/chr(234)/eg;
    $form =~ s/&euml;/chr(235)/eg;
    $form =~ s/&igrave;/chr(236)/eg;
    $form =~ s/&iacute;/chr(237)/eg;
    $form =~ s/&icirc;/chr(238)/eg;
    $form =~ s/&iuml;/chr(239)/eg;
    $form =~ s/&eth;/chr(240)/eg;
    $form =~ s/&ntilde;/chr(241)/eg;
    $form =~ s/&ograve;/chr(242)/eg;
    $form =~ s/&oacute;/chr(243)/eg;
    $form =~ s/&ocirc;/chr(244)/eg;
    $form =~ s/&otilde;/chr(245)/eg;
    $form =~ s/&ouml;/chr(246)/eg;
    $form =~ s/&divide;/chr(247)/eg;
    $form =~ s/&oslash;/chr(248)/eg;
    $form =~ s/&ugrave;/chr(249)/eg;
    $form =~ s/&uacute;/chr(250)/eg;
    $form =~ s/&ucirc;/chr(251)/eg;
    $form =~ s/&uuml;/chr(252)/eg;
    $form =~ s/&yacute;/chr(253)/eg;
    $form =~ s/&thorn;/chr(254)/eg;
    $form =~ s/&yuml;/chr(255)/eg;

}

__END__

=head1 NAME
Save this file to "mw", which stands for merriam-webster, then you can run it as
"mw word" or "perl mw word"

=head1 DESCRIPTION
a simple web robot to look up a word from Merriam-Webster site using POST 
method, and print the text response to STDOUT. 

=head1 README
A special-purpose simple script that looks up a word from Merriam-Webster site.
This script only uses Socket and no other external modules or packages, and it 
demonstrates the use of POST method to submit a FORM. However, the specific use 
of this script is limited to talking to www.m-w.com, and the fact that many 
parameters are hard-coded makes it dependent on the stability of that web site. 
Nonetheless, since everything is explicitly written, it is very easy to manually
change those hard-coded strings. 
Version 2.0 adds the ability to look up a misspelled word, and changes the 
behavior when the user is presented a selection of words from displaying the 
menu once to always looping back to prompt the user again with the menu.

=head1 PREREQUISITES
requires strict module and Socket module

=head1 SCRIPT CATEGORIES
Web

=cut
