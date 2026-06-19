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
#-------------------------------------------------------------------------------
# TODO:
# - find happy medium between Perl and Python without using awk
#    
    

printf "%-28s %-18s %6s %6s %6s %4s\n" \
       "Mount" "Filesystem" "Size" "Used" "Avail" "Use%"

awk '!/^#/ && NF {print $2}' /etc/fstab |
    while read -r mp; do
        if [ "$mp" == "none" ]; then
            continue
        fi
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
    done
