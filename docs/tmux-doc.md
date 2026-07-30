# tmux

Config em `tmux/.tmux.conf`. Prefix customizado: **`C-a`** (não o padrão `C-b`).

> ⚠️ Como o prefix é `C-a`, qualquer bind do Neovim ou de outro programa que
> use `C-a` sozinho (ex: "select all") **não funciona** dentro de uma sessão
> tmux — o tmux intercepta a tecla antes de repassar pro programa.

---

## Sua configuração customizada

| Recurso | Config |
|---|---|
| Prefix | `C-a` (era `C-b`, remapeado) |
| Recarregar config | `prefix` + `r` |
| Mouse | habilitado |
| True color | habilitado (integração com Neovim) |
| Base index | painéis/janelas começam em `1`, não `0` |
| Escape time | `10ms` (mais responsivo pro Vim) |
| Focus events | habilitado (necessário pro Neovim detectar foco) |

### Navegação entre panes (sem prefix)

| Atalho | Ação |
|---|---|
| `C-←` | pane à esquerda |
| `C-→` | pane à direita |
| `C-↑` | pane acima |
| `C-↓` | pane abaixo |

Integrado com `vim-tmux-navigator` — as mesmas teclas navegam entre splits
do Neovim e panes do tmux de forma transparente, sem precisar saber em qual
dos dois você está.

### Split de painéis

| Atalho | Ação |
|---|---|
| `prefix` + `\|` | split horizontal (lado a lado), mantém diretório atual |
| `prefix` + `-` | split vertical (em cima/embaixo), mantém diretório atual |

### Resize de painéis

| Atalho | Ação |
|---|---|
| `prefix` + `H` | reduz 5 colunas pra esquerda |
| `prefix` + `J` | reduz 5 linhas pra baixo |
| `prefix` + `K` | reduz 5 linhas pra cima |
| `prefix` + `L` | reduz 5 colunas pra direita |

### Plugins (via TPM)

| Plugin | Função |
|---|---|
| `tpm` | gerenciador de plugins |
| `tmux-sensible` | defaults sensatos (base de configuração) |
| `vim-tmux-navigator` | navegação unificada tmux ↔ Neovim |
| `tmux-resurrect` | salva/restaura sessões, janelas e painéis |
| `tmux-continuum` | auto-restauração ao abrir o tmux (`@continuum-restore on`) |

Instalar/atualizar plugins: `prefix` + `I` (maiúsculo), ou via script:
```bash
./install.sh --tmux-plugins
```

---

## Cheatsheet básico (comandos nativos do tmux)

### Sessões

| Comando | Ação |
|---|---|
| `tmux` | inicia uma nova sessão sem nome |
| `tmux new -s nome` | inicia uma nova sessão com nome |
| `tmux ls` | lista sessões ativas |
| `tmux attach -t nome` | reconecta numa sessão existente |
| `tmux kill-session -t nome` | encerra uma sessão específica |
| `prefix` + `d` | desconecta da sessão (ela continua rodando em background) |
| `prefix` + `s` | lista e troca entre sessões (visual) |
| `prefix` + `$` | renomeia a sessão atual |

### Janelas (windows)

| Atalho | Ação |
|---|---|
| `prefix` + `c` | cria nova janela |
| `prefix` + `,` | renomeia a janela atual |
| `prefix` + `n` | próxima janela |
| `prefix` + `p` | janela anterior |
| `prefix` + `0-9` | vai direto pra janela pelo número |
| `prefix` + `w` | lista janelas (visual, pra escolher) |
| `prefix` + `&` | fecha a janela atual (pede confirmação) |

### Painéis (panes)

| Atalho | Ação |
|---|---|
| `prefix` + `\|` | split horizontal (seu bind customizado) |
| `prefix` + `-` | split vertical (seu bind customizado) |
| `C-<setas>` | navega entre panes (seu bind customizado) |
| `prefix` + `z` | zoom no pane atual (tela cheia temporária) |
| `prefix` + `x` | fecha o pane atual (pede confirmação) |
| `prefix` + `{` | move o pane pra posição anterior |
| `prefix` + `}` | move o pane pra próxima posição |

### Modo cópia (copy mode — navegar/copiar texto do histórico)

| Atalho | Ação |
|---|---|
| `prefix` + `[` | entra em copy mode |
| `q` | sai do copy mode |
| `Espaço` | inicia seleção (dentro do copy mode) |
| `Enter` | copia a seleção e sai do copy mode |
| `prefix` + `]` | cola o que foi copiado |

> Como `mouse on` está habilitado na sua config, também dá pra selecionar
> texto com o mouse diretamente — o tmux copia automaticamente ao soltar.

### Sessões persistentes (resurrect/continuum)

| Atalho | Ação |
|---|---|
| `prefix` + `Ctrl-s` | salva o estado da sessão manualmente (resurrect) |
| `prefix` + `Ctrl-r` | restaura a última sessão salva manualmente |

Com `continuum` ativo (`@continuum-restore on`), a restauração acontece
**automaticamente** ao abrir o tmux — não precisa rodar `Ctrl-r` na maioria
dos casos, só use isso como plano B.

---

## Troubleshooting rápido

**Cores estranhas / sem true color no Neovim dentro do tmux:**
```bash
echo $TERM   # deve mostrar algo como "tmux-256color" ou "xterm-256color"
```
Se não, confere se seu terminal local também exporta suporte a 256 cores/true
color antes do tmux iniciar.

**`prefix + r` não recarrega nada:**
Confirma que está editando o arquivo certo — o `.tmux.conf` real é o do
repo (`~/dotfiles/tmux/.tmux.conf`), linkado via symlink em `~/.tmux.conf`.
Editar direto em `~/.tmux.conf` funciona igual (é o mesmo arquivo por baixo
do symlink), mas só faz sentido versionar via repo.