# General shell command helpers.

# ap - Find a tool below the current directory and add its directory to PATH.
ap() {
    if [ $# -ne 1 ]; then
        echo "Usage: ap <filename>" >&2
        return 1
    fi

    local name="$1"
    local found=""
    local candidate

    found="$(find . -type f -name "$name" -print -quit 2>/dev/null)"

    if [ -z "$found" ] && [[ "$name" != *.* ]]; then
        for candidate in "$name" "$name.exe" "$name.sh" "$name.bat" "$name.cmd"; do
            found="$(find . -type f -name "$candidate" -print -quit 2>/dev/null)"
            [ -n "$found" ] && break
        done
    fi

    if [ -z "$found" ]; then
        echo "Not found: $name" >&2
        return 1
    fi

    local directory
    directory="$(cd "$(dirname "$found")" && pwd)" || return 1

    echo "Found: $directory"
    case ":$PATH:" in
        *":$directory:"*)
            echo "Already in PATH: $directory"
            ;;
        *)
            export PATH="$directory:$PATH"
            echo "Added to PATH: $directory"
            ;;
    esac
}

# gd - Git diff.
gd() { git diff "$@"; }

# gr - Git remotes.
gr() { git remote -v "$@"; }
