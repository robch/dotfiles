# ~/.bash_profile
# Portable login-shell configuration
# Keep this safe for macOS, Linux, WSL, and Git Bash.

# ===== macOS-only Settings =====
if [[ "$OSTYPE" == darwin* ]]; then
    # Silence the "zsh is now default" warning when using bash on macOS
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # Homebrew environment (Mac-only)
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$('/opt/homebrew/bin/brew' shellenv)"
    fi

    # Java (OpenJDK 17) - Mac Homebrew installation
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    export JAVA_HOME="/opt/homebrew/opt/openjdk@17"

    # Mac-specific aliases
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

    # macOS system preferences
    defaults write -g KeyRepeat -int 2 2>/dev/null || true
    defaults write -g InitialKeyRepeat -int 15 2>/dev/null || true
fi

# ===== Load Portable Configuration =====
# Source .bashrc from login shells.
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
