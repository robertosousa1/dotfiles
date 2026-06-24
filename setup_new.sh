#!/bin/bash
#
# Mac Setup Script
# Interactive menu to install apps, npm packages and VS Code extensions.
#
# Usage:
#   chmod +x setup_new.sh
#   ./setup_new.sh

FAILED_ITEMS=()
INSTALLED_ITEMS=()
MANUAL_ITEMS=(
  "Microsoft To Do — App Store"
  "TestFlight / Transporter — App Store"
  "Xcode — App Store (10GB+, download directly)"
  "Friendly Streaming Browser — no cask available"
  "Waterllama — App Store"
  "Node via nvm — run: nvm install --lts && nvm alias default --lts"
  "JDK 8 (legacy) — only if needed: brew install --cask adoptopenjdk/openjdk/adoptopenjdk8"
  "Miniconda — only if needed: brew install --cask miniconda"
  "Zinit / zsh plugins — install manually as preferred"
  "Dracula theme for Terminal.app — git clone https://github.com/dracula/terminal-app.git"
)

# ─────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────

is_cask_installed()    { brew list --cask    2>/dev/null | grep -qx "$1"; }
is_formula_installed() { brew list --formula 2>/dev/null | grep -qx "$1"; }
is_cmd()               { command -v "$1" &>/dev/null; }
is_vscode_ext()        { code --list-extensions 2>/dev/null | grep -qix "$1"; }
is_npm_pkg()           { npm list -g --depth=0 2>/dev/null | grep -q "$1"; }

do_install_cask() {
  local name="$1" cask="$2"
  gum spin --spinner dot --title "Installing $name..." -- brew install --cask "$cask" \
    && INSTALLED_ITEMS+=("$name") || FAILED_ITEMS+=("$name")
}

do_install_brew() {
  local name="$1" formula="$2"
  gum spin --spinner dot --title "Installing $name..." -- brew install "$formula" \
    && INSTALLED_ITEMS+=("$name") || FAILED_ITEMS+=("$name")
}

do_install_cmd() {
  local name="$1" cmd="$2"
  gum spin --spinner dot --title "Installing $name..." -- bash -c "$cmd" \
    && INSTALLED_ITEMS+=("$name") || FAILED_ITEMS+=("$name")
}

header() {
  clear
  gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "1 4" \
    "Mac Setup" "$1"
}

# ─────────────────────────────────────────
# Prerequisites
# ─────────────────────────────────────────

clear
gum style \
  --foreground 212 --border-foreground 212 --border double \
  --align center --width 50 --margin "1 2" --padding "1 4" \
  "Mac Setup" "Checking prerequisites..." 2>/dev/null \
|| echo "=== Mac Setup — Checking prerequisites ==="

# Homebrew — load env if installed but not in PATH yet
if [ -x "/opt/homebrew/bin/brew" ] && ! is_cmd brew; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if is_cmd brew; then
  echo "✅ Homebrew — already installed"
else
  echo "⚠️  Homebrew is not installed."
  if gum confirm "Install Homebrew now?" 2>/dev/null || { echo -n "Install Homebrew? [y/N] "; read -r r && [[ "$r" =~ ^[yY] ]]; }; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    grep -qxF 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile 2>/dev/null || \
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "✅ Homebrew installed."
  else
    echo "Homebrew is required. Exiting."
    exit 1
  fi
fi

# gum
if is_cmd gum; then
  echo "✅ gum — already installed"
else
  echo "⚠️  gum (interactive UI) is not installed."
  echo -n "Install gum via Homebrew? [y/N] "
  read -r r
  if [[ "$r" =~ ^[yY] ]]; then
    brew install gum
    echo "✅ gum installed."
  else
    echo "gum is required for the interactive menu. Exiting."
    exit 1
  fi
fi

sleep 1

# ─────────────────────────────────────────
# Applications
# ─────────────────────────────────────────

# Format: "Display Name|type(cask/brew/special)|identifier"
APPS_ITEMS=(
  # Git
  "Git|brew|git"
  "Git LFS|brew|git-lfs"
  "GitHub CLI|brew|gh"
  # Browsers
  "Google Chrome|cask|google-chrome"
  "Brave Browser|cask|brave-browser"
  # Communication
  "WhatsApp|cask|whatsapp"
  "Slack|cask|slack"
  "Discord|cask|discord"
  "Zoom|cask|zoom"
  "Microsoft Teams|cask|microsoft-teams"
  # Productivity
  "Microsoft Word|cask|microsoft-word"
  "Microsoft Excel|cask|microsoft-excel"
  "Microsoft PowerPoint|cask|microsoft-powerpoint"
  "Microsoft Outlook|cask|microsoft-outlook"
  "OneDrive|cask|onedrive"
  "Notion|cask|notion"
  "Obsidian|cask|obsidian"
  # Editors & IDEs
  "Visual Studio Code|cask|visual-studio-code"
  "Android Studio|cask|android-studio"
  "DataGrip|cask|datagrip"
  # Dev Tools
  "Docker Desktop|cask|docker"
  "Postman|cask|postman"
  "Insomnia|cask|insomnia"
  "MongoDB Compass|cask|mongodb-compass"
  "MySQL Workbench|cask|mysqlworkbench"
  "DevToys|cask|devtoys"
  "DevDocs|cask|devdocs"
  "draw.io|cask|drawio"
  "ResponsivelyApp|cask|responsively"
  "OBS|cask|obs"
  "The Unarchiver|cask|the-unarchiver"
  "CleanMyMac|cask|cleanmymac"
  "MonitorControl|cask|monitorcontrol"
  # Dev Tools misc
  # Font
  "Fira Code (font)|special|font-fira-code"
  # Terminal
  "Oh My Zsh + Spaceship theme|special|omz"
)

app_is_installed() {
  local type="$2" id="$3"
  case "$type" in
    cask)    is_cask_installed "$id" ;;
    brew)    is_formula_installed "$id" || is_cmd "$id" ;;
    special)
      case "$id" in
        aws)          is_cmd aws ;;
        nvm)          [ -s "$HOME/.nvm/nvm.sh" ] ;;
        virtualenv)   is_cmd virtualenv ;;
        font-fira-code) is_cask_installed "font-fira-code" ;;
        cocoapods)    is_cmd pod ;;
        omz)          [ -d "$HOME/.oh-my-zsh" ] ;;
      esac
      ;;
  esac
}

install_app() {
  local name="$1" type="$2" id="$3"
  case "$type" in
    cask) do_install_cask "$name" "$id" ;;
    brew) do_install_brew "$name" "$id" ;;
    special)
      case "$id" in
        aws)
          do_install_cmd "$name" "curl -s 'https://awscli.amazonaws.com/AWSCLIV2.pkg' -o /tmp/AWSCLIV2.pkg && sudo installer -pkg /tmp/AWSCLIV2.pkg -target /" ;;
        nvm)
          do_install_cmd "$name" \
            "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash && \
             grep -qxF '[ -s \"\$NVM_DIR/nvm.sh\" ]' ~/.zshrc 2>/dev/null || \
             printf '\nexport NVM_DIR=\"\$HOME/.nvm\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"\n[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"\n' >> ~/.zshrc" ;;
        virtualenv)
          do_install_cmd "$name" "pip3 install virtualenv" ;;
        font-fira-code)
          do_install_cask "$name" "font-fira-code" ;;
        cocoapods)
          do_install_cmd "$name" "sudo gem install cocoapods" ;;
        omz)
          do_install_cmd "$name" \
            "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" '' --unattended && \
             bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)\" && \
             sed -i '' 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"spaceship\"/' ~/.zshrc && \
             cat >> ~/.zshrc << 'EOF'

# zinit plugins
zinit light spaceship-prompt/spaceship-prompt
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
EOF" ;;
      esac
      ;;
  esac
}

# Generic category screen — set _CATEGORY_ITEMS before calling
_CATEGORY_ITEMS=()

show_category() {
  local title="$1"
  header "$title"

  local installed_labels=()
  local available_labels=()
  local available_entries=()

  for entry in "${_CATEGORY_ITEMS[@]}"; do
    IFS='|' read -r name type id <<< "$entry"
    if app_is_installed "$name" "$type" "$id"; then
      installed_labels+=("$name")
    else
      available_labels+=("$name")
      available_entries+=("$entry")
    fi
  done

  if [ ${#installed_labels[@]} -gt 0 ]; then
    gum style --foreground 46 "Already installed:"
    for label in "${installed_labels[@]}"; do
      echo "  ✅ $label"
    done
    echo ""
  fi

  if [ ${#available_labels[@]} -eq 0 ]; then
    gum style --foreground 46 "All items are already installed!"
    sleep 2
    return
  fi

  gum style --foreground 240 "Select to install (space to toggle, enter to confirm, ctrl+c to go back):"
  echo ""

  local selected
  selected=$(gum choose --no-limit --height=20 "${available_labels[@]}") || return

  [ -z "$selected" ] && return

  echo ""
  while IFS= read -r sel; do
    for entry in "${available_entries[@]}"; do
      IFS='|' read -r name type id <<< "$entry"
      if [ "$name" = "$sel" ]; then
        install_app "$name" "$type" "$id"
        break
      fi
    done
  done <<< "$selected"

  echo ""
  gum style --foreground 212 "Done. Press any key to return to the menu."
  read -r -n1
}

show_apps() {
  _CATEGORY_ITEMS=("${APPS_ITEMS[@]}")
  show_category "Applications"
}

# ─────────────────────────────────────────
# Node.js
# ─────────────────────────────────────────

NODE_ITEMS=(
  "nvm|special|nvm"
  "Watchman|brew|watchman"
  "CocoaPods|special|cocoapods"
  "Reactotron|cask|reactotron"
)

# ─────────────────────────────────────────
# Cloud
# ─────────────────────────────────────────

CLOUD_ITEMS=(
  "AWS CLI v2|special|aws"
  "AWS VPN Client|cask|aws-vpn-client"
  "Terraform|brew|terraform"
  "Helm|brew|helm"
  "kubectl|brew|kubectl"
  "Argo CD CLI|brew|argocd"
)

show_cloud() {
  _CATEGORY_ITEMS=("${CLOUD_ITEMS[@]}")
  show_category "Cloud"
}

AI_ITEMS=(
  "Claude|cask|claude"
  "ChatGPT|cask|chatgpt"
  "Perplexity|cask|perplexity"
)

show_ai() {
  _CATEGORY_ITEMS=("${AI_ITEMS[@]}")
  show_category "AI Assistants"
}

show_node() {
  _CATEGORY_ITEMS=("${NODE_ITEMS[@]}")
  show_category "Node.js Ecosystem"
}

# ─────────────────────────────────────────
# Python
# ─────────────────────────────────────────

PYTHON_ITEMS=(
  "virtualenv|special|virtualenv"
)

show_python() {
  _CATEGORY_ITEMS=("${PYTHON_ITEMS[@]}")
  show_category "Python Ecosystem"
}

# ─────────────────────────────────────────
# Global NPM Packages
# ─────────────────────────────────────────

NPM_ITEMS=(
  "yarn"
  "pnpm"
  "@anthropic-ai/claude-code"
  "@fission-ai/openspec"
  "autocannon"
  "eas-cli"
  "expo-cli"
  "json-server"
  "npm-check"
  "ntl"
  "serverless"
)

show_npm() {
  header "Global NPM Packages"

  if ! is_cmd npm; then
    gum style --foreground 196 "npm is not installed. Install Node via nvm first."
    sleep 3
    return
  fi

  local installed_labels=()
  local available_labels=()

  for pkg in "${NPM_ITEMS[@]}"; do
    if is_npm_pkg "$pkg"; then
      installed_labels+=("$pkg")
    else
      available_labels+=("$pkg")
    fi
  done

  if [ ${#installed_labels[@]} -gt 0 ]; then
    gum style --foreground 46 "Already installed:"
    for label in "${installed_labels[@]}"; do
      echo "  ✅ $label"
    done
    echo ""
  fi

  if [ ${#available_labels[@]} -eq 0 ]; then
    gum style --foreground 46 "All npm packages are already installed!"
    sleep 2
    return
  fi

  gum style --foreground 240 "Select to install (space to toggle, enter to confirm, ctrl+c to go back):"
  echo ""

  local selected
  selected=$(gum choose --no-limit --height=20 "${available_labels[@]}") || return

  [ -z "$selected" ] && return

  local to_install=()
  while IFS= read -r pkg; do
    to_install+=("$pkg")
  done <<< "$selected"

  echo ""
  gum spin --spinner dot --title "Installing npm packages..." -- \
    npm i -g "${to_install[@]}" \
    && INSTALLED_ITEMS+=("npm: ${to_install[*]}") \
    || FAILED_ITEMS+=("npm packages")

  echo ""
  gum style --foreground 212 "Done. Press any key to return to the menu."
  read -r -n1
}

# ─────────────────────────────────────────
# VS Code Extensions
# ─────────────────────────────────────────

VSCODE_ITEMS=(
  "anthropic.claude-code"
  "bierner.markdown-mermaid"
  "christian-kohler.path-intellisense"
  "dbaeumer.vscode-eslint"
  "dracula-theme.theme-dracula"
  "eamodio.gitlens"
  "editorconfig.editorconfig"
  "esbenp.prettier-vscode"
  "foxundermoon.shell-format"
  "hashicorp.terraform"
  "jpoissonnier.vscode-styled-components"
  "mikestead.dotenv"
  "ms-azuretools.vscode-docker"
  "naumovs.color-highlight"
  "openai.chatgpt"
  "pkief.material-icon-theme"
  "prisma.prisma"
  "ritwickdey.liveserver"
  "snyk-security.vscode-vuln-cost"
  "wix.vscode-import-cost"
  "yzhang.markdown-all-in-one"
)

show_vscode() {
  header "VS Code Extensions"

  if ! is_cmd code; then
    gum style --foreground 196 "VS Code is not installed. Install it first via Applications."
    sleep 3
    return
  fi

  local installed_labels=()
  local available_labels=()

  for ext in "${VSCODE_ITEMS[@]}"; do
    if is_vscode_ext "$ext"; then
      installed_labels+=("$ext")
    else
      available_labels+=("$ext")
    fi
  done

  if [ ${#installed_labels[@]} -gt 0 ]; then
    gum style --foreground 46 "Already installed:"
    for label in "${installed_labels[@]}"; do
      echo "  ✅ $label"
    done
    echo ""
  fi

  if [ ${#available_labels[@]} -eq 0 ]; then
    gum style --foreground 46 "All extensions are already installed!"
    sleep 2
    return
  fi

  gum style --foreground 240 "Select to install (space to toggle, enter to confirm, ctrl+c to go back):"
  echo ""

  local selected
  selected=$(gum choose --no-limit --height=20 "${available_labels[@]}") || return

  [ -z "$selected" ] && return

  echo ""
  while IFS= read -r ext; do
    gum spin --spinner dot --title "VS Code: $ext..." -- code --install-extension "$ext" \
      && INSTALLED_ITEMS+=("vscode: $ext") \
      || FAILED_ITEMS+=("vscode: $ext")
  done <<< "$selected"

  echo ""
  gum style --foreground 212 "Done. Press any key to return to the menu."
  read -r -n1
}

# ─────────────────────────────────────────
# Summary
# ─────────────────────────────────────────

show_summary() {
  header "Summary"

  if [ ${#INSTALLED_ITEMS[@]} -gt 0 ]; then
    echo ""
    gum style --foreground 46 "✅ Installed:"
    for item in "${INSTALLED_ITEMS[@]}"; do
      echo "   • $item"
    done
  fi

  if [ ${#FAILED_ITEMS[@]} -gt 0 ]; then
    echo ""
    gum style --foreground 196 "❌ Failed (check manually):"
    for item in "${FAILED_ITEMS[@]}"; do
      echo "   • $item"
    done
  fi

  echo ""
  gum style --foreground 214 "📋 Requires manual installation:"
  for item in "${MANUAL_ITEMS[@]}"; do
    echo "   • $item"
  done

  echo ""
  gum style --foreground 240 "Tip: for App Store apps, use 'brew install mas' and 'mas install <id>'."
  echo ""
}

# ─────────────────────────────────────────
# Main menu loop
# ─────────────────────────────────────────

while true; do
  header "Main Menu"

  CHOICE=$(gum choose \
    "Applications" \
    "AI Assistants" \
    "Cloud" \
    "Node.js Ecosystem" \
    "Python Ecosystem" \
    "Global NPM Packages" \
    "VS Code Extensions" \
    "─────────────" \
    "Summary & Manual Items" \
    "Exit")

  case "$CHOICE" in
    "Applications")          show_apps ;;
    "AI Assistants")         show_ai ;;
    "Cloud")                 show_cloud ;;
    "Node.js Ecosystem")     show_node ;;
    "Python Ecosystem")      show_python ;;
    "Global NPM Packages")   show_npm ;;
    "VS Code Extensions")    show_vscode ;;
    "Summary & Manual Items") show_summary; read -r -n1 ;;
    "Exit"|"─────────────")
      show_summary
      gum style --foreground 212 "Goodbye!"
      echo ""
      exit 0
      ;;
  esac
done
