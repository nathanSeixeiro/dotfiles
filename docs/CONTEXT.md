# Contexto do projeto dotfiles — resumo da sessão

> Guardar este arquivo para retomar o trabalho em outra conversa/sessão sem
> perder o histórico de decisões. Não precisa necessariamente ir pro repo
> público — pode ficar como nota pessoal.

Repo: https://github.com/nathanSeixeiro/dotfiles

## Atualizações desde a última revisão deste documento

### install.sh — fixes aplicados
- **Bug corrigido**: `.zshrc` nunca teve a linha de PATH do Go (`export PATH="$PATH:/usr/local/go/bin"`)
  — só estava documentada, nunca aplicada no arquivo real. Corrigido.
- **Bootstrap headless do LazyVim/Mason era instável**:
  - `+qa` fechava o Neovim antes do `Lazy sync` (e o build assíncrono do
    tree-sitter-cli que ele dispara) terminar → causava
    `Package is already installing`. Fix: espera o evento `LazyDone` antes
    de fechar.
  - `:MasonInstall` não existia ainda no momento da chamada headless (plugin
    lazy-loaded). Fix: `require('mason')` explícito antes do comando.
  - Timeout do Mason install (30s) era curto demais — 2 de 5 LSPs (`gopls`,
    `dockerfile-language-server`) não completavam a tempo. Aumentado pra 90s.
- **television**: trocado de download manual de release do GitHub pro script
  oficial deles (`curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash`)
- **Oh My Zsh**: confirmado como pré-requisito manual, não automatizado
  (decisão explícita do usuário)

### Novo: `.zshrc` com override por máquina
Padrão adotado (Opção B, decidida explicitamente pelo usuário): o `.zshrc`
versionado no repo é genérico; configs específicas de cada máquina (nvm,
envman, BROWSER, aliases locais tipo `argocd-switch`) ficam em
`~/.config/zsh/local.zsh`, **não versionado**, carregado no final do
`.zshrc` via:
```bash
[ -f "$HOME/.config/zsh/local.zsh" ] && source "$HOME/.config/zsh/local.zsh"
```
Esse padrão foi necessário porque uma segunda máquina de trabalho (usuário
`nathan`, contexto "senai") tinha um `.zshrc` real (não symlink) com nvm,
envman, docker/aws plugins extras e um alias `argocd-switch` — específicos
daquela máquina, não do dotfiles pessoal genérico.

### Novo: `scripts/health.sh`
Script de diagnóstico geral do ambiente — testado numa máquina nova e já
encontrou 3 problemas reais (documentados acima: Go PATH, 2 LSPs faltando).
Localização real: **`scripts/health.sh`**, não na raiz do repo (correção
de um erro de documentação anterior deste mesmo CONTEXT.md).

Uso:
```bash
./scripts/health.sh       # checagem normal
./scripts/health.sh -v    # verboso, com versões
```

### CodeRabbit — avaliado, não implementado ainda
Discutido como ferramenta de code review por IA (GitHub App + CLI local).
Usuário tem interesse em:
1. Instalar o GitHub App na conta pessoal (`https://github.com/apps/coderabbitai`)
   pra revisar PRs automaticamente — grátis para repos públicos como o `dotfiles`
2. Instalar a CLI (`cr`/`coderabbit`) pra validação local antes de commit:
   ```bash
   curl -fsSL https://cli.coderabbit.ai/install.sh | sh
   cr auth login
   cr review --type uncommitted
   ```
3. Possível próximo passo (ainda não decidido): hook de pre-commit rodando
   `cr review --type uncommitted --prompt-only` automaticamente

---

## Estado atual (confirmado, funcionando)

- Repo único e consolidado em `~/dotfiles` (local) = origin no GitHub
- **Todos os symlinks do sistema apontam pra `~/dotfiles`** (não mais para
  `~/projects/dotfiles`, que foi um erro criado no meio da sessão e depois
  removido por completo)
- Estrutura padrão GNU Stow: cada pasta no topo = 1 package, espelhando a
  árvore de `$HOME` dentro dela

```
dotfiles/
├── nvim/.config/nvim/           → ~/.config/nvim (LazyVim completo)
├── tmux/.tmux.conf              → ~/.tmux.conf
├── zshrc/.zshrc                 → ~/.zshrc
├── television/.config/television/ → ~/.config/television
├── docs/
│   ├── neovim.md
│   └── tools-installation.md
├── install.sh
├── README.md
└── .gitignore
```

## Decisões importantes tomadas

1. **doctl e k9s**: revertidos para "só instalação" (sem symlink/versionamento),
   por decisão explícita do usuário — não têm customização pessoal relevante
2. **Go, kind, kubectl**: idem, só instalação via script
3. **bat/fd-find**: via `apt`, com tratamento do detalhe Debian/Ubuntu
   (binários instalam como `batcat`/`fdfind` → symlink pra `bat`/`fd` em
   `~/.local/bin`, que já está no PATH via `.zshrc`)
4. **Oh My Zsh NÃO é instalado pelo script** — é pré-requisito manual. O
   `.zshrc` do repo depende de `~/.oh-my-zsh` já existir
   (`source $ZSH/oh-my-zsh.sh`)
5. **television**: instalado via script oficial deles
   (`curl -fsSL .../install.sh | bash`), não via download manual de release
6. **Versões sempre "latest"**: todos os comandos de instalação (go, kubectl,
   kind, k9s, doctl) buscam dinamicamente a versão mais recente, nunca fixam
   versão — decisão explícita do usuário
7. **`.aws` e `.kube/config` NUNCA entram no repo** — credenciais sensíveis,
   ficam fora do versionamento por design

## Erro cometido e corrigido durante a sessão

Claude criou por engano um segundo repositório em `~/projects/dotfiles`
(deveria ter usado `~/dotfiles` desde o início, que era onde o usuário já
estava trabalhando). Isso gerou dois repos git paralelos com conteúdo quase
idêntico, além de uma pasta recursiva `~/dotfiles/dotfiles/dotfiles/...`
(lixo de cópia acidental, nunca rastreada pelo git). Processo de resolução:

1. Comparado `diff -rq` entre as duas pastas → nvim, tmux, zshrc eram
   idênticos entre si
2. `television` só existia em `~/projects/dotfiles` → copiado pro lugar certo
3. `~/projects/dotfiles` apagado por completo
4. Pasta recursiva lixo `~/dotfiles/dotfiles` apagada (confirmado via
   `git ls-files` que nunca esteve rastreada)
5. Todos os symlinks do sistema refeitos apontando pra `~/dotfiles`

**Licão:** sempre confirmar o caminho exato do diretório de trabalho antes
de rodar comandos com caminho absoluto, especialmente em sessões longas.

## Neovim / LazyVim — customizações do usuário

- **Keymaps custom** (`lua/config/keymaps.lua`):
  - `C-z` / `C-y` → undo/redo (normal E insert mode) — porque `C-z` nativo
    do Vim faz `:suspend`, não undo
  - `C-s` → salvar (normal e insert mode)
- **Keymaps de plugins** (`lua/plugins/keymaps.lua`):
  - Grupos which-key: `<leader>t` (Terminal), `<leader>k` (Kubernetes),
    `<leader>i` (Infra/Terraform)
  - `<leader>tt` → abrir terminal
  - `<leader>ka` → `kubectl apply -f %`
  - `<leader>ti/tp/tf` → terraform init/plan/fmt
  - ⚠️ Nota deixada na doc: `<leader>t` serve dois papéis (Terminal E
    Terraform) — não há conflito técnico mas pode confundir; usuário ainda
    não decidiu se quer reorganizar
- **LSPs via Mason**: gopls, yaml-language-server, terraform-ls,
  bash-language-server, dockerfile-language-server
- **yamlls** (`lua/plugins/kubernetes.lua`): aplica schemas do Kubernetes
  automaticamente em `*.yaml`/`*.yml`
- **Neo-tree** (`lua/plugins/neo-tree.lua`): `hide_dotfiles = false` e
  `hide_gitignored = false` — dotfiles e arquivos gitignored aparecem por
  padrão na árvore
- **Select all discutido mas NÃO aplicado ainda**: usuário queria bind tipo
  `C-a`, mas isso conflita com o prefix do tmux (`set -g prefix C-a`).
  Alternativa sugerida: `ggVG` (comando nativo) ou mapear em `aa`/`AA`
  (aceitando o pequeno delay no `a`/`A` normal por causa do timeout de
  sequência de teclas). **Ainda não decidido/aplicado no keymaps.lua.**

## Known issue documentado

**Tree-sitter — `GLIBC_2.39 not found`**
Ambiente: Ubuntu 22.04.5 LTS (WSL2), glibc 2.35. Alguns parsers do
`nvim-treesitter` exigem glibc 2.39 (só disponível a partir do Ubuntu 24.04).
Decisão: manter ambiente como está por enquanto; considerar migração para
Ubuntu 24.04 no WSL no futuro.

## tmux — configuração relevante

- Prefix: `C-a` (não o padrão `C-b`)
- Mouse on, true color, base-index 1
- Navegação entre panes: `C-<setas>` (sem prefix), integrado com Neovim
  (vim-tmux-navigator)
- Plugins via TPM: `tmux-sensible`, `vim-tmux-navigator`, `tmux-resurrect`,
  `tmux-continuum` (`@continuum-restore on` — restauração automática)

## install.sh — estrutura atual das flags

```bash
./install.sh              # tudo
./install.sh --base       # zsh, tmux, git, ripgrep, bat, fd-find, stow
./install.sh --dotfiles   # stow + clone TPM
./install.sh --editor     # neovim (binário) + lazy sync headless + mason install headless
./install.sh --tools      # go, kubectl, kind, k9s, doctl
./install.sh --tmux-plugins  # roda install_plugins do TPM direto
```

`install_television` e `install_oh_my_zsh` existem como funções mas
**Oh My Zsh não é chamada automaticamente no fluxo `all`** (pré-requisito
manual, por pedido do usuário).

## Pendências / próximos passos em aberto

- [ ] Testar `stow --restow --target="$HOME" --simulate <pkg>` antes de rodar
      o script de verdade numa máquina nova (symlinks já existentes podem
      conflitar com o stow na primeira execução — talvez precise de
      `--adopt`)
- [ ] Decidir e aplicar o bind de "select all" (`aa` vs `ggVG` vs outro)
- [ ] Resolver se quer reorganizar `<leader>t` (Terminal vs Terraform)
- [ ] Possíveis docs futuras sugeridas mas ainda não criadas:
      `docs/tmux.md`, `docs/zsh.md`
- [ ] Validar na prática se `install_television` (script oficial) e o
      bootstrap headless do LazyVim/Mason funcionam de ponta a ponta numa
      máquina limpa (nunca testado fim-a-fim ainda)

## Perfil do usuário (contexto de fundo, não repo-específico)

Nathan Seixeiro — Cloud Native / Kubernetes / Platform Engineering. Gosta de
entender o "porquê" das coisas, não só decorar; documenta bastante;
contribui pra comunidade CNCF/KEDA; busca crescimento técnico consistente.