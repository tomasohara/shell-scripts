# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -- # -*- Perl -*- Force Emacs perl-mode
'di';
'ig00';

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

sub usage {
    select(STDERR);
    print <<USAGE_END;
Usage: $0 [-CESUX] [-r] [-p prefix string] [-s suffix string] [-t template]
       [-wf word_file] [-w word_pattern] ...
       [field pattern1] [field pattern2] ...

-C                Search in Collins Spanish-English dictionary.
-E                Assume all word patterns are regular expressions.
-S                Search using the headword and sense ID.
-U                Assume all word patterns are substrings.
-X                Assume all word patterns should match exactly.
-i                Search in a case-insensitive way
-p  prefix string String to print before the template output.
-r                Print the whole word record instead of the headword.
-s  suffix string String to print after the template output.
-t  template      String to use as an output template.
-w  word_pattern  The word pattern to search with.
-wf word_file     The file containing the word patterns to search with.
[field pattern]   A field pattern to match in the word record.

-si     Skip entries that are for idioms

USAGE_END

    exit 1;
}

#
# Unbuffer stdout.
#
select((select(STDOUT), $| = 1)[0]);

#
# If no command line arguments are given, give a usage message.
#
($#ARGV >= 0) || &usage;

#
# Some pre-defined variables to allow embedding single and double quotes
# in templates.
#
$sq = "'";
$dq = "\"";

#
# Set the locations of the appropriate index and dict files and
# make the default the LDOCE files.
#
$ldoce_index = '/home/lexbase/scratch/LexBase/lexbase.index';
$ldoce_dict = '/home/lexbase/scratch/LexBase/lexbase.lex';
$collins_index = '/home/lexbase/COLLINS/SCRATCH/lex.index';
$collins_dict = '/home/lexbase/COLLINS/SCRATCH/lex.data';

$using_ldoce = 1;
$dbich = '\#';
$dbi = $ldoce_index;
$dbf = $ldoce_dict;

# Flag for skipping over definitions for entries that are idioms
$skip_idioms = 0;

#
# Set the location of the search engine.
#
$lbgrep = $ENV{'LBGREP'} ||
    '/home/mleisher/look-tools/lexbase.new/lbgrep-2.0/lbgrep';

#
# Rearrange ARGV to force the case insensitive and regex flags
# to be first.  This is required by lbgrep so it can build its
# search patterns correctly.
#
while ($argv = shift(@ARGV)) {
    if ($argv =~ /^-[iE]/) {
        unshift(@NARGV, $argv);
    } else {
        push(@NARGV, $argv);
    }
}

while ($_ = shift(@NARGV)) {
    if (/^-C$/) {
        $lbgrep_opts .= "--separator-char '|' ";
        $using_ldoce = 0;
        $dbich = '\|';
        $dbi = $collins_index;
        $dbf = $collins_dict;
        next;
    }
    if (/^-E$/) {
        $lbgrep_opts .= "--match-type regex ";
        next;
    }
    if (/^-S$/) {
        $lbgrep_opts .= "--include-senseid ";
        next;
    }
    if (/^-U$/) {
        $lbgrep_opts .= "--match-type substring ";
        next;
    }
    if (/^-X$/) {
        $lbgrep_opts .= "--match-type exact ";
        next;
    }
    if (/^-i$/) {
        $lbgrep_opts .= "--case-insensitive ";
        $case_fold = 1;
        next;
    }
    if (/^-wf$/) {
        $lbgrep_opts .= "--pattern-file " . shift(@NARGV) . " ";
        $got_pattern_file = 1;
        next;
    }
    if (/^-w$/) {
        $lbgrep_opts .= "--pattern '" . shift(@NARGV) . "' ";
        $got_pattern = 1;
        next;
    }
    if (/^-p$/) {
        $prefstr = "\"" . shift(@NARGV) . "\"";
        next;
    }
    if (/^-s$/) {
        $suffstr = "\"" . shift(@NARGV) . "\"";
        next;
    }
    if (/^-t$/) {
        #
        # Set the template for the output.
        #
        $template = "\"" . shift(@NARGV) . "\"" ||
            die "$0: missing template specification\n";
        next;
    }
    if (/^-r$/) {
        #
        # Set the flag indicating that the whole record is requested
        # and not just the headword.
        #
        $printrecord = 1;
        next;
    }
    if (/^-si$/) {
	# Set flag to skip over definitions for entries that are idioms
	$skip_idioms = 1;
	next;
    }
    if (/^-(.+)$/) {
        warn "$0: unknown option: $_\n";
        &usage;
    }
    #
    # Collect all of the field patterns into one array.
    #
    if (substr($_, 0, 1) eq "!") {
        push(@fpats, "!^\\\$" . substr($_, 1));
    } else {
        push(@fpats, "^\\\$" . $_);
    }
}

#
# Make sure the record print flag is off if a template
# specification was supplied.
#
$printrecord = 0 if (defined($template));

#
# Now set the index file for lbgrep.
#
$lbgrep_opts .= "-I $dbi";

if (!$got_pattern && !$got_pattern_file) {
    #
    # No words were supplied, so assume they want to search the
    # whole database.
    #
    if ($using_ldoce) {
        warn "$0: no words supplied - searching all of LDOCE.\n";
    } else {
        warn "$0: no words supplied - searching all of Collins S-E dict.\n";
    }
    open(SEARCH, "$dbi") || die "$0: can't open file $dbi\n";
} else {
    #
    # We have either one or more patterns or pattern files.
    # Start lbgrep.
    #
    &debug_out(4, "issuing: $lbgrep $lbgrep_opts |\n");
    open(SEARCH, "$lbgrep $lbgrep_opts |") ||
        die "$0: can't start the search engine.\n";
}

#
# Set perl up so that ^ and $ will match within strings
#
$* = 1;

#
# At this point, if we don't have any field patterns to search for,
# the $printrecord variable is 0, and no template has been specified,
# the search is either for all headwords or for all headwords that
# match a certain pattern.  If no field patterns were supplied, simply
# run through each returned item, split off the headword and print it.
#
if (!defined(@fpats) && $printrecord == 0 && !defined($template)) {
    while (<SEARCH>) {
        print;
    }
    close(SEARCH);
    exit 0;
}

#
# Open up the LexBase database for retrieving the records.
#
open(LB, "$dbf") || die "$0: can't open file $dbf";

#
# If we are using a template, we want to emit the prefix string before
# starting the search.
#
#if (defined($template) && defined($prefstr)) { print eval $prefstr; }

#
# This will iterate over each match that lbgrep finds for the
# word pattern in the index file, break it up into:
# A. The 'sense id'
# B. The start and end locations of the record in the main LexBase file
# After the start and end locations are found, it reads the whole record
# at once, and then loops through matching each field expression against
# the whole record.
#
while (<SEARCH>) {
    # Get the 'sense id' and the starting byte offset.
    ($word, $start) = split(/$dbich/);

    # Get the ending byte offset.
    ($start, $end) = split(' ', $start);

    # Figure out how many bytes the record will be.
    $rsize = $end - $start;

    # Make sure the size is valid
    if ($rsize <= 0) {
	&debug_out(3, "Invalid record length: $dbich\n");
	next;
    }

    # Move to the beginning of the record in the LexBase file.
    seek(LB, $start, 0);

    # Read the whole record and remove the last newline from it.
    sysread(LB, $record, $rsize);
    chop $record;

    #
    # Set a flag that will tell us if all of the fields match or not.
    # If only a word pattern was provided on the command line, this
    # iteration will simply be skipped, otherwise, each field pattern
    # will be applied to the record to see if a match occured.
    # The first field pattern that DOESN'T match will cause this
    # iteration to terminate with $got_one set to 0, indicating this
    # record doesn't match.
    #
    $got_one = 1;
    foreach (@fpats) {
        if (substr($_, 0, 1) eq "!") {
            $fp = substr($_, 1);
            if ($case_fold) {
                $got_one = (($record !~ /$fp/i) ? 1 : 0);
            } else {
                $got_one = (($record !~ /$fp/) ? 1 : 0);
            }
        } else {
            $fp = $_;
            if ($case_fold) {
                $got_one = (($record =~ /$fp/i) ? 1 : 0);
            } else {
                $got_one = (($record =~ /$fp/) ? 1 : 0);
            }
        }
        last if $got_one == 0;
    }
    if ($got_one == 1) {
        if ($printrecord == 1) {
            print "$record\n";
        } elsif (defined($template)) {
            ($hw, $A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L,
             $M, $N, $O, $P, $Q, $R, $S, $T, $U, $V) = split(/\n\$[A-V] /,
                                                             $record);

	    # Don't include the entry if only the main entries are desired,
	    # not those that are for idioms that use the headword.
	    if ($skip_idioms && ($K ne "")) {
		next;
	    }

            ($wh, $junk) = split(/_/, $hw);
            if (defined($template) && defined($prefstr) && $prefprinted == 0) {
                print eval $prefstr;
                $prefprinted = 1;
            }

            print eval $template ,"\n";
        } else { print "$word\n"; }
    }
}

#
# If we are using a template, we want to emit the suffix string after
# the search terminates.
#
if (defined($template) && defined($suffstr)) { print eval $suffstr; }

close SEARCH;
close LB;

exit 0;

######################################################

.00;

'di
.nr nl 0-1
.nr % 0
'; __END__ # Manual page starts here
.TH LBFORMAT 1 "April 19, 1994"
.AT 3
.SH NAME
lbformat \- lookup patterns in LDOCE or Collins Spanish/English dictionary
with template based output formatting
.SH SYNOPSIS
.B lbformat
[-CESUX] [-r] [-p prefix string] [-s suffix string] [-t template]
[-wf word_file] [-w word_pattern] ...
.br
[field pattern1] [field pattern2] ...
.SH DESCRIPTION
\fBlbformat\fP takes zero or more word patterns (specified by the
\fI-w\fP option), or a filename of a file containing a list of word
patterns to search for, along with zero or more field patterns, looks
them up in either LDOCE or Collins Spanish/English dictionaries (in
LexBase format) and prints them to standard output.  The form the
output takes depends on what command line parameters have been
specified.
.TP 4
.BI \-C
This option indicates that the search should be done in the Collins
Spanish/English dictionary instead of LDOCE which is the default.
.TP 4
.BI \-E
This option indicates that all word patterns found on the command line
or in a file are to be viewed as regular expressions (see REGULAR
EXPRESSIONS).
.TP 4
.BI \-S
This option indicates that the search should be done using both the
headword and the sense ID.  By default, only the headword is used
during the search.
.TP 4
.BI \-U
This option indicates that all of the word patterns are to be
considered substrings (as opposed to regular expressions or exact
matches) of the headword.
.TP 4
.BI \-X
This option indicates that and exact match should be done with the
headword.  If the \fB\-S\fP option was present, then an exact match
will be done with the headword and sense ID.
.TP 4
.BI \-i
This option indicates that a case-insensitive search should be done.
Case-insensitive searching is done correctly with Latin1 text.  By
default, \fIlbformat\fP searches in a case-sensitive manner.
.TP 4
.BI \-p " prefix string"
This option specifies the string that will be printed before the
template output is printed (ignored if \fI-t\fP was not specified).
.TP 4
.BI \-r
This option specifies that the complete LexBase record for each entry
found should be printed.
.TP 4
.BI \-s " suffix string"
This option specifies the string that will be printed after the
template output is printed (ignored if \fI-t\fP was not specified).
.TP 4
.BI \-t " template"
This option allows a template string to be specified which will format
the output according to the fields listed in the string (see TEMPLATES
section).  This option overrides the \fI-r\fP option.
.TP 4
.BI \-w " word pattern"
This option specifies a word pattern to search for in the LexBase
dictionary index.  If the \fI-E\fP option was specified, the word
pattern is assumed to be a regular expression (see REGULAR
EXPRESSIONS).
.TP 4
.BI \-wf " word_file"
This option specifies a file containing word patterns to be searched
for in the LexBase dictionary index.  Each word pattern should be on a
separate line.  If the \fI-E\fP option was specified on the command
line, all of the word patterns are assumed to be regular expressions
(see REGULAR EXPRESSIONS).
.TP 4
.I "field pattern"
Field patterns are regular expressions that specify which fields
should be matched using what regular expression.  The format of a
field expression is: '<field letter><space><pattern>'.
.sp
Example: 'C (v.*|.*adv)'
.br
would look for a 'v' or an 'adv' in the \fI$C\fP field of the LexBase
record.  The regular expression used can be any legal \fBperl\fP
regular expression (see the \fBperl\fP documentation for a discussion
of these).
.sp
If an exclamation point ('!') appears as the FIRST character in the
field pattern, then a logical not is applied when matching
against that field.  Note: if an exclamation point is used, two
backslashes ('\\') will be needed in front of it so the shell
doesn't misinterpret it.
.sp
Example: '\\!K $'
.br
would look for all records whose \fI$K\fP fields are not empty.
.sp
An arbitrary number of field pattern specifications can be specified.
.sp
The field patterns are applied with an implied logical AND between them.
.SH TEMPLATES
The LexBase database files are currently arranged with each record
consisting of the headword followed by up to 22 information fields.
Each field is on a separate line and is prefixed with $[A-V] (meaning
the dollar sign followed by a letter between 'A' and 'V', inclusive).
Each record is separated by a blank line.
.sp
\fBLbformat\fP template strings use these field specifiers to describe
which field contents should be used.  Here is an example of a template
that would print a matched entry as one item in a Lisp association
list:
.sp
.IP
\'($sq$hw $sq($P $C $dq$I$dq))'
.sp
.LP
What this template specifies is the following:
.br
<open parenthesis> <single quote> <headword> <space> <single quote>
<open parenthesis> <field P contents> <space> <field C contents>
<space> <double quotes> <field I contents> <double quote> <close
parenthesis> <close parenthesis>
.sp
You might have noticed that this template uses the \fI$hw\fP variable.
\fI$hw\fP is a special variable that means the headword.  The
\fI$hw\fP variable contains the whole headword, including the sense ID
as well.  If you want the headword without the sense ID, use \fI$wh\fP
instead of \fI$hw\fP.
.sp
This also demonstrates how to include single and double quotes in the
template string.  The shell has a habit of interpreting single and
double quotes in its own fashion, so two special variables were set up
to deal with this: \fI$sq\fP (single quote) and \fI$dq\fP (double
quote).  When the template string is evaluated, these will be
converted to their respective characters.
.sp
Two other command line specifiers can be used to construct complete
entities for specific purposes.  For instance, if we had specified the
following on the command line, \fBlbformat\fP would generate a
complete Lisp association list:
.sp
.IP
-p '$sq(' -s ')' -t '($sq$hw $sq($P $C $dq$I$dq))'
.sp
.LP
Similar constructs can be generated for other languages like Prolog
simply by specifying an appropriate template string.
.SH EXAMPLES
\f(CW% lbformat -E -w '^activate_' -w '^bank_[^_]+_[0-2]' \\
.br
-t '($sq$hw $sq($P $C $dq$I$dq))' 'C v.*' -p '$sq(' -s ')'\fP
.sp
This command line will look up the verb forms of all entries of
'activate' and all entries of 'bank' whose senses are between 0 and 2.
The output will be a Lisp association list with the headword as the
lookup key.
.sp
\f(CW% lbformat 'C (.*adv|adv.*)'\fP
.sp
This command will look up all entries that have the string 'adv' in
their \fI$C\fP field.
.SH "REGULAR EXPRESSIONS"
Normally, \fBlbformat\fP assumes that word patterns specified on the
command line or in a file are to be used to basically do a substring
or an exact match on entries in the LexBase dictionary index file.
However, if the \fI-E\fP option is specified, any word patterns on the
command line or in a file are assumed to be regular expressions.
.sp
The GNU regex package is used to handle these kinds of regular
expressions and by default, \fBlbformat\fP assumes the regular
expressions are in \fBegrep\fP format with the added capability of
interval operators ({} operators).
.SH ENVIRONMENT
LBGREP \- this should be set to the location of the \fBlbgrep\fP
program which is the search engine written in C.
.SH FILES
None.
.SH AUTHOR
mleisher@crl.nmsu.edu (Mark Leisher)
.SH "SEE ALSO"
perl(1)
.SH DIAGNOSTICS
.B lbformat
will exit with an error message under four conditions:
.br
.IP "1."
If no command line parameters are given
.IP "2."
If the search process for the LexBase index cannot be started.
.IP "3."
If the LexBase database file cannot be opened.
.IP "4."
If a template specifier is missing.
.SH BUGS
Probably
