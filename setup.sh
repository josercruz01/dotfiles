#!/bin/bash

###############################################################################
# Variable declaration
###############################################################################

export DOTFILES_DIR
export DOTFILES_BACKUP_DIR
DOTFILES_DIR=~/dotfiles
DOTFILES_BACKUP_DIR=~/dotfiles_old

###############################################################################
# Helper functions
###############################################################################

move() {
  if [ -f $1 ]; then
    mv "${1}" "${2}" && return 0
  fi
  return 0
}

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1
  printf "\n"
  return 0
}

ask_for_sudo() {

  # Ask for the administrator password upfront
  sudo -v

  # Update existing `sudo` time stamp until this script has finished
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> /dev/null &
  return 0

}

cmd_exists() {
  [ -x "$(command -v "$1")" ] \
    && printf 0 \
    || printf 1
  return 0
}

execute() {
  $1 &> /dev/null
  print_result $? "${2:-$1}"
  return 0
}

get_answer() {
  printf "$REPLY"
  return 0
}

get_os() {

  declare -r OS_NAME="$(uname -s)"
  local os=""

  if [ "$OS_NAME" == "Darwin" ]; then
    os="osx"
  elif [ "$OS_NAME" == "Linux" ] && [ -e "/etc/lsb-release" ]; then
    os="ubuntu"
  fi

  printf "%s" "$os"
  return 0

}

is_git_repository() {
  [ "$(git rev-parse &>/dev/null; printf $?)" -eq 0 ] \
    && return 0 \
    || return 1
}

mkd() {
  if [ -n "$1" ]; then
    if [ -e "$1" ]; then
      if [ ! -d "$1" ]; then
        print_error "$1 - a file with the same name already exists!"
      else
        print_success "$1"
      fi
    else
      execute "mkdir -p $1" "$1"
    fi
  fi
  return 0
}

print_error() {
  # Print output in red
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
  return 0
}

print_info() {
  # Print output in purple
  printf "\n\e[0;35m $1\e[0m\n\n"
  return 0
}

print_question() {
  # Print output in yellow
  printf "\e[0;33m  [?] $1\e[0m"
  return 0
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ $1 -ne 0 ] \
    && exit
  return 0
}

print_success() {
  # Print output in green
  printf "\e[0;32m  [✔] $1\e[0m\n"
  return 0
}

###############################################################################
# XCode Command Line Tools                                                    #
###############################################################################

if ! xcode-select --print-path &> /dev/null; then

  # Prompt user to install the XCode Command Line Tools
  xcode-select --install &> /dev/null

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Wait until the XCode Command Line Tools are installed
  until xcode-select --print-path &> /dev/null; do
    sleep 5
  done

  print_result $? 'Install XCode Command Line Tools'

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Point the `xcode-select` developer directory to
  # the appropriate directory from within `Xcode.app`
  # https://github.com/alrra/dotfiles/issues/13

  sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
  print_result $? 'Make "xcode-select" developer directory point to Xcode'

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Prompt user to agree to the terms of the Xcode license
  # https://github.com/alrra/dotfiles/issues/10

  sudo xcodebuild -license
  print_result $? 'Agree with the XCode Command Line Tools licence'

fi

sudo chown $USER /usr/local
sudo chmod -R 755 /usr/local

###############################################################################
# Symlinks to link dotfiles into ~/                                           #
###############################################################################

declare -a FILES_TO_SYMLINK=(

  'shell/shell_aliases'
  'shell/shell_config'
  'shell/shell_exports'
  'shell/shell_functions'
  'shell/bash_profile'
  'shell/bash_prompt'
  'shell/bashrc'
  'shell/zshrc'
  'shell/ackrc'
  'shell/curlrc'
  'shell/gemrc'
  'shell/inputrc'
  'shell/screenrc'

  'git/gitattributes'
  'git/gitconfig'
  'git/gitignore'

  'tmux/tmux.conf'
)

# Move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files

for i in ${FILES_TO_SYMLINK[@]}; do
  echo "Moving any existing dotfiles from ~ to $DOTFILES_BACKUP_DIR"
  move ~/.${i##*/} ${DOTFILES_BACKUP_DIR}
done

# Backup gpg dotfiles
mkdir -p ${DOTFILES_BACKUP_DIR}/.gnupg
move ~/.gnupg/gpg.conf ${DOTFILES_BACKUP_DIR}/.gnupg
move ~/.gnupg/gpg-agent.conf ${DOTFILES_BACKUP_DIR}/.gnupg-agent

main() {

  local i=''
  local sourceFile=''
  local targetFile=''

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for i in ${FILES_TO_SYMLINK[@]}; do

    sourceFile="$(pwd)/$i"
    targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$targetFile" ]; then
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else
      ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
      if answer_is_yes; then
        rm -rf "$targetFile"
        execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
      else
        print_error "$targetFile → $sourceFile"
      fi
    fi

  done

  # Handle gpg dotfiles manually since they live inside ~/.gnupg folder
  mkdir -p ~/.gnupg
  ln -s "$(pwd)/gnupg/gpg.conf" ~/.gnupg/gpg.conf
  ln -s "$(pwd)/gnupg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf

  # Copy binaries
  ln -fs $DOTFILES_DIR/bin $HOME
  chmod +rwx $HOME/bin/*
}

install_zsh () {
  # Test to see if zshell is installed.  If it is:
  if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Install Oh My Zsh if it isn't already present
    if [[ ! -d $DOTFILES_DIR/oh-my-zsh/ ]]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
      chsh -s $(which zsh)
    fi
  else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
      if [[ -f /etc/redhat-release ]]; then
        sudo yum install zsh
        install_zsh
      fi
      if [[ -f /etc/debian_version ]]; then
        sudo apt-get install zsh
        install_zsh
      fi
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
      echo "We'll install zsh, then re-run this script!"
      brew install zsh
      exit
    fi
  fi
}

main

echo "switching to zsh, please run script again after the switch..."
install_zsh

echo -n "Creating $DOTFILES_BACKUP_DIR for backup of any existing dotfiles in ~..."
mkdir -p $DOTFILES_BACKUP_DIR
echo "done"

# Change to the dotfiles directory
echo -n "Changing to the $DOTFILES_DIR directory..."
cd $DOTFILES_DIR
echo "done"

###############################################################################
# OSX defaults                                                                #
###############################################################################

$DOTFILES_DIR/osx/set-defaults.sh

###############################################################################
# Homebrew                                                                    #
###############################################################################

$DOTFILES_DIR/install/brew.sh
$DOTFILES_DIR/install/brew-cask.sh

###############################################################################
# Node                                                                        #
###############################################################################

$DOTFILES_DIR/install/npm.sh

###############################################################################
# Zsh                                                                         #
###############################################################################

# Install Zsh settings
ln -s $DOTFILES_DIR/zsh/themes/jose.zsh-theme $HOME/.oh-my-zsh/themes

# Install font used by the zsh theme
cp -rf $DOTFILES_DIR/font/Inconsolata-dz-Powerline.otf /Library/Fonts

###############################################################################
# Vim and neovim
###############################################################################

# Install vim
$DOTFILES_DIR/vim/install.sh

# Configure installation
ln -fs $DOTFILES_DIR/vim/vimfiles ~/.config/nvim
ln -fs $DOTFILES_DIR/vim/vimfiles ~/.vim
ln -fs $DOTFILES_DIR/vim/vimrc ~/.config/nvim/init.vim
ln -fs $DOTFILES_DIR/vim/vimrc ~/.vimrc

nvim +PluginInstall +qall

###############################################################################
# Ruby
###############################################################################
$DOTFILES_DIR/install/ruby.sh

###############################################################################
# Tmuxinator
###############################################################################

gem install tmuxinator
curl -o ~/.tmuxinator.completion.zsh \
  https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh

###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Install the Solarized Dark theme for iTerm
open "${HOME}/dotfiles/iterm/themes/Solarized Dark.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Reload zsh settings
source ~/.zshrc
