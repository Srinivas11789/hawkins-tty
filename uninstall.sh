#!/usr/bin/env bash
# uninstall.sh - Hawkins Terminal Uninstaller

set -e

# Colors
RED='\033[38;2;255;23;68m'
GREEN='\033[38;2;0;230;118m'
AMBER='\033[38;2;255;171;0m'
CYAN='\033[38;2;0;229;255m'
RESET='\033[0m'

echo -e "${RED}Uninstalling Hawkins Terminal...${RESET}"
echo

# =============================================================================
# [1/5] REMOVE CLI SYMLINK
# =============================================================================
echo -e "${AMBER}[1/5]${RESET} Removing CLI..."

for dir in "/usr/local/bin" "$HOME/bin" "$HOME/.local/bin"; do
    if [[ -L "${dir}/hawkins" ]]; then
        rm -f "${dir}/hawkins"
        echo -e "  Removed ${dir}/hawkins"
    fi
done

# =============================================================================
# [2/5] REMOVE SHELL INTEGRATION FROM RC FILES
# =============================================================================
echo -e "\n${AMBER}[2/5]${RESET} Removing shell integration..."

for rc_file in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc"; do
    if [[ -f "$rc_file" ]] && grep -q "hawkins-terminal" "$rc_file" 2>/dev/null; then
        # Create backup
        cp "$rc_file" "${rc_file}.hawkins-backup"

        # Remove hawkins lines (the comment and the source line)
        grep -v "hawkins-terminal" "$rc_file" | grep -v "Hawkins Terminal" > "${rc_file}.tmp"
        mv "${rc_file}.tmp" "$rc_file"

        echo -e "  Cleaned ${CYAN}$rc_file${RESET} (backup at ${rc_file}.hawkins-backup)"
    fi
done

# =============================================================================
# [3/5] REMOVE CONFIG DIRECTORY
# =============================================================================
echo -e "\n${AMBER}[3/5]${RESET} Removing config..."

CONFIG_DIR="$HOME/.config/hawkins-terminal"
if [[ -d "$CONFIG_DIR" ]]; then
    rm -rf "$CONFIG_DIR"
    echo -e "  Removed ${CYAN}$CONFIG_DIR${RESET}"
fi

# =============================================================================
# [4/5] REMOVE ITERM2 PROFILE & COLORS
# =============================================================================
echo -e "\n${AMBER}[4/5]${RESET} Removing iTerm2 files..."

# Dynamic Profile
ITERM_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
if [[ -f "$ITERM_PROFILES_DIR/hawkins.json" ]]; then
    rm -f "$ITERM_PROFILES_DIR/hawkins.json"
    echo -e "  Removed iTerm2 Dynamic Profile"
fi

# Color schemes
ITERM_COLORS_DIR="$HOME/.config/iterm2/colors"
if [[ -d "$ITERM_COLORS_DIR" ]]; then
    rm -f "$ITERM_COLORS_DIR/hawkins.itermcolors"
    rm -f "$ITERM_COLORS_DIR/upside-down.itermcolors"
    echo -e "  Removed color scheme files"
fi

# =============================================================================
# [5/5] REMOVE OH-MY-ZSH THEME
# =============================================================================
echo -e "\n${AMBER}[5/5]${RESET} Removing extras..."

if [[ -f "$HOME/.oh-my-zsh/custom/themes/hawkins.zsh-theme" ]]; then
    rm -f "$HOME/.oh-my-zsh/custom/themes/hawkins.zsh-theme"
    echo -e "  Removed Oh-My-Zsh theme"
fi

# =============================================================================
# NOTES
# =============================================================================
echo
echo -e "${AMBER}Manual cleanup (if needed):${RESET}"
echo
echo -e "  ${CYAN}Starship config:${RESET}"
echo -e "    Restore backup: mv ~/.config/starship.toml.bak ~/.config/starship.toml"
echo
echo -e "  ${CYAN}iTerm2 colors:${RESET}"
echo -e "    The color presets may still appear in iTerm2 Preferences."
echo -e "    Remove manually: Preferences → Profiles → Colors → Color Presets → Delete"
echo
echo -e "${GREEN}Uninstall complete.${RESET}"
echo -e "${RED}Goodbye from Hawkins.${RESET}"
