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
# - ** Have option to disable line number
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
use vars qw/$relaxed $strict $quiet $matching $before $after $info/;

if (!defined($ARGV[0])) {
    my $options = "options = [-warnings | -info] [-context=N] [-no_astericks] [-skip_ruby_lib]";
    $options .= " [-relaxed | -strict] [-verbose] [-quiet] [-before=N] [-after=N]";
    my $example = "ex: $script_name whatever\n";
    my $note = "Notes:\n";
    $note .= "- The default context is 1.\n";
    $note .= "- Warnings are skipped by default.\n";
    $note .= "- Use -no_astericks if input uses ***'s outside of error contexts.\n";
    $note .= "- Use -relaxed to include special cases (e.g., xyz='error').\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$note\n";
}

&init_var(*warning, &FALSE);		# alias for -warnings
&init_var(*warnings, $warning);		# include warnings?
&init_var(*skip_warnings, ! $warnings);	# omit warnings?
my($show_warnings) = (! $skip_warnings);
&init_var(*info, &FALSE);               # informative messages (e.g., FYI's)?
my($show_informative) = $info;
&init_var(*context, 3);			# context lines before and after
&init_var(*before, $context);		# lines of context to show before
&init_var(*after, $context);		# "" show after
&init_var(*no_asterisks, &FALSE);	# skip warnings for '***' in text
my $asterisks = (! $no_asterisks);
&init_var(*ruby, &FALSE);	   	# alias for -skip_ruby_lib
&init_var(*skip_ruby_lib, $ruby);	# skip Ruby library related errors
&init_var(*relaxed, &FALSE);            # relaxed for special cases
&init_var(*strict, ! $relaxed);         # alias for relaxed=0 
&init_var(*quiet, &FALSE);              # just output errors proper (e.g., no filenames)
&init_var(*matching, &FALSE);           # show matching text

my $NULL = chr(0);			# null character ('\0')
my(@before_context);			# prior context
my($line);	       			# line in context

our($current_file) = defined($ARGV[0]) ? $ARGV[0] : "";
&show_current_file_info();

my($after_lines) = 0;			# number of more after-context lines
while (<>) {
    &dump_line();
    chop;
    my($has_error) = &FALSE;		# whether line has error
    my($match_info) = "";             # text span within line that matched

    # Check for error log corruption
    if ($show_warnings && /$NULL/) {
	# Null chars usually indicate file corruption (eg, multiple writers)
	$has_error = &TRUE;
	$match_info = "E1 [$&]";
	s/$NULL/^@/g;		# change null char '^@' to "^@" ('^' & '@')
	&debug_print(&TL_MOST_DETAILED, "1. has_error=$has_error\n");
    }

    # Check for known errors
    # NOTE: case-sensitive to avoid false negatives
    # TODO: relax case sensitivity
    # TODO: rework so that the pattern which matches can be identified (e.g., 'foreach my $pattern (@error_patterns) { if ($line =~ $pattern) { ... }')
    # TODO: rework error in line test to omit files
    # NOTE: It can be easier to add special-case rules rather than devise a general regex;
    # ex: 'error' occuring within a line even at word boundaries can be too broad.
    elsif (## DEBUG: &debug_print(&TL_MOST_DETAILED, "here\n", 7) &&
	   ## OLD: /^(ERROR|Error)\b/	   
	   /^(Error)\b/i
	   ## OLD: || /command not found/i
	   ## NOTE: maldito modules package polutes environment and man page not clear about disabling
	   || (/command not found/i && (! /Cannot switch to Modules/))
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
	   ## OLD: || /command not found/
	   || /^sh: /
           || /\[Errno \d+\]/
	   || /Operation not permitted/
	   || /Command exited with non-zero status/
	   || /ommand terminated by signal/

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

	   # Build errors (also cp, etc.)
	   || /(Make|Dependency) .* failed/
	   || /cannot create/
	   || /cannot open/
	   || /cannot find/
	   || /cannot overwrite/
	   || /:( fatal)? error /

	   # Git errors (WTH: can't modern tools say 'error'???)
	   || /^fatal:/
	   
	   # Java errors
	   || /^Exception\b/

	   # Ruby errors
	   || /: undefined\b/
	   || /\(\S+Error\)/		# ex: wrong number of arguments (1 for 0) (ArgumentError)
	   || /Exception.*at.*\.rb/

	   # Python errors
	   || /^Traceback/		# stack trace
	   || /^\S+Error/		# exception (e.g., TypeError)
	   || /:\s*error\s*:/i          # argparse error (e.g., main.py: error: unrecognized arguments
	   || /^FAILED\b/i              # pytest failure

	   # Cygwin errors
	   || /\bunable to remap\b/

	   # Miscellaneous errors
	   || /wn: invalid search/
	   || /socket has failed to (bind|listen)/
	   ) {
	$has_error = &TRUE;
	$match_info = "E2 [$&]";
	&debug_print(&TL_MOST_DETAILED, "2. has_error=$has_error\n");
    }

    # Check for warnings and starred messages
    # TODO: Have option for restricting ***'s to start of line.
    # NOTE: $strict includes "error" or "warning" occurring anywhere, etc.;
    # It was added to excluded keyword usage as in "conflict_handler='error'".
    # TODO: Put strict in separate section, such as having 4 sections overall :
    #    {error, warning} x {non-strict, strict}
    elsif ($show_warnings &&
	   ((/\b(warning)\b/i           # warning token occuring 
	     && ((! /='warning'/i) || $strict)) # ... includes quotes if strict
	    || (/\b(error)\b/i	        # matches within line error case above
		&& ((! /='error'/i) || $strict))  # ... includes quotes if strict
	    || /: No match/		# shell warning?
	    || /: warning\b/		# Ruby warnings
	    || /^bash: /                # ex: "bash: [: : unary operator expected"
	    || /Traceback|\S+Error/     # Python exceptions (caught)
	    || /\b\S+Warning/           # Python warning (e.g., RuntimeWarning)
	    || (/exception|failed/      # logger messages (e.g., "Training job failed")
		&& $strict)
	    || ($asterisks && /\*\*\*/))) {
	$has_error = &TRUE;
	$match_info = "W1 [$&]";
	&debug_print(&TL_MOST_DETAILED, "3. has_error=$has_error\n");
    }
    elsif ($show_informative &&
	   (/\bFYI:/i                   # ex: "FYI: Prepending mezla to path"
	   || /information/i)) {        # ex: "How about some information, please?"
	$has_error = &TRUE;
	$match_info = "I1 [$&]";
	&debug_print(&TL_MOST_DETAILED, "4. has_error=$has_error\n");
    }

    # Filter certain case(s)
    if ($has_error && $skip_ruby_lib && /\/usr\/lib\/ruby/) {
	&debug_print(&TL_DETAILED, "Skipping ruby library error at line $. ($_)\n");
	$has_error = &FALSE;
	&debug_print(&TL_MOST_DETAILED, "5. has_error=$has_error\n");
    }

    # If an error, then display line preceded by pre-context
    &debug_print(&TL_MOST_DETAILED, "final has_error=$has_error\n");
    if ($has_error) {
	# Show up the N preceding context lines, unless there is an overlap
	# with previous error context in which no pre-context is shown.
	my($num) = ($after_lines > 0) ? 0 : (scalar @before_context);
	my($i);
	for ($i = 0; $i < $num; $i++) {
	    printf "%-4d     %s\n", ($. - ($num - $i)), $before_context[$i]; 
	}

	# Display the error line and update the after context count
	printf "%-4d >>> %s <<<\n", $., $_;
	if ($matching) {
	    printf "%-4d match: %s\n", $., $match_info;
	}
	$after_lines = $after;
    }

    # Otherwise print line only if in the post-context
    else {
	printf "%-4d     %s\n", $., $_ if ($after_lines > 0);
	printf "\n" if ($after_lines == 1);
	$after_lines--;
    }

    # Update the context
    # TODO: efficiency please
    push(@before_context, $_);
    shift @before_context if ($#before_context == $before);

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
    if (($current_file ne "") && ($quiet == &FALSE)) {
	if ($verbose) {
	    print "========================================================================\n";
	    printf "Errors%s\n\n", ($skip_warnings ? "" : " and Warnings");
	}
	print "$current_file\n";
    }
}
