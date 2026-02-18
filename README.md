# 🛠️ My Dotfiles

Personal shell configuration for macOS, Linux, and WSL.

**Philosophy:** One portable config, works everywhere, keeps secrets out of git.

---

## 📦 What's Included

- **`.bashrc`** - Portable bash configuration (works on macOS, Linux, WSL)
  - Aliases for common commands (`ll`, `la`, `cls`, etc.)
  - Git workflow functions (`gw`, `gs`, `gl`)
  - Smart navigation shortcuts
  - Colored prompt
  
- **`.bash_profile`** - macOS-specific configuration
  - Homebrew environment setup
  - Java/OpenJDK paths
  - Mac-only aliases (Finder integration)
  - Sources `.bashrc` for compatibility

- **`install.sh`** - Smart installation script
  - Auto-detects your OS (macOS, Linux, or WSL)
  - Backs up existing configs
  - Creates symlinks to dotfiles
  
---

## 🚀 Installation

### First Time Setup

```bash
# Clone this repo
git clone https://github.com/robch/dotfiles.git ~/dotfiles

# Run the installer
~/dotfiles/install.sh

# Reload your shell
source ~/.bash_profile  # macOS
source ~/.bashrc        # Linux/WSL
```

### On a New Machine

Same steps as above! The install script handles everything.

---

## 🔐 Private Configuration

For machine-specific or sensitive config (API keys, work aliases, etc.), create:

**`~/.bashrc.local`**

This file is:
- ✅ **NOT committed** to git (see `.gitignore`)
- ✅ **Automatically loaded** by `.bashrc`
- ✅ **Perfect for secrets**

### Example `~/.bashrc.local`:

```bash
# API Keys
export GITHUB_TOKEN="ghp_your_token_here"
export OPENAI_API_KEY="sk-your-key-here"

# Work-specific
alias deploy='~/work/scripts/deploy.sh'
export WORK_PROJECT_PATH="~/company/projects"

# Machine-specific
alias backup='rsync -av ~ /mnt/backup/$(hostname)/'
```

---

## 🌍 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **macOS** | ✅ Fully supported | Uses `.bash_profile` + `.bashrc` |
| **Linux** | ✅ Fully supported | Uses `.bashrc` directly |
| **WSL** | ✅ Fully supported | Uses `.bashrc` directly |

The installer auto-detects your platform and does the right thing.

---

## 📝 Key Features

### Aliases

```bash
ll          # Long listing, human-readable sizes
la          # Long listing, including hidden files
llt         # Long listing, sorted by time
cls         # Clear screen (Windows muscle memory!)
..          # Go up one directory
...         # Go up two directories
....        # Go up three directories
```

### Git Functions

```bash
gw          # Git worktree (list if no args, else pass through)
gs          # Git status
gl          # Git log
```

### Safety Features

```bash
cp          # Prompts before overwriting
mv          # Prompts before overwriting
rm          # Prompts before overwriting
```

---

## 🔄 Updating

### On Your Main Machine

```bash
# Edit files in ~/dotfiles/
nano ~/dotfiles/.bashrc

# Commit and push
cd ~/dotfiles
git add .
git commit -m "Add new alias"
git push
```

### On Other Machines

```bash
# Pull latest changes
cd ~/dotfiles
git pull

# Reload your shell
source ~/.bash_profile  # macOS
source ~/.bashrc        # Linux/WSL
```

---

## 🎨 Customization

### Adding a New Alias

Edit `~/dotfiles/.bashrc`:

```bash
# Add to the aliases section
alias myalias='my command here'
```

Commit and push:

```bash
cd ~/dotfiles
git add .bashrc
git commit -m "Add myalias"
git push
```

### Adding Platform-Specific Config

**For macOS only:** Edit `~/dotfiles/.bash_profile`

**For Linux/WSL only:** Add to `~/dotfiles/.bashrc` with a check:

```bash
# In .bashrc
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux/WSL-specific stuff
    alias open='xdg-open'  # or explorer.exe for WSL
fi
```

---

## 📚 Background

### Why Split `.bashrc` and `.bash_profile`?

**macOS terminals** start as **login shells** → read `.bash_profile`  
**Linux terminals** start as **non-login shells** → read `.bashrc`

**Solution:** `.bash_profile` sources `.bashrc`, so everything works everywhere!

### Why Use Symlinks?

Your actual configs live in `~/dotfiles/` (git-tracked), but bash looks for them in `~/`.

**Symlinks** make `~/.bashrc` point to `~/dotfiles/.bashrc`, so:
- ✅ Edit once, commit to git
- ✅ Bash finds configs where it expects them
- ✅ Easy to sync across machines

---

## 🤝 Contributing

This is my personal config, but if you spot a bug or have a cool suggestion, feel free to open an issue!

---

## 📄 License

MIT - Feel free to fork and adapt for your own use!

---

## 💡 Pro Tips

1. **Never commit secrets** - Use `.bashrc.local` for sensitive data
2. **Test before pushing** - Run `bash -n ~/.bashrc` to check syntax
3. **Document your aliases** - Future you will thank you
4. **Keep it portable** - Avoid hard-coded paths when possible
5. **Back up first** - The install script does this automatically

---

**Happy configuring! 🚀**
