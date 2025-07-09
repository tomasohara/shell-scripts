#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Find duplicate alias definitions in bash scripts or configuration files.

Sample usage:
   python3 {script} ~/shell-scripts
   python3 {script} ~/shell-scripts --check-definitions
   python3 {script} ~/shell-scripts --exclude /path/to/exclude
   python3 {script} ~/.bashrc --verbose
   python3 {script} ~/shell-scripts --json
"""

# Standard modules
import json
import os
import re
from collections import defaultdict

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

debug.trace(5, f"global __doc__: {__doc__}")
debug.assertion(__doc__)

# Constants for switches
CHECK_DEFINITIONS = "check-definitions"
EXCLUDE_PATH = "exclude"
JSON_OUTPUT = "json"

# Constants
TL = debug.TL

# Environment options
ALIAS_VERBOSE = system.getenv_bool(
    "ALIAS_VERBOSE", False,
    description="Enable verbose alias processing")

class AliasFinder:
    """Helper class for finding duplicate alias definitions"""
    
    def __init__(self, verbose=False):
        self.alias_pattern = re.compile(r'^\s*alias\s+([^=\s]+)\s*=\s*(.*)$', my_re.MULTILINE)
        self.verbose = verbose
        self.shell_extensions = ['.sh', '.bash', '.zsh', '.csh', '.fish']
        self.shell_configs = ['.bashrc', '.bash_profile', '.zshrc', '.profile', 
                             'bashrc', 'bash_profile', 'zshrc', 'profile']
    
    def log(self, message):
        """Print debug message if verbose"""
        if self.verbose:
            debug.trace(4, f"AliasFinder: {message}")
    
    def find_shell_files(self, path, exclude_paths=None):
        """Find all shell script files, excluding specified paths"""
        exclude_paths = exclude_paths or []
        path = os.path.expanduser(path)
        exclude_paths = [os.path.expanduser(p) for p in exclude_paths]
        
        self.log(f"Searching in: {path}")
        
        if not os.path.exists(path):
            return []
        
        if os.path.isfile(path):
            return [path] if not self._is_excluded(path, exclude_paths) else []
        
        shell_files = []
        for root, dirs, files in os.walk(path):
            if self._is_excluded(root, exclude_paths):
                continue
            
            # Skip excluded directories
            dirs[:] = [d for d in dirs if not self._is_excluded(os.path.join(root, d), exclude_paths)]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                if self._is_excluded(file_path, exclude_paths):
                    continue
                
                if self._is_shell_file(file):
                    shell_files.append(file_path)
                    self.log(f"Found: {file_path}")
        
        return shell_files
    
    def _is_excluded(self, path, exclude_paths):
        """Check if path should be excluded"""
        if not exclude_paths:
            return False
        
        path = os.path.abspath(path)
        for excluded in exclude_paths:
            excluded = os.path.abspath(excluded)
            if path == excluded or path.startswith(excluded + os.sep):
                return True
        return False
    
    def _is_shell_file(self, filename):
        """Check if file is a shell script"""
        return (any(filename.endswith(ext) for ext in self.shell_extensions) or
                filename in self.shell_configs or
                filename.startswith('.bash'))
    
    def extract_aliases(self, file_path):
        """Extract aliases from a single file"""
        aliases = []
        
        try:
            lines = system.read_lines(file_path)
            
            for line_num, line in enumerate(lines, 1):
                match = self.alias_pattern.match(line)
                if match:
                    aliases.append({
                        'name': match.group(1).strip(),
                        'definition': match.group(2).strip(),
                        'file': file_path,
                        'line': line_num,
                        'actual_line': line.strip()
                    })
                    
        except (FileNotFoundError, IOError) as e:
            debug.trace(3, f"Could not read {file_path}: {e}")
        except UnicodeDecodeError as e:
            debug.trace(3, f"Could not decode {file_path}: {e}")
        
        self.log(f"Found {len(aliases)} aliases in {file_path}")
        return aliases

    
    def find_duplicates(self, files, check_definitions=False):
        """Find duplicate aliases across files"""
        all_aliases = []
        for file_path in files:
            all_aliases.extend(self.extract_aliases(file_path))
        
        self.log(f"Total aliases found: {len(all_aliases)}")
        
        # Group by alias name
        name_groups = defaultdict(list)
        for alias in all_aliases:
            name_groups[alias['name']].append(alias)
        
        # Find duplicates
        duplicates = {k: v for k, v in name_groups.items() if len(v) > 1}
        
        if check_definitions:
            # Only show duplicates with different definitions
            filtered_duplicates = {}
            for name, aliases in duplicates.items():
                definitions = set(alias['definition'] for alias in aliases)
                if len(definitions) > 1:  # Multiple different definitions
                    filtered_duplicates[name] = aliases
            duplicates = filtered_duplicates
        
        return duplicates

class ExtractDuplicateAliases(Main):
    """Alias duplicate finder script"""
    
    check_definitions = False
    path = ""
    exclude_paths = []
    json_output = False
    
    def setup(self):
        """Process command line arguments"""
        debug.trace(TL.VERBOSE, f"Script.setup(): self={self}")
        
        self.check_definitions = self.get_parsed_option(CHECK_DEFINITIONS, self.check_definitions)
        self.json_output = self.get_parsed_option(JSON_OUTPUT, self.json_output)
        
        # Handle exclude paths (can be specified multiple times)
        exclude_option = self.get_parsed_option(EXCLUDE_PATH, [])
        if isinstance(exclude_option, str):
            self.exclude_paths = [exclude_option]
        elif isinstance(exclude_option, list):
            self.exclude_paths = exclude_option
        else:
            self.exclude_paths = []
        
        # Get the path argument
        self.path = self.get_parsed_argument("path", ".")
        
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")
    
    def print_readable_output(self, result):
        """Print results in clean readable format"""
        if result["status"] == "error":
            print(f"Error: {result['message']}")
            return
        
        print("Duplicate Alias Analysis")
        print("=" * 50)
        print(f"Path analyzed: {result['path']}")
        print(f"Files analyzed: {result['total_files']}")
        
        if self.exclude_paths:
            print(f"Excluded paths: {', '.join(self.exclude_paths)}")
        
        if self.check_definitions:
            print("Mode: Only showing aliases with different definitions")
        else:
            print("Mode: Showing all duplicate alias names")
        
        print()
        
        if not result['duplicates']:
            print("No duplicate aliases found.")
            return
        
        print(f"Found {result['unique_duplicates']} unique duplicate aliases:")
        print()
        
        for duplicate in result['duplicates']:
            print(f"Alias: {duplicate['alias']} ({duplicate['occurrences']} occurrences)")
            print("-" * 40)
            
            for location in duplicate['locations']:
                print(f"  File: {location['file']}")
                print(f"  Line {location['line_number']}: {location['line_content']}")
                print(f"  Definition: {location['definition']}")
                print()
    
    def run_main_step(self):
        """Main processing step"""
        debug.trace(5, f"Script.run_main_step(): self={self}")
        
        # Create finder
        finder = AliasFinder(verbose=self.verbose)
        
        # Find shell files
        shell_files = finder.find_shell_files(self.path, self.exclude_paths)
        
        if not shell_files:
            result = {
                "status": "error",
                "message": f"No shell scripts found in {self.path}",
                "path": self.path,
                "files_analyzed": [],
                "duplicates": []
            }
            
            if self.json_output:
                print(json.dumps(result, indent=2))
            else:
                self.print_readable_output(result)
            return
        
        # Find duplicates
        duplicates = finder.find_duplicates(shell_files, self.check_definitions)
        
        # Format results
        duplicate_list = []
        for name, aliases in duplicates.items():
            duplicate_entry = {
                "alias": name,
                "occurrences": len(aliases),
                "locations": []
            }
            
            for alias in aliases:
                location = {
                    "file": alias['file'],
                    "line_number": alias['line'],
                    "line_content": alias['actual_line'],
                    "definition": alias['definition']
                }
                duplicate_entry["locations"].append(location)
            
            duplicate_list.append(duplicate_entry)
        
        # Sort by occurrences (descending)
        duplicate_list.sort(key=lambda x: x['occurrences'], reverse=True)
        
        result = {
            "status": "success",
            "path": self.path,
            "files_analyzed": shell_files,
            "total_files": len(shell_files),
            "unique_duplicates": len(duplicates),
            "check_definitions": self.check_definitions,
            "duplicates": duplicate_list
        }
        
        if self.json_output:
            print(json.dumps(result, indent=2))
        else:
            self.print_readable_output(result)

def main():
    """Entry point"""
    app = ExtractDuplicateAliases(
        description=__doc__.format(script=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        auto_help=True,
        boolean_options=[
            (CHECK_DEFINITIONS, "Only show aliases with different definitions"),
            (JSON_OUTPUT, "Output results in JSON format"),
        ],
        text_options=[
            (EXCLUDE_PATH, "Paths to exclude (can be specified multiple times)"),
        ],
        positional_arguments=["path"],
        float_options=None
    )
    app.run()

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    debug.trace(5, f"module __doc__: {__doc__}")
    main()
