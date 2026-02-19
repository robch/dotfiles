# ~/.bashrc
# Portable bash configuration - works on macOS, Linux, any terminal
# This file is sourced by ~/.bash_profile on macOS

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
alias ll='ls -lh'           # Long format, human-readable sizes
alias la='ls -lah'          # Long format, including hidden files
alias l='ls -CF'            # Columnar format with file type indicators
alias llt='ls -lhtr'        # Long format, sorted by time (newest last)

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
alias reloadbash='source ~/.bash_profile'

# === Cycod Path Configuration (Auto-generated) ===
# Generated on Wed Feb 18 09:14:56 PST 2026
# Prioritizes debug builds of cycod tools
export PATH="/Users/r/src/cycod/src/cycod/bin/Debug/net9.0:/Users/r/src/cycod/src/cycodt/bin/Debug/net9.0:/Users/r/src/cycod/src/cycodmd/bin/Debug/net9.0:/Users/r/src/cycod/src/cycodj/bin/Debug/net9.0:/Users/r/src/cycod/src/cycodgr/bin/Debug/net9.0:/Users/r/src/cycod/src/mcp/geolocation/bin/Debug/net9.0:/Users/r/src/cycod/src/mcp/mxlookup/bin/Debug/net9.0:/Users/r/src/cycod/src/mcp/osm/bin/Debug/net9.0:/Users/r/src/cycod/src/mcp/weather/bin/Debug/net9.0:/Users/r/src/cycod/src/mcp/whois/bin/Debug/net9.0:$PATH"
# === End Cycod Path Configuration ===

# ===== Snapshot Workflow (back/diff) =====
# back - Create numbered snapshots for exploratory development
# diff - Compare current code vs latest snapshot using Beyond Compare
source ~/src/dotfiles/functions/_fns4_back_and_diff.sh


# ===== Load Local/Private Configuration =====
# Put machine-specific, private, or work-related config in ~/.bashrc.local
# This file is NOT committed to your dotfiles repo (see .gitignore)
# Examples: API keys, company aliases, personal tokens
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
