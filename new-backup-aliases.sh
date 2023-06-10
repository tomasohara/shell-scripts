# Bash aliases (functions) for backing up a drive directory-by-directory,
# for easier restores and for easier re-start if backup script fails
# (e.g., due to lack of temporary space).
#
# Note: streamlined version of backup-aliases.sh (e.g., no support for win32)
# TODO:
# - integrate misc features added later there (e.g., modification time)
# - add features from other backup scripts/aliases (e.g., max size)
# - * put archive log in separate file (e.g., xyz.tar.log)!
#
# Usage example:
#   source ~/bin/new-backup-aliases.sh
#   backup_dir="j:/backup/tpo-esc"
#   cd c:/
#   create-backup-script
#   trace-cmd source /tmp/_do_backup.sh > ${backup_dir}/_do_backup.log 2>&1
#
# TODO: convert example to Linux
#

# Get aliases (n.b., tracing should be delayed)
shopt -s expand_aliases
# maldito shellcheck: [SC1090: Can't follow non-constant source]
# shellcheck disable=SC1090
{
    source ~/bin/tomohara-aliases.bash
}

# Initialize
backup_dir="d:/backup/tpo-net"
TMP="${TMP:-/tmp}"
nice="${NICE:-nice -19}"
tar="${TAR:-tar}"
seven_zip=7z
if [ "$(under-macos)" = "1" ]; then seven_zip=7zz; fi

# TODO: check args to override defaults

# do-backup-dir(subdir-name): Bash function to do individual directory SUBDIR. The tar file is created temporarily under /tmp [on C] to avoid overfilling the backup drive [on D].
#
# TODO:
# maldito shellcheck: SC2046 [Quote this to prevent word splitting]
# shellcheck disable=SC2046
#
function do-backup-dir () { local dir="$1";
    $nice "$tar" cvf "$TMP/$dir.tar" "$dir";
    $nice "$seven_zip" a "${backup_dir}/$dir.7z" "$TMP/$dir.tar";
    if [ $? -eq 0 ]; then
	## OLD: /bin/rm -fv "$TMP/$dir.tar";
	command rm -fv "$TMP/$dir.tar";
    else
	echo "Error: Problem running 7zip over '$TMP/$dir.tar'"
    fi
}

# redux-backup-dir: Backs up the directory only if the backup archive doesn't
# already exit.
#
function redux-backup-dir () { local dir="$1";
    if [ ! -e "${backup_dir}/$dir.7z" ]; then
	do-backup-dir "$dir"
    else 
	echo "Warning: Skipping backup for $dir since backup already exists"
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
    "$seven_zip" x -o"$TMP" "$subdir.7z"
    # Unextract tar archive (embedded in above)
    cd "$target_dir"
    tar xf "$TMP/$subdir.tar"
    cd "$current_dir"
    # Remove tar archive from temp dir
    ## OLD: /bin/rm -v "$TMP/$subdir.tar"
    command rm -v "$TMP/$subdir.tar"
}

# Prints sorted list of subdirectories proper (i.e., excluding .)
#
alias get-subdirs-proper='find . -maxdepth 1 -type d | grep -v "^\.\$" | sort -u'

# create-backup-script: creates script to invoke above other each subdirectory except backup ones and special ones like '$Recycle.Bin'
#
function create-backup-script () {
    echo "mkdir -p $backup_dir" >| "$TMP"/_do_backup.sh;
    echo "Warning: omits directories with 'backup' or '$' in name"
    # maldito shellcheck: SC2196 (info): egrep is non-standard and deprecated
    # shellcheck disable=SC2196
    get-subdirs-proper | egrep -iv '((backup)|(\$))' | perl -pe 's/^\.\/(.*)$/do-backup-dir "$1"/;' >> "$TMP"/_do_backup.sh
    ## OLD: echo "TODO: trace-cmd source $TMP/_do_backup.sh >| ${backup_dir}/_do_backup.log 2>&1;";
}

# Auxiliary alias for tracing command execution (i.e., temporarily enabling trace)
#
function trace-cmd () {
    set -o xtrace;
    ## OLD: eval "$@";
    eval "$*"
    set - -o xtrace
}

if [ "$1" = "" ]; then

cat <<USAGE_END
 
Example:

backup_dir="j:/backup/tpo-esc"
TMP=/tmp
mkdir -p "$backup_dir"
cd c:/
create-backup-script
trace-cmd source $TMP/_do_backup.sh > "${backup_dir}/_do_backup.log" 2>&1
USAGE_END

fi
