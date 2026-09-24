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

# Node via nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use default &>/dev/null

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
alias gaa="git add ."
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gw="git switch"
alias gwm="git switch main" 

# =========================
# Tools
# =========================

# Television
export TV_SHELL=zsh

# =========================
# Local (por máquina, não versionado)
# =========================
[ -f "$HOME/.config/zsh/local.zsh" ] && source "$HOME/.config/zsh/local.zsh"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
