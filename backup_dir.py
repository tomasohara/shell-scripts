#!/usr/bin/env python3
#
# Python script that performs backups of the current directory. It creates a tar file
# using find to select files less than a given size in bytes and up to a given recent
# time period based on number of days. In addition, it has an option to create an
# encrypted archive either via the zip utility.
#
# Note:
# - Written by Tana A. given Bash snippets I use.
#

"""Simple program to make backups of a source based on several parameters"""
import time
import os
import socket
import shutil
import logging
import tarfile
from datetime import date
## OLD
## import py7zr
import click
from tqdm import tqdm

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system

# Environment constants
HOME_DIR = system.getenv_text("HOME", "~",
                              "User home directory")
BACKUP_DIR = system.getenv_text("BACKUP_DIR", HOME_DIR,
                                "Base directory for backups")
LOG_DIR = system.getenv_text("LOG_DIR", ".",
                             "Directory for log files")
DRY_RUN = system.getenv_bool("DRY_RUN", False, "Dry run mode")
PASSWORD_DEFAULT = system.getenv_value(
    "PASSWORD_DEFAULT", None,
    description="Default for password to avoid prompt: be careful when debugging/logging")

def create_backup_folder(source):
    """Try to create the backup folder if it doesn't exist"""
    debug.trace(6, f"create_backup_folder({source})")
    ## OLD: backup_dir = os.path.join(os.environ["HOME"], socket.gethostname())
    backup_dir = os.path.join(BACKUP_DIR, socket.gethostname())
    ## OLD: base_dir = source.split("/")[-2]
    base_dir = gh.basename(source)
    if DRY_RUN:
        system.print_stderr(f"mkdir -p {backup_dir}")
    else:
        try:
            os.makedirs(backup_dir, exist_ok=True)
        except OSError as err:
            print(f"Error creating backup directory: {err}")
            logging.error("Error creating backup directory: %err")
    total, used, free = tuple(
        number / 1073741824 for number in shutil.disk_usage(backup_dir)
    )
    #OLD:if free < total * 0.05: print("Error: Not enough space to make backup")
    print(f"{backup_dir}: Total={total:1f} Used={used:.1f} Free={free:.1f} "
        f"{free/total*100:.1f}% of the total space)"
    )
    # TODO: report error file not writable
    logging.basicConfig(
        ## OLD: filename=f"{backup_dir}/_make-{base_dir}-incremental-backup-"
        ## filename=f"_make-{base_dir}-incremental-backup-"
        filename=os.path.join(LOG_DIR, (f"_make-{base_dir}-incremental-backup-" +
                                        f'{date.today().strftime("%Y%m%d")}.log')),
        filemode="w",
        encoding="utf-8",
        level=logging.DEBUG,
    )
    logging.debug("Debug starts now")


def backup_derive(source, max_days_old, max_size_chars):
    """Sets type of backup depending on modification time and file max_size_chars"""
    debug.trace(6, f"backup_derive{(source, max_days_old, max_size_chars)}")
    logging.info("Starts setting basename")
    # Backup source, equivalent to $HOME/$HOSTNAME
    ## OLD: backup_dir = os.path.join(os.environ["HOME"], socket.gethostname())
    backup_dir = os.path.join(BACKUP_DIR, socket.gethostname())
    hostname = socket.gethostname()  ##Get's hostname
    ## OLD: base_dir = source.split("/")[-2]  ##Backup folder name
    base_dir = gh.basename(source)
    ## OLD: max_days_old=31
    ## -or-: max_days_old=92;   -or-: max_days_old=366;
    ## -or-: max_days_old=$(calc-int "5 * 365.25");
    ## -or-: max_days_old=36525                     ## (i.e., 100 years--no limit)
    ## OLD: max_size_chars=$(calc-int "5 * 1024**2")
    ## -or-: max_size_chars=131072     -or-: max_size_chars=1048577
    ## -or-: max_size_chars=1000000000 -or-: max_size_chars=1099511627776
    ##(i.e., 1TB--effectively no limit)
    ## TODO: max_days_old=$(calc-int "5 * 365.25"); max_size_chars=$(calc-int "10**9")
    # max_days_old = 5 * 365.25
    # max_size_chars = 10 ** 9
    if (
        max_days_old >= 36525 and max_size_chars >= 1048576
    ):  ##If 100 years and 1TB--effectively no limit
        basename = f"{backup_dir}/full-{hostname}-{base_dir}-"
    elif max_days_old >= 365.25 * 5 and max_size_chars >= 1024:  ##If 5 years and 1GB
        basename = f"{backup_dir}/fullish-{hostname}-{base_dir}-"
    else:
        basename = f"{backup_dir}/incr-{hostname}-{base_dir}-{max_days_old}d-{max_size_chars}mb-"
    basename = basename + date.today().strftime(
        "%Y%m%d"
    )  ##Adds date in YY-MM-DD format
    system.print_stderr(f"basename: {basename}")
    logging.info("basename:%s", basename)
    logging.info("Finish setting basename")
    return basename


def sort_files(walkdir, days, size):
    """Walks inside selected path and sift files based on given parameters"""
    debug.trace(4, f"sort_files{(walkdir, days, size)}")
    logging.info("Starts walking inside path, some errors are expected")
    max_days_old = days * 86400  # Time in days converted to seconds
    max_size_chars = size * 1048576  # max_size_chars in megabytes converted to bytes
    lista = []  # Initializes a new empty list
    # Walks inside every source and file in walkdir
    if DRY_RUN:
        system.print_stderr("Dry run: Creating list of files to backup")
    expr = os.walk(walkdir) if not DRY_RUN else tqdm(os.walk(walkdir), desc='Creating list')
    #OLD:for root, _, files in os.walk(walkdir):
    last_root = None
    for root, _, files in expr:
        if (root != last_root):
            debug.trace(5, f"new root: {root}")
            last_root = root
        debug.trace_expr(6, root, _, files)
        for file in files:
            try:
                #OLD:if os.path.getsize(filepath) < max_size_chars and time.time() - os.path.getmtime(filepath) < max_days_old
                # TODO: add  option to exclude metafiles (e.g., @PaxHeader under MacOS)
                if (
                    os.stat(os.path.join(root, file)).st_size < max_size_chars
                    and time.time() - os.path.getmtime(os.path.join(root, file))
                    < max_days_old
                ):  ##If size is less than max size and time (in epoch seconds) less than max days
                    lista.append(os.path.join(root, file))
            except OSError as err:
                logging.warning(err)
                pass
    logging.debug("list: %s", lista)
    logging.info("Finish walking inside path")
    return lista


def create_tar(basename, lista):
    """Creates a simple 7z file and writes files on it"""
    debug.trace(5, f"create_tar({basename}, _)")
    debug.trace_expr(6, lista)
    logging.info("Starts creating tar.gz file")
    if DRY_RUN:
        system.print_stderr("Dry run, no archive will be created")
        system.print_stderr(f"Creating archive {basename}.tar.gz")
        for _ in tqdm(lista, desc="Creating archive"):
            time.sleep(0.001)
            pass
    else:
        with tarfile.open(basename + ".tar.gz", "w:gz") as archive:
            for file in tqdm(lista, desc="Creating archive"):
                try:
                    archive.add(file)
                except OSError as err:  ##Broken links usually gives errors at this point
                    logging.warning(err)
                    pass
                except Exception as err:              # pylint: disable=broad-except
                    logging.critical(err)
                    print(err)
        logging.info("Finish creating tar.gz file")

def create_encrypted_tar(password, basename):
    """Creates a GPG encrypted tar.gz file"""
    debug.trace(4, f"create_encrypted_7z(********, _)")
    logging.info("Starts creating encrypted tar.gz file")
    os.system(
        f"gpg --batch --yes --passphrase {password} --symmetric {basename}.tar.gz"
    )
    os.remove(f"{basename}.tar.gz")
    logging.info("Finish creating encrypted tar.gz file")


def create_encrypted_7z(password, basename, lista):
    """Creates a encrypted 7z file and writes files on it"""
    debug.trace(4, f"create_encrypted_7z(********, {basename}, _)")
    debug.trace_expr(6, lista)
    logging.info("Starts creating encrypted 7z file")
    import py7zr                         # pylint: disable=import-outside-toplevel
    with py7zr.SevenZipFile(basename + ".7z", "w", password=password) as archive:
        for file in tqdm(lista, desc="Creating archive"):
            try:
                archive.write(file)
            except OSError as err:
                logging.warning(err)
                pass
            except Exception as err:              # pylint: disable=broad-except
                logging.critical(err)
                ## OLD: print("Unable to continue. Please see log")
                system.print_error("Unable to continue:\n\t{err}")
    logging.info("Finish creating encrypted 7z file")


def deactivate_prompts(ctx, _, value):
    """Deactivates prompt except if -f is on (e.g., password prompt if full backup)"""
    debug.trace(6, f"deactivate_prompts{(ctx, _, value)}")
    if not value:
        for param in ctx.command.params:
            param.prompt = None
    return value


@click.command()
@click.option("-f", "--full", is_flag=True, help="Full backup. Overrides size and days", callback=deactivate_prompts)
@click.option(
    "--password",
    prompt=True,
    hide_input=True,
    ## OLD: default="",
    default=(PASSWORD_DEFAULT or ""),
    confirmation_prompt=True,
    help="Blank for no encryption",
)
@click.option("-S", "--source", default=os.getcwd, help="Alternative source")
## OLD
## @click.option("-d", "--days", required=True, type=int, help="Max days since modification")
## @click.option("-s", "--size", required=True, type=int, help="Max size in MB")
@click.option("-d", "--days", type=int, help="Max days since modification")
@click.option("-s", "--size", type=float, help="Max size in MB")
@click.option(
    "-g",
    "--gpg",
    is_flag=True,
    help="Alternative encrypt using gpg. Faster but requires a Linux system",
)
@click.option('--DRY_RUN', is_flag=True)

def main(password, source, full, days, size, gpg, dry_run): # pylint: disable=too-many-arguments
    """Main function"""
    debug.trace_fmt(3, "main{args}",
                    args=(password, source, full, days, size, gpg, dry_run))
    #
    # note: --dry-run overrides DRY_RUN
    global DRY_RUN
    DRY_RUN = dry_run
    #
    if DRY_RUN:
        logging.info("Dry run")
        system.print_stderr("Dry run")
    #
    create_backup_folder(source)
    logging.info("Checking --full flag")
    if full:
        logging.info("Changing days and size to infinite (--full)")
        debug.assertion(not (days or size))
        days = size = float("inf")
    if not days:
        days = 30
        system.print_stderr(f"FYI: Using {days} days")
    if not size:
        size = 10
        system.print_stderr(f"FYI: Using {size} size [mb]")

    basename = backup_derive(source, days, size)
    lista = sort_files(source, days, size)
    debug.trace_expr(5, lista, max_len=8192)
    logging.info("Testing password")
    if password:
        if gpg:
            create_tar(basename, lista)
            create_encrypted_tar(password, basename)
        else:
            logging.info("Password given")
            create_encrypted_7z(password, basename, lista)
    else:
        logging.info("Password not given")
        create_tar(basename, lista)


if __name__ == "__main__":
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    # pylint: disable=no-value-for-parameter
    main()
