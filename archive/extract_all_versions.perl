#!/usr/bin/perl -sw
#
# extract_all_versions.perl: extract all versions of a source file from CVS
# or RCS, saving the result as {prefix}{filename}.{revision} 
# (eg, reverse.perl.1 ... reverse.perl.5).
#
#
# sample RCS log (similar format for CVS):
#
#   $ rlog reverse.perl
#   
#   RCS file: RCS/reverse.perl,v
#   Working file: reverse.perl
#   head: 1.5
#   branch:
#   locks: strict
#   access list:
#   symbolic names:
#   keyword substitution: kv
#       total revisions: 5;     selected revisions: 5
#   description:
#   .
#   ----------------------------
#   revision 1.5
#   date: 2002/09/26 09:28:35;  author: tomohara;  state: Exp;  lines: +1 -1
#   .
#   ----------------------------
#   revision 1.4
#   date: 2002/08/23 05:21:47;  author: tomohara;  state: Exp;  lines: +1 -1
#   .
#   ----------------------------
#   revision 1.3
#   date: 2002/08/23 05:16:10;  author: tomohara;  state: Exp;  lines: +2 -0
#   .
#   ----------------------------
#   revision 1.2
#   date: 2002/06/27 17:08:22;  author: tomohara;  state: Exp;  lines: +3 -0
#   .
#   ----------------------------
#   revision 1.1
#   date: 1998/05/31 20:51:56;  author: tomohara;  state: Exp;
#   .
#   
# NOTES:
# - This makes it easier to find when certain changes were made to files,
#   such as when the check-in comments are missing or uninformative.
#

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN { 
    $dir = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP $script_name/;
}

use strict;
use vars qw /$prefix $cvs $revision/;

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-prefix=label] [-cvs] [-revision]";
    my($example) = "examples:\n\n$script_name reverse.perl\n\n";
    ## $example .= "$0 example2\n\n";			        # TODO: revise example 2
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";			# TODO: add optional note

    die "\nusage: $script_name [options] source_file\n\n$options\n\n$example\n$note\n";
}
&init_var(*prefix, "");			# prefix for the revision files
&init_var(*cvs, &FALSE);		# use CVS rather than RCS
&init_var(*revision, ".*");		# regex for revision

my($log_command) = ($cvs ? "cvs log" : "rlog");
my($extract_command) = ($cvs ? "cvs update" : "co");

my($file) = $ARGV[0];
my($basename) = &remove_dir($file);
my($temp_file) = &make_path($TEMP, "extract_all_versions.$$");

# Extract a list of the revision ID's
#
my($revision_log) = &run_command("$log_command '$file'");
my(@revision_IDs) = grep { /^revision \S+$/ } split(/\n/, $revision_log);

# Extract a copy of each revision
#
foreach my $ID (@revision_IDs) {
    $ID =~ s/revision //i;
    if ($ID !~ /$revision/) {
	&debug_print(&TL_DETAILED, "Skipping version $ID due to filter ($revision)\n");
	next;
    }
    my($revision_file) = &make_path($TEMP, "$prefix$basename.$ID");
    print "extracting revision $ID to $revision_file\n";
    &issue_command("$extract_command -p -r$ID '$file' > '$revision_file' 2>> $temp_file");
}

unlink $temp_file unless (&DEBUG_LEVEL > &TL_USUAL);

&exit();
