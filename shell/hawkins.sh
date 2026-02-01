#!/usr/bin/env bash
# hawkins.sh - Complete Hawkins Terminal shell integration
# Source this in your ~/.bashrc or ~/.zshrc for the full experience

# Prevent multiple sourcing
[[ -n "$_HAWKINS_SHELL_LOADED" ]] && return 0
_HAWKINS_SHELL_LOADED=1

# =============================================================================
# CONFIGURATION DEFAULTS
# =============================================================================

# Source user config if it exists (created by install-light/install-rich)
[[ -f "${HOME}/.config/hawkins-terminal/env" ]] && source "${HOME}/.config/hawkins-terminal/env"

: "${HAWKINS_ACTIVE:=1}"
: "${HAWKINS_FLICKER_STARTUP:=1}"
: "${HAWKINS_LIGHTS_FRAME:=1}"
: "${HAWKINS_ANIMATE_QUOTE:=1}"
: "${HAWKINS_SHOW_DEMOGORGON:=1}"
: "${HAWKINS_MINIMAL:=0}"
: "${HAWKINS_SHOW_SUCCESS:=1}"
: "${HAWKINS_SUCCESS_THRESHOLD:=0}"   # Seconds before showing success (0 = all commands)
: "${HAWKINS_DISPLAY_MODE:=rich}"     # Display mode: rich | light
: "${HAWKINS_COLORIZE_COMMANDS:=1}"  # Enable colored ls/grep aliases (0 to disable)

# Detect hawkins-terminal installation directory
if [[ -f "${HOME}/.config/hawkins-terminal/path" ]]; then
    _HAWKINS_DIR="$(cat "${HOME}/.config/hawkins-terminal/path")"
elif [[ -n "$HAWKINS_TERMINAL_DIR" ]]; then
    _HAWKINS_DIR="$HAWKINS_TERMINAL_DIR"
else
    # Try to find it relative to this script, resolving symlinks
    _HAWKINS_SH_SOURCE="${BASH_SOURCE[0]:-$0}"
    while [[ -L "$_HAWKINS_SH_SOURCE" ]]; do
        _HAWKINS_SH_DIR="$(cd -P "$(dirname "$_HAWKINS_SH_SOURCE")" && pwd)"
        _HAWKINS_SH_SOURCE="$(readlink "$_HAWKINS_SH_SOURCE")"
        [[ "$_HAWKINS_SH_SOURCE" != /* ]] && _HAWKINS_SH_SOURCE="$_HAWKINS_SH_DIR/$_HAWKINS_SH_SOURCE"
    done
    _HAWKINS_DIR="$(cd -P "$(dirname "$_HAWKINS_SH_SOURCE")/.." && pwd)"
fi

# Verify installation
if [[ ! -f "$_HAWKINS_DIR/cli/hawkins" ]]; then
    echo "Hawkins Terminal not found at $_HAWKINS_DIR" >&2
    return 1
fi

# Source library files
source "$_HAWKINS_DIR/cli/lib/colors.sh"
source "$_HAWKINS_DIR/cli/lib/christmas.sh"
source "$_HAWKINS_DIR/cli/lib/banner.sh"
source "$_HAWKINS_DIR/cli/lib/effects.sh"

# =============================================================================
# ACTIVATION/DEACTIVATION SYSTEM
# =============================================================================

# Save original shell state on first source
if [[ -z "$_HAWKINS_STATE_SAVED" ]]; then
    _HAWKINS_STATE_SAVED=1
    _HAWKINS_ORIG_PROMPT_COMMAND="$PROMPT_COMMAND"
    _HAWKINS_ORIG_PS1="$PS1"
    if [[ -n "$ZSH_VERSION" ]]; then
        # Save zsh hook state
        _HAWKINS_HAD_PREEXEC=0
        _HAWKINS_HAD_PRECMD=0
    fi
fi

# Activate Hawkins mode (enable all effects)
hawkins_activate() {
    HAWKINS_ACTIVE=1
    HAWKINS_MINIMAL=0
    echo -e "${TC_SLIME}▌${RESET} Hawkins mode activated"

    # Re-show startup if in interactive shell
    if [[ $- == *i* ]] && [[ -t 1 ]]; then
        _hawkins_show_startup
    fi
}

# Deactivate Hawkins mode (restore original shell state)
hawkins_deactivate() {
    HAWKINS_ACTIVE=0

    # Restore original prompt command (bash)
    if [[ -n "$BASH_VERSION" ]]; then
        PROMPT_COMMAND="$_HAWKINS_ORIG_PROMPT_COMMAND"
        # Remove DEBUG trap
        trap - DEBUG
    fi

    # Restore original PS1 if we changed it
    if [[ -n "$_HAWKINS_ORIG_PS1" ]]; then
        PS1="$_HAWKINS_ORIG_PS1"
    fi

    # For zsh, hooks remain but check HAWKINS_ACTIVE

    echo -e "${TC_AMBER}▌${RESET} Hawkins mode deactivated"
}

# =============================================================================
# STARTUP BANNER
# =============================================================================

_hawkins_show_startup() {
    local show_banner="${HAWKINS_SHOW_BANNER:-1}"
    local show_quote="${HAWKINS_SHOW_QUOTE:-1}"
    local minimal="${HAWKINS_MINIMAL:-0}"

    # Skip in non-interactive shells or subshells
    [[ ! -t 1 ]] && return
    [[ -n "$HAWKINS_SUPPRESS_BANNER" ]] && return
    [[ "$HAWKINS_ACTIVE" != "1" ]] && return

    # Minimal mode - just a colored line
    if [[ "$minimal" == "1" ]]; then
        echo -e "${TC_NEON_RED}━━━ HAWKINS ━━━${RESET}"
        return
    fi

    # LIGHT mode - simplified startup without effects
    if [[ "${HAWKINS_DISPLAY_MODE:-rich}" == "light" ]]; then
        if [[ "$show_banner" == "1" ]] && [[ -f "$_HAWKINS_DIR/cli/assets/banner.txt" ]]; then
            echo -e "$TC_NEON_RED"
            cat "$_HAWKINS_DIR/cli/assets/banner.txt"
            echo -e "$RESET"
        fi

        if [[ "$show_quote" == "1" ]]; then
            local quotes=(
                "Friends don't lie."
                "Mornings are for coffee and contemplation."
                "She's our friend and she's crazy!"
                "Bit*hin'."
                "Mouth breather."
                "The gate... I opened it."
                "It's not over."
            )
            local idx=$((RANDOM % ${#quotes[@]}))
            local quote="${quotes[$idx]}"
            echo -e "${TC_PURPLE}\"${quote}\"${RESET}"
            echo
        fi
        return
    fi

    # RICH mode - Full banner with effects
    if [[ "$show_banner" == "1" ]] && [[ -f "$_HAWKINS_DIR/cli/assets/banner.txt" ]]; then
        # Top lights frame
        if [[ "${HAWKINS_LIGHTS_FRAME:-1}" == "1" ]]; then
            christmas_frame_static 57
        fi

        # Banner with optional flicker effect
        if [[ "${HAWKINS_FLICKER_STARTUP:-1}" == "1" ]]; then
            quick_flicker_banner
        else
            echo -e "$TC_NEON_RED"
            cat "$_HAWKINS_DIR/cli/assets/banner.txt"
            echo -e "$RESET"
        fi

        # Bottom lights frame
        if [[ "${HAWKINS_LIGHTS_FRAME:-1}" == "1" ]]; then
            christmas_frame_static 57
        fi
    fi

    # Quote with optional typewriter effect
    if [[ "$show_quote" == "1" ]]; then
        local quotes=(
            "Friends don't lie."
            "Mornings are for coffee and contemplation."
            "She's our friend and she's crazy!"
            "Bit*hin'."
            "Mouth breather."
            "The gate... I opened it."
            "It's not over."
        )
        local idx=$((RANDOM % ${#quotes[@]}))
        local quote="${quotes[$idx]}"

        echo
        if [[ "${HAWKINS_ANIMATE_QUOTE:-1}" == "1" ]]; then
            typewriter_boxed "\"$quote\"" 0.03 purple
        else
            echo -e "${TC_PURPLE}\"${quote}\"${RESET}"
        fi
        echo
    fi
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Last command status tracking
_hawkins_last_exit=0
_hawkins_cmd_started=0

_hawkins_preexec() {
    # Called before each command (zsh has preexec, bash needs DEBUG trap)
    # Skip during shell initialization
    [[ -z "$_HAWKINS_INIT_COMPLETE" ]] && return
    # Skip our own functions to prevent recursion in DEBUG trap
    [[ -n "$BASH_VERSION" ]] && [[ "${BASH_COMMAND:-}" == _hawkins_* ]] && return

    _hawkins_cmd_start=$SECONDS
    _hawkins_cmd_started=1
}

_hawkins_precmd() {
    _hawkins_last_exit=$?
    local duration=$(( SECONDS - ${_hawkins_cmd_start:-$SECONDS} ))

    # Only show error/success after user has actually run a command
    # (prevents showing errors from startup initialization)
    if [[ "$_hawkins_cmd_started" != "1" ]]; then
        return
    fi
    _hawkins_cmd_started=0

    # Show error message for failed commands
    if [[ $_hawkins_last_exit -ne 0 ]]; then
        _hawkins_show_error $_hawkins_last_exit
    elif [[ $duration -ge ${HAWKINS_SUCCESS_THRESHOLD:-0} ]] && [[ "$HAWKINS_ACTIVE" == "1" ]] && [[ "${HAWKINS_SHOW_SUCCESS:-1}" == "1" ]]; then
        # Show success message for commands that meet the threshold
        _hawkins_show_success
    fi

    # Show duration for long commands
    if [[ $duration -gt 5 ]] && [[ "$HAWKINS_ACTIVE" == "1" ]]; then
        echo -e "${TC_SYNTH}Command took ${duration}s${RESET}"
    fi
}

_hawkins_show_error() {
    local exit_code=$1
    local error_msg=""

    # Skip if Hawkins is not active
    [[ "$HAWKINS_ACTIVE" != "1" ]] && return

    # Common exit codes with Stranger Things flavor
    case $exit_code in
        1)   error_msg="Something's wrong... (general error)" ;;
        2)   error_msg="Misuse of shell command" ;;
        126) error_msg="Permission denied - the gate is closed" ;;
        127) error_msg="Command not found - lost in the Upside Down" ;;
        128) error_msg="Invalid exit argument" ;;
        130) error_msg="Interrupted (Ctrl+C) - you escaped" ;;
        137) error_msg="Killed (SIGKILL) - the Demogorgon got it" ;;
        139) error_msg="Segmentation fault - reality fractured" ;;
        143) error_msg="Terminated (SIGTERM)" ;;
        *)   error_msg="Exit code: $exit_code" ;;
    esac

    # Vecna's whispers, Erica's sass, and messages from the Upside Down
    local taglines=(
        # Vecna
        '"You have broken." - Vecna'
        '"I see your pain." - Vecna'
        '"You cannot escape your past." - Vecna'
        '"Join me." - Vecna'
        '"It is time." - Vecna'
        '"You are not special." - Vecna'
        '"You were my first victim." - Vecna'
        '"You broke so easily." - Vecna'
        '"Your suffering is almost over." - Vecna'
        '"I have seen into your mind." - Vecna'
        '"You are not special. You are broken." - Vecna'
        '"The clock is ticking." - Vecna'
        '"Welcome to my world." - Vecna'
        '"You have lost." - Vecna'
        '"There is no saving you." - Vecna'
        '"I have been waiting for you." - Vecna'
        '"Your memories betray you." - Vecna'
        '"This is only the beginning." - Vecna'
        '"You feel it, dont you?" - Vecna'
        '"One by one." - Vecna'
        # Erica (sassy commentary on your failure)
        '"You can'\''t spell America without Erica." - Erica'
        '"I'\''m ten, you bald b*stard." - Erica'
        '"Just the facts." - Erica'
        '"Nerd!" - Erica'
        '"You know what I love most about this country? Capitalism." - Erica'
        '"I'\''m not stupid. I'\''m smarter than most of you." - Erica'
        '"Code Red? I got a Code Shut Your Mouth." - Erica'
        '"Oh please, I'\''m not a nerd. I'\''m a financier." - Erica'
        '"Eat your d*mn pie." - Erica'
        '"I am Eleven, you long-haired freak." - Erica'
        '"I am not a nerd, nerd!" - Erica'
        '"More fudge." - Erica'
        '"Enough." - Erica'
        '"You do what this man tells you, you'\''re ALL GONNA DIE!" - Erica'
        # Upside Down messages
        "~ THE UPSIDE DOWN ~"
        "~ IT'S FEEDING TIME ~"
        "~ RUN. ~"
        "~ THE GATE IS OPEN ~"
        "~ IT KNOWS YOU'RE HERE ~"
        "~ NO ESCAPE ~"
        "~ THE MIND FLAYER WATCHES ~"
        "~ ELEVEN CAN'T SAVE YOU ~"
        "~ DARKNESS CONSUMES ~"
        "~ YOU SHOULDN'T BE HERE ~"
        "~ THE PARTICLES ARE MOVING ~"
        "~ HAWKINS WILL FALL ~"
        "~ FOUR CHIMES ~"
        "~ THE RIFT GROWS ~"
    )
    local tag_idx=$((RANDOM % ${#taglines[@]}))
    local tagline="${taglines[$tag_idx]}"

    # LIGHT mode: Simple error display without ASCII art
    if [[ "${HAWKINS_DISPLAY_MODE:-rich}" == "light" ]]; then
        echo -e "${TC_NEON_RED}✗ ERROR: ${error_msg}${RESET}"
        echo -e "${TC_BLOOD}${tagline}${RESET}"
        return
    fi

    # RICH mode: Full display with effects and ASCII art

    # Brief screen flash effect
    echo -ne "${BG_TC_BLOOD}"
    sleep 0.03
    echo -ne "${RESET}"
    sleep 0.02
    echo -ne "${BG_TC_NEON_RED}"
    sleep 0.02
    echo -ne "${RESET}"

    # Show Demogorgon ASCII art with error message on the side
    if [[ "${HAWKINS_SHOW_DEMOGORGON:-1}" == "1" ]] && [[ -f "$_HAWKINS_DIR/cli/assets/demogorgon.txt" ]]; then
        echo
        # Read demogorgon into array and print with message at center
        local lines=()
        while IFS= read -r line; do
            lines+=("$line")
        done < "$_HAWKINS_DIR/cli/assets/demogorgon.txt"

        local total=${#lines[@]}
        local mid=$((total / 2))
        local padding="   "

        for ((i=0; i<total; i++)); do
            if [[ $i -eq $((mid - 1)) ]]; then
                # Error line (bold)
                printf "${TC_BLOOD}%-22s${padding}${BOLD}${TC_NEON_RED}ERROR: %s${RESET}\n" "${lines[$i]}" "$error_msg"
            elif [[ $i -eq $mid ]]; then
                # Tagline
                printf "${TC_BLOOD}%-22s${padding}${TC_BLOOD}%s${RESET}\n" "${lines[$i]}" "$tagline"
            else
                echo -e "${TC_BLOOD}${lines[$i]}${RESET}"
            fi
        done
        echo
    else
        # Fallback if no demogorgon
        echo -e "${TC_NEON_RED}▌${BOLD} ERROR: ${error_msg}${RESET}"
    fi
}

_hawkins_show_success() {
    # Skip if Hawkins is not active
    [[ "$HAWKINS_ACTIVE" != "1" ]] && return

    # Character quotes from the "good" Stranger Things characters
    local quotes=(
        # Eleven
        '"Friends dont lie." - Eleven'
        '"I can do it." - Eleven'
        '"Bit*hin'"'"'." - Eleven'
        '"I dump your ass." - Eleven'
        # Hopper
        '"Mornings are for coffee and contemplation." - Hopper'
        '"Keep the door open 3 inches." - Hopper'
        '"You'"'"'re a good kid, you know that?" - Hopper'
        # Joyce
        '"This is not crazy. This is real!" - Joyce'
        '"I will never stop looking for him." - Joyce'
        '"I know my son." - Joyce'
        # Dustin
        '"She'"'"'s our friend and she'"'"'s crazy!" - Dustin'
        '"I am on a curiosity voyage." - Dustin'
        '"Just wait till we tell Will." - Dustin'
        '"You got the job!" - Dustin'
        '"Son of a bit*h. You'"'"'re really no help at all." - Dustin'
        '"If you die, I die." - Dustin'
        '"Dude, you did it! You won a fight!" - Dustin'
        '"Everyone'"'"'s getting a t-shirt." - Dustin'
        '"This is a groundbreaking scientific discovery." - Dustin'
        '"What'"'"'s Planck'"'"'s constant? 6.62607004." - Dustin'
        '"You just saved the world." - Dustin'
        # Steve
        '"Henderson! Get in here!" - Steve'
        '"Ahoy ladies!" - Steve'
        '"Six nuggets. For real?" - Steve'
        '"Me Three." - Steve'
        '"I may be a pretty shitty boyfriend, but it turns out I'"'"'m a pretty good babysitter." - Steve'
        '"That settles it." - Steve'
        # Robin
        '"How many children are you friends with?" - Robin'
        '"Dingus!" - Robin'
        '"You rule, you know that?" - Robin'
        '"I'"'"'m Robin. As in bird." - Robin'
        '"We'"'"'re not even in the game; we'"'"'re on the bench." - Robin'
        '"Secret Russians? I don'"'"'t know, I guess I just wanted it to be real." - Robin'
        '"Ask me tomorrow." - Robin'
        # Eddie
        '"This is music!" - Eddie'
        '"I didn'"'"'t run away this time, right?" - Eddie'
        '"Most metal ever!" - Eddie'
        '"Chrissy, this is for you!" - Eddie'
        # Max
        '"I'"'"'m not afraid of you." - Max'
        '"Lucas, I'"'"'m still here." - Max'
        '"I was angry at everything. I just needed someone to blame." - Max'
        # Murray
        '"Bald eagle. Bald eagle!" - Murray'
        '"It'"'"'s all connected!" - Murray'
        '"Why is this four year old speaking to me?" - Murray'
        # Lucas
        '"We never would'"'"'ve found Will without you." - Lucas'
        '"He farted." - Lucas'
        # Will
        '"It'"'"'s like home, but it'"'"'s so dark and empty." - Will'
        '"What if he figures out we'"'"'re spying on him? What if he spies back?" - Will'
        '"And I'"'"'m always there for you too." - Will'
        # Nancy
        '"I wanted to be different, I guess." - Nancy'
        '"What did you do?" - Nancy'
        '"I want to kill it." - Nancy'
        '"It'"'"'s bullsh*t." - Nancy'
        # Hopper
        '"This is not real, this is a kids game." - Hopper'
        '"Joyce, drive!" - Hopper'
    )

    local quote_idx=$((RANDOM % ${#quotes[@]}))
    local quote="${quotes[$quote_idx]}"

    # LIGHT mode: Simple one-liner, no ASCII art
    if [[ "${HAWKINS_DISPLAY_MODE:-rich}" == "light" ]]; then
        echo -e "${TC_SLIME}✓${RESET} ${TC_SLIME}${quote}${RESET}"
        return
    fi

    # RICH mode: Full display with ASCII art

    # Alternate between waffle and walkie-talkie art
    local art_choice=$((RANDOM % 2))

    echo
    if [[ $art_choice -eq 0 ]]; then
        # Waffle ASCII art
        echo -e "${TC_SLIME} ╔═╦═╗${RESET}"
        echo -e "${TC_SLIME} ╠═╬═╣${RESET}  ${TC_SLIME}${quote}${RESET}"
        echo -e "${TC_SLIME} ╚═╩═╝${RESET}"
    else
        # Walkie-talkie ASCII art
        echo -e "${TC_SLIME} ┌───┐${RESET}"
        echo -e "${TC_SLIME} │:::│${RESET}  ${TC_SLIME}${quote}${RESET}"
        echo -e "${TC_SLIME} │ ▪ │${RESET}"
        echo -e "${TC_SLIME} └─┬─┘${RESET}"
        echo -e "${TC_SLIME}   │${RESET}"
    fi
}

# =============================================================================
# STYLED OUTPUT HELPERS
# =============================================================================

# Info message
hawkins_info() {
    echo -e "${TC_SYNTH}▌${RESET} $*"
}

# Success message
hawkins_success() {
    echo -e "${TC_SLIME}▌${RESET} $*"
}

# Warning message
hawkins_warn() {
    echo -e "${TC_AMBER}▌${RESET} $*"
}

# Error message (manual use)
hawkins_error() {
    echo -e "${TC_NEON_RED}▌${TC_BLOOD} $*${RESET}"
}

# Highlight/accent
hawkins_accent() {
    echo -e "${TC_HOT_PINK}$*${RESET}"
}

# Header/title
hawkins_header() {
    local text="$*"
    local width=${#text}
    echo
    echo -e "${TC_NEON_RED}┌$(printf '─%.0s' $(seq 1 $((width + 2))))┐${RESET}"
    echo -e "${TC_NEON_RED}│ ${TC_HOT_PINK}${text}${TC_NEON_RED} │${RESET}"
    echo -e "${TC_NEON_RED}└$(printf '─%.0s' $(seq 1 $((width + 2))))┘${RESET}"
    echo
}

# =============================================================================
# COMMAND WRAPPERS (opt-in via HAWKINS_COLORIZE_COMMANDS)
# =============================================================================

if [[ "${HAWKINS_COLORIZE_COMMANDS:-1}" == "1" ]]; then
    # Styled ls
    if command -v gls &>/dev/null; then
        _hawkins_ls_cmd='gls --color=auto'
    elif ls --color=auto &>/dev/null 2>&1; then
        _hawkins_ls_cmd='ls --color=auto'
    else
        _hawkins_ls_cmd='ls -G'
    fi
    
    # Define alias after determining command
    # shellcheck disable=SC2139
    alias ls="$_hawkins_ls_cmd"

    alias ll='ls -lah'
    alias la='ls -a'

    # Styled grep
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    # Styled diff (if colordiff available)
    if command -v colordiff &>/dev/null; then
        alias diff='colordiff'
    fi
fi

# =============================================================================
# SHELL-SPECIFIC SETUP
# =============================================================================

if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh setup
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _hawkins_preexec
    add-zsh-hook precmd _hawkins_precmd

    # Enable prompt substitution for function calls in PROMPT
    setopt PROMPT_SUBST

    # Source zsh theme if not using starship or oh-my-zsh
    if ! command -v starship &>/dev/null && [[ -z "$ZSH_THEME" ]]; then
        [[ -f "$_HAWKINS_DIR/prompt/hawkins.zsh-theme" ]] && source "$_HAWKINS_DIR/prompt/hawkins.zsh-theme"
    fi

elif [[ -n "$BASH_VERSION" ]]; then
    # Bash setup
    trap '_hawkins_preexec' DEBUG

    # Add to PROMPT_COMMAND
    if [[ -z "$PROMPT_COMMAND" ]]; then
        PROMPT_COMMAND="_hawkins_precmd"
    else
        PROMPT_COMMAND="_hawkins_precmd; $PROMPT_COMMAND"
    fi

    # Source bash prompt if not using starship
    if ! command -v starship &>/dev/null; then
        [[ -f "$_HAWKINS_DIR/prompt/hawkins.bashrc" ]] && source "$_HAWKINS_DIR/prompt/hawkins.bashrc"
    fi
fi

# =============================================================================
# LS_COLORS FOR HAWKINS THEME
# =============================================================================

export LS_COLORS='di=1;38;2;0;229;255:ln=38;2;213;0;249:so=38;2;0;230;118:pi=38;2;255;171;0:ex=1;38;2;255;23;68:bd=38;2;255;171;0;48;2;40;40;50:cd=38;2;255;171;0;48;2;40;40;50:su=38;2;255;23;68;48;2;40;40;50:sg=38;2;255;171;0;48;2;40;40;50:tw=1;38;2;0;229;255:ow=1;38;2;0;229;255:*.tar=38;2;213;0;0:*.zip=38;2;213;0;0:*.gz=38;2;213;0;0:*.bz2=38;2;213;0;0:*.xz=38;2;213;0;0:*.jpg=38;2;213;0;249:*.png=38;2;213;0;249:*.gif=38;2;213;0;249:*.mp3=38;2;0;229;255:*.mp4=38;2;0;229;255:*.mov=38;2;0;229;255'

# macOS specific
export LSCOLORS='GxfxcxdxBxegedabagGxGx'

# =============================================================================
# INITIALIZE
# =============================================================================

# Show startup banner (only for interactive login shells or new terminals)
if [[ $- == *i* ]]; then
    _hawkins_show_startup
fi

# Export helpers for use in scripts (bash only - zsh doesn't support export -f)
if [[ -n "$BASH_VERSION" ]]; then
    export -f hawkins_info hawkins_success hawkins_warn hawkins_error hawkins_accent hawkins_header hawkins_activate hawkins_deactivate 2>/dev/null || true
fi

# Mark initialization complete (enables preexec for auto-lights)
_HAWKINS_INIT_COMPLETE=1
