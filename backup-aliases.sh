# Bash aliases (functions) for backing up a drive directory-by-directory,
# for easier restores and for easier re-start if backup script fails
# (e.g., due to lack of temporary space).
#
# usage example:
#   source ~/bin/backup-aliases.sh
#   backup_dir="f:/backup/tpo-torre/d"
#   cd d:/
#   create-backup-script /tmp/_do_d_backup.sh
#   trace-cmd source /tmp/_do_d_backup.sh >| ${backup_dir}/_do_d_backup.log 2>&1
#
# NOTE:
# - Inremental backups are done when MAX_MOD_TIME enironmen variable se.
# - 7zip seems to use current directory for temp files.
# - example default to p: drive (for WD Passport)
#
# TODO:
# - **** Add non-recursive option so that root directories can be backed up (e.g., C:\* to get ls-alR.list and other misc files but to exclude directories)!
# - *** Use 64bit version of 7Zip if available (see make-tpo-backup.sh)!
# - *** Omit gzip if 7zip also being used (i.e., xyz.tar.gz.7z to => xyz.tar.7z)
# - ** Ensure log output not buffereed (i.e., is flushed)!
# - Have option to use compressed tar archive to cut down on space requirments.
# - Make sure current disk not used for temp file (e.g, cygwin.7z.tmp).
# - Add verification step:
#   ex: $ (for f in "${backup_dir}"/*7z; do 7z l "$f"; done) >| "${backup_dir}"/_archive-test.log 2>&1
# - Resolve stuipid problem with 7zip and filenames with spaces (e.g., save with underscores)!.
#

## OLD: backup_dir="d:/backup/$HOSTNAME"
## TODO: if [ "$backup_dir" = "" ]; then backup_dir="p:/backup/$HOSTNAME"; fi
## OLD: TMP="/tmp"
## TODO: if [ "$TMP" = "" ]; then TMP=/tmp; fi

NICE_TIMED="nice -19 /usr/bin/time"

# do-backup-dir(subdir-name): Bash function to do individual directory SUBDIR.
# This first creates a tar file and then compresses than with 7Zip.
# The tar file is created temporarily under /tmp [on C] to avoid overfilling
# the backup drive [on D] during the backup operation.
#
function do-backup-dir () {
    local dir="$1";
    tar_file="$TMP/$dir.tar"
    zip_file="${backup_dir}/$dir.7z"
    #
    echo ""
    echo "start of do-backup-dir($dir): " $(date)
    # Create tar archive for directory (n.b., unless already there such as if previous 7zip failed)
    # TODO: make re-use optional
    if [ -s "$tar_file" ]; then
	echo "Warning: using existing tar file ($tar_file)"
    elif [ "$MAX_MOD_TIME" != "" ]; then
	echo "Finding modified files"
	find "$dir" -type f -mtime -$MAX_MOD_TIME -print | $NICE_TIMED tar cvfT "$TMP/$dir.tar" -
    else
	echo "Creating tar archive"
	$NICE_TIMED tar cvf "$TMP/$dir.tar" "$dir";
    fi
    ls -lh "$tar_file"
    #
    # Compress archive via 7zip
    echo "Compresssing tar archive with 7zip"
    $NICE_TIMED 7z a "$zip_file" "$tar_file";
    ls -lh "$zip_file"
    #
    if [ ! -s "${backup_dir}/$dir.7z" ]; then
	echo "Error: problem creating backup for $dir";
    fi
    # Cleanup
    if [ "$RETAIN_TEMP_TAR" != "1" ]; then
	/bin/rm -fv "$TMP/$dir.tar";
    fi
    echo "end of do-backup-dir(): " $(date)
    echo "" 
}

# winpath(filename): returns full absolute path for FILENAME in Win32 format,
# adding surround qoutations if there are embedded spaces
# ex:  win32-path "/c/Program Files" => "C:\Program Files"
#
function win32-path () {
    cygpath.exe -wa "$@" | perl -pe 's/^(.* .*)$/"$1"/g;'
}

# TODO: remove (as no longer used)???
# -or- reconcile w/ do-backup-dir (e.g., MAX_MOD_TIME support)
# do-backup-dir-win32(subdir): version of do-backup-dir using winpath for arguments
# to 7z (assuming win32 version).
# note: tar does't seem to handle d:/dir/.../filename format even though
# other cygwin Unix commands do (e.g., ls)
#
function do-backup-dir-win32 () { 
    local dir="$1";
    tar_file="$TMP/$dir.tar"
    tar_file_win32=`win32-path "$tar_file"`
    zip_file=`win32-path "${backup_dir}/$dir.7z"`
    #
    if [ -s "$tar_file" ]; then
	echo "Warning: using existing tar file ($tar_file)"
    elif [ "$MAX_MOD_TIME" != "" ]; then
	echo "Finding modified files"
	find "$dir" -type f -mtime -$MAX_MOD_TIME -print | $NICE_TIMED tar cvfT "$tar_file_win32" -
    else
	echo "Creating tar archive"
	$NICE_TIMED tar cvf "$tar_file_win32" "$dir";
    fi
    #
    echo "Compresssing tar archive with 7zip"
    $NICE_TIMED 7z a "$zip_file" "$tar_file_win32"
    if [ -s "${backup_dir}/$dir.7z" ]; then
	echo /bin/rm -fv "$TMP/$dir.tar";
    else
	echo "Error: problem creating backup for $dir";
    fi
}

# redux-backup-dir: Backs up the directory only if the backup archive doesn't
# already exit.
#
function redux-backup-dir () { 
    local dir="$1";
    if [ ! -e "${backup_dir}/$dir.7z" ]; then
	do-backup-dir "$dir"
    else 
	echo "Skipping backup for $dir since backup already exists"
    fi
}

# restore-dir(BACKUP-PATH, [target-dir=$PWD]): restore 7zip backup corresponding
# to BACKUP-PATH to the TARGET-DIR (normally the current directory). 
# NOTE: BACKUP-PATH is of the form: [dir]SUBDIR-NAME[.7z]
# EX: restore-dir /p/backup/tpo-torre/c/Temp.7z
# OLD: assumes archive in current directory called SUBDIR.7z
# old-ex: restore-dir Program-Misc
# TODO: send 7z output to stdout instead of temp file (e.g., piped into tar)
#
function restore-dir () { 
    local file="$1"; local target_dir="$2";
    local current_dir="$PWD"
    local backup_dir=`dirname "$file"`
    local subdir=`basename "$file" .7z`
    if [ "$target_dir" = "" ]; then target_dir="$current_dir"; fi;
    # Unextract 7zip archive first to temp dir
    # note: -y is to force overwrite of existing temp tar archive (e.g., /tmp/Users.tar)
    echo "Unzippng 7z archive"
    $NICE_TIMED 7z x -y -o"$TMP" "${backup_dir}/${subdir}.7z"
    # Unextract tar archive (embedded in above)
    # note: supports situation where tar archive is gzipped (via older script)
    cd "$target_dir"
    if [ ! -e "$TMP/$subdir.tar" ]; then
	echo "Unzipping tar archive"
	$NICE_TIMED gzip --decompress "$TMP/$subdir.tar.gz"
    fi
    echo "Extracting tar archive"
    tar xf "$TMP/$subdir.tar"
    cd "$current_dir"
    # Cleanup tar archive in temp dir
    /bin/rm -vf "$TMP/$subdir.tar"
}

# Prints list of subdirectories (excluding .)
#
alias subdirs-proper='find . -maxdepth 1 -type d | grep -v "^\.\$"'

# create-backup-script(script=$TMP/_do_backup.sh): creates script to invoke above other each subdirectory except backup ones and special ones like '$Recycle.Bin'
#
function create-backup-script () {
    local script="$TMP/_do_backup.sh"
    if [ "$1" != "" ]; then script="$1"; fi

    # Create backup script
    echo "#! /bin/bash" >| "$script";
    echo 'echo "start: $(date)"' >> "$script"; 

    echo '# Make sure backup aliases defined (e.g., in case backup-aliases.sh not already sourced).'
    echo '# note: this happens when running alternative startup for timing purposes)'
    echo 'do_backup_def=$(typeset -f do-backup-dir)'
    echo 'if [ "$do_backup_def" == "" ]; then source $BIN/backup-aliases.sh; fi'
    #
    echo "mkdir -p $backup_dir" >> "$script";
    echo "Warning: Ignoring 'backup' directories and those with \$'s in name"
    subdirs-proper | egrep -iv '((backup)|(\$))' | perl -pe 's/^\.\/(.*)$/do-backup-dir "$1"/;' >> "$script";
    echo 'echo "end: $(date)"' >> "$script"; 

    # Show commands for user to enter to run script with tracing
    echo ""
    echo "** Edit backup script to comment out unwanted directories or to put most important ones first. ***"
    echo
    echo "TODO: trace-cmd source "$script" >| ${backup_dir}/_do_backup.log 2>&1;";
}

# Auxiliary alias for tracing command execution (i.e., temporarily enabling trace)
#
function trace-cmd () {
    set -o xtrace;
    eval "$@";
    set - -o xtrace
}

cat <<USAGE_END

Notes:
- Use create-backup-script to create script for backup of current directory.
- Use restore-dir to extract archive created in earlier backup.
- Avoid usage of cygwin drive letter prefix (e.g., c:/) in paths
  ex: p:/backup => /p/backup
- Make sure regular temporary directory (TMP) not included in dir's to backup.
- Make sure sufficient temp space (e.g., 50 - 100 GB)!
 
Backup example:

    backup_drive=c
    target_drive=p
    type_suffix=""
    # TODO: 
    # export MAX_MOD_TIME=90    # set for inremental backup
    # type_suffix="-incr-$MAX_MOD_TIME"
    # export RETAIN_TEMP_TAR=1	# enable for debugging or redundancy
    backup_dir="/\${target_drive}/backup/$HOSTNAME/\${backup_drive}\${type_suffix}" 
    backup_base="_do_\${backup_drive}_backup"
    TMP=/\${target_drive}/temp
    backup_script="\${backup_dir}/\${backup_base}.sh"
    backup_log="\${backup_dir}/\${backup_base}.log"
    #
    mkdir -p "\$backup_dir"
    cd \${backup_drive}:/
    create-backup-script "\$backup_script"
    #
    echo "*** TODO ***"
    echo "- Modify '\$backup_script'"
    echo "- Move or delete old 7zip files to avoid in-place update"
    echo '- Backup *.* files in root directory!'
    pause.perl
    #
    trace-cmd source "\$backup_script" >| "\$backup_log" 2>&1
    # ALT but still work-in-progress (e.g., issue with temp. vars):
    #   trace-cmd /usr/bin/time nice -19 "\$backup_script" >| "\$backup_log" 2>&1

Restore example:

    restore-dir /\${target_drive}/backup/tpo-torre/c/Users.7z /d/temp
USAGE_END
