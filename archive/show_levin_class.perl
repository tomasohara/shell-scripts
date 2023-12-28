# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# show_levin_class.perl: wrapper around show_levin_class.sh to allow for inflections
# in the lookup
# TODO: rework all of show_levin_class.sh in perl
#
# Copyright (c) 2001 Cycorp, Inc.  All rights reserved.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

require 'NL_support.perl';
use vars qw/$port $verbose/;

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-verbose]";
    my($example) = "examples:\n\n$script_name fire\n\n";
    ## $example .= "$0 example2\n\n";			        # TODO: revise example 2
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";			# TODO: add optional note

    die "\nusage: $script_name [options] word\n\n$options\n\n$example\n$note\n";
}
## &init_var(*fu, &FALSE);		# TODO: add command-line options
my($show_levin_classes_script) = &find_library_file("show_levin_class.sh");

# Initial the NL-specific module for accessing Cyc
&init_NL_support();

# Get list of words to process
my(@words);
if (($#ARGV == 0) && ($ARGV[0] eq "-")) {
    # Assume the words are given one per line in the standard input
    @words = <STDIN>;
}
else {
    @words = @ARGV;
}

foreach my $word (@words) {
    $word = &trim($word);
    my($root) = &find_root_wordform($word, "verb");
    my($classes) = "";
    my($other_info) = "";

    # Extract the classes using the show_levin_class.sh utility
    # example ouput:
    # $ show_levin_class.sh express
    # Levin classes for express: 11.1 48.1.2
    # 11.1	Send Verbs
    # 48.1.2	Reflexive Verbs of Appearance
    #
    my($class_info) = &run_command("${show_levin_classes_script} $root");
    if ($class_info =~ /classes for $root: (.*)\n([^\000]+)/) {
	$classes = $1;
	$other_info = $2;
    }

    # Print the word, root and then Levin class information
    print "$word\t$root\t$classes\n";
    print "${other_info}\n\n" if ($verbose);
}

&exit();
