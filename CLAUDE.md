# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hawkins Terminal is a Stranger Things-themed terminal experience. Pure shell implementation (Bash/Zsh) with no external dependencies. Transforms the command line with themed visuals: ASCII banners, Christmas lights animations, Demogorgon error messages, character quotes on success, and rotating prompt stations.

## Commands

```bash
# Installation
make install          # Install to ~/.local/share/hawkins-terminal
make install-light    # Install with minimal output mode
make link             # Create dev symlink (for development)
make uninstall        # Remove installation

# Testing
make test             # Syntax checks (bash -n) on all shell files + zsh compatibility

# Demos
make demo             # Preview startup effects
make demo-success     # Preview success messages
make demo-error       # Preview error messages (Demogorgon)
make demo-light       # Light mode demo
make demo-rich        # Rich mode demo
```

## Architecture

```
cli/
├── hawkins           # Main CLI entry point - dispatches to subcommands
├── lib/
│   ├── colors.sh     # ANSI true color (24-bit RGB) definitions
│   ├── banner.sh     # ASCII banner display
│   ├── effects.sh    # Visual effects (flicker, glow, typewriter, glitch)
│   └── christmas.sh  # Christmas lights and alphabet wall animations
└── assets/           # ASCII art files (banner.txt, demogorgon*.txt)

shell/
└── hawkins.sh        # Main shell integration - hooks into precmd/preexec

prompt/               # Optional prompt themes (Starship, Zsh, Bash)
iterm/                # iTerm2 color schemes and profiles
```

## Key Patterns

**Prevent multiple sourcing:**
```bash
[[ -n "$_HAWKINS_COLORS_LOADED" ]] && return 0
_HAWKINS_COLORS_LOADED=1
```

**Cross-shell compatibility (Bash/Zsh):**
```bash
if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh-specific (uses add-zsh-hook)
elif [[ -n "$BASH_VERSION" ]]; then
    # Bash-specific (uses DEBUG trap)
fi
```

**Symlink resolution for sourced scripts:**
```bash
_HAWKINS_SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$_HAWKINS_SOURCE" ]]; do
    _HAWKINS_DIR="$(cd -P "$(dirname "$_HAWKINS_SOURCE")" && pwd)"
    _HAWKINS_SOURCE="$(readlink "$_HAWKINS_SOURCE")"
    [[ "$_HAWKINS_SOURCE" != /* ]] && _HAWKINS_SOURCE="$_HAWKINS_DIR/$_HAWKINS_SOURCE"
done
```

**Hook system:** Zsh uses `preexec`/`precmd` hooks; Bash uses `PROMPT_COMMAND` with `DEBUG` trap. Both detect command exit status to show error (Demogorgon) or success (character quote) messages.

## Configuration

Environment variables (set before sourcing `hawkins.sh`):
- `HAWKINS_DISPLAY_MODE` - "rich" (default) or "light"
- `HAWKINS_SUCCESS_THRESHOLD` - Seconds before showing success message (0=all)
- `HAWKINS_SUPPRESS_BANNER` - Hide startup banner (useful for tests)

## Color Palette

All colors use true color format `\033[38;2;R;G;Bm`:
- `TC_NEON_RED` (#ff1744) - Primary branding
- `TC_SLIME` (#00e676) - Success
- `TC_AMBER` (#ffab00) - Christmas lights
- `TC_ELECTRIC` (#00e5ff) - Eleven's powers
