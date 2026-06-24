# Contexto e decisões técnicas

Este documento registra o raciocínio por trás das escolhas feitas no projeto —
útil para quem quiser contribuir, adaptar ou entender por que certas coisas
funcionam do jeito que funcionam.

## O que é este projeto

Um script interativo de setup de Mac. Funciona em qualquer MacBook novo, sem
dependências de uma máquina anterior. A ideia é ter um inventário pessoal de
ferramentas que pode ser reaplicado a qualquer momento.

## Estrutura do repositório

```
dotfiles/
├── setup.sh              # script de instalação interativo
├── vscode.settings.json  # configurações de referência do VS Code
├── .gitconfig            # aliases e configurações do Git
├── .zshrc                # configuração do shell zsh
├── README.md
└── CONTEXT.md
```

## Decisões técnicas

### Dependência do `gum`

O script usa [gum](https://github.com/charmbracelet/gum) para a interface
interativa (menus, checkboxes, progress bar). O Homebrew é instalado
automaticamente se ausente, mas o `gum` precisa estar disponível antes de
rodar o script — ou o script tenta instalá-lo via `brew install gum` na
inicialização.

### Homebrew como padrão

Homebrew é preferido sobre Mac App Store sempre que existir cask equivalente
— facilita automação e atualização (`brew upgrade`). A App Store só é usada
quando não há alternativa (apps exclusivos da loja).

### CocoaPods via Homebrew

Instalado via `brew install cocoapods`, não via `gem install cocoapods`.

- **Motivo:** o Ruby do sistema no macOS Sequoia é a versão 2.6, antiga demais
  para a dependência `ffi` do CocoaPods (exige Ruby >= 3.0). O Homebrew usa
  seu próprio Ruby internamente, evitando o conflito.
- **Alternativa descartada:** instalar `rbenv` + Ruby 3.x seria mais correto
  segundo a doc oficial, mas `rbenv global` substitui o Ruby padrão do sistema,
  podendo impactar ferramentas nativas do macOS.
- **Risco aceito:** o Homebrew pode demorar a atualizar o CocoaPods; projetos
  com restrição de versão no `Podfile` podem ter incompatibilidade (improvável
  na prática).

### Node.js / nvm

O script instala o `nvm` mas não fixa uma versão de Node. Após instalar o nvm,
o usuário escolhe a versão conforme os projetos:

```bash
nvm install --lts
nvm alias default $(node --version)
```

`nvm alias default --lts` não é válido — `--lts` não é aceito pelo `nvm alias`.

### GitHub Copilot

A extensão `github.copilot` foi **depreciada**. A extensão atual é
`github.copilot-chat`, mas ela já vem **built-in no VS Code 1.99+** — não pode
ser instalada nem atualizada via `code --install-extension` (o VS Code rejeita
qualquer versão diferente da built-in).

A solução correta é fazer login com a conta GitHub pelo menu de contas do
próprio VS Code (canto inferior esquerdo). Nenhuma instalação de extensão é
necessária.

### Corepack

Não incluído no script. O yarn é instalado via Homebrew e o pnpm via script
oficial — sem depender do campo `"packageManager"` no `package.json`. Corepack
só traz valor em projetos que especificam versão de gerenciador por projeto,
o que não é o caso aqui.

### vscode.settings.json

As configurações foram revisadas para remover settings depreciados:

- `javascript.suggest.autoImports` → `js/ts.suggest.autoImports`
- `javascript.updateImportsOnFileMove.enabled` → `js/ts.updateImportsOnFileMove.enabled`
- `typescript.tsserver.log` → `js/ts.tsserver.log`
- `editor.codeActionsOnSave` usa `"always"` em vez de `true` (depreciado)

O arquivo é uma referência — não é aplicado automaticamente pelo script.

### .gitconfig

O arquivo não inclui a seção `[user]` (name/email) — cada pessoa deve
configurar localmente com `git config --global user.name` e
`git config --global user.email`. Isso permite que o arquivo seja versionado
e compartilhado sem expor dados pessoais.

## Itens mantidos como manuais (não automatizados)

| Item | Motivo |
|---|---|
| Xcode | App Store, 10 GB+ |
| Microsoft To Do | Exclusivo App Store |
| TestFlight / Transporter | Exclusivos App Store |
| Waterllama / Friendly Streaming Browser | App Store ou sem cask |
| Perplexity | Sem cask disponível |
| GitHub Copilot | Built-in no VS Code 1.99+, requer login |
| Zinit + plugins zsh | Instalação manual por preferência |
| Tema Dracula (Terminal.app) | Clone manual do repositório |
