# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# upcase_dirs.perl: Make all directory names upper case
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (defined($ARGV[0]) && ($ARGV[0] eq "help")) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

local(@file_list) = glob("*");
foreach $file_name (@file_list) {
    &debug_out(6, "$file_name\n");

    if (-d $file_name) {
	$new_file_name = &to_upper($file_name);
	# $new_file_name = "\U$file_name";

	if ($new_file_name ne $file_name) {
	    &debug_out(3, "issuing: rename $file_name $new_file_name\n");
	    rename $file_name, $new_file_name;
	}
    }
}
