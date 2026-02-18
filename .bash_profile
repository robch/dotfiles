∫# ~/.bash_profile
# macOS-specific bash configuration
# This file is read by login shells (macOS Terminal, iTerm2, SSH, etc.)

# ===== Mac-Specific Settings =====

# Silence the "zsh is now default" warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Homebrew environment (Mac-only)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Java (OpenJDK 17) - Mac Homebrew installation
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"

# Mac-specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# ===== Load Portable Configuration =====
# This makes all your aliases, functions, and settings available
# Works with any terminal emulator (Terminal.app, iTerm2, Ghostty, Kitty, etc.)
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# ===== macOS System Preferences =====
# Set keyboard repeat rate to fast (like Windows)
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
