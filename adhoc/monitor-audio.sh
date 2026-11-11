#!/bin/bash
#
# monitor-audio.sh: record log of applications using audio service
#
# note: via Gemini 3.1 Pro; updated via Gemini 3.8 Flash
#
# Tips for running as a persistent systemd user service:
# 1. Place or link the script in ~/.local/bin/monitor-audio.sh
# 2. Create ~/.config/systemd/user/monitor-audio.service with:
#
#    [Unit]
#    Description=Monitor Audio Events
#    After=pipewire.service pipewire-pulse.service
#
#    [Service]
#    ExecStart=%h/.local/bin/monitor-audio.sh
#    StandardOutput=append:%h/.local/share/audio-events.log
#    StandardError=append:%h/.local/share/audio-events.log
#    Restart=always
#    RestartSec=3
#
#    [Install]
#    WantedBy=default.target
#
# 3. Enable and activate:
#    systemctl --user daemon-reload
#    systemctl --user enable --now monitor-audio.service
#    systemctl --user status monitor-audio.service
#

echo "Listening for applications playing sound... (Press Ctrl+C to stop)"

# Listen for new audio streams being created
pactl subscribe | grep --line-buffered "Event 'new' on sink-input" | while read -r line; do
    ## DEBUG
    echo "line=$line"

    # Extract the stream ID from the event string
    ## TODO3: -oP => --only-matching --perl-regexp
    # ex: Event 'new' on sink-input #892
    id=$(echo "$line" | grep -oP '(?<=#)[0-9]+')

    # Slight delay to allow the app to register its name with the audio server
    sleep 0.05

    # Query the audio server for the name of the app using this ID
    ## OLD:
    ## app_name=$(pactl list sink-inputs | awk -v id="$id" '
    ##         $0 ~ "Sink Input #"id {found=1}
    ##         found && /application\.name/ {
    ##             match($0, /"([^"]+)"/, arr)
    ##             print arr[1]
    ##             exit
    ##         }
    ##     ')
    # Extract application name using Perl with fallbacks to process binary or media name
    app_name=$(pactl list sink-inputs | perl -ne '
        BEGIN { $target_id = shift @ARGV; }
        if (/Sink Input #(\d+)/) {
            $found = ($1 eq $target_id);
            next;
        }
        if ($found) {
            $name   = $1 if /application\.name = "([^"]+)"/;
            $binary = $1 if /application\.process\.binary = "([^"]+)"/;
            $media  = $1 if /media\.name = "([^"]+)"/;
            last if /^\s*$/;
        }
        END {
            my $res = $name || $binary || $media || "";
            print $res;
        }
    ' "$id")

    # Print the timestamp and the application name
    echo "$(date '+%Y-%m-%d %H:%M:%S.%3N') - Sound played by: ${app_name:-Unknown App} (Stream ID: $id)"
done
