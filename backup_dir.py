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
import py7zr
import click

def create_backup_folder(source):
    """Try to create the backup folder if it doesn't exist"""
    backup_dir = os.path.join(os.environ["HOME"], socket.gethostname())
    base_dir = source.split("/")[-2]
    try:
        os.makedirs(backup_dir, exist_ok=True)
    except OSError as err:
        print(err)
    total, used, free = tuple(
        number / 1073741824 for number in shutil.disk_usage(backup_dir)
    )
    print(f"{backup_dir}: Total={total:1f} Used={used:.1f} Free={free:.1f} "
        f"{free/total*100:.1f}% of the total space)"
    )
    logging.basicConfig(
        ## OLD: filename=f"{backup_dir}/_make-{base_dir}-incremental-backup-"
        filename=f"_make-{base_dir}-incremental-backup-"
        f'{date.today().strftime("%Y%m%d")}.log',
        filemode="w",
        encoding="utf-8",
        level=logging.DEBUG,
    )
    logging.debug("Debug starts now")


def backup_derive(source, max_days_old, max_size_chars):
    """Sets type of backup depending on modification time and file max_size_chars"""
    logging.info("Starts setting basename")

    # Backup source, equivalent to $HOME/$HOSTNAME
    backup_dir = os.path.join(os.environ["HOME"], socket.gethostname())

    hostname = socket.gethostname()  ##Get's hostname
    base_dir = source.split("/")[-2]  ##Backup folder name
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
        max_days_old > 36525 and max_size_chars > 1048576
    ):  ##If 100 years and 1TB--effectively no limit
        basename = f"{backup_dir}/full-{hostname}-{base_dir}-"
    elif max_days_old > 365.25 * 5 and max_size_chars > 1024:  ##If 5 years and 1GB
        basename = f"{backup_dir}/fullish-{hostname}-{base_dir}-"
    else:
        basename = f"{backup_dir}/incr-{hostname}-{base_dir}-"
    basename = basename + date.today().strftime(
        "%Y%m%d"
    )  ##Adds date in YY-MM-DD format
    print(f"basename: {basename}")
    logging.info("basename:%s", basename)
    logging.info("Finish setting basename")
    return basename


def sort_files(walkdir, size, days):
    """Walks inside selected path and sift files based on given parameters"""
    logging.info("Starts walking inside path, some errors are expected")
    max_days_old = days * 86400  # Time in days converted to seconds
    max_size_chars = size * 1048576  # max_size_chars in megabytes converted to bytes
    lista = []  # Initializes a new empty list
    # Walks inside every source and file in walkdir
    for root, _, files in os.walk(walkdir):
        for file in files:
            try:
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
    logging.info("Starts creating tar.gz file")
    with tarfile.open(basename + ".tar.gz", "w:gz") as archive:
        for file in lista:
            try:
                archive.add(file)
            except OSError as err:  ##Broken links usually gives errors at this point
                logging.warning(err)
                pass
            except Exception as err:
                logging.critical(err)
                print(err)
    logging.info("Finish creating tar.gz file")


def create_encrypted_7z(password, basename, lista):
    """Creates a encrypted 7z file and writes files on it"""
    logging.info("Starts creating encrypted 7z file")
    with py7zr.SevenZipFile(basename + ".7z", "w", password=password) as archive:
        for file in lista:
            try:
                archive.write(file)
            except OSError as err:
                logging.warning(err)
                pass
            except Exception as err:
                logging.critical(err)
                print("Unable to continue. Please see log")
    logging.info("Finish creating encrypted 7z file")


@click.command()
@click.option(
    "--password",
    prompt=True,
    hide_input=True,
    default="",
    confirmation_prompt=True,
    help="Blank for no encryptation",
)
@click.option("-S", "--source", default=os.getcwd, help="Alternative source")
@click.option("-f", "--full", is_flag=True, help="Full backup. Overrides size and days")
@click.option("-d", "--days", required=True, type=int, help="Max days since modification")
@click.option("-s", "--size", required=True, type=int, help="Max size in MB")
def main(password, source, full, days, size):
    """Main function"""
    create_backup_folder(source)
    logging.info("Checking --full flag")
    if full:
        logging.info("Changing days and size to infinite (--full)")
        days = size = float("inf")
    basename = backup_derive(source, days, size)
    lista = sort_files(source, days, size)
    logging.info("Testing password")
    if password:
        logging.info("Password given")
        create_encrypted_7z(password, basename, lista)
    else:
        logging.info("Password not given")
        create_tar(basename, lista)


if __name__ == "__main__":
    # pylint: disable=no-value-for-parameter
    main()
