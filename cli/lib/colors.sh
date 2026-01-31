#!/usr/bin/env bash
# colors.sh - Hawkins Terminal color definitions

# Prevent multiple sourcing
[[ -n "$_HAWKINS_COLORS_LOADED" ]] && return 0
_HAWKINS_COLORS_LOADED=1

# Get script directory (works in both bash and zsh)
if [[ -n "$ZSH_VERSION" ]]; then
    _COLORS_SCRIPT_DIR="${${(%):-%x}:A:h}"
elif [[ -n "$BASH_VERSION" ]]; then
    _COLORS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    _COLORS_SCRIPT_DIR="$(dirname "$0")"
fi

# Reset
RESET='\033[0m'

# Text styles
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Hawkins color palette (256-color and true color)
# Using ANSI escape sequences

# Standard ANSI colors mapped to our palette
BLACK='\033[30m'
RED='\033[31m'           # Blood #d50000
GREEN='\033[32m'         # Slime #00e676
YELLOW='\033[33m'        # Amber #ffab00
BLUE='\033[34m'          # Synth #2979ff
MAGENTA='\033[35m'       # Purple #d500f9
CYAN='\033[36m'          # Electric #00e5ff
WHITE='\033[37m'

# Bright variants
BRIGHT_BLACK='\033[90m'
BRIGHT_RED='\033[91m'    # Neon Red #ff1744
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
BRIGHT_MAGENTA='\033[95m' # Hot Pink #ff4081
BRIGHT_CYAN='\033[96m'
BRIGHT_WHITE='\033[97m'

# Background colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# True color (24-bit) - for terminals that support it
# Usage: echo -e "${TC_NEON_RED}text${RESET}"

# Primary palette
TC_VOID='\033[38;2;10;10;15m'        # #0a0a0f - Background
TC_NEON_RED='\033[38;2;255;23;68m'   # #ff1744 - Foreground/Logo
TC_HOT_PINK='\033[38;2;255;64;129m'  # #ff4081 - Cursor/Accent
TC_BLOOD='\033[38;2;213;0;0m'        # #d50000 - Dark red
TC_SLIME='\033[38;2;0;230;118m'      # #00e676 - Green
TC_AMBER='\033[38;2;255;171;0m'      # #ffab00 - Yellow
TC_SYNTH='\033[38;2;41;121;255m'     # #2979ff - Blue
TC_PURPLE='\033[38;2;213;0;249m'     # #d500f9 - Magenta
TC_ELECTRIC='\033[38;2;0;229;255m'   # #00e5ff - Cyan

# Background true colors
BG_TC_VOID='\033[48;2;10;10;15m'
BG_TC_NEON_RED='\033[48;2;255;23;68m'
BG_TC_HOT_PINK='\033[48;2;255;64;129m'
BG_TC_BLOOD='\033[48;2;213;0;0m'
BG_TC_SLIME='\033[48;2;0;230;118m'
BG_TC_AMBER='\033[48;2;255;171;0m'
BG_TC_SYNTH='\033[48;2;41;121;255m'
BG_TC_PURPLE='\033[48;2;213;0;249m'
BG_TC_ELECTRIC='\033[48;2;0;229;255m'

# Christmas light colors (for animations)
LIGHT_COLORS=(
    '\033[38;2;255;23;68m'    # Neon Red
    '\033[38;2;0;230;118m'    # Slime Green
    '\033[38;2;41;121;255m'   # Synth Blue
    '\033[38;2;255;171;0m'    # Amber Yellow
    '\033[38;2;213;0;249m'    # Purple
    '\033[38;2;0;229;255m'    # Electric Cyan
    '\033[38;2;255;64;129m'   # Hot Pink
)

# Helper function to set color
hawkins_color() {
    local color="$1"
    case "$color" in
        void)     echo -ne "$TC_VOID" ;;
        red)      echo -ne "$TC_NEON_RED" ;;
        pink)     echo -ne "$TC_HOT_PINK" ;;
        blood)    echo -ne "$TC_BLOOD" ;;
        green)    echo -ne "$TC_SLIME" ;;
        yellow)   echo -ne "$TC_AMBER" ;;
        blue)     echo -ne "$TC_SYNTH" ;;
        purple)   echo -ne "$TC_PURPLE" ;;
        cyan)     echo -ne "$TC_ELECTRIC" ;;
        reset)    echo -ne "$RESET" ;;
        *)        echo -ne "$RESET" ;;
    esac
}
