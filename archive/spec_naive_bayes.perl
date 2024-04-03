# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# spec_naive_bayes.perl: create a model specification for Naive Bayes given
# the COCO factors specification
#
# sample input:
#
#    FACTORS A 20/B 4/C 16/D 14/E 13/F 16/G 2/H 2/I 2/J 2/K 2/L 2/M 2/N 2/O 2/P 2/Q 1//
#    LIST
#
# sample output:
#
#    AB 1 AC 1 AD 1 AE 1 AF 1 AG 1 AH 1 AI 1 AJ 1 AK 1 AL 1 AM 1 AN 1 AO 1 AP 1 AQ 1 A -15
#
# alternative output format;
#
#    AB,AC,AD,AE,AF,AG,AH,AI,AJ,AK,AL,AM,AN,AO,AP,AQ
#
# NOTE: This model is equivalent to
#
#		AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ
#               -----------------------------------------------
#                                    A**15
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*class_var, "A");
&init_var(*coco_format, &FALSE);

if (!defined($ARGV[0])) {
    $options = "options = [-class_var=label]";
    $example = "ex: $script_name SAMPLE.FACTORS\n";

    die "\nusage: $script_name [options] factors_file\n\n$options\n\n$example\n\n";
}

# Read in the factors specification file
$factors = &read_file($ARGV[0]);

# Remove extraneous text from the factors statement
$factors =~ s/FACTORS //;	# remove "FACTORS " prefix
## $factors =~ s/\/\/[^\000]*/\//g;	# remove "/\nLIST" suffix
$factors =~ s/\/\s*LIST\s*//;	# remove "/\nLIST" suffix
$factors =~ s/\d+ *\///g;	# drop number of values & delim ("20/")
$factors =~ s/${class_var} //;	# drop class variable
$factors =~ s/\s\s+/ /g;	# change runs of whitespace to a blank
$factors = &trim($factors);

# Add interaction of class variable with each of the other variables
if ($coco_format == &FALSE) {
    # ex: "B C D" => "AB 1  AC 1  AD 1"
    $num_vars = ($factors =~ s/(\S+) ?/${class_var}$1 1  /g);

    # Add demoninator which is (1 / (class_var ^ N - 1)), where N is the number
    # of variables. (This accounts for the intersections of each interaction.)
    $factors .= sprintf "${class_var} -%d", ($num_vars - 1);
}
else {
    # ex: "B C D" => "AB, AC, AD"
    $num_vars = ($factors =~ s/(\S+) ?/${class_var}$1, /g);
    $factors =~ s/,\s*$//;               # drop last comma
}


printf "%s\n", $factors;
