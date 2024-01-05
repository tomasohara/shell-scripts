# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# prep_tome_reader.perl: prepares a tab-separated file for tome reader by
# duplicating every fifth record to get around annoying 'feature' in which
# each fifth record is replaced with a registation entry:
#	Please register to view this record
#
# NOTES:
# - The TomeReader tab-separate input format actually requires a <TAB><SPACE>,
#   since otherwise the character after the tab is ignored.
# - The sort option should be checked when working with foreign language
#   texts (e.g., spanish_english.dict) that are sorted non-standardly.
#   Alternatively, the file can be sorted beforehand as shown in the example.
#

require 'common.perl';

if (!(defined($ARGV[0]))) {
    $options = "options = [-dup]";

    $example = "examples:\n\n$script_name my-tab-separated-info.data\n\n";
    $example .= "sort spanish_english.dict | $0 - >| spanish_english.prep\n\n";

    $notes = "Notes:\n\n- The file must be in tab-separated format.\n";
    $notes .= "- Sort the file if not already or if sorted non-standardly\n  (e.g.Spanish chorizo after cuidado.\n";
    $notes .= "- Use the Tabbed Separated File option on the open dialog of Import command.\n\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$notes";
}

&init_var(*dup, &FALSE);	# duplicate every fifth entry to workaround unregistered feature

my($line) = 0;
while (<>) {
    &dump_line();
    chop;

    # Add a space after all tabs
    s/\t/\t /g;

    # Print the current line
    $line++;
    &debug_out(&TL_DETAILED, "$line: '$_'\n");
    print "$_\n";

    # Duplicate every fifth line
    if ($dup && (($line % 5) == 0)) {
	$line++;
	&debug_out(&TL_DETAILED, "$line: DUPL '$_'\n");
	print "$_\n";
    }
}

&exit();
