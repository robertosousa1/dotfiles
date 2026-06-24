#!/bin/bash
#
# Script de setup do Mac novo
# Exibe todos os itens de uma vez para seleção, depois instala o que foi escolhido.
#
# Uso:
#   chmod +x setup_new.sh
#   ./setup_new.sh

set -e

MANUAL_ITEMS=()
SKIPPED_ITEMS=()
FAILED_ITEMS=()
INSTALLED_ITEMS=()

# ----------------------------------------
# Homebrew (pré-requisito obrigatório)
# ----------------------------------------

if ! command -v brew &>/dev/null; then
  echo "Homebrew não encontrado. Instalando..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✓ Homebrew já instalado."
fi

# ----------------------------------------
# gum (pré-requisito para a UI)
# ----------------------------------------

if ! command -v gum &>/dev/null; then
  echo "Instalando gum (UI interativa)..."
  brew install gum
fi

# ----------------------------------------
# Seleção de itens
# ----------------------------------------

echo ""
gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 50 --margin "1 2" --padding "1 4" \
  "Setup do Mac" "Selecione o que instalar"

echo ""
gum style --foreground 240 "  ↑↓ navegar   espaço selecionar   enter confirmar"
echo ""

ALL_ITEMS=(
  # Git
  "Git"
  "Git LFS"
  "GitHub CLI (gh)"
  "Configurar nome/email/editor do Git"
  # Navegadores
  "Google Chrome"
  "Brave Browser"
  # Comunicação
  "WhatsApp"
  "Slack"
  "Discord"
  "Zoom"
  "Microsoft Teams"
  # Produtividade
  "Microsoft Word"
  "Microsoft Excel"
  "Microsoft PowerPoint"
  "Microsoft Outlook"
  "OneDrive"
  "Notion"
  "Obsidian"
  # IA / Assistentes
  "Claude"
  "ChatGPT"
  "Perplexity"
  # Editores e IDEs
  "Visual Studio Code"
  "Android Studio"
  "DataGrip"
  # Ferramentas de desenvolvimento
  "Docker Desktop"
  "docker-compose"
  "Postman"
  "Insomnia"
  "MongoDB Compass"
  "MySQL Workbench"
  "DevToys"
  "DevDocs"
  "Reactotron"
  "draw.io"
  "ResponsivelyApp"
  "OBS"
  "The Unarchiver"
  "CleanMyMac"
  "MonitorControl"
  "AWS VPN Client"
  # CLIs de Cloud / Infra
  "AWS CLI v2"
  "AWS EB CLI"
  "Azure CLI"
  "Terraform"
  "Helm"
  "kubectl"
  "Argo CD CLI"
  "Watchman"
  # Linguagens / Runtimes
  "nvm"
  "yarn"
  "pnpm"
  "OpenJDK 17"
  "CocoaPods"
  "virtualenv (pip)"
  # Extras
  "Pacotes globais npm"
  "Fira Code (fonte)"
  "Oh My Zsh + tema Spaceship"
  "Extensões do VS Code"
)

SELECTED=$(gum choose --no-limit --height=40 "${ALL_ITEMS[@]}")

if [ -z "$SELECTED" ]; then
  echo ""
  gum style --foreground 214 "Nenhum item selecionado. Saindo."
  exit 0
fi

echo ""
gum style --foreground 212 "Iniciando instalação..."
echo ""

# ----------------------------------------
# Instalar cada item selecionado
# ----------------------------------------

already_installed_brew() {
  brew list --formula 2>/dev/null | grep -qx "$1" || \
  brew list --cask   2>/dev/null | grep -qx "$1"
}

install() {
  local name="$1"
  local cmd="$2"
  local check="$3"   # comando opcional para checar existência (ex: "command -v git")

  if [ -n "$check" ] && eval "$check" &>/dev/null; then
    gum style --foreground 240 "  ↩ $name já instalado, pulando."
    INSTALLED_ITEMS+=("$name (já existia)")
    return
  fi

  gum spin --spinner dot --title "Instalando $name..." -- bash -c "$cmd" \
    && INSTALLED_ITEMS+=("$name") \
    || FAILED_ITEMS+=("$name")
}

install_brew() {
  local name="$1"
  local formula="$2"
  local check="${3:-command -v $formula}"
  if already_installed_brew "$formula"; then
    gum style --foreground 240 "  ↩ $name já instalado, pulando."
    INSTALLED_ITEMS+=("$name (já existia)")
  else
    gum spin --spinner dot --title "Instalando $name..." -- brew install "$formula" \
      && INSTALLED_ITEMS+=("$name") \
      || FAILED_ITEMS+=("$name")
  fi
}

install_cask() {
  local name="$1"
  local cask="$2"
  if already_installed_brew "$cask"; then
    gum style --foreground 240 "  ↩ $name já instalado, pulando."
    INSTALLED_ITEMS+=("$name (já existia)")
  else
    gum spin --spinner dot --title "Instalando $name..." -- brew install --cask "$cask" \
      && INSTALLED_ITEMS+=("$name") \
      || FAILED_ITEMS+=("$name")
  fi
}

while IFS= read -r item; do
  case "$item" in

    "Git")
      install_brew "Git" "git" ;;

    "Git LFS")
      install_brew "Git LFS" "git-lfs" ;;

    "GitHub CLI (gh)")
      install_brew "GitHub CLI" "gh" ;;

    "Configurar nome/email/editor do Git")
      echo ""
      git_name=$(gum input --placeholder "Nome (git config user.name)")
      git config --global user.name "$git_name"
      git_email=$(gum input --placeholder "Email (git config user.email)")
      git config --global user.email "$git_email"
      git_editor=$(gum input --placeholder "Editor padrão (ex: vim, code --wait)")
      git config --global core.editor "$git_editor"
      INSTALLED_ITEMS+=("Configurar Git")
      echo ""
      ;;

    "Google Chrome")
      install_cask "Google Chrome" "google-chrome" ;;

    "Brave Browser")
      install_cask "Brave Browser" "brave-browser" ;;

    "WhatsApp")
      install_cask "WhatsApp" "whatsapp" ;;

    "Slack")
      install_cask "Slack" "slack" ;;

    "Discord")
      install_cask "Discord" "discord" ;;

    "Zoom")
      install_cask "Zoom" "zoom" ;;

    "Microsoft Teams")
      install_cask "Microsoft Teams" "microsoft-teams" ;;

    "Microsoft Word")
      install_cask "Microsoft Word" "microsoft-word" ;;

    "Microsoft Excel")
      install_cask "Microsoft Excel" "microsoft-excel" ;;

    "Microsoft PowerPoint")
      install_cask "Microsoft PowerPoint" "microsoft-powerpoint" ;;

    "Microsoft Outlook")
      install_cask "Microsoft Outlook" "microsoft-outlook" ;;

    "OneDrive")
      install_cask "OneDrive" "onedrive" ;;

    "Notion")
      install_cask "Notion" "notion" ;;

    "Obsidian")
      install_cask "Obsidian" "obsidian" ;;

    "Claude")
      install_cask "Claude" "claude" ;;

    "ChatGPT")
      install_cask "ChatGPT" "chatgpt" ;;

    "Perplexity")
      install_cask "Perplexity" "perplexity" ;;

    "Visual Studio Code")
      install_cask "Visual Studio Code" "visual-studio-code" ;;

    "Android Studio")
      install_cask "Android Studio" "android-studio" ;;

    "DataGrip")
      install_cask "DataGrip" "datagrip" ;;

    "Docker Desktop")
      install_cask "Docker Desktop" "docker" ;;

    "docker-compose")
      install_brew "docker-compose" "docker-compose" ;;

    "Postman")
      install_cask "Postman" "postman" ;;

    "Insomnia")
      install_cask "Insomnia" "insomnia" ;;

    "MongoDB Compass")
      install_cask "MongoDB Compass" "mongodb-compass" ;;

    "MySQL Workbench")
      install_cask "MySQL Workbench" "mysqlworkbench" ;;

    "DevToys")
      install_cask "DevToys" "devtoys" ;;

    "DevDocs")
      install_cask "DevDocs" "devdocs" ;;

    "Reactotron")
      install_cask "Reactotron" "reactotron" ;;

    "draw.io")
      install_cask "draw.io" "drawio" ;;

    "ResponsivelyApp")
      install_cask "ResponsivelyApp" "responsively" ;;

    "OBS")
      install_cask "OBS" "obs" ;;

    "The Unarchiver")
      install_cask "The Unarchiver" "the-unarchiver" ;;

    "CleanMyMac")
      install_cask "CleanMyMac" "cleanmymac" ;;

    "MonitorControl")
      install_cask "MonitorControl" "monitorcontrol" ;;

    "AWS VPN Client")
      install_cask "AWS VPN Client" "aws-vpn-client" ;;

    "AWS CLI v2")
      install "AWS CLI v2" \
        "curl -s 'https://awscli.amazonaws.com/AWSCLIV2.pkg' -o /tmp/AWSCLIV2.pkg && sudo installer -pkg /tmp/AWSCLIV2.pkg -target /" \
        "command -v aws" ;;

    "AWS EB CLI")
      install_brew "AWS EB CLI" "awsebcli" ;;

    "Azure CLI")
      install_brew "Azure CLI" "azure-cli" ;;

    "Terraform")
      install_brew "Terraform" "terraform" ;;

    "Helm")
      install_brew "Helm" "helm" ;;

    "kubectl")
      install_brew "kubectl" "kubectl" ;;

    "Argo CD CLI")
      install_brew "Argo CD CLI" "argocd" ;;

    "Watchman")
      install_brew "Watchman" "watchman" ;;

    "nvm")
      install_brew "nvm" "nvm" ;;

    "yarn")
      install_brew "yarn" "yarn" ;;

    "pnpm")
      install "pnpm" "curl -fsSL https://get.pnpm.io/install.sh | sh -" "command -v pnpm" ;;

    "OpenJDK 17")
      install_brew "OpenJDK 17" "openjdk@17" ;;

    "CocoaPods")
      install_brew "CocoaPods" "cocoapods" ;;

    "virtualenv (pip)")
      install "virtualenv" "pip3 install virtualenv" "command -v virtualenv" ;;

    "Pacotes globais npm")
      install "Pacotes globais npm" \
        "npm i -g @anthropic-ai/claude-code @fission-ai/openspec autocannon eas-cli expo-cli json-server npm-check ntl serverless" \
        "command -v serverless" ;;

    "Fira Code (fonte)")
      install "Fira Code" \
        "brew tap homebrew/cask-fonts && brew install --cask font-fira-code" \
        "already_installed_brew font-fira-code" ;;

    "Oh My Zsh + tema Spaceship")
      install "Oh My Zsh + Spaceship" \
        "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" '' --unattended && \
         git clone https://github.com/denysdovhan/spaceship-prompt.git \"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt\" --depth=1 && \
         ln -sf \"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme\" \"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme\""
      ;;

    "Extensões do VS Code")
      if command -v code &>/dev/null; then
        EXTENSIONS=(
          anthropic.claude-code
          bierner.markdown-mermaid
          christian-kohler.path-intellisense
          dbaeumer.vscode-eslint
          dracula-theme.theme-dracula
          eamodio.gitlens
          editorconfig.editorconfig
          esbenp.prettier-vscode
          foxundermoon.shell-format
          hashicorp.terraform
          jpoissonnier.vscode-styled-components
          mikestead.dotenv
          ms-azuretools.vscode-docker
          naumovs.color-highlight
          openai.chatgpt
          pkief.material-icon-theme
          prisma.prisma
          ritwickdey.liveserver
          snyk-security.vscode-vuln-cost
          wix.vscode-import-cost
          yzhang.markdown-all-in-one
        )
        INSTALLED_EXTS=$(code --list-extensions 2>/dev/null)
        for ext in "${EXTENSIONS[@]}"; do
          if echo "$INSTALLED_EXTS" | grep -qix "$ext"; then
            gum style --foreground 240 "  ↩ $ext já instalado, pulando."
          else
            gum spin --spinner dot --title "VS Code: $ext..." -- code --install-extension "$ext" \
              || FAILED_ITEMS+=("VS Code ext: $ext")
          fi
        done
        INSTALLED_ITEMS+=("Extensões do VS Code")
      else
        FAILED_ITEMS+=("Extensões do VS Code — VS Code não encontrado, instale primeiro")
      fi
      ;;

  esac
done <<< "$SELECTED"

# Itens sempre manuais
MANUAL_ITEMS+=(
  "Microsoft To Do — App Store"
  "TestFlight / Transporter — App Store"
  "Xcode — App Store (10GB+, baixar direto)"
  "Friendly Streaming Browser — sem cask, baixar direto"
  "Waterllama — App Store"
  "Node via nvm — rode: nvm install --lts && nvm alias default --lts"
  "JDK 8 (legado) — se precisar: brew install --cask adoptopenjdk/openjdk/adoptopenjdk8"
  "Miniconda — se precisar: brew install --cask miniconda"
  "Zinit / plugins zsh — instalar manualmente conforme preferência"
  "Tema Dracula para Terminal.app — git clone https://github.com/dracula/terminal-app.git"
)

# ----------------------------------------
# Resumo final
# ----------------------------------------

echo ""
gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 50 --margin "1 2" --padding "1 2" \
  "Resumo da instalação"

if [ ${#INSTALLED_ITEMS[@]} -gt 0 ]; then
  echo ""
  gum style --foreground 46 "✅ Instalados:"
  for item in "${INSTALLED_ITEMS[@]}"; do
    echo "   • $item"
  done
fi

if [ ${#FAILED_ITEMS[@]} -gt 0 ]; then
  echo ""
  gum style --foreground 196 "❌ Falharam (verificar manualmente):"
  for item in "${FAILED_ITEMS[@]}"; do
    echo "   • $item"
  done
fi

echo ""
gum style --foreground 214 "📋 Instalação manual necessária:"
for item in "${MANUAL_ITEMS[@]}"; do
  echo "   • $item"
done

echo ""
gum style --foreground 240 "Dica: para apps da App Store, use 'brew install mas' e 'mas install <id>'."
echo ""
gum style --foreground 212 "Concluído."
