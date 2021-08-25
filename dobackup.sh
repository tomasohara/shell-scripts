#! /bin/csh -f
#
# dobackup 
#
# Make a copy of the specified files (in the current directory) into
# the ./backup subdirectory. The backedup files are marked read-only.
#
# Example:
#    dobackup *.cxx *.h
#
# TODO:
# - make the setting of the read-only bit optional
# - figure out how to handle spaces in filenames with foreach
# - handle filenames starting with dashes (eg, -asciilatex.error)
# - handle filenames containing $'s (e.g., ~$exam-2.docx)
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Complain if the command-line is wrong
if ("$1" == "") then
    echo "Format: dobackup file_spec ..."
    echo ""
    echo "example:"
    echo ""
    echo "$0 *.perl"
    echo ""
    exit
endif

# Make sure that the backup directory exists
# NOTE: if the old-style BACKUP directory exists, it is used
# and a symbolic link is created 
# TODO: make BACKUP the symbolic link instead
if (! -e ./backup/. ) then
    if (-e ./BACKUP) then
	ln -s BACKUP backup
    else
	mkdir ./backup
    endif
endif

# Copy each file to the backup directory and set to read-only
# TODO: handle files with embedded spaces (e.g., for chmod processing)
while ("$1" != "")
    set fil = "$1"
    if (! -d "$fil") then
	# Output current file to backup (TODO: only do in verbose mode)
	## TODO: set basefil = "`basename ""$fil""`"
	set basefil = `basename "$fil"`
	if (-e "$basefil") then
	    echo "Backing up '$fil' to './backup/$basefil'"
	endif

	# Make existing version of backup file writable
	## OLD: echo "Backing up '$fil' to './backup/$basefil'"
	## OLD: if (-e "./backup/$basefil") chmod u+w "./backup/$basefil"
	if (-e "./backup/$basefil") then
	    chmod u+w "./backup/$basefil"
	endif

	# Copy the file and remove write access
	# TODO: just issue error message if file doesn't exist (i.e., don't run cp and chmod commands)
	cp -p "$fil" ./backup
	chmod ugo-w "./backup/$basefil"
    endif
    shift
end
