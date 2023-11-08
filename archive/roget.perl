# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# roget.perl: misc script for working the Roget categories
#
# right now it just moves files to the proper subdirectory,
# based on category number
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    &usage();
}

if ($ARGV[0] eq "ORGANIZE") {
    shift @ARGV;
    foreach $file (@ARGV) {
	if ($file =~ /(\d+)[a-e]?_/) {
	    $cat_num = $1;

	    $dir = &category_dir($cat_num);
	    &issue_command("mv $file $dir/$file");
	}
    }
}
elsif ($ARGV[0] =~ /^\d/) {
    $cat_num = $ARGV[0];
    $dir = &category_dir($cat_num);
    print "$dir is directory for category $cat_num\n";
}
else {
    &usage();
}

#------------------------------------------------------------------------------

sub usage {
    $options = "options = n/a";
    $example = "ex: $script_name {[ORGANIZE file ...] | [CatNUM ...]}\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}


sub category_dir {
    local($category) = @_;

    if ($category <= 179) {
	$dir = "ABSTRACT";
    }
    elsif ($category <= 315) {
	$dir = "SPACE";
    }
    elsif ($category <= 449) {
	$dir = "MATTER";
    }
    elsif ($category <= 599) {
	$dir = "INTELLECT";
    }
    elsif ($category <= 819) {
	$dir = "VOLITION";
    }
    elsif ($category <= 1000) {
	$dir = "AFFECTIONS";
    }
    else {
	&debug_out(2, "Unknown category number: $category\n");
	$dir = "UNKNOWN";
    }

    return ($dir);
}
