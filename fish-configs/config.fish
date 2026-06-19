if status is-interactive
    # Load custom terminal and theme colors
    source ~/.config/fish/my_colors.fish
end

# Color files according to their type. Needs "vivid" and "eza"
# sudo pacman -S vivid eza
if status is-interactive
    # Generate distinct text colors for every file extension using the 'one-dark' theme
    set -gx LS_COLORS (vivid generate one-dark)

    # Use eza with the long-list layout (-l), icons, and explicit color rendering
    alias ls="eza -l --icons=always --color=always --group-directories-first"
    alias ll="eza -la --icons=always --color=always --group-directories-first"
end
export PATH="$HOME/.local/bin:$PATH"

# Guard against accidental 'tailscale down' — kills remote SSH access
function tailscale --wraps=tailscale
    if contains -- down $argv
        echo "  tailscale down = LOSE SSH ACCESS from remote."
        echo "   Server at home, will only get on manually."
        read -P "Type 'I understand' to proceed: " confirm
        if test "$confirm" != "I understand"
            echo "Aborted."
            return 1
        end
    end
    command tailscale $argv
end

# Prompt with time, user@host (bold red), path (green), git branch
function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status

    # Extract active Python virtual environment name
    set -l venv_prompt ""
    if set -q VIRTUAL_ENV
        set -l venv_name (basename "$VIRTUAL_ENV")
        set venv_prompt (set_color cyan)"($venv_name) "(set_color normal)
    end

    # Detect Rust project by checking for Cargo context
    set -l rust_prompt ""
    if type -q cargo; and cargo locate-project --quiet >/dev/null 2>&1
        set rust_prompt (set_color ffa500)"(Rust) "(set_color normal)
    end

    if functions -q fish_is_root_user; and fish_is_root_user
        printf '%s@%s %s%s%s# ' $USER (prompt_hostname) (set -q fish_color_cwd_root
                                                          and set_color $fish_color_cwd_root
                                                          or set_color $fish_color_cwd) \
            (prompt_pwd) (set_color --reset)
    else
        set -l status_color (set_color $fish_color_status)
        set -l statusb_color (set_color --bold $fish_color_status)
        set -l pipestatus_string (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

        # Print layout with $rust_prompt appended before the newline
        printf '[%s] %b%s%b@%b%s %b%s%s%b%s %s%s\n> ' \
            (date "+%H:%M:%S") \
            (set_color --bold red) $USER (set_color normal) (set_color --bold red) (prompt_hostname) \
            (set_color $fish_color_cwd) $PWD $pipestatus_string \
            (set_color --reset) (fish_vcs_prompt) $venv_prompt $rust_prompt
    end
end

