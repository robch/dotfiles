# CycoD shell helpers - AI model selection and quick-invoke wrappers
# Sourced from ~/.bashrc via DOTFILES_DIR discovery (same pattern as _fns4_back_and_diff.sh)

# Resolve the dotfiles repository root from this helper file.
if [ -z "${DOTFILES_DIR:-}" ]; then
    _fns4_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTFILES_DIR="$(cd "$_fns4_script_dir/.." && pwd)"
fi

# ===== Model Selectors =====
# Call one of these to switch the active model for i() and q().
fast() { model_name=gpt-5.4-mini; }
good() { model_name=claude-sonnet-4.6; }
best() { model_name=claude-opus-4.7; }

# ===== System Prompt Default =====
add_system_prompt="Try to not use emoticons, unless I specifically ask for them."

# ===== Quick-invoke Wrappers =====

# i - pass one or more input files/args to cycod (--inputs)
i() {
    echo Using $model_name
    cycod --copilot-model-name "$model_name" \
          --add-system-prompt "$add_system_prompt" \
          --inputs "$@"
}

# q - pass a single inline prompt to cycod (--input)
q() {
    echo Using $model_name
    cycod --copilot-model-name "$model_name" \
          --add-system-prompt "$add_system_prompt" \
          --input "$*"
}

# ama - ask cycod's built-in help system
ama() { cycod help ama "$@"; }

# Set the default model on shell startup
fast
