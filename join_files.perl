# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# join_files.perl: make each file a separate column of the result
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

$num_files = (1 + $#ARGV);

# Read in each file to a separate array
# Also, print the file name as the label for column i
$max_lines = 0;
for ($i = 0; $i < $num_files; $i++) {
    local(*array) = eval "*file_$i";
    @array = split(/\n/, &read_file($ARGV[$i]));
    $max_lines = &max($max_lines, (1 + $#array));
    print "\t" if ($i > 0);
    printf "%s", $ARGV[$i];
}
printf "\n";

# Print each row of each array
for ($l = 0; $l < $max_lines; $l++) {
    for ($i = 0; $i < $num_files; $i++) {
	local(*array) = eval "*file_$i";
	local($field) = "";
	if ($l <= $#array) {
	    $field = $array[$l];
	}
	print "\t" if ($i > 0);
	printf "%s", $field;
    }
    printf "\n";
}
