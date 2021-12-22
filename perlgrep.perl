#!/usr/bin/perl -sw
# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# perlgrep.perl: quick n' dirty version of (e)grep via perl regex matching
#
# This faciliates the use of tab characters, as well the use of Perl's
# extended regular expression pattern matching (eg, \d for [0-9]).
#
# NOTES:
# - The -para option now supports paragraph matching (same as perl -0 option)
#       perlgrep.perl -d=6 -i coling comps.bib |& less
# - If escape sequences are used in patterns, then the pattern should be
#   single quoted rather than double quoted when using csh or bash. Otherwise,
#   an error similar to the following might occur.

#       $ perlgrep "\\TODO{[^}]+}[^\s%]" *.tex
#       Unrecognized escape \T passed through before HERE mark in regex m/\T << HERE ODO {[^}]+}[^\s%]/ at /e/cartera-de-tomas/bin/perlgrep.perl line 79, <> line 1.
#       
# TODO:
# - *** Track down missing files:
#     ex: perl-grep -c '\x00' test_sort_json_annots.d*.19nov21.*.log
#     [see /home/tomohara/osr/docs/_adhoc.22nov21.log]
# - ** Add test suite against regular grep.
# - Use parentheses around print and printf throughout.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$v $i $para $slurp $context $C $A $B $n $max $show_filename $w $c $h/;

# Determine values of command-line arguments
# TODO: use expanded names for all options (e.g., -not_atching for -v)
&init_var(*v, &FALSE);		# grep -v option to show lines not matching
&init_var(*i, &FALSE);		# grep -i for case insensitive matching
&init_var(*para, &FALSE);	# paragraph input mode
&init_var(*slurp, &FALSE);	# apply the pattern to entire files
&init_var(*context, 0);		# grep 'context' (i.e., before & after) option
&init_var(*C, $context);	# alias for -context
&init_var(*A, $C);		# grep 'after' context option
&init_var(*B, $C);		# grep 'before' context option
&init_var(*n, &FALSE);		# grep line-number option
&init_var(*c, &FALSE);		# just show count
my($just_count) = $c;
&init_var(*max, &MAXINT);	# maximum number of matches to show
&init_var(*h, &FALSE);		# grep -h option to hide filename
&init_var(*show_filename, 	# include file name in output
	  ((scalar @ARGV) > 2) && !$h);
## TODO: &init_var(*c, &FALSE);		# just show count
&init_var(*w, &FALSE);		# match word boundaries

# Show usage statement if insufficient arguments
#
if (!defined($ARGV[0])) {
    my($options) = "options = [-v] [-i] [-w] [-para] [-A=n | -B=n | -C=n] [-max=N] [-show_filename | -h] [-c]";
    my($example) = "examples:\n\n$script_name -v \"\\t\\t\" 052698_nb_ci_062498_nb55.diff\n\n";
    $example .= "perlgrep.perl -para -i \"coling\" comps.bib | & less\n\n";
    $example .= "$0 -show_filename -max=1 \"\\r\\n\" *.lisp\n\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}
my($pattern) = shift @ARGV;

select(STDOUT); $| = 1;		    # set stdout unbuffered

# Optionally set paragraph input mode
$/ = "" if ($para);		# paragraph input mode
## OLD: $/ = 0777 if ($slurp);		# complete-file input mode
undef $/ if ($slurp);		# complete-file input mode

# Modify the pattern to reflect word boundaries
if ($w) {
    $pattern = "\\b$pattern\\b";
}

my(@before);			# lines before current target context

&debug_print(&TL_DETAILED, "checking for pattern '$pattern'; just_count=$just_count\n");
my($hit_count) = 0;
my($after_context) = 0;
my($current_file) = defined($ARGV[0]) ? $ARGV[0] : "<stdin>";
my($record_num) = 0;
my($para_line_num) = 1;
my($current_count) = 0;
my($undisplayed_counts) = &TRUE;

# TODO: use Iterator::Files to account for problems with files haing leadng spaces
# See http://search.cpan.org/~jv/Iterator-Diamond-1.01/lib/Iterator/Files.pm.
while (<>) {
    my($num_para_lines) = 0;
    &debug_print(&TL_VERY_VERBOSE, "[$current_file] ");
    if ($para) {
	&debug_out(&TL_VERY_DETAILED, "P%d L%d:\t%s", $., $para_line_num, $_);
	my(@para_lines) = split(/\n/, $_);
	$num_para_lines = ($#para_lines + 1);
	&assert($num_para_lines > 0);
	&debug_out(&TL_VERY_VERBOSE, "# para lines: %d\n", $num_para_lines);
    }
    else {
	&dump_line("$_", &TL_VERY_VERBOSE);
    }
    $record_num++;
    my($include) = &FALSE;
    ## OLD: my($filespec) = ($show_filename ? "${current_file}: " : "");

    # See if the pattern matches the current line
    # NOTE: s qualifier treats string as single line (in case -para specified)
    if (($i && /$pattern/is) || (/$pattern/s)) {
	$include = (! $v);
	$after_context = ($include ? ($A + 1) : 0);
    }
    else {
	$include = $v;
	$after_context--;
    }
    &debug_out(&TL_VERY_VERBOSE, "include=%d; after_context=%d\n", $include, $after_context);

    if ($include) {
	$current_count++;
	$undisplayed_counts = &TRUE;
	if (! $just_count) {
	    if ($B > 0) {
		printf "%s", join("", @before);
		@before = ();
	    }

	    if ($show_filename) {
		print "$current_file:";
	    }
	    if ($n) {
		printf("%d: ", ($para ? $para_line_num : $record_num));
	    }
	    printf("%s", $_);
	}

	# See whether to stop the search due to max hit count
	if (++$hit_count >= $max) {
	    &debug_out(&TL_DETAILED, "max hits (%d) reached\n", $max);
	    last;
	}
    }
    elsif ($after_context > 0) {
	printf "%s", $_ unless ($just_count);
    }
    elsif ($B > 0) {
	# update the lines-before context
	# NOTE: This is only done for lines not otherwise printed
	# TODO: look into a more efficient queue implementation
	push (@before, $_);
	shift @before if ($#before == $B);
    }
    if (eof) {
	# Display the counts for the previous file
	if ($just_count) {	    
	    if ($show_filename) {
		print "$current_file:";
	    }
	    print "$current_count\n";
	}

	# Update the current-file status indicators
	$current_file = defined($ARGV[0]) ? $ARGV[0] : "<stdin>";
	$record_num = 0;
	$para_line_num = 1;
	$current_count = 0;
	$undisplayed_counts = &FALSE;
    }
    else {
	## TEST: $current_file = defined($ARGV[0]) ? $ARGV[0] : "<stdin>";
	#
	if ($para) {
	    $para_line_num += ($num_para_lines + 1);
	}
    }
}

# Show the final counts unless just displayed
if ($just_count && $undisplayed_counts) {
    if ($show_filename) {
	print "$current_file:";
    }
    print "$current_count\n";
}
