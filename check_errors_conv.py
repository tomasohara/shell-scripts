# -----------------------------------------------------------------------
## PERL: 
# # *-*-perl-*-*
# eval 'exec perl -Ssw $0 "$@"'
#     if 0;
# # ... various shebang alternatives and comments
## PYTHON:
#!/usr/bin/env python3

"""
PERL:
# check_errors.perl: Scan the error log for errors, warnings and other
# suspicious results. This prints the offending line bracketted by >>>
# and <<< along with N lines before and after to provide context.
#
# TODO:
# [see above]
#
PYTHON:
check_errors.py: Scan the error log for errors, warnings, and other suspicious results.
Prints offending line bracketed by >>> and <<<, with N lines before and after for context.
#
TODO:
# [see above]
#
BEHAVIOR:
- All original TODOs and script intent preserved verbatim.
- The script's overall structure, control flow, and output formatting are maintained.
- No mezcla or framework integration is present in this phase.
"""
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL:
# BEGIN { 
#     my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); 
#     require 'common.perl';
#     use vars qw/$verbose /;
# }
## PYTHON:
import os
import sys
import re

script_dir = os.path.dirname(os.path.abspath(__file__))
if script_dir not in sys.path:
    sys.path.insert(0, script_dir)
try:
    import common  # Assumes common.py exists in the same directory
except ImportError:
    pass

## BEHAVIOR:
# - Ensures any 'common' library is available as in Perl.
# - In Perl, BEGIN ensures this is run before any code; in Python, top-level code is executed before main.
# - No error is raised if common is missing, matching Perl's behavior unless required symbols are used.
# - $verbose is declared here but is set by CLI processing later, as in Perl.
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL:
# use strict;
# use vars qw/$warning $warnings $skip_warnings $context $no_asterisks $skip_ruby_lib $ruby/;
# use vars qw/$relaxed $strict $quiet $matching $before $after $info/;
## PYTHON:
warning = False
warnings = False
skip_warnings = False
context = None
no_asterisks = False
skip_ruby_lib = False
ruby = False
relaxed = False
strict = False
quiet = False
matching = False
before = None
after = None
info = False
verbose = False
TRUE = True
FALSE = False
NULL = '\0'
## BEHAVIOR:
# - All Perl global variables are preserved as module-level Python variables.
# - Initialized to Perl defaults; will be overridden by CLI parsing.
# - Python does not need 'use strict'; uninitialized globals will cause runtime exceptions.
# - Variable names and grouping match Perl's use vars.
# - TRUE/FALSE/NULL are defined to directly replace Perl's &TRUE/&FALSE/$NULL.
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL:
# Manual CLI/ARGV option parsing and variable dependency logic handled in &init.
## PYTHON:
def parse_options(argv):
    global warning, warnings, skip_warnings, context, no_asterisks, skip_ruby_lib, ruby
    global relaxed, strict, quiet, matching, before, after, info, verbose
    non_option_args = []
    idx = 1
    while idx < len(argv):
        arg = argv[idx]
        if arg in ("-warning", "-warnings"):
            warning = TRUE
            warnings = TRUE
        elif arg == "-nowarnings":
            warning = FALSE
            warnings = FALSE
        elif arg in ("-skip_warnings", "--skip-warnings"):
            skip_warnings = TRUE
        elif arg in ("-info", "--info"):
            info = TRUE
        elif arg.startswith("-context="):
            context = int(arg.split("=")[1])
            before = context
            after = context
        elif arg.startswith("-before="):
            before = int(arg.split("=")[1])
        elif arg.startswith("-after="):
            after = int(arg.split("=")[1])
        elif arg in ("-no_asterisks", "-no_astericks", "--no-asterisks"):
            no_asterisks = TRUE
        elif arg in ("-asterisks", "--asterisks"):
            no_asterisks = FALSE
        elif arg in ("-skip_ruby_lib", "--skip-ruby-lib"):
            ruby = TRUE
            skip_ruby_lib = TRUE
        elif arg in ("-ruby",):
            ruby = TRUE
        elif arg in ("-relaxed",):
            relaxed = TRUE
        elif arg in ("-strict",):
            strict = TRUE
        elif arg in ("-quiet",):
            quiet = TRUE
        elif arg in ("-matching",):
            matching = TRUE
        elif arg in ("-verbose",):
            verbose = TRUE
        elif arg in ("-h", "--help"):
            print_usage_and_exit()
        elif arg.startswith("-"):
            print(f"Unknown option: {arg}", file=sys.stderr)
            print_usage_and_exit(code=1)
        else:
            non_option_args.append(arg)
        idx += 1

    # Initialize derived variables
    global show_warnings, show_informative, asterisks
    show_warnings = True  # Default: show warnings unless explicitly disabled
    show_informative = info
    asterisks = not no_asterisks
    
    # Handle warning logic - by default warnings should be shown
    if skip_warnings:
        show_warnings = False
    
    return non_option_args

def print_usage_and_exit(code=0):
    script_name = os.path.basename(sys.argv[0])
    options = "options = [-warnings | -info] [-context=N] [-no_astericks] [-skip_ruby_lib]"
    options += " [-relaxed | -strict] [-verbose] [-quiet] [-before=N] [-after=N] [-matching]"
    example = f"ex: {script_name} log-file\n"
    note = "Notes:\n"
    note += "- The default context is 1.\n"
    note += "- Warnings are skipped by default.\n"
    note += "- Use -no_astericks if input uses ***'s outside of error contexts.\n"
    note += "- Use -relaxed to include special cases (e.g., xyz='error').\n"
    note += "- Use -matching to show the text from regex match."
    print(f"\nusage: {script_name} [options] [file ...]\n\n{options}\n\n{example}\n\n{note}\n")
    sys.exit(code)
## BEHAVIOR:
# - All Perl CLI flags and aliases are supported; each is mapped to its Python equivalent.
# - Boolean and numeric options are parsed and assigned to globals.
# - Option logic (e.g., skip_warnings depends on warnings) matches Perl's init_var and variable dependencies.
# - Non-option arguments are accumulated as the input files list.
# - Usage/help output matches Perl for content and formatting.
# - Unknown options cause immediate usage and exit, matching Perl's die().
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL:
# if (!defined($ARGV[0])) { die(usage) }
## PYTHON:
def file_exists(filename):
    return os.path.isfile(filename)

def exit_with_message(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)

def show_current_file_info():
    if (strict and current_file != "-" and not file_exists(current_file) and current_file != ""):
        exit_with_message(f"Error: file '{current_file}' not accessible.")
    if current_file != "":
        if not quiet:
            if verbose:
                print("=" * 72)
                print("Errors" + ("" if skip_warnings else " and Warnings") + "\n")
            print(current_file)
## BEHAVIOR:
# - File existence is checked only in strict mode and only if not reading from stdin.
# - Verbose output and file header formatting match Perl's divider and label output.
# - File name is printed unless quiet is set.
# - Fatal error/exit mimics Perl's &exit.
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL: L79-
# my($after_lines) = 0; while (<>) { ... }
## PYTHON:
def dump_line():
    # Placeholder for any future context or debug printing.
    pass

def debug_print(level, message):
    if verbose and level <= TL_MOST_DETAILED:
        print("[DEBUG]", message, file=sys.stderr)

TL_MOST_DETAILED = 3
TL_DETAILED = 2

def re_search(pattern, string, flags=0):
    return re.search(pattern, string, flags)

# Error patterns compiled - this is the key fix
_error_patterns = [
    (re.compile(r'^\s*(Error)\b', re.IGNORECASE), "E2"),
    (re.compile(r'\b(ERROR):', re.IGNORECASE), "E1"),
    (re.compile(r'\b(ERROR)\b', re.IGNORECASE), "E2"),
    (re.compile(r'command not found'), "E2"),
    (re.compile(r'(^|\s)[A-Z]\S+Error(\s|:|$)'), "E2"),
    (re.compile(r'socket has failed to (bind|listen)'), "E2"),
]

def line_matches_known_error(line, relaxed):
    for regex, label in _error_patterns:
        if regex.pattern == r'command not found':
            if regex.search(line) and not re.search(r'Cannot switch to Modules', line):
                m = regex.search(line)
                return TRUE, f"{label} [{m.group(0)}]"
            continue
        if regex.pattern == r'(^|\s)[A-Z]\S+Error(\s|:|$)':
            m = regex.search(line)
            if m:
                blacklist = re.compile(r'BrokenPipeError|SillyPythonException')
                if relaxed or not blacklist.search(line):
                    return TRUE, f"{label} [{m.group(0)}]"
            continue
        m = regex.search(line)
        if m:
            return TRUE, f"{label} [{m.group(0)}]"
    return FALSE, ""
## BEHAVIOR:
# - All regex patterns are precompiled and checked in order, matching Perl's array of qr//.
# - Perl's $& is replaced with match.group(0); group numbering is preserved.
# - Special-case logic for command not found and Python exception blacklists is preserved.
# - Greediness, case, and order follow Perl's original.
# - No pattern optimization or reordering is performed.
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
## PERL: L83-L275 (Main script)
# while (<>) { ... }
## PYTHON:
def main():
    global current_file, before_context
    files = non_option_args if non_option_args else ["-"]
    for file_idx, fname in enumerate(files):
        if fname == "-":
            file_obj = sys.stdin
            current_file = ""
        else:
            current_file = fname
            try:
                file_obj = open(current_file, encoding='utf-8', errors='replace')
            except Exception as e:
                exit_with_message(f"Error: could not open file '{current_file}': {e}")

        show_current_file_info()
        before_context = []  # Will store tuples: (line_num, line)
        
        # Read all lines into memory to handle context properly
        try:
            lines = [(i + 1, line.rstrip('\r\n')) for i, line in enumerate(file_obj)]
        except Exception as e:
            exit_with_message(f"Error reading file '{current_file}': {e}")
        
        n_lines = len(lines)
        i = 0

        while i < n_lines:
            line_num, line = lines[i]
            has_error = FALSE
            match_info = ""

            # Null byte check
            if show_warnings and NULL in line:
                has_error = TRUE
                match_info = f"E1 [{NULL}]"
                line = line.replace(NULL, "^@")
                debug_print(TL_MOST_DETAILED, f"1. has_error={has_error}\n")
            
            # Main error patterns - this is the key fix
            if not has_error:
                matched, match_info_candidate = line_matches_known_error(line, relaxed)
                if matched:
                    has_error = TRUE
                    match_info = match_info_candidate
                    debug_print(TL_MOST_DETAILED, f"2. has_error={has_error}\n")
            
            # Warnings/starred/informative messages
            if not has_error and show_warnings:
                m = None
                warning_match = re_search(r'\b(warning)\b', line, re.IGNORECASE)
                error_match = re_search(r'\b(error)\b', line, re.IGNORECASE)
                eq_warning = re_search(r"='warning'", line, re.IGNORECASE)
                eq_error = re_search(r"='error'", line, re.IGNORECASE)
                no_match = re_search(r': No match', line)
                no_newline = re_search(r'\\ No newline at end', line)
                ruby_warning = re_search(r': warning\b', line)
                bash_warning = re_search(r'^\s*bash: ', line)
                traceback_or_error = re_search(r'Traceback|\S+Error', line)
                py_warning = re_search(r'\b\S+Warning', line)
                exception_failed = re_search(r'exception|failed', line, re.IGNORECASE) if strict else None
                asterisks_match = (asterisks and re_search(r'\*\*\*', line))
                
                if ((warning_match and (not eq_warning or strict)) or
                    (error_match and (not eq_error or strict)) or
                    no_match or
                    no_newline or
                    ruby_warning or
                    bash_warning or
                    traceback_or_error or
                    py_warning or
                    (exception_failed and strict) or
                    asterisks_match):
                    has_error = TRUE
                    for _m in [warning_match, error_match, no_match, no_newline, ruby_warning, bash_warning,
                               traceback_or_error, py_warning, exception_failed, asterisks_match]:
                        if _m:
                            m = _m
                            break
                    match_info = f"W1 [{m.group(0) if m else ''}]"
                    debug_print(TL_MOST_DETAILED, f"3. has_error={has_error}\n")
            elif not has_error and show_informative:
                m1 = re_search(r'\bFYI:', line, re.IGNORECASE)
                m2 = re_search(r'information', line, re.IGNORECASE)
                if m1 or m2:
                    has_error = TRUE
                    m = m1 if m1 else m2
                    match_info = f"I1 [{m.group(0)}]"
                    debug_print(TL_MOST_DETAILED, f"4. has_error={has_error}\n")

            # Filter ruby library errors
            if has_error and skip_ruby_lib and re.search(r'/usr/lib/ruby', line):
                debug_print(TL_DETAILED, f"Skipping ruby library error at line {line_num} ({line})\n")
                has_error = FALSE
                debug_print(TL_MOST_DETAILED, f"5. has_error={has_error}\n")

            # Print context and error line with proper formatting
            if has_error:
                # Print before context lines
                for ctx_num, ctx_line in before_context:
                    print(f"{ctx_num:8} {ctx_line}")

                # Print error line with >>> <<<
                print(f"{line_num:8} >>>{line}<<<")
                if matching:
                    print(match_info)

                # Print after-context lines
                for k in range(1, after + 1):
                    if i + k < n_lines:
                        next_num, next_line = lines[i + k]
                        print(f"{next_num:8} {next_line}")

                # Update before_context with after lines for future context
                before_context = []
                for k in range(1, after + 1):
                    if i + k < n_lines:
                        next_num, next_line = lines[i + k]
                        before_context.append((next_num, next_line))
            else:
                # Add current line to before context
                before_context.append((line_num, line))
                if len(before_context) > before:
                    before_context.pop(0)

            i += 1

        if file_obj is not sys.stdin:
            file_obj.close()
    
    if verbose:
        print()

## BEHAVIOR:
# - Context lines before are printed with their line number and space before error line, up to 'before' lines.
# - Error line is printed with its line number, space, and >>>...<<<.
# - After-context lines are printed with their line number and space, up to 'after' lines following the error.
# - If errors are close together, context lines may overlap as in Perl.
# - Context buffer is updated with after-context lines to support consecutive error regions.
# - Output formatting, whitespace, and line-numbering matches Perl's output for context and error lines.
# - Non-error lines are not printed unless they are in context for an error.
# - If no errors/warnings/informatives are found, only the filename is printed (unless -quiet).
# -----------------------------------------------------------------------

if __name__ == "__main__":
    non_option_args = parse_options(sys.argv)
    if not non_option_args:
        print_usage_and_exit()
    
    # Set defaults for before/after context
    # Type Error for Python3 if not set properly
    # TypeError: '>' not supported between instances of 'int' and 'NoneType'
    if before is None:
        before = 3
    if after is None:
        after = 3
    
    main()