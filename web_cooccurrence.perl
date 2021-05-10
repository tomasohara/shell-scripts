#!/usr/bin/perl -sw
#
# web_mutual_information.perl: show mutual information of two terms (or dice
# coefficient) based on web co-occurrence frequencies:
#    f(+w1, +w2),   f(+w1, -w2),  f(-w1, +w2),  f(-w1, -w2)
#
# NOTES:
# - This is a simple wrapper around &web_cooccurrence in extra.perl, 
# which in turn invokes web_freq.perl.
#
# - Underlying statistics:
#   mutual information:
#	log2(P(X=1,Y=1) / P(X=1) * P(Y=1))
#
#   the Dice coefficient:
#	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
#

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN { $dir = `dirname $0`; chop $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$verbose $d/;
require 'extra.perl';
use vars qw/$use_MI $use_dice/;

# Process the command-line options
if (!defined($ARGV[1])) {
    my($options) = "options = [-altavista] [-hotbot] [-use_MI] [-use_dice]";
    my($example) = "examples:\n\n$script_name dog cat\n\n";
    $example .= "$0 -d=4 perro dog\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";			# TODO: add optional note

    die "\nusage: $script_name [options] term1 term2\n\n$options\n\n$example\n$note\n";
}
## &init_var(*fu, &FALSE);		# TODO: add command-line options
my($term1) = $ARGV[0];
my($term2) = $ARGV[1];

&print_web_cooccurrence_header();
my($metric) = &web_cooccurrence($term1, $term2);
printf "co-occurrence of '%s' and '%s': %.3f\n", $term1, $term2, $metric;

&exit();
