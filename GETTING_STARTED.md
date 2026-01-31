# Getting Started with Hawkins Terminal

A Stranger Things-inspired terminal experience with dynamic effects, themed error displays, and immersive visual presentation.

## Quick Install

```bash
make install
```

Or manually add to your shell config:

```bash
# Add to ~/.bashrc or ~/.zshrc
source /path/to/hawkins-terminal/shell/hawkins.sh
```

## What You'll See

On terminal startup:
1. Christmas lights frame
2. Flickering HAWKINS banner
3. Christmas lights frame
4. Typewriter-animated quote

On command errors:
- Demogorgon ASCII art
- Themed error messages

On long commands (>2 seconds):
- Animated Christmas lights while waiting

## Commands

| Command | Description |
|---------|-------------|
| `hawkins_activate` | Enable all Hawkins effects |
| `hawkins_deactivate` | Disable effects, restore normal shell |

## Configuration

Set these in your shell config BEFORE sourcing hawkins.sh:

```bash
# Disable all effects (fast startup)
export HAWKINS_MINIMAL=1

# Individual toggles (all default to 1)
export HAWKINS_FLICKER_STARTUP=0   # Disable startup flicker
export HAWKINS_LIGHTS_FRAME=0      # Disable Christmas lights
export HAWKINS_ANIMATE_QUOTE=0     # Disable typewriter quote
export HAWKINS_SHOW_DEMOGORGON=0   # Disable Demogorgon on errors
export HAWKINS_AUTO_LIGHTS=0       # Disable loading lights

# Suppress banner entirely
export HAWKINS_SUPPRESS_BANNER=1
```

## CLI Tool

The `hawkins` command provides additional effects:

```bash
hawkins              # Show banner
hawkins --flicker    # Flickering banner
hawkins --glow       # Glowing banner
hawkins --lights     # Christmas lights animation
hawkins --wall MSG   # Joyce's alphabet wall
```

## Shell Support

- **Bash**: Full support
- **Zsh**: Full support (including Oh-My-Zsh)

## Prompt Themes

For the full experience, use the included prompt themes:

**Starship** (recommended):
```bash
cp prompt/hawkins.toml ~/.config/starship.toml
```

**Bash** (without Starship):
```bash
source prompt/hawkins.bashrc
```

**Zsh/Oh-My-Zsh**:
```bash
cp prompt/hawkins.zsh-theme ~/.oh-my-zsh/custom/themes/
# Then set ZSH_THEME="hawkins" in ~/.zshrc
```

## iTerm2 Color Scheme

Import the color scheme for the best visual experience:

1. Open iTerm2 Preferences
2. Go to Profiles > Colors
3. Click "Color Presets..." > "Import..."
4. Select `hawkins.itermcolors` or `upside-down.itermcolors`

## Troubleshooting

**Effects not showing?**
- Make sure you're in an interactive terminal
- Check `echo $HAWKINS_ACTIVE` (should be `1`)
- Run `hawkins_activate` to re-enable

**Want faster startup?**
```bash
export HAWKINS_MINIMAL=1
```

**Seeing path errors?**
Set the installation path explicitly:
```bash
export HAWKINS_TERMINAL_DIR=/path/to/hawkins-terminal
source $HAWKINS_TERMINAL_DIR/shell/hawkins.sh
```
