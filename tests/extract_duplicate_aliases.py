#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Script to find and analyze duplicate alias definitions in Bash scripts.
# This helps identify potential conflicts and redundant definitions that can
# cause unexpected behavior in shell environments.
#

"""
Find duplicate alias definitions in bash scripts or configuration files.

Sample usage:
   {script} ~/.bashrc
   {script} --json ~/tom-shell-scripts/*.bash
   cat aliases.sh | {script} --stdin
   {script} --verbose --summary test_aliases.sh
"""

# Standard modules
from collections import defaultdict
import json
import re

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

# Constants for switches
JSON_OUTPUT = "json"
VERBOSE_MODE = "verbose"
SUMMARY_ONLY = "summary"
USE_STDIN = "stdin"
INCLUDE_COMMENTS = "include-comments"

# Constants
TL = debug.TL

# Environment options
ALIAS_DEBUG_LEVEL = system.getenv_int(
    "ALIAS_DEBUG_LEVEL", 0,
    description="Debug level for alias duplicate detection")
IGNORE_QUOTED_ALIASES = system.getenv_bool(
    "IGNORE_QUOTED_ALIASES", False,
    description="Ignore aliases with quotes in their names")

class AliasDuplicateFinder:
    """Helper class for finding duplicate alias definitions."""
    
    def __init__(self, include_comments=False):
        """Initializer: sets up alias detection patterns."""
        debug.trace(TL.VERBOSE, f"AliasDuplicateFinder.__init__(): self={self}")
        self.include_comments = include_comments
        # Pattern to match alias definitions (handles various formats)
        self.alias_pattern = re.compile(
            r'^\s*alias\s+([^=\s]+)\s*=\s*(.*)$',
            re.MULTILINE
        )
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def is_comment_line(self, line):
        """Check if line is a comment."""
        return line.strip().startswith("#")
    
    def extract_aliases_from_content(self, content, source_name="stdin"):
        """Extract all alias definitions from content."""
        debug.trace(TL.DETAILED, f"Extracting aliases from {source_name}")
        aliases = []
        
        if isinstance(content, str):
            lines = content.splitlines()
        else:
            lines = content
            
        for line_num, line in enumerate(lines, 1):
            # Skip comments unless requested
            if self.is_comment_line(line) and not self.include_comments:
                continue
                
            match = self.alias_pattern.match(line)
            if match:
                alias_name = match.group(1).strip()
                alias_value = match.group(2).strip()
                
                # Skip quoted aliases if configured
                if IGNORE_QUOTED_ALIASES and (alias_name.startswith('"') or alias_name.startswith("'")):
                    debug.trace(TL.DETAILED, f"Skipping quoted alias: {alias_name}")
                    continue
                    
                aliases.append({
                    'name': alias_name,
                    'value': alias_value,
                    'line': line_num,
                    'source': source_name
                })
                debug.trace(TL.VERBOSE, f"Found alias '{alias_name}' at line {line_num}")
                
        return aliases
    
    def find_duplicates(self, all_aliases):
        """Group aliases by name and return duplicates."""
        alias_groups = defaultdict(list)
        
        for alias in all_aliases:
            alias_groups[alias['name']].append(alias)
            
        # Return only groups with duplicates
        duplicates = {
            name: definitions 
            for name, definitions in alias_groups.items() 
            if len(definitions) > 1
        }
        
        debug.trace(TL.USUAL, f"Found {len(duplicates)} duplicate aliases")
        return duplicates

class DuplicateAliasScript(Main):
    """Input processing class for duplicate alias detection"""
    
    # Class-level member variables for arguments
    json_output = False
    verbose_mode = False
    summary_only = False
    use_stdin = False
    include_comments = False
    collected_lines = []
    finder = None
    
    def setup(self):
        """Check results of command line processing"""
        debug.trace(TL.VERBOSE, f"DuplicateAliasScript.setup(): self={self}")
        
        # Extract argument values
        self.json_output = self.get_parsed_option(JSON_OUTPUT, self.json_output)
        self.verbose_mode = self.get_parsed_option(VERBOSE_MODE, self.verbose_mode)
        self.summary_only = self.get_parsed_option(SUMMARY_ONLY, self.summary_only)
        self.use_stdin = self.get_parsed_option(USE_STDIN, self.use_stdin)
        self.include_comments = self.get_parsed_option(INCLUDE_COMMENTS, self.include_comments)
        
        # Initialize helper
        self.finder = AliasDuplicateFinder(include_comments=self.include_comments)
        
        # Set debug level if verbose
        if self.verbose_mode:
            debug.set_level(TL.USUAL)
            
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def process_line(self, line):
        """Processes current line from input"""
        debug.trace_fmtd(TL.QUITE_DETAILED, "DuplicateAliasScript.process_line({l})", l=line)
        self.collected_lines.append(line)
    
    def wrap_up(self):
        """Do final processing"""
        debug.trace(6, f"DuplicateAliasScript.wrap_up(); self={self}")
        
        all_aliases = []
        
        # Process stdin if we have collected lines
        if self.collected_lines:
            aliases = self.finder.extract_aliases_from_content(
                self.collected_lines, 
                source_name="stdin"
            )
            all_aliases.extend(aliases)
        
        # Process files if provided
        if hasattr(self, 'filename') and self.filename:
            try:
                with open(self.filename, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.readlines()
                aliases = self.finder.extract_aliases_from_content(
                    content,
                    source_name=self.filename
                )
                all_aliases.extend(aliases)
            except IOError as e:
                system.print_stderr(f"Error reading {self.filename}: {e}")
                
        # Find duplicates
        duplicates = self.finder.find_duplicates(all_aliases)
        
        # Output results
        if not duplicates:
            print("No duplicate aliases found!")
            return
            
        if self.json_output:
            self._output_json(duplicates)
        elif self.summary_only:
            self._output_summary(duplicates)
        else:
            self._output_detailed(duplicates)
    
    def _output_json(self, duplicates):
        """Output results in JSON format."""
        print(json.dumps(duplicates, indent=2))
    
    def _output_summary(self, duplicates):
        """Output summary of duplicates."""
        print(f"Found {len(duplicates)} duplicate aliases:")
        for alias_name in sorted(duplicates.keys()):
            count = len(duplicates[alias_name])
            print(f"  {alias_name}: {count} definitions")
    
    def _output_detailed(self, duplicates):
        """Output detailed report of duplicates."""
        print("=== DUPLICATE ALIAS REPORT ===")
        print(f"Total duplicate aliases found: {len(duplicates)}")
        print()
        
        for alias_name in sorted(duplicates.keys()):
            definitions = duplicates[alias_name]
            print(f"Alias: {alias_name}")
            print(f"Found {len(definitions)} definitions:")
            
            for defn in definitions:
                print(f"  {defn['source']}:{defn['line']}")
                print(f"    Value: {defn['value']}")
                
                # Check if values differ
                if self.verbose_mode:
                    values = [d['value'] for d in definitions]
                    if len(set(values)) > 1:
                        print("    *** WARNING: Different values detected! ***")
            print()

def main():
    """Entry point"""
    app = DuplicateAliasScript(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=False,
        manual_input=False,
        auto_help=True,
        boolean_options=[
            (JSON_OUTPUT, "Output results in JSON format"),
            (VERBOSE_MODE, "Enable verbose output with additional warnings"),
            (SUMMARY_ONLY, "Show only summary of duplicate counts"),
            (USE_STDIN, "Read from standard input"),
            (INCLUDE_COMMENTS, "Include commented alias definitions")
        ])
    app.run()
    
    # Ensure no TODO variables remain
    debug.assertion(not any(my_re.search(r"^TODO_", m, my_re.IGNORECASE)
                            for m in dir(app)))

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    debug.assertion("TODO:" not in __doc__)
    main()
