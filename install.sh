#!/usr/bin/env bash
#
# install.sh — bootstrap do ambiente (dotfiles + ferramentas)
# Repo: https://github.com/nathanSeixeiro/dotfiles
#
# Uso:
#   ./install.sh            # symlinks + tools
#   ./install.sh --dotfiles # só symlinks
#   ./install.sh --tools    # só instalação de ferramentas
#

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim tmux zshrc television)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { printf "\033[1;32m[install]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$1"; }
err() { printf "\033[1;31m[error]\033[0m %s\n" "$1" >&2; }

# ---------------------------------------------------------------------------
# Dotfiles (via GNU Stow)
# ---------------------------------------------------------------------------
install_dotfiles() {
  log "Verificando stow..."
  if ! command -v stow &>/dev/null; then
    log "Instalando stow..."
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

  # Zshrc é a exceção: a pasta se chama 'zshrc' mas o alvo é ~/.zshrc direto
  # (stow --restow já resolve isso pois zshrc/.zshrc -> ~/.zshrc)

  log "Setup do tmux plugin manager (TPM)..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    log "TPM já instalado."
  fi

  log "Dotfiles linkados com sucesso."
}

# ---------------------------------------------------------------------------
# Tools (sempre a versão mais recente)
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

install_bat_fd() {
  log "Instalando bat e fd-find (apt)..."
  sudo apt update
  sudo apt install -y bat fd-find

  # No Debian/Ubuntu os binários instalam como 'batcat' e 'fdfind'.
  # Cria symlinks para 'bat' e 'fd' em ~/.local/bin (já está no PATH via .zshrc).
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true
  log "bat e fd instalados (symlinks em ~/.local/bin)."
}

install_tools() {
  install_go
  install_kubectl
  install_kind
  install_k9s
  install_doctl
  install_bat_fd
  log "Todas as ferramentas instaladas."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  case "${1:-all}" in
  --dotfiles) install_dotfiles ;;
  --tools) install_tools ;;
  all)
    install_dotfiles
    install_tools
    ;;
  *)
    err "Argumento inválido: $1"
    exit 1
    ;;
  esac
  log "Concluído."
}

main "${1:-all}"
