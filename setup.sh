echo 'installing homebrew' 
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/roberto/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

echo 'installing git' 
brew install git

echo 'installing git-lfs' 
brew install git-lfs

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
brew install --cask google-chrome

echo 'installing brave'
brew install --cask brave-browser

echo 'installing spotify' 
brew install --cask spotify

echo 'installing whatsapp desktop' 
brew install --cask whatsapp

echo 'installing skype' 
brew install --cask skype

echo 'installing discord' 
brew install --cask discord

echo 'installing telegram' 
brew install --cask telegram

echo 'installing slack' 
brew install --cask slack

echo 'installing clean my mac' 
brew install --cask cleanmymac

echo 'installing team viewer' 
brew install --cask teamviewer

echo 'installing the unarchiver' 
brew install --cask the-unarchiver

echo 'installing docker' 
brew install --cask docker
open -a Docker

echo 'installing docker-compose' 
brew install docker-compose

echo 'installing mysqlworkbench' 
brew install --cask mysqlworkbench

echo 'installing aws-cli' 
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

echo 'installing aws eb cli' 
brew install awsebcli

echo 'installing aws vpn client' 
brew install --cask aws-vpn-client

echo 'installing azure-cli' 
brew install azure-cli

echo 'installing terraform' 
brew install terraform

echo 'installing mongodb compass' 
brew install --cask mongodb-compass

echo 'installing studio 3t' 
brew install --cask studio-3t

echo 'installing microsoft teams' 
brew install --cask microsoft-teams

echo 'installing zoom' 
brew install --cask zoom

echo 'installing microsoft word' 
brew install --cask microsoft-word

echo 'installing microsoft excel' 
brew install --cask microsoft-excel

echo 'installing microsoft powerpoint' 
brew install --cask microsoft-powerpoint

echo 'installing microsoft outlook' 
brew install --cask microsoft-outlook

echo 'installing microsoft remote desktop' 
echo 'microsoft remote desktop not available for download by brew cask' 

echo 'installing microsoft to do' 
echo 'microsoft to do not available for download by brew cask' 

echo 'installing friendly streaming browser' 
echo 'friendly streaming browser not available for download by brew cask' 

echo 'installing birdid' 
echo 'birdid desktop not available for download by brew cask' 

echo 'installing reactotron' 
brew install --cask reactotron

echo 'installing insomnia' 
brew install --cask insomnia

echo 'installing postman' 
brew install --cask postman

echo 'installing devdocs'
brew install --cask devdocs

echo 'installing obs'
brew install --cask obs

echo 'installing notion'
brew install --cask notion

echo 'installing adobe acrobat reader dc'
brew install --cask adobe-acrobat-reader

echo 'installing responsively app'
brew install --cask responsively

echo 'installing draw.io'
brew install --cask drawio

echo 'installing visual studio code'
brew install --cask visual-studio-code

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
code --install-extension hashicorp.terraform

echo 'installing fira code'
brew tap homebrew/cask-fonts
brew install --cask font-fira-code

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
brew install --cask android-studio

echo 'installing datagrip'
brew install --cask datagrip

echo 'installing nvm'
brew install nvm

export NVM_DIR="$HOME/.nvm" && (
git clone https://github.com/creationix/nvm.git "$NVM_DIR"
cd "$NVM_DIR"
git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 14.16.0
nvm --version
nvm alias default 14.16.0
node --version
npm --version

echo 'installing pnpm'
curl -fsSL https://get.pnpm.io/install.sh | sh -

echo 'installing yarn'
brew install yarn --ignore-dependencies

echo 'installing global npm packages'
npm i -g serverless expo-cli autocannon ntl create-react-app json-server react-native-cli npm-check expo-cli appcenter-cli

echo 'installing watchman'
brew install watchman

echo 'installing cocoapods'
brew cleanup -d -v
brew install cocoapods

echo 'installing jdk8'
brew install --cask adoptopenjdk/openjdk/adoptopenjdk8
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
brew install --build-from-source jupyterlab

echo 'installing miniconda'
brew install --cask miniconda

echo 'installing elixir'
brew install elixir
    
echo 'installing phoenix'
mix archive.install hex phx_new 1.5.7

echo 'installing soapui'
brew install soapui --no-quarantine

echo 'installing devtoys'
brew install --cask devtoys

echo 'installing chatgpt'
brew install --cask chatgpt
