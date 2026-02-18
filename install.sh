#!/bin/bash

# Dotfiles Installation Script
# Supports macOS, Linux, and WSL

set -e  # Exit on error

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dotfiles Installation${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo -e "${GREEN}✓${NC} Detected: macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
        OS="wsl"
        echo -e "${GREEN}✓${NC} Detected: WSL (Windows Subsystem for Linux)"
    else
        OS="linux"
        echo -e "${GREEN}✓${NC} Detected: Linux"
    fi
else
    OS="unknown"
    echo -e "${YELLOW}⚠${NC} Unknown OS: $OSTYPE (proceeding anyway)"
fi

echo ""

# Function to backup and symlink
link_file() {
    local src="$1"
    local dest="$2"
    
    # If destination exists and is not a symlink, back it up
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${YELLOW}  Backing up:${NC} $dest → $BACKUP_DIR/"
        mv "$dest" "$BACKUP_DIR/"
    fi
    
    # Remove existing symlink if present
    [ -L "$dest" ] && rm "$dest"
    
    # Create symlink
    ln -sf "$src" "$dest"
    echo -e "${GREEN}  ✓ Linked:${NC} $dest → $src"
}

# Install common files (all platforms)
echo -e "${BLUE}Installing common dotfiles...${NC}"
link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

# Install platform-specific files
if [ "$OS" = "macos" ]; then
    echo ""
    echo -e "${BLUE}Installing macOS-specific files...${NC}"
    link_file "$DOTFILES_DIR/.bash_profile" "$HOME/.bash_profile"
fi

# Note about .bashrc.local
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} Create ${BLUE}~/.bashrc.local${NC} for private/machine-specific config"
echo "   (This file won't be committed to git)"
echo ""
echo -e "${YELLOW}Examples for ~/.bashrc.local:${NC}"
echo "   export GITHUB_TOKEN=\"your-token\""
echo "   alias work='cd /path/to/work/projects'"
echo "   export COMPANY_SPECIFIC_VAR=\"value\""
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}📦 Backups saved to:${NC} $BACKUP_DIR"
    echo ""
fi

echo -e "${GREEN}Next steps:${NC}"
echo "  1. Reload your shell: ${BLUE}source ~/.bash_profile${NC} (macOS) or ${BLUE}source ~/.bashrc${NC} (Linux/WSL)"
echo "  2. Or just open a new terminal window"
echo "  3. Push to GitHub: ${BLUE}cd ~/dotfiles && git push${NC}"
echo ""
