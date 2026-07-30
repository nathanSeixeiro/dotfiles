# dotfiles

Setup do meu ambiente de desenvolvimento (WSL2/Ubuntu), gerenciado via [GNU Stow](https://www.gnu.org/software/stow/).
Foco em Cloud Native / Kubernetes / Platform Engineering.

## Stack

- **Sistema:** Ubuntu 22.04.5 LTS (WSL2)
- **Shell:** Zsh + Oh My Zsh (tema `robbyrussell`)
- **Multiplexador:** tmux (prefix `C-a`, TPM, `tmux-resurrect` + `tmux-continuum`
  para sessões persistentes entre reinicializações)
- **Editor:** Neovim + LazyVim
- **LSPs:** Go, YAML (schemas Kubernetes), Terraform, Bash, Dockerfile
- **Navegação integrada tmux ↔ Neovim** via `Ctrl + setas`

## O que tem aqui

| Pasta | O que é |
|---|---|
| [`nvim/`](./nvim) | Config do Neovim (LazyVim) — ver [docs/neovim.md](./docs/neovim.md) |
| [`tmux/`](./tmux) | Config do tmux (prefix `C-a`, TPM, resurrect/continuum) |
| [`zshrc/`](./zshrc) | `.zshrc` (oh-my-zsh, tema robbyrussell, aliases git/k8s/terraform) |
| [`television/`](./television) | Config do [television](https://github.com/alexpasmantier/television) (fuzzy finder) |
| [`docs/`](./docs) | Documentação detalhada de cada parte do setup |

## Ferramentas (instaladas via script, sem config versionada)

Go, kubectl, kind, k9s, doctl (sempre na versão mais recente) + `bat` e `fd-find`
(via apt). Detalhes em [docs/tools-installation.md](./docs/tools-installation.md).

## Instalação

```bash
git clone https://github.com/nathanSeixeiro/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Também dá pra rodar em partes:

```bash
./install.sh --dotfiles   # só cria os symlinks (stow)
./install.sh --tools      # só instala go/kubectl/kind/k9s/doctl
```

O script usa `stow` para linkar cada pasta pra dentro de `$HOME`, então qualquer
edição feita aqui no repo já reflete direto no ambiente (e vice-versa).

## Estrutura (padrão Stow)

Cada pasta no topo do repo é um "package" do stow — a árvore dentro dela espelha
exatamente onde o arquivo deve cair dentro de `$HOME`:

```
dotfiles/
├── nvim/.config/nvim/       → ~/.config/nvim
├── tmux/.tmux.conf          → ~/.tmux.conf
├── zshrc/.zshrc             → ~/.zshrc
└── television/.config/television/ → ~/.config/television
```

## Documentação

- [docs/neovim.md](./docs/neovim.md) — keymaps customizados + cheatsheet básico de Vim
- [docs/tools-installation.md](./docs/tools-installation.md) — instalação das CLIs (go, kubectl, kind, k9s, doctl)

## Notas

- `.aws` e `.docker` **não** são versionados aqui — são symlinks específicos da
  integração WSL↔Windows na minha máquina, configurados manualmente.
- `~/.kube/config` também nunca entra no repo (credenciais de cluster).
