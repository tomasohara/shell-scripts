#! /usr/bin/env bash
#
# show-KDE-settings.bash: displays KDE configuration settings for each module
#
# note:
# - Based on grok.
# - Also see kconsave utility [https://github.com/Prayag2/konsave].
#

# Set bash regular and/or verbose tracing
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [[ ("$1" == "") || ("$1" == "--help") ]]; then
    script=$(basename "$0")
    ## TODO: remove following which is only meant for when ./template.bash run
    if [[ "$script" == "template.bash" ]]; then echo "Warning: not intended for standalone usage"; fi;
    ## TODO: if [[ $script ~= *\ * ]]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 -"
    echo ""
    # filter shellcheck SC2016 (info): Expressions don't expand in single quotes
    # shellcheck disable=SC2016
    echo 'ddmmmyy=$(date '+%d%b%y')'
    echo "$script - > ~/config/show-KDE-settings.\$ddmmmyy.log 2>&1"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    ## TODO: add more notes
    ## echo ""
    echo ""
    exit
fi

# Parse command-line options
# TODO: set getopt-type utility
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [[ "$moreoptions" == "1" ]]; do
    # TODO : add real options
    if [[ "$1" == "--trace" ]]; then
        set -o xtrace
    elif [[ "$1" == "--TODO-fubar" ]]; then
        ## TODO: implement
        echo "TODO-fubar"
    elif [[ ("$1" == "--") || ("$1" == "-") ]]; then
        shift
        break
    else
        echo "Error: Unknown option: $1";
        exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
# TODO: add positional arg assignment (delete if not planned)
## todo_arg1="$1"

# List all KDE Control Modules (KCMs) and Check for errors by attempting to load
##
## OLD:
## echo "Listing all available KDE Control Modules (KCMs):"
## kcmshell5 --list
##
## # Check for errors in each module by attempting to load them
##
echo -e "\nChecking for errors in each KCM (this may take a moment):"
for module in $(kcmshell5 --list | cut -f1 -d' ' | sort); do
    echo "Testing $module..."
    kcmshell5 "$module" --help > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: $module failed to load."
    fi
done

# Trace import setting configurations
# note: refined via Gemini
echo -e "\n--- KDE Configuration Dump ---\n"
#
# Core Desktop, Layout, and Window Rules
head --lines=10000 \
    ~/.config/kdeglobals \
    ~/.config/plasmarc \
    ~/.config/plasma-org.kde.plasma.desktop-appletsrc \
    ~/.config/kwinrulesrc \
    ~/.config/kwalletrc \
    ~/.config/kwinrc \
    ~/.config/kglobalshortcutsrc \
    ~/.config/khotkeysrc \
    ~/.config/plasmanotifyrc \
    ~/.config/kactivitymanagerdrc \
    ~/.config/kcminputrc \
    ~/.config/kfontinstuirc \
    ~/.config/kscreenlockerrc \
    ~/.config/powermanagementprofilesrc

## TODO:
## ... > ~/plasma-settings-dump.txt 2>/dev/null
## echo "Settings exported to ~/plasma-settings-dump.txt"
