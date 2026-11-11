#! /usr/bin/env bash
#
# Shows current mount point status for external drives from /etc/fstab
#
#-------------------------------------------------------------------------------
# via POE Assistant
#
# Sample output:
#    Mount                        Filesystem           Size   Used  Avail Use%
#    /                            /dev/nvme0n1p6       538G   497G    14G  98%
#    /boot/efi                    /dev/nvme0n1p1        96M    38M    59M  39%
#    /mnt/old-vivo-fs-root        /dev/nvme0n1p5       188G   177G   2.1G  99%
#    /mnt/ntfs                    n/a                   
#    /mnt/ntfs-adhoc              /dev/sdc2            2.8T   2.5T   258G  91%
#    /mnt/resmed                  n/a                   
#    /mnt/exfat-adhoc             /dev/sdc1            2.8T   2.6T   149G  95%
#    /mnt/sd512                   n/a                   
#    /mnt/micro-sd-1tb            n/a                   
#    /mnt/wd6tbp1ext              n/a                   
#    /mnt/wd6tbp2ntfs             n/a                   
#    /mnt/micro-sd-256gb          n/a
#...............................................................................
# Format of /etc/fstab:
#   <file system> <mount point>   <type>  <options>       <dump>  <pass>
# Examples:
#   /dev/disk/by-uuid/c18192ff-4585-4df7-b891-8654be8eae49 / ext4 defaults 0 1
#   /dev/disk/by-uuid/620B-BDEE /boot/efi vfat defaults 0 2
#   /swapfile	none	swap	sw	0	0
#   /dev/mmcblk0p1 /mnt/resmed vfat nosuid,nodev,nofail,noauto,x-gvfs-show,uid=1000,gid=1000 0 0
#
## UPDATE 10 Sep 26: allows check for specified mount point

#-------------------------------------------------------------------------------
# TODO:
# - find happy medium between Perl and Python without using awk
#    

function show-mount-info {
    local mp="$1"
    if findmnt -rn "$mp" >/dev/null 2>&1; then
        df -h --output=target,source,size,used,avail,pcent "$mp" \
            | awk 'NR==2 {
                          printf "%-28s %-18s %6s %6s %6s %4s\n",
                                       $1,$2,$3,$4,$5,$6
                      }'               
    else
        printf "%-28s %-18s %6s %6s %6s %4s\n" \
               "$mp" "n/a" "" "" "" ""
    fi
}


# Display command-line usage
# TODO2: add option to hide /mnt/fstab entries
if [ "$1" == "--help" ]; then
    script=$(basename "$0")
    echo "usage: $script [mount-point ...] [-]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 /media/tomohara/UBUNTU_24_0"
    exit
fi

printf "%-28s %-18s %6s %6s %6s %4s\n" \
       "Mount" "Filesystem" "Size" "Used" "Avail" "Use%"

awk '!/^#/ && NF {print $2}' /etc/fstab |
    while read -r mp; do
        if [ "$mp" == "none" ]; then
            continue
        fi
        show-mount-info "$mp"
    done

for mp in "$@"; do
    show-mount-info "$mp"
done
