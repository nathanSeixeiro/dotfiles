# =========================
# Oh My Zsh
# =========================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  kubectl
  terraform
)

source $ZSH/oh-my-zsh.sh


# =========================
# Environment
# =========================

# Neovim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Go
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"

# User binaries
export PATH="$HOME/.local/bin:$PATH"


# =========================
# Aliases
# =========================

# Kubernetes
alias k="kubectl"

# Terraform
alias tf="terraform"


# =========================
# Git aliases
# =========================

alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"


# =========================
# Tools
# =========================

# Television
export TV_SHELL=zsh

# =========================
# Local (por máquina, não versionado)
# =========================
[ -f "$HOME/.config/zsh/local.zsh" ] && source "$HOME/.config/zsh/local.zsh"
