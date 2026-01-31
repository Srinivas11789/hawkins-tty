#!/usr/bin/env bash
# effects.sh - Visual effects for Hawkins Terminal

# Prevent multiple sourcing
[[ -n "$_HAWKINS_EFFECTS_LOADED" ]] && return 0
_HAWKINS_EFFECTS_LOADED=1

# Get script directory (works in both bash and zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    _EFFECTS_SCRIPT_DIR="${${(%):-%x}:A:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    _EFFECTS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    _EFFECTS_SCRIPT_DIR="$(dirname "$0")"
fi
source "${_EFFECTS_SCRIPT_DIR}/colors.sh"
# Note: banner.sh should be sourced before effects.sh when used in hawkins.sh

# Trap to ensure cleanup on exit
cleanup() {
    echo -e "$RESET"
    tput cnorm 2>/dev/null  # Show cursor
}

# Typewriter effect - print text character by character
typewriter() {
    local text="$1"
    local delay="${2:-0.05}"
    local color="${3:-red}"

    hawkins_color "$color"

    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done

    echo -e "$RESET"
}

# Flicker effect - make text appear to flicker like broken neon
flicker_text() {
    local text="$1"
    local duration="${2:-3}"
    local color="${3:-red}"

    trap cleanup EXIT
    tput civis 2>/dev/null  # Hide cursor

    local end_time=$((SECONDS + duration))

    while [[ $SECONDS -lt $end_time ]]; do
        # Random flicker pattern
        local pattern=$((RANDOM % 10))

        if [[ $pattern -lt 7 ]]; then
            # Normal brightness
            hawkins_color "$color"
            echo -ne "\r$text"
        elif [[ $pattern -lt 9 ]]; then
            # Dim
            echo -ne "\r${DIM}${text}${RESET}"
        else
            # Off (brief)
            echo -ne "\r$(printf '%*s' ${#text} '')"
        fi

        sleep "0.$(printf '%02d' $((RANDOM % 15 + 5)))"
    done

    # End with text visible
    hawkins_color "$color"
    echo -e "\r$text$RESET"

    tput cnorm 2>/dev/null  # Show cursor
    trap - EXIT
}

# Flicker banner effect
flicker_banner() {
    local duration="${1:-3}"

    trap cleanup EXIT
    tput civis 2>/dev/null

    local banner_lines=()
    local banner_file="${_EFFECTS_SCRIPT_DIR}/../assets/banner.txt"

    while IFS= read -r line; do
        banner_lines+=("$line")
    done < "$banner_file"

    local num_lines=${#banner_lines[@]}
    local end_time=$((SECONDS + duration))

    # Initial display
    echo -e "$TC_NEON_RED"
    for line in "${banner_lines[@]}"; do
        echo "$line"
    done

    while [[ $SECONDS -lt $end_time ]]; do
        local pattern=$((RANDOM % 10))

        # Move cursor back up
        echo -ne "\033[${num_lines}A"

        if [[ $pattern -lt 6 ]]; then
            # Full brightness
            echo -e "$TC_NEON_RED"
        elif [[ $pattern -lt 8 ]]; then
            # Dim red
            echo -e "$TC_BLOOD"
        elif [[ $pattern -lt 9 ]]; then
            # Very dim
            echo -e "${DIM}$TC_BLOOD"
        else
            # Flash to different color briefly
            echo -e "$TC_HOT_PINK"
        fi

        for line in "${banner_lines[@]}"; do
            echo "$line"
        done

        sleep "0.$(printf '%02d' $((RANDOM % 20 + 5)))"
    done

    # End with banner visible
    echo -ne "\033[${num_lines}A"
    echo -e "$TC_NEON_RED"
    for line in "${banner_lines[@]}"; do
        echo "$line"
    done
    echo -e "$RESET"

    tput cnorm 2>/dev/null
    trap - EXIT
}

# Glow effect - pulse text brightness
glow_text() {
    local text="$1"
    local cycles="${2:-3}"
    local color="${3:-red}"

    trap cleanup EXIT
    tput civis 2>/dev/null

    # Glow levels using brightness modulation
    local glow_colors
    case "$color" in
        red)   glow_colors=("$TC_BLOOD" "$TC_NEON_RED" "$TC_HOT_PINK" "$TC_NEON_RED") ;;
        pink)  glow_colors=("$TC_NEON_RED" "$TC_HOT_PINK" "$BRIGHT_WHITE" "$TC_HOT_PINK") ;;
        blue)  glow_colors=("$BLUE" "$TC_SYNTH" "$TC_ELECTRIC" "$TC_SYNTH") ;;
        green) glow_colors=("$GREEN" "$TC_SLIME" "$BRIGHT_GREEN" "$TC_SLIME") ;;
        *)     glow_colors=("$TC_BLOOD" "$TC_NEON_RED" "$TC_HOT_PINK" "$TC_NEON_RED") ;;
    esac

    for ((cycle=0; cycle<cycles; cycle++)); do
        for glow_color in "${glow_colors[@]}"; do
            echo -ne "\r${glow_color}${text}${RESET}"
            sleep 0.15
        done
    done

    # End at medium brightness
    echo -e "\r${TC_NEON_RED}${text}${RESET}"

    tput cnorm 2>/dev/null
    trap - EXIT
}

# Glitch effect - scramble characters randomly
glitch_text() {
    local text="$1"
    local duration="${2:-2}"
    local color="${3:-red}"

    trap cleanup EXIT
    tput civis 2>/dev/null

    local glitch_chars='!@#$%^&*<>[]{}|░▒▓█'
    local end_time=$((SECONDS + duration))

    while [[ $SECONDS -lt $end_time ]]; do
        local output=""
        for ((i=0; i<${#text}; i++)); do
            if [[ $((RANDOM % 10)) -lt 2 ]]; then
                # Replace with glitch character
                local glitch_idx=$((RANDOM % ${#glitch_chars}))
                output+="${glitch_chars:$glitch_idx:1}"
            else
                output+="${text:$i:1}"
            fi
        done

        hawkins_color "$color"
        echo -ne "\r$output"
        sleep 0.05
    done

    # End with original text
    hawkins_color "$color"
    echo -e "\r$text$RESET"

    tput cnorm 2>/dev/null
    trap - EXIT
}

# Scan line effect - reveal text line by line
scanline() {
    local text="$1"
    local delay="${2:-0.1}"
    local color="${3:-red}"

    hawkins_color "$color"

    while IFS= read -r line; do
        echo "$line"
        sleep "$delay"
    done <<< "$text"

    echo -e "$RESET"
}

# Quick flicker banner - brief flicker effect for startup (~250ms total)
quick_flicker_banner() {
    local banner_file="${_EFFECTS_SCRIPT_DIR}/../assets/banner.txt"

    if [[ ! -f "$banner_file" ]]; then
        echo "Banner file not found" >&2
        return 1
    fi

    trap cleanup EXIT
    tput civis 2>/dev/null

    local banner_lines=()
    while IFS= read -r line; do
        banner_lines+=("$line")
    done < "$banner_file"

    local num_lines=${#banner_lines[@]}

    # Quick flicker sequence (~250ms total)
    local flicker_pattern=(
        "$TC_BLOOD:0.03"
        "$RESET:0.02"
        "$TC_NEON_RED:0.04"
        "$TC_BLOOD:0.02"
        "$RESET:0.03"
        "$TC_HOT_PINK:0.02"
        "$TC_NEON_RED:0.05"
        "$TC_BLOOD:0.03"
        "$TC_NEON_RED:0"
    )

    for entry in "${flicker_pattern[@]}"; do
        local color="${entry%%:*}"
        local delay="${entry##*:}"

        echo -e "$color"
        for line in "${banner_lines[@]}"; do
            echo "$line"
        done

        if [[ "$delay" != "0" ]]; then
            sleep "$delay"
            # Move cursor back up for next frame
            echo -ne "\033[${num_lines}A"
        fi
    done

    echo -e "$RESET"
    tput cnorm 2>/dev/null
    trap - EXIT
}

# Typewriter effect with decorative box frame
typewriter_boxed() {
    local text="$1"
    local delay="${2:-0.03}"
    local color="${3:-purple}"

    local text_len=${#text}
    local box_width=$((text_len + 4))

    # Top border
    hawkins_color "$color"
    echo -n "╔"
    printf '═%.0s' $(seq 1 $((box_width - 2)))
    echo "╗"

    # Content line with typewriter effect
    echo -n "║ "

    for ((i=0; i<text_len; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done

    echo " ║"

    # Bottom border
    echo -n "╚"
    printf '═%.0s' $(seq 1 $((box_width - 2)))
    echo "╝"

    echo -e "$RESET"
}

# Power on effect - simulate old CRT turning on
power_on() {
    trap cleanup EXIT
    tput civis 2>/dev/null

    local term_height
    term_height=$(tput lines 2>/dev/null || echo 24)

    # Clear screen with void color
    echo -e "${BG_TC_VOID}"
    clear

    # Horizontal line expanding from center
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)
    local center=$((term_height / 2))

    # Move to center
    tput cup "$center" 0 2>/dev/null

    # Expanding line
    for ((width=1; width<=term_width; width+=4)); do
        local padding=$(( (term_width - width) / 2 ))
        tput cup "$center" 0 2>/dev/null
        printf "%*s" "$padding" ""
        echo -ne "${TC_NEON_RED}"
        printf '%.0s─' $(seq 1 $width)
        sleep 0.02
    done

    sleep 0.3
    clear

    # Show banner
    show_banner_centered "red"

    tput cnorm 2>/dev/null
    trap - EXIT
}
