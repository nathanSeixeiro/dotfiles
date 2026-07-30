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
| [`scripts/`](./scripts) | Scripts utilitários (`health.sh` — checagem geral do ambiente) |
| [`docs/`](./docs) | Documentação detalhada de cada parte do setup |

## Ferramentas instaladas pelo script (sem config versionada)

- **Base:** zsh, tmux, git, ripgrep, bat, fd-find, stow (via apt)
- **Shell:** `.zshrc` linkado via stow (Oh My Zsh é pré-requisito manual, não instalado pelo script)
- **Editor:** Neovim (binário oficial, latest release) — LazyVim e LSPs (Mason)
  são sincronizados automaticamente no bootstrap
- **Cloud CLIs:** Go, kubectl, kind, k9s, doctl (sempre a versão mais recente)
- **television:** instalado via script oficial (`install.sh` do repo alexpasmantier/television)

Detalhes de cada instalação: [docs/tools-installation.md](./docs/tools-installation.md).

## Instalação

```bash
git clone https://github.com/nathanSeixeiro/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Isso faz o bootstrap completo, do zero: pacotes base → dotfiles (symlinks + TPM)
→ Neovim + LazyVim + Mason (LSPs) → television → CLIs cloud (go, kubectl, kind,
k9s, doctl) → plugins do tmux.

> ⚠️ **Pré-requisito:** o `.zshrc` deste repo assume que `Oh My Zsh` já está
> instalado em `~/.oh-my-zsh` (`source $ZSH/oh-my-zsh.sh`). O script **não**
> instala o Oh My Zsh automaticamente — instale manualmente antes de rodar
> `--dotfiles`, ou o shell vai dar erro ao abrir:
> ```bash
> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
> ```

Também dá pra rodar em partes:

```bash
./install.sh --base          # zsh, tmux, git, ripgrep, bat, fd-find, stow
./install.sh --dotfiles      # symlinks (stow) + clone do TPM
./install.sh --editor        # neovim + bootstrap LazyVim + Mason (LSPs)
./install.sh --tools         # go, kubectl, kind, k9s, doctl
./install.sh --tmux-plugins  # instala plugins do TPM (resurrect, continuum, etc)
```

O script usa `stow` para linkar cada pasta pra dentro de `$HOME`, então qualquer
edição feita aqui no repo já reflete direto no ambiente (e vice-versa).

> Depois do `./install.sh`, troque o shell padrão para zsh (se ainda não estiver):
> ```bash
> chsh -s $(which zsh)
> ```
> Requer logout/login (ou reiniciar o terminal) para valer.

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

## Health check

```bash
./scripts/health.sh          # checagem geral do ambiente
./scripts/health.sh -v       # modo verboso, com versões completas
```

Confere symlinks, LSPs instalados via Mason, plugins do tmux, PATH e todas as
CLIs — útil depois de rodar o `install.sh` numa máquina nova, ou pra debugar
quando algo "some" do ambiente.

## Documentação

- [docs/neovim.md](./docs/neovim.md) — keymaps customizados + cheatsheet básico de Vim
- [docs/tools-installation.md](./docs/tools-installation.md) — instalação das CLIs (go, kubectl, kind, k9s, doctl)

## Notas

- `.aws` e `.docker` **não** são versionados aqui — são symlinks específicos da
  integração WSL↔Windows na minha máquina, configurados manualmente.
- `~/.kube/config` também nunca entra no repo (credenciais de cluster).