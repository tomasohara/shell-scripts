# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# rename_files.perl: script for renaming a list of files by doing a simple
# pattern replacement (old to new), assuming Unix (or that the DOS version 
# of the mv command is available).
#
# Notes:
# - With -regex, the patterns are actually  Perl regular expressions, so the
# full range of pattern matching is available, although not recommended due
# to potential for unexpected results.
# - With -ignore, case differences in filenames are ignored.
#
# TODO:
# - Add recursive option.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$q $f $regex $quick $force $test $evalre $global $i $ignore/;
use vars qw/$t $nt $para/;
use vars qw/$rename_old/;

&init_var(*q, &FALSE);		# alias for -q
&init_var(*quick, $q);		# quick spec: infer files from old pattern
&init_var(*f, &FALSE);		# force overwrite of the files
&init_var(*force, $f);		# alias for -f
&init_var(*i, &FALSE);		# alias for -ignore
&init_var(*ignore, $i);	        # ignore case
## TEST:
&init_var(*para, &FALSE);	# paragraph regex mode (for newlines in filename)
## OLD: &init_var(*regex, &FALSE);	# allow regular expression in pattern
&init_var(*regex, $para);	# allow regular expression in pattern
&init_var(*evalre, &FALSE);	# run replacement through eval environment
my($nt_default) = (defined($t) ? (! $t) : &TRUE);  # abbrev. for 'not t'
&init_var(*nt, $nt_default);    # alias for -test=0
&init_var(*t, (! $nt));         # alias for -test
&init_var(*test, $t);           # just test the rename operation
&init_var(*global, &FALSE);	# global replacement
&init_var(*rename_old, &FALSE); # rename old file as {old}.{MMDDDYY}

# Refuse to process buggy -rename_old
if ($rename_old) {
    &exit("Error: The -rename_old is not yet functional\n");
}

## TEST:
# TODO: put $para support in common.perl (likewise for slurp, as in count_it.perl)
$/ = "" if ($para);		# paragraph input mode

## TODO: our($mods) = "";
## $mods = "";
## $mods .= "g" if ($global);

# Extract pattern specifications from command line
if (!defined($ARGV[1])) {
    &usage();
    &exit();
}
my $old_pattern = shift @ARGV;
my $new_pattern = shift @ARGV;
my $test_spec = ($test ? "test " : "");

## OLD:
## $new_pattern = "" if (! defined($new_pattern));
## if ($new_pattern eq "/") {
##     $new_pattern = "";
## }

# TEMP: warn about options not yet working
if ($evalre) {
    &debug_print(&TL_ALWAYS, "Warning: -evalre not yet working right\n")
}

# Normalize the patterns
## TODO: rework -ignore processing
if ($ignore) {
    $old_pattern = &to_lower($old_pattern);
    $new_pattern = &to_lower($new_pattern);
}

# Support for quick spec: try all files that match the old pattern,
# provided that no files specified
if ($quick) {
    if (defined($ARGV[0])) {
	&warning("Ignoring -quick mode as files specified\n");
    }
    else {
	@ARGV = glob "*";
	for (my $i = 0; $i <= $#ARGV; $i++) {
	    $ARGV[$i] = &to_lower($ARGV[$i]) if ($ignore);
	    $ARGV[$i] = undef unless ($ARGV[$i] =~ /$old_pattern/);
	}
    }
}

# Apply the pattern to each file specified on command line,
# renaming old file to new name
&debug_print(&TL_DETAILED, "old_pattern=/$old_pattern/; new_pattern=/$new_pattern/; regex=$regex\n");
## TODO: my $quals = ""; $quals .= "g" if ($global); 
for (my $i = 0; $i <= $#ARGV; $i++) {
    next if (!defined($ARGV[$i]));
    my $old_file = $ARGV[$i];
    if (! -e "$old_file") {
	&debug_print(&TL_DETAILED, "Ignoring non-existent old file ($old_file).\n"); 
	next;
    }
    my $new_file = $old_file;

    # Apply patterns, making sure escaped unless regex desired.
    # TODO: resolve problem getting replacement parameters used
    # ex: rename-files -evalre -d=6 '\.(...)$' '.\\1-2' *.??? 2>&1 | less
    if ($evalre) {
	## ($global ? (eval { $new_file =~ s/$old_pattern/$new_pattern/g }) : (eval { $new_file =~ s/$old_pattern/$new_pattern/; })); &debug_print(&TL_VERBOSE, "\$1 = $1\n"); };
	## TODO: my $quals = ($global ? "g" : ""); eval { $new_file =~ s/$old_pattern/$new_pattern/$quals; &debug_print(&TL_VERBOSE, "\$1 = $1\n"); };
	## OLD:
	## eval { if ($global) { $new_file =~ s/$old_pattern/$new_pattern/ig; } else { $new_file =~  s/$old_pattern/$new_pattern/; };
	##        &debug_print(&TL_VERBOSE, "\$1 = $1\n"); 
	## };
	&debug_print(&TL_VERY_VERBOSE, "evalre replacement\n");
	## TODO: if ($global) { $new_file =~ s/$old_pattern/$new_pattern/ge; } else { $new_file =~  s/$old_pattern/$new_pattern/e; };
	while ( $new_file =~ m/$old_pattern/ ) {
	    ## TODO: resolve issue with replacement '-p-$1'
	    my($replacement) = eval "$new_pattern";
	    if (! defined($replacement)) {
		&debug_print(&TL_ERROR, "Error: bad replacement\n");
		last;
	    }
	    &debug_print(&TL_VERBOSE, "replacement: $replacement\n");
	    my($last_name) = $new_file;
	    $new_file =~ s/$old_pattern/$replacement/;
	    last if ((! $global) || ($new_file eq $last_name));
	}
     }
    elsif ($regex) {
	&debug_print(&TL_VERY_VERBOSE, "regex replacement\n");
	if ($global) { $new_file =~ s/$old_pattern/$new_pattern/g; } else { $new_file =~ s/$old_pattern/$new_pattern/; };
	## BAD: $new_file =~ s/$old_pattern/$new_pattern/;
	## BAD (not appropriate for loop): if (&VERBOSE_DEBUGGING) { &debug_print(-1, "\$1 = $1\n"); }
    }
    else {
	## ($global ne "" ? ($new_file =~ s/\Q$old_pattern/$new_pattern/g) : ($new_file =~ s/\Q$old_pattern/$new_pattern/));
	&debug_print(&TL_VERY_VERBOSE, "quoted-regex replacement\n");
	if ($global) { $new_file =~ s/\Q$old_pattern/$new_pattern/g; } else { $new_file =~ s/\Q$old_pattern/$new_pattern/; }
    }

    # If the file names are the same, do nothing
    if ($new_file eq $old_file) {
	&debug_print(&TL_DETAILED, "File names are the same for \"$old_file\"\n");
	next;
    }

    # Move target to target.{today}
    # note: get_file_ddmmmyy returns current year 2022 as 1971!
    if ((-e $new_file) && $rename_old) {
	my($old_file_dated) = $new_file . "." . &get_file_ddmmmyy($new_file);
	&debug_print(&TL_BASIC, "${test_spec}renaming existing target \"$new_file\" as \"$old_file_dated\"\n");
	if (! $test) {
	    rename $new_file, $old_file_dated;
	}
    }
    
    # If file with new name exists, don't overwrite unless force specified
    if ((-e $new_file) && ($force == &FALSE)) {
	print "\"$new_file\" already exists! not mv'ing \"$old_file\" \"$new_file\"\n";
    }

    # Otherwise, proceed with the rename
    else {
	# Make sure spaces and single quotes are properly escaped
	## &issue_command("mv '$old_file' '$new_file'", &TL_USUAL);
	## $old_file =~ s/([^\\]) /$1\\ /g;
	## $old_file =~ s/\'/\\\'/g;
	## $new_file =~ s/([^\\]) /$1\\ /g;
	## $old_file =~ s/\'/\\\'/g;

	# Execute the rename command
	## &cmd("mv $old_file' '$new_file'", &TL_USUAL);
	## OLD: my $test_spec = ($test ? "test " : "");
	&debug_print(&TL_BASIC, "${test_spec}renaming \"$old_file\" to \"$new_file\"\n");
	next if ($test);
	my($OK) = rename $old_file, $new_file;
	if (! $OK) {
	    &error("Problem during the rename of \"$old_file\" to \"$new_file\" ($!)\n");
	}
    }
}

&exit();

#------------------------------------------------------------------------

sub usage {
    my($options) = "main options = [-q | -quick] [-f | -force] [-i | -ignore] [-global] [-regex]";
    $options .= "\nother options = [-evalre] [-t | -test] [-para]";
    ## TODO: $options .= "\nother options = [-evalre] [-t | -test] [-para] [-rename_old]";
    $options .= "\ncommon options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name rename_files ' - Shortcut' '' *Shortcut*\n\n";
    $example .= "$0 rename-files -q -- '--' '-'\n\n";
    my($note) = "";
    $note .= "Notes:\n\n-- Use -- for first argument if dashes occur in old-pattern.\n-- By default only a single occurrence of the pattern is replaced.\n\n- The -ignore option is with respect to old vs. new comparison).\n";
    ## TODO: $note .= "- Use -rename_old to rename existing target file with date-based suffix (e.g., fubar to fubar.22mar22).\n";

    print STDERR "\nUsage: $script_name [options] old-pattern new-pattern [file] ...\\n\n$options\n\n$example\n$note";
}
