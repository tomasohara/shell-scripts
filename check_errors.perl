# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
##
## #!/bin/sh -- # -*- perl -*-
## eval 'exec perl -Ssw $0 ${1+"$@"}'
##  if 0;

#!/bin/csh -f perl -sw
#!/usr/local/bin/perl -sw
#
# check_errors.perl: Scan the error log for errors, warnings and other
# suspicious results. This prints the offending line bracketted by >>>
# and <<< along with N lines before and after to provide context.
#
# TODO:
# - * Change 'error' in filename test as warning.
# - Don't reproduce lines in case of overlapping context regions.
# - Have option to make search case-insensitive.
# - Add option to show which case is being violated (since context display can be confusing, especially when control characters occur in context [as with output form linux script command]).
# - Convert into python.
# - Have option to skip filenames in input.
# - Add codes for error types for convenient filtering (a la pylint).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); 
    require 'common.perl';
    use vars qw/$verbose /;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$warning $warnings $skip_warnings $context $no_asterisks $skip_ruby_lib $ruby/;

if (!defined($ARGV[0])) {
    my $options = "options = [-warnings] [-context=N] [-no_astericks] [-skip_ruby_lib]";
    my $example = "ex: $script_name whatever\n";
    my $note = "Notes:\n";
    $note .= "- The default context is 1\n";
    $note .= "- Warnings are skipped by default\n";
    $note .= "- Use -no_astericks if input uses ***'s outside of error contexts\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$note\n";
}

&init_var(*warning, &FALSE);		# alias for -warnings
&init_var(*warnings, $warning);		# include warnings?
&init_var(*skip_warnings, ! $warnings);	# omit warnings?
my($show_warnings) = (! $skip_warnings);
&init_var(*context, 3);			# context lines before and after
&init_var(*no_asterisks, &FALSE);	# skip warnings for '***' in text
my $asterisks = (! $no_asterisks);
&init_var(*ruby, &FALSE);	   	# alias for -skip_ruby_lib
&init_var(*skip_ruby_lib, $ruby);	# skip Ruby library related errors

my $NULL = chr(0);			# null character ('\0')
my(@before_context);			# prior context
my($line);	       			# line in context

our($current_file) = defined($ARGV[0]) ? $ARGV[0] : "";
&show_current_file_info();

my($after) = 0;				# number of more after-context lines
while (<>) {
    &dump_line();
    chop;
    my($has_error) = &FALSE;		# whether line has error

    # Check for error log corruption
    if ($show_warnings && /$NULL/) {
	# Null chars usually indicate file corruption (eg, multiple writers)
	$has_error = &TRUE;
	s/$NULL/^@/g;		# change null char '^@' to "^@" ('^' & '@')
    }

    # Check for known errors
    # NOTE: case-sensitive to avoid false negatives
    # TODO: relax case sensitivity
    # TODO: rework so that the pattern which matches can be identified (e.g., 'foreach my $pattern (@error_patterns) { if ($line =~ $pattern) { ... }')
    # TODO: rework error in line test to omit files
    elsif (## &debug_print(7, "here\n", 7) &&
	   /^(ERROR|Error)\b/
	   || /command not found/i
	   || /No space/
	   || /Segmentation fault/
	   || /Assertion failed/
	   || /Assertion .* failed/
	   || /Floating exception/

	   # Unix shell errors (e.g., bash or csh)
	   || /Can\'t execute/
	   || /Can\'t locate/
	   || /Word too long/
	   || /Arg list too long/
	   || /Badly placed/
	   || /Expression Syntax/
	   || /No such file or directory/
	   || /permission denied/i
	   || /Illegal variable name/
	   || /Unmatched [\"\']\./	# HACK: emacs highlight fix (")
	   || /Bad : modifier in/
	   || /Syntax Error/
	   || /Too many (\(|\)|arguments)/
	   || /illegal option/
	   || /Missing name for redirect/
	   || /Variable name must contain/
	   || /unexpected EOF/
	   || /unexpected end of file/
	   || /command not found/
	   || /^sh: /
           || /\[Errno \d+\]/

	   # Perl interpretation errors
	   # TODO: Add more examples like not-a-number, which might not be apparent.
	   # ex: Argument "not-a-number" isn't numeric in addition (+) at /home/tomohara/bin/cooccurrence.perl line 67, <> line 1.
	   || /^\S+: Undefined variable/
	   || /Invalid conversion in printf/
	   || /Execution .* aborted/
	   || /used only once: possible typo/
	   || /Use of uninitialized/
	   || /Undefined subroutine/
	   || /Reference found where even-sized list expected/
	   || /Out of memory/
	   || /Unmatched .* in regex/
	   || /at .*\.(perl|prl|pl|pm) line \d+/	# catch-all for other perl errors

	   # Build errors
	   || /(Make|Dependency) .* failed/
	   || /cannot open/
	   || /cannot find/
	   || /:( fatal)? error /

	   # Java errors
	   || /^Exception\b/

	   # Ruby errors
	   || /: undefined\b/
	   || /\(\S+Error\)/		# ex: wrong number of arguments (1 for 0) (ArgumentError)
	   || /Exception.*at.*\.rb/

	   # Python errors
	   || /^Traceback/		# stack trace
	   || /^\S+Error/		# exception

	   # Cygwin errors
	   || /\bunable to remap\b/

	   # Miscellaneous errors
	   || /wn: invalid search/
	   ) {
	$has_error = &TRUE;
    }

    # Check for warnings and starred messages
    # TODO: Have option for restricting ***'s to start of line.
    elsif ($show_warnings &&
	   (/\b(Warning|WARNING)\b/ 
	    || /\b(Error|error)\b/	# matches within line error case above
	    || /: No match/		# shell warning?
	    || /: warning\b/		# Ruby warnings
	    || /^bash: /                # ex: "bash: [: : unary operator expected"
	    || /Traceback|\S+Error/     # Python exceptions (caught)
	    || ($asterisks && /\*\*\*/))) {
	$has_error = &TRUE;
    }

    # Filter certain case
    if ($has_error && $skip_ruby_lib && /\/usr\/lib\/ruby/) {
	&debug_print(&TL_DETAILED, "Skipping ruby library error at line $. ($_)\n");
	$has_error = &FALSE
    }

    # If an error, then display line preceded by pre-context
    if ($has_error) {
	# Show up the N preceding context lines, unless there is an overlap
	# with previous error context in which no pre-context is shown.
	my($num) = ($after > 0) ? 0 : (scalar @before_context);
	my($i);
	for ($i = 0; $i < $num; $i++) {
	    printf "%-4d     %s\n", ($. - ($num - $i)), $before_context[$i]; 
	}

	# Display the error line and update the after context count
	printf "%-4d >>> %s <<<\n", $., $_;
	$after = $context;
    }

    # Otherwise print line only if in the post-context
    else {
	printf "%-4d     %s\n", $., $_ if ($after > 0);
	printf "\n" if ($after == 1);
	$after--;
    }

    # Update the context
    # TODO: efficiency please
    push(@before_context, $_);
    shift @before_context if ($#before_context == $context);

    # Check for a change in file, if so reset the accumlators
    # NOTE: ARGV closed to reset line numbering
    if (eof) {
	close(ARGV);
	$current_file = defined($ARGV[0]) ? $ARGV[0] : "";
	&show_current_file_info();
	@before_context = ();
    }
}

# Optionally add extra blank line at end.
# NOTE: Used for cc-errors alias invoking first over errors and then warnings.
print "\n" if ($verbose);

#------------------------------------------------------------------------

# show_current_file_info(): display name of current file (and warning inclusion status)
#
sub show_current_file_info {
    if ($current_file ne "") {
	if ($verbose) {
	    print "========================================================================\n";
	    printf "Errors%s\n\n", ($skip_warnings ? "" : " and Warnings");
	}
	print "$current_file\n";
    }
}
