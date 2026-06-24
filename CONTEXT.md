# Contexto e decisões — Setup do MacBook

Este documento existe para que o Claude Code (ou qualquer pessoa) entenda o
raciocínio por trás dos scripts sem precisar reconstruir a conversa original.

## Natureza do projeto

Este é um projeto de **setup de configuração de Mac**, não um projeto de
"migração" entre dois Macs. O script `setup.sh` deve funcionar em qualquer
MacBook novo, independentemente de existir ou não um Mac antigo por perto.

O MacBook antigo do usuário foi usado **apenas como insumo** para decidir o que
entra no script (lista de apps reais em uso, Brewfile existente, ferramentas de
trabalho) — não é uma dependência do fluxo. Uma vez que o script reflita o que o
usuário realmente usa, ele pode ser reaplicado em qualquer Mac novo no futuro,
sem precisar de acesso a um Mac antigo.

## Estrutura do repositório (dotfiles)

```
dotfiles/
├── .gitconfig
├── .zshrc
├── CONTEXT.md
├── README.md
├── setup.sh              ← script ATIVO, foco do trabalho agora
└── vscode.settings.json
```

**Escopo atual: trabalhar exclusivamente no `setup.sh`.**
`.gitconfig`, `.zshrc` e `vscode.settings.json` ainda não entraram em revisão —
isso é uma etapa futura, depois que o `setup.sh` estiver fechado.
`setup.sh` é o script antigo (pré-projeto), serve só de contexto histórico, não
deve ser editado nem executado como instalador real.

## Objetivo

Configurar um MacBook (atualmente um M5 Pro) com apps, ferramentas de linha de
comando, extensões e configurações, com o mínimo de fricção e máximo de
automação possível via Homebrew — mas com **confirmação manual item a item** no
script de instalação, para evitar instalar coisas que não são mais usadas.

## Origem dos dados (insumo, não dependência)

1. **Script antigo do usuário** (`setup.sh`, criado em um momento anterior,
   estilo "setup de Mac" linear, sem confirmações) — serviu de base para o
   inventário de ferramentas, mas estava desatualizado (ex: Node 14.16.0 fixo,
   links antigos do Oh My Zsh, apps que o usuário não usa mais como SoapUI,
   Miniconda, JDK 8).
2. **`coletar_migracao.sh`** rodado no Mac antigo do usuário, gerando:
   - `lista_apps.txt` (apps em `/Applications`)
   - `Brewfile` (formulas, casks, extensões vscode, pacotes npm já via
     `brew bundle dump`)
   Esse script foi só uma ferramenta de **levantamento de inventário** — não
   faz parte do setup em si e não é necessário para rodar o `setup.sh`.
3. Cruzamento manual entre os dois para decidir o que entra no `setup.sh`.

## Decisões tomadas

### CocoaPods
- Instalado via **`brew install cocoapods`**, não via `gem install cocoapods`.
- Motivo: o Ruby do sistema no macOS Sequoia é a versão 2.6, que é antiga demais
  para a dependência `ffi` exigida pelo CocoaPods (requer Ruby >= 3.0). O
  `brew install` usa o Ruby interno do Homebrew, evitando esse conflito.
- A doc oficial do CocoaPods e do React Native recomendam `gem install`, mas
  essa orientação está desatualizada para macOS moderno com Apple Silicon.
- Risco aceito: o Homebrew pode demorar a atualizar o CocoaPods para versões
  mais novas, e em projetos com restrição de versão no `Podfile` pode haver
  incompatibilidade — improvável na prática.
- Alternativa descartada: instalar `rbenv` + Ruby 3.x antes do CocoaPods
  seguiria a doc oficial, mas `rbenv global` substitui o Ruby padrão do sistema
  podendo impactar ferramentas nativas do macOS que dependem do Ruby 2.6.

### Estratégia geral
- **Homebrew é preferido sobre Mac App Store** sempre que existir cask
  equivalente — facilita automação (`brew bundle`/scripts) e atualização
  (`brew upgrade`).
- App Store (`mas`) só é usado quando não há alternativa via Homebrew (apps
  exclusivos da loja).
- Apps geridos por TI/MDM da empresa (HIAE) **não são instalados via Homebrew**
  — ficam marcados como manuais, pois o Company Portal/MDM corporativo deve
  reinstalá-los automaticamente ou exigem pacote interno.

### Itens removidos do script (não usados atualmente / substituídos)
Removidos a pedido do usuário por não fazerem mais parte do fluxo de trabalho
atual:
- **pyenv**, **Elixir** — não usados atualmente.
- **create-react-app** — descontinuado/não usado.
- **appcenter-cli** — não usado.
- **Microsoft Edge**, **Telegram**, **Skype** — navegadores/comunicação não usados.
- **Microsoft Defender**, **Microsoft Company Portal** — geridos por TI, fora do
  escopo de instalação manual via Homebrew (de qualquer forma seriam
  reinstalados pelo MDM da empresa).
- **Adobe Acrobat Reader** — não usado mais.
- **Microsoft Remote Desktop** — não usado.
- **Keynote / Pages** — usa equivalentes Microsoft (Word/PowerPoint).
- **ChatGPT Atlas** — app novo sem cask confirmado no Homebrew; se necessário,
  baixar manualmente do site da OpenAI.
- **Cursor** — não usado (usuário prioriza VS Code).
- **Studio 3T** — não usado mais (MongoDB Compass é suficiente).
- **TeamViewer** — não usado.
- **GlobalProtect**, **Falcon (CrowdStrike)**, **Secure Login Client** — ligados
  à infraestrutura de segurança corporativa do HIAE; melhor deixar o
  MDM/Company Portal cuidar disso.
- **BirdID** — certificado digital, sem cask, não incluído no fluxo automatizado.
- **Amphetamine** — não usado.

### Corepack
- Decisão: **não incluir `corepack enable`** no script.
- Raciocínio: o usuário já instala yarn (via Homebrew) e pnpm (via script oficial)
  diretamente, sem depender do campo `"packageManager"` no `package.json`.
  Corepack só traria valor se os projetos especificassem versões individuais de
  gerenciador de pacotes por projeto — o que não é a prática atual do usuário.
  Pode ser revisitado se algum projeto futuro exigir essa abordagem.

### Node.js / nvm
- O script **não fixa uma versão de Node** (o script antigo usava `14.16.0`,
  hoje EOL). Em vez disso, fica como item manual:
  `nvm install --lts && nvm alias default --lts`
  para o usuário escolher a versão ativa conforme necessidade dos projetos.

### Itens mantidos como instalação manual (não automatizados)
- **TestFlight / Transporter** — exclusivos da App Store.
- **Microsoft To Do** — exclusivo da App Store.
- **Xcode** — App Store, mas grande (10GB+), melhor baixar direto no Mac novo.
- **Friendly Streaming Browser** — sem cask disponível.
- **Waterllama** — App Store.
- **JDK 8 (legado)** — só instalar se algum projeto específico ainda exigir.
- **Miniconda** — só instalar se necessário.
- **Zinit / plugins zsh** (zsh-autosuggestions, zsh-completions,
  fast-syntax-highlighting) — instalação manual, conforme preferência de setup
  do terminal.
- **Tema Dracula para Terminal.app** — clone manual do repositório.

## Estrutura do script `setup.sh`

- Funções helper: `confirm()` (pergunta s/N), `run_brew()`, `run_cask()`,
  `add_manual()`, `section()` (para organizar saída no terminal).
- Arrays de controle: `MANUAL_ITEMS`, `SKIPPED_ITEMS`, `FAILED_ITEMS` — usados
  para gerar o resumo final.
- Seções, em ordem: Homebrew → Git → Navegadores → Comunicação → Produtividade/
  Microsoft 365 → IA/Assistentes → Editores/IDEs → Ferramentas de
  desenvolvimento → CLIs de Cloud/Infra → Linguagens/Runtimes → Pacotes globais
  npm → Fontes → Zsh/Terminal → Extensões VS Code → Resumo.

## Dados sensíveis

Se for usado novamente como ferramenta de levantamento de inventário, o
`coletar_migracao.sh` copia `.aws/credentials` e `.ssh/config` para uma pasta
local. Caso esses arquivos precisem ser movidos entre máquinas, **transferir
apenas via AirDrop/USB**, nunca por nuvem pública, e apagar a cópia temporária
depois de usada.

## Próximos passos sugeridos (para retomar no Claude Code)

1. Revisar e testar o `setup.sh` em um Mac novo, conferindo o resumo final
   gerado (itens pulados, falhos e manuais).
3. Resolver manualmente os itens de App Store via `mas` (instalar `mas`, e usar
   `mas install <id>` para cada app — os IDs podem ser obtidos com `mas list`
   em qualquer Mac que já tenha os apps instalados, não necessariamente um
   "Mac antigo" específico).
4. Quando o `setup.sh` estiver fechado, avançar para revisar e versionar
   `.gitconfig`, `.zshrc` e `vscode.settings.json` no mesmo repositório.
5. Validar versões de ferramentas críticas (kubectl, terraform, helm, argocd,
   aws-cli, azure-cli) após a instalação.