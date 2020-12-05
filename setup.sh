echo 'installing homebrew' 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

echo 'installing git' 
brew install git

echo "What name do you want to use in GIT user.name?"
echo "For example, mine will be \"Roberto Alves\""
read git_config_user_name
git config --global user.name "$git_config_user_name"
clear 

echo "What email do you want to use in GIT user.email?"
echo "For example, mine will be \"roberto_junior_sousa@hotmail.com\""
read git_config_user_email
git config --global user.email $git_config_user_email
clear

echo "What default editor do you want to use in GIT core.editor?"
read git_core_editor_to_vim
git config --global core.editor $git_core_editor_to_vim
clear

echo 'installing git remote codecommit' 
pip install git-remote-codecommit

echo 'installing chrome' 
brew cask install google-chrome

echo 'installing brave'
brew cask install brave-browser

echo 'installing spotify' 
brew cask install spotify

echo 'installing whatsapp desktop' 
brew cask install whatsapp

echo 'installing skype' 
brew cask install skype

echo 'installing discord' 
brew cask install discord

echo 'installing telegram' 
brew cask install telegram

echo 'installing slack' 
brew cask install slack

echo 'installing clean my mac' 
brew cask install cleanmymac

echo 'installing team viewer' 
brew cask install teamviewer

echo 'installing the unarchiver' 
brew cask install the-unarchiver

echo 'installing docker' 
brew cask install docker
open -a Docker

echo 'installing aws-cli' 
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

echo 'installing aws eb cli' 
brew install awsebcli

echo 'installing aws vpn client' 
brew cask install aws-vpn-client

echo 'installing mongodb compass' 
brew cask install mongodb-compass

echo 'installing studio 3t' 
brew cask install studio-3t

echo 'installing microsoft teams' 
brew cask install microsoft-teams

echo 'installing zoom' 
brew cask install zoom

echo 'installing microsoft word' 
brew cask install microsoft-word

echo 'installing microsoft excel' 
brew cask install microsoft-excel

echo 'installing microsoft powerpoint' 
brew cask install microsoft-powerpoint

echo 'installing microsoft outlook' 
brew cask install microsoft-outlook

echo 'installing microsoft remote desktop' 
echo 'microsoft remote desktop not available for download by brew cask' 

echo 'installing microsoft to do' 
echo 'microsoft to do not available for download by brew cask' 

echo 'installing friendly streaming browser' 
echo 'friendly streaming browser not available for download by brew cask' 

echo 'installing birdid' 
echo 'birdid desktop not available for download by brew cask' 

echo 'installing reactotron' 
brew cask install reactotron

echo 'installing insomnia' 
brew cask install insomnia

echo 'installing postman' 
brew cask install postman

echo 'installing devdocs'
brew cask install devdocs

echo 'installing obs'
brew cask install obs

echo 'installing notion'
brew cask install notion

echo 'installing adobe acrobat reader dc'
brew cask install adobe-acrobat-reader

echo 'installing responsively app'
brew cask install responsively

echo 'installing draw.io'
brew cask install drawio

echo 'installing visual studio code'
brew cask install visual-studio-code

echo 'installing extensions'
code --install-extension dbaeumer.vscode-eslint
code --install-extension christian-kohler.path-intellisense
code --install-extension dracula-theme.theme-dracula
code --install-extension esbenp.prettier-vscode
code --install-extension foxundermoon.shell-format
code --install-extension pmneo.tsimporter
code --install-extension eamodio.gitlens
code --install-extension yzhang.markdown-all-in-one
code --install-extension naumovs.color-highlight
code --install-extension ms-azuretools.vscode-docker
code --install-extension mikestead.dotenv
code --install-extension editorconfig.editorconfig
code --install-extension wix.vscode-import-cost
code --install-extension ritwickdey.liveserver
code --install-extension ionutvmi.path-autocomplete
code --install-extension rocketseat.rocketseatreactnative
code --install-extension rocketseat.rocketseatreactjs
code --install-extension tomoki1207.pdf
code --install-extension jpoissonnier.vscode-styled-components
code --install-extension pkief.material-icon-theme
code --install-extension snyk-security.vscode-vuln-cost
code --install-extension natqe.reload

echo 'installing fira code'
brew tap homebrew/cask-fonts
brew cask install font-fira-code

echo 'installing zsh'
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo 'installing oh my zsh'
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" 
code ~/.zshrc
echo 'Set ZSH_THEME="spaceship"'

echo 'installing dracula theme terminal'
git clone https://github.com/dracula/terminal-app.git

echo 'installing zplugin'
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
echo 'add the following lines to .zshrc /
      zplugin light zsh-users/zsh-autosuggestions /
      zplugin light zsh-users/zsh-completions /
      zplugin light zdharma/fast-syntax-highlighting'

echo 'installing android studio'
brew cask install android-studio

echo 'installing datagrip'
brew cask install datagrip

echo 'installing nvm'
brew install nvm

export NVM_DIR="$HOME/.nvm" && (
git clone https://github.com/creationix/nvm.git "$NVM_DIR"
cd "$NVM_DIR"
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 14.15.0
nvm --version
nvm alias default 14.15.0
node --version
npm --version

echo 'installing yarn'
brew install yarn --ignore-dependencies

echo 'installing global npm packages'
npm i -g serverless expo-cli autocannon ntl create-react-app json-server react-native-cli

echo 'installing watchman'
brew install watchman

echo 'installing cocoapods'
brew cleanup -d -v
brew install cocoapods

echo 'installing jdk8'
brew cask install adoptopenjdk/openjdk/adoptopenjdk8
cd ~/Library/Android/sdk/tools/bin/
sdkmanager --licenses
open -a Android\ Studio
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk /
      export PATH=$PATH:$ANDROID_HOME/emulator /
      export PATH=$PATH:$ANDROID_HOME/tools /
      export PATH=$PATH:$ANDROID_HOME/tools/bin /
      export PATH=$PATH:$ANDROID_HOME/platform-tools'
      
echo 'installing pyenv'
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc

echo 'creating alias to pip3'
echo "alias pip='pip3'" >> ~/.zshrc
 
echo 'installing virtualenv'
pip install virtualenv

echo 'installing jupyter notebook'
brew install jupyter

echo 'installing miniconda'
brew cask install miniconda
    
