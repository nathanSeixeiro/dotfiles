#!/usr/bin/env bash
#
# install.sh — bootstrap completo do ambiente (dotfiles + editores + ferramentas)
# Repo: https://github.com/nathanSeixeiro/dotfiles
#
# Uso:
#   ./install.sh              # tudo (pacotes base + dotfiles + editor + tools)
#   ./install.sh --dotfiles   # só symlinks (stow) + clone do TPM
#   ./install.sh --base       # só pacotes base (zsh, tmux, git, ripgrep, build tools)
#   ./install.sh --editor     # só neovim + bootstrap LazyVim + Mason (LSPs)
#   ./install.sh --tools      # só CLIs (go, kubectl, kind, k9s, doctl, bat, fd)
#   ./install.sh --tmux-plugins  # só instala plugins do TPM (resurrect, continuum, etc)
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim tmux zshrc television)
NVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { printf "\033[1;32m[install]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[error]\033[0m %s\n" "$1" >&2; }

# ---------------------------------------------------------------------------
# Pacotes base (apt) — pré-requisitos de tudo mais abaixo
# ---------------------------------------------------------------------------
install_base_packages() {
  log "Instalando pacotes base (apt)..."
  sudo apt update
  sudo apt install -y \
    zsh tmux git curl unzip tar build-essential \
    ripgrep bat fd-find \
    stow

  # Debian/Ubuntu instalam bat/fd com nomes diferentes (batcat/fdfind).
  # Cria os symlinks esperados pelo .zshrc (alias cat="bat") e pelo LazyVim (fd).
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true

  log "Pacotes base instalados."
}

# ---------------------------------------------------------------------------
# Oh My Zsh — NÃO instalado automaticamente por este script.
# O .zshrc do repo assume que $HOME/.oh-my-zsh já existe (source $ZSH/oh-my-zsh.sh).
# Se você usa uma instalação própria de Oh My Zsh, garanta que ela já esteja lá
# antes de rodar --dotfiles, ou o shell vai dar erro ao abrir.
# Função mantida aqui apenas como referência/opcional, não é chamada em "all".
# ---------------------------------------------------------------------------
install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh já instalado, pulando."
    return
  fi
  log "Instalando Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log "Oh My Zsh instalado."
}

# ---------------------------------------------------------------------------
# Neovim (binário oficial, release mais recente)
# ---------------------------------------------------------------------------
install_neovim() {
  log "Instalando Neovim (latest release)..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf "$NVIM_INSTALL_DIR"
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm nvim-linux-x86_64.tar.gz
  log "Neovim instalado em $NVIM_INSTALL_DIR (PATH já configurado via .zshrc)."
}

# ---------------------------------------------------------------------------
# Television (fuzzy finder, release mais recente)
# ---------------------------------------------------------------------------
install_television() {
  log "Instalando television (script oficial)..."
  curl -fsSL https://raw.githubusercontent.com/alexpasmantier/television/master/install.sh | bash
  log "television instalado."
}

# ---------------------------------------------------------------------------
# Dotfiles (via GNU Stow)
# ---------------------------------------------------------------------------
install_dotfiles() {
  log "Verificando stow..."
  if ! command -v stow &>/dev/null; then
    sudo apt update && sudo apt install -y stow
  fi

  cd "$DOTFILES_DIR"
  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
      log "Linkando pacote: $pkg"
      stow --restow --target="$HOME" "$pkg"
    else
      warn "Pacote '$pkg' não encontrado, pulando."
    fi
  done

  log "Setup do tmux plugin manager (TPM)..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    log "TPM já instalado."
  fi

  log "Dotfiles linkados com sucesso."
}

# ---------------------------------------------------------------------------
# Tools cloud (sempre a versão mais recente)
# ---------------------------------------------------------------------------
install_go() {
  log "Instalando Go (latest)..."
  GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
  curl -LO "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "${GO_VERSION}.linux-amd64.tar.gz"
  rm "${GO_VERSION}.linux-amd64.tar.gz"
  log "Go instalado: ${GO_VERSION}"
}

install_kubectl() {
  log "Instalando kubectl (latest stable)..."
  KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
  log "kubectl instalado: ${KUBECTL_VERSION}"
}

install_kind() {
  log "Instalando kind (latest stable)..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
  log "kind instalado."
}

install_k9s() {
  log "Instalando k9s (latest)..."
  K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d '"' -f4)
  curl -LO "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
  tar -xzf k9s_Linux_amd64.tar.gz k9s
  sudo mv k9s /usr/local/bin/k9s
  rm k9s_Linux_amd64.tar.gz
  log "k9s instalado: ${K9S_VERSION}"
}

install_doctl() {
  log "Instalando doctl (latest)..."
  DOCTL_VERSION=$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep '"tag_name"' | cut -d '"' -f4 | tr -d 'v')
  curl -LO "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
  tar xf "doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
  sudo mv doctl /usr/local/bin/doctl
  rm "doctl-${DOCTL_VERSION}-linux-amd64.tar.gz"
  log "doctl instalado: ${DOCTL_VERSION}"
}

install_tools() {
  install_go
  install_kubectl
  install_kind
  install_k9s
  install_doctl
  log "Todas as CLIs cloud instaladas."
}

# ---------------------------------------------------------------------------
# Bootstrap do editor: LazyVim (plugins) + Mason (LSPs)
# ---------------------------------------------------------------------------
bootstrap_lazyvim() {
  export PATH="$PATH:$NVIM_INSTALL_DIR/bin"
  if ! command -v nvim &>/dev/null; then
    err "nvim não encontrado no PATH. Rode --editor primeiro (instala o Neovim)."
    return 1
  fi

  log "Sincronizando plugins do LazyVim (headless, esperando conclusão real)..."
  # Espera o evento LazyDone antes de fechar, em vez de +qa imediato —
  # sem isso, o Lazy sync (e o build do tree-sitter-cli via Mason que ele
  # dispara) pode ser cortado no meio, causando "Package is already installing".
  nvim --headless \
    -c "autocmd User LazyDone qa" \
    -c "Lazy! sync" \
    || warn "Lazy sync retornou erro — abra o nvim manualmente para checar (:Lazy)."

  log "Instalando LSPs via Mason (gopls, yaml-language-server, terraform-ls, bash-language-server, dockerfile-language-server)..."
  # Carrega o mason.nvim explicitamente antes de chamar MasonInstall, já que
  # ele é lazy-loaded e o comando não existe até o plugin ser requerido.
  # Espera todas as instalações terminarem via mason-registry antes de sair.
  nvim --headless \
    -c "lua require('mason')" \
    -c "MasonInstall gopls yaml-language-server terraform-ls bash-language-server dockerfile-language-server" \
    -c "autocmd User MasonToolsUpdateCompleted qa" \
    -c "lua vim.defer_fn(function() vim.cmd('qa') end, 90000)" \
    || warn "Mason install retornou erro — abra o nvim e rode :Mason manualmente para checar."

  log "LazyVim + Mason configurados."
  warn "Recomendado: abra o nvim normalmente uma vez (nvim) para confirmar que tudo terminou de instalar (treesitter parsers, LSPs)."
}

install_editor() {
  install_neovim
  bootstrap_lazyvim
}

# ---------------------------------------------------------------------------
# Plugins do tmux via TPM (headless)
# ---------------------------------------------------------------------------
install_tmux_plugins() {
  if [ ! -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    err "TPM não encontrado. Rode --dotfiles primeiro (clona o TPM)."
    return 1
  fi
  log "Instalando plugins do tmux (tpm, resurrect, continuum, vim-navigator)..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  log "Plugins do tmux instalados."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  case "${1:-all}" in
    --dotfiles)     install_dotfiles ;;
    --base)         install_base_packages ;;
    --editor)       install_editor ;;
    --tools)        install_tools ;;
    --tmux-plugins) install_tmux_plugins ;;
    all)
      install_base_packages
      install_dotfiles
      install_editor
      install_television
      install_tools
      install_tmux_plugins
      ;;
    *) err "Argumento inválido: $1"; exit 1 ;;
  esac
  log "Concluído."
}

main "${1:-all}"