# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# convert-todo-to-outlook.perl: convert todo list from from todo file
# into a task comma-separate value (CSV) file for import into Outlook.
# The todo list file consists of lines of the following format:
#     <description><TAB><time-stamp>
# ex: "change Unix and Yahoo passwords	Mon Jul 15 11:37:58 MDT 2002"
#
#........................................................................
# Sample input:
#
#    To-do items
#
#    change Unix and Yahoo passwords 	Mon Jul 15 11:37:58 MDT 2002
#    utilize todo alias more often for non-project-oriented items 	Thu Sep 26 03:58:54 MDT 2002
#    add Emacs macros for HTML links 	Fri Sep 27 03:20:57 MDT 2002
#    ...
#    get linux CR/RW driver for toshiba	Sat Mar 22 12:59:55 MST 2003
#    look into PC control via (universal) remote	Sat Mar 22 13:00:21 MST 2003
#
# Alternative format:
#
#    Prior.	Time	Due	Description
#    1-5	hours			
#    ----------------------------------------------------------------------------------------------------
#    1	20	15 May	Integrate classifiers with differentia extraction
#    ....................................................................................................
#    2	20	1 Jun	Normalize the relationships extracted from link grammar
#    2	20	1 Jun	Revise differentia extraction chapter
#
# Relative due date format:
#
#    [within N days/weeks/months] description
#
# Absolute due date formats:
#
#    [by DD MMM YYYY] description
#    [by MM/DD/YYYY] description
#
# Sample output:
#
#    "Subject", "Due Date", "Reminder On/Off", "Reminder Date", "Reminder Time", "Priority", "Status", "Categories"
#    "change Unix and Yahoo passwords", "10/15/2002", "True", "10/08/2002", "12:00:00 PM", "Normal", "Not Started", "Longterm"
#    "utilize todo alias more often for non-project-oriented items", "12/26/2002", "True", "12/19/2002", "12:00:00 PM", "Normal", "Not Started", "Longterm"
#    "add Emacs macros for HTML links", "12/27/2002", "True", "12/20/2002", "12:00:00 PM", "Normal", "Not Started", "Longterm"
#    ...
#    "get linux CR/RW driver for toshiba", "06/22/2003", "True", "06/15/2003", "12:00:00 PM", "Normal", "Not Started", "Longterm"
#    "look into PC control via (universal) remote", "06/22/2003", "True", "06/15/2003", "12:00:00 PM", "Normal", "Not Started", "Longterm"
#    
#........................................................................
# TODO:
# - Sort input by entry date prior to removing duplicates so that later ones
#   have priority.
# - Add support for specifying low priority items.
# - Add options for extracting 'TODO:' notes from text files
#      Tue 21 Jan 03
#      
#      TODO: fix make-arahomot-backup.sh
#      
#      cartera-de-tomas $ /f/tom/make-arahomot-backup.sh --full
#      issuing: tar cvfz /f/temp/arahomot-012103.tar.gz /f/cartera-de-tomas ...
#      ...
# - Similarly add support for mail-todo items
#      Date: Sat, 22 Mar 2003 16:12:01 -0700
#      From: Tom O'Hara <tomohara@cs.nmsu.edu>
#      To: tomohara@cs.nmsu.edu
#      Subject: TODO: move ~/Multilingual files to ~/cartera-de-tomas
#      
#      TODO: move ~/Multilingual files to ~/cartera-de-tomas
# - Sort the result by due date.
# - Check for duplicate items (based on degree of overlap of words or phrases).
# - Retain double quotes (rather than converting to single quotes).
# - Add interactive duplicate filtering.
# - Check timestamps when detecting duplicates (e.g., more likely if few second difference).
# - Only load Text::Levenshtein when duplicate check active.
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    $dir = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP $script_name/;
    require 'extra.perl';
}
# Load in Levenstein edit distance module 
# Note: done separately in case in different directory than script
BEGIN { 
    use Text::Levenshtein qw(distance);
}

use strict;
use vars qw /$para $category $due_days $remind_days $tabular $date $add_datespec $prune $prune_duplicates $threshold $char_threshold $word_threshold/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-due_days=N] [-remind_days=N] [-tabular] [-para] [-category=label] \n";
    $options .=    "               [-add_datespec | -date] [-prune_duplicates]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "EXAMPLES:\n\n$0 todo_list.text\n\n";
    $example .= "cd ~/organizer\n";
    $example .= "date=`date '+%m%d%y'`\n";
    $example .= "move todo_list.text ./port-todo-\$date.text\n";
    $example .= "tac port-todo-\$date.text | $script_name -prune -threshold=90 -date -category='Medium-term;Todo-File' - > ./old-todo-\$date.csv\n";
    $example .= "cygstart excel `cygpath.exe -wa ./old-todo-\$date.csv`\n";
    # TODO: figure out Outlook command line invocation for import (e.g., via macro invocation).
    $example .= "# Optional, export existing Outlook tasks\n"; 
    $example .= "# Do the actual import via Outlook\n";
    my($note) = "";
    $note .= "NOTES:\n\n- To sort by due date in Excel, make sure formatted as date. Also, it seems that you need\n";
    $note .= "to select the entire region but specify header row (with symbolic names appearing).\n\n";
    $note .= "- Double quotes are replaced with single quotes.\n\n";
    $note .= "- With -prune_duplicates, input should be in descending order (hence the 'tac' command above (i.e., reverse 'cat').\n\n";

    die "\nUSAGE: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*para, &FALSE);		# paragraph input mode
&init_var(*category, "");		# Category for the task
&init_var(*due_days, 90);		# days from entry date that task is due
&init_var(*remind_days, 7);		# days before due date for reminder
my($DAY_SECONDS) = (24 * 60 * 60);	# number of seconds in a day (86400)
&init_var(*tabular, &FALSE);		# use alternative tabular input format
&init_var(*date, &FALSE);		# alias for -add_datespec
&init_var(*add_datespec, $date);	# add info on due date and entry date from todo item
&init_var(*prune, &FALSE);   		# alias for -prune_duplicates
&init_var(*prune_duplicates, $prune);   # don't include duplicate task descriptions
&init_var(*threshold, 90);		# alias for -prune_threshold
&init_var(*word_threshold, $threshold); # percent word overlap required for pruning
$word_threshold /= 100;
&init_var(*char_threshold, $threshold); # percent character overlap required for pruning
$char_threshold /= 100;
## &init_var(*hours, $tabular);		# include 'Total Work' field to record estimated hours
my($default_due_days) = $due_days;
my($default_remind_days) = $remind_days;
my($current_year) = &current_year();
my(%processed);			# hash for descriptions already processed

# Output field description line
# NOTE: CR/LF used since Outlook doesn't recognized Unix ascii files
# TODO: infer 'Total Work' occurrence from header in tabular format
print '"Subject", "Due Date", "Reminder On/Off", "Reminder Date", "Reminder Time", "Priority", "Status", "Categories"';
print ', "Total Work"' if ($tabular);
print "\r\n";

# Set optional paragraph input mode
if ($para) {
    $/ = "";
}
my $last_description = "";
while (<>) {
    &dump_line();
    chomp;
    my($original_line) = $_;
    my($description) = "";
    my($priority) = "Normal";
    my($entry_date) = &current_timestamp();
    my($entry_date_spec) = "";
    my($due_date) = -1;
    my($minutes) = 0;
    my($due_date_spec) = "";

    # Check for next todo item

    # Check alternative tabular format: <priority><TAB><hours><TAB><due-date><TAB><description>
    # TODO: check the header to see which fields are present
    if ($tabular && /^(\d+)\t(\d+)\t([^\t]+)\t(.*)/) {
	$priority = (($1 < 3) ? "High" : ($1 < 5) ? "Normal" : "Low");
	$minutes = $2 * 60;
	$due_date_spec = $3;
	$description = $4;

	# Convert the ascii date into an internal date struct
	$due_date_spec .= " $current_year" if ($due_date_spec !~ /\d+\s*$/);
	$due_date = &derive_time_stamp($due_date_spec);
    }
		      
    # ex: record Bob's Moms House\s number: (717) 306-4223 				Fri Jan 3 20:41:39 2003
    # ex: establish preview for TIFF files under Windows Picture and Fax Viewer 	Fri Jan 3 15:46:03 2003
    # ex: fix emacs setup under other ILIT-TPO accounts					Sat 02 Oct 04 8:16 PM
    elsif (/^([^\t]+)\t(\S+\s+\S+\s+\d\d?\s+\d\d:\d\d:\d\d\s+\S+\s+\d\d\d\d)/
	   || /^([^\t]+)\t(\S+\s+\S+\s+\d\d?\s+\d\d:\d\d:\d\d\s+\d\d\d\d)/
	   || /^([^\t]+)\t(\S+\s+\d+\s+\S+\s+\d+\s+\d\d:\d\d\s+(am|pm))/si) {
	($description, $entry_date_spec) = ($1, $2);

	# Derive due date for the task as well as reminder
	# - due date is 3 months from entry date
        # - reminder date is 1 week prior to due date
	# TODO: do due date computation based on month values
	$entry_date = &derive_time_stamp($entry_date_spec);
    }

    # Ignore other date fileds
    # TODO: support European-type date spec (e.g., Sat 02 Oct 04 8:16 PM)
    elsif (/^([^\t]+)\t(.*)/) {
	$description = $1;
	my($ignored) = $2;

	&warning("Ignoring unknown date specification '$ignored' for '$description'\n");
    }
    
    # Check for relative due-date specification in description
    # ex: "[within 1 weeks] revise instructions on lisp lexicon import"
    if ($description =~ /^\s*\[(\s*within\s*([0-9Nn]+)\s*(day|week|month|year)s?)\]\s*/si) {
	$description = $';	# '
	$due_date_spec = $1;
	my($unit) = &to_lower($2);
	my($period) = &to_lower($3);

	# Determine how many days are in the given unit.
	# Also, use default in case of cut-n-paste error (e.g., 'add-todo "[within N weeks] ..."' template)
	my($period_days) = &get_period_days($period);
	if ($unit eq "n") {
	    $unit = &get_default_increment($period);
	}

	# Derive due date by advancing specified number of time periods (in days)
	&debug_out(&TL_VERBOSE, "to-do within %d days\n", $unit * $period_days);
	$due_date = ($entry_date + ($unit * $period_days * $DAY_SECONDS));
    }
    elsif ($description =~ /^\s*\[\s*within/si) {
	&warning("Problem parsing relative due-date description: '$description\n'");
    }

    # Check for absolute due-date specification (via [by DD MMM YYYY] or [by MM/DD/YYYY])
    # EX: [by 10 mar 04] check about seminars at Hopkins 
    # NOTE: this also allows for time-of-day specifications (see derive_time_stamp in extra.perl)
    if ($description =~ /^\s*\[(\s*by\s+([^\]]+)\s*)\]\s*/si) {
	$description = $';	# '
	$due_date_spec = $1;
	my($date_spec) = $2;

	# Convert from textual date into timestamp
	$due_date = &derive_time_stamp($date_spec);
    }
    elsif ($description =~ /^\s*\[\s*by/si) {
	&warning("Problem parsing absolute due-date description: '$description\n'");
    }

    # Derive a default due date unless specified
    &debug_out(&TL_VERBOSE, "due_date: %d\n", $due_date);
    if ($due_date <= 0) {
	&warning("Supplying default Due Date $default_due_days days from entry: '$description'\n");
	$due_date = ($entry_date + ($default_due_days * $DAY_SECONDS));
    }

    # Make sure the description isn't a duplicate unless same as last (e.g., in case date spec changed).
    # NOTE: Although Outlook has an ability to ignore duplicates, the due-date option preempts that.
    $description = &trim($description);
    ## OLD test: ($prune_duplicates && get_entry(\%processed, $description) && ($description ne $last_description))
    if ($prune_duplicates 
	&& (get_entry(\%processed, $description) 
	    || &overlapping_description($description, $last_description))) {
	&warning("Ignoring duplicate entry of '$description' from '$original_line'\n");
	next;
    }
    &set_entry(\%processed, $description, &TRUE);
    $last_description = $description;

    # Check for priority indicators (e.g., ending exclamation point)
    # EX: "[within 4 weeks] reconcille tpo-test.lisp!
    if ($description =~ /!$/) {
	$priority = "High";
    }

    # Add the entry to the CSV output if fields extracted OK
    # ex: "check back with Julio about latino clubs", "05/11/2005", "True", "05/18/2005", "12:00:00 PM", "Normal", "Not Started", "Medium-term"
    # TODO: have option to include the entry date (e.g., via description if not supported in Outlook)
    if ($description ne "") {
	my($remind_date) = ($due_date - ($default_remind_days * $DAY_SECONDS));
	## my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($due_date)
	my(@due_date_fields) = localtime($due_date);
	my($due_date_value) = sprintf "%02d/%02d/%04d", (1 + $due_date_fields[4]), $due_date_fields[3], (1900 + $due_date_fields[5]);
	my(@remind_date_fields) = localtime($remind_date);
	my($remind_date_value) = sprintf "%02d/%02d/%04d", (1 + $remind_date_fields[4]), $remind_date_fields[3], (1900 + $remind_date_fields[5]);
	&debug_print(&TL_VERY_VERBOSE, "entry_date=$entry_date due_date=$due_date remind_date=$remind_date\n");
	&debug_print(&TL_VERY_VERBOSE, "date_fields=(sec, min, hour, mday, mon, year, wday, yday, isdst)\n");
	&debug_print(&TL_VERY_DETAILED, "remind_date_fields=(@remind_date_fields)\n");
	&debug_print(&TL_VERY_DETAILED, "due_date_fields=(@due_date_fields)\n");

	# Optionally, add date specification to the end of the description
	$due_date_spec = &trim($due_date_spec);
	$entry_date_spec = &trim($entry_date_spec);
	if ($add_datespec && (($due_date_spec ne "") || ($entry_date_spec ne ""))) {
	    $description .= " [";
	    $description .= "$due_date_spec" if ($due_date_spec ne "");
	    if ($entry_date_spec ne "") {
		$description .= " " if ($due_date_spec ne "");
		$description .= "from $entry_date_spec";
	    }
	    $description .= "]";
	}

	# Convert double quotes to single quotes
	# TODO: issue warning about doing this
	$description =~ s/\"/\'/g;

	# Print the Outlook task item in CSV format
	# NOTE: CR/LF used since Outlook doesn't recognized Unix ascii files
	# TODO: allow for time-of-day specification
	#     Subject	         Due Date	Reminder On/Off	  Reminder Date	           Reminder Time     Priority	   Status	     Categories
        print "\"$description\", \"${due_date_value}\", \"True\", \"${remind_date_value}\", \"12:00:00 PM\", \"$priority\", \"Not Started\", \"$category\"";
	print ", \"$minutes\"" if ($tabular);
	print "\r\n";

    }
    else {
	&warning("ignoring line '$_'\n");
    }
}

&exit();

#------------------------------------------------------------------------

# get_default_increment(time_unit): get default to-do time increment for TIME_UNIT (day/week/month/year)
# EX: get_default_increment("month") => 6
# NOTE: Currently based on half of the number of given units in that of next higher increment 
#       (e.g., 2 for 'week' since 4 weeks in a month).
#
my(%default_todo_increments);
#
sub get_default_increment {
    my($time_unit) = @_;
    if (! (scalar %default_todo_increments)) {
	%default_todo_increments = (
	   "day" => 5,
	   "week" => 2,
	   "month" => 6,
	   "year" => 1,
	   "" => -1
	   );
    }

    my($increment) = &get_entry(\%default_todo_increments, &to_lower($time_unit), -1);
    if (!defined($increment)) {
	&error("Unexpected time unit: $time_unit");
	$increment = 1;
	}
    &assert($increment > 0);
    &debug_print(&TL_VERY_VERBOSE, "get_default_increment(@_) => $increment\n");

    return ($increment);
}

# get_period_days(time_unit): get number of days in specified time period
# EX: get_period_days("month") => 30
# TODO: use generic get_xyx_function using assoc. array.
#
my(%day_increments);
#
sub get_period_days {
    my($time_unit) = @_;
    if (! (scalar %day_increments)) {
	%day_increments = (
	    "day" => 1,
	    "week" => 7,
	    "month" => 30,
	    "year" => 365,
	    "" => -1
	    );
    }
    my($increment) = &get_entry(\%day_increments, &to_lower($time_unit), -1);
    if (!defined($increment)) {
	&error("Unexpected time unit: $time_unit");
	$increment = 1;
	}
    &assert($increment > 0);
    &debug_print(&TL_VERY_VERBOSE, "get_period_days(@_) => $increment\n");

    return ($increment);
}

# overlapping_description(description1, description2): whether the two descriptions are similar except for minort differences (e.g., typo correction). This incorporates both edit distance and word overlap heuristics.
# NOTE: This is far from foolproof, so relatively high thresholds should be used (e.g., char overlap > 50 and word overlap > 70).
#
sub overlapping_description {
    my($desc1, $desc2) = @_;
    my $does_overlap = &FALSE;
    &debug_print(&TL_DETAILED, "overlapping_description(@_)\n");

    my $edit_distance = &distance($desc1, $desc2);
    &debug_print(&TL_DETAILED, "edit distance: $edit_distance\n");
    my $max_desc_len = &max((length $desc1), (length $desc2));
    if ($max_desc_len == 0) {
	$does_overlap = &TRUE;
    }
    else {
	my $character_overlap = (1 - ($edit_distance / $max_desc_len));
	&debug_print(&TL_DETAILED, "char overlap: $character_overlap\n");
	if ($character_overlap >= $char_threshold) {
	    # NOTE: words are alphanumeric tokens
	    my @desc1 = &tokenize($desc1, "[^A-Za-z0-9]");
	    my @desc2 = &tokenize($desc2, "[^A-Za-z0-9]");
	    my @overlap = &intersection(\@desc1, \@desc2);
	    my $overlap_degree = (((scalar @overlap) > 0) ? (scalar @overlap / &max(scalar @desc1, scalar @desc2)) : 0);
	    &debug_print(&TL_DETAILED, "word overlap: $overlap_degree\n");
	    $does_overlap = &boolean($overlap_degree >= $word_threshold);
	}
    }
    &debug_print(&TL_DETAILED, "overlapping_description() => $does_overlap\n");

    return ($does_overlap);
}
