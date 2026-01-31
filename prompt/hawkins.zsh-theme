# Hawkins Terminal - Zsh Theme
# A Stranger Things-inspired prompt

# Colors
HAWKINS_RED="%F{#ff1744}"
HAWKINS_PINK="%F{#ff4081}"
HAWKINS_BLOOD="%F{#d50000}"
HAWKINS_GREEN="%F{#00e676}"
HAWKINS_AMBER="%F{#ffab00}"
HAWKINS_BLUE="%F{#2979ff}"
HAWKINS_PURPLE="%F{#d500f9}"
HAWKINS_CYAN="%F{#00e5ff}"
HAWKINS_DIM="%F{#666666}"
HAWKINS_RESET="%f"

# Animation state (persists between prompts)
typeset -g _hawkins_frame=0

# Increment frame counter before each prompt (runs in parent shell, not subshell)
_hawkins_increment_frame() {
    (( _hawkins_frame = (_hawkins_frame + 1) % 10 ))
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _hawkins_increment_frame

# Git branch (fallback if oh-my-zsh not loaded)
_hawkins_git_info() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    local dirty=""
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        dirty="${HAWKINS_PURPLE}!"
    fi
    echo "${HAWKINS_GREEN} ${branch}${dirty}${HAWKINS_RESET}"
}

# Animated christmas lights - shifts colors each prompt
_hawkins_lights() {
    local bulb="●"
    local wire="─"
    local colors=(
        '%F{#ff1744}'   # Red
        '%F{#00e676}'   # Green
        '%F{#2979ff}'   # Blue
        '%F{#ffab00}'   # Amber
        '%F{#d500f9}'   # Purple
        '%F{#00e5ff}'   # Cyan
    )
    local num_colors=${#colors[@]}
    local output=""

    # Frame is incremented in precmd hook, use it for color offset

    for ((i=0; i<18; i++)); do
        if [[ $((i % 3)) -eq 0 ]]; then
            # Offset by frame for animation effect
            local color_idx=$(( ((i / 3) + _hawkins_frame) % num_colors + 1 ))
            output+="${colors[$color_idx]}${bulb}%f"
        else
            output+="${HAWKINS_DIM}${wire}%f"
        fi
    done
    echo "$output"
}

# Terminal-style Stranger Things prompts
_hawkins_station() {
    local stations=(
        "HAWKINS-LAB"
        "RADIO-TOWER"
        "CHANNEL-11"
        "HEATHKIT"
        "WORMHOLE"
        "THE-GATE"
        "VOID-SIGNAL"
        "FREQUENCY-83"
        "WALKIE"
        "TRACKER"
    )
    local idx=$(( (_hawkins_frame % ${#stations[@]}) + 1 ))
    echo "${stations[$idx]}"
}

# User info (show user@host if SSH)
_hawkins_user() {
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo "${HAWKINS_RED}%n${HAWKINS_PINK}@%m "
    fi
}

# Virtual environment
_hawkins_venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "${HAWKINS_CYAN}($(basename $VIRTUAL_ENV)) "
    fi
}

# Enable prompt substitution
setopt PROMPT_SUBST

# Build prompt
# Format: ~/path branch
#         ●──●──●──● HAWKINS-LAB://~ ▸
PROMPT='$(_hawkins_venv)$(_hawkins_user)${HAWKINS_AMBER}%~${HAWKINS_RESET}$(_hawkins_git_info)
$(_hawkins_lights) ${HAWKINS_RED}$(_hawkins_station)${HAWKINS_DIM}://${HAWKINS_AMBER}%1~${HAWKINS_RESET} %(?.${HAWKINS_RED}▸.${HAWKINS_BLOOD}▸)${HAWKINS_RESET} '

# LS colors
export LSCOLORS='GxfxcxdxbxegedabagGxGx'
export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=1;36:ow=1;36'
