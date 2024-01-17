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
# - Have the -n option reflect lines not paragraphs if -para option used
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$v $i $para $slurp $context $C $A $B $n $max $show_filename $w $c $nocr $cr_fix/;

# Determine values of command-line arguments
# TODO: use expanded names for all options (e.g., -not_atching for -v)
&init_var_exp(*v, &FALSE);		# grep -v option to show lines not matching
&init_var_exp(*i, &FALSE);		# grep -i for case insensitive matching
&init_var_exp(*para, &FALSE);	# paragraph input mode
&init_var_exp(*slurp, &FALSE);	# apply the pattern to entire files
&init_var_exp(*context, 0);		# grep 'context' (i.e., before & after) option
&init_var_exp(*C, $context);	# alias for -context
&init_var_exp(*A, $C);		# grep 'after' context option
&init_var_exp(*B, $C);		# grep 'before' context option
&init_var_exp(*n, &FALSE);		# grep line-number option
&init_var_exp(*c, &FALSE);		# just show count
my($just_count) = $c;
&init_var_exp(*max, &MAXINT);	# maximum number of matches to show
&init_var_exp(*show_filename, 
	  (scalar @ARGV) > 2);	# include file name in output
## TODO: &init_var_exp(*c, &FALSE);		# just show count
&init_var_exp(*w, &FALSE);		# match word boundaries
&init_var_exp(*nocr, &FALSE);	# alias for -cr_fix
&init_var_exp(*cr_fix, &FALSE);	# remove DOS-style carriage returns

# If CR's are to be removed, re-invoke over a filtered file
if ($cr_fix) {
    my($all_input_data) = &read_entire_input();
    ## # TODO: get access to original command-line and just remove -cr_fix arg
    ## &run_command_over("$0 -v=$v -i=$i  -para=$para  -slurp=$slurp  -context=$context  -C=$C  -A=$A  -B=$B  -n=$n  -c=$c  -max=$max -show_filename=$show_filename -w=$w -cr_fix=0", $all_input_data);

    # Rerun over the CR filtered data, disabling CR fix (of course).
    # NOTE: Other arguments handled via exported init variables.
    # TODO: Make sure exported env. vars causes no problems with subprocesses.
    &run_command_over("$0 -cr_fix=0", $all_input_data);
    &exit();
}

# Show usage statement if insufficient arguments
#
if (!defined($ARGV[0])) {
    ## my($options) = "options = [-v] [-i] [-para] [-slurp] [-context=N | -C=N] [-A=n] [-B=n] [-n] [-c] [-w] [-max=N] [-show_filename] [-nocr] ";
    my($options) = "options = [-v] [-i] [-para] [-slurp] [-context=N | -C=N] [-A=n] [-B=n] [-n] [-c] [-w] [-max=N] [-show_filename] ";
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
$/ = 0777 if ($slurp);		# complete-file input mode

# Modify the pattern to reflect word boundaries
if ($w) {
    $pattern = "\\b$pattern\\b";
}

my(@before);			# lines before current target context

&debug_print(&TL_DETAILED, "checking for pattern '$pattern'; just_count=$just_count\n");
my($hit_count) = 0;
my($after_context) = 0;
my($current_file) = defined($ARGV[0]) ? $ARGV[0] : "<stdin>";
my($current_line) = 0;
my($current_count) = 0;
my($undisplayed_counts) = &TRUE;

while (<>) {
    &dump_line("$_", &TL_VERY_VERBOSE);
    $current_line++;
    my($include) = &FALSE;
    my($filespec) = ($show_filename ? "${current_file}: " : "");

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
		printf "%d: ", $current_line;
	    }
	    printf "%s", $_;
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
	$current_line = 0;
	$current_count = 0;
	$undisplayed_counts = &FALSE;
    }
}

# Show the final counts unless just displayed
if ($just_count && $undisplayed_counts) {
    if ($show_filename) {
	print "$current_file:";
    }
    print "$current_count\n";
}
