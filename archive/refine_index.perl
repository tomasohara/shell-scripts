# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# refine_index.perl: converts citation-key index into name index
#
# example input:
#
#    \indexentry{Yarowsky-92}{2}
#    \indexentry{Bruce-Wiebe-95}{3}
#    \indexentry{Smith-Medin-81}{5}
#    \indexentry{Rosch-73}{5}
#
# example output:
#
#    \indexentry{Yarowsky}{2}
#    \indexentry{Bruce}{3}
#    \indexentry{Wiebe}{3}
#    \indexentry{Smith}{5}
#    \indexentry{Medin}{5}
#    \indexentry{Rosch}{5}
#
# TODO:
# - handle problem with conflated last names
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

use strict;
use vars qw/$bibfile/;

if (!defined($ARGV[0])) {
    my($options) = "options = [-bibfile=file]";
    my($example) = "ex: $script_name lexical-acquisition.idx\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*bibfile, "");	# bibtex file for resolving the keys

while (<>) {
    &dump_line();
    chop;
    my($use_old) = &TRUE;

    # check for an index entry
    if (/\\indexentry{(.*)}{(\d+)}/) {
	my($key, $page) = ($1, $2);

	# Try to resolve the key in the bibtex file
	# TODO: cache all of the author last names in memory
	# TODO: add better handling for keys with quotes
	if ($bibfile ne "") {
	    my($search_key) = $key;
	    $search_key =~ s/\'/./g;
	    my($entry) = &perl("perlgrep.perl -para '$search_key' '$bibfile'");
	    if ($entry =~ /(author|editor)\s*=\s*[{\"](.*)[}\"]/) {
		my($authors) = $2;
		foreach my $author (split(/\s+and\s+/, $authors)) {
		    last if ($author eq "others");
		    $use_old = &FALSE;

		    # Extract the last name from the author
		    # TODO: handle special cases like von, etc.
		    my($last_name) = &trim($author);
		    $last_name =~ s/.*\s+(\S+)/$1/;
		    $last_name =~ s/{(.*)}/$1/;

		    printf "\\indexentry{%s}{%d}\n", $last_name, $page; 
		}
	    }
	}

	# If key is of form name-YY, or name1-name2-YY, etc., use individual names
	elsif ($key =~ /\w.*\-\d+/) {
	    # Break up the key into (name1, [name2], ... year, [rest])
	    foreach my $name (split(/\-/, $key)) {
		last if ($name =~ /^\d/);	# stop when a year is encountered
		last if ($name eq "etal");  # likewise for "et al." specification

		$use_old = &FALSE;
		printf "\\indexentry{%s}{%d}\n", $name, $page; 
	    }
	}

	# Otherwise print the entry as is
	if ($use_old) {
	    printf "\\indexentry{%s}{%d}\n", $key, $page; 	    
	}
    }
}

&exit();
