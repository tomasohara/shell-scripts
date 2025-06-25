#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check_errors.py: Scan the error log for errors, warnings and other
suspicious results. This prints the offending line bracketted by >>>
and <<< along with N lines before and after to provide context.

TODO:
- ** Have option to disable line number
- * Change 'error' in filename test as warning.
- Don't reproduce lines in case of overlapping context regions.
- Have option to make search case-insensitive.
- Add option to show which case is being violated (since context display can be confusing, especially when control characters occur in context [as with output form linux script command]).
- Convert into python.
- Have option to skip filenames in input.
- Add codes for error types for convenient filtering (a la pylint).
"""

import sys
import os
import re
import argparse

# Global variables (mimicking Perl's use vars)
verbose = False
warning = False
warnings = False
skip_warnings = True
context = 3
no_asterisks = False
skip_ruby_lib = False
ruby = False
relaxed = False
strict = True
quiet = False
matching = False
before = 3
after = 3
info = False

# Constants
FALSE = False
TRUE = True
TL_MOST_DETAILED = 5
TL_DETAILED = 4

# Mimicking common.perl functions
def init_var(var_name, default_value):
    """Initialize variable if not already set"""
    if var_name not in globals() or globals()[var_name] is None:
        globals()[var_name] = default_value
    return globals()[var_name]

def debug_print(level, message, indent=0):
    """Print debug message if verbose enough"""
    if verbose and level <= TL_DETAILED:
        print(" " * indent + message, end='')

def file_exists(filepath):
    """Check if file exists"""
    return os.path.exists(filepath)

def exit_with_error(message):
    """Exit with error message"""
    print(message, file=sys.stderr)
    sys.exit(1)

def dump_line():
    """Placeholder for line dumping functionality"""
    pass

# Main script
if __name__ == "__main__":
    script_name = os.path.basename(sys.argv[0])
    
    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description="Scan the error log for errors, warnings and other suspicious results",
        epilog="Notes:\n" +
               "- The default context is 1.\n" +
               "- Warnings are skipped by default.\n" +
               "- Use -no_astericks if input uses ***'s outside of error contexts.\n" +
               "- Use -relaxed to include special cases (e.g., xyz='error').\n" +
               "- Use -matching to show the text from regex match.",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('files', nargs='*', help='Log files to check')
    parser.add_argument('-warning', '-warnings', action='store_true', help='Include warnings')
    parser.add_argument('-skip_warnings', action='store_true', help='Omit warnings')
    parser.add_argument('-info', action='store_true', help='Informative messages (e.g., FYI\'s)?')
    parser.add_argument('-context', type=int, default=3, help='Context lines before and after (default: 3)')
    parser.add_argument('-before', type=int, help='Lines of context to show before')
    parser.add_argument('-after', type=int, help='Lines of context to show after')
    parser.add_argument('-no_asterisks', '-no_astericks', action='store_true', help='Skip warnings for \'***\' in text')
    parser.add_argument('-skip_ruby_lib', '-ruby', action='store_true', help='Skip Ruby library related errors')
    parser.add_argument('-relaxed', action='store_true', help='Relaxed for special cases')
    parser.add_argument('-strict', action='store_true', help='Strict error checking')
    parser.add_argument('-quiet', action='store_true', help='Just output errors proper (e.g., no filenames)')
    parser.add_argument('-verbose', action='store_true', help='Verbose output')
    parser.add_argument('-matching', action='store_true', help='Show matching text')
    
    args = parser.parse_args()
    
    # Handle the case when no files are provided
    if not args.files:
        parser.print_help()
        sys.exit(1)
    
    # Initialize variables from arguments
    warning = args.warning
    warnings = warning
    skip_warnings = not warnings if not args.skip_warnings else True
    show_warnings = not skip_warnings
    info = args.info
    show_informative = info
    context = args.context
    before = args.before if args.before is not None else context
    after = args.after if args.after is not None else context
    no_asterisks = args.no_asterisks
    asterisks = not no_asterisks
    ruby = args.skip_ruby_lib
    skip_ruby_lib = ruby
    relaxed = args.relaxed
    strict = not relaxed if not args.strict else True
    quiet = args.quiet
    verbose = args.verbose
    matching = args.matching
    
    NULL = chr(0)  # null character ('\0')
    before_context = []  # prior context
    
    current_file = args.files[0] if args.files else ""
    file_index = 0
    
    def show_current_file_info():
        """Display name of current file (and warning inclusion status)"""
        global current_file
        # Make sure file exists (or stderr)
        if strict and current_file != "-" and not file_exists(current_file) and file_index < len(args.files):
            exit_with_error(f"Error: file '{current_file}' not accessible.")
        # Show current file if not stdin. Also adds divider if verbose mode.
        if current_file != "":
            if not quiet:
                if verbose:
                    print("========================================================================")
                    print(f"Errors{'' if skip_warnings else ' and Warnings'}")
                    print()
                print(current_file)
    
    show_current_file_info()
    
    after_lines = 0  # number of more after-context lines
    line_number = 0
    
    # Process all files
    for filename in args.files:
        current_file = filename
        if file_index > 0:
            show_current_file_info()
        
        try:
            if filename == '-':
                file_handle = sys.stdin
            else:
                file_handle = open(filename, 'r', encoding='utf-8')
            
            line_number = 0
            before_context = []
            
            for line in file_handle:
                line_number += 1
                dump_line()
                line = line.rstrip('\n')
                has_error = FALSE
                match_info = ""
                
                # Check for error log corruption
                if show_warnings and NULL in line:
                    # Null chars usually indicate file corruption (eg, multiple writers)
                    has_error = TRUE
                    match = re.search(NULL, line)
                    match_info = f"E1 [{match.group() if match else ''}]"
                    line = line.replace(NULL, '^@')  # change null char '^@' to "^@" ('^' & '@')
                    debug_print(TL_MOST_DETAILED, f"1. has_error={has_error}\n")
                
                # Check for known errors
                # NOTE: case-sensitive to avoid false negatives
                # TODO: relax case sensitivity
                # TODO: rework so that the pattern which matches can be identified
                # TODO: rework error in line test to omit files
                # NOTE: It can be easier to add special-case rules rather than devise a general regex
                elif (re.search(r'^\s*(Error)\b', line, re.I)
                      or re.search(r'\serror:', line, re.I)
                      or (re.search(r'command not found', line, re.I) and not re.search(r'Cannot switch to Modules', line))
                      or re.search(r'No space', line)
                      or re.search(r'Segmentation fault', line)
                      or re.search(r'Assertion failed', line, re.I)
                      or re.search(r'Assertion .* failed', line, re.I)
                      or re.search(r'Floating exception', line, re.I)
                      
                      # Unix shell errors (e.g., bash or csh)
                      or re.search(r'Can\'t execute', line)
                      or re.search(r'Can\'t locate', line)
                      or re.search(r'Word too long', line)
                      or re.search(r'Arg list too long', line)
                      or re.search(r'Badly placed', line)
                      or re.search(r'Expression Syntax', line)
                      or re.search(r'No such file or directory', line)
                      or re.search(r'permission denied', line, re.I)
                      or re.search(r'Illegal variable name', line)
                      or re.search(r'Unmatched ["\']\.', line)
                      or re.search(r'Bad : modifier in', line)
                      or re.search(r'Syntax Error', line)
                      or re.search(r'Too many (\(|\)|arguments)', line)
                      or re.search(r'illegal option', line)
                      or re.search(r'Missing name for redirect', line)
                      or re.search(r'Variable name must contain', line)
                      or re.search(r'unexpected EOF', line)
                      or re.search(r'unexpected end of file', line)
                      or re.search(r'^\s*sh: ', line)
                      or re.search(r'\[Errno \d+\]', line)
                      or re.search(r'Operation not permitted', line)
                      or re.search(r'Command exited with non-zero status', line)
                      or re.search(r'ommand terminated by signal', line)
                      
                      # Perl interpretation errors
                      # TODO: Add more examples like not-a-number, which might not be apparent.
                      or re.search(r'^\s*\S+: Undefined variable', line)
                      or re.search(r'Invalid conversion in printf', line)
                      or re.search(r'Execution .* aborted', line)
                      or re.search(r'used only once: possible typo', line)
                      or re.search(r'Use of uninitialized', line)
                      or re.search(r'Undefined subroutine', line)
                      or re.search(r'Reference found where even-sized list expected', line)
                      or re.search(r'Out of memory', line)
                      or re.search(r'Unmatched .* in regex', line)
                      or re.search(r'at .*\.(perl|prl|pl|pm) line \d+', line)
                      
                      # Build errors (also cp, etc.)
                      or re.search(r'(Make|Dependency) .* failed', line)
                      or re.search(r'cannot create', line)
                      or re.search(r'cannot open', line)
                      or re.search(r'cannot find', line)
                      or re.search(r'cannot overwrite', line)
                      or re.search(r':( fatal)? error ', line)
                      
                      # Git errors (WTH: can't modern tools say 'error'???)
                      or re.search(r'^\s*fatal:', line)
                      
                      # Java errors
                      or re.search(r'^\s*Exception\b', line)
                      
                      # Ruby errors
                      or re.search(r': undefined\b', line)
                      or re.search(r'\(\S+Error\)', line)
                      or re.search(r'Exception.*at.*\.rb', line)
                      
                      # Python errors
                      or re.search(r'^\s*Traceback', line)
                      or (re.search(r'(^|\s)[A-Z]\S+Error(\s|:|$)', line)
                          and (relaxed or not re.search(r'BrokenPipeError|SillyPythonException', line)))
                      or re.search(r'^\S+\.\S+Error:', line)
                      or re.search(r':\s*error\s*:', line, re.I)
                      or re.search(r'^\s*FAILED\b', line, re.I)
                      or re.search(r'\|\s*(ERROR|CRITICAL)\s*\|', line)
                      
                      # Cygwin errors
                      or re.search(r'\bunable to remap\b', line)
                      
                      # Miscellaneous errors
                      or re.search(r'wn: invalid search', line)
                      or re.search(r'socket has failed to (bind|listen)', line)):
                    has_error = TRUE
                    # Find which pattern matched
                    for pattern in [r'^\s*(Error)\b', r'\serror:', r'command not found']:
                        match = re.search(pattern, line, re.I)
                        if match:
                            match_info = f"E2 [{match.group()}]"
                            break
                    debug_print(TL_MOST_DETAILED, f"2. has_error={has_error}\n")
                
                # Check for warnings and starred messages
                # TODO: Have option for restricting ***'s to start of line.
                # NOTE: strict includes "error" or "warning" occurring anywhere, etc.
                elif (show_warnings and
                      ((re.search(r'\b(warning)\b', line, re.I)
                        and (not re.search(r"='warning'", line, re.I) or strict))
                       or (re.search(r'\b(error)\b', line, re.I)
                           and (not re.search(r"='error'", line, re.I) or strict))
                       or re.search(r': No match', line)
                       or re.search(r'\\ No newline at end', line)
                       or re.search(r': warning\b', line)
                       or re.search(r'^\s*bash: ', line)
                       or re.search(r'Traceback|\S+Error', line)
                       or re.search(r'\b\S+Warning', line)
                       or (re.search(r'exception|failed', line)
                           and strict)
                       or (asterisks and re.search(r'\*\*\*', line)))):
                    has_error = TRUE
                    # Find which pattern matched
                    for pattern in [r'\b(warning)\b', r'\b(error)\b', r'\*\*\*']:
                        match = re.search(pattern, line, re.I)
                        if match:
                            match_info = f"W1 [{match.group()}]"
                            break
                    debug_print(TL_MOST_DETAILED, f"3. has_error={has_error}\n")
                
                elif (show_informative and
                      (re.search(r'\bFYI:', line, re.I)
                       or re.search(r'information', line, re.I))):
                    has_error = TRUE
                    match = re.search(r'\bFYI:|information', line, re.I)
                    if match:
                        match_info = f"I1 [{match.group()}]"
                    debug_print(TL_MOST_DETAILED, f"4. has_error={has_error}\n")
                
                # Filter certain case(s)
                if has_error and skip_ruby_lib and re.search(r'/usr/lib/ruby', line):
                    debug_print(TL_DETAILED, f"Skipping ruby library error at line {line_number} ({line})\n")
                    has_error = FALSE
                    debug_print(TL_MOST_DETAILED, f"5. has_error={has_error}\n")
                
                # If an error, then display line preceded by pre-context
                debug_print(TL_MOST_DETAILED, f"final has_error={has_error}\n")
                if has_error:
                    # Show up the N preceding context lines, unless there is an overlap
                    # with previous error context in which no pre-context is shown.
                    num = 0 if after_lines > 0 else len(before_context)
                    for i in range(num):
                        print(f"{line_number - (num - i):<4d}     {before_context[i]}")
                    
                    # Display the error line and update the after context count
                    print(f"{line_number:<4d} >>> {line} <<<")
                    if matching:
                        print(f"{line_number:<4d} match: {match_info}")
                    after_lines = after
                
                # Otherwise print line only if in the post-context
                else:
                    if after_lines > 0:
                        print(f"{line_number:<4d}     {line}")
                    if after_lines == 1:
                        print()
                    after_lines -= 1
                
                # Update the context
                # TODO: efficiency please
                before_context.append(line)
                if len(before_context) > before:
                    before_context.pop(0)
            
            if filename != '-':
                file_handle.close()
            
        except IOError as e:
            print(f"Error reading file {filename}: {e}", file=sys.stderr)
        
        file_index += 1
        # Reset for next file
        before_context = []
    
    # Optionally add extra blank line at end.
    # NOTE: Used for cc-errors alias invoking first over errors and then warnings.
    if verbose:
        print()
