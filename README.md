# macOS Setup

Script interativo para configurar um Mac do zero: aplicativos, ferramentas de
linha de comando, runtimes e extensões de editor, instalados via [Homebrew](https://brew.sh).

## Por que

A maioria dos scripts de setup de Mac instala tudo de uma vez, sem chance de
revisão. Este script pergunta item por item antes de instalar, e termina com
um resumo claro do que foi instalado, do que foi pulado e do que precisa de
ação manual (App Store, apps corporativos, ou pacotes sem cask disponível).

## Uso

```bash
chmod +x setup.sh
./setup.sh
```

Para cada item, responda `s` para instalar ou Enter/qualquer outra tecla para
pular. Ao final, o script exibe:

- ✅ itens instalados
- ⏭️ itens pulados
- ❌ itens que falharam
- 📋 itens que exigem instalação manual

## O que é instalado

| Categoria | Exemplos |
|---|---|
| Navegadores | Chrome, Brave |
| Comunicação | WhatsApp, Slack, Discord, Zoom, Teams |
| Produtividade | Word, Excel, PowerPoint, Outlook, OneDrive, Notion, Obsidian |
| IA / Assistentes | Claude, ChatGPT, Perplexity |
| Editores / IDEs | VS Code, Android Studio, DataGrip |
| Ferramentas de dev | Docker, Postman, Insomnia, MongoDB Compass, DevToys |
| CLIs de cloud/infra | AWS CLI, Azure CLI, Terraform, Helm, kubectl, Argo CD |
| Linguagens / runtimes | nvm, yarn, pnpm, OpenJDK, CocoaPods |
| Terminal | Git, GitHub CLI, Oh My Zsh + Spaceship |
| Editor | Extensões do VS Code (ESLint, Prettier, GitLens, Copilot, etc.) |

A lista completa está no próprio script, organizada em seções.

## Requisitos

- macOS
- Conexão com a internet
- Acesso de administrador (necessário para instalar o AWS CLI v2)

## Estrutura

```
.
├── setup.sh   # script de instalação
├── .gitconfig      # configuração padrão do Git (a revisar)
├── .zshrc          # configuração do shell (a revisar)
└── vscode.settings.json  # configurações do VS Code (a revisar)
```

> `.gitconfig`, `.zshrc` e `vscode.settings.json` ainda estão em revisão e
> serão documentados em uma versão futura.

## Observações técnicas

**CocoaPods** é instalado via `brew install cocoapods` em vez do método oficial
(`gem install cocoapods`). O motivo é que o Ruby incluído no macOS Sequoia (2.6)
é antigo demais para as dependências atuais do CocoaPods, que exigem Ruby >= 3.0.
O Homebrew usa seu próprio Ruby internamente, contornando esse problema sem
interferir no Ruby do sistema. Ver detalhes em [CONTEXT.md](CONTEXT.md).

## Personalizando

Para adaptar a lista de apps às suas necessidades, edite as seções dentro de
`setup.sh` — cada item usa uma das funções `run_brew`, `run_cask` ou
`add_manual`, então é direto adicionar, remover ou comentar linhas.

## Licença

MIT (ou a de sua preferência).