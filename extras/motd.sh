#!/usr/bin/env bash
# motd.sh - Message of the Day for Hawkins Terminal
# Add to your shell profile to show on login

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAWKINS_DIR="$(dirname "$SCRIPT_DIR")"

# Source the CLI if available
if [[ -f "$HAWKINS_DIR/cli/hawkins" ]]; then
    source "$HAWKINS_DIR/cli/lib/colors.sh"
    source "$HAWKINS_DIR/cli/lib/banner.sh"
fi

# Stranger Things quotes
QUOTES=(
    "Friends don't lie."
    "Mornings are for coffee and contemplation."
    "She's our friend and she's crazy!"
    "You're going to be home soon."
    "I dump your ass."
    "Bit*hin'."
    "Mouth breather."
    "The gate... I opened it."
    "I'm the monster."
    "It's not over. It's never over."
    "We never would have upset you if we knew you had superpowers."
    "This is crazy. This is crazy. This is crazy."
    "Promise?"
    "Maybe I am a mess. Maybe I'm crazy. Maybe I'm out of my mind!"
    "It's a mind flayer."
)

# Get random quote
get_quote() {
    local idx=$((RANDOM % ${#QUOTES[@]}))
    echo "${QUOTES[$idx]}"
}

# Get time-based greeting
get_greeting() {
    local hour
    hour=$(date +%H)

    if [[ $hour -lt 6 ]]; then
        echo "The Upside Down is watching..."
    elif [[ $hour -lt 12 ]]; then
        echo "Good morning, friend."
    elif [[ $hour -lt 18 ]]; then
        echo "Good afternoon."
    elif [[ $hour -lt 22 ]]; then
        echo "Good evening."
    else
        echo "The night is dark..."
    fi
}

# Display MOTD
show_motd() {
    # Show banner if available
    if type show_banner &>/dev/null; then
        show_banner "red"
    else
        echo -e "\033[38;2;255;23;68m"
        echo "  HAWKINS TERMINAL"
        echo -e "\033[0m"
    fi

    echo
    echo -e "\033[38;2;255;171;0m$(get_greeting)\033[0m"
    echo
    echo -e "\033[38;2;213;0;249m\"$(get_quote)\"\033[0m"
    echo
    echo -e "\033[38;2;0;229;255m$(date '+%A, %B %d, %Y')\033[0m"
    echo
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_motd
fi
