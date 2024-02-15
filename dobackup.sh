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
## TODO2: add --verbose
set allow_relative_backup = 0
set rel_backup_arg = "--rel-backup"
if ("$1" == "") then
    set script = `basename "$0"`
    echo "Format: dobackup [$rel_backup_arg] file_spec ..."
    echo ""
    echo "example:"
    echo ""
    echo "$0 *.perl"
    echo ""
    echo "$script $rel_backup_arg main.py tests/test_main.py"
    echo ""
    exit
endif
if ("$1" == "--rel-backup") then
    set allow_relative_backup = 1
    shift
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
    set dir = "."
    set backup_dir = "./backup"
    if ("$allow_relative_backup" == "1") then
        set dir = `dirname "$1"`
        set backup_dir = "$dir/backup"
        mkdir -p "$backup_dir"
    endif
    
    if (! -d "$fil") then
	# Output current file to backup (TODO: only do in verbose mode)
	## TODO: set basefil = "`basename ""$fil""`"
	set basefil = `basename "$fil"`
	if (-e "$dir/$basefil") then
	    echo "Backing up '$fil' to '$backup_dir/$basefil'"
        else
            echo "Warning: not backing up '$fil' to '$backup_dir/$basefil'; try $rel_backup_arg"
	endif

	# Make existing version of backup file writable
	## OLD: echo "Backing up '$fil' to '$backup_dir/$basefil'"
	## OLD: if (-e "$backup_dir/$basefil") chmod u+w "$backup_dir/$basefil"
	if (-e "$backup_dir/$basefil") then
	    chmod u+w "$backup_dir/$basefil"
	endif

	# Copy the file and remove write access
	# TODO: just issue error message if file doesn't exist (i.e., don't run cp and chmod commands)
	cp -p "$fil" "$backup_dir"
	chmod ugo-w "$backup_dir/$basefil"
    endif
    shift
end
