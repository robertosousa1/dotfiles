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
  "Xcode — App Store (10GB+)"
  "Friendly Streaming Browser — App Store"
  "Waterllama — App Store"
  "Perplexity — no cask available, download from https://perplexity.ai"
  "GitHub Copilot (VS Code) — built-in since VS Code 1.99+; sign in via Accounts menu (bottom-left) with your GitHub account"
  "Zinit / zsh plugins — install manually as preferred"
)

# ─────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────

is_app_installed()     { find /Applications -maxdepth 2 -name "*.app" 2>/dev/null | grep -qi "$1"; }
is_cask_installed() {
  local cask="$1"
  # Map cask name to app name for verification
  case "$cask" in
    google-chrome)      is_app_installed "Google Chrome" ;;
    brave-browser)      is_app_installed "Brave Browser" ;;
    whatsapp)           is_app_installed "WhatsApp" ;;
    slack)              is_app_installed "Slack" ;;
    discord)            is_app_installed "Discord" ;;
    zoom)               is_app_installed "zoom" ;;
    microsoft-teams)    is_app_installed "Microsoft Teams" ;;
    microsoft-word)     is_app_installed "Microsoft Word" ;;
    microsoft-excel)    is_app_installed "Microsoft Excel" ;;
    microsoft-powerpoint) is_app_installed "Microsoft PowerPoint" ;;
    microsoft-outlook)  is_app_installed "Microsoft Outlook" ;;
    onedrive)           is_app_installed "OneDrive" ;;
    notion)             is_app_installed "Notion" ;;
    obsidian)           is_app_installed "Obsidian" ;;
    spotify)            is_app_installed "Spotify" ;;
    claude)             is_app_installed "Claude" ;;
    chatgpt)            is_app_installed "ChatGPT" ;;
    google-gemini)      is_app_installed "Gemini" ;;
    perplexity)         is_app_installed "Perplexity" ;;
    visual-studio-code) is_app_installed "Visual Studio Code" ;;
    android-studio)     is_app_installed "Android Studio" ;;
    datagrip)           is_app_installed "DataGrip" ;;
    docker)             is_app_installed "Docker" ;;
    postman)            is_app_installed "Postman" ;;
    insomnia)           is_app_installed "Insomnia" ;;
    mongodb-compass)    is_app_installed "MongoDB Compass" ;;
    mysqlworkbench)     is_app_installed "MySQLWorkbench" ;;
    devtoys)            is_app_installed "DevToys" ;;
    devdocs)            is_app_installed "DevDocs" ;;
    drawio)             is_app_installed "draw.io" ;;
    responsively)       is_app_installed "Responsively" ;;
    obs)                is_app_installed "OBS" ;;
    the-unarchiver)     is_app_installed "The Unarchiver" ;;
    cleanmymac)         is_app_installed "CleanMyMac" ;;
    monitorcontrol)     is_app_installed "MonitorControl" ;;
    aws-vpn-client)     is_app_installed "AWS VPN Client" ;;
    reactotron)         is_app_installed "Reactotron" ;;
    font-fira-code)     brew list --cask 2>/dev/null | grep -qx "font-fira-code" ;;
    *)                  brew list --cask 2>/dev/null | grep -qx "$cask" ;;
  esac
}
is_formula_installed() { brew list --formula 2>/dev/null | grep -qx "$1"; }
is_cmd()               { command -v "$1" &>/dev/null; }
is_vscode_ext()        { code --list-extensions 2>/dev/null | grep -qix "$1"; }
is_npm_pkg()           { npm list -g --depth=0 2>/dev/null | grep -q "$1"; }

_PROGRESS_CURRENT=0
_PROGRESS_TOTAL=0

_draw_progress() {
  local current="$1" total="$2"
  local bar_width=20
  local filled=$(( bar_width * current / total ))
  local empty=$(( bar_width - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++));  do bar+="░"; done
  gum style --foreground 212 "  ${bar}  ${current}/${total}"
}

_INSTALL_LOG=/tmp/mac_setup_install.log
_SPINNER_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
_ESC=$(printf '\033')

# Last meaningful line of the install log written after byte offset $1,
# so the user sees what the current installer is doing
_last_log_line() {
  tail -c +"$(( $1 + 1 ))" "$_INSTALL_LOG" 2>/dev/null \
    | tail -c 4000 \
    | tr '\r' '\n' \
    | sed -E "s/${_ESC}\[[0-9;]*[a-zA-Z]//g" \
    | grep -v -e '^[[:space:]]*$' \
    | tail -1 \
    | sed -E 's/^[#=O -]*([0-9]+(\.[0-9]+)?%)[[:space:]]*$/Downloading... \1/; s/^[#=O -]+$/Downloading.../'
}

# Runs the install in the background and shows a spinner, the elapsed time and the
# installer's latest output, so long downloads don't look frozen
_run_install() {
  local name="$1"
  shift
  _draw_progress "$_PROGRESS_CURRENT" "$_PROGRESS_TOTAL"
  printf '\n===== %s =====\n' "$name" >> "$_INSTALL_LOG"
  local offset
  offset=$(wc -c < "$_INSTALL_LOG" | tr -d ' ')

  "$@" >> "$_INSTALL_LOG" 2>&1 &
  local pid=$!
  # Background jobs ignore ctrl+c in scripts, so stop the install ourselves
  trap 'pkill -TERM -P "$pid" 2>/dev/null; kill "$pid" 2>/dev/null; _sudo_stop; printf "\r%s[K\n" "$_ESC"; exit 130' INT

  local start=$SECONDS frame=0 cols elapsed status line
  cols=$(tput cols 2>/dev/null || echo 80)
  while kill -0 "$pid" 2>/dev/null; do
    elapsed=$(( SECONDS - start ))
    status=$(_last_log_line "$offset")
    line=$(printf '  %s Installing %s... %d:%02d  %s' \
      "${_SPINNER_FRAMES[frame % ${#_SPINNER_FRAMES[@]}]}" "$name" $(( elapsed / 60 )) $(( elapsed % 60 )) "$status")
    printf '\r%s[K%s[38;5;240m%s%s[0m' "$_ESC" "$_ESC" "${line:0:$(( cols - 1 ))}" "$_ESC"
    frame=$(( frame + 1 ))
    sleep 0.2
  done
  printf '\r%s[K' "$_ESC"

  elapsed=$(( SECONDS - start ))
  if wait "$pid"; then
    gum style --foreground 46  "  ✅ $name installed in $(printf '%d:%02d' $(( elapsed / 60 )) $(( elapsed % 60 )))"
    INSTALLED_ITEMS+=("$name")
  else
    gum style --foreground 196 "  ❌ $name failed (see $_INSTALL_LOG)"
    FAILED_ITEMS+=("$name")
  fi
  trap - INT
  _PROGRESS_CURRENT=$(( _PROGRESS_CURRENT + 1 ))
}

# ─────────────────────────────────────────
# Pre-install notes
# ─────────────────────────────────────────

# Installers that run a .pkg (or sudo) and stop to ask for the Mac password
_needs_sudo() {
  case "$1" in
    aws|aws-vpn-client|microsoft-word|microsoft-excel|microsoft-powerpoint|microsoft-outlook|microsoft-teams|onedrive|zoom) return 0 ;;
    *) return 1 ;;
  esac
}

_has_java() { /usr/libexec/java_home &>/dev/null || [ -e "$HOME/.sdkman/candidates/java/current" ]; }

# Prints one note per line for the selected entries ("name|type|id")
_install_notes() {
  local entry name type id ids=" "
  for entry in "$@"; do
    IFS='|' read -r name type id <<< "$entry"
    ids+="$id "
  done

  for entry in "$@"; do
    IFS='|' read -r name type id <<< "$entry"
    case "$id" in
      android-studio|docker|microsoft-word|microsoft-excel|microsoft-powerpoint|microsoft-outlook|microsoft-teams|maestro)
        echo "$name — large download, can take several minutes" ;;
    esac
    case "$id" in
      maestro)
        _has_java || echo "$name — needs Java: install 'JDK 17.0.19-zulu (React Native)' in Java Ecosystem first" ;;
      node-lts)
        [ -s "$HOME/.nvm/nvm.sh" ] || [[ "$ids" == *" nvm "* ]] || echo "$name — needs nvm: select nvm too" ;;
      jdk-rn)
        [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] || [[ "$ids" == *" sdkman "* ]] || echo "$name — needs SDKMAN: select SDKMAN too" ;;
    esac
    _needs_sudo "$id" && echo "$name — asks for your Mac password (admin installer)"
  done
}

_SUDO_KEEPALIVE_PID=""

# Asks for the password once and keeps sudo alive, so installers don't stop mid-progress
_sudo_start() {
  sudo -v || return 1
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  _SUDO_KEEPALIVE_PID=$!
}

_sudo_stop() {
  [ -n "$_SUDO_KEEPALIVE_PID" ] && kill "$_SUDO_KEEPALIVE_PID" 2>/dev/null
  _SUDO_KEEPALIVE_PID=""
}

# Shows the notes for the selected entries and asks to continue; returns 1 to cancel
_confirm_install() {
  local notes entry name type id needs_sudo=false
  notes=$(_install_notes "$@")
  for entry in "$@"; do
    IFS='|' read -r name type id <<< "$entry"
    _needs_sudo "$id" && needs_sudo=true
  done

  if [ -n "$notes" ]; then
    echo ""
    gum style --foreground 214 "Before installing:"
    while IFS= read -r note; do
      echo "  ⚠️  $note"
    done <<< "$notes"
    echo ""
    gum confirm "Continue?" || return 1
  fi

  if $needs_sudo; then
    echo ""
    gum style --foreground 240 "Enter your Mac password once so the installers don't stop to ask:"
    _sudo_start || return 1
  fi
}

do_install_cask() {
  _run_install "$1" brew install --cask "$2"
}

do_install_brew() {
  _run_install "$1" brew install "$2"
}

do_install_cmd() {
  _run_install "$1" bash -c "$2"
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
  # Media
  "Spotify|cask|spotify"
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
        node-lts)     [ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh" && nvm which default &>/dev/null ;;
        virtualenv)   is_cmd virtualenv ;;
        font-fira-code) is_cask_installed "font-fira-code" ;;
        cocoapods)    is_formula_installed "cocoapods" ;;
        omz)          [ -d "$HOME/.oh-my-zsh" ] ;;
        sdkman)       [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ] ;;
        jdk-rn)       [ -d "$HOME/.sdkman/candidates/java/17.0.19-zulu" ] ;;
        maestro)      is_cmd maestro || [ -x "$HOME/.maestro/bin/maestro" ] ;;
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
        node-lts)
          do_install_cmd "$name" \
            "source \"\$HOME/.nvm/nvm.sh\" && nvm install --lts && nvm alias default \$(node --version)" ;;
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
          do_install_brew "$name" "cocoapods" ;;
        sdkman)
          do_install_cmd "$name" "brew install bash &>/dev/null; curl -s 'https://get.sdkman.io' | \$(brew --prefix bash)/bin/bash" ;;
        jdk-rn)
          do_install_cmd "$name" \
            "source \"\$HOME/.sdkman/bin/sdkman-init.sh\" && sdk install java 17.0.19-zulu && sdk default java 17.0.19-zulu" ;;
        maestro)
          do_install_cmd "$name" \
            "[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\"; curl -fsSL 'https://get.maestro.mobile.dev' | bash" ;;
        omz)
          do_install_cmd "$name" \
            "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" '' --unattended && \
             bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)\" && \
             sed -i '' 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"\"/' ~/.zshrc && \
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

  local selected_entries=()
  while IFS= read -r sel; do
    for entry in "${available_entries[@]}"; do
      IFS='|' read -r name type id <<< "$entry"
      if [ "$name" = "$sel" ]; then
        selected_entries+=("$entry")
        break
      fi
    done
  done <<< "$selected"

  _confirm_install "${selected_entries[@]}" || return

  echo ""
  _PROGRESS_CURRENT=0
  _PROGRESS_TOTAL=${#selected_entries[@]}

  for entry in "${selected_entries[@]}"; do
    IFS='|' read -r name type id <<< "$entry"
    install_app "$name" "$type" "$id"
  done
  _sudo_stop

  _draw_progress "$_PROGRESS_TOTAL" "$_PROGRESS_TOTAL"
  echo ""
  if [ ${#FAILED_ITEMS[@]} -eq 0 ]; then
    gum style --foreground 46 "  All selected items installed successfully!"
  else
    gum style --foreground 214 "  Done with some failures. Check the log: $_INSTALL_LOG"
  fi
  echo ""
  gum style --foreground 212 "Press any key to return to the menu."
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
  "Node.js LTS (via nvm)|special|node-lts"
  "Watchman|brew|watchman"
  "CocoaPods|brew|cocoapods"
  "Reactotron|cask|reactotron"
  "Maestro (mobile E2E tests)|special|maestro"
)

# ─────────────────────────────────────────
# Cloud
# ─────────────────────────────────────────

CLOUD_ITEMS=(
  "AWS CLI v2|special|aws"
  "AWS VPN Client|cask|aws-vpn-client"
  "Terraform|brew|terraform"
  "Helm|brew|helm"
  "Argo CD CLI|brew|argocd"
  "Railway CLI|brew|railway"
)

show_cloud() {
  _CATEGORY_ITEMS=("${CLOUD_ITEMS[@]}")
  show_category "Cloud"
}

AI_ITEMS=(
  "Claude|cask|claude"
  "ChatGPT|cask|chatgpt"
  "Gemini|cask|google-gemini"
)

show_ai() {
  _CATEGORY_ITEMS=("${AI_ITEMS[@]}")
  show_category "AI Assistants"
}

show_node() {
  _CATEGORY_ITEMS=("${NODE_ITEMS[@]}")
  show_category "Node.js Ecosystem"
  if printf '%s\n' "${INSTALLED_ITEMS[@]}" | grep -q "^nvm$"; then
    echo ""
    gum style --foreground 214 "  ⚠️  nvm installed. Run 'Node.js LTS' from this menu to install Node,"
    gum style --foreground 214 "     or restart your terminal and run: nvm install --lts && nvm alias default \$(node --version)"
  fi
}

# ─────────────────────────────────────────
# Java
# ─────────────────────────────────────────

JAVA_ITEMS=(
  "SDKMAN|special|sdkman"
  "JDK 17.0.19-zulu (React Native)|special|jdk-rn"
)

show_java() {
  _CATEGORY_ITEMS=("${JAVA_ITEMS[@]}")
  show_category "Java Ecosystem"
  if printf '%s\n' "${INSTALLED_ITEMS[@]}" | grep -q "^SDKMAN$"; then
    echo ""
    gum style --foreground 214 "  ⚠️  SDKMAN installed. Run 'JDK 17.0.19-zulu (React Native)' from this menu to install Java,"
    gum style --foreground 214 "     or restart your terminal and run: sdk install java 17.0.19-zulu"
  fi
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
  "@google/gemini-cli"
  "@fission-ai/openspec"
  "autocannon"
  "eas-cli"
  "expo-cli"
  "json-server"
  "npm-check"
  "ntl"
  "serverless"
  "vercel"
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
  _PROGRESS_CURRENT=0
  _PROGRESS_TOTAL=${#to_install[@]}

  for pkg in "${to_install[@]}"; do
    _run_install "$pkg" npm install -g "$pkg"
  done

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
  "mikestead.dotenv"
  "ms-azuretools.vscode-docker"
  "naumovs.color-highlight"
  "openai.chatgpt"
  "pkief.material-icon-theme"
  "prisma.prisma"
  "ritwickdey.liveserver"
  "snyk-security.snyk-vulnerability-scanner"
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
  _PROGRESS_CURRENT=0
  _PROGRESS_TOTAL=$(echo "$selected" | wc -l | tr -d ' ')

  while IFS= read -r ext; do
    _draw_progress "$_PROGRESS_CURRENT" "$_PROGRESS_TOTAL"
    gum style --foreground 240 "  ⠸ Installing $ext..."
    if code --install-extension "$ext" >> "$_INSTALL_LOG" 2>&1; then
      gum style --foreground 46  "  ✅ $ext installed"
      INSTALLED_ITEMS+=("vscode: $ext")
    else
      gum style --foreground 196 "  ❌ $ext failed"
      FAILED_ITEMS+=("vscode: $ext")
    fi
    _PROGRESS_CURRENT=$(( _PROGRESS_CURRENT + 1 ))
  done <<< "$selected"

  _draw_progress "$_PROGRESS_TOTAL" "$_PROGRESS_TOTAL"
  echo ""
  if [ ${#FAILED_ITEMS[@]} -eq 0 ]; then
    gum style --foreground 46 "  All selected items installed successfully!"
  else
    gum style --foreground 214 "  Done with some failures. Check the log: $_INSTALL_LOG"
  fi
  echo ""
  gum style --foreground 212 "Press any key to return to the menu."
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
    "Java Ecosystem" \
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
    "Java Ecosystem")        show_java ;;
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
