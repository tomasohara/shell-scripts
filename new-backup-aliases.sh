# Bash aliases (functions) for backing up a drive directory-by-directory,
# for easier restores and for easier re-start if backup script fails
# (e.g., due to lack of temporary space).
#
# usage example:
#   source ~/bin/backup-aliases.sh
#   backup_dir="j:/backup/tpo-esc"
#   cd c:/
#   create-backup-script
#   trace-cmd source /tmp/_do_backup.sh >| ${backup_dir}/_do_backup.log 2>&1
#

backup_dir="d:/backup/tpo-net"
TMP="/tmp"

# do-backup-dir(subdir-name): Bash function to do individual directory SUBDIR. The tar file is created temporarily under /tmp [on C] to avoid overfilling the backup drive [on D].
#
function do-backup-dir () { local dir="$1";
    tar cvf "$TMP/$dir.tar" "$dir";
    7z a "${backup_dir}/$dir.7z" "$TMP/$dir.tar";
    /bin/rm -f "$TMP/$dir.tar";
}

# redux-backup-dir: Backs up the directory only if the backup archive doesn't
# already exit.
#
function redux-backup-dir () { local dir="$1";
    if [ ! -e "${backup_dir}/$dir.7z" ]; then
	do-backup-dir "$dir"
    else 
	echo "Skipping backup for $dir since backup already exists"
    fi
}

# restore-dir(subdir-name, [target-dir=/tmp]): restore SUBDIR to TARGET
# NOTE: assumes archive in current directory called SUBDIR.7z
# ex: restore-dir Program-Misc
# TODO: send 7z output to stdout instead of temp file
#
function restore-dir () { 
    local subdir="$1"; local target_dir="$2";
    local current_dir="$PWD"
    if [ "$target_dir" = "" ]; then target_dir="$current_dir"; fi;
    # Unextract 7zip archive first to temp dir
    7z x -o"$TMP" "$subdir.7z"
    # Unextract tar archive (embedded in above)
    cd "$target_dir"
    tar xf "$TMP/$subdir.tar"
    cd "$current_dir"
    # Cleanup tar archive in temp dir
    /bin/rm -v "$TMP/$subdir.tar"
}

# Prints list of subdirectories (excluding .)
#
alias subdirs-proper='find . -maxdepth 1 -type d | grep -v "^\.\$"'

# create-backup-script: creates script to invoke above other each subdirectory except backup ones and special ones like '$Recycle.Bin'
#
function create-backup-script () {
    echo "mkdir -p $backup_dir" >| $TMP/_do_backup.sh;
    echo "Warning: 'backup' directories and those with \$'s in name"
    subdirs-proper | egrep -iv '((backup)|(\$))' | perl -pe 's/^\.\/(.*)$/do-backup-dir "$1"/;' >> $TMP/_do_backup.sh;
    echo "TODO: trace-cmd source $TMP/_do_backup.sh >| ${backup_dir}/_do_backup.log 2>&1;";
}

# Auxiliary alias for tracing command execution (i.e., temporarily enabling trace)
#
function trace-cmd () {
    set -o xtrace;
    eval "$@";
    set - -o xtrace
}

cat <<USAGE_END
 
TODO: create-backup-script

Example:

backup_dir="j:/backup/tpo-esc"
TMP=/tmp
mkdir -p "$backup_dir"
cd c:/
create-backup-script
trace-cmd source $TMP/_do_backup.sh >| "${backup_dir}/_do_backup.log" 2>&1
 
USAGE_END
