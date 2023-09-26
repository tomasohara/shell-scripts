#!/usr/bin/env bash
#
# Workaround for gnome-terminal invocation. See
#   https://askubuntu.com/questions/1108808/gnome-terminal-fails-to-start-timed-out
# TODO (see https://askubuntu.com/questions/1478156/error-constructing-proxy-for-org-gnome-terminal)?
#   LANG="en_US.UTF-8" /usr/bin/dbus-launch /usr/bin/gnome-terminal

dbus-update-activation-environment --systemd --all
gnome-terminal &
