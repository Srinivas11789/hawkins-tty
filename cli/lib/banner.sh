#!/usr/bin/env bash
# banner.sh - ASCII banner display for Hawkins Terminal

# Prevent multiple sourcing
[[ -n "$_HAWKINS_BANNER_LOADED" ]] && return 0
_HAWKINS_BANNER_LOADED=1

# Get script directory (works in both bash and zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    # shellcheck disable=SC2296,SC2298
    _BANNER_SCRIPT_DIR="${${(%):-%x}:A:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    _BANNER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    _BANNER_SCRIPT_DIR="$(dirname "$0")"
fi
source "${_BANNER_SCRIPT_DIR}/colors.sh"
source "${_BANNER_SCRIPT_DIR}/christmas.sh"

# Get the banner file path
BANNER_FILE="${_BANNER_SCRIPT_DIR}/../assets/banner.txt"

# Display banner with optional color
show_banner() {
    local color="${1:-red}"

    if [[ ! -f "$BANNER_FILE" ]]; then
        echo "Banner file not found: $BANNER_FILE" >&2
        return 1
    fi

    hawkins_color "$color"
    cat "$BANNER_FILE"
    echo -e "$RESET"
}

# Display banner with gradient effect (top to bottom)
show_banner_gradient() {
    local colors=("blood" "red" "pink" "red" "blood" "red")
    local line_num=0

    if [[ ! -f "$BANNER_FILE" ]]; then
        echo "Banner file not found: $BANNER_FILE" >&2
        return 1
    fi

    while IFS= read -r line; do
        local color_idx=$((line_num % ${#colors[@]}))
        hawkins_color "${colors[$color_idx]}"
        echo "$line"
        ((line_num++))
    done < "$BANNER_FILE"

    echo -e "$RESET"
}

# Display banner with random colors per character
show_banner_rainbow() {
    local colors=("red" "pink" "yellow" "green" "cyan" "blue" "purple")

    if [[ ! -f "$BANNER_FILE" ]]; then
        echo "Banner file not found: $BANNER_FILE" >&2
        return 1
    fi

    while IFS= read -r line; do
        local i=0
        while [[ $i -lt ${#line} ]]; do
            local char="${line:$i:1}"
            if [[ "$char" != " " ]]; then
                local color_idx=$((RANDOM % ${#colors[@]}))
                hawkins_color "${colors[$color_idx]}"
            fi
            echo -n "$char"
            ((i++))
        done
        echo
    done < "$BANNER_FILE"

    echo -e "$RESET"
}

# Display banner centered in terminal
show_banner_centered() {
    local color="${1:-red}"
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 80)

    if [[ ! -f "$BANNER_FILE" ]]; then
        echo "Banner file not found: $BANNER_FILE" >&2
        return 1
    fi

    hawkins_color "$color"

    while IFS= read -r line; do
        local line_length=${#line}
        local padding=$(( (term_width - line_length) / 2 ))
        if [[ $padding -gt 0 ]]; then
            printf "%*s" "$padding" ""
        fi
        echo "$line"
    done < "$BANNER_FILE"

    echo -e "$RESET"
}

# Display banner with christmas lights frame above and below
show_banner_framed() {
    local color="${1:-red}"

    if [[ ! -f "$BANNER_FILE" ]]; then
        echo "Banner file not found: $BANNER_FILE" >&2
        return 1
    fi

    # Get banner width for lights frame
    local max_width=0
    while IFS= read -r line; do
        [[ ${#line} -gt $max_width ]] && max_width=${#line}
    done < "$BANNER_FILE"

    # Top lights
    christmas_frame_static "$max_width"

    # Banner
    hawkins_color "$color"
    cat "$BANNER_FILE"
    echo -e "$RESET"

    # Bottom lights
    christmas_frame_static "$max_width"
}
