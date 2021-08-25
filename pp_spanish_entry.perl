# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# pp_entry.perl: pretty print entries from NTC's Spanish-English dictionary.
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

sub usage {
    select(STDERR);
    print <<USAGE_END;

Usage: $script_name [options] file

options = [-english] [-trans_listing=0|1] [-sp_ignore_phrasals=0|1]


Pretty print entries from NTC\'s Spanish-English dictionary.


examples: 

spanish-lookup poder | $script_name > poder.pp

$script_name -sp_ignore_phrasals=1 como_dice.list > como_dice.pp2


USAGE_END

    exit 1;
}

# Check command-line options
&init_var(*english, &FALSE);
&init_var(*spanish, ! $english);
&init_var(*help, &FALSE);

# If command line arguments are missing or -help specified, show a usage message and then exit.
# Note: $#ARGV = (# of arguments) - 1
if ($help || (($#ARGV < 0) && &blocking_stdin())) {
    &usage();
}

# TODO: invoke init_pp function
if ($spanish) {
    require 'spanish.perl';
    eval "*pp_entry = *sp_pp_entry";
    eval "*trans_listing = *sp_trans_listing";
    eval "*prefix = *sp_prefix";
}
else {
    require 'english.perl';
    eval "*pp_entry = *eng_pp_entry";
    eval "*trans_listing = *eng_trans_listing";
    eval "*prefix = *eng_prefix";
}
use vars qw/$simple $first_trans $first_sense/;
&debug_out(4, "using %s, %s, & %s\n", *pp_entry, *trans_listing, *prefix);


# Prettyprint each of the word entries as a separate block
#
print "\n";
while (<>) {
    &dump_line();
    chop;
    my($word) = "";
    my($entry) = "";
    my($key) = "";

    # Ignore comments
    if (/^ *\#/) {
	if (/word:.*translation/) {
	    $trans_listing = &TRUE;
	    $prefix = "\t";
	}
	next;
    }

    if ($trans_listing) {
	if ($_ !~ /:\t/) {
	    print "$_\n";
	    next;
	}
	($word, $entry) = split(/:\t/, $_);
	$key = "n/a";
	print "$word";
    }
    else {
	($key, $word, $entry) = split(/\t/, $_);
    }
    &debug_print(5, "k=$key w=$word\n");

    if ($entry !~ /^[ \t]*$/) {
	print &pp_entry($word, $entry);
    }
    else {
	print "\t\n";
    }
}


