#! /usr/bin/env python
#
# This groups several tools to dea with filenames.
# This can be used as command-line tool or as module.


"""This groups several tools to dea with filenames."""


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh
from mezcla      import file_utils as fl


# Command-line labels constants
FILENAMES = 'files'
RENAME    = 'rename'
COPY      = 'copy'
FREE      = 'free'           # get free filenames
BASE      = 'base'           # basename for option FREE
SEP       = 'sep'            # separation text between basenae and N for option FREE
EM        = 'em'             # get filename with em
FREE_DATE = 'free-with-date' # get filename with creation date


class Filenames(Main):
    """Argument processing class"""


    # Class-level member variables for arguments (avoids need for class constructor)
    rename    = False
    copy      = False
    free      = False
    base      = ''
    sep       = ''
    em        = False
    free_date = False


    # Global
    filenames = ''


    def setup(self):
        """Process arguments"""
        debug.trace(5, f"Script.setup(): self={self}")


        # Check the command-line options
        self.filenames = self.get_parsed_argument(FILENAMES, "")
        self.rename    = self.has_parsed_option(RENAME)
        self.copy      = self.has_parsed_option(COPY)
        self.free      = self.has_parsed_option(FREE)
        self.base      = self.get_parsed_argument(BASE, "")
        self.sep       = self.get_parsed_argument(SEP, "")
        self.em        = self.has_parsed_option(EM)
        self.free_date = self.has_parsed_option(FREE_DATE)


        # Check if options are correct
        if (self.free or self.free_date) and not (self.base or self.rename):
            print(f'Error, --{BASE} cannot be empty for --{FREE} or --{FREE_DATE} options.')
            self.free = self.free_date = False


        # Process entered input
        if not self.filenames:
            self.filenames = system.read_all_stdin().strip().split()


    def run_main_step(self):
        """Process input stream"""
        debug.trace(5, f"Script.run_main_step(): self={self}")

        # Loop for options that use filenames
        for filename in self.filenames:
            debug.trace(7, f'filenames - processing filename {filename}')

            if self.rename and self.em:
                rename_with_em(filename)
                return

            if self.rename and self.free_date:
                rename_with_file_date(filename, copy=self.copy)
                return

            if self.em:
                print(get_name_em(filename))

        # Other options
        if self.free_date:
            print(get_free_date_name(self.base))
            return

        if self.free:
            print(get_free_filename(self.base, self.sep))
            return


def get_free_filename(basename, separation):
    """Get filename starting with BASE that is not used"""
    # NOTE: If <basename> exists <basename><separation><N> checked until the filename not used (for N in 2, 3, ... ).

    free_filename = basename
    number        = 0 # This shuld start from 1 or 0?

    while gh.file_exists(free_filename):
        number       += 1
        free_filename = basename + separation + str(number)

    debug.trace(7, f"get_free_filename(basename={basename}, separation={separation}) => {free_filename}")
    return free_filename


def get_name_em(filename):
    """Get filename with current directory set to it's dir"""
    ## WORK-IN-PROGRESS
    ##
    ## implement equivalent to
    ## function em-file() {
    ##	local file="$1"
    ##	local base=$(basename "$file")
    ##	local dir=$(dirname "$file")
    ## 	command pushd $dir
    ## 	em "$base"
    ##	command popd
    ##}


def rename_with_em(filename):
    """Edit filename with current directory set to it's dir"""
    ## WORK-IN-PROGRESS


def get_free_date_name(basename):
    """Get filename with .ddMmmYY.N suffix"""

    if not gh.file_exists(basename):
        return basename

    modification_date = fl.get_modification_date(basename, strftime='%d%b%y')
    result = get_free_filename(basename + '.' + modification_date, '.')

    debug.trace(7, f"get_free_date_name(basename={basename}) => {result}")
    return result


# rename_with_file_date(file, ...): rename each file(s) with .ddMmmYY suffix
# Notes: 1. If file.ddMmmYY exists, file.ddMmmYY.N tried (for N in 1, 2, ...).
# 2. No warning is issued if the file doesn't exist, so can be used as a no-op.
## TODO: have option to put suffix before extension
def rename_with_file_date(basename, target='./', copy=False):
    """Rename or Copy file with date"""

    if not gh.file_exists(basename):
        return

    new_filename = get_free_date_name(basename)

    ## TODO: check assertion fail on glue_helpers copy_file and rename_file
    if copy:
        ## TODO: implement target path when the file is copied
        gh.copy_file(basename, new_filename)
    else:
        gh.rename_file(basename, new_filename)

    debug.trace(7, f"rename_with_file_date(basename={basename}, target={target}, copy={copy})")


if __name__ == '__main__':
    app = Filenames(description     = __doc__,
                    boolean_options = [(RENAME,   f'Rename file, can be conbined with options --{EM} or --{FREE_DATE}, optionally --{COPY}'),
                                       (COPY,      'Copy file instead of replace filename'),
                                       (FREE,     f'Get free filename starting with BASE, this option needs --{BASE} and --{SEP}'),
                                       (EM,        'Get filename with current directory set to it\'s dir'),
                                       (FREE_DATE, 'Get free filename with .ddMmmYY suffix')],
                    text_options    = [(FILENAMES, 'target files'),
                                       (BASE,      'basename for option FREE'),
                                       (SEP,       'separation text between basenae and N for option FREE')],
                    positional_arguments = [(FILENAMES, 'target filenames', [], "*")],
                    skip_input = True)
    app.run()
