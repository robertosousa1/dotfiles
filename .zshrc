# ---------------------
# Oh My Zsh
# ---------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# ---------------------
# Zinit
# ---------------------
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light spaceship-prompt/spaceship-prompt

# ---------------------
# Spaceship
# ---------------------
SPACESHIP_PROMPT_ORDER=(user dir host git exec_time line_sep jobs exit_code char)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

# ---------------------
# Core
# ---------------------
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# ---------------------
# NVM
# ---------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ---------------------
# Android SDK
# ---------------------
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# ---------------------
# Zsh command history
# ---------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history
setopt hist_ignore_dups
setopt inc_append_history
setopt hist_reduce_blanks

# ---------------------
# Zsh shell options
# ---------------------
setopt auto_cd
setopt extended_glob

# ---------------------
# Zsh tab-completion
# ---------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ---------------------
# Arrow keys ↑/↓ search zsh history filtered by what you've typed so far
# ---------------------
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# ---------------------
# Paste handling — avoids zsh mangling special chars (URLs, etc.) when pasting into the terminal
# ---------------------
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# ---------------------
# SDKMAN (must stay at the end of the file)
# ---------------------