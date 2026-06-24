# Current machine note: Git Bash setup

Date: 2026-06-24
Machine: CYCOROB
Shell: Git Bash (`OSTYPE=msys`)
Repo path: `/c/src/.r/dotfiles`

## Goal for this pass
Make the tracked dotfiles work well in Git Bash on this machine first, then extend the same approach later to WSL and macOS.

## Decisions
- Keep the helper logic in the repo in `functions/_fns4_back_and_diff.sh`.
- Make startup files portable instead of hardcoding a single clone path.
- Prefer repo-local detection over machine-only assumptions.
- Keep machine-specific notes committed so future shell/OS work can continue from the same place.

## Current compatibility notes
- Git Bash needs `msys/mingw/cygwin` detection.
- `install.sh` should use the script location as the repo root, not only `~/dotfiles`.
- `back()` should use the Windows Git Bash backup root `/c/bak` by default.
- `diff()` should use Beyond Compare only when the executable can actually be found.
- macOS-only commands must stay guarded so they do not run in Git Bash.

## Follow-up
- Add WSL-specific handling later.
- Add macOS-specific machine notes later.
- If a machine needs paths or tools that are unique to it, keep them in a committed machine override file under `machines/<hostname>/`.
