#! /bin/csh -f
#
# make-tpo-backup.sh: create tar file with backup of important
# directories on TPO's laptop andf desktop
#
# NOTE:
# - based on make-arahomot-backup.sh for NMSU laptop configuration and make-ilit-tpo-backup.sh for ILIT
#
# TODO:
# - Reconsile version from tpo-plata (tpo-cygwin-setup.bash.jul17).
# - Refine 'Full' backup into 'Complete' to include archived directories (e.g., c:/archive).
# - Add option for c:/Program-Misc and other misc c: directories (e.g., c:/cygwin/tmp)
# - add support for creating CD from this
# - figure out problem with stat
#   issuing: cvfz /f/temp/arahomot-121402.tar.gz /f/cartera-de-tomas /f/Documents\ and\ Settings/tomohara /f/tom /e/new-cyc /e/cyc /e/open-cyc c:/mybin
#   tar: Removing leading `/' from member names
#   tar: /f/Documents\\: Cannot stat: No such file or directory
#   tar: and\\: Cannot stat: No such file or directory
#   tar: Settings/tomohara: Cannot stat: No such file or directory
# - add support for registry (e.g., via XP's system state):
#   ntbackup systemstate /f c:\temp\system-state.bkf; gzip c:\temp\system-state.bkf
# - add support for 7-Zip
# - have option to resolve win32 pathnames (e.g., /my-docs => C:\Documents and Settings\Tomas\My Documents) so that can be issued remotely (e.g., from tpo-escritorio)
# - add option for case-sensitive filtering
# - regenerate and save c:/ls-alR.list (e.g., after copying to ~/config).
# - create listing with optional top-n sorting:
#      $ view-tar data-tpo-torre-012312.tar.gz > data-tpo-torre-012312.list
#      $ sort --key=3 -rn data-tpo-torre-012312.list | head -1000 > data-tpo-torre-012312.topn.sort
#   -or-
#      $ file=txstate-tpo-plata-030812.tar.gz; basename=`basename $file .tar.gz`; view-tar $basename.tar.gz | sort --key=3 -rn | head -1000 > $basename.sort
# - filter misc data directories
#   exs: Roaming   'Local/Microsoft/Windows/Temporary Internet Files'
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Determine output files and files to backup
# NOTE: Files with spaces need to be specified within embedded single quotes
# TODO: require symbolic links or Cygwin mounts instead
#   cartera-de-tomas $ mount
#   C:\Documents and Settings\tomohara\My Documents on /my-docs type system (binmode,exec)
#   C:\Documents and Settings\Tom OHara on /my-data type system (binmode,exec)
#   ...
set date = `date '+%m%d%y'`

# Determine root drive for my directories (e.g., d for d:/cartera-de-tomas)
set root_drive="`printenv TPODRIVE`"
if ($root_drive == "") set root_drive="`printenv WINDRIVE`"
if ($root_drive == "") set root_drive="c"

# TODO: handle case with different cygwin prefix (e.g., "" with /c for /cygdrive/c)
set base_dir="/cygdrive/$root_drive"
set usb_dir="/cygdrive/u"
if (! -d "$usb_dir") then
    set base_dir="/${root_drive}"
    set usb_dir="/u"
endif
if (! -d "$base_dir") then 
    set base_dir="${root_drive}:"
    ## OLD: set usb_dir="$u:"
    set usb_dir="u:"
endif
set default_backup_dirs="/my-docs  /my-data/Favorites /my-data/Desktop /my-data/SendTo "
set backup_dirs=""
## TODO: figure out problem specifying spaces
## OLD: set basic_dirs="/$root/cartera-de-tomas /my-data/Start\ Menu /my-data/SendTo "
set basic_dirs="$base_dir/cartera-de-tomas"
## set ilit_dirs="c:/ILIT c:/onyx "
## set txstate_dirs="${root_drive}:/txstate "
# NOTE: Links used to avoid space problem in file names
# links $ ls -l /links | perl -pe "s/.* (\S+) -> (.*)/\1: \2/;"
#   Basis: C:/Program Files/Basis Technology
#   Inxight: C:/Program Files/Inxight
## set data_dirs="/my-data $base_dir/config "
set data_dirs="/my-data "
## OLD: set full_dirs="$base_dir/tom ${root_drive}:/mybin "
set full_dirs="$base_dir/tom $base_dir/work $base_dir/archive "
set backup_dest_dir="$base_dir/backup"

# Determine hostname to use in filename
set host=`hostname`
if ($?HOST_NICKNAME) then
    set host="$HOST_NICKNAME"
endif
if ($host == "") then
    if ($?HOSTNAME) then
        ## DBG: echo "hostname: $HOSTNAME"
        set host="$HOSTNAME"
    endif
    if ($?HOST) then
        ## DBG: echo "host: $HOST"
        set host="$HOST"
    endif
    ## DBG: echo "h: $host"
    ## DBG: exit
endif

# Parse command-line arguments
set full=0
set basic=1
set data=0
## set txstate=0
## set other_tar_options=""
set other_tar_options="z"
set ext="tar"
set tar="tar"
set use_7zip=0
set mtime=""
## set filter_regex="[^\x00-\xFF]"		# dummy filter (excludes nothing)
## HACK: work around filtering bug
set filter_regex="fubarsky"		# dummy filter (hopefully excludes nothing)
set test=0
set show_usage=0
#
set label="basic"
if ("$1" == "") then
    set show_usage=1
endif
while ("$1" =~ -*)
    if ("$1" == "--full") then
	set full=1
   	set label="full"
    else if ("$1" == "--brief") then
	set basic=0
	set label="brief"
    else if ("$1" == "--basic") then
	set basic=1
	set label="basic"
    else if ("$1" == "--data") then
	set data=1
	set label="data"
    ## else if ("$1" == "--txstate") then
	## set txstate=1
	## set label="txstate"
    else if ("$1" == "--mtime") then
	set mtime="-mtime $2"
	shift
    else if ("$1" == "--filter") then
	set filter_regex="$2"
	shift
    else if ("$1" == "--help") then
	set show_usage=1
    else if ("$1" == "--trace") then
	set echo=1
    else if ("$1" == "--test") then
	set test=1
    else if ("$1" == "--bzip") then
	# TODO: add better work-around for stupid tar utility handling of "conflicting" -z and -j options
        # (eg, have separate option var for compression flags)
	## set other_tar_options="${other_tar_options}j"
        set other_tar_options="j"
	set ext="bz"
    else if ("$1" == "--7zip") then
        set use_7zip=1
    else if ("$1" == "--include-dir") then
	set backup_dirs="$backup_dirs $2"
	shift
    else if ("$1" == "--backup-dir") then
	set backup_dest_dir="$2"
	shift
    else
	echo "ERROR: unknown option: $1"
	# Invoke the script to show the options
	$0
	exit
    endif
    shift
end

# Optionally show usage (e.g., no arguments or if --help specified
if ("$show_usage" == "1") then
    set script_name = `basename $0`
    set date = `date '+%m%d%y'`
    set log_base = "`basename $script_name .sh`-$date.log"
    ## TODO: echo ""
    ## TODO: make sure all arguments are shown
    echo "usage: `basename $0` [--brief] [--basic] [--data] [--full] [--mtime find-mtime-spec] [--test] [--filter regex] [--trace] [--help] [--include-dir dir] [--backup-dir dir] [--bzip] [--7zip]"
    echo "" 
    echo "Simple examples:"
    echo "- $script_name --brief"
    ## echo "- $0 --brief > $backup_dest_dir/brief-${log_base} 2>&1"
    echo "- nice -19 $script_name --basic > $backup_dest_dir/basic-${log_base} 2>&1"
    echo "- nice -19 $script_name --data > $backup_dest_dir/brief-data-${log_base} 2>&1"
    echo ""
    echo "Detailed example:"
    # Note: *** The main example follows i.e., don't add changes above)! ***
    #
    echo "*** Warning: following removes all backup files for host '$host' from USB backup directory (given limited space) ***"
    echo "    if [ -d "${usb_dir}" ]; then delete-force ${usb_dir}/backup/*$host*-[0-9][0-9][0-9][0-9][0-9][0-9].tar.*; df -h ${usb_dir}; fi"
    ## OLD: echo "nice -19 $script_name --data --filter 'google|thunderbird' --include-dir $base_dir/work > $backup_dest_dir/data-${log_base} 2>&1"
    ## TODO: echo "nice -19 $script_name --data --filter 'google|thunder' --include-dir $base_dir/work > $backup_dest_dir/${log_base} 2>&1"
    ## OLD: echo "nice -19 $script_name --data --filter 'google|thunder' > $backup_dest_dir/${log_base} 2>&1"
    ## echo "my_backup_dir=$backup_dest_dir"
    ## echo "my_backup_type=data"
    echo "# TODO: Optional make sure running admin console"
    echo "my_backup_dir=$backup_dest_dir; my_backup_type=data"
    ## OLD echo "-or-: my_backup_dir=/s/backup/; my_backup_type=full"
    ## TODO: guess backup drive (e.g., via system name and/or df-info alias)
    echo "# -or-: my_backup_dir=/p/backup/; my_backup_type=full"
    echo "nice -19 /usr/bin/time $script_name --backup-dir "'$my_backup_dir'" --"'$my_backup_type'" --filter 'google|thunder' --7zip >| "'$my_backup_dir'"/"'$my_backup_type'"-${log_base} 2>&1"
    echo "ls -lthS "'$my_backup_dir'"/*${date}*"
    echo "if [ -d "${usb_dir}" ]; then mkdir -p ${usb_dir}/backup; copy-force "'$my_backup_dir'"/*${date}* ${usb_dir}/backup; fi"
    ## echo "*** TODO: tar cvfz /b/backup/juju-data.tar.gz $JJDATA > /b/backup/juju-data.tar.log 2>&1 ***"
    ## echo ""
    ## echo ""
    echo "# TODO: Remember to backup smartphone, stupid! Likewise, backup the tablet."
    echo ""
    echo "Notes:"
    ## echo ""
    echo "- All backups include ${default_backup_dirs}"
    echo "--basic will also include ${basic_dirs}"
    echo "--brief disables the default --basic (i.e., excludes ${basic_dirs})"
    echo "--data will also include ${data_dirs}"
    ## echo "--txstate will also include ${txstate_dirs} "
    echo "--full will also include ${full_dirs} ${data_dirs}"
    echo "--filter is not case sensitive and currently doesn't work with --mtime"
    echo "--include-dir adds another directory (multiple usages allowed)"
    echo "--test shows what would be backed up."
    ## TODO: echo ""
    exit
endif


# Determine output files and files to backup
if (! $data) set backup_dirs="$backup_dirs $default_backup_dirs"
if ($basic || $full) set backup_dirs="$backup_dirs $basic_dirs "
if ($data || $full) set backup_dirs="$backup_dirs $data_dirs "
## if ($txstate || $full) set backup_dirs="$backup_dirs $txstate_dirs "
if ($full) set backup_dirs="$backup_dirs $full_dirs "

# Do the backup
set tar_file=$backup_dest_dir/$label-$host-$date.$ext.gz
set backup_log=$backup_dest_dir/$label-$host-$date.log
echo "Starting backup at" `date`
if ("$mtime" != "") then
    echo "issuing: nice -19 find  $backup_dirs -type f $mtime | egrep -i -v " "$filter_regex" "| $tar cvfT${other_tar_options} $tar_file -"
    if (! $test) nice +19 find $backup_dirs -type f $mtime | egrep -i -v "$filter_regex" | $tar cvfT${other_tar_options} $tar_file - > $backup_log
else
    echo "issuing: nice +19 find $backup_dirs -type f | egrep -i -v " "$filter_regex" " | $tar cvfT${other_tar_options} $tar_file -"
    if (! $test) nice +19 find $backup_dirs -type f | egrep -i -v "$filter_regex" | $tar cvfT${other_tar_options} $tar_file - > $backup_log
endif
echo "Ending backup at" `date`

# Optionally compress the archive with 7zip
# TODO:
# - use highest compression, or let user specify the degree of compression).
# - skip tar-based gzip if 7zip used
# - use Windows version if available (e.g., 64-bit for more memory usage).
if ("$use_7zip" == 1) then
    # Make sure windows version of 7-Zip active
    # Note: This gives for better performance, as well as more memory if 32-bit Cygwin.
    ## BAD: esetenv PATH "/c/Program-Misc/windows/7-Zip:$PATH"
    set path = (${root_drive}:/Program-Misc/windows/7-Zip ${root_drive}:/cygwin/bin $PATH)

    # Use win32 version of tar file
    # ex: /c/backup/data-flaco-082718.tar.gz => c:/backup/data-flaco-082718.tar.gz
    set tar_file = `echo "$tar_file" | perl -pe "s@^/([a-z])/@\1:/@;"`
    
    # note: 7zip command line usage
    #    7z <command> [<switches>...] <archive_name> [<file_names>...]
    # where 'a' switch is for adding files. -mx9 is for maxium compression
    ## TODO: 7z a -mx9 $tar_file.7z $tar_file
    7z a $tar_file.7z $tar_file
endif

if (! $test) ls -l $tar_file* $backup_log
