#!/usr/bin/env bash
#
# health.sh — checagem geral do ambiente (dotfiles + ferramentas)
# Repo: https://github.com/nathanSeixeiro/dotfiles
#
# Uso:
#   ./health.sh          # roda todas as checagens
#   ./health.sh -v        # modo verboso (mostra versões completas)
#
set -uo pipefail # sem -e: queremos continuar mesmo se um check falhar

VERBOSE="${1:-}"
PASS=0
FAIL=0
WARN=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
ok() {
  printf "  \033[1;32m✔\033[0m %s\n" "$1"
  PASS=$((PASS + 1))
}
bad() {
  printf "  \033[1;31m✘\033[0m %s\n" "$1"
  FAIL=$((FAIL + 1))
}
warn() {
  printf "  \033[1;33m!\033[0m %s\n" "$1"
  WARN=$((WARN + 1))
}
section() { printf "\n\033[1;36m▸ %s\033[0m\n" "$1"; }

check_cmd() {
  local cmd="$1" label="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    if [ "$VERBOSE" = "-v" ]; then
      local version
      version=$("$cmd" --version 2>&1 | head -1)
      ok "$label ($version)"
    else
      ok "$label instalado"
    fi
    return 0
  else
    bad "$label não encontrado no PATH"
    return 1
  fi
}

check_symlink() {
  local path="$1" expected_contains="$2" label="$3"
  if [ -L "$path" ]; then
    local target
    target=$(readlink -f "$path")
    if [[ "$target" == *"$expected_contains"* ]]; then
      ok "$label -> $target"
    else
      warn "$label é symlink mas aponta pra fora do repo: $target"
    fi
  elif [ -e "$path" ]; then
    bad "$label existe mas NÃO é symlink (arquivo real, provavelmente não linkado via stow)"
  else
    bad "$label não existe"
  fi
}

# ---------------------------------------------------------------------------
# 1. Symlinks dos dotfiles
# ---------------------------------------------------------------------------
section "Dotfiles (symlinks)"
check_symlink "$HOME/.zshrc" "dotfiles" ".zshrc"
check_symlink "$HOME/.tmux.conf" "dotfiles" ".tmux.conf"
check_symlink "$HOME/.config/nvim" "dotfiles" ".config/nvim"
check_symlink "$HOME/.config/television" "dotfiles" ".config/television"

# ---------------------------------------------------------------------------
# 2. Config local por máquina
# ---------------------------------------------------------------------------
section "Config local (não versionada)"
if [ -f "$HOME/.config/zsh/local.zsh" ]; then
  ok "~/.config/zsh/local.zsh existe"
else
  warn "~/.config/zsh/local.zsh não existe (ok se esta máquina não precisa de config local)"
fi

# ---------------------------------------------------------------------------
# 3. Shell
# ---------------------------------------------------------------------------
section "Shell"
check_cmd zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  ok "Oh My Zsh instalado"
else
  bad "Oh My Zsh NÃO instalado (o .zshrc do repo depende dele)"
fi
if [[ "$SHELL" == *"zsh"* ]]; then
  ok "zsh é o shell padrão (\$SHELL=$SHELL)"
else
  warn "shell padrão não é zsh (\$SHELL=$SHELL) — rode: chsh -s \$(which zsh)"
fi

# ---------------------------------------------------------------------------
# 4. Editor
# ---------------------------------------------------------------------------
section "Neovim / LazyVim"
check_cmd nvim
if command -v nvim &>/dev/null; then
  LAZY_LOCK="$HOME/.config/nvim/lazy-lock.json"
  if [ -f "$LAZY_LOCK" ]; then
    PLUGIN_COUNT=$(grep -c '":' "$LAZY_LOCK" 2>/dev/null || echo 0)
    ok "lazy-lock.json presente (~$PLUGIN_COUNT plugins travados)"
  else
    warn "lazy-lock.json não encontrado — LazyVim pode não ter sincronizado ainda"
  fi

  MASON_BIN="$HOME/.local/share/nvim/mason/bin"
  for lsp in gopls yaml-language-server terraform-ls bash-language-server dockerfile-language-server; do
    if [ -x "$MASON_BIN/$lsp" ]; then
      ok "LSP: $lsp instalado (via Mason)"
    else
      bad "LSP: $lsp NÃO encontrado em $MASON_BIN"
    fi
  done
fi

# ---------------------------------------------------------------------------
# 5. tmux
# ---------------------------------------------------------------------------
section "tmux"
check_cmd tmux
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  ok "TPM instalado"
  PLUGIN_DIRS=$(find "$HOME/.tmux/plugins" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
  if [ "$PLUGIN_DIRS" -gt 1 ]; then
    ok "$((PLUGIN_DIRS - 1)) plugin(s) do tmux instalado(s) além do TPM"
  else
    warn "TPM instalado mas nenhum plugin baixado ainda — rode: ./install.sh --tmux-plugins"
  fi
else
  bad "TPM não encontrado em ~/.tmux/plugins/tpm"
fi

# ---------------------------------------------------------------------------
# 6. CLIs cloud
# ---------------------------------------------------------------------------
section "CLIs cloud"
check_cmd go
check_cmd kubectl
check_cmd kind
check_cmd k9s
check_cmd doctl

# ---------------------------------------------------------------------------
# 7. Utilitários
# ---------------------------------------------------------------------------
section "Utilitários"
check_cmd bat
check_cmd fd
check_cmd rg "ripgrep"
check_cmd tv "television"
check_cmd stow

# ---------------------------------------------------------------------------
# 8. Sanidade do PATH
# ---------------------------------------------------------------------------
section "PATH"
if echo "$PATH" | grep -q "/opt/nvim-linux-x86_64/bin"; then
  ok "PATH inclui o Neovim"
else
  bad "PATH NÃO inclui /opt/nvim-linux-x86_64/bin — abra um terminal novo ou 'source ~/.zshrc'"
fi
if echo "$PATH" | grep -q "$HOME/.local/bin"; then
  ok "PATH inclui ~/.local/bin"
else
  bad "PATH NÃO inclui ~/.local/bin (necessário pra bat/fd)"
fi

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
echo ""
echo "─────────────────────────────────────"
printf "\033[1;32m%s OK\033[0m   \033[1;33m%s avisos\033[0m   \033[1;31m%s falhas\033[0m\n" "$PASS" "$WARN" "$FAIL"
echo "─────────────────────────────────────"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
