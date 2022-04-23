#! /usr/bin/env python
#
# This script groups several tools to find files.
# This can be used as command-line tool or as module.


"""
This script groups several tools to find files.

ex:
\t$ python find_files.py --find-files /some/path/to/dir
"""


# Standard packages
import re
import sys


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug
from mezcla      import file_utils as fu
from mezcla      import glue_helpers as gh
import filenames as fn


# Command-line labels constants
FIND_FILES = 'find-files'
PATH       = 'path'


class FindFiles(Main):
    """Argument processing class"""


    # Class-level member variables for arguments (avoids need for class constructor)
    find_files = False
    path       = ''


    def setup(self):
        """Process arguments"""
        debug.trace(5, f"Script.setup(): self={self}")

        # Process command-line options
        self.find_files = self.has_parsed_option(FIND_FILES)
        self.path       = self.get_parsed_argument(PATH, self.path)


        # Check path
        if len(self.path) > 1 and self.path[-1] == '/':
            self.path = self.path[:-1]
        if self.path in ('', '-'):
            self.path = system.get_current_directory()


    def run_main_step(self):
        """Process input stream"""
        debug.trace(5, f"Script.run_main_step(): self={self}")

        if self.find_files:
            find_files(path=self.path)


# list_dir(): produces listing(s) of files in current directory
# tree, in support of find-files-here; this contains full ls entry (as with -l).
# (The subdirectory listings produced by 'ls -alR' are preceded by blank lines,
# which is required for find-files-here as explained below.)
# Notes: Also puts listing proper in ls-R.list (i.e., just list of files).
def find_files(path='.', full=False, special_dirs=False):
    """List files in current directory tree"""
    debug.trace(5, f"find_files(path={path}, full={full}, special_dirs={special_dirs})")

    debug.trace(debug.VERBOSE, f'find_files(path={path}, full={full}, special_dirs={special_dirs})')

    # Setup filenames
    ls_opts       = 'alR' if full else 'R'
    filename      = 'ls-' + ls_opts + '.list'
    log_filename  = filename + '.log'
    current_files = [filename, log_filename]

    # Rename existing files with file date as suffix and move to a backup folder
    if any(fu.path_exist(path + '/' + filename) for filename in current_files):
        gh.create_directory(path + '/backup')
        for current_file in current_files:
            gh.run(f'mv {path}/{current_file} {path}/backup') # TODO: pure python.
            fn.rename_with_file_date(path + '/backup/' + current_file)

    # Perform the actual listings, putting errors in the .log file for each listing
    # Note: If root directory and special_dirs is false, filters out special directories.
    ## TODO: ** resolve intermittent problem when running under /
    dir_list           = fu.get_directory_listing(path, recursive=True, long=full, return_string=True)
    is_root_dir        = path == '/'
    regex_special_dirs = '^\\.(/(cdrom|dev|media|mnt|proc|run|sys|snap)$)'
    file_content       = ''
    for item in dir_list:
        if is_root_dir and not special_dirs and re.search(regex_special_dirs, item):
            continue
        item          = re.sub(r'^\.\/\.', '\n./', item)
        file_content += item + '\n'

    # Save the files
    gh.write_file(path + '/' + filename, file_content)
    sys.stderr = open(path + '/' + log_filename, 'w+')
    sys.stderr.close()

    # Show created files
    dir_list = fu.get_directory_listing(path, recursive=False, long=True, return_string=True)
    for item in dir_list:
        if any(new_file in item for new_file in current_files):
            print(item)

    # Call recursively to do brief and full listing of files
    if not full:
        find_files(path=path, full=True)


def find_files_there():
    """find files there"""
    ## WORK-IN-PROGRESS
    ##
    ## implement equivalent to
    ## function find-files-there () { perlgrep.perl -para -i "$@" | egrep -i '((:$)|('$1'))' | $PAGER_NOEXIT -p "$1"; }


def find_files_here():
    """find files here"""
    ## WORK-IN-PROGRESS
    ##
    ## implement equivalent to
    ## function find-files-here () { find-files-there "$1" "$PWD/ls-alR.list"; }


if __name__ == '__main__':
    app = FindFiles(description     = __doc__,
                    boolean_options = [(FIND_FILES, 'list files in current directory tree and save the result')],
                    positional_options = [(PATH, 'path target')],
                    manual_input    = True)
    app.run()
