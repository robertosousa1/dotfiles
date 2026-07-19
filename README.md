# macOS Setup

Script interativo para configurar um Mac do zero: aplicativos, ferramentas de
linha de comando, runtimes e extensões de editor, instalados via [Homebrew](https://brew.sh).

## Por que

A maioria dos scripts de setup de Mac instala tudo de uma vez, sem chance de
revisão. Este script usa uma interface interativa (via [gum](https://github.com/charmbracelet/gum))
que permite selecionar exatamente o que instalar em cada categoria, e termina
com um resumo claro do que foi instalado, do que foi pulado e do que precisa de
ação manual.

## Pré-requisitos

- macOS (testado no Sequoia com Apple Silicon)
- Conexão com a internet
- Acesso de administrador

O script instala automaticamente o [Homebrew](https://brew.sh) e o
[`gum`](https://github.com/charmbracelet/gum) (interface interativa) caso
ainda não estejam presentes, pedindo confirmação antes de cada um.

## Uso

```bash
git clone https://github.com/robertosousa1/dotfiles.git
cd dotfiles
chmod +x setup.sh
./setup.sh
```

O script abre um menu com categorias. Em cada uma, você seleciona os itens que
quer instalar (espaço para marcar, enter para confirmar). Ao final, exibe um
resumo:

- ✅ itens instalados com sucesso
- ⏭️ itens pulados
- ❌ itens que falharam
- 📋 itens que exigem instalação manual

## O que é instalado

| Categoria | Exemplos |
|---|---|
| Navegadores | Chrome, Brave |
| Comunicação | WhatsApp, Slack, Discord, Zoom, Teams |
| Produtividade | Word, Excel, PowerPoint, Outlook, OneDrive, Notion, Obsidian |
| IA / Assistentes | Claude, ChatGPT, Gemini |
| Editores / IDEs | VS Code, Android Studio, DataGrip |
| Ferramentas de dev | Docker, Postman, Insomnia, MongoDB Compass, DevToys |
| CLIs de cloud/infra | AWS CLI, Azure CLI, Terraform, Helm, kubectl, Argo CD, Railway |
| Linguagens / runtimes | nvm, yarn, pnpm, OpenJDK, CocoaPods |
| Terminal | Git, GitHub CLI, Oh My Zsh + Spaceship |
| VS Code | ESLint, Prettier, GitLens, Dracula, Snyk, etc. |

A lista completa está no próprio script, organizada em seções comentadas.

## O que exige ação manual

Alguns itens não podem ser automatizados e aparecem no resumo final como
pendências:

- **Xcode** — App Store (10 GB+), melhor baixar direto no Mac novo
- **Microsoft To Do** — exclusivo da App Store
- **TestFlight / Transporter** — exclusivos da App Store
- **Waterllama / Friendly Streaming Browser** — App Store ou sem cask
- **Perplexity** — sem cask disponível; baixar em [perplexity.ai](https://perplexity.ai)
- **GitHub Copilot** — built-in no VS Code 1.99+; basta fazer login com sua
  conta GitHub pelo menu de contas (canto inferior esquerdo do VS Code)
- **Zinit e plugins zsh** — instalação manual conforme preferência

## Dotfiles

O repositório também inclui arquivos de configuração de referência:

| Arquivo | O que é |
|---|---|
| `vscode.settings.json` | Configurações do VS Code (copiar para `~/Library/Application Support/Code/User/settings.json`) |
| `.gitconfig` | Aliases e configurações do Git (copiar para `~/.gitconfig`) |
| `.zshrc` | Configuração do shell zsh (copiar para `~/.zshrc`) |

> Esses arquivos são referências — não são aplicados automaticamente pelo
> script. Revise e adapte antes de usar.

## Personalizando

Para adaptar o script ao seu ambiente, edite os arrays dentro de `setup.sh`.
Os itens seguem o formato `"Nome Exibido|tipo|nome-do-pacote"`:

```bash
"Git|brew|git"                        # instala via: brew install git
"Google Chrome|cask|google-chrome"    # instala via: brew install --cask google-chrome
"Slack|cask|slack"                    # instala via: brew install --cask slack
```

O "Nome Exibido" é o que aparece no menu interativo. O "tipo" é `brew` para
ferramentas de linha de comando ou `cask` para aplicativos com interface gráfica.
O "nome-do-pacote" é o identificador do Homebrew — para encontrar o nome correto,
use `brew search <nome>` ou consulte [formulae.brew.sh](https://formulae.brew.sh).

Adicionar, remover ou comentar linhas é o suficiente para personalizar a lista.

## Observações técnicas

**CocoaPods** é instalado via `brew install cocoapods` em vez do método oficial
(`gem install cocoapods`). O Ruby incluído no macOS Sequoia (2.6) é antigo
demais para as dependências atuais do CocoaPods, que exigem Ruby >= 3.0.
O Homebrew usa seu próprio Ruby internamente, contornando o problema sem
interferir no Ruby do sistema. Ver detalhes em [CONTEXT.md](CONTEXT.md).

**GitHub Copilot** não pode ser instalado via `code --install-extension` porque
a extensão `github.copilot` foi depreciada e a `github.copilot-chat` (atual)
já vem built-in no VS Code 1.99+. Qualquer tentativa de instalação via CLI
resulta em erro de conflito de versão. A solução é fazer login pelo próprio
VS Code.

## Licença

MIT
