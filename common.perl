# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# common.perl: Commonly used perl routines (variables & constants)
#
# global variables:
#     $script_dir        directory where the main script resides
#     $script_name       file name for main script without directory path
#     $debug_level       debugging trace level (higher is more verbose)
#     $disable_commands  disables the execution of external commands
#     $TRUE, $FALSE      boolean constants (old version)
#     &TRUE, &FALSE      boolean constants (preferred due to Perl warnings)
#     $MAXINT            constant for largest integer in a word
#
# Developed 1997-1999
# Tom O'Hara
# New Mexico State University
#
# Revised 1999-2001
# Tom O'Hara
# Cycorp Inc.
#
# Revised 2002-2003
# Tom O'Hara
# New Mexico State University
#
# TODO:
# - * Add gotcha's for modification (e.g., consider Python port instead)!
# - Make changes to take advantage of Perl 6???.
# - Have common.pm be a wrapper around this.
# - Add additional common arguments like -verbose (e.g., -para).
# - Change the assumed baseline Perl version from Perl 4.031 to Perl 5.
# - Make sure that global variables such as path_delim don't conflict with
#   user variables.
# - Use debug_print unless formatted I/O needed.
# - Use my instead of local unless old-style references assumed.
# - Revise the function synopsis.
# - Put extraneous stuff in extra.perl.
# - Track down other scripts that are redundantly initializing $TEMP, etc.
# - Specify 'use strict' and 'use diagnostics'.
# - Weed out init_var's usages here and elsewhere with default of &TRUE;
#   rework via separate init_var for opposite and one with negative of that
#   (eg., '&init_var(*do_it, &TRUE);' => '&init_var(*skip_it, &TRUE); &init_var(*do_it, ! $skip_it); ').
# - Try to weed out remaining local's (e.g., in init_var and lock)
# - Work around stupid problem using &DEBUGGING when 'use English' in effect (Undefined subroutine &main::).
# - Use built-in variable for $path_delim (path delimiter).
#
# Portions Copyright (c) 1997-1999, 2002-2003 Tom O'Hara
# Portions Copyright (c) 1999-2001 Cycorp, Inc.  All rights reserved.
#
#
#------------------------------------------------------------------------
# Function synopsis:
# append_entry(array, key, text): Append to the value of an associative array by the given text.
# asctime(): return the time formatted as with the asctime library function
# assert(expression) Issues an error message if the expression evaluates to 0.
# basename(filename, extension): returns the filename w/o the extension.
# blocking_stdin():	determine whether input from STDIN would block
# capitalize(word):	returns the word (or text) capitalized.
# cleanup_common():	module termination cleanup routine
# cmd(command_line):	same as issue_command(command_line)
# copy_file(source_file, destination_file) Copies the source file to the destination. (OS-independent)
# debug_out(trace_level, format_string, argument, ...) Prints a formatted trace message to STDERR when the current debugging level is at or above the specified level.
# difference(list1, list2)  Returns the difference of the two lists (passed as references).
# dirname(file):	returns the directory for the file
# dump_line([line], [debug_level]):   display line in trace (w/ line number)
# error_out(format_string, argument, ...) Prints a formatted error message to STDERR
# filter_warnings(warning_text): Filter benign warnings.
# find(array_ref, item): returns 0-based position of item in the array
# get_entry(array, key, [default=0]) Get the value for the key in the associative array, using the given  default if no corresponding entry.
# get_env(environment_var, default_value, [trace_level]): returns the value of the environment variable, defaulting to the specified value. 
# get_time():		alias for asctime()
# incr_entry(array, key, [increment=1]) Increment the value of an associative array by the given amount, which defaults to 1.
# init_common():	initialize this common module.
# init_var(variable_name, initial_value)  Initializes a variable unless it is already defined.
# intersection(list1, list2)  Returns the intersection of the two lists (passed as references).
# iso_lower(text):	lowercase text accounting for ISO-9660 accents
# iso_remove_diacritics($text): remove diacritic marks from the text
# issue_command(command_line, [trace_level]) Issue the specified command and ignores the result.
# lock(*FILE):		locks the specified file for exclusive access
# make_full_path(filename)   Returns the fully-specified pathname to the file.
# make_path(directory, filename)  Appends the filename to the directory name to form a full-path file  specification.
# pwd():		returns the current directory
# read_file(file_name): Reads in the entire file, returned as a text string.
# remove_dir(full_file_name): removes the directory component from file name
# reset_trace():      reset the line number and other trace information
# run_command(command_line, [trace_level], [disable]) Runs the specified command and returns the result as a string.
# run_perl(command_line) Invoke perl to process the specified command-line.
# tokenize (text) Returns the list of whitespace-delimited tokens from the text
# trace_array(array_ref, [debug_level], [label])  Outputs the (list) array to the trace file, unless current debug   level is lower than specified trace level.
# trace_assoc_array(associative_array_ref, [debug_level])  Outputs the associative array to the trace file, unless current debug   level is lower than specified trace level.
# trim(text):		removes leading and trailing whitespace
# unlock(*FILE):	unlocks the specified file
# write_file(file_name, text): Writes the text to the specified file.
#

# 
# TODO: use 'our' rather than 'use vars':
##
## our($debug_level, $d, $o, $redirect, $script_dir, $script_name, $TRUE, $FALSE, $MAXINT,
##     $disable_commands, $under_WIN32, $unix, $delim, $precision, $verbose, $TEMP, $TMP,
##     $OSTYPE, $OS, $HOST, $debugging_timestamps, $unbuffered, $para, $slurp, $PATH, @PATH,
##     $common_options);
##
use vars qw/$debug_level $d $o $redirect $script_dir $script_name $TRUE $FALSE $MAXINT
    $disable_commands $unix $under_WIN32 $delim $path_delim $path_var_delim $precision $verbose $help $TEMP $TMP
    $OSTYPE $OS $HOST $debugging_timestamps $disable_assertions $unbuffered $para $slurp $PATH @PATH
    $force_WIN32 $force_unix $osname $common_options $utf8 $BOM $timeout $timeout_seconds $timeout_script $wait_for_user/;
use vars qw/$preserve_temp/;

sub COMMON_OPTIONS { $common_options; }

# NOTE: stupid Perl: the __WARN__ signal is disabled when the -w switch is used
# Also, this doesn't seem to trap warnings due to command-line variables,
## $SIG{__WARN__} = 'filter_warnings';

# Define constants
sub TRUE { 1; }
sub FALSE { 0; }
sub MAXINT { $MAXINT; }
sub MININT { -$MAXINT; }
sub MAXIMUM_INTEGER { $MAXINT; }

sub DELIM { $path_delim; }
sub under_WIN32 { $under_WIN32 && (! $force_unix); }
sub use_WIN32 { $under_WIN32 && ((! $unix) || $force_WIN32); }
sub under_CYGWIN { $under_WIN32 && $unix; }
sub WIN32 { $under_WIN32; }
sub SOLARIS { ($OSTYPE eq "solaris" ? &TRUE : &FALSE); }

# Constants for controlling program trace output.
#
# NOTES: 
#
# The higher the value, the more output produced.  In practice, start
# out at detailed or verbose during debugging, and then set the values
# higher once debugged, especially for frequently called functions.
#
# *** Resist the temptation to remove debugging trace code, instead
# assign higher trace levels. The person who inherits your code can
# benefit from these trace statements (or even yourself if you
# revisit the code after a long absence).
#
sub TL_ALWAYS {0;}		# message always displayed
sub TL_ERROR {1;};		# only information about errors
sub TL_BASIC {2;};		# include important intermediate results
sub TL_WARNING { &TL_BASIC; }	# alias for TL_BASIC
sub TL_USUAL {3;};		# a compromise between TL_BASIC & TL_DETAILED
sub TL_DETAILED {4;};		# detailed information (eg, subroutine calls)
sub TL_VERBOSE {5;};		# extra information to help with debugging
sub TL_VERY_DETAILED {6;};	# ex: line-by-line file operations
sub TL_VERY_VERBOSE {7;};	# ex: string manipulation (eg., tokenization)
sub TL_MOST_DETAILED {8;};	# ex: frequently called support functions
sub TL_MOST_VERBOSE {9;};	# ex: results of such functions
sub TL_ALL {99;}		# all debugging output

sub DEBUG_LEVEL {$debug_level;};
sub DEBUGGING { return ($debug_level >= TL_USUAL) };
sub DETAILED_DEBUGGING { return ($debug_level >= TL_DETAILED) };
sub VERBOSE_DEBUGGING { return ($debug_level >= TL_VERBOSE) };

sub SCRIPT_DIR {$script_dir;};
sub TEMP_DIR {$TEMP;};

# Uncomment the following to help track down undeclared variables.
# Be prepared for a plethora of warnings. One that is important is
#    'Global symbol "xyz" requires explicit package name'
# when NOT preceded by 'Global symbol "xyz" requires explicit package name'
# NOTE: not used since other scripts might fail with it
# TODO: fix all client scripts to be strict as well
#
## use strict;
## no strict "refs";		# to allow for symbolic file handles
## use diagnostics;


# init_common()
#
# Initialize this common module. The main purpose is to set up the
# variables used for controlling the debugging traces. This also
# determines the script file name (for usage statements) and directory
# (for locating other scripts).
# EX: init_common() => 1
#
sub init_common {
    # This function is automatically called during module loading.
    # So if it is explictly invoked, there's no need to proceed.
    $initialized = &FALSE if (!defined($initialized));
    if ($initialized) {
	return ($initialized);
    }

    $initialized = &FALSE if (!defined($initialized));
    # Set debugging level to either $d, DEBUG_LEVEL evironment variable or 3 (the default)
    map { $debug_level = $_ unless defined($debug_level); } ($d, $ENV{"DEBUG_LEVEL"}, &TL_USUAL);
    ## $debug_line_num = 0;
    &debug_print(&TL_VERBOSE, "init_common(@_)\n");
    &trace_assoc_array(\%ENV, &TL_ALL, "%ENV");
    
    # Initialization of important constants
    # NOTE: redundant initializations as above due to unit testing problem with
    # test-perl-examples.perl
    $script_dir = ".";
    $script_name = $0;
    $TRUE = 1;
    $FALSE = 0;
    $MAXINT = 2147483647;
    &init_var_exp(*disable_commands, $FALSE);
    &init_var_exp(*force_WIN32, &FALSE);		# force WIN32 file usage, etc.
    &init_var_exp(*force_unix, &FALSE);		# force unix file usage, etc.
    $under_WIN32 = defined($ENV{WINDIR});
    $unix = (! $under_WIN32);
    &debug_print(&TL_VERBOSE, "take 1: under_WIN32=$under_WIN32 unix=$unix\n");
    
    # Common arguments for the scripts using common.perl
    #
    $common_options = "[-verbose] [-help]";
    &init_var_exp(*precision, 3);	# default number of decimal places for rounding
    &init_var_exp(*verbose, &FALSE);	# verbose output mode
    &init_var(*help, &FALSE);	        # show usage
    ## &init_var_exp(*strict, &FALSE);		# use strict perl type checking
    #
    &init_var_exp(*unbuffered, &FALSE);	# unbuffered I/O
    &init_var_exp(*debugging_timestamps, &FALSE);   # timestamp all debug output
    &init_var_exp(*disable_assertions, &FALSE);	    # don't check for assertions
    &init_var_exp(*preserve_temp,                   # preserve temporary files
		  &VERBOSE_DEBUGGING);          

    # Check options for changing line-input mode
    &init_var_exp(*para, &FALSE);		# read paragraphs not lines
    &init_var_exp(*slurp, &FALSE);		# read entire files not lines
    &assert(! ($para && $slurp));
    $/ = "" if ($para);			# paragraph input mode
    $/ = 0777 if ($slurp);		# complete-file input mode

    # Make sure debugging level corresponds to DEBUG_LEVEL environment variable.
    # Also, the value gets overridden by -d=N command-line switch.
    $debug_level = &get_env("DEBUG_LEVEL", &TL_BASIC);
    if (defined($d)) {
	$debug_level = $d;
    }

    # Set or override DEBUG_LEVEL environment variable based on value determined above. 
    # NOTE: This helps propagate -d settings to perl scripts invoked by the script
    $ENV{"DEBUG_LEVEL"} = $debug_level;

    # Assign values to basic constants
    ## $TRUE = 1;
    ## $FALSE = 0;
    ## &assert($TRUE != $FALSE);

    # See if running under Windows NT or Win95 instead of Unix
    # note: OSTYPE normally not set in this case
    &init_var_exp(*OSTYPE, "???");		# Unix operating system type
    &init_var_exp(*OS, "???");		        # Windows operating system
    &init_var_exp(*HOST, "???");		# system host name
    $osname = (defined($^O) ? $^O : "???");	# name of OS under which Perl built
    if ($osname =~ /Win32/i) {
	$under_WIN32 = &TRUE;
	$unix = &FALSE;
	## $redirect = ($debug_level > 3);
    }
    elsif ($OS eq "Windows_NT") {
	$under_WIN32 = &TRUE;
	if ($OSTYPE eq "cygwin") {
	    $unix = &TRUE;
	}
    }

    # Account for Unix/Windows differences in filename and path var. delimiter
    $path_delim = "\/";
    $path_var_delim = ":";
    if (&use_WIN32) {
	$path_delim = "\\";
	$path_var_delim = ";";
    }
    # TEMP HACK: support for old name (until client scripts revised)
    ## $delim = $path_delim;

    # Pattern for use in regex (e.g., '$dir =~ /^[$PD]/')
    $PD = "\\\\\/";

    # Determine the directory for the scripts
    $script_name = $0;
    $script_dir = $0;
    if ($script_dir =~ /[$PD]/) {
	$script_dir =~ s/[$PD][^$PD]*$/$path_delim\./;	# chop off the file name
	$script_name =~ s/\.?\.?[$PD]?.*[$PD]//; 	# chop off the directory
    }
    else {
	$script_dir = ".";
    }
    $script_dir = &make_full_path($script_dir);

    # Miscellaneous initialization
    &init_punctuation unless (defined($punctuation_pattern));
    
    # Temporary directory location
    # TMP: system temporary directory
    # TEMP: either $TMP or current directory if debugging
    # NOTE: this must be done after $unix/$under_WIN32 check
    &init_var_exp(*TMP, "/tmp/");
    &init_var_exp(*TEMP, (&VERBOSE_DEBUGGING ? &pwd() : $TMP));
    $TEMP .= $path_delim unless ($TEMP =~ /[$PD]$/);

    if ($unbuffered || &DETAILED_DEBUGGING) {
	&debug_print(&TL_VERBOSE, "setting unbuffered I/O\n");
	select(STDIN); $| = 1;		    # set stderr unbuffered
	select(STDERR); $| = 1;		    # set stderr unbuffered
	select(STDOUT); $| = 1;		    # set stdout unbuffered
    }

    # Redirect stdout to file specified with -o option
    if (defined($o)) {
	&debug_print(&TL_VERY_DETAILED, "redirecting STDOUT to $o\n");
	close(STDOUT);
	open(STDOUT, "> $o") ||               # redefine stdout to the file
	    die "Unable to create output file $o ($!)\n";
    }

    # Redirect stderr to stdout if desired (support for Windows)
    if (defined($redirect) && ($redirect == &TRUE)) {
	select(STDOUT); $| = 1;		    # set stdout unbuffered
	open(STDERR, ">&STDOUT");	    # redefine stderr
	select(STDERR); $| = 1;		    # set stderr unbuffered
    }

    # Make sure input and output use UTF-8
    # NOTE: Needed mainly for win32 
    # TODO: add support for automatic decode_utf8 of input (see count_it.perl)
    &init_var_exp(*utf8, &FALSE);
    if ($utf8) {
	## OLD:
	## eval "use Encode;";
	eval "use Encode 'decode_utf8'";
	## binmode(STDIN, ":utf8");
	## binmode(STDOUT, ":utf8");
	## binmode(STDERR, ":utf8");
	eval 'use open ":std", ":encoding(UTF-8)";';
	&debug_print(&TL_DETAILED, "Enabled UTF-8 support\n");
    }

    # Trace out a few values
    my($args) = join(" ", @ARGV);
    &debug_print(&TL_VERY_VERBOSE, "$0 @ARGV\n");
    &debug_out(&TL_VERBOSE, "starting %s %s [%s]\n", $script_name, $args, &get_time());
    ## &debug_print(&TL_DETAILED, "$0 $args\n");
    &debug_print(&TL_VERBOSE, "debug_level=$debug_level; #ARGV=$#ARGV; script_dir=$script_dir path_delim=$path_delim temp=$TEMP\n");
    &debug_print(&TL_VERBOSE, "host=$HOST OS=$OS; OSTYPE=$OSTYPE; osname=$osname under_WIN32=$under_WIN32; Unix=$unix\n");
    &trace_array(*ARGV, &TL_VERY_DETAILED, "\@ARGV");

    # Setup @PATH global to combination of @INC and $PATH environemnt var
    &trace_array(\@INC, &TL_MOST_DETAILED, "\@INC");
    &trace_array(\@PATH, &TL_MOST_DETAILED, "default \@PATH");
    &init_var_exp(*PATH, "");
    @PATH = @INC;
    ## BAD: map { &pushnew(\@PATH, $_); } split($path_delim, $PATH);
    map { &pushnew(\@PATH, $_); } split($path_var_delim, $PATH);
    &trace_array(\@PATH, &TL_MOST_DETAILED, "\@PATH");
    ## NOTE: following assertion yields a warning: Useless use of sort in scalar context ..
    ## TODO: &assertion(sort(&intersection(\@PATH, \@INC)) == sort(@INC)));
    my(@sorted_PATH_INC_intersection) = sort(&intersection(\@PATH, \@INC));
    my(@sorted_INC) = sort(@INC);
    &assertion(@sorted_PATH_INC_intersection == @sorted_INC);
    &trace_array(\@sorted_PATH_INC_intersection, &TL_MOST_DETAILED, "\@sorted_PATH_INC_intersection");
    &trace_array(\@sorted_INC, &TL_MOST_DETAILED, "\@sorted_INC");
	
    
    &init_var_exp(*timeout_script, "cmd.sh"); # script for running commands with timeout check
    &init_var_exp(*timeout, &FALSE);	# check for command timeout
    &init_var_exp(*timeout_seconds, 	# seconds to wait for timeout
		  $timeout ? 60 : -1);
    &init_var(*wait_for_user, &FALSE);  # wait for user at end of script

    $initialized = &TRUE;

    # Print optional UTF-8 byte order mark (BOM): (U+FEFF)
    &init_var_exp(*BOM, &FALSE);
    if ($BOM) {
	print "\xEF\xBB\xBF\n";
    }

    return ($initialized);
}

# cleanup_common(): module termination cleanup routine
# NOTE: This must be explicitly invoked.
#
# TODO: see if there's a way to invoke it automatically
#
sub cleanup_common {
    &debug_out(&TL_VERBOSE, "ending %s: %s\n", $script_name, &get_time());

    # Optionally, wait for the user response before terminating.
    if ($wait_for_user) {
	require 'extra.perl';
	&get_user_response("Hit any key to exit: ");
    }
}

# force_win32_usage([force]): enables WIN32 usage even when under CygWin
#
sub force_win32_usage {
    my($force) = @_;
    $force = &TRUE unless (defined($force));

    $force_WIN32 = $force;
}

# exit([error_message]): terminates the program, optionally displaying an error message
#
sub exit {
    my($error_message) = @_;
    if (defined($error_message)) {
	chomp $error_message;
	&error_out("%s\n", $error_message);
    }
    &cleanup_common();
    exit;
}

# get_time(): alias for asctime()
#
sub get_time {
    return (&asctime());
}

# get_env(environment_var, default_value, [trace_level])
#
# Returns the value of the environment variable, defaulting to the specified
# value.
# 
sub get_env {
    my($var, $default, $trace_level) = @_;
    my($var_text, $value);
    $trace_level = &TL_VERY_VERBOSE unless (defined($trace_level));

    $value = $default;
    $var_text = $ENV{$var};
    if (defined($var_text)) {
	$value = $var_text;
	}
    &debug_out($trace_level, 
	       "get_env(\"%s\", \"%s\", trace_level=%d) => %s\n",
	       $var, $default, $trace_level, $value);

    return $value
}

# set_env(environment_var, value, [trace_level])
#
# Sets the value of the environment variable. (Useful for tracing.)
#
sub set_env {
    my($var, $value, $trace_level) = @_;
    $trace_level = &TL_VERY_VERBOSE unless (defined($trace_level));
    ## TODO: &assert(defined($value));
    $ENV{$var} = $value;
    &debug_out($trace_level, "set_env(%s, %s)\n", $var, $value);
}

# run_command(command_line, [trace_level], [disable])
#
# Runs the specified command and returns the result as a string.
#
# NOTES:
#
# Command execution is disabled with $disable_commands = &TRUE.
#
# This is leading to some obscure Perl bug in the reporting of
# undefined values in dump_links.perl (perhaps an internal perl variable).
# This has not been noticed with other scripts.
#
# EX: run_command("echo a b c") => "a b c"
#
# TODO:
# - Use a more intuitive way of disabling commands
# - Try to detect with run_command_win32 needed under CygWin (e.g., trapping output from C# applications)
#
sub ALWAYS_RUN { &FALSE };
#
sub run_command {
    if (&use_WIN32) {
	return (&run_command_win32(@_));
    }
    my($command, $trace_level, $disable) = @_;
    $trace_level = &TL_VERBOSE+1 unless (defined($trace_level));
    $disable = $disable_commands unless (defined($disable));
    my($result) = "";

    # See if system commands have been disabled (for testing purposes)
    if ($disable) {
	&debug_out($trace_level - 1, "(disabled) run_command: %s\n", $command);
	return ("");
    }
    
    # Add optional timeout check (only works for Unix or CygWin)
    my($temp_script) = "";
    if ($timeout_seconds > 0) {
	## $command =~ s/([^\\])([*?&])/$1\\$2/g;
	# TODO: Quote arguments if special shell characters
	## if ($command =~ /([^\\])([*?&])/) {
	    ## my($command_name, @args) = split(/ +/, $command);
	    ## $command = sprintf "$command_name %s", join(" ", map { "\"$_\""; } @args);
	## }

	# Use temporary script to run command as eval environment in cmd.sh runs into problems with special shell characters
	$temp_script = "temp-$$.sh";
	&write_file($temp_script, "$command\n");
	$command = "$timeout_script --time-out $timeout_seconds source $temp_script";
    }

    &debug_print($trace_level, "run_command: $command\n");
    open(RUN_COMMAND_FILE, "$command|");
    while (<RUN_COMMAND_FILE>) {
	$_ =~ s/[\n\r]+$//;
	$result .= "$_\n";
    }
    $result =~ s/[\n\r]+$//;
    close(RUN_COMMAND_FILE);
    &debug_out($trace_level+1, "run_command => {\n%s\n}\n", $result);

    if ($temp_script ne "") {
	## OLD: unlink $temp_script unless (&VERBOSE_DEBUGGING);
	unlink $temp_script unless ($preserve_temp);
    }

    return ($result);
}

# run_command_win32: version of run_command for Windows
#
# NOTE: output redirection is not supported
#
my($run_output_num) = 0;
#
sub run_command_win32 {
    my($command, $trace_level, $disable) = @_;
    $trace_level = &TL_VERBOSE+1 unless (defined($trace_level));
    $disable = $disable_commands unless (defined($disable));
    my($result) = "";
    &assert($command !~ /\>/);

    # See if system commands have been disabled (for testing purposes)
    if ($disable) {
	&debug_out($trace_level - 1, "(disabled) run_command: %s\n", $command);
	return ("");
    }

    # Issue the command (indirectly via system)
    # NOTE: output redirection not preceded by space (e.g. the space could be part of output if echoed)
    my($temp_file) = sprintf "%s%s-%d-%d.data", &TEMP_DIR, "temp-run-output", $$, $run_output_num++;
    &issue_command("$command > $temp_file", $trace_level+1);

    $result = &read_file($temp_file,  $trace_level+2);
    $result =~ s/\r\n/\n/g;
    chomp $result;
    &debug_out($trace_level+1, "run_command_win32 => {\n%s\n}\n", $result);
    ## OLD: unlink $temp_file unless (&DEBUG_LEVEL > &TL_VERY_DETAILED);
    ## TODO: see why following didn't generate warning
    ## BAD: unlink $temp_temp unless ($preserve_temp);
    unlink $temp_file unless ($preserve_temp);

    return ($result);
}

# run_command_fmt(command_format_string, arg1, ...)
#
# Version of run_command that allows sprintf format string and arguments
# NOTE: trace-level and disable-command optional arguments are not supported
#
sub run_command_fmt {
    my($command_fmt, @args) = @_;
    return (&run_command(sprintf $command_fmt, @args));
}

# run_command_over(command, data, [trace_level])
#
# Run's the specified command using the data as input returning the output
# as a string.
#
# NOTE: The commmand is assumed to take a file name as the last input. A
# temporary file is created for this purpose, which uses a unique ID and
# is retained during debugging.
#
# TODO: just use a single temp file (eg, temp-run-command-$$.data) rather
# than separate ones (e.g., temp-run-command-$$-$num.data) unless verbose debugging
#
my($run_num) = 0;
#
sub run_command_over {
    my($command, $input, $trace_level) = @_;
    $trace_level = &TL_VERY_DETAILED unless (defined($trace_level));

    # Output input to temp file and then run command using the file as input
    my($temp_file) = sprintf("%s%s-%d-%d.data", &TEMP_DIR, "temp-run-command", $$, $run_num++);
    &write_file($temp_file, $input);
    my($result) = &run_command(sprintf("%s %s", $command, $temp_file), $trace_level);
    ## TODO: add $preserve_temp_files option
    unlink $temp_file unless (&DEBUG_LEVEL >= $trace_level);

    return ($result);
}

# issue_command(command_line, [trace_level])
#
# Issue the specified command and ignores the result.
#
# NOTE: Command execution is disabled with $disable_commands = &TRUE
#
sub issue_command {
    my($command, $trace_level) = @_;
    $trace_level = &TL_DETAILED unless (defined($trace_level));
    my($result);

    # Under Win32, commands to be run interpretted by the shell are run via 'cmd /c'
    # NOTE: This is used mainly when running perl scripts
    # Also, the command needs to be properly escaped
    # TODO: Add support for Win95 and Win98
    if (&use_WIN32 && ($command !~ /\.exe/)) {
	$command = "cmd /c " . $command;

	# Make sure backslashes are properly escaped
	$command =~ s/([^\\])\\([^\\])/$1\\\\$2/g;
    }

    # Add optional timeout check (only works for Unix or CygWin)
    if ($timeout_seconds > 0) {
	$command = "$timeout_script --time-out $timeout_seconds $command";
    }

    &debug_print($trace_level, "issue_command: $command\n");
    system("$command") unless ($disable_commands);
}


# issue_command_over(command, data)
#
# Issues the specified command using the data as input.
# NOTE: The commmand is assumed to take a file name as the last input. A
# temporary file is created for this purpose, which uses a unique ID and
# is retained during debugging.
# TODO: consolidate with run_command_over
#
my($issue_num) = 0;
#
sub issue_command_over {
    my($command, $input) = @_;
    my($temp_file) = sprintf "%s%s.%d.%d", &TEMP_DIR, "temp_run_command", $$, $issue_num++;
    &write_file($temp_file, $input);
    my($result) = &issue_command(sprintf "%s %s", $command, $temp_file);
    ## OLD: unlink $temp_file unless (&DEBUG_LEVEL > &TL_VERBOSE);
    unlink $temp_file unless ($preserve_temp);
    return ($result);
}

# issue_command_fmt(command_format_string, arg1, ...)
#
# Version of issue_command that allows sprintf format string and arguments
# NOTE: trace-level optional argument is not supported
#
sub issue_command_fmt {
    my($command_fmt, @args) = @_;
    return (&issue_command(sprintf $command_fmt, @args));
}

# cmd(command_line):  same as issue_command(command_line)
#
sub cmd {
    &issue_command(@_);
}


# shell(command_format_string, format_arguments)
#
# Run a command that is specified via an sprintf format string with arguments.
# NOTE: This is equivalent to issue_command_fmt
#
sub shell {
    my($command_fmt, @args) = @_;

    &issue_command(sprintf $command_fmt, @args);
}

# debug_on([new-trace-level=TL_DETAILED]): turn on detailed debugging
#
sub debug_on {
    ## BAD: my($level) = $_;
    my($level) = @_;
    $level = &TL_DETAILED if (!defined($level));

    $debug_level = $level;
}

# debug_out(trace_level, format_string, argument, ...)
#
# Prints a formatted trace message to STDERR when the current debugging
# level is at or above the specified level.
#
# TODO: Introduce debug_out_fmt for the printf version to avoid problems 
# with % characters occurring in the format text. Then this version
# (debug_out) would just print the text.
#
sub debug_out {
    my($level, $format_text, @args) = @_;
    &debug_print(&TL_MOST_VERBOSE, "debug_out(@_)\n");

    # Do sanity check to ensure printf formatting present
    # TODO: move inside trace level test to avoid too many warnings.
    if (&DETAILED_DEBUGGING && ($format_text !~ /%/)) {
	my($package, $filename, $line) = caller;
	&warning("No printf format specification at $filename:$line: Consider using debug_print instead of debug_out\n");
    }

    # Perform the formatted output unless trace level not sufficiently high.
    if ($level <= $debug_level) {
	printf STDERR "[%s] ", &asctime, if ($debugging_timestamps);
	printf STDERR $format_text, @args;
    }
    return (1);
}

# debug_out_fmt(trace_level, format_string, argument, ...)
# alias for debug_out
#
sub debug_out_fmt {
    return (&debug_out(@_));
}

# debug_out_new(trace_level, text)
# version of debug_out that doesn't using printf for formatting the results
# NOTE: this avoids problems with strings containing printf formatting codes
# TODO: rename debug_out as debug_out_fmt and debug_out_new as debug_out???
#
sub debug_out_new {
    my($level, $text) = @_;
    if ($level <= $debug_level) {
        print STDERR $text;
    }
}

# debug_trace(trace_level, text, ...)
# version of debug_out that doesn't using printf for formatting the results
# NOTE: this avoids problems with strings containing printf formatting codes
# TODO: rename debug_out as debug_out_fmt and debug_out_new and debug_out
#
sub debug_trace {
    my($level, @text_args) = @_;
    if ($level <= $debug_level) {
	printf STDERR "[%s] ", &asctime, if ($debugging_timestamps);
        print STDERR @text_args;
    }
}

# debug_print(args): alias for debug_trace
#
sub debug_print {
    return (&debug_trace(@_));
}

# debug_printf(format, args): alias for debug_out_fmt
#
sub debug_printf {
    return (&debug_out_fmt(@_));
}

# TODO: add function for conditional evaluation of debug code:
## # debug_code(trace_level, perl_code)
## # Evaluate given Perl code if debug level in effect.
## # EX: debug_code(&TL_VERBSOSE, "$file =~ s/\\n/\\n    /g;");
## #
## sub debug_code {
##     my($level, @command_args) = @_;
##     if ($level <= $debug_level) {
## 	eval "@command_args";
##     }
## }

# error_out(format_string, argument, ...)
#
# Prints a formatted error message to STDERR
#
sub error_out {

    &debug_print(&TL_ERROR, "ERROR: ");
    return &debug_out(&TL_ERROR, @_);
}

# error_printf(arg, ...): alias for error_out
#
sub error_printf {
    &error_out(@_);
}

# error_print(argument, ...)
#
# Prints an error message to STDERR using concatenation of args
#
sub error_print {
    &error_out("%s", join("", @_));
}

# error(arg, ...): alias for error_print
#
sub error {
    &error_print(@_);
}

# warning_out(format_string, argument, ...)
#
# Prints a formatted warning message to STDERR
#
sub warning_out {
    &debug_print(&TL_WARNING, "WARNING: ");
    return &debug_out(&TL_WARNING, @_);
}

# warning_printf(arg, ...): alias for warning_out
#
sub warning_printf {
    &warning_out(@_);
}

# warning_print(argument, ...)
#
# Prints an warning message to STDERR using concatenation of args
#
sub warning_print {
    &warning_out("%s", join("", @_));
}

# warning(arg, ...): alias for warning_print
#
sub warning {
    &warning_print(@_);
}

# assert(expression)
#
# Issues an error message if the expression evaluates to 0, showing
# the expression that failed and the file name and line number, as in
# the C assert macro. This faciliates debugging, especially when the
# problem is due to unexpected input.
#
# example: &assert((scalar @all_senses) == (scalar @singleton_senses));
#
# TODO:
# - have version that doesn't evaluate the expression
#
sub assert {
    my($expression, $package, $filename, $line) = @_;
    if ($disable_assertions) {
	&debug_print(99, "my assert(@_) {checking disabled}\n");
	return;
    }
    &debug_print(&TL_VERBOSE+4, "my assert(@_)\n");

    # Determine the package to use for the evaluation environment,
    # as well as the filename and line number for the assertion call.
    if (! defined($package)) {
	($package, $filename, $line) = caller;
    }

    # Evaluate the expression in the caller's package
    ## &debug_print(&TL_VERBOSE+4, "eval: 'package $package; $expression;'\n");
    my($result) = eval("package $package; $expression;") if (defined($expression));

    # If failed, then display the failed expression along with it's
    # filename and line number (as in the assert macro for C).
    if (!defined($result) || ($result eq "0")) {
	## OLD: $expression = &run_command("tail +$line '$filename' | head -1", &TL_VERY_VERBOSE);
	$expression = &run_command("tail --lines=+$line '$filename' | head -1", &TL_VERY_VERBOSE);
	$expression =~ s/^\s*&?assert(\(.*\));\s*(\#.*)?$/$1/;
	print STDERR "*** Assertion failed: $expression [$filename: $line] (input line=$.)\n";
    }
    else {
	&debug_print(&TL_VERBOSE+4, "result: $result\n");
    }
}

# soft_assertion(expression): Alias for assert
# assertion(expression): ditto
# TODO: Rework so soft_assertion is the defined function (i.e., not alias).
#
sub soft_assertion { 
    my($package, $filename, $line) = caller; 
    &assert(@_, $package, $filename, $line); 
}
#
sub assertion { 
    my($package, $filename, $line) = caller; 
    &assert(@_, $package, $filename, $line);
}

# reset_trace():      reset the line number and other trace information
# NOTE: obsolete function
#

sub reset_trace {
    ## $debug_line_num = 0;
}


# dump_line([line], [debug_level]):   display line in trace (w/ line number)
#

sub dump_line {
    my($line, $level) = @_;
    $line = $_ unless defined($line);
    $level = &TL_VERY_DETAILED unless defined($level);
    chop $line if ($line =~ /\n$/);

    &debug_out($level, "%d:\t%s\n", $., $line);
}


# trace_assoc_array(associative_array_ref, [debug_level], [label])
#
# Outputs the associative array to the trace file, unless current debug 
# level is lower than specified trace level.
#
sub trace_assoc_array {
    my($assoc_array_ref, $trace_level, $label) = @_;
    $trace_level = &TL_VERBOSE + 2 if (!defined($trace_level));
    $label = $assoc_array_ref if (!defined($label));

    if ($trace_level <= &DEBUG_LEVEL) {
	my($key);
	&debug_out($trace_level, "%s: {\n", $label);
	foreach $key (sort(keys(%{$assoc_array_ref}))) {
	    my($value) = ${$assoc_array_ref}{$key};
	    $value = "(undefined)" if (!defined($value));
	    &debug_out($trace_level, "\t%s: %s\n", $key, $value);
	}
	&debug_print($trace_level, "\t}\n");
    }

    return;
}

# trace_associative_array: alias for trace_assoc_array
#
sub trace_associative_array {
    return (&trace_assoc_array(@_));
}


# trace_array(array_ref, [debug_level], [label])
#
# Outputs the (list) array to STDERR, unless current debug 
# level is lower than specified trace level.
#
sub trace_array {
    my($array_ref, $trace_level, $label) = @_;
    $trace_level = &TL_VERBOSE + 2 if (!defined($trace_level));
    $label = $array_ref if (!defined($label));

    if ($trace_level <= &DEBUG_LEVEL) {
	my($i);
	&debug_out($trace_level, "%s:\n", $label);
	for ($i = 0; $i <= $#{$array_ref}; $i++) {
	    &debug_out($trace_level, "\t%d:'%s'\n", $i, ${$array_ref}[$i]);
	}
    }

    return;
}


# blocking_stdin():	determine whether input from STDIN would block
#
sub blocking_stdin {
    my($blocked) = &FALSE;
    my($flags);
    &debug_print(&TL_VERY_DETAILED, "blocking_stdin()\n");

    # Stupidity: non-uniform support for fcntl
    if (&use_WIN32) {
	&debug_print(&TL_VERBOSE, "skipping blocking_stdin test under Win32\n");
	return 0;
    }
    my($perl5) = ($] =~ /^5/);
    eval "use Fcntl;" if ($perl5);
    eval "require 'sys/fcntl.ph';" if (!$perl5);

    # fcntl() performs a variety of functions on open descriptors:
    #
    # F_GETFL        Get descriptor status flags (see fcntl(5) for
    #                definitions).
    #
    $flags = fcntl(STDIN, &F_GETFL, 0);
    &debug_print(&TL_VERY_VERBOSE, "fcntl(STDIN, &F_GETFL, 0) => $flags\n");
    # TODO: ($flags && O_RDWR)
    if (($flags eq "2") || ($flags eq "8194")) {
	$blocked = &TRUE;
    }

    return ($blocked);
}

# init_var(variable_name, initial_value, [export=FALSE])
#
# Initializes a variable unless it is already defined. This is intended
# for variables that can be defined on the Perl command line via
#     perl -s -var=value ...
# where value defaults to 1 (i.e., '-var' is equivalent to '-var=1').
#
# example:
#     perl -s it.perl -d=5 -var1=101
#
#     it.perl:
#        require 'common.perl'
#        &init_var(*var1, 99);	;; $var1 => 101;
#        &init_var(*var2, 77);  ;; $var2 => 77
#
# NOTE: 
# The environment setting for the variable is checked first whenever
# the variable hasn't been defined on the command line. In addition, the
# environment variable can optionally be set, which faciliates passing
# settings to sub-scripts that have similar parameters.
#
# WARNING:
# - The automatic creation of environment variables can lead to subtle problems
# with other scripts that rely upon environemt variables. This is disabled under
# WIN32 since the environment variables are case insensitive.
#
# TODO:
# - Use some convention (e.g., option_<NAME>) to avoid inadvertant conflicts.
# - add support for automatic 'use qw/$var/;' declaration (for strict mode)
# - create init_local_var for non-commandline variables
# - Make export_var false by default and require explicit usage in those scripts
#   requiring it (e.g., those that call helper scripts with same arguments).
# - Add option to disable environment variable usage.
#
our($export_default) = &FALSE;
sub set_init_var_export {
    my($default) = @_;
    $export_default = $default;
}
#
## OLD: sub EXPORT {&TRUE;}
#
sub init_var {
    use vars qw/$var_name $var_value $export_var/;
    local(*var_name, $var_value, $export_var) = @_;
    my($default_export_var) = $export_default;
    $export_var = $default_export_var if (!defined($export_var));

    # Determine the environment variable name, which the variable w/o the package 
    # specifier (eg, "*main::use_random_coords" => "use_random_coords").
    # TODO: Use some convention to avoid clash w/ common env vars ???
    #       Maintain the package spec ???
    my($env_var) = *var_name;
    $env_var =~ s/^.*:://;
    ## TODO: make this optional
    $env_var = &to_upper($env_var);
    my($new_value);

    if (!defined($var_name)) {
	# Get the value of the corresponding environment variable, if set.
	$new_value = &get_env($env_var, $var_value, &TL_VERBOSE+2);
	$var_name = $new_value;
    }
    else {
	$new_value = $var_name;
    }

    # Update the environment variable to the value, useful for automatic
    # transfer of parameter values to perl scripts invoked by this script.
    if ($export_var) {
	## OLD:
	## my($env_var) = *var_name;
	## $env_var =~ s/^.*:://;
	&set_env($env_var, $new_value, &TL_VERY_VERBOSE);
    }
    &debug_out(&TL_DETAILED + 1, "init_var(%s, %s): %s=%s\n", 
	       *var_name, $var_value, *var_name, $var_name);
}

# init_var_exp(variable_name, initial_value)
#
# Version of init_var that always exports the variable to environment
# NOTE: this facilitates processing of common argments among scripts but
# can lead to subtle problems
#
sub init_var_exp {
    &assert(!defined($_[2]));
    &init_var($_[0], $_[1], &TRUE);
}

# min(x, y): returns minimal numeric value
# EX: min(7, -7) => -7
# TODO: extend to handle arrays
#
sub min {
    my($x, $y) = @_;

    return ($x < $y ? $x : $y);
}


# max(x, y): returns maximal numeric value
# EX: max(7, -7) => 7
#
sub max {
    my($x, $y) = @_;

    return ($x > $y ? $x : $y);
}



# max_item(list): returns maximum in list of number
# ex: max_item(1, -2, 3) => 3
#
sub max_item {
    my $max = $_[0];
    map { $max = max($max, $_); } @_;
    return ($max);
}

# min_item(list): returns minimum in list of number
# ex: min_item(1, -2, 3) => -2
#
sub min_item {
    my $min = $_[0];
    map { $min = min($min, $_); } @_;
    return ($min);
}

sub max_value { return max_item(@_); }

sub min_value { return min_item(@_); }


# write_file(file_name, text, [trace_level])
#
# Writes the text to the specified file.
# EX: my($file)=&make_path(&TEMP_DIR, "foo"); write_file($file, "fubar"); read_file($file) => "fubar"
# TODO: add check for missing <NL> at end of file???
#
sub write_file {
    my($file_name, $text, $trace_level) = @_;
    $trace_level = &TL_VERBOSE unless (defined($trace_level));
    &debug_print($trace_level, "write_file($file_name, _)\n");
    &debug_out($trace_level+3, "text={\n%s}\n", $text);

    if (!open(WRITE_FILE, ">$file_name")) {
	&debug_print(&TL_ERROR, "unable to create $file_name ($!)\n");
	return;
    }
    if ($utf8) {
	binmode(WRITE_FILE, ":utf8");
    }
    print WRITE_FILE $text;
    close(WRITE_FILE);

    return;
}

# append_file(file_name, text)
#
# Appends the text to the specified file.
# EX: my($file)=&make_path(&TEMP_DIR, "fu"); write_file($file, "foo"); append_file($file, "bar"); read_file($file) => "foobar"
#
sub append_file {
    my($file_name, $text) = @_;
    &debug_print(&TL_VERBOSE, "append_file($file_name, _)\n");
    &debug_out(&TL_VERBOSE+3, "text={\n%s}\n", $text);

    if (!open(WRITE_FILE, ">>$file_name")) {
	&debug_print(&TL_ERROR, "unable to append to $file_name ($!)\n");
	return;
    }
    if ($utf8) {
	binmode(WRITE_FILE, ":utf8");
    }
    print WRITE_FILE $text;
    close(WRITE_FILE);

    return;
}

# find_library_file(file_name, [search_dirs])
#
# Searches the Perl library directories for the file and returns the full pathname
# TODO: add the current directory to the path???
#
sub find_library_file {
    &debug_print(&TL_VERBOSE, "find_library_file(@_)\n");
    my($file, @search_dirs) = @_;
    @search_dirs = @PATH unless ((scalar @search_dirs) > 0);
    my($pathname) = $file;
    my($dir);

    # Check each directory on PATH for file
    foreach $dir (@search_dirs) {
	# See if plain file (-f) exists (-e) in current directory
	my($test_pathname) = &make_path($dir, $file);
	if (&file_exists($test_pathname)) {
	    $pathname = &make_full_path($test_pathname);
	    &assert(&file_exists($pathname));
	    last;
	}
    }
    &debug_print(&TL_DETAILED, "find_library_file(@_) => $pathname\n");

    return ($pathname);
}


# find_program_file(file, [dirs]): search path for program named FILE or FILE.EXE
# OLD: EX: find_program_file("cmd") => "CMD.EXE"
# TODO: fix
# EX: find_program_file("ansifilter") => "linux/ansifilter"
#
sub find_program_file {
    &debug_print(&TL_VERBOSE, "find_program_file(@_)\n");
    my($file, @dirs) = @_;

    my($pathname) = $file;
    if (&use_WIN32 && ($file !~ /.exe/i)) {
	$file .= ".exe";
    }
    return (&find_library_file($file, @dirs));
}


# file_exists(file_name): determine whether the (plain) file exists
# NOTE: directories are not considered
# EX: (file_exists($unix ? '/etc/mtab' : 'c:\\MSDOS.SYS')) => 1
# EX: (file_exists($unix ? '/bin' : 'c:\\TEMP')) => 0
# TODO: have option to specify file types to consider
#
sub file_exists {
    my($file) = @_;
    my($exists) = &boolean((-e $file && -f $file));
    
    &debug_print(&TL_VERY_DETAILED, "file_exists($file) => $exists\n");
    return ($exists);
}

# dir_exists(file_name): determine whether the (plain) file exists
# NOTE: directories are not considered
# EX: (dir_exists($unix ? '/etc/mtab' : 'c:\\MSDOS.SYS')) => 0
# EX: (dir_exists($unix ? '/bin' : 'c:\\TEMP')) => 1
# TODO: have option to specify file types to consider
#
sub dir_exists {
    my($file) = @_;
    my($exists) = &boolean((-e $file && -d $file));
    
    &debug_print(&TL_VERY_DETAILED, "dir_exists($file) => $exists\n");
    return ($exists);
}

# read_file(file_name, [trace_level])
#
# Reads in the entire file, and returns the data as a text string.
# EX: my($file)=&make_path(&TEMP_DIR, "abc"); write_file($file, "a\nb\nc\n"); read_file($file) => "a\nb\nc\n"
#
sub read_file {
    my($file_name, $trace_level) = @_;
    $trace_level = &TL_VERBOSE unless (defined($trace_level));
    my($text) = "";
    &debug_print($trace_level, "read_file($file_name)\n");

    if (!open(READ_FILE, "<$file_name")) {
	&error_out("unable to read %s (%s)\n", $file_name, $!);
	return ($text);
    }
    if ($utf8) {
	binmode(READ_FILE, ":utf8");
    }

    &reset_trace();
    while (<READ_FILE>) {
	&dump_line($_, &TL_VERBOSE+3);
	$text =~ s/\r//;	# ignore DOS carriage returns
	$text .= $_;
    }
    close(READ_FILE);
    &debug_print(&TL_VERBOSE+4, "text={\n$text}\n");

    return ($text);
}

# read_entire_input([handle]): read all of the input and return as a string
#
sub read_entire_input {
    my($handle) = @_;
    $handle = "STDIN" if (!defined($handle));
    &debug_print(&TL_VERBOSE, "read_entire_input(@_): handle=$handle\n");

    return (join("", <$handle>));
}

# old_intersection(list1, list2)
#
# Returns the intersection of the two lists (passed as references).
# This sorts the files, and then scans both lists for equal entries.
# EX: intersection(['a', 'b', 'c'], ['b', 'e']) => ("b")
# TODO: have option for difference(list1, list2), etc.
#
sub old_intersection {
    my($list1_ref, $list2_ref) = @_;
    my(@list) = ();
    my($num) = 0;
    my($i, $j);
    &debug_out(&TL_VERY_VERBOSE, "intersection(%s, %s)\n", $list1_ref, $list2_ref);

    # Sanity check for well-defined arrays
    # note: disabled since it doesn't account for empty lists
    ## &assert('defined(@$list1_ref) && defined(@$list2_ref)');

    # Sort the two lists
    my(@sort1) = sort(@{$list1_ref});
    my(@sort2) = sort(@{$list2_ref});

    # Do a merge-style pass, adding equal entries to the list
    for ($i = 0, $j = 0; ($i <= $#sort1 && $j <= $#sort2); ) {
	&debug_out(&TL_VERBOSE+4, "sort1[%d]='%s' vs sort2[%d]='%s'\n",
		   $i, $sort1[$i], $j, $sort2[$j]);
	if ($sort1[$i] lt $sort2[$j]) {
	    $i++;
	}
	elsif ($sort1[$i] gt $sort2[$j]) {
	    $j++;
	}
	else {
	    $list[$num++] = $sort1[$i];
	    $i++;
	    $j++;
	}
    }
    my($debug_result) = "intersection((@{$list1_ref}), (@{$list2_ref})) =>\n(@list)\n";
    &assert((1 + $#list) <= ((1 + $#{$list1_ref}) + (1 + $#{$list2_ref})));
    &debug_out(&TL_VERBOSE+3, "%s", $debug_result);

    return (@list);
}


# intersection(list1, list2): returns intersection of the two lists
# without sorting them and while preserving the order of the terms in the first list
#
sub intersection {
    my($list1_ref, $list2_ref) = @_;
    &debug_print(&TL_VERBOSE+2, "intersection(@_)\n");
    my(%seen);
    my($item);
    
    # Tag each item in the second list as seen
    map { $seen{$_} = &TRUE; } @$list2_ref;

    # Get those items not see
    my(@list) = grep (defined($seen{$_}), @$list1_ref);
    &debug_print(&TL_VERBOSE+3, "intersection((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

    return (@list);
}

# difference(list1, list2)
#
# Returns the difference of the two lists (passed as references).
# This sorts the files, and then scans both lists for equal entries.
# EX: difference(['a', 'b', 'c'], ['b', 'e']) => ("a", "c")
# TODO: reconcile with intersection (from intersection.perl)
# TODO: preserve the order of the original reference list
# NOTE: the entry's are assumed to not contain the empty string
#
sub difference {
    my($list1_ref, $list2_ref) = @_;
    my(@list);
    my($num) = 0;
    my($i, $j);
    &debug_print(&TL_VERBOSE+2, "difference(@_)\n");

    # Sort the two lists
    my(@sort1) = sort(@$list1_ref);
    my(@sort2) = sort(@$list2_ref);

    # Do a merge-style pass, adding unequal entries to the list
    my($last) = "";
    for ($i = 0, $j = 0; ($i <= $#sort1 && $j <= $#sort2); ) {
        &debug_out(&TL_VERBOSE+4, "sort1[%d]='%s' vs sort2[%d]='%s'; last='%s'\n",
                   $i, $sort1[$i], $j, $sort2[$j], $last);
        if ($sort1[$i] lt $sort2[$j]) {
            $list[$num++] = $sort1[$i] unless ($sort1[$i] eq $last);
	    $last = $sort1[$i];
            $i++;
        }
        elsif ($sort1[$i] gt $sort2[$j]) {
            $j++;
        }
        else {
	    $last = $sort1[$i];
            $i++;
            $j++;
        }
    }
    for (; $i <= $#sort1; $i++) {
	$list[$num++] = $sort1[$i];
    }
    &debug_print(&TL_VERBOSE+3, "difference((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

    return (@list);
}

# new_difference(list1, list2): returns difference of the first list versus the second
# without sorting and while preserving the order of the terms
#
sub new_difference {
    my($list1_ref, $list2_ref) = @_;
    &debug_print(&TL_VERBOSE+2, "new_difference(@_)\n");
    my(%seen);
    ## my($item);
    
    # Tag each item in the second list as seen
    map { $seen{$_} = &TRUE; } @$list2_ref;

    # Get those items not seen
    my(@list) = grep (!defined($seen{$_}), @$list1_ref);
    &debug_print(&TL_VERBOSE+3, "difference((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

    return (@list);
}

# basename(filename, [extension]):
#
# Like the unix csh command, this returns the filename sans the extension.
# EX: basename("classification.log", ".log") => "classification"
# EX: basename("classification.log") => "classification.log"
# NOTE: Unlike the Unix command, this doesn't remove the directory
#
sub basename {
    my($file, $ext) = @_;
    $ext = "" if (!defined($ext));

    $file =~ s/$ext$//;

    return ($file);
}

# basename_proper(file): just return the basename of the file (i.e., no extension
# and no directory)
# EX: basename_proper(&make_path(&TEMP_DIR, "classification.log")) => "classification"
# TODO: have function make_temp_path(f) for &make_path(&TEMP_DIR,f)???
# NOTE: omits the directory unlike &basename
#
sub basename_proper {
    my($file) = @_;

    $file = &remove_dir(&remove_extension($file));

    return ($file);
}


# replace_extension(filename, extension)
#
# Replace the extension of the filename with the supplied extension.
# EX: replace_extension("README.NOW", ".LATER") => "README.LATER"
#
sub replace_extension {
    my($file, $ext) = @_;

    # Make sure the extension starts with a period
    $ext = "." . $ext if ($ext !~ /^\./);

    # Replace the existing extension with the supplied one
    $file = &remove_extension($file);
    $file .= $ext;

    return ($file);
}


# remove_extension(filename): remove any part of the filename starting
# with the last occurrence of the extension delimiter ('.')
# EX: remove_extension("README.NOW") => "README"
#
sub remove_extension {
    my($file) = @_;

    # Replace the existing extension with the supplied one
    $file =~ s/\.[^\.]+$//;

    return ($file);    
}

# pwd: returns the current directory (a la unix pwd command)
# EX: my($tmp) = $TMP; my($dir) = &pwd(); chdir $tmp; my($cd) = &pwd(); chdir $dir; ($cd eq $tmp) => 1
# TODO-EX: (pwd() eq $ENV{PWD}) => 1
# NOTE: This example fails with /home/graphling because /home/ch1/graphling
# used in former but not latter.
#
sub pwd {
    my($PWD) = ($unix ? "pwd" : "cmd /c cd");
    my($dir);
    
##    $dir = &run_command("$PWD", 	# command to run
##			&TL_VERY_VERBOSE, # high trace level
##			&FALSE); 	# never disabled
    $dir = `$PWD`;
    $dir =~ s/[\r\n]+$//;
    &debug_print(&TL_VERY_DETAILED, "pwd(@_) => $dir\n");

    return ($dir);
}


# dirname(file, [is_http])
#
# Return the directory for the file, either from the name itself or the
# current directory.
#
# NOTES:
# - The last component of the path is treated as a file even if a directory itself.
# - see remove_dir() for function to return filename
#
# EX: dirname("/usr") => "/"
# EX: dirname('c:\\temp\\xyz') => 'c:\\temp\\'
#
sub dirname {
    my($file, $is_http) = @_;
    $is_http = &FALSE if (!defined($is_http));
    &debug_print(&TL_VERY_DETAILED, "dirname(@_): is_http=$is_http; PD=$PD\n");

    # Use the part of the file name before the base name
    my($dir) = ".";
    ## if ($file =~ /^(((\.\.[$PD].*[$PD]).*)|([$PD]).*))[^$PD]/) {
    if ($file =~ /(\.?\.?[$PD]?.*[$PD])[^$PD]/) {
	$dir = $1;
	&debug_print(&TL_VERY_VERBOSE, "1: dir=$dir\n");
    }

    # Use the current directory if no directory given (or if "." used)
    if (($dir eq "") || ($dir eq ".")) {
	$dir = &pwd();
	&debug_print(&TL_VERY_VERBOSE, "2: dir=$dir\n");
    }
    # Make sure the directory name is absolute
    if (($dir !~ /^[$PD]/) && ($dir !~ /^[A-Z]:\\/i) && (! $is_http)) {
	$dir = &make_path(&pwd(), $dir);
	&debug_print(&TL_VERY_VERBOSE, "3: dir=$dir\n");
    }
    $dir =~ s/\/tmp_mnt//;	# remove temporary NFS file mount directory
    &debug_print(&TL_MOST_DETAILED, "dirname($file) => $dir\n");

    return ($dir);
}

# url_dirname(URL_path): Return the directory for the url path
#
sub url_dirname {
    return (&dirname($_[0], &TRUE));
}

# incr_entry(array_ref, key, [increment=1])
#
# Increment the value of an associative array by the given amount,
# which defaults to 1. The new value is returned.
# EX: my(%h) = (devil => 665); incr_entry(\%h, "devil"); $h{devil} => 666
#
sub incr_entry {
    my($array_ref, $key, $increment) = @_;
    $increment = 1 if (!defined($increment));
    &debug_print(&TL_ALL, "incr_entry(@_)\n");

    if (!defined($$array_ref{$key})) {
	$$array_ref{$key} = 0;
    }
    $$array_ref{$key} += $increment;

    return ($$array_ref{$key});
}


# append_entry(array_ref, key, text)
#
# Append to the value of an associative array by the given text.
# EX: my(%h) = (it => "it"); append_entry(\%h, "it", "'s"); $h{it} => "it's"
# TODO-EX: ($dir = "c:\\fubar", append_entry(\%ENV, "PATH", ":$dir"), (scalar ($ENV{PATH} =~ m/\Q$dir\E/))) => 1
# EX: $dir = 'c:\\fubar'; append_entry(\%ENV, "PATH", ":$dir"); (index($ENV{PATH}, $dir) > 0) => 1
#
sub append_entry {
    my($array_ref, $key, $text) = @_;
    &debug_print(&TL_ALL, "append_entry(@_)\n");

    if (!defined($$array_ref{$key})) {
	$$array_ref{$key} = "";
    }
    $$array_ref{$key} .= $text;
}


# get_entry(array, key, [default=0])
#
# Get the value for the key in the associative array, using the given 
# default if no corresponding entry.
# TODO: add assertion against empty assoc array to help detect typos (e.g., get_entry(%hash,...) instead of  get_entry(\%hash, ...)
#
sub get_entry {
    my($array_ref, $key, $default) = @_;
    $default = 0 if (!defined($default));
    my($value) = $default;

    if (defined($$array_ref{$key})) {
	$value = $$array_ref{$key};
    }
    &debug_out_fmt(&TL_ALL, "get_entry(%s, '%s', ['%s']) => '%s'\n", 
 		   $array_ref, $key, $default, $value);

    return ($value);
}

# set_entry(array_ref, key, value)
#
# Modifies the associative array in place. 
#
# EX: (set_entry(\%part_of_speech_num, "SimpleNoun", 3), $part_of_speech_num{"SimpleNoun"}) => 3
#
# NOTE: This is inefficient, but very useful for debugging purposes.
# Also, see get_entry above.
# TODO: print out contents of array and hash ref values during debugging
# TODO: Have the value default to true.
#
sub set_entry {
    my($array_ref, $key, $value) = @_;
    &assert(defined($value));
    &debug_print(&TL_ALL, "set_entry(@_)\n");
    
    $$array_ref{$key} = $value;

    return;
}


# tokenize (text, [split_pattern="\\s+"])
#
# Returns the list of whitespace-delimited tokens from the text
# EX: &tokenize("my dog has fleas") => ("my", "dog", "has", "fleas")
# EX: &tokenize("trains, planes, autos", '\\s*,\\s*') => ("trains", "planes", "autos")
# TODO: add support for specify split character (w/ whitespace pattern added)
#

sub tokenize {
    my($text, $split_pattern) = @_;
    $split_pattern = "\\s+" if (!defined($split_pattern));

    # Trim whitespace and then segment based on the intermediate whitespace
    $text = &trim($text);
    my(@tokens) = split(/$split_pattern/, $text);
    &debug_out(&TL_MOST_DETAILED, "tokenize(%s) => (%s)\n", 
	       $text, join(", ", @tokens));

    return (@tokens);
}


# find(array_ref, item, [ignore_case]): returns 0-based position of item in the array
# TODO: use more efficient build-in mechanism for this
#
sub find {
    my($array_ref, $item, $ignore_case) = @_;
    my(@array) = @$array_ref;
    $ignore_case = &FALSE if (!defined($ignore_case));
    my($pos) = -1;
    my($i);

    $item = &to_lower($item) if ($ignore_case);
    for ($i = 0; $i <= $#array; $i++) {
	my($array_item) = $array[$i];
	$array_item = &to_lower($array_item) if ($ignore_case);
	if ($array_item eq $item) {
	    $pos = $i;
	    last;
	}
    }
    &debug_out(TL_VERY_VERBOSE, "find(%s, %s, [%s]) => %d\n", 
	       $array_ref, $item, $ignore_case, $pos);

    return ($pos);
}

# find_ignoring_case(array_ref, item): returns 0-based position of item in
# the array without regard for case
#
sub find_ignoring_case {
    my($array_ref, $item) = @_;
    &find($array_ref, $item, &TRUE);
}

# remove_duplicates(list): returns list with duplicate elements removed
#
sub remove_duplicates {
    my(@list) = @_;
    &debug_print(&TL_VERY_VERBOSE, "remove_duplicates(@_)\n");
    my(@new_list, %seen);
    my($item);

    foreach $item (@list) {
	push(@new_list, $item) unless (defined($seen{$item}));
	$seen{$item} = &TRUE;
    }
    return (@new_list);
}

# pushnew(array_ref, item, ...): add the items to the list unless already there.
# Returns the number of elements in the revised array.
#
sub pushnew {
    my($array_ref, @items) = @_;
    my($item);
    foreach $item (@items) {
	if (find($array_ref, $item) == -1) {
	    push(@$array_ref, $item);
	}
    }
    return (scalar (@$array_ref));
}

#------------------------------------------------------------------------------


# run_perl(command_line)
#
# Invoke perl to process the specified command-line, returning the output
# The command line includes the script to run (without 'perl ' prefix)
#	&run_perl("testit.perl a b c") 
# That is, this is intended as a shortcut to run_command:
#	&run_command("perl -Ssw testit.perl a b c");
# TODO:
# - add warning if the command is not a perl script invocation
# - only use the -S flag when the command line is relative
# 
sub run_perl {
    my($command_line) = @_;
    
    return (&run_command("perl -Ssw $command_line"));
}


# perl(command_line): alias for run_perl
#
sub perl {
    &run_perl(@_);
}


# copy_file(source_file, destination_file)
#
# Copies the source file to the destination. (OS-independent)
#
sub copy_file {
    my($source, $destination) = @_;
    my($text);

    $text = &read_file($source);
    &write_file($destination, $text);

    return;
}

# delete_file(file_name, [warn=&TRUE]); Removes FILE_NAME.
# Note: a wrapper around unlink with tracing and optional warnings
#
sub delete_file {
    my($file_name, $warn) = @_;
    $warn =  &boolean(! defined($warn));

    # Perform the actual deletion
    $OK = unlink($file_name);

    # Issue warning if problem unless warnings are to be suppressed.
    # In addition, trace the result if debugging.
    if (! ($OK or $warn)) {
	&warning("Problem deleting '$file_name'\n")
    }
    &debug_print(&VERY_DETAILED, "delete_file($file_name); status='$OK'\n");

    return $OK
}

# trim(text): Removes leading and trailing whitespace
#
# EX: trim_whitespace("@ xyz .") => "@ xyz ."
# EX: trim_whitespace(" xyz ") => "xyz"
# TODO: have optional parameter to specify removal text pattern
#
sub trim {
    my($text) = @_;

    # Remove leading and trailing whitespace
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;

    return ($text);
}

# trim_whitespace: alias for trim
# EX: trim_whitespace("\n\tMy House\n \t\n") => "My House"
#
sub trim_whitespace {
    return (&trim(@_));
}

# init_punctuation(): initialize data for punctuation stripping
#
# EX: init_punctuation(); (index(&PUNCTUATION_PATTERN, "%") != -1) => 1
# BAD EX: ("abc#def" =~ m/${punctuation_pattern}/) => 1
# EX: ("abc#def" =~ m/&PUNCTUATION_PATTERN/e) => 1
#
our($punctuation_pattern);
sub PUNCTUATION_PATTERN { $punctuation_pattern; }
#
sub init_punctuation {
    # TODO: figure out regex problem with using the pattern; add '<' & '>'
    $punctuation_pattern = "[\,\.\:\;\!\@\#\\\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\\\]";
    &debug_print(&TL_VERBOSE, "init_punctuation: pattern = '$punctuation_pattern'\n");

    return (&TRUE);
}

# trim_punctuation(text): remove leading or trailing punctuation chars from text
# EX: trim_punctuation("Dr.") => "Dr"
# EX: trim_punctuation("Dr. Jones") => "Dr. Jones"
#
sub trim_punctuation {
    my($text) = @_;
    &init_punctuation unless (defined($punctuation_pattern));

    # TODO: use the pattern variable
    # $text =~ s/^${punctuation_pattern}//g;
    # $text =~ s/${punctuation_pattern}$//g;
    $text =~ s/^[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]+//;
    $text =~ s/[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]+$//;
    &debug_print(&TL_VERBOSE, "trim_punctuation(@_) => $text\n");
    
    return ($text);
}

# remove_punctuation(text): remove any punctuation chars from text (anywhere)
# EX: remove_punctuation('s^$% list') => "s list"
#
sub remove_punctuation {
    my($text) = @_;
    &init_punctuation if (! defined($punctuation_pattern));

    ## $text =~ s/${punctuation_pattern}//g;
    $text =~ s/[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]//g;
    &debug_print(&TL_VERBOSE, "remove_punctuation(@_) => $text\n");
    
    return ($text);
}

# remove_outer_quotes(text): remove quotation marks around text
# EX: remove_outer_quotes('"pen pal"') => "pen pal"
# EX: remove_outer_quotes("'pen pal'") => "pen pal"
#
sub remove_outer_quotes {
    my($text) = @_;
    if ($text =~ /^\s*([\"\'])([^\000]*)\1\s*$/) {
	$text = $2;
    }
    &debug_print(&TL_VERY_DETAILED, "remove_outer_quotes(@_) => $text\n");

    return ($text);
}

# iso_lower(text): lowercase text accounting for ISO-9660 accents
# TODO: handle the full-range of accents (not just those for Spanish)
# BAD EX: iso_lower("AÑO") => "año"
# EX: iso_lower("A\x{00D1}O") => "a\x{00F1}o"
#
sub iso_lower {
    my($text) = @_;

    ## OLD: $text =~ tr/A-ZÁÉÍÓÚÑÜÄËÏÖÜ/a-záéíóúñüäëïöü/;
    ## BAD: $text =~ tr/A-Z\xC1\xC9\xCD\xD3\xDA\xD1\xC4\xCB\xCF\xD6\xDC/a-z\xE1\xE9\xED\xF3\xFA\xF1\xE4\xEB\xEF\xF6\xFC/;
    $text =~ s/.*/\L$&/g;

    return ($text);
}

# iso_upper(text): uppercase text accounting for ISO-9660 accents
# TODO: handle the full-range of accents (not just those for Spanish)
# BAD: EX: iso_upper("José") => "JOSÉ"
# EX: iso_upper("Jos\x{00E9}") => "JOS\x{00C9}"
#
sub iso_upper {
    my($text) = @_;

    ## OLD: $text =~ tr/a-záéíóúñäëïöü/A-ZÁÉÍÓÚÑÜÄËÏÖÜ/;
    ## BAD: $text =~ tr/a-z\xE1\xE9\xED\xF3\xFA\xF1\xE4\xEB\xEF\xF6\xFC/A-Z\xC1\xC9\xCD\xD3\xDA\xD1\xC4\xCB\xCF\xD6\xDC/;
    $text =~ s/.*/\U$&/g;

    return ($text);
}

# to_lower(text): convert text to lowercase
# note: alias for iso_lower
# EX: to_lower("NOW is the Time") => "now is the time"
#
sub to_lower {
    my($text) = @_;

    return (&iso_lower($text));
}


# to_upper(text): convert text to uppercase
# note: alias for iso_upper
# EX: to_upper("She'll be back") => "SHE'LL BE BACK"
#
sub to_upper {
    my($text) = @_;

    return (&iso_upper($text));
}


# capitalize(text)
#
# Returns the text (or text) capitalized.
# Ex: capitalize("dog") => "Dog"
# EX: capitalize("CAT") => "Cat"
#
sub capitalize {
    my($text) = @_;

    my($first_char) = substr($text, 0, 1);
    my($rest) = substr($text, 1);
    my($new_text) = &to_upper($first_char) . &to_lower($rest);
    &debug_print(&TL_VERY_VERBOSE, "capitalize($text) => '$new_text'\n");
    
    return ($new_text);
}


# iso_remove_diacritics($text): remove diacritic marks from the text
# TODO: handle the full-range of accents (not just those for Spanish)
# TODO: handle UTF-8 (see http://ahinea.com/en/tech/accented-translate.html)
#

sub iso_remove_diacritics {
    my($text) = @_;
    

    ## OLD: $text =~ tr/ÁÉÍÓÚÑÜáéíóúñü/AEIOUNOaeiounu/;
    ## TODO: handle all diaresis characters (äëïö)
    $text =~ tr/\xC1\xC9\xCD\xD3\xDA\xD1\xDC\xE1\xE9\xED\xF3\xFA\xF1\xFC/\x41\x45\x49\x4F\x55\x4E\x4F\x61\x65\x69\x6F\x75\x6E\x75/;

    # additional diactrics
    # TODO: be more systematic
    ## $text =~ s/çãêâôöèäàÃëÇÂîòïÔìðÊÅåùÀŠý/caeaooeaaAeCAioiOioEAauASy/g;
    $text =~ tr/\xE7\xE3\xEA\xE2\xF4\xF6\xE8\xE4\xE0\xC3\xEB\xC7\xC2\xEE\xF2\xEF\xD4\xEC\xF0\xCA\xC5\xE5\xF9\xC0\x8A\xFD/\x63\x61\x65\x61\x6F\x6F\x65\x61\x61\x41\x65\x43\x41\x69\x6F\x69\x4F\x69\x6F\x45/;
    ## $key =~ s/[¡!¿?]//; ???
    &debug_print(&TL_VERY_DETAILED, "iso_remove_diacritics(@_) => '$text'\n");

    return ($text);
}    

# utf8_remove_diacritics(text): removes diacritics from UTF-8 text
# TODO: find some standard perl module for doing this 
#
# show-unicode-code-info ()
# {
#     perl -CIOE -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";' -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_))
# { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset
# , unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($
# /); print "\n"; ' < $1
# }
# $ show-unicode-code-info utf8-diacritics.txt > utf8-diacritics.info
# $ cut.perl -f="2,1" utf8-diacritics.info | sort -u | extract_matches.perl -fields=2 -replacement='    s/\\x{$1}/_/g;\t# $2' - >| utf8-diacritics.subst
#
sub utf8_remove_diacritics {
    my($text) = @_;

    # TODO: just use tr with the unicode characters
    $text =~ s/\x{00C0}/A/g;	# À
    $text =~ s/\x{00C1}/A/g;	# Á
    $text =~ s/\x{00C2}/A/g;	# Â
    $text =~ s/\x{00C3}/A/g;	# Ã
    $text =~ s/\x{00C5}/A/g;	# Å
    $text =~ s/\x{00C7}/C/g;	# Ç
    $text =~ s/\x{00C9}/E/g;	# É
    $text =~ s/\x{00CA}/E/g;	# Ê
    $text =~ s/\x{00CD}/I/g;	# Í
    $text =~ s/\x{00D1}/N/g;	# Ñ
    $text =~ s/\x{00D3}/O/g;	# Ó
    $text =~ s/\x{00D4}/O/g;	# Ô
    $text =~ s/\x{00DA}/U/g;	# Ú
    $text =~ s/\x{00DC}/U/g;	# Ü
    $text =~ s/\x{00E0}/a/g;	# à
    $text =~ s/\x{00E1}/a/g;	# á
    $text =~ s/\x{00E2}/a/g;	# â
    $text =~ s/\x{00E3}/a/g;	# ã
    $text =~ s/\x{00E4}/a/g;	# ä
    $text =~ s/\x{00E5}/a/g;	# å
    $text =~ s/\x{00E7}/c/g;	# ç
    $text =~ s/\x{00E8}/e/g;	# è
    $text =~ s/\x{00E9}/e/g;	# é
    $text =~ s/\x{00EA}/e/g;	# ê
    $text =~ s/\x{00EB}/e/g;	# ë
    $text =~ s/\x{00EC}/i/g;	# ì
    $text =~ s/\x{00ED}/i/g;	# í
    $text =~ s/\x{00EE}/i/g;	# î
    $text =~ s/\x{00EF}/i/g;	# ï
    $text =~ s/\x{00F0}/o/g;	# ð
    $text =~ s/\x{00F1}/n/g;	# ñ
    $text =~ s/\x{00F2}/o/g;	# ò
    $text =~ s/\x{00F3}/o/g;	# ó
    $text =~ s/\x{00F4}/o/g;	# ô
    $text =~ s/\x{00F6}/o/g;	# ö
    $text =~ s/\x{00F9}/u/g;	# ù
    $text =~ s/\x{00FA}/u/g;	# ú
    $text =~ s/\x{00FC}/u/g;	# ü
    $text =~ s/\x{00FD}/y/g;	# ý
    $text =~ s/\x{0101}/a/g;	# ā
    $text =~ s/\x{0107}/c/g;	# ć
    $text =~ s/\x{010D}/c/g;	# č
    $text =~ s/\x{0144}/n/g;	# ń
    $text =~ s/\x{015F}/s/g;	# ş
    $text =~ s/\x{0160}/S/g;	# Š
    $text =~ s/\x{016B}/u/g;	# ū
    $text =~ s/\x{1F78}/o/g;	# ὸ

    # TODO: convert hexview.perl to use helper routine placed in extra.perl
    if ($debug_level >= &TL_MOST_VERBOSE) {
	&debug_out(-1, "hex in: %s\n", &run_command_over("hexview.perl - <", "@_"));
	&debug_out(-1, "hex out: %s\n", &run_command_over("hexview.perl - <", $text));
    }
    &debug_print(&TL_VERY_VERBOSE, "utf8_remove_diacritics(@_) => '$text'\n");

    return ($text);
}

# Determine whether text represents a valid number: [-]NNN.NNN[e[+-]N]
# note: the number can be embedded in whitespace
#
# EX: is_numeric("5.3e10") => 1
# EX: is_numeric("0") => 1
# EX: is_numeric("five") => 0
# EX: is_numeric("0.760202956099713") => 1
# EX: is_numeric("-5") => 1
#
sub is_numeric {
    my($text) = @_;
    my($ok) = &FALSE;

    if ((length($text) > 0) 
	&& ($text =~ /\d+/)
	&& ($text =~ /^\s*-?\d*\.?\d*(e[+-]?\d+)?\s*$/i)) {
	$ok = &TRUE;
    }
    &debug_print(&TL_VERY_VERBOSE, "is_numeric(@_) => $ok\n");

    return ($ok);
}

# round(number, [decimal places])
#
# Rounds the number to the specified number of decimal places, usually 3.
#
sub round {
    my($number, $places) = @_;
    $places = $::precision if (!defined($places));
    my($format) = "%.${places}f";
    my($result) = sprintf($format, $number);
    &debug_print(&TL_ALL, "round($number, [$places]) => $result\n");
    return ($result);
}

# round_all(list, [decimal places])
#
# Rounds all the numbers to the specified number of decimal places.
#
sub round_all {
    return (map { &round($_) } @_);
}

# remove_dir(full_file_name): removes the directory component from the file
# and returns the base name.
#
# Notes: 
# - See dirname() for function to return directory name
# - This is a misnomer and eventually will be renamed.
# - The last component of the path is treated as a file even if a directory itself.
#
# EX: remove_dir("../notes.text") => "notes.text"
# EX: remove_dir("/usr") => "usr"
# EX: remove_dir("/usr/") => "usr"
# EX: remove_dir("/usr/.") => "."
#
sub remove_dir {
    my($file) = @_;

    $file =~ s/[$PD]$//;		# chop off extraneous trailing path delim
    $file =~ s/^\.?\.?[$PD]//;		# chop off relative part of directory
    $file =~ s/^.*[$PD]//;		# chop off directory prefix

    &debug_print(&TL_VERY_VERBOSE, "remove_dir(@_); path_delim=$path_delim => $file\n");

    return ($file);
}

# remove_dirname(path): alias for remove_dir
#
sub remove_dirname {
    return (&remove_dir(@_));
}


# make_path(base_directory, file_component, ...)
#
# Appends the filename(s) to the directory name to form a full-path file
# specification. If the filename begins with an absolute directory spec
# (eg, /home/joe/my.data) it is removed (eg, my.data).
# EX: make_path("/home/jane", "/home/joe/my.data") => "/home/jane/my.data"
# EX: make_path("/home/tomohara/bin/test-results", "..") => "/home/tomohara/bin/test-results/.."
#
sub make_path {
    my($dir, @file_components) = @_;
    my($delim) = &DELIM;
    &debug_print(&TL_MOST_VERBOSE, "make_path(@_)\n");
    my($file);

    # All but the first component should not specify absolute paths
    # TODO: remove this check
    foreach $file (@file_components) {
	$file = &remove_dir($file) if ($file =~ /^[$PD]/);
    }

    my($path) = $dir;
    $path .= $delim unless ($path =~ /[$PD]$/);
    $path .= join($delim, @file_components);

    # Make sure Unix pathnames are not used under CygWin with -force_WIN32 in effect
    if ($unix && &use_WIN32 && ($path =~ /\//)) {
	$path = &run_command("cygpath.exe -w '$path'", &TL_MOST_VERBOSE);
    }

    &debug_print(&TL_MOST_DETAILED, "make_path(@_) => $path\n");

    return ($path);
}

# make_full_path(filename)
#
# Returns the fully-specified pathname to the file.
# NOTE: Under CygWin the Win32 version of the path is used to avoid problems
# with programs not compiled under CygWin (e.g., java).
# TODO: rename to return_full_path
#
sub make_full_path {
    my($file) = @_;
    &debug_print(&TL_MOST_VERBOSE, "make_full_path(@_): path_delim='$path_delim'\n");

    # Get directory name from path, resolve it to full path and add back to path
    my($dir) = &dirname($file);
    $file = &remove_dir($file);
    $file = &make_path($dir, $file);
    
    &debug_print(&TL_MOST_DETAILED, "make_full_path(@_) => $file\n");
    return ($file);
}

# asctime(): return the time formatted as with the asctime library function
#
sub asctime {
    return (scalar localtime);
}

# filter_warnings(warning_text)
#
# Filter benign warnings.
# NOTE: Perl by-passes the __WARN__ signal handling when -w option is used
#
sub filter_warnings {
    &debug_print(&TL_USUAL, "filter_warnings(@_)\n");
    printf STDERR "@_\n";
}

# This is just a no-op function used for referencing variables that might
# be defined in other modules.
#
sub NO_OP { &FALSE; }

sub reference_vars { &NO_OP; }

sub reference_var { &NO_OP; }


# Standard C library constants for locking
# TODO: use a package for these and for lock()/unlock()
sub LOCK_SH { 1; }
sub LOCK_EX { 2; }
sub LOCK_NB { 4; }
sub LOCK_UN { 8; }

# lock(file_handle): locks the specified file for exclusive access
# Based on Perl help for flock.
#
sub lock {
    my($file_handle) = @_;

    flock($file_handle, &LOCK_EX);
}

# unlock(file_handle): unlocks the specified file
# Based on Perl help for flock.
#
sub unlock {
    my($file_handle) = @_;

    flock($file_handle, &LOCK_UN);
}

# word_count(text): returns the number of words in the text
#
sub word_count {
    my($text) = @_;
    my(@words) = &tokenize($text);

    return (1 + $#words);
}

# boolean(expression): returns integer boolean value for expression
# 1 iff true, otherwise 0
# note: this converts Perl's use of undefined or "" to 0
# EX: boolean(undef) => "0"
#
sub boolean {
    my($expression) = @_;
    $expression = &FALSE if (!defined($expression));
    my($boolean_value) = ($expression ? 1 : 0);
    &debug_print(&TL_MOST_VERBOSE, "boolean($expression) => $boolean_value\n");
    return ($boolean_value);
}

# indent(text, [indentation]): indent all lines in text specifed indenation
# string (4 spaces by default)
# EX: indent("veni\nvidi\nvici\n") => "    veni\n    vidi\n    vici\n"
#
sub indent {
    my($text, $indentation) = @_;
    $indentation = "    " if (!defined($indentation));
    
    $text =~ s/([^\n]+)\n/$indentation$1\n/g;

    return ($text);
}

# mean(values): computes the mean of a list of numbers
# EX: mean(1, 2, 3, 4, 5, 6) => 3.5
#
sub mean {
    my(@values) = @_;
    my($num) = (scalar @values);
    my($sum) = 0;

    map { $sum += $_; } @values;
    my($mean) = ($num > 0) ? ($sum / $num) : 0.0;
    &debug_print(&TL_DETAILED, "mean(@_) => $mean\n");
    
    return ($mean);
}

# stdev(values): computes standard deviation of a list of numbers
#      squareroot( \sum(x - mean)^2 / (N - 1))
# EX: round(stdev(1, 2, 3, 4, 5, 6)) => 1.871
#
sub stdev {
    my(@values) = @_;
    my($num) = (scalar @values);

    # Compute sample mean
    my($mean) = &mean(@values);

    # Compute sample standard deviation
    my($sum_sq_mean_diff) = 0.0;
    map { $sum_sq_mean_diff += ($_ - $mean) ** 2; } @values;
    my($stdev) = ($num > 1) ? sqrt($sum_sq_mean_diff / ($num - 1)) : 0.0;
    &debug_print(&TL_DETAILED, "stdev(@_) => $stdev\n");

    return ($stdev);
}

# get_file_ddmmmyy(file): returns FILE's date in DDmmmYY format (e.g., 31mar22).
# note: keep date in synch with tomohara-aliases.perl
# TODO: fix me: returns current year 2022 as ddmmm71 (i.e., 1971)!
#
sub get_file_ddmmmyy {
    my($filename) = @_;
    &debug_print(6, "get_file_ddmmmyy($filename)\n");

    # Get the local time structure
    my($atime, $mtime, $ctime, $blksize, $blocks) = stat($filename);
    &debug_print(6, "file stat: ($atime, $mtime, $ctime, $blksize, $blocks)\n");
    my($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($mtime);
    &debug_print(6, "localtime: ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)\n");

    # Format it as ddMMMyy (e.g., 29mar22)
    my(@months) = ( "jan", "feb", "mar", "apr", "may", "nun",
		    "jul", "aug", "sep", "oct", "nov", "dec" );
    my($ddmmmyy) = sprintf "%02d%s%02d", $mday, $months[$mon], $year;
    &debug_print(5, "get_file_ddmmmyy($filename) => $ddmmmyy\n");

    return ($ddmmmyy);
}

#------------------------------------------------------------------------------

# Initialization: invoke init_common & return 1 to indicate success
# in the package loading.

&init_common();
&assert(&TRUE != &FALSE);
1;
