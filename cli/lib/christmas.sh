#!/usr/bin/env bash
# christmas.sh - Christmas lights animation for Hawkins Terminal

# Prevent multiple sourcing
[[ -n "$_HAWKINS_CHRISTMAS_LOADED" ]] && return 0
_HAWKINS_CHRISTMAS_LOADED=1

# Get script directory (works in both bash and zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=SC2296,SC2298
    _CHRISTMAS_SCRIPT_DIR="${${(%):-%x}:A:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    _CHRISTMAS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    _CHRISTMAS_SCRIPT_DIR="$(dirname "$0")"
fi
source "${_CHRISTMAS_SCRIPT_DIR}/colors.sh"

# Cleanup on exit
cleanup() {
    echo -e "$RESET"
    tput cnorm 2>/dev/null
}

# Christmas lights string - animated bulbs
christmas_lights() {
    local width="${1:-40}"
    local duration="${2:-10}"
    local speed="${3:-0.2}"

    trap cleanup EXIT INT
    tput civis 2>/dev/null

    local bulb_on="●"
    local bulb_off="○"
    local wire="─"

    # Light colors cycling
    local colors=(
        '\033[38;2;255;23;68m'    # Red
        '\033[38;2;0;230;118m'    # Green
        '\033[38;2;41;121;255m'   # Blue
        '\033[38;2;255;171;0m'    # Yellow/Amber
        '\033[38;2;213;0;249m'    # Purple
        '\033[38;2;0;229;255m'    # Cyan
    )

    local num_colors=${#colors[@]}
    local end_time=$((SECONDS + duration))
    local offset=0

    echo -e "${DIM}${WHITE}"

    while [[ $SECONDS -lt $end_time ]]; do
        local output=""

        for ((i=0; i<width; i++)); do
            if [[ $((i % 3)) -eq 0 ]]; then
                # This is a bulb position
                local color_idx=$(( (i / 3 + offset) % num_colors ))

                # Random chance for bulb to be "off" (flickering)
                if [[ $((RANDOM % 20)) -eq 0 ]]; then
                    output+="${DIM}${WHITE}${bulb_off}${RESET}"
                else
                    output+="${colors[$color_idx]}${bulb_on}${RESET}"
                fi
            else
                # Wire between bulbs
                output+="${DIM}${WHITE}${wire}${RESET}"
            fi
        done

        echo -ne "\r$output"

        ((offset++))
        sleep "$speed"
    done

    echo -e "\n$RESET"
    tput cnorm 2>/dev/null
    trap - EXIT INT
}

# Wall of lights - like Joyce's alphabet wall
alphabet_wall() {
    local message="${1:-HELLO}"
    local delay="${2:-0.5}"

    trap cleanup EXIT INT
    tput civis 2>/dev/null

    # The alphabet with light positions
    local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    # Colors for each letter position (cycling)
    local colors=(
        '\033[38;2;255;23;68m'    # Red
        '\033[38;2;255;171;0m'    # Amber
        '\033[38;2;0;230;118m'    # Green
        '\033[38;2;41;121;255m'   # Blue
        '\033[38;2;213;0;249m'    # Purple
        '\033[38;2;0;229;255m'    # Cyan
        '\033[38;2;255;64;129m'   # Pink
    )

    local num_colors=${#colors[@]}

    # Display the alphabet as a wall of lights (dim)
    display_wall() {
        local highlight_letter="${1:-}"
        local output=""

        for ((i=0; i<${#alphabet}; i++)); do
            local letter="${alphabet:$i:1}"
            local color_idx=$((i % num_colors))

            if [[ "$letter" == "$highlight_letter" ]]; then
                # Bright/highlighted
                output+="${colors[$color_idx]}${BOLD} ${letter} ${RESET}"
            else
                # Dim
                output+="${DIM}${WHITE} ${letter} ${RESET}"
            fi

            # Line break after M (13 letters per row)
            if [[ $i -eq 12 ]]; then
                output+="\n"
            fi
        done

        echo -e "$output"
    }

    # Initial dim wall
    echo
    display_wall

    # Spell out the message
    message="$(echo "$message" | tr '[:lower:]' '[:upper:]')"  # Convert to uppercase (Bash 3.2 compatible)

    for ((i=0; i<${#message}; i++)); do
        local letter="${message:$i:1}"

        if [[ "$letter" == " " ]]; then
            sleep "$delay"
            continue
        fi

        # Move cursor up to redraw wall
        echo -ne "\033[3A"

        # Display with highlighted letter
        display_wall "$letter"

        sleep "$delay"
    done

    # Final dim state
    sleep 0.5
    echo -ne "\033[3A"
    display_wall

    echo -e "$RESET"
    tput cnorm 2>/dev/null
    trap - EXIT INT
}

# Static christmas lights frame - horizontal string of lights (no animation)
christmas_frame_static() {
    local width="${1:-60}"

    local bulb="●"
    local wire="─"

    local colors=(
        '\033[38;2;255;23;68m'    # Red
        '\033[38;2;0;230;118m'    # Green
        '\033[38;2;41;121;255m'   # Blue
        '\033[38;2;255;171;0m'    # Yellow/Amber
        '\033[38;2;213;0;249m'    # Purple
        '\033[38;2;0;229;255m'    # Cyan
    )

    local num_colors=${#colors[@]}
    local output=""

    for ((i=0; i<width; i++)); do
        if [[ $((i % 3)) -eq 0 ]]; then
            # Bulb position
            local color_idx=$(( (i / 3) % num_colors ))
            output+="${colors[$color_idx]}${bulb}${RESET}"
        else
            # Wire
            output+="${DIM}${WHITE}${wire}${RESET}"
        fi
    done

    echo -e "$output"
}

# Background christmas lights animation for long-running commands
christmas_lights_bg() {
    local width="${1:-40}"

    trap 'echo -e "$RESET"; tput cnorm 2>/dev/null; exit 0' EXIT INT TERM

    tput civis 2>/dev/null

    local bulb_on="●"
    local wire="─"

    local colors=(
        '\033[38;2;255;23;68m'    # Red
        '\033[38;2;0;230;118m'    # Green
        '\033[38;2;41;121;255m'   # Blue
        '\033[38;2;255;171;0m'    # Yellow/Amber
        '\033[38;2;213;0;249m'    # Purple
        '\033[38;2;0;229;255m'    # Cyan
    )

    local num_colors=${#colors[@]}
    local offset=0

    # Save cursor position
    echo -ne "\033[s"

    while true; do
        local output=""

        for ((i=0; i<width; i++)); do
            if [[ $((i % 3)) -eq 0 ]]; then
                local color_idx=$(( (i / 3 + offset) % num_colors ))
                output+="${colors[$color_idx]}${bulb_on}${RESET}"
            else
                output+="${DIM}${WHITE}${wire}${RESET}"
            fi
        done

        # Restore cursor, print, then restore again
        echo -ne "\033[u\r$output"

        ((offset++))
        sleep 0.2
    done
}

# Blinking lights pattern
blink_pattern() {
    local pattern="${1:-alternating}"
    local width="${2:-30}"
    local duration="${3:-5}"

    trap cleanup EXIT INT
    tput civis 2>/dev/null

    local bulb="●"
    local colors=(
        '\033[38;2;255;23;68m'
        '\033[38;2;0;230;118m'
    )

    local end_time=$((SECONDS + duration))
    local state=0

    while [[ $SECONDS -lt $end_time ]]; do
        local output=""

        case "$pattern" in
            alternating)
                for ((i=0; i<width; i++)); do
                    local color_idx=$(( (i + state) % 2 ))
                    output+="${colors[$color_idx]}${bulb} "
                done
                ;;
            chase)
                for ((i=0; i<width; i++)); do
                    if [[ $((i % 5)) -eq $((state % 5)) ]]; then
                        output+="${colors[0]}${bulb} "
                    else
                        output+="${DIM}${WHITE}○ "
                    fi
                done
                ;;
            random)
                for ((i=0; i<width; i++)); do
                    local color_idx=$((RANDOM % 2))
                    if [[ $((RANDOM % 3)) -eq 0 ]]; then
                        output+="${DIM}${WHITE}○ "
                    else
                        output+="${colors[$color_idx]}${bulb} "
                    fi
                done
                ;;
        esac

        echo -ne "\r${output}${RESET}"

        ((state++))
        sleep 0.3
    done

    echo -e "\n$RESET"
    tput cnorm 2>/dev/null
    trap - EXIT INT
}
