#! /usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Checks for file system differences, such as due to inadvertent recursive
# chmod issued under /.
#
# note: Via POE asssitant using mezcla template.
#

"""
Compare two recursive file system listings (e.g., ls -alR) for permission
and ownership drift. This helps in recovering from operator errors, such as
recursive chmod.

Reports:
- Files/directories missing from NEW but present in OLD
- Permission, owner, or group changes

Sample usage:
  {script} ls-alR.list.14Jul25 ls-alR.list.05Feb26
"""

# Standard modules
import os
import sqlite3
from typing import Optional, Iterator, Tuple

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system

TL = debug.TL

# ---------------------------------------------------------------------------

LS_LINE_RE = my_re.compile(
    r"""
    ^
    (?P<mode>[bcdlps\-][rwx\-]{9})\s+
    \d+\s+
    (?P<owner>\S+)\s+
    (?P<group>\S+)\s+
    \S+\s+
    (?P<date>\w+\s+\d+\s+[\d:]+)\s+
    (?P<name>.+)
    $
    """,
    my_re.VERBOSE,
)

# Environment options
#
SHOW_MISSING = system.getenv_bool(
    "SHOW_MISSING", False,
    description="Show missing files from old")

# ---------------------------------------------------------------------------

class Helper:
    """Parse ls -alR listings and compare permissions using SQLite."""

    def __init__(self, db_path: str) -> None:
        debug.trace_expr(TL.VERBOSE, db_path)
        self.db = sqlite3.connect(db_path)
        self._init_db()

    def _init_db(self) -> None:
        cur = self.db.cursor()
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS files (
                path TEXT PRIMARY KEY,
                mode TEXT,
                owner TEXT,
                grp TEXT
            )
            """
        )
        self.db.commit()

    def parse_listing(self, fh, label: Optional[str] = None) -> Iterator[Tuple[str, str, str, str]]:
        """Yield (path, mode, owner, group) from ls -alR output in file handle FH
        for LABEL listing (e.g., old)."""
        if label is None:
            label = "n/a"
        cwd = None
        in_directory = False
        dir_offset = -1

        for l, line in enumerate(fh):
            debug.trace(6, f"{label} line {l + 1}: {line!r}; {in_directory=} {dir_offset=}")

            # Make sure line non-empty
            line = line.rstrip("\n")
            if not line:
                if in_directory:
                    debug.assertion(dir_offset > 0)
                in_directory = False
                continue

            # Record directory (e.g., "./boot:") and ignore line
            if line.endswith(":") and line.startswith("."):
                cwd = line[:-1]
                debug.assertion(not in_directory)
                in_directory = True
                dir_offset = 0
                debug.trace(5, f"New directory for {label}: {cwd!r}")
                continue
            dir_offset += 1

            # Ignore line giving total (blocks) allocated in directory (e.g., "total 20")
            if my_re.match(r"^total \d+$", line):
                debug.trace(5, f"Ignoring {label} total blocks line {line!r}")
                debug.assertion(in_directory)
                debug.assertion(dir_offset == 1)
                continue
                            
            # Ignore line that doesn't given permissions (e.g., permission error report)
            m = LS_LINE_RE.match(line)
            if not m or not cwd:
                debug.trace(5, f"Ignoring {label} line {line!r}")
                continue

            # Ignore current or parent directory (e.g., ".")
            name = m.group("name")
            if name in (".", ".."):
                debug.trace(6, f"Ignoring {label} dot dir {name!r}")
                continue

            # Return next entry; ex: ("/etc/default/grub", "-rw-r--r--", "root", "operator")
            full_path = os.path.normpath(os.path.join(cwd, name))
            result = (
                full_path,
                m.group("mode"),
                m.group("owner"),
                m.group("group"),
            )
            debug.trace(7, f"yielding {result!r}")
            yield result

    def load_old(self, old_file: str) -> None:
        """Open OLD_FILE listing"""
        debug.trace(TL.USUAL, f"Loading old listing: {old_file}")
        cur = self.db.cursor()

        with system.open_file(old_file, "r", errors="ignore") as fh:
            for path, mode, owner, group in self.parse_listing(fh, label="old"):
                cur.execute(
                    "INSERT OR REPLACE INTO files VALUES (?, ?, ?, ?)",
                    (path, mode, owner, group),
                )

        self.db.commit()

    def compare_new(self, new_file: str) -> None:
        """Compare NEW_FILE listing against old, checking for permission issues, etc."""
        debug.trace(TL.USUAL, f"Comparing new listing: {new_file}")
        cur = self.db.cursor()

        seen = set()

        with system.open_file(new_file, "r", errors="ignore") as fh:
            for path, mode, owner, group in self.parse_listing(fh, label="new"):
                seen.add(path)
                row = cur.execute(
                    "SELECT mode, owner, grp FROM files WHERE path=?",
                    (path,),
                ).fetchone()

                if not row:
                    continue

                old_mode, old_owner, old_group = row

                if (mode, owner, group) != (old_mode, old_owner, old_group):
                    print(
                        f"PERM CHANGED: {path}\n"
                        f"  OLD: {old_mode} {old_owner}:{old_group}\n"
                        f"  NEW: {mode} {owner}:{group}\n"
                    )

        # Missing files
        if SHOW_MISSING:
            for (path,) in cur.execute("SELECT path FROM files"):
                if path not in seen:
                    print(f"MISSING IN NEW: {path}")

# ---------------------------------------------------------------------------

def main() -> None:
    """Entry point"""
    OLD_LISTING = "old-ls-alR"
    NEW_LISTING = "new-ls-alR"
    main_app = Main(
        skip_input=True,
        manual_input=True,
        description=__doc__.format(script=gh.basename(__file__)),
        positional_arguments=[(OLD_LISTING, "old ls -alR /"),
                              (NEW_LISTING, "new listing")],
    )

    args = main_app.parsed_args
    old_listing = args[OLD_LISTING]
    new_listing = args[NEW_LISTING]

    db_filename = "ls-diff.sqlite"
    db_path = gh.form_path(gh.get_temp_dir(), db_filename)
    debug.trace(3, f"Using temp db {db_path!r}")

    helper = Helper(db_path)
    helper.load_old(old_listing)
    helper.compare_new(new_listing)

# ---------------------------------------------------------------------------

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
