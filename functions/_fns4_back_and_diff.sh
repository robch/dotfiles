# back and diff - Snapshot-based development workflow
# Add these functions to your ~/.bashrc

# Resolve the dotfiles repository root from this helper file.
if [ -z "${DOTFILES_DIR:-}" ]; then
    _fns4_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_DIR="$(cd "$_fns4_script_dir/.." && pwd)"
fi

# Detect platform/shell flavor
if [[ "$OSTYPE" == darwin* ]]; then
    CYCODEV_PLATFORM="macos"
elif [[ "$OSTYPE" == linux-gnu* ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
        CYCODEV_PLATFORM="wsl"
    else
        CYCODEV_PLATFORM="linux"
    fi
elif [[ "$OSTYPE" == msys* || "$OSTYPE" == mingw* || "$OSTYPE" == cygwin* ]]; then
    CYCODEV_PLATFORM="gitbash"
else
    CYCODEV_PLATFORM="unknown"
fi

# Default backup location
if [[ "$CYCODEV_PLATFORM" == gitbash ]]; then
    BACK_DIR="${BACK_DIR:-/c/bak}"
else
    BACK_DIR="${BACK_DIR:-$HOME/bak}"
fi

# Location of exclude patterns file
BACK_EXCLUDES="${BACK_EXCLUDES:-$DOTFILES_DIR/.backignore}"

resolve_bcomp_exe() {
    if [ -n "${BCOMP_EXE:-}" ] && [ -x "$BCOMP_EXE" ]; then
        printf '%s\n' "$BCOMP_EXE"
        return 0
    fi

    if command -v bcomp >/dev/null 2>&1; then
        command -v bcomp
        return 0
    fi

    if command -v BComp.exe >/dev/null 2>&1; then
        command -v BComp.exe
        return 0
    fi

    if command -v bcompare >/dev/null 2>&1; then
        command -v bcompare
        return 0
    fi

    if [[ "$CYCODEV_PLATFORM" == macos ]]; then
        local mac_bcomp="/Applications/Beyond Compare.app/Contents/MacOS/bcomp"
        if [ -x "$mac_bcomp" ]; then
            printf '%s\n' "$mac_bcomp"
            return 0
        fi
    fi

    if [[ "$CYCODEV_PLATFORM" == gitbash ]]; then
        local win_bcomp="${LOCALAPPDATA:-/c/Users/$USER/AppData/Local}/Programs/Beyond Compare 5/BComp.exe"
        if [ -x "$win_bcomp" ]; then
            printf '%s\n' "$win_bcomp"
            return 0
        fi

        win_bcomp="${PROGRAMFILES:-/c/Program Files}/Beyond Compare 5/BComp.exe"
        if [ -x "$win_bcomp" ]; then
            printf '%s\n' "$win_bcomp"
            return 0
        fi

        win_bcomp="${PROGRAMFILES_X86:-/c/Program Files (x86)}/Beyond Compare 5/BComp.exe"
        if [ -x "$win_bcomp" ]; then
            printf '%s\n' "$win_bcomp"
            return 0
        fi
    fi

    return 1
}

BCOMP_EXE="$(resolve_bcomp_exe 2>/dev/null || true)"

require_bcomp() {
    if [ -z "$BCOMP_EXE" ]; then
        echo "Warning: Beyond Compare was not found on this machine."
        echo "         Set BCOMP_EXE or install Beyond Compare to use diff."
        return 1
    fi

    return 0
}

build_exclude_args() {
    local source_dir="$1"
    local exclude_args=()

    if [ -f "$source_dir/.gitignore" ]; then
        exclude_args+=("--exclude-from=$source_dir/.gitignore")
    fi

    if [ -f "$BACK_EXCLUDES" ]; then
        exclude_args+=("--exclude-from=$BACK_EXCLUDES")
    fi

    printf '%s\n' "${exclude_args[@]}"
}

copy_tree_with_excludes() {
    local source_dir="$1"
    local dest_dir="$2"
    local exclude_args=()

    while IFS= read -r arg; do
        [ -n "$arg" ] && exclude_args+=("$arg")
    done < <(build_exclude_args "$source_dir")

    if command -v rsync >/dev/null 2>&1; then
        rsync -ah --stats "${exclude_args[@]}" "$source_dir/" "$dest_dir/"
        return 0
    fi

    if command -v tar >/dev/null 2>&1; then
        (cd "$source_dir" && tar "${exclude_args[@]}" -cf - .) | tar -xpf - -C "$dest_dir"
        return 0
    fi

    echo "Error: Neither rsync nor tar is available for snapshot creation."
    return 1
}

# back - Create numbered snapshot backup
back() {
    local source_dir dest_dir dest_base dest_parent
    local x=1
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        # No args: backup current directory
        source_dir="$(pwd)"
        dest_base="$(basename "$source_dir")."
        dest_parent="$BACK_DIR"
    elif [ $# -eq 1 ]; then
        if [ -d "$1" ]; then
            # One arg, is directory
            source_dir="$(cd "$1" && pwd)"
            dest_base="$(basename "$source_dir")."
            dest_parent="$BACK_DIR"
        else
            # One arg, not directory - use as pattern
            source_dir="$(pwd)"
            dest_base="$1."
            dest_parent="$BACK_DIR"
        fi
    elif [ $# -eq 2 ]; then
        source_dir="$(cd "$1" && pwd)"
        if [ -d "$2" ]; then
            # Dest exists, use as parent
            dest_base="$(basename "$source_dir")."
            dest_parent="$(cd "$2" && pwd)"
        else
            # Dest doesn't exist, use as pattern
            dest_parent="$(dirname "$2")"
            dest_base="$(basename "$2")."
        fi
    else
        echo "Usage: back [source_dir] [dest_dir]"
        return 1
    fi
    
    # Find next available number
    while [ -d "$dest_parent/$dest_base$x" ]; do
        x=$((x + 1))
    done
    dest_dir="$dest_parent/$dest_base$x"
    
    echo "------------------------------------------------------------------------------"
    echo "Backing up: $source_dir"
    echo "        to: $dest_dir"
    echo "------------------------------------------------------------------------------"
    
    # Create destination
    mkdir -p "$dest_dir"
    
    # Copy tree with excludes
    copy_tree_with_excludes "$source_dir" "$dest_dir" || return 1
    
    # Save git reflog if git repo
    if [ -d "$source_dir/.git" ]; then
        (cd "$source_dir" && git reflog HEAD -30 > "$dest_dir/GIT-REFLOG-HEAD-LAST-30.txt" 2>/dev/null) || true
    fi
    
    echo "------------------------------------------------------------------------------"
    echo "Backup complete: $dest_dir"
    echo ""
    ls -lh "$dest_dir" | head -20
}

# diff - Compare current directory vs latest backup using Beyond Compare
# Beyond Compare is required; warn if it cannot be found.
diff() {
    local source_dir dest_dir dest_base dest_parent
    local x=1 highest=0
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        # No args: diff current vs latest backup
        source_dir="$(pwd)"
        dest_base="$(basename "$source_dir")."
        dest_parent="$BACK_DIR"
    elif [ $# -eq 1 ]; then
        if [ -d "$1" ]; then
            # One arg, is directory
            source_dir="$(cd "$1" && pwd)"
            dest_base="$(basename "$source_dir")."
            dest_parent="$BACK_DIR"
        else
            # One arg, not directory - use as pattern
            source_dir="$(pwd)"
            dest_base="$1."
            dest_parent="$BACK_DIR"
        fi
    elif [ $# -eq 2 ]; then
        # Two args: direct comparison
        if [ -d "$1" ] && [ -d "$2" ]; then
            source_dir="$(cd "$1" && pwd)"
            dest_dir="$(cd "$2" && pwd)"

            if ! require_bcomp; then
                return 1
            fi

            echo "------------------------------------------------------------------------------"
            echo "Comparing: $dest_dir"
            echo "      and: $source_dir"
            echo "------------------------------------------------------------------------------"

            "$BCOMP_EXE" "$dest_dir" "$source_dir" >/dev/null 2>&1 &
            disown
            return 0
        else
            echo "Error: Both arguments must be directories"
            return 1
        fi
    else
        echo "Usage: diff [source_dir] [dest_dir]"
        return 1
    fi
    
    # Find highest numbered backup
    while [ -d "$dest_parent/$dest_base$x" ]; do
        highest=$x
        x=$((x + 1))
    done
    
    if [ $highest -eq 0 ]; then
        echo "Error: No backup found at $dest_parent/$dest_base*"
        echo "Run 'back' first to create a backup."
        return 1
    fi
    
    dest_dir="$dest_parent/$dest_base$highest"

    if ! require_bcomp; then
        return 1
    fi

    echo "------------------------------------------------------------------------------"
    echo "Comparing: $dest_dir"
    echo "      and: $source_dir"
    echo "------------------------------------------------------------------------------"
    
    "$BCOMP_EXE" "$dest_dir" "$source_dir" >/dev/null 2>&1 &
    disown
}
