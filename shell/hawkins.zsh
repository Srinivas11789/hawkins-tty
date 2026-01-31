#!/usr/bin/env zsh
# hawkins.zsh - Zsh-specific Hawkins Terminal integration
# Source this in your ~/.zshrc

# Get installation directory from stored path or resolve symlink
if [[ -f "$HOME/.config/hawkins-terminal/path" ]]; then
    HAWKINS_TERMINAL_DIR="$(cat "$HOME/.config/hawkins-terminal/path")"
elif [[ -n "$HAWKINS_TERMINAL_DIR" ]]; then
    : # Use existing value
else
    # Resolve symlink to find real location
    _HAWKINS_ZSH_SOURCE="${(%):-%x}"
    if [[ -L "$_HAWKINS_ZSH_SOURCE" ]]; then
        _HAWKINS_ZSH_SOURCE="$(readlink "$_HAWKINS_ZSH_SOURCE")"
    fi
    HAWKINS_TERMINAL_DIR="$(cd "$(dirname "$_HAWKINS_ZSH_SOURCE")/.." && pwd)"
fi

source "$HAWKINS_TERMINAL_DIR/shell/hawkins.sh"

# =============================================================================
# ZSH-SPECIFIC ENHANCEMENTS
# =============================================================================

# Syntax highlighting colors (if zsh-syntax-highlighting is installed)
if [[ -n "$ZSH_HIGHLIGHT_STYLES" ]]; then
    ZSH_HIGHLIGHT_STYLES[default]='fg=#ff1744'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#d50000'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#d500f9,bold'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=#00e676'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00e676'
    ZSH_HIGHLIGHT_STYLES[function]='fg=#00e676'
    ZSH_HIGHLIGHT_STYLES[command]='fg=#00e676'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=#00e676,underline'
    ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff4081'
    ZSH_HIGHLIGHT_STYLES[path]='fg=#ffab00,underline'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#00e5ff'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#00e5ff'
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#00e5ff'
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#d500f9'
    ZSH_HIGHLIGHT_STYLES[assign]='fg=#ffab00'
    ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff4081'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=#555555'
fi

# Autosuggestion color (if zsh-autosuggestions is installed)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#444455'

# Completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{#ff4081}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{#d50000}-- no matches --%f'
zstyle ':completion:*:messages' format '%F{#ffab00}-- %d --%f'

# =============================================================================
# ZSH PROMPT (if not using Starship)
# =============================================================================

if ! command -v starship &>/dev/null; then
    # Custom Hawkins prompt
    setopt PROMPT_SUBST

    # Git info
    autoload -Uz vcs_info
    precmd_functions+=( vcs_info )
    zstyle ':vcs_info:git:*' formats '%F{#00e676} %b%f'
    zstyle ':vcs_info:git:*' actionformats '%F{#00e676} %b%f %F{#ff4081}(%a)%f'

    # Build prompt
    PROMPT='%F{#ffab00}%~%f${vcs_info_msg_0_}
%(?.%F{#ff1744}.%F{#d50000})❯%f '

    # Right prompt with time (optional)
    # RPROMPT='%F{#2979ff}%T%f'
fi
