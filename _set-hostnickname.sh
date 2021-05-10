# Adhoc scrip to set host nickname until Bash initiation scrips resolved with respect
# to ssh login shells.
# Usage:
# $ source ~/bin/_set-hostnickname.sh

# Make sure hot nickanme set (e.g., for pwd-host-info alias)
## OLD: export HOST_NICKNAME=NLP-edge-node
if [ "$HOST_NICKNAME" = "" ]; then export HOST_NICKNAME=NLP-edge-node; fi
