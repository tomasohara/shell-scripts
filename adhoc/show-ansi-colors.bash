#!/usr/bin/env bash
#
# Prints a table of the 256 ANSI color codes.
#
# note: via POE Assistant
#

#!/usr/bin/env bash

cube_to_rgb() {
    case $1 in
        0) echo 0;;
        1) echo 95;;
        2) echo 135;;
        3) echo 175;;
        4) echo 215;;
        5) echo 255;;
    esac
}

echo "ID   HEX       CLOSEST NAME"
echo "-------------------------------------------------------------"

for id in {0..255}; do

    if [ "$id" -lt 16 ]; then
        # System colors (hardcode hex)
        sys_hex=(
        "#000000" "#800000" "#008000" "#808000" "#000080" "#800080" "#008080" "#c0c0c0"
        "#808080" "#ff0000" "#00ff00" "#ffff00" "#0000ff" "#ff00ff" "#00ffff" "#ffffff"
        )
        hex="${sys_hex[$id]}"

    elif [ "$id" -le 231 ]; then
        i=$((id - 16))
        r=$((i / 36))
        g=$(((i % 36) / 6))
        b=$((i % 6))

        R=$(cube_to_rgb $r)
        G=$(cube_to_rgb $g)
        B=$(cube_to_rgb $b)

        hex=$(printf "#%02x%02x%02x" "$R" "$G" "$B")

    else
        gray=$((8 + (id - 232) * 10))
        hex=$(printf "#%02x%02x%02x" "$gray" "$gray" "$gray")
    fi

    # Get closest color name (via rgb_color_name.py)
    # TODO2: re-implement so done in single pass
    name=$(QUIET_MODE=1 rgb_color_name.py --hex6 <<<"$hex" \
           | awk -F, '{print $2}' \
           | tr -d '>')

    printf "\e[48;5;%sm\e[38;5;0m %3d  %-9s %-25s \e[0m\n" \
        "$id" "$id" "$hex" "$name"

done
