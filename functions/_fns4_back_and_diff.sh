# back and diff - Snapshot-based development workflow
# Add these functions to your ~/.bashrc

# Default backup location
BACK_DIR="$HOME/bak"

# Location of exclude patterns file
BACK_EXCLUDES="$HOME/src/dotfiles/.backignore"

# Beyond Compare executable
BCOMP_EXE="/Applications/Beyond Compare.app/Contents/MacOS/bcomp"

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
    
    # Build exclude options
    local exclude_opts=""
    
    # Use .gitignore if exists
    if [ -f "$source_dir/.gitignore" ]; then
        exclude_opts="--exclude-from=$source_dir/.gitignore"
        echo "Using .gitignore from source"
    fi
    
    # Use our exclude file
    if [ -f "$BACK_EXCLUDES" ]; then
        # Read and convert patterns
        while IFS= read -r pattern; do
            [[ -z "$pattern" || "$pattern" =~ ^# ]] && continue
            pattern="${pattern//\\//}"
            exclude_opts="$exclude_opts --exclude=$pattern"
        done < "$BACK_EXCLUDES"
        echo "Using excludes from: $BACK_EXCLUDES"
    fi
    
    # Copy with rsync (quiet mode, summary only)
    rsync -ah --stats $exclude_opts "$source_dir/" "$dest_dir/"
    
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
    
    echo "------------------------------------------------------------------------------"
    echo "Comparing: $dest_dir"
    echo "      and: $source_dir"
    echo "------------------------------------------------------------------------------"
    
    "$BCOMP_EXE" "$dest_dir" "$source_dir" >/dev/null 2>&1 &
    disown
}
