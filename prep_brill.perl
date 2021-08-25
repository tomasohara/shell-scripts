# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -ws
#!/usr/local/Gnu/bin/perl -w
#!/usr/bin/perl -w
# TODO: #!/usr/bin/env perl -sw
# Perl options:   -w code warnings; -s cmdline vars
#
# preparse.perl: preprocess a file prior to parsing or part-of-speech tagging
#
# NOTE:
# - For efficieny, comment out the detailed debug tracing (e.g., "## DEBUG: ...")/
# - However, *** don't delete debug tracing ***: very helpful for diagnosing problems processing
#   different types of texts.
#
# TODO:
# - reconcile with changes made at Cycorp
# - reconcile with preparse.perl
# - fix handling of miscellaneous whitespace characters (e.g., horizontal tab and form feed)
# - track down source of extraneous newlines (e.g., double newline at end)
#

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$retain_punct $para $same_line $preserve_tabs $tabs $space_tokenization $space/;

#------------------------------------------------------------------------

# usage(): show options for command line usage
#
sub usage {
    my($program_name) = $0;
    $program_name =~ s/\.?\.?\/.*\///;

    select(STDERR);
    print <<USAGE_END;

Usage: $program_name [options] [file|-] ...

options = [-retain_punct] [-para] [-same_line] [-[preserve_]tabs] [-space_[tokenization]]

Preprocesses a file prior to parsing, part-of-speech tagging (via Brill tagger), etc.

Examples:

$program_name lex_rel.defs

$program_name -same_line -preserve_tabs 

Notes:
- Use -same_line if line endings should be preserved.
- Tabs preserved unless -space_tokenization specified.

USAGE_END

    &exit();
}

#------------------------------------------------------------------------

# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if ($#ARGV == -1) {
    &usage();
}
&init_var(*retain_punct, &FALSE);	# retain the formatting of the punctuation
&init_var(*para, &FALSE);		# paragraph input mode
&init_var(*same_line, &FALSE);		# keep sentences on same line
&init_var(*tabs, &FALSE);		# alias for -preserve_tabs
&init_var(*preserve_tabs, $tabs);	# retain tab characters (e.g., tab-separated data file)
&init_var(*space, &FALSE);		# alias for -space_tokenization
&init_var(*space_tokenization, $space);	# use single space for runs of whitespace

# Optionally set paragraph input mode
if ($para) {
    $/ = "";
}


while (<>) {
    # note: line not chomp'ed as ending newline used in patterns
    my($line) = $_;
    &dump_line($line);
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "hex in: %s\n", &run_command_over("hexview.perl - <", $line));

    # Optionally convert horizontal tabs to vertical ones
    ## TODO: my($HTAB) = "\x08";
    my($HTAB) = "\x07";				# bell character
    my($mapped) = &FALSE;                       # mapped tabs
    if ($preserve_tabs && ($line =~ /\t/)) {
	$mapped = &TRUE;
	&debug_print(&TL_VERY_DETAILED, "Mapping tabs\n");
	## BAD: &assert(! /$HTAB/);
	&assert($line !~ /$HTAB/);
	## BAD: s/\t/$HTAB/g;
	## BAD: s/\t/\x07/g;
	$line =~ s/\t/\x07/g;
	## BAD: &assert(! /\t/);
	&assert($line !~ /\t/);
	&debug_print(&TL_VERY_VERBOSE, "Done mapping tabs\n");
    }
    # OLD: $_ = $line;
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));
    # TODO: track down problem with $_ being unset somewhere above after the dump_line

    # Check for sentence breaks
    # TODO: account for punctuation and alphanumeric tokens before line-ending periods
    if (! $same_line) {
	&debug_print(&TL_VERY_DETAILED, "Applying sentence-break fixes\n");
	$line =~ s/([\?\!])/$1\n/g;			# treat '?' and '!' as end of sentences
	$line =~ s/(\s[a-z]+ *\.)/$1\n/g;		# add new line after lowercase word followed by period
	$line =~ s/([\)\]\}] *\.)/$1\n/g;		# add new line after right parenthesis, brace or bracket
	$line =~ s/(\s[A-Z][a-z]{3,} *\.)/$1\n/g;	# likewise for proper nouns (capitalized words > length 3)
    }
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));

    # Put whitespace around punct & other special chars
    # NOTE: possessives are restored
    if (! $retain_punct) {
	&debug_print(&TL_VERY_DETAILED, "Isolating punctuation\n");
	$line =~ s/([\~\!\@\#\$\%\^\&\*\(\)\_\+\`\-\=\{\}\|\[\]\\\:\"\;\'\<\>\?\,\.\/])/ $1 /g;
	$line =~ s/ \' s / \'s /g;			# restore possessive
    }
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));

    # Convert newlines to spaces unless at end of sentence
    if (! $same_line) {
	&debug_print(&TL_VERY_DETAILED, "Converting internal newlines to spaces\n");
	$line =~ s/([^\.\?\! \r\n\t])\s*\n/$1 /g;
    }
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));

    # Combine multiple spaces into single space; also remove leading and trailing spaces.
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));
    if ($space_tokenization) {
	&debug_print(&TL_VERY_DETAILED, "Applying space tokenization\n");
	# TODO: simplifying patterns (due to newline handling)
	$line =~ s/\s+(.)/ $1/g;
	$line =~ s/^\s//;
	$line =~ s/\s\n$/\n/;
    }
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "line='%s'\nhex: %s\n", $line, &run_command_over("hexview.perl - <", $line));

    # Convert vertical tabs back into horizontal ones
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "hex2: %s\n", &run_command_over("hexview.perl - <", $line));
    ## OLD: &assert($line eq $_);
    if ($preserve_tabs && $mapped) {
	&debug_print(&TL_VERY_DETAILED, "Restoring tabs\n");
	## BAD: s/$HTAB/\t/g;
	$line =~ s/\x07/\t/g;
	&assert($line =~ /\t/);
    }

    # Print final result
    ## DEBUG: &debug_out(&TL_VERY_DETAILED, "hex out: %s\n", &run_command_over("hexview.perl - <", $line));
    print($line);
}
