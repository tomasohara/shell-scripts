# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# make_single_annotations.perl: duplicate sentences with mutliple annotations
# for the classification variable, keeping a different annotation per copy
#
# example input:
#
# The 30-day simple yield fell <wf sense=2>to</wf> an average 8.19% from 8.22%;
# the 30-day compound yield slid <wf sense=2>to</wf> an average 8.53% from 8.56%. 
#
# output:
#
# The 30-day simple yield fell <wf sense=2>to</wf> an average 8.19% from 8.22%;
# the 30-day compound yield slid to an average 8.53% from 8.56%. 
# The 30-day simple yield fell to an average 8.19% from 8.22%;
# the 30-day compound yield slid <wf sense=2>to</wf> an average 8.53% from 8.56%. 
#
# NOTE: Assumes all sentences are on a single line
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

$line_num = 0;
while (<>) {
    &dump_line();
    chop;
    $line_num++;

    # Make duplicates when there are more than one annotation
    if (/<wf[^<>]+sense=[^<>]+>[^\000]*<wf[^<>]+sense=[^<>]/) {
	&debug_print(4, "duplicating line $line_num\n");

	# Find each sense annotation and make duplicate for it
	local(@copies, $post);
	local($text) = "";
	while (/<wf[^<>]+sense=[^<>]+>([^<>]+)<\/wf>/) {
	    $pre = $`; $pattern = $&; $word = $1; $post = $'; $_ = $';

	    # The current copy only gets the sense from the current pattern
	    $pre =~ s/<\/?wf[^<>]*>//g; 	# strip previous sense tags 
	    $post =~ s/<\/?wf[^<>]*>//g;	# strip subsequent sense tags
	    push(@copies, ($text . $pre . $pattern . $post));
	    $text .= $pre . " $word ";
	    &debug_print(6, "\$_ = $_\n");
	}
	
	# Combine all the copies together (separated by newlines)
	$_ = join("\n", @copies);
    }
    # Sanity check on first sentence
    &assert('0 == /<wf[^<>]+sense=[^<>]+>.*<wf[^<>]+sense=[^<>]/');

    print "$_\n";
}

