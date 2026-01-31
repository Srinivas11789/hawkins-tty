#!/usr/bin/env bash
# Hawkins Terminal - Bash PS1 Prompt
# A Stranger Things-inspired prompt
#
# Usage: Add to your ~/.bashrc:
#   source /path/to/hawkins-terminal/prompt/hawkins.bashrc

# Colors (using ANSI escape codes)
HAWKINS_RED='\[\033[38;2;255;23;68m\]'
HAWKINS_PINK='\[\033[38;2;255;64;129m\]'
HAWKINS_BLOOD='\[\033[38;2;213;0;0m\]'
HAWKINS_GREEN='\[\033[38;2;0;230;118m\]'
HAWKINS_AMBER='\[\033[38;2;255;171;0m\]'
HAWKINS_BLUE='\[\033[38;2;41;121;255m\]'
HAWKINS_PURPLE='\[\033[38;2;213;0;249m\]'
HAWKINS_CYAN='\[\033[38;2;0;229;255m\]'
HAWKINS_RESET='\[\033[0m\]'
HAWKINS_BOLD='\[\033[1m\]'
HAWKINS_DIM='\[\033[2m\]'

# Git branch function
__hawkins_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
        local status=""
        local git_status
        git_status=$(git status --porcelain 2>/dev/null)

        if [[ -n "$git_status" ]]; then
            status=" !"
        fi

        echo " ${branch}${status}"
    fi
}

# Git status indicator
__hawkins_git_status() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local staged modified untracked

        staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        modified=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

        local status=""
        [[ $staged -gt 0 ]] && status+="+$staged "
        [[ $modified -gt 0 ]] && status+="!$modified "
        [[ $untracked -gt 0 ]] && status+="?$untracked"

        if [[ -n "$status" ]]; then
            echo " [$status]"
        fi
    fi
}

# Animation frame counter
__hawkins_frame=0

# Terminal-style station names
__hawkins_station() {
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
    # Frame is incremented in __hawkins_prompt, use it directly
    echo "${stations[$__hawkins_frame]}"
}

# Last command status indicator
__hawkins_status() {
    if [[ $1 -eq 0 ]]; then
        echo -e "\033[38;2;255;23;68m▸\033[0m"
    else
        echo -e "\033[38;2;213;0;0m▸\033[0m"
    fi
}

# Animated christmas lights for prompt
__hawkins_lights() {
    local bulb="●"
    local wire="─"
    local colors=(
        '\033[38;2;255;23;68m'   # Red
        '\033[38;2;0;230;118m'   # Green
        '\033[38;2;41;121;255m'  # Blue
        '\033[38;2;255;171;0m'   # Amber
        '\033[38;2;213;0;249m'   # Purple
        '\033[38;2;0;229;255m'   # Cyan
    )
    local dim='\033[2m'
    local reset='\033[0m'
    local output=""
    local num_colors=${#colors[@]}

    for ((i=0; i<18; i++)); do
        if [[ $((i % 3)) -eq 0 ]]; then
            # Offset by frame for animation
            local color_idx=$(( ((i / 3) + __hawkins_frame) % num_colors ))
            output+="${colors[$color_idx]}${bulb}${reset}"
        else
            output+="${dim}${wire}${reset}"
        fi
    done
    echo -e "$output"
}

# Build the prompt
__hawkins_prompt() {
    local last_exit=$?

    # Increment frame counter (runs in parent shell via PROMPT_COMMAND)
    (( __hawkins_frame = (__hawkins_frame + 1) % 10 ))

    # User and host (only show host if SSH)
    local user_host=""
    if [[ -n "$SSH_CONNECTION" ]]; then
        user_host="${HAWKINS_RED}\u${HAWKINS_PINK}@\h ${HAWKINS_RESET}"
    fi

    # Directory (shortened)
    local dir="${HAWKINS_AMBER}\w${HAWKINS_RESET}"

    # Git info
    local git_branch="${HAWKINS_GREEN}\$(__hawkins_git_branch)${HAWKINS_RESET}"
    local git_status="${HAWKINS_PURPLE}\$(__hawkins_git_status)${HAWKINS_RESET}"

    # Status indicator
    local status_char="\$(__hawkins_status $last_exit)"

    # Christmas lights
    local lights="\$(__hawkins_lights)"

    # Station name
    local station="\$(__hawkins_station)"

    # Current dir basename
    local basedir="\W"

    # Build PS1
    # Format: ~/path branch
    #         ●──●──●──● HAWKINS-LAB://~ ▸
    PS1="${user_host}${dir}${git_branch}${git_status}\n${lights} ${HAWKINS_RED}${station}${HAWKINS_DIM}://${HAWKINS_AMBER}${basedir}${HAWKINS_RESET} ${status_char} "
}

# Set the prompt command
PROMPT_COMMAND='__hawkins_prompt'

# Optional: Set terminal title
case "$TERM" in
    xterm*|rxvt*|screen*)
        PROMPT_COMMAND="${PROMPT_COMMAND}; echo -ne \"\033]0;\${PWD##*/}\007\""
        ;;
esac

# LS colors matching Hawkins theme
export LSCOLORS='GxfxcxdxbxegedabagGxGx'
export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=1;36:ow=1;36'

# Enable colors for grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;31'  # Red

# Aliases with colors
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias grep='grep --color=auto'
alias diff='diff --color=auto 2>/dev/null || diff'
