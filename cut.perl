# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# cut.perl: cut columns like the cut utility but w/o line restrictions (length???)
#
# TODO:
# - Add option to real support for CSV files via existing package (not the hack below).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
}
use English;				# for $PREMATCH, etc.

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$f $fields $delimiter $delim $fix $missing $col $delim_token/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-col=N | -fields=fieldspec] [-fix] [-delim=text] [-missing=string]";
    $options .= "\nwhere fieldspec = [N1 or N1-M1], ...";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -f=1 english_morph_prep.list >| english_morph_prep.keys\n\n";
    $example .= "$script_name -f='2,1' iso-639-language-codes.list > language-to-code.list\n\n";
    my($note) = "";
    $note .= "Notes:\n\n";
    $note .= " - Delimiter defaults to a tab, and missing value to '???'.\n";
    $note .= " - Field numbers are 1-based as in Unix cut.\n";
    $note .= " - Option aliases: -f for -col; -fields for -fieldspec; -delimiter for -delim.\n\n";

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*col, "");                            # alias for -fields="COL+1"
&init_var(*f, "");		                # alias for -fields
&assertion(($col eq "") || ($f eq ""));
## OLD: &init_var(*fields, $f);	                # list of field numbers or ranges to include
my($fields_default) = (($col ne "") ? $col : $f); # default for -fields using -col or -f values
#
&init_var(*fields,               # 1-based field specification as in cut,
	  $fields_default);      # (e.g, "Ni or Ni-Mi[, ...]")
#
my($field_spec) = $fields;
&init_var(*fix, &FALSE);		# treat whitespace as field delimiters
## TODO: 
&init_var(*delim, "\t");                # alias for -delimiter
## OLD: &init_var(*delimiter, "\t");	# field delimiter for data
## TODO: 
&init_var(*delimiter, $delim);		# field delimiter for data
&init_var(*missing, "???");		# value to use if not enough columns
if ($fix) {
    &assertion($delimiter =~ /^\s+$/);
}

# Extract the fields, expanding N-M into enumeration
&debug_print(&TL_VERY_DETAILED, "fs=$field_spec\n");
while ($field_spec =~ /(\d+)-(\d+)/) {
    my($start, $end) = ($1, $2);
    &debug_print(&TL_VERY_DETAILED, "s=$start, e=$end\n");
    my($subfield_spec) = "";

    # Convert i-j format (e.g., "4-7" => "4,5,6,7")
    for (my $i = $start; $i < $end; $i++) {
	$subfield_spec .= "$i,"
    }
    $subfield_spec .= "$end";

    # Replace range
    $field_spec = $PREMATCH . $subfield_spec . $POSTMATCH; 
}
# HACK: allow fields to have embedded comma's (as in value support below)
my(@fields) = split(/,/, $field_spec);

# Make sure delimiter conflict with regex operator properly escaped
my($escape_count) = 0;
sub MAX_ESCAPE_COUNT { 5 };
# 
while (($delimiter =~ /([^\\]|^)([\|\*\+\.])/) && ($escape_count < &MAX_ESCAPE_COUNT)) {
    $delimiter = "$1\\$2";
    $escape_count++;
}
&debug_print(&TL_VERBOSE, "Escape count: $escape_count; delimiter: $delimiter\n");

# Extract fields from each line of input
while (<>) {
    &dump_line();
    chop;

    # Optionally, fix up the data into columns
    # Note: mainly intended for whitespace-delimited data
    if ($fix) {
	&assertion($delimiter eq "\t");
	s/\s+/$delimiter/g;
    }
    # HACK: Replace non-space delimiter within quotes with <DELIM> token
    # TODO: Use unassigned Unicode value in place of <DELIM>
    my($line) = $_;
    $line = &encode_delimiter($line);
    ## BAD: my(@columns) = split("$delimiter", $line);
    my(@columns) = split(/$delimiter/, $line);
    &trace_array(\@columns, &TL_VERY_DETAILED, "\@columns");

    # Print each of column entries for the fields specified
    my(%missing_columns);
    for (my $i = 0; $i <= $#fields; $i++) {
	print $delimiter if ($i > 0);
	my($col) = $fields[$i] - 1;
	my($value) = $columns[$col];
	## TODO: $value = "" if (! defined($value));
	# HACK: Restore delimiter within value (e.g., ',' within address)
	if (! defined($value)) {
	    $value = "???";
	    if (! defined($missing_columns{$col})) {
		&debug_print(&TL_USUAL, "Warning: Missing value at line $. column $col\n");
		$missing_columns{$col} = &TRUE;
	    }
	}
	$value = &decode_delimiter($value);
	## OLD: print $value if (defined($columns[$col]));
	print $value;
    }
    print "\n";
}

#-------------------------------------------------------------------------------

# encode_delimiter(text): replaces delimiter within quoted text with dummy token
# EX: ($delimiter == "," && encode_delimiter('"1, 2, 3", cuatro, cinco')) => '"1<DELIM> 2<DELIM> 3", cuatro, cinco'
# EX: ($delimiter == "," && encode_delimiter('uno, dos tres, cuatro, cinco')) => 'uno, dos tres, cuatro, cinco'
# EX: ($delimiter == "|" && encode_delimiter('pme_reference_no|pmrnote_enttyp_txt|pmnote_dscrptn_txt|pmrnote_estpstd_dt')) => 'pme_reference_no|pmrnote_enttyp_txt|pmrnote_subjct_txt|pmnote_dscrptn_txt|pmrnote_estpstd_dt|pmrnote_estpstd_tm'
#
## our($delim_token) = "<DELIM>";
sub DELIM_TOKEN { "<DELIM>"; }
## our($max_embedded) = 1024;
sub MAX_EMBEDDED { 1024; }
#
sub encode_delimiter {
    my($text) = @_;
    &debug_print(&TL_VERY_VERBOSE, "encode_delimiter(@_)\n");
    if ($delimiter !~ /^\s+$/) {
        ## BAD: my($before) = $_;
	my($before) = $text;
	my($count) = 0;
        while (($text =~ /^([^"]*")([^"]*$delimiter[^"]*)(")/) && ($count < &MAX_EMBEDDED)) {
            my($pre, $value, $post) = ($` + $1, $2, $3 . $');        # emacs quirk: '
            $value =~ s/$delimiter/&DELIM_TOKEN/ge;
            $text = $pre . $value . $post;
	    $count++;
	    &debug_print(&TL_VERBOSE, "revision $count to text: '$text'\n");
        }
        my($after) = $text;
        if ($before ne $after) {
            &debug_print(&TL_DETAILED, "line changed from '$before' to '$after'\n");
        }
	if ($count == &MAX_EMBEDDED) {
	    &warning("max number of delim-embedded fields reached: &MAX_EMBEDDED\n");
	}
    }
    &debug_print(&TL_MOST_VERBOSE, "encode_delimiter(@_) => '$text'\n");
    return ($text);
}

# decode_delimiter(text): replaces delimiter token with actual value
#
sub decode_delimiter {
    my($text) = @_;
    $text =~ s/&DELIM_TOKEN/$delimiter/ge;
    &debug_print(&TL_VERY_VERBOSE, "decode_delimiter(@_) => '$text'\n");
    return ($text);
}
    
