#! /usr/bin/env python
# 
# Merges two versions of the same file, using an earlier version as a baseline
# (i.e., 3-way merge). If the baseline version is not supplied it is determined
# as the most recent backup older than both versions.
#
# Notes:
# - The merge process can easily get confused is there are parallel changes to
#   the same sections.
# - Use a visual merge script to help with manual reconciliation (e.g., via kdiff3).
#
# TODO:
# - Integrate merge heuristics for common issues.
#   -- For example, accounting for changes flagged with comments:
#      ## OLD: from regex import my_re
#      from my_regex import my_re
#   -- Accounting for changes elsewhere.
#

"""Perform 3-way merge with baseline from backup dir

Sample usage:

{prog} --stdout .bashrc ~/temp/.bashrc > .new-bashrc
"""

# Standard packages
import re

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system

# Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
BASENAME = "basename"
BACKUP_DIR = "backup-dir"
BACKUP_FILENAME = "backup-filename"
MAIN_FILENAME = "main-filename"
OTHER_FILENAME = "other-filename"
QUIET = "quiet"
USE_STDOUT = "stdout"
SKIP_BASELINE = "skip-baseline"
UPDATE_MAIN_FILE = "update-main-file"
IGNORE_ERRORS = "ignore-errors"
## OLD: MERGE = system.getenv_text("MERGE", "/usr/bin/merge -p",
MERGE = system.getenv_text("MERGE", "merge -p",
                           description="Command line for merge with output piping arg (e.g., -p)")
IGNORE_TIMESTAMP = system.getenv_bool("IGNORE_TIMESTAMP", False,
                                      "Whether to ignore time of backup files")

#...............................................................................

def get_timestamp(filename):
    """Returns timestamp for FILENAME as string value"""
    # EX: get_timestamp("/vmlinuz") => "2021-04-15 04:24:54"
    result = system.get_file_modification_time(filename, as_float=False)
    debug.assertion(isinstance(result, str))
    return result


def get_numeric_timestamp(filename):
    """Returns timestamp for FILENAME as floating point value"""
    # EX: get_numeric_timestamp("/vmlinuz") => 1618478694.0
    result = system.get_file_modification_time(filename, as_float=True)
    debug.assertion(isinstance(result, float))
    return result

#...............................................................................

class Script(Main):
    """Adhoc script processing class"""
    main_filename = ""
    other_filename = ""
    backup_filename = ""
    backup_dir = "./backup"
    basename = ""
    update_file1 = False
    skip_baseline = False
    quiet = False
    use_stdout = None
    ignore_errors = False
    ## TODO: use_temp_base_dir = True

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.main_filename = self.get_parsed_argument(MAIN_FILENAME)
        self.other_filename = self.get_parsed_argument(OTHER_FILENAME)
        self.backup_filename = self.get_parsed_option(BACKUP_FILENAME)
        default_backup_dir = gh.form_path(gh.dirname(self.main_filename),
                                          self.backup_dir) 
        self.backup_dir = self.get_parsed_option(BACKUP_DIR,
                                                 default_backup_dir)
        self.basename = self.get_parsed_option(BASENAME,
                                               gh.basename(self.main_filename))
        self.update_file1 = self.get_parsed_option(UPDATE_MAIN_FILE, self.update_file1)
        self.skip_baseline = self.get_parsed_option(SKIP_BASELINE, self.skip_baseline)
        self.quiet = self.get_parsed_option(QUIET, self.quiet)
        self.use_stdout = self.get_parsed_option(USE_STDOUT, not self.update_file1)
        self.ignore_errors = self.get_parsed_option(IGNORE_ERRORS)
        debug.trace_object(5, self, label="Script instance")

    def check_regular_file(self, filename):
        """Make sure regular file exists; otherwise, issue error and exit"""
        debug.trace(4, f"Script.check_regular_file({filename})")
        ok = (system.file_exists(filename) and system.is_regular_file(filename))
        if not ok and not self.ignore_errors:
            system.exit(f"Error: expecting regular file for '{filename}'")
        return ok

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)

        # Validate input files
        self.check_regular_file(self.main_filename)
        if system.is_directory(self.other_filename):
            self.other_filename = gh.form_path(self.other_filename,
                                               gh.basename(self.main_filename))
        self.check_regular_file(self.other_filename)

        # Find the backup baseline if not specified
        if not self.backup_filename:
            EPSILON = 1e-6
            main_timestamp = get_numeric_timestamp(self.main_filename)
            other_timestamp = get_numeric_timestamp(self.other_filename)
            min_timestamp = min(main_timestamp, other_timestamp) - EPSILON

            # Find most recent backup older than the two files
            # TODO: reinstate ~ check (or ./backup/f ./backup/~ and backup/f.~N~)
            SEP = "\t"
            backup_files = gh.get_files_matching_specs("{d}/{b}{SEP}{d}/{b}*".
                                                       format(d=self.backup_dir,
                                                              b=self.basename, SEP=SEP)
                                                       .split(SEP))
            timestamped_backups = [(f, ts) for (f, ts) in sorted(zip(backup_files,
                                                                     map(get_numeric_timestamp, backup_files)),
                                                                 key=lambda f_ts: f_ts[1], reverse=True)
                                   if ((ts <= min_timestamp) or IGNORE_TIMESTAMP)]
            debug.trace_expr(5, timestamped_backups)
            if timestamped_backups:
                self.backup_filename = timestamped_backups[0][0]

            # If no suitable backup, use the older of the two files
            if ((not self.backup_filename) and self.skip_baseline):
                self.backup_filename = self.main_filename if (main_timestamp < other_timestamp) else self.other_filename
        if not self.backup_filename:
            system.exit("Error: Unable to find baseline backup for {f1} ({ts1}) and {f2} ({ts2}) ",
                        f1=self.main_filename, ts1=get_timestamp(self.main_filename),
                        f2=self.other_filename, ts2=get_timestamp(self.other_filename))
        self.check_regular_file(self.backup_filename)

        # Do the merge and check for conflicts
        # NOTE: Makes copy of each before merge in case inadvertantly clobbered (e.g., $TMP/filename1.copy)
        # TODO: produce report including diff listings of old vs. new
        system.create_directory(self.temp_base)
        temp_new_file = gh.form_path(self.temp_base, self.basename)
        gh.copy_file(self.main_filename, gh.form_path(self.temp_base, gh.basename(self.main_filename) + ".copy"))
        gh.copy_file(self.other_filename, gh.form_path(self.temp_base, gh.basename(self.other_filename) + ".copy"))
        result = gh.run("{m} {f1} {b} {f2} > {new}", m=MERGE, f1=self.main_filename,
                        b=self.backup_filename, f2=self.other_filename, new=temp_new_file)
        if re.search(r"conflict in merge", result):
            system.print_stderr("Error in merge:\n\t{r}", r=gh.indent_lines(result))
        elif self.update_file1:
            if not self.quiet:
                print("Updating {f1}, after rename to {f1}.backup".format(f1=self.main_filename))
            gh.rename_file(self.main_filename, (self.main_filename + ".backup"))
            gh.copy_file(temp_new_file, self.main_filename)
        elif self.use_stdout:
            print(system.read_entire_file(temp_new_file))
        else:
            if not self.quiet:
                print(f"Merge result:\n\t{result}")
                debug.trace(4, f"See {temp_new_file}")
        return

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    # TODO: add examples (especially with consolidated backup directory)
    app = Script(
        description=__doc__.format(prog=gh.basename(__file__)),
        skip_input=True,
        manual_input=True,
        use_temp_base_dir=True,
        boolean_options=[(IGNORE_ERRORS, "Ignore errors in processing"),
                         (UPDATE_MAIN_FILE, f"Replace {MAIN_FILENAME} with merged result--be careful"),
                         (USE_STDOUT, "Use standard output for result"),
                         (QUIET, "Omit status messages")],
        positional_arguments=[MAIN_FILENAME, OTHER_FILENAME],
        text_options=[(BACKUP_FILENAME, "Backup file for baseline"),
                      (BACKUP_DIR, "Backup directory"),
                      (BASENAME, f"Basename for backup check--if not {MAIN_FILENAME}")])
    app.run()
