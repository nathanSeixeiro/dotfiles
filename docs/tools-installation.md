# Tools Installation

Ferramentas instaladas manualmente como binário em `/usr/local/bin` (sem apt/snap),
sem configuração pessoal versionada no repo — apenas instalação.

Todos os comandos abaixo sempre puxam a **versão mais recente disponível** pra manter o ambiente sempre atualizado.

> Testado em WSL2 (Ubuntu) / linux-amd64. Ajustar arch se necessário (`uname -m`).

---

## Go

```bash
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
curl -LO https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
rm ${GO_VERSION}.linux-amd64.tar.gz
```

PATH necessário:
```bash
export PATH="$PATH:/usr/local/go/bin"
```

Verificar:
```bash
go version
```

---

## kubectl

```bash
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

Verificar:
```bash
kubectl version --client
```

---

## kind

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```


Verificar:
```bash
kind version
```

---

## k9s

```bash
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d '"' -f4)
curl -LO https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz k9s
sudo mv k9s /usr/local/bin/k9s
rm k9s_Linux_amd64.tar.gz
```

Verificar:
```bash
k9s version
``` 


---

## Resumo para o futuro `install.sh`

| Ferramenta | Fonte "latest" | Local final |
|---|---|---|
| go | `go.dev/VERSION?m=text` | `/usr/local/go` |
| kubectl | `dl.k8s.io/release/stable.txt` | `/usr/local/bin/kubectl` |
| kind | `kind.sigs.k8s.io/dl/latest` | `/usr/local/bin/kind` |
| k9s | GitHub API `releases/latest` | `/usr/local/bin/k9s` |

```
