# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# extract_matches.perl: simple script for extracting text in a file matching a particular pattern
# This is equivalent to the following bash function
#     function extract_matches () { perl -ne "while (/$1/) { printf \"%s\\n\", \$1; s/$1//; }" $2 }
# See count_it.perl for a similar script for counting the frequency of such patterns.
#
# Portions Copyright (c) 2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 2002-2004 Tom O'Hara  All rights reserved.
#
# TODO:
# - Specify list of fields to output (as in cut.perl).
# - Check for looping due to empty patterns (e.g., '(.*)').
# - Only apply s qualifier when -para or -slurp specified.
# - Add -chomp option as in count_it.perl.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$utf8 $script_name $verbose/;
}


# Be strict about variable usage (unless if -nostrict specified)
use vars qw/$nostrict/;
if (! defined($nostrict)) {
    use strict;
}
#
## # Specify additional diagnostics and strict variable usage, excepting those
## # for command-line arguments (see init_var's in &init).
## #
## OLD: use strict;
##
use vars qw/$replacement $restore $para $file $fields $one_per_line
    $max_count $i $locale $single $preserve $slurp/;
use vars qw/$multi_per_line $multi_line_match $sep/;

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-replacement=perl_template] [-fields=N] [-para] [-file] [-restore] [-max_count=n] [-one_per_line|-single] [-locale] [-i] [-preserve]";
    $options .= " [-multi_per_line] [-sep=T]";
    my($example) = "examples:\n\nls -l | $0 \"\\.([^\\.]+\$)\"\n\n";
    $example .= "echo '(trace' `$script_name \"^\\(defun (\\S+)\" init.lisp` ')'\n\n";
    $example .= "$script_name -replacement='\$1-\$2-method' '^\\(def-instance-method \\((\\S+) (\\S+)' /home/tom/cycl/subloop-class-example.lisp\n\n";
    $example .= "$script_name -para -replacement='A \$1 : \$2' 'def\\S+\\s*(\\S+)\\s*[^\\\"]*\\s*\\\"([^\\\"]+)\\\"' parse-template-utilities.lisp\n\n";
    $example .= "echo \"a b c d\" | $script_name -restore='\$2' -fields=2 \"(\\S) (\\S)\"\n\n";

    my($note) = "";
    $note .= "notes:\n\nUse -restore to simulate look-ahead (see example above).\n";
    $note .= "With - for pattern, it defaults to tab-delimited fields (e.g., via -fields=N).\n";

    print STDERR "\nusage: $0 [options] pattern\n\n$options\n\n$example\n$note\n";
    &exit();
}
&init_var(*replacement, "");		# pattern for replacement (e.g, \1-\2-method)
&init_var(*restore, "");		# portion of matching text to be restored
&init_var(*para, &FALSE);		# paragraph input mode
&init_var(*slurp, &FALSE);		# alias for -file
&init_var(*file, $slurp);		# entire file input mode
&init_var(*fields, 1);			# number of output fields
&init_var(*single, &FALSE);		# alias for -one_per_line
# NOTE: multi_per_line (as in count_it.perl) is the default
&init_var(*one_per_line, $single);	# only count one instance of the pattern per line
&init_var(*multi_per_line, ! $single);  # multiple matches per line
&init_var(*max_count,			# maximum number of matches per line
	  ## OLD: $one_per_line ? 1 : &MAXINT);
	  $multi_per_line ? &MAXINT : 1);
&init_var(*i, &FALSE);			# ignore case
&init_var(*preserve, &FALSE);		# preserve case (when -i in effect)
&debug_print(&TL_DETAILED, "Note: -preserve not implemented\n") if ($preserve);
&init_var(*locale, &FALSE);		# use locale information
&init_var(*multi_line_match, &FALSE);   # use m qualifier for multi-line matching
&init_var(*sep, "\t");                   # field separatpr
my($single_line_input) = (! ($para || $slurp));
my($ignore_case) = $i;
my($auto_pattern) = &FALSE;		# automatically derive pattern (for tab-delimited fields)

# Initialization locale information
# if ($locale) {
    use locale;
# }

## TODO -i option
## &init_var(*i, &FALSE);		# case insensitive
my($pattern) = shift @ARGV;
if ($pattern eq "-") {
    $auto_pattern = &TRUE;
    $pattern = (($fields > 1) ? "(\\S+)" : "(.*)");
}

# Optionally set paragraph or entire-file input mode
if ($para) {
    $/ = "";
}
if ($file) {
    undef $/;
}

# Enforce a single pattern per line when beginning-of-line pattern (^) used 
# TODO: add `extract_matches.perl '^\s*(\S+)' cs-p4-linux-hosts.info >| cs-p4-linux-hosts.list` as test case
if (($pattern =~ /^\^/) || ($pattern =~ /\$$/)) {
    $max_count = 1;
}
&debug_print(&TL_VERY_DETAILED, "max_count=$max_count\n");

# For multiple-field patterns, generate a replacement with tab separated fillers
# note: this assumes that replacement is same as "\$1" default
my($i);
my($fix_replacement) = ($replacement eq "");
$replacement = "\$1" if $fix_replacement;
for ($i = 2; $i <= $fields; $i++) {
    ## OLD:
    ## $replacement .= "\t\$$i" if ($fix_replacement);
    ## $pattern .= "\t(\\S+)" if ($auto_pattern);
    $replacement .= "$sep\$$i" if ($fix_replacement);
    $pattern .= "$sep(\\S+)" if ($auto_pattern);
}

# Put grouping parenthesis around pattern, if none present
if ($pattern !~ /\(.*\)/) {
    $pattern = "(" . $pattern . ")";
}

# Make sure the replacement uses $1, etc. in place of \1 to avoid Perl warning
# (e.g. "\1 better written as $1 at (eval 2) line 1, <> line 17.")
$replacement =~ s/\\(\d+)/\$$1/g;
#
&debug_out(&TL_VERY_DETAILED, "pattern='%s'; replacement='%s'; restore='%s'\n", $pattern, $replacement, $restore);

# Scan through the text (checking the pattern line by line)
my($total_matched) = 0;
while (<>) {
    if ($utf8) {
	$_ = decode_utf8($_);
    }
    # TODO: add sanity check about DOS carriage returns screwing up pattern matching
    &dump_line("$_", &TL_VERY_VERBOSE);
    chomp;

    # Print the text instances that matches the pattern, each on a separate line
    # NOTE: s qualifier treats string as single line & m multiline matching (in case -para specified); uses awkward special case logic to avoid issues with embedded newline matching (i.e., appraoch with //m as no-op not used for regular input)
    # TODO2: add option to control application (e.g., -multiline)
    ## OLD: while (($ignore_case && m/$pattern/is) || (m/$pattern/s)) ...
    my($count) = 0;
    while (($multi_line_match &&
	    (($ignore_case  && (m/$pattern/ims) || (m/$pattern/ms))))
	   || (($ignore_case && m/$pattern/is) || (m/$pattern/s))) {
	my($matching_text) = $&;
	&debug_print(&TL_VERY_DETAILED, "\n");
	&debug_out(&TL_VERY_DETAILED, "matching text: '%s'\n", $matching_text);
	for ($i = 1; $i <= $fields; $i++) {
	    &debug_out(&TL_VERY_DETAILED, "\$%d = '%s'; ", $i, eval "\${$i}");
	}
	&debug_print(&TL_VERY_DETAILED, "\n");

	# Update the current line being matched
	if ($restore ne "") {
	    ## OLD: my($restore_text) = eval { "$restore"; };
	    my($restore_text) = eval "$restore";
	    &debug_print(&TL_DETAILED, "restoring $restore_text to line\n");
	    $_ = $restore_text . $';		# '
	    &debug_print(&TL_VERBOSE, "line='$_'\n");
	}
	else {
	    $_ = $';				# '
	}

	# Transform matching text based on replacement pattern (e.g., '$1')
	## OLD:
	## my($qualifier) = ($ignore_case ? "i" : "");
	## eval "\$matching_text =~ s/\$pattern/$replacement/s$qualifier";
	## my($replacement_text) = eval { $replacement; };
	my($replacement_text);
	eval "\$replacement_text = \"$replacement\";";
	&debug_out(&TL_VERY_DETAILED, "replacement text: '%s'\n", $replacement_text);
	if ($ignore_case) {
	    if ($multi_line_match) {
		$matching_text =~ s/$pattern/$replacement_text/ims;
	    }
	    else {
		$matching_text =~ s/$pattern/$replacement_text/is;
	    }
	}
	else {
	    if ($multi_line_match) {
		$matching_text =~ s/$pattern/$replacement_text/ms;
	    }
	    else {
		$matching_text =~ s/$pattern/$replacement_text/s;
	    }
	}
	&debug_out(&TL_VERY_DETAILED, "resulting text: '%s'\n", $matching_text);
	print "$matching_text\n";
	$total_matched++;

	# See if limit for displayed matches reached
	&debug_print(&TL_VERY_DETAILED, "count=$count max_count=$max_count\n"); 
	$count++;
	last if ($count >= $max_count);
    }

    # Trace out lines not matched
    if ($count == 0) {
	my($line) = ($single_line_input ? $_ : "{ $_ }");
	&debug_print(&TL_VERY_VERBOSE, "line not matched: $line\n");
    }
}

# Report unmatched pattern in verbose mode
if ($verbose && ($total_matched == 0)) {
    print("no matches\n");
}

&exit();
