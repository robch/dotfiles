# ~/.bashrc
# Portable bash configuration - works on macOS, Linux, WSL, and Git Bash
# This file is sourced by ~/.bash_profile on login shells.

# ===== Prompt =====
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# ===== PATH Additions =====
# .NET tools
export PATH="$PATH:$HOME/.dotnet/tools"

# ===== Git Functions =====
gw() {
  if [ $# -eq 0 ]; then
    git worktree list
  else
    git worktree "$@"
  fi
}
gs() { git status "$@"; }
gl() { git log "$@"; }

# ===== Directory Listing Aliases =====
alias dir='ls -lh'          # Windows muscle memory (same as ll)
alias ll='ls -lh'           # Long format, human-readable sizes
alias la='ls -lah'          # Long format, including hidden files
alias l='ls -CF'            # Columnar format with file type indicators
alias llt='ls -lhtr'        # Long format, sorted by time (newest last)
alias dan='ls -lh'          # Directories all by name (default sort)
alias da='ls -lhtr'         # Directories all by date (newest last)

# Current month shortcut (update monthly)
alias d='d5'                # Current month: May (update each month)
alias dn='d5n'              # Current month by name

# Month-filtered listings (shows current month + previous month)
# dx = sorted by date (newest last), dxn = sorted by name
d1() { ls -lhtr "$@" | grep -E '(Jan|Dec)'; }
d1n() { ls -lh "$@" | grep -E '(Jan|Dec)'; }
d2() { ls -lhtr "$@" | grep -E '(Feb|Jan)'; }
d2n() { ls -lh "$@" | grep -E '(Feb|Jan)'; }
d3() { ls -lhtr "$@" | grep -E '(Mar|Feb)'; }
d3n() { ls -lh "$@" | grep -E '(Mar|Feb)'; }
d4() { ls -lhtr "$@" | grep -E '(Apr|Mar)'; }
d4n() { ls -lh "$@" | grep -E '(Apr|Mar)'; }
d5() { ls -lhtr "$@" | grep -E '(May|Apr)'; }
d5n() { ls -lh "$@" | grep -E '(May|Apr)'; }
d6() { ls -lhtr "$@" | grep -E '(Jun|May)'; }
d6n() { ls -lh "$@" | grep -E '(Jun|May)'; }
d7() { ls -lhtr "$@" | grep -E '(Jul|Jun)'; }
d7n() { ls -lh "$@" | grep -E '(Jul|Jun)'; }

# ===== Navigation Shortcuts =====
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Common typo fix
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# ===== Safety Nets =====
# Prompt before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ===== Common Shortcuts =====
alias cls='clear'           # For the Windows muscle memory!
alias h='history'
alias grep='grep --color=auto'

# ===== Config Management =====
alias editbash='code ~/.bashrc'
alias editbashrc='code ~/.bashrc'
alias editprofile='code ~/.bash_profile'
alias reloadbash='source ~/.bashrc'

# ===== Load shared helper functions =====
# Resolve the repo root from this file's location when DOTFILES_DIR is unset.
if [ -z "${DOTFILES_DIR:-}" ]; then
    _dotfiles_source="${BASH_SOURCE[0]}"
    DOTFILES_DIR="$(cd "$(dirname "$_dotfiles_source")" && pwd)"
fi

if [ -f "$DOTFILES_DIR/functions/_fns4_back_and_diff.sh" ]; then
    source "$DOTFILES_DIR/functions/_fns4_back_and_diff.sh"
fi

if [ -f "$DOTFILES_DIR/functions/_fns4_cycod.sh" ]; then
    source "$DOTFILES_DIR/functions/_fns4_cycod.sh"
fi

# ===== Machine-specific overrides =====
# Keep machine-local settings in committed files so the setup can travel
# across shells, operating systems, and future machines.
if [ -n "${DOTFILES_DIR:-}" ] && [ -f "$DOTFILES_DIR/machines/$(hostname 2>/dev/null)/bashrc.local" ]; then
    source "$DOTFILES_DIR/machines/$(hostname 2>/dev/null)/bashrc.local"
fi

# ===== Load Local/Private Configuration =====
# Put machine-specific, private, or work-related config in ~/.bashrc.local
# This file is NOT committed to your dotfiles repo (see .gitignore)
# Examples: API keys, company aliases, personal tokens
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
