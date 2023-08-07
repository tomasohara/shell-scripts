#! /usr/bin/env python
#
# extract_document_text.py: extract text from documents of various types
#
# NOTE:
# - Mostly a wrapper around functionality in textract package.
# - By default a suffix is added to the entire filename (e.g., fubar.docx.txt.1apr18),
#   but an affix can be used instead (e.g., fubar.docx.1apr18.txt).
#
# TODO:
# - Use file date for default date affix.
# - Handle UTF8.
#
#

"""Extract text from common document types"""

# Standard packages
import sys
import datetime

# Installed packages
import textract

# Local packages
from mezcla import system
from mezcla import debug


# Determine environment-based options
STDOUT = system.getenv_boolean("STDOUT", False)
## TODO: USE_TODAY = system.getenv_boolean("USE_TODAY", False)
## TODO: use new misc_util.get_date_ddmmmyy()
TODAY_DDMMMYY = datetime.date.today().strftime("%d%b%y").lower()
ADD_DATE = system.getenv_boolean("ADD_DATE", False)
DEFAULT_SUFFIX = "" if (STDOUT or not ADD_DATE) else TODAY_DDMMMYY
EXT = system.getenv_text("EXT", ".txt")
SUFFIX = system.getenv_text("SUFFIX", DEFAULT_SUFFIX)
USE_AFFIX = system.getenv_boolean("USE_AFFIX", False)
FORCE = system.getenv_boolean("FORCE", False)
EXTENSION = system.getenv_value("EXTENSION", None,
                                "Extension of file for conversion")


def show_usage_and_quit():
    """Show command-line usage for script and then exit"""
    ## OLD:
    ## usage = """
## Usage: {prog} [options] [input-dir] [output-file]

    usage = """
Usage: {prog} [options] [input-file] [output-file]

Options: [--help]

Notes:
- Converts documents to text
- Use following environment options:
  STDOUT: Send all output to standard output.
  EXT: File extension for output text file (e.g., .txt)
  SUFFIX: New suffix for output text file (e.g., [.txt].copy).
  ADD_DATE: Add date as suffix or affix (e.g., .txt.17mar18).
  USE_AFFIX: Put suffix before file extension (e.g., .copy[.txt]).
"""
    print(usage.format(prog=sys.argv[0]))
    sys.exit()


def document_to_text(doc_filename):
    """Returns text version of document FILENAME of unspecified type"""
    text = ""
    try:
        ## OLD: text = system.from_utf8(textract.process(doc_filename))
        text = textract.process(doc_filename,
                                extension=EXTENSION
                                ).decode("UTF-8")
    except:
        debug.trace_fmtd(3, "Warning: problem converting document file {f}: {e}",
                         f=doc_filename, e=sys.exc_info())
    return text


def main():
    """Entry point for script"""
    args = sys.argv[1:]
    debug.trace_fmtd(5, "main(): args={a}", a=args)
    affix = ""
    suffix = ""
    if SUFFIX:
        if USE_AFFIX:
            affix = ("." + SUFFIX)
        else:
            suffix = ("." + SUFFIX)
    debug.trace_fmtd(4, "affix={a} suffix={s}", a=affix, s=suffix)

    # Parse command-line arguments
    i = 0
    if (not args):
        show_usage_and_quit()
    while (args[i].startswith("-")):
        option = args[i]
        if (option == "--help"):
            show_usage_and_quit()
        else:
            sys.stderr.write("Error: unknown option '{o}'\n".format(o=option))
            show_usage_and_quit()
        i += 1

    # Process each of the arguments
    for filename in args:
        text = document_to_text(filename)
        ## TODO: file_date = datetime.datetime.fromtimestamp(os.path.getmtime(filename))
        if STDOUT:
            sys.stdout.write(system.to_utf8(text) + "\n")
        else:
            new_filename = system.remove_extension(filename) + affix + EXT + suffix
            if system.non_empty_file(new_filename) and not FORCE:
                system.print_stderr("Error: file {nf} exists. Use FORCE to overwrite".
                                    format(nf=new_filename))
            else:
                system.write_file(new_filename, text)
                print(new_filename)

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
