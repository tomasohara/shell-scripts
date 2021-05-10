# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# spell.perl: wrapper around the spell command that optionally sets the
# spell file if one exists. The output is sorting by default (with
# duplicates removed).
#
# TODO:
# - Add user dictionary support (e.g., based on MS Office).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name $TEMP/;
}

use strict;
use vars qw/$nosort $spell_file $latex $ispell $aspell $spell $gnu /;

if (!defined($ARGV[0])) {
    my($options) = "options = [-spell_file=file] [-latex]";
    my($example) = "ex: $script_name report.text\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}
my($file) = $ARGV[0];

&init_var_exp(*nosort, &FALSE);		# don't sort (-u) the output
&init_var_exp(*spell_file, "");		# user spelling file
my($user_spell_file) = ($spell_file ne "") ? $spell_file : &replace_extension($file, ".spell");
&init_var_exp(*latex, 			# latex mode
	  &boolean($file =~ /\.tex$/));
&init_var_exp(*gnu, &FALSE);		# use gnu spell instead of ispell
&init_var_exp(*aspell, &under_CYGWIN);	# use aspell (ispell replacement)
&init_var_exp(*ispell, ! $aspell);	# use ispell rather than spell
&init_var_exp(*spell, 			# spell program to use
	      ($ispell ? "ispell" : 
	       $aspell ? "aspell" : 	# TODO: add options '-l en list'
	       "spell"));

# If the input file is specified as '-', re-invoke over a temporary file based on STDIN
# TODO: write function for creating temporary file from standard input
if ($ARGV[0] eq "-") {
    # Write STDIN to a temp file
    my($temp_file) = "$TEMP/spell.$$";
    my(@input) = <>;
    &write_file($temp_file, join("\n", @input));

    # Recursively the script on the file and then exit
    &issue_command("$0 $temp_file");
    unlink $temp_file unless (&DEBUGGING);
    &exit();
}

# Setup up options for the system spell command
my($spell_command) = $spell;
my($spell_options) = "";
my($temp_spell_file) = "";
$spell_command = $spell;

# Set up the options for ispell
# -l:	just list the spelling errors
# -p file: user spelling file
# -t:	tex/latex input
$spell_options = "-l";
$spell_options .= " -t" if ($latex);
if (-e $user_spell_file) {
    # Make sure spell file doesn't contain comments
    # TODO: make this support optional
    $temp_spell_file = "$TEMP/temp-spell-file.list";
    &issue_command("grep -v '^#' '$user_spell_file' > '$temp_spell_file'");
    $user_spell_file = $temp_spell_file;

    # Specify the spell-file to use
    $spell_options .= " -p${user_spell_file}";
}
elsif ($spell_file ne "") {
    &warning("Spelling file '$spell_file' not found.\n");
}

# Run the actual spell-checking command
my($sort_command) = ($nosort ? "" : "| sort -u");
&issue_command("$spell_command $spell_options < $ARGV[0] $sort_command");

# Cleanup
if ((-e $temp_spell_file) && (! &DEBUGGING)) {
    unlink $temp_spell_file;
}

