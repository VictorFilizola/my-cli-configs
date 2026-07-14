# ── Oh-My-Zsh ────────────────────────────────────
export ZSH="/usr/share/oh-my-zsh"
# Plugins:
#   git     — aliases (gst, ga, gc, gl, gp…) + branch in prompt via vcs_info
#   fzf     — Ctrl+T file picker, Ctrl+R history search, Alt+C cd into dirs
#   extract — one `extract <archive>` to rule tar.gz/zip/rar/7z/etc.
plugins=(git fzf extract)
source $ZSH/oh-my-zsh.sh

# ── Greeting ────────────────────────────────────
fastfetch --config ~/.config/fastfetch/config.jsonc

# ── History Settings ─────────────────────────────
export HISTCONTROL=ignoreboth
export HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ── Man Page Colors ──────────────────────────────
# ── Man Page Colors ──────────────────────────────
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"

# ── FZF ──────────────────────────────────────────
export FZF_BASE=/usr/share/fzf

# ── Aliases & Behaviors ─────────────────────────
export LS_COLORS="$(vivid generate one-dark)"
alias ls="eza -l --icons=always --color=always --group-directories-first"
alias ll="eza -la --icons=always --color=always --group-directories-first"

# Arch / pacman helpers
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
alias n="nvim"
alias c="clear"
# alias update="sudo pacman -Syu"
# alias cleanup="sudo pacman -Rsn $(pacman -Qtdq)"
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# Disable XON/XOFF so Ctrl+S works in Neovim
stty -ixon

# ── Tailscale Wrapper ───────────────────────────
tailscale() {
    if [[ " $* " =~ " down " ]]; then
        echo "tailscale down = LOSE SSH ACCESS from remote."
        echo "Server at home, will only get on manually."
        echo -n "Type 'I understand' to proceed: "
        read confirm
        if [[ "$confirm" != "I understand" ]]; then
            echo "Aborted."
            return 1
        fi
    fi
    command tailscale "$@"
}

# ── Completion Tuning ───────────────────────────
zstyle ':completion:*' menu select
setopt AUTO_LIST
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'

# ── Prompt Configuration ────────────────────────
setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%F{#F14E32}(%b)%f'
zstyle ':vcs_info:git*' actionformats '%F{#F14E32}(%b|%a)%f'

precmd() {
    vcs_info
}

build_prompt() {
    local p_time="%D{%H:%M:%S}"
    local p_user="%B%F{red}%n%f%b"
    local p_host="%B%F{red}%m%f%b"
    local p_cwd="%F{green}%~%f"
    local p_vcs="${vcs_info_msg_0_}"

    local p_venv=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        p_venv="%F{cyan}[$(basename "$VIRTUAL_ENV")]%f"
    fi

    local p_rust=""
    if [[ -f Cargo.toml ]]; then
        p_rust="%F{#ffa500}(Rust)%f"
    fi

    if [[ -z "$p_vcs" && -n "${p_venv}${p_rust}" ]]; then
        p_vcs=" "
    fi

    local p_extras="${p_vcs}${p_venv}${p_rust}"
    echo "[${p_time}] ${p_user}@${p_host} ${p_cwd} ${p_extras}"
}

PROMPT='$(build_prompt)
> '

# ── OpenClaw Completion ─────────────────────────
if [[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]]; then
    source "$HOME/.openclaw/completions/openclaw.zsh"
fi

# ── Environment Variables to use DeepSeek API to Claude Code ───────────────────────
export PATH="$HOME/.local/bin:$PATH"
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="*INSERT HERE YOUR DEEPSEEK API KEY"
export ANTHROPIC_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"

# ── Syntax Highlighting & Colors ────────────────
# These must be loaded at the very end of the file

source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/doc/pkgfile/command-not-found.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#ff5555'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#ff5555'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ff5555'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F7BB2F'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F7BB2F'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#4A8789,bold'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#8EC07C'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#CC261F,bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#928474'
ZSH_HIGHLIGHT_STYLES[default]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[path]='fg=#D5C4A2,underline'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#786D82'
