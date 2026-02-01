#!/usr/bin/env bash
# install.sh - Hawkins Terminal Installer
# A Stranger Things-inspired terminal experience

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[38;2;255;23;68m'
GREEN='\033[38;2;0;230;118m'
AMBER='\033[38;2;255;171;0m'
CYAN='\033[38;2;0;229;255m'
PINK='\033[38;2;255;64;129m'
RESET='\033[0m'

echo -e "${RED}"
cat << 'EOF'
██╗  ██╗ █████╗ ██╗    ██╗██╗  ██╗██╗███╗   ██╗███████╗
██║  ██║██╔══██╗██║    ██║██║ ██╔╝██║████╗  ██║██╔════╝
███████║███████║██║ █╗ ██║█████╔╝ ██║██╔██╗ ██║███████╗
██╔══██║██╔══██║██║███╗██║██╔═██╗ ██║██║╚██╗██║╚════██║
██║  ██║██║  ██║╚███╔███╔╝██║  ██╗██║██║ ╚████║███████║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝
EOF
echo -e "${RESET}"
echo -e "${AMBER}Installing Hawkins Terminal...${RESET}"
echo

# Detect shell
SHELL_NAME=$(basename "$SHELL")
echo -e "${CYAN}Detected shell:${RESET} $SHELL_NAME"

# =============================================================================
# [1/6] CLI TOOL
# =============================================================================
echo -e "\n${GREEN}[1/6]${RESET} Installing CLI tool..."

# Make CLI executable
chmod +x "${SCRIPT_DIR}/cli/hawkins"
find "${SCRIPT_DIR}/cli/lib" -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find "${SCRIPT_DIR}/shell" -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find "${SCRIPT_DIR}/extras" -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# Create symlink in /usr/local/bin or ~/bin
INSTALL_DIR=""
if [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
    INSTALL_DIR="/usr/local/bin"
elif [[ -d "$HOME/.local/bin" ]]; then
    INSTALL_DIR="$HOME/.local/bin"
elif [[ -d "$HOME/bin" ]]; then
    INSTALL_DIR="$HOME/bin"
else
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIR="$HOME/.local/bin"
    echo -e "${AMBER}  Note: Created ~/.local/bin - you may need to add it to your PATH${RESET}"
fi

ln -sf "${SCRIPT_DIR}/cli/hawkins" "${INSTALL_DIR}/hawkins"
echo -e "  Installed ${CYAN}hawkins${RESET} command to ${INSTALL_DIR}/hawkins"

# =============================================================================
# [2/6] CONFIG DIRECTORY & SHELL INTEGRATION
# =============================================================================
echo -e "\n${GREEN}[2/6]${RESET} Setting up shell integration..."

CONFIG_DIR="$HOME/.config/hawkins-terminal"
mkdir -p "$CONFIG_DIR"

# Store installation path
echo "$SCRIPT_DIR" > "$CONFIG_DIR/path"

# Symlink shell integration files
ln -sf "${SCRIPT_DIR}/shell/hawkins.sh" "$CONFIG_DIR/hawkins.sh"
ln -sf "${SCRIPT_DIR}/shell/hawkins.zsh" "$CONFIG_DIR/hawkins.zsh"
ln -sf "${SCRIPT_DIR}/shell" "$CONFIG_DIR/shell"
ln -sf "${SCRIPT_DIR}/cli" "$CONFIG_DIR/cli"

echo -e "  Created config directory at ${CYAN}$CONFIG_DIR${RESET}"

# =============================================================================
# [3/6] ADD TO SHELL RC FILE
# =============================================================================
echo -e "\n${GREEN}[3/6]${RESET} Configuring shell startup..."

SHELL_RC=""
SOURCE_LINE=""

case "$SHELL_NAME" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        SOURCE_LINE='[[ -f ~/.config/hawkins-terminal/hawkins.zsh ]] && source ~/.config/hawkins-terminal/hawkins.zsh'
        ;;
    bash)
        if [[ -f "$HOME/.bashrc" ]]; then
            SHELL_RC="$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_RC="$HOME/.bash_profile"
        else
            SHELL_RC="$HOME/.bashrc"
        fi
        SOURCE_LINE='[[ -f ~/.config/hawkins-terminal/hawkins.sh ]] && source ~/.config/hawkins-terminal/hawkins.sh'
        ;;
    *)
        echo -e "  ${AMBER}Unknown shell ($SHELL_NAME) - manual setup required${RESET}"
        ;;
esac

if [[ -n "$SHELL_RC" ]]; then
    # Check if already added
    if [[ -f "$SHELL_RC" ]] && grep -q "hawkins-terminal" "$SHELL_RC" 2>/dev/null; then
        echo -e "  Shell integration already in ${CYAN}$SHELL_RC${RESET}"
    else
        # Add to shell rc
        {
            echo ""
            echo "# Hawkins Terminal - Stranger Things theme"
            echo "$SOURCE_LINE"
        } >> "$SHELL_RC"
        echo -e "  Added to ${CYAN}$SHELL_RC${RESET}"
        echo -e "  ${PINK}Banner will show on new terminal windows!${RESET}"
    fi
fi

# =============================================================================
# [4/6] ITERM2 COLOR SCHEME & PROFILE
# =============================================================================
echo -e "\n${GREEN}[4/6]${RESET} Installing iTerm2 theme..."

# Copy color schemes
ITERM_COLORS_DIR="$HOME/.config/iterm2/colors"
mkdir -p "$ITERM_COLORS_DIR"
cp "${SCRIPT_DIR}/iterm/hawkins.itermcolors" "$ITERM_COLORS_DIR/"
cp "${SCRIPT_DIR}/iterm/upside-down.itermcolors" "$ITERM_COLORS_DIR/"

# Install Dynamic Profile
ITERM_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
if [[ -d "$HOME/Library/Application Support/iTerm2" ]]; then
    mkdir -p "$ITERM_PROFILES_DIR"
    cp "${SCRIPT_DIR}/iterm/profiles/hawkins.json" "$ITERM_PROFILES_DIR/"
    echo -e "  Installed ${CYAN}Hawkins${RESET} profile to iTerm2"
    echo -e "  ${PINK}Select it from: Profiles → Hawkins${RESET}"
else
    echo -e "  ${AMBER}iTerm2 not found - skipping Dynamic Profile${RESET}"
fi

echo -e "  Color schemes at ${CYAN}$ITERM_COLORS_DIR${RESET}"

# =============================================================================
# [5/6] STARSHIP PROMPT (optional)
# =============================================================================
echo -e "\n${GREEN}[5/6]${RESET} Configuring prompt..."

if command -v starship &> /dev/null; then
    STARSHIP_CONFIG="$HOME/.config/starship.toml"

    if [[ -f "$STARSHIP_CONFIG" ]]; then
        cp "$STARSHIP_CONFIG" "${STARSHIP_CONFIG}.bak"
        echo -e "  Backed up existing Starship config"
    fi

    cp "${SCRIPT_DIR}/prompt/starship.toml" "$STARSHIP_CONFIG"
    echo -e "  Installed ${CYAN}Starship${RESET} theme"
else
    echo -e "  Starship not found - using built-in Hawkins prompt"
    echo -e "  ${AMBER}Optional: brew install starship${RESET}"
fi

# Oh-My-Zsh theme (if using zsh without starship)
if [[ "$SHELL_NAME" == "zsh" ]] && [[ -d "$HOME/.oh-my-zsh" ]]; then
    cp "${SCRIPT_DIR}/prompt/hawkins.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/"
    echo -e "  Installed Oh-My-Zsh theme (use ZSH_THEME=\"hawkins\" if not using Starship)"
fi

# =============================================================================
# [6/6] VERIFICATION
# =============================================================================
echo -e "\n${GREEN}[6/6]${RESET} Verifying installation..."

CHECKS_PASSED=0
CHECKS_TOTAL=3

# Check CLI
if [[ -x "${INSTALL_DIR}/hawkins" ]]; then
    echo -e "  ${GREEN}✓${RESET} hawkins command installed"
    ((CHECKS_PASSED++))
else
    echo -e "  ${RED}✗${RESET} hawkins command not found"
fi

# Check config
if [[ -f "$CONFIG_DIR/hawkins.sh" ]]; then
    echo -e "  ${GREEN}✓${RESET} Shell integration configured"
    ((CHECKS_PASSED++))
else
    echo -e "  ${RED}✗${RESET} Shell integration missing"
fi

# Check shell rc
if [[ -n "$SHELL_RC" ]] && grep -q "hawkins-terminal" "$SHELL_RC" 2>/dev/null; then
    echo -e "  ${GREEN}✓${RESET} Shell RC updated"
    ((CHECKS_PASSED++))
else
    echo -e "  ${AMBER}!${RESET} Shell RC needs manual update"
fi

# =============================================================================
# DONE
# =============================================================================
echo
echo -e "${GREEN}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${RED}Installation complete!${RESET} (${CHECKS_PASSED}/${CHECKS_TOTAL} checks passed)"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${RESET}"
echo
echo -e "${AMBER}What happens now:${RESET}"
echo -e "  ${PINK}•${RESET} Open a ${CYAN}new terminal window${RESET} to see the Hawkins banner"
echo -e "  ${PINK}•${RESET} Errors will show in Stranger Things style"
echo -e "  ${PINK}•${RESET} Your prompt is now themed"
echo
echo -e "${AMBER}CLI commands:${RESET}"
echo -e "  ${CYAN}hawkins${RESET}              Show banner"
echo -e "  ${CYAN}hawkins flicker${RESET}      Flickering neon effect"
echo -e "  ${CYAN}hawkins lights${RESET}       Christmas lights animation"
echo -e "  ${CYAN}hawkins wall \"RUN\"${RESET}   Alphabet wall message"
echo -e "  ${CYAN}hawkins help${RESET}         All commands"
echo
echo -e "${AMBER}Optional - iTerm2 profile:${RESET}"
echo -e "  Open iTerm2 → Profiles → select ${CYAN}Hawkins${RESET}"
echo
echo -e "${AMBER}Configuration:${RESET}"
echo -e "  ${CYAN}HAWKINS_SHOW_BANNER=0${RESET}  Disable startup banner"
echo -e "  ${CYAN}HAWKINS_SHOW_QUOTE=0${RESET}   Disable random quote"
echo -e "  ${CYAN}HAWKINS_MINIMAL=1${RESET}      Minimal mode (small header)"
echo
echo -e "${RED}Welcome to Hawkins.${RESET}"
