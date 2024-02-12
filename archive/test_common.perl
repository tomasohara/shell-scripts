
$verbose = 0 unless (defined($verbose));

&do_unit_tests();
exit;

# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# common.perl
#
# Common perl routines (variables & constants)
#
# TODO: add routine to dump current line
#       have common.pm be a wrapper around this
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
# Fall 1997
# Tom O'Hara
# New Mexico State University
#
# Revised 1999+
# Tom O'Hara
# Cycorp Inc.
#
# TODO:
# - add additional common arguments like -verbose (e.g., -para)
# - change the assumed baseline Perl version from Perl 4.031 to Perl 5
# - make sure that global variables such as delim don't conflict with
#   user variables
# - use debug_print unless formatted I/O needed
# - use my instead of local unless old-style references assumed
# - get rid of old-style reference usages 
#   (e.g., 'local(*array) = @_;' => 'my($array_ref) = @_;')
# - revise the function synopsis
# - put extraneous stuff in extra.perl
# - track down other scripts that are redundantly initializing $TEMP, etc.
#
# Portions Copyright (c) 1997 - 1999 Tom O'Hara
# Portions Copyright (c) 1999 - 2001 Cycorp, Inc.  All rights reserved.
#
#
#------------------------------------------------------------------------
# Function synopsis:
# append_entry(array, key, text): Append to the value of an associative array by the given text.
# asctime(): return the time formatted as with the asctime library function
# assert(quoted_expression) Issues an error message if the expression evaluates to 0.
# basename(filename, extension): returns the filename w/o the extension.
# blocking_stding():	determine whether input from STDIN would block
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
# trace_array(array_ref, [debug_level])  Outputs the (list) array to the trace file, unless current debug   level is lower than specified trace level.
# trace_assoc_array(associative_array_ref, [debug_level])  Outputs the associative array to the trace file, unless current debug   level is lower than specified trace level.
# trim(text):		removes leading and trailing whitespace
# unlock(*FILE):	unlocks the specified file
# write_file(file_name, text): Writes the text to the specified file.
#

    $initialized = &FALSE if (!defined($initialized));
    # Set debugging level to either $d, DEBUG_LEVEL evironment variable or 3 (the default)
    $debug_level = ($d || $ENV{"DEBUG_LEVEL"} || &TL_USUAL);
    ## $debug_line_num = 0;
    
    # Initialization of important constants
    # TODO: move miscellaneous initializations into &init_common
    $script_dir = ".";
    $script_name = $0;
    $TRUE = 1;
    $FALSE = 0;
    $MAXINT = 2147483647;
    &init_var(*disable_commands, $FALSE);
    $under_WIN32 = &FALSE;
    my($unix) = (! $under_WIN32);
    $delim = "\/";
    
    # Temporary directory location
    # TMP: system temporary directory
    # TEMP: either $TMP or current directory if debugging
    $TMP = "/tmp/" if !defined($TMP);
    $TEMP = (&DETAILED_DEBUGGING ? &pwd() : $TMP);
    ## local($TEMP);
    ## &init_var(\$TEMP, ($unix ? "/tmp/" : "C:\\TEMP\\"));
    
    # Common arguments for the scripts using common.perl
    #
    my($common_options) = "[-verbose]";
    &init_var(*precision, 3);	# default number of decimal places for rounding
    &init_var(*verbose, &FALSE);	# verbose output mode
    #

sub COMMON_OPTIONS { $common_options; }

# NOTE: stupid Perl: the __WARN__ signal is disabled when the -w switch is used
# Also, this doesn't seem to trap warnings due to command-line variables,
## $SIG{__WARN__} = 'filter_warnings';

# Define constants
sub TRUE { 1; }
sub FALSE { 0; }
sub MAXINT { $MAXINT; }
sub MININT { -$MAXINT; }
sub MAXIMUM_INTEGER { $MAXINT ; }

sub DELIM { $delim; }
sub under_WIN32 { $under_WIN32; }
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
sub TL_ALL {9;}			# all debugging output

sub DEBUG_LEVEL {$debug_level;};
sub DEBUGGING { return ($debug_level >= TL_USUAL) };
sub DETAILED_DEBUGGING { return ($debug_level > TL_DETAILED) };

sub SCRIPT_DIR {$script_dir;};
sub TEMP_DIR {$TEMP;};

&assert(&TRUE != &FALSE);


# NOTE: uncomment the following to help track down undeclared variables.
# Be prepared for a plethora of warnings. One that is important is
#    'Global symbol "xyz" requires explicit package name'
# when NOT preceded by 'Global symbol "xyz" requires explicit package name'
#
# use strict 'vars';


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
    $debug_level = ($d || $ENV{"DEBUG_LEVEL"} || &TL_USUAL);
    ## $debug_line_num = 0;
    
    # Initialization of important constants
    # NOTE: redundant initializations as above due to unit testing problem with
    # test-perl-examples.perl
    $script_dir = ".";
    $script_name = $0;
    $TRUE = 1;
    $FALSE = 0;
    $MAXINT = 2147483647;
    &init_var(*disable_commands, $FALSE);
    $under_WIN32 = &FALSE;
    my($unix) = (! $under_WIN32);
    $delim = "\/";
    
    # Temporary directory location
    # TMP: system temporary directory
    # TEMP: either $TMP or current directory if debugging
    $TMP = "/tmp/" if !defined($TMP);
    $TEMP = (&DETAILED_DEBUGGING ? &pwd() : $TMP);
    ## local($TEMP);
    ## &init_var(\$TEMP, ($unix ? "/tmp/" : "C:\\TEMP\\"));
    
    # Common arguments for the scripts using common.perl
    #
    my($common_options) = "[-verbose]";
    &init_var(*precision, 3);	# default number of decimal places for rounding
    &init_var(*verbose, &FALSE);	# verbose output mode

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

    # See if running under Windows NT or Win95
    # note: OSTYPE normally not set in this case
    &init_var(*OSTYPE, "???");		# Unix operating system type
    &init_var(*OS, "???");		# Windows operating system
    if ($OSTYPE eq "???") {
	$under_WIN32 = &TRUE;
	$redirect = ($debug_level > 3);
    }

    # Determine the directory for the scripts
    ## $script_dir = $0;
    ## $script_dir =~ s/\/[^\/]*$/\/./;	    # chop off the file name
    ## $script_name = $0;
    ## $script_name =~ s/\.?\.?\/?.*\///;	    # chop off the directory
    local($D) = "/";			    # path delimiter (os-specific)
    if ($OS eq "Windows_NT") {
	# NOTE: Perl5 under Win95 seems to behave like Unix
	$under_WIN32 = &TRUE;
	if ($OSTYPE eq "cygwin") {
	    $unix = &TRUE;
	}
	else {
	    $D = "\\\\";			    # TODO: check for Win32 env setting
	    $delim = "\\";
	}
    }
    $script_dir = $0;
    $script_dir =~ s/$D[^$D]*$/$D./;	    # chop off the file name
    $script_name = $0;
    $script_name =~ s/\.?\.?$D?.*$D//;	    # chop off the directory

    # Determine temporary directory
    &init_var(*TEMP, ($unix ? "/tmp/" : "C:\\TEMP\\"));
    $TEMP .= $delim unless ($TEMP =~ /$delim$/);

    if ($debug_level > 3) {
	select(STDERR); $| = 1;		    # set stderr unbuffered
	select(STDOUT); $| = 1;		    # set stdout unbuffered
    }

    # Redirect stdout to file specified with -o option
    if (defined($o)) {
	&debug_out(&TL_VERY_DETAILED, "redirecting STDOUT to $o\n");
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

    # Trace out a few values
    my($args) = join(" ", @ARGV);
    &debug_print(&TL_VERY_VERBOSE, "$0 @ARGV\n");
    &debug_out(&TL_VERBOSE, "starting $script_name %s [%s]\n", $args, &get_time());
    ## &debug_out(&TL_DETAILED, "$0 $args\n");
    &debug_out(&TL_VERBOSE, "debug_level=$debug_level; #ARGV=$#ARGV; script_dir=$script_dir d=$D\n");
    &debug_print(&TL_VERBOSE, "OS=$OS; OSTYPE=$OSTYPE; under_WIN32=$under_WIN32; Unix=$unix\n");
    &trace_array(*ARGV, &TL_VERY_DETAILED);
    &trace_array(\@INC, &TL_MOST_DETAILED);

    $initialized = &TRUE;

    return ($initialized);
}

# cleanup_common(): module termination cleanup routine
# NOTE: This must be explicitly invoked.
#
# TODO: see if there's a way to invoke it automatically
#
sub cleanup_common {
    &debug_out(&TL_VERBOSE, "ending $script_name: %s\n", &get_time());
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
    local($var, $default, $trace_level) = @_;
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
    local($var, $value, $trace_level) = @_;
    $trace_level = &TL_VERY_VERBOSE unless (defined($trace_level));

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
# TODO:
# - Use a more intuitive way of disabling commands
#
sub ALWAYS_RUN { &FALSE };
#
sub run_command {
    my($command, $trace_level, $disable) = @_;
    $trace_level = &TL_VERBOSE+1 unless (defined($trace_level));
    $disable = $disable_commands unless (defined($disable));
    my($result) = "";

    # See if system commands have been disabled (for testing purposes)
    if ($disable) {
	&debug_out($trace_level - 1, "(disabled) run_command: %s\n", $command);
	return ("");
    }

    &debug_out($trace_level, "run_command: %s\n", $command);
    open(RUN_COMMAND_FILE, "$command|");
    while (<RUN_COMMAND_FILE>) {
	$result .= $_;
    }
    chop $result unless ($result !~ /\n$/);
    close(RUN_COMMAND_FILE);
    &debug_out($trace_level+1, "run_command => {\n%s\n}\n", $result);

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
# Run's the specified command using the data as input.
# NOTE: The commmand is assumed to take a file name as the last input. A
# temporary file is created for this purpose, which uses a unique ID and
# is retained during debugging.
#
my($run_num) = 0;
sub run_command_over {
    my($command, $input, $trace_level) = @_;
    $trace_level = &TL_VERBOSE+1 unless (defined($trace_level));
    my($temp_file) = sprintf "%s%s.%d.%d", &TEMP_DIR, "temp_run_command", $$, $run_num++;
    &write_file($temp_file, $input);
    my($result) = &run_command(sprintf "%s %s", $command, $temp_file, $trace_level);
    unlink $temp_file unless (&DEBUG_LEVEL > &TL_VERBOSE);
    return ($result);
}

# issue_command(command_line, [trace_level])
#
# Issue the specified command and ignores the result.
#
# NOTE: Command execution is disabled with $disable_commands = &TRUE
#
sub issue_command {
    local($command, $trace_level) = @_;
    $trace_level = &TL_DETAILED unless (defined($trace_level));
    local($result);

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
sub issue_command_over {
    my($command, $input) = @_;
    my($temp_file) = sprintf "%s%s.%d.%d", &TEMP_DIR, "temp_run_command", $$, $issue_num++;
    &write_file($temp_file, $input);
    my($result) = &issue_command(sprintf "%s %s", $command, $temp_file);
    unlink $temp_file unless (&DEBUG_LEVEL > &TL_VERBOSE);
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
    local($level, $format_text, @args) = @_;
    if ($level <= $debug_level) {
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
# TODO: rename debug_out as debug_out_fmt and debug_out_new and debug_out
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

# error_out(format_string, argument, ...)
#
# Prints a formatted error message to STDERR
#
sub error_out {

    &debug_out(&TL_ERROR, "ERROR: ");
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
    &debug_out(&TL_WARNING, "WARNING: ");
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
# Note the expression can be quoted so that the assertion violation
# can show the expression that failed as well as the file and line number.
# Unfortunately, this only works for global variables
# (i.e., using local instead of my).
#
# example: &assert('(scalar @all_senses) == (scalar @singleton_senses)');
#
# TODO:
# - have version that doesn't evaluate the expression
# - show the assertion text via `tail +LINE FILE | head -1`
#
sub assert {
    my($expression) = @_;
    &debug_print(&TL_VERBOSE+4, "my assert(@_)\n");

    # Determine the package to use for the evaluation environment,
    # as well as the filename and line number for the assertion call.
    my($package, $filename, $line) = caller;

    # Evaluate the expression in the caller's package
    &debug_out_new(&TL_VERBOSE+4, "eval: 'package $package; $expression;'\n");
    my($result) = eval("package $package; $expression;");

    # If failed, then display the failed expression along with it's
    # filename and line number (as in the assert macro for C).
    if (!defined($result) || ($result eq "0")) {
	print STDERR "*** Assertion failed: $expression [$filename: $line] (input line=$.)\n";
    }
    else {
	&debug_print(&TL_VERBOSE+4, "result: $result\n");
    }
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
    local($line, $level) = @_;
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
    local(*assoc_array, $trace_level, $label) = @_;
    $trace_level = &TL_VERBOSE + 2 if (!defined($trace_level));
    $label = *assoc_array if (!defined($label));

    if ($trace_level <= &DEBUG_LEVEL) {
	local($key);
	&debug_out($trace_level, "%s: {\n", $label);
	foreach $key (sort(keys(%assoc_array))) {
	    &debug_out($trace_level, "\t%s: %s\n", $key, $assoc_array{$key});
	}
	&debug_out($trace_level, "\t}\n");
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
# Outputs the (list) array to the trace file, unless current debug 
# level is lower than specified trace level.
#
sub trace_array {
    local(*array, $trace_level, $label) = @_;
    $trace_level = &TL_VERBOSE + 2 if (!defined($trace_level));
    $label = *array if (!defined($label));

    if ($trace_level <= &DEBUG_LEVEL) {
	local($i);
	&debug_out($trace_level, "%s: ", $label);
	for ($i = 0; $i <= $#array; $i++) {
	    &debug_out($trace_level, "%d:'%s' ", $i, $array[$i]);
	}
	&debug_out($trace_level, "\n");
    }

    return;
}


# blocking_stding():	determine whether input from STDIN would block
#
sub blocking_stdin {
    local ($blocked) = &FALSE;
    local ($flags);

    # Stupidity: non-uniform support for fcntl
    if ($under_WIN32) {
	return 0;
    }
    $perl5 = ($] =~ /^5/);
    eval "use Fcntl;" if ($perl5);
    eval "require 'sys/fcntl.ph';" if (!$perl5);

    # fcntl() performs a variety of functions on open descriptors:
    #
    # F_GETFL        Get descriptor status flags (see fcntl(5) for
    #                definitions).
    #
    $flags = fcntl(STDIN, &F_GETFL, 0);
    &debug_out(&TL_VERY_VERBOSE, "fcntl(STDIN, &F_GETFL, 0) => $flags\n");
    if (($flags eq "2") || ($flags eq "8194")) {
	$blocked = &TRUE;
    }

    return ($blocked);
}

# init_var(variable_name, initial_value, [export=TRUE])
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
# The automatic creation of environment variables can lead to subtle problems
# with other scripts that rely upon environemt variables.
#
# TODO:
# Use some convention (e.g., option_<NAME>) to avoid inadvertant  conflicts.
#
sub EXPORT {&TRUE;}

sub init_var {
    local (*var, $value, $export) = @_;
    $export = &TRUE if (!defined($export));

    # Determine the environment variable name, which the variable w/o the package 
    # specifier (eg, "*main::use_random_coords" => "use_random_coords").
    # TODO: Use some convention to avoid clash w/ common env vars ???
    #       Maintain the package spec ???
    local($env_var) = *var;
    $env_var =~ s/^.*:://;
    my($new_value);

    if (!defined($var)) {
	# Get the value of the corresponding environment variable, if set.
	$new_value = &get_env($env_var, $value, &TL_VERBOSE+2);
	$var = $new_value;
    }
    else {
	$new_value = $var;
    }

    # Update the environment variable to the value, useful for automatic
    # transfer of parameter values to perl scripts invoked by this script.
    if ($export) {
	local($env_var) = *var;
	$env_var =~ s/^.*:://;
	&set_env($env_var, $new_value, &TL_VERY_VERBOSE);
    }
    &debug_out(&TL_DETAILED + 1, "init_var(%s, %s): %s=%s\n", 
	       *var, $value, *var, $var);
}


# min(x, y): returns minimal numeric value
#
sub min {
    local ($x, $y) = @_;

    return ($x < $y ? $x : $y);
}


# max(x, y): returns maximal numeric value
#
sub max {
    local ($x, $y) = @_;

    return ($x > $y ? $x : $y);
}


# write_file(file_name, text)
#
# Writes the text to the specified file.
#
sub write_file {
    local($file_name, $text) = @_;
    &debug_out(&TL_VERBOSE, "write_file($file_name, _)\n");
    &debug_out(&TL_VERBOSE+3, "text={\n%s}\n", $text);

    if (!open(WRITE_FILE, ">$file_name")) {
	&debug_out(&TL_ERROR, "unable to create $file_name ($!)\n");
	return;
    }
    print WRITE_FILE $text;
    close(WRITE_FILE);

    return;
}

# append_file(file_name, text)
#
# Appends the text to the specified file.
#
sub append_file {
    local($file_name, $text) = @_;
    &debug_out(&TL_VERBOSE, "append_file($file_name, _)\n");
    &debug_out(&TL_VERBOSE+3, "text={\n%s}\n", $text);

    if (!open(WRITE_FILE, ">>$file_name")) {
	&debug_out(&TL_ERROR, "unable to append to $file_name ($!)\n");
	return;
    }
    print WRITE_FILE $text;
    close(WRITE_FILE);

    return;
}

# find_library_file(file_name)
#
# Searches the Perl library directories for the file and returns the full pathname
# TODO: add the current directory to the path???
#
sub find_library_file {
    my($file) = @_;
    my($pathname) = $file;
    my($dir);
    foreach $dir (@INC) {
	my($test_pathname) = &make_path($dir, $file);
	if (-e $test_pathname) {
	    $pathname = &make_full_path($test_pathname);
	    last;
	}
    }
    &debug_out(&TL_VERBOSE, "find_library_file($file) => $pathname\n");

    return ($pathname);
}

# read_file(file_name)
#
# Reads in the entire file, and returns the data as a text string.
#
sub read_file {
    local($file_name) = @_;
    local($text) = "";
    &debug_out(&TL_DETAILED, "read_file($file_name)\n");

    if (!open(READ_FILE, "<$file_name")) {
	&error_out("unable to read $file_name ($!)\n");
	return ($text);
    }

    &reset_trace();
    while (<READ_FILE>) {
	&dump_line($_, &TL_VERBOSE+3);
	$text =~ s/\r//;	# ignore DOS carriage returns
	$text .= $_;
    }
    close(READ_FILE);
    &debug_out(&TL_VERBOSE+4, "text={\n$text}\n");

    return ($text);
}


# intersection(list1, list2)
#
# Returns the intersection of the two lists (passed as references).
# This sorts the files, and then scans both lists for equal entries.
# TODO: have option for difference(list1, list2), etc.
#
sub intersection {
    local(*list1, *list2) = @_;
    local(@list) = ();
    local($num) = 0;
    local($i, $j);
    &debug_out(&TL_VERBOSE+2, "intersection(%s, %s)\n", *list1, *list2);

    # Sanity check for well-defined arrays
    # note: desiabled since it doesn't account for empty lists
    ## &assert('defined(@list1) && defined(@list2)');

    # Sort the two lists
    local(@sort1) = sort(@list1);
    local(@sort2) = sort(@list2);

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
    local($debug_result) = "intersection((@list1), (@list2)) =>\n(@list)\n";
    &assert('(1 + $#list) <= ((1 + $#list1) + (1 + $#list2))');
    &debug_out(&TL_VERBOSE+3, "%s", $debug_result);

    return (@list);
}


# new_intersection(list1, list2): returns intersection of the two lists
# without sorting them and while preserving the order of the terms in the first list
#
sub new_intersection {
    my($list1_ref, $list2_ref) = @_;
    &debug_out(&TL_VERBOSE+2, "new_intersection(@_)\n");
    my(%seen);
    my($item);
    
    # Tag each item in the second list as seen
    map { $seen{$_} = &TRUE; } @$list2_ref;

    # Get those items not see
    my(@list) = grep (defined($seen{$_}), @$list1_ref);
    &debug_out(&TL_VERBOSE+3, "intersection((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

    return (@list);
}

# difference(list1, list2)
#
# Returns the difference of the two lists (passed as references).
# This sorts the files, and then scans both lists for equal entries.
# TODO: reconcile with intersection (from intersection.perl)
# TODO: preserve the order of the original reference list
# NOTE: the entry's are assumed to not contain the empty string
#
sub difference {
    my($list1_ref, $list2_ref) = @_;
    my(@list);
    my($num) = 0;
    my($i, $j);
    &debug_out(&TL_VERBOSE+2, "difference(@_)\n");

    # Sort the two lists
    local(@sort1) = sort(@$list1_ref);
    local(@sort2) = sort(@$list2_ref);

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
    &debug_out(&TL_VERBOSE+3, "difference((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

    return (@list);
}

# new_difference(list1, list2): returns difference of the first list versus the second
# without sorting and while preserving the order of the terms
#
sub new_difference {
    my($list1_ref, $list2_ref) = @_;
    &debug_out(&TL_VERBOSE+2, "new_difference(@_)\n");
    my(%seen);
    my($item);
    
    # Tag each item in the second list as seen
    map { $seen{$_} = &TRUE; } @$list2_ref;

    # Get those items not seen
    my(@list) = grep (!defined($seen{$_}), @$list1_ref);
    &debug_out(&TL_VERBOSE+3, "difference((@$list1_ref), (@$list2_ref)) =>\n(@list)\n");

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
    local ($file, $ext) = @_;
    $ext = "" if (!defined($ext));

    $file =~ s/$ext$//;

    return ($file);

}

# basename_proper(file): just return the basename of the file (i.e., no extension
# and no directory)
# EX: basename_proper("/tmp/classification.log") => "classification"
# NOTE: omits the directory unlike &basename
#
sub basename_proper {
    my($file) = @_;

    $file = &remove_dir(&basename($file));
    $file =~ s/\.[^\.]+$//;

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
    $file =~ s/\.[^\.]+$//;
    $file .= $ext;

    return ($file);
}


# pwd: returns the current directory (a la unix pwd command)
#
sub pwd {
    local($PWD) = ($unix ? "pwd" : "cd");
    local($dir);
    
    $dir = &run_command("$PWD", 	# command to run
			&TL_VERBOSE+2, 	# high trace level
			&FALSE); 	# never disabled

    return ($dir);
}


# dirname(file, [is_http])
#
# Return the directory for the file, either from the name itself or the
# current directory.
# note: see remove_dir() for function to return filename
#
sub dirname {
    my($file, $is_http) = @_;
    $is_http = &FALSE if (!defined($is_http));
    my($D) = ($unix ? "/" : "\\\\");
    &debug_out(&TL_VERY_DETAILED, "dirname(@_): is_http=%s; D=%s\n", $is_http, $D);

    # Use the part of the file name before the base name
    my($dir) = ".";
    if ($file =~ /(\.?\.?$D?.*$D).*/) {
	$dir = $1;
    }

    # Use the current directory if no directory given (or if "." used)
    if (($dir eq "") || ($dir eq ".")) {
	$dir = &pwd();
    }
    # Make sure the directory name is absolute
    if (($dir !~ /^$D/) && (! $is_http)) {
	$dir = &make_path(&pwd(), $dir);
    }
    $dir =~ s/\/tmp_mnt//;	# remove temporary NFS file mount directory
    &debug_out(&TL_MOST_DETAILED, "dirname($file) => $dir\n");

    return ($dir);
}

# url_dirname(URL_path): Return the directory for the url path
#
sub url_dirname {
    return (&dirname($_[0], &TRUE));
}

# incr_entry(array, key, [increment=1])
#
# Increment the value of an associative array by the given amount,
# which defaults to 1. The new value is returned.
#
sub incr_entry {
    local (*array, $key, $increment) = @_;
    $increment = 1 if (!defined($increment));
    &debug_print(&TL_ALL, "incr_entry(@_)\n");

    if (!defined($array{$key})) {
	$array{$key} = 0;
    }
    $array{$key} += $increment;

    return ($array{$key});
}

# append_entry(array, key, text)
#
# Append to the value of an associative array by the given text.
#
sub append_entry {
    local (*array, $key, $text) = @_;
    &debug_print(&TL_ALL, "append_entry(@_)\n");

    if (!defined($array{$key})) {
	$array{$key} = "";
    }
    $array{$key} .= $text;
}

# get_entry(array, key, [default=0])
#
# Get the value for the key in the associative array, using the given 
# default if no corresponding entry.
#
sub get_entry {
    my($array_ref, $key, $default) = @_;
    $default = 0 if (!defined($default));
    local ($value) = $default;

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
#
sub set_entry {
    local (*array, $key, $value) = @_;
    &debug_out_new(&TL_ALL, "set_entry(@_)\n");
    
    $array{$key} = $value;

    return;
}

# tokenize (text, [split_pattern="\\s+"])
#
# Returns the list of whitespace-delimited tokens from the text
# EX: &tokenize("my dog has fleas") => ("my", "dog", "has", "feas")
#

sub tokenize {
    my($text, $split_pattern) = @_;
    $split_pattern = "\\s+" if (!defined($split_pattern));

    # Trim whitespace and then segment based on the intermediate whitespace
    $text = &trim($text);
    local (@tokens) = split(/$split_pattern/, $text);
    &debug_print(&TL_MOST_DETAILED, "tokenize($text) => (@tokens)\n");

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
    local(*array, $item) = @_;
    &find(*array, $item, &TRUE);
}

# remove_duplicates(list): returns list with duplicate elements removed
#
sub remove_duplicates {
    my(@list) = @_;
    &debug_out(&TL_VERY_VERBOSE, "remove_duplicates(@_)\n");
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
# TODO: add warning if the command is not a perl script invocation
# 
sub run_perl {
    local($command_line) = @_;
    
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
    local ($source, $destination) = @_;
    local ($text);

    $text = &read_file($source);
    &write_file($destination, $text);

    return;
}


# trim(text): Removes leading and trailing whitespace
#
sub trim {
    local ($text) = @_;

    # Remove leading and trailing whitespace
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;

    return ($text);
}

# init_punctuation(): initialize data for punctuation stripping
#
my($punctuation_pattern);
#
sub init_punctuation {
    # TODO: figure out regex problem with using the pattern
    $punctuation_pattern = "[\,\.\:\;\!\@\#\\\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\\\]";
    &debug_print(&TL_VERY_VERBOSE, "init_punctuation: pattern = '$punctuation_pattern'\n");
}

# trim_punctuation(text): remove leading or trailing punctuation chars from text
#
sub trim_punctuation {
    my($text) = @_;
    &init_punctuation unless (defined($punctuation_pattern));

    # TODO: use the pattern variable
    # $text =~ s/^${punctuation_pattern}//g;
    # $text =~ s/${punctuation_pattern}$//g;
    $text =~ s/^[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]+//;
    $text =~ s/[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]+$//;
    &debug_print(&TL_VERY_VERBOSE, "trim_punctuation(@_) => $text\n");
    
    return ($text);
}

# remove_punctuation(text): remove any punctuation chars from text
#
sub remove_punctuation {
    my($text) = @_;
    &init_punctuation if (! defined($punctuation_pattern));

    ## $text =~ s/${punctuation_pattern}//g;
    $text =~ s/[\,\.\:\;\!\@\#\$\%\^\&\*\(\)\{\}\[\]\"\'\/\\]//g;
    &debug_print(&TL_VERBOSE, "remove_punctuation(@_) => $text\n");
    
    return ($text);
}

# iso_lower(text): lowercase text accounting for ISO-9660 accents
# TODO: handle the full-range of accents (not just those for Spanish)
#
sub iso_lower {
    local ($text) = @_;

    $text =~ tr/A-ZÁÉÍÓÚÑÜÄËÏÖÜ/a-záéíóúñüäëïöü/;

    return ($text);
}

# iso_lower(text): uppercase text accounting for ISO-9660 accents
# TODO: handle the full-range of accents (not just those for Spanish)
#
sub iso_upper {
    local ($text) = @_;

    $text =~ tr/a-záéíóúñäëïöü/A-ZÁÉÍÓÚÑÜÄËÏÖÜ/;

    return ($text);
}

# to_lower(text): convert text to lowercase
# note: alias for iso_lower
#
sub to_lower {
    local ($text) = @_;

    return (&iso_lower($text));
}


# to_upper(text): convert text to uppercase
# note: alias for iso_upper
#
sub to_upper {
    local ($text) = @_;

    return (&iso_upper($text));
}


# capitalize(text)
#
# Returns the text (or text) capitalized.
# Ex: capitalize("dog") => "Dog"
# EX: capitalize("CAT") => "Cat"
#
sub capitalize {
    local ($text) = @_;

    local($first_char) = substr($text, 0, 1);
    local($rest) = substr($text, 1);
    local($new_text) = &to_upper($first_char) . &to_lower($rest);
    &debug_print(&TL_VERY_VERBOSE, "capitalize($text) => '$new_text'\n");
    
    return ($new_text);
}


# iso_remove_diacritics($text): remove diacritic marks from the text
# TODO: handle the full-range of accents (not just those for Spanish)
#

sub iso_remove_diacritics {
    local ($text) = @_;

    $text =~ tr/ÁÉÍÓÚÑÜáéíóúñü/AEIOUNOaeiounu/;
    ## $key =~ s/[¡!¿?]//; ???

    return ($text);
}

# Determine whether text represents a valid number: [-]NNN.NNN[e[+-]N]
# note: the number can be embedded in whitespace
#
sub is_numeric {
    local($text) = @_;
    local($ok) = &FALSE;

    if ((length($text) > 0) && ($text =~ /^\s*-?\d*\.?\d*(e[+-]\d+)?\s*$/i)) {
	$ok = &TRUE;
    }

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
    return (sprintf $format, $number);
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
# EX: remove_dir("../notes.text") => "notes.text"
#
sub remove_dir {
    my($file) = @_;

    ## my($D) = ($unix ? "/" : "\\\\");
    ## $file =~ s/^\Q\.?\.?$D?.*$D\E//;	    # chop off the directory

    $file =~ s/^\.?\.?$delim//;	    	    # chop off relative part of directory
    $file =~ s/^.*$delim//;		    # chop off directory prefix
    &debug_out(&TL_VERY_VERBOSE, "remove_dir(@_); delim=$delim => $file\n");

    return ($file);
}


# make_path(base_directory, file_component, ...)
#
# Appends the filename(s) to the directory name to form a full-path file
# specification. If the filename begins with an absolute directory spec
# (eg, /home/joe/my.data) it is removed (eg, my.data).
#
sub make_path {
    my($dir, @file_components) = @_;
    my($delim) = &DELIM;
    &debug_out(&TL_MOST_VERBOSE, "make_path(@_): delim='$delim'\n");
    &assert((($delim eq "\\") || ($delim eq "/")));
    my($regex_delim) = "\$delim";
    my($file);

    foreach $file (@file_components) {
	$file = &remove_dir($file) if ($file =~ /^$regex_delim/);
    }
    my($path) = $dir . $delim . join($delim, @file_components);
    &debug_out(&TL_MOST_DETAILED, "make_path(@_) => $path\n");

    return ($path);
}

# make_full_path(filename)
#
# Returns the fully-specified pathname to the file.
# TODO: rename to return_full_path
#
sub make_full_path {
    local($file) = @_;
    &debug_out(&TL_MOST_VERBOSE, "make_full_path(@_): delim='$delim'\n");

    local($dir) = &dirname($file);
    $file = &remove_dir($file);
    $file = &make_path($dir, $file);
    &debug_out(&TL_MOST_DETAILED, "make_full_path(@_) => $file\n");

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
sub reference_vars {
}

sub reference_var {
}

# Standard C library constants for locking
# TODO: use a package for these and for lock()/unlock()
sub LOCK_SH { 1; }
sub LOCK_EX { 2; }
sub LOCK_NB { 4; }
sub LOCK_UN { 8; }

# lock(*FILE): locks the specified file for exclusive access
# Based on Perl help for flock.
#
sub lock {
    local(*FILE) = @_;

    flock(FILE, &LOCK_EX);
}

# unlock(*FILE): unlocks the specified file
# Based on Perl help for flock.
#
sub unlock {
    local(*FILE) = @_;

    flock(FILE, &LOCK_UN);
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
#
sub boolean {
    my($expression) = @_;
    $expression = "" if (!defined($expression));
    my($boolean_value) = ($expression ? 1 : 0);
    &debug_print(&TL_MOST_VERBOSE, "boolean($expression) => $boolean_value\n");
    return ($boolean_value);
}

#------------------------------------------------------------------------------

# Initialization: invoke init_common & return 1 to indicate success
# in the package loading.

&init_common();
1;

#========================================================================

# verify_test(test_expression, result): check whether TEST_EXPRESSION evaluates
# to RESULT. If not, issue an error report.
#
sub verify_test {
    my($test, $desired_result) = @_;
    print STDERR "Testing '$test'\n" if ($verbose);

    # Get the result in format compatible with desired result
    my($result);
    if ($desired_result =~ /^\s*\(/) {
	# Re-evaluate test expression as list
	# TODO just evaluate once
	my(@result) = eval $test;

	# `Quote strings elements, and then add comma's in string list
	@result = grep { s/([^\d\s]+\w+)/\"\1\"/g; } @result;
	$result = "(" . join(", ", @result) . ")";
    }
    else {
	$result = eval $test;			# evaluate as scalar
    }


    # Compare versus desired result (via eval for extra flexibility)
    $result = "$@" if (!defined($result));
    if (($result ne $desired_result) 
	&& ($result ne (eval $desired_result))) {
	print STDERR "Test failed: $test => $desired_result [result=$result]\n";
    }
    elsif ($verbose) {
	print STDERR "Test passed: $test => $desired_result\n";
    }
}

sub do_unit_tests {

    &verify_test("init_common()", "1");
    &verify_test("basename(\"classification.log\", \".log\")", "\"classification\"");
    &verify_test("basename(\"classification.log\")", "\"classification.log\"");
    &verify_test("basename_proper(\"/tmp/classification.log\")", "\"classification\"");
    &verify_test("replace_extension(\"README.NOW\", \".LATER\")", "\"README.LATER\"");
    &verify_test("(set_entry(\\%part_of_speech_num, \"SimpleNoun\", 3), \$part_of_speech_num{\"SimpleNoun\"})", "3");
    &verify_test("&tokenize(\"my dog has fleas\")", "(\"my\", \"dog\", \"has\", \"feas\")");
    &verify_test("capitalize(\"dog\")", "\"Dog\"");
    &verify_test("capitalize(\"CAT\")", "\"Cat\"");
    &verify_test("remove_dir(\"../notes.text\")", "\"notes.text\"");
}
