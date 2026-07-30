# Neovim / LazyVim

Config baseada no [LazyVim](https://www.lazyvim.org/), com customizações pessoais
em cima da base padrão. Repositório: `~/dotfiles/nvim/.config/nvim/`.

---

## Estrutura

```
nvim/.config/nvim/
├── init.lua
├── lazy-lock.json          # versões travadas dos plugins (não editar manualmente)
├── lazyvim.json             # extras/imports do LazyVim habilitados
├── stylua.toml              # formatação de código Lua
└── lua/
    ├── config/
    │   ├── autocmds.lua      # autocomandos (eventos automáticos)
    │   ├── keymaps.lua       # SEUS atalhos customizados (carregado no VeryLazy)
    │   ├── lazy.lua          # bootstrap do lazy.nvim
    │   └── options.lua       # opções gerais (tabsize, numbers, etc)
    └── plugins/
        ├── example.lua       # exemplo padrão do LazyVim (referência)
        ├── keymaps.lua       # atalhos ligados a plugins específicos (Terraform)
        ├── kubernetes.lua    # config do yamlls para schemas do Kubernetes
        └── neo-tree.lua      # customização da árvore de arquivos
```

> Atalhos padrão do LazyVim (não listados aqui) estão documentados oficialmente em:
> https://www.lazyvim.org/keymaps

---

## Seus keymaps customizados

Definidos em `lua/config/keymaps.lua`:

| Atalho | Modo | Ação | Motivo |
|---|---|---|---|
| `C-z` | Normal | Undo | Por padrão `C-z` suspende o Neovim (`:suspend`); remapeado para comportamento de "undo" como em editores comuns |
| `C-y` | Normal | Redo | Não existe padrão nativo pra isso; mapeado pra `C-r` (redo real do Vim) |
| `C-s` | Normal | Salvar (`:w`) | Atalho comum em outros editores |
| `C-s` | Insert | Salvar (sai do insert, salva) | Mesma lógica, funcionando também durante digitação |

```lua
local map = vim.keymap.set
map("n", "<C-z>", "u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Save" })
```

---

## LSPs instalados (via Mason)

| LSP | Linguagem |
|---|---|
| `gopls` | Go |
| `yaml-language-server` | YAML (com schemas do Kubernetes) |
| `terraform-ls` | Terraform |
| `bash-language-server` | Bash |
| `dockerfile-language-server` | Dockerfile |

Todos com validação, autocomplete e hover funcionando via LSP nativo do Neovim.

---

## Keymaps de plugins (`lua/plugins/keymaps.lua`)

Grupos registrados no Which-Key:

| Grupo | Nome |
|---|---|
| `<leader>t` | Terminal |
| `<leader>k` | Kubernetes |
| `<leader>i` | Infra / Terraform |

Atalhos:

| Atalho | Ação |
|---|---|
| `<leader>tt` | abrir terminal |
| `<leader>ka` | `kubectl apply -f %` (aplica o arquivo atual) |
| `<leader>ti` | `terraform init` |
| `<leader>tp` | `terraform plan` |
| `<leader>tf` | `terraform fmt` |

> Nota: `<leader>t` está usado tanto para o grupo "Terminal" quanto para os
> atalhos de Terraform (`ti`, `tp`, `tf`). Como são sub-chaves diferentes
> (`tt` vs `ti/tp/tf`) não há conflito, mas vale revisar se quiser separar
> os grupos por clareza no futuro (ex: mover Terraform pra `<leader>i`).

---

## Kubernetes / YAML (`lua/plugins/kubernetes.lua`)

Configura o `yamlls` (LSP de YAML) para aplicar automaticamente os schemas do
Kubernetes em qualquer arquivo `*.yaml`/`*.yml` — dá autocomplete e validação de
manifests (Deployment, Service, etc) sem precisar de comentário `# yaml-language-server`
no topo do arquivo.

---

## Neo-tree (`lua/plugins/neo-tree.lua`)

> ⚠️ Conteúdo ainda não documentado aqui — colar o arquivo depois para eu
> completar esta seção.

---

## Cheatsheet básico (pra nunca mais esquecer)

### Navegação

| Tecla | Ação |
|---|---|
| `h` `j` `k` `l` | esquerda / baixo / cima / direita |
| `w` | pula pra próxima palavra |
| `b` | volta pra palavra anterior |
| `0` | início da linha |
| `$` | fim da linha |
| `gg` | início do arquivo |
| `G` | fim do arquivo |
| `Ctrl-d` / `Ctrl-u` | meia página pra baixo / pra cima |
| `{` / `}` | pula parágrafo (bloco em branco) anterior/seguinte |

### Editar / Apagar

| Tecla | Ação |
|---|---|
| `i` | insert antes do cursor |
| `a` | insert depois do cursor |
| `o` | nova linha abaixo + insert |
| `O` | nova linha acima + insert |
| `x` | apaga o caractere sob o cursor |
| `dd` | apaga a linha inteira |
| `dw` | apaga até o fim da palavra |
| `d$` | apaga até o fim da linha |
| `cc` | apaga a linha inteira e entra em insert |
| `cw` | apaga a palavra e entra em insert |

### Copiar / Colar (yank/paste)

| Tecla | Ação |
|---|---|
| `yy` | copia (yank) a linha inteira |
| `yw` | copia a palavra |
| `p` | cola depois do cursor/linha |
| `P` | cola antes do cursor/linha |
| `v` | seleção visual (caractere) |
| `V` | seleção visual (linha inteira) |
| `y` (em visual) | copia a seleção |
| `d` (em visual) | apaga a seleção |

### Undo / Redo / Salvar (seus atalhos + nativos)

| Tecla | Ação |
|---|---|
| `u` ou `C-z` | undo |
| `C-r` ou `C-y` | redo |
| `C-s` | salvar |
| `.` | repete a última ação |

### Busca

| Tecla | Ação |
|---|---|
| `/palavra` | busca pra frente |
| `?palavra` | busca pra trás |
| `n` | próxima ocorrência |
| `N` | ocorrência anterior |

### Janelas / Buffers (LazyVim)

| Tecla | Ação |
|---|---|
| `<leader>e` | abre/fecha neo-tree (árvore de arquivos) |
| `<leader>ff` | busca arquivo (find files) |
| `<leader>fg` | busca por texto no projeto (grep) |
| `<Tab>` / `<S-Tab>` | próximo / buffer anterior |
| `<leader>bd` | fecha buffer atual |

> `<leader>` no LazyVim padrão é a tecla **espaço**.

---

## Known issues

### Tree-sitter — `GLIBC_2.39 not found`

**Ambiente:** Ubuntu 22.04.5 LTS (WSL2), `glibc 2.35`.

Algumas versões recentes do parser do `nvim-treesitter` são compiladas exigindo
`glibc 2.39`, que não existe no Ubuntu 22.04 (só a partir do 24.04).

**Decisão atual:** manter o ambiente como está por enquanto; considerar migração
para Ubuntu 24.04 no WSL futuramente caso o erro comece a afetar mais parsers
ou funcionalidades do LazyVim.

**Como verificar sua glibc:**
```bash
ldd --version | head -1
```

---

## Como adicionar um novo keymap

1. Atalho **geral** (não ligado a plugin específico) → `lua/config/keymaps.lua`
2. Atalho **ligado a um plugin** → cria/edita o arquivo do plugin em `lua/plugins/`
3. Sempre inclui `desc = "..."` — aparece no `which-key` (menu de ajuda ao segurar `<leader>`)
4. Depois de editar, salva e recarrega com `:source %` ou reabre o Neovim
