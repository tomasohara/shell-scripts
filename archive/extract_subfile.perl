# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
#   Extract a portion of a file, base on inclusion regions.
#
#   Usage: extract_subfile.pe [start] [end]
#
#   extract_subfile.pe "    FUNCTION" "    DESCRIPTION" < clman.data
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Set defaults
$start = "";
$end = "^\\s*\$";

# Check for special ComLex test
&init_var(*comlex_test, &FALSE);
if ($comlex_test) {
    ## perl -Ssw extract_subfile.perl -filter_file=dso_verbs.list -from=":TAGS[\s\S]*)" -to=")" :ORTH :ORTH <../comlex/COMLEX-SYNTAX-2.2 > dso_comlex_verbs.list
    &init_var(*filter_file, "dso_verbs.list");
    &init_var(*from, ':TAGS[\s\S]*\)');
    &init_var(*to, ")");
    @ARGV = (":ORTH", ":ORTH", "../ComLex/COMLEX-SYNTAX-2.2");
    ## $filter_list = "abandon";
    ## @ARGV = (":ORTH", ":ORTH", "comlex.list");
}

# Parse command-line: split_subfile.pe [options] start [end] [base]
# Also check for variables set from the command-line (eg, -include_start=0)
#
&init_var(*include_start, $TRUE);
&init_var(*include_end, $FALSE);
&init_var(*just_once, &FALSE);
&init_var(*max_count, ($just_once ? 1 : &MAXINT));

&init_var(*from, "");
&init_var(*to, "");
## $* = 1;

&init_var(*filter_file, "");
&init_var(*filter_list, ($filter_file ne "" ? &read_file($filter_file) : ""));
@filter = split(/\n/, $filter_list);

if (!defined($ARGV[0])) {
    $options = "[-include_start] [-include_end] [-max_count=N] [-filter_file=f]";
    $usage = "Usage: $script_name $options start_pattern [end_pattern] < data";
    $example = "Examples:\n\n$script_name FUNCTION DESCRIPTION < clman.data\n\n";
    $example .= "perl -Ssw $script_name -filter_file=dso_words.list :ORTH :ORTH < COMLEX-SYNTAX-2.2 > dso_comlex_full.list\n\n";
    $example .= "perl -Ssw $script_name -filter_file=dso_verbs.list -from=\":TAGS[\\s\\S]*\)\" -to=\")\" :ORTH :ORTH < COMLEX-SYNTAX-2.2 > dso_comlex_verbs.list\n\n";
    die("\n$usage\n\n$example\n");
}

$start = $ARGV[0];
shift @ARGV;
if (defined($ARGV[0])) {
    $end = $ARGV[0];
    shift @ARGV;
}

&debug_print(4, "Start pattern (inclusive=$include_start): /${start}/\n");
&debug_print(4, "End pattern (inclusive=$include_end) : /${end}/\n");
&debug_out(4, "filter=(%s)\n", join(',', @filter));
&debug_print(5, "Just once=$just_once\n");

# Process each line of the input stream
$include = $FALSE;
$count = 0;
$subtext = "";
while (<>) {
    &dump_line($_, 7);

    # check for start of inclusion region
    if (/$start/
	&& (($include == $FALSE) || ($start eq $end))) {

	# Stop if the occurrence count is above maximum
	$count++;
	if ($count > $max_count) {
	    &debug_print(4, "ignoring rest of input (max=$max_count)\n");
	    last;
	}

	# Print any current inclusion text and reset buffer for next subfile
	$include = $TRUE;
	&filter_subtext($subtext, *filter);
	$subtext = "";
	$subtext .= $_ if ($include_start);
    }

    # check for end of inclusion region
    elsif (/$end/ 
	   && ($include == $TRUE)) {
	$include = $FALSE;
	$subtext .= $_ if ($include_end);
	&filter_subtext($subtext, *filter);
	$subtext = "";
    }

    # accumulate the text if within the inclusion region
    elsif ($include) {
	$subtext .= $_;
    }

    # otherwise ignore the text
    else {
	&debug_out(6, "ignoring: %s", $_);
    }
}

&filter_subtext($subtext, *filter);

#------------------------------------------------------------------------------

# filter_subtext(text, filter_list)
#
# See if the text contains one of the substrings from filter_list.
# NOTES:
#     This uses a case-sensitive match.
#     Empty strings aren't included.
#
sub filter_subtext {
    local($text, *filter) = @_;
    local($filter);
    local($include) = &FALSE;

    if ($text eq "") {
	$include = &FALSE;
    }
    elsif ($#filter < 0) {
	$include = &TRUE;
    }
    else {
	foreach $filter (@filter) {
	    if (index($text, $filter) >= 0) {
		$include = &TRUE;
		last;
	    }
	}
    }

    if ($include) {
	if ($from ne "") {
	    ## &debug_print(5, ".TAGS: {\n$&}\n") if ($text =~ /:TAGS[\s\S]*/);
	    &debug_print(5, "deleting: $&\n") if ($text =~ /$from/);
	    $text =~ s/$from/$to/;
	}
	&debug_out(5, "including: {\n%s}\n", $text);
	print $text;
    }
    else {
	&debug_out(5, "filtering: {\n%s}\n", $text);
    }
}
