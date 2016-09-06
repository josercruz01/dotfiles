#!/bin/bash
set -e
set -x

# Installs Homebrew and some of the common dependencies needed/desired for software development

# Ask for the administrator password upfront
sudo -v

# Check for Homebrew and install it if missing
if test ! $(which brew)
then
  echo "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew tap homebrew/versions
brew tap homebrew/dupes
brew tap Goles/battery

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade --all

# Install the Homebrew packages I use on a day-to-day basis.
#
# - Languages: rbenv (Ruby), nvm (Node.js)
# - Databases: Progres, MySQL, Redis, Elasticsearch
# - Fuck (https://github.com/nvbn/thefuck): Correct your previous command. Note
#   that this needs to be added to zsh or bash. See the project README.
# - git-extras (https://vimeo.com/45506445): Adds a shit ton of useful commands #   to git.
# - autojump (https://github.com/joelthelion/autojump): a faster way to navigate
#   your filesystem.
# Note that I install nvm (https://github.com/creationix/nvm) instead
# of installing Node directly. This gives me more explicit control over
# which version I'm using.

apps=(
    rbenv 
    nvm
    bash-completion2
    coreutils
    findutils
    fortune
    ponysay
    git
    git-extras
    gnu-sed --with-default-names
    grep --with-default-names
    homebrew/completions/brew-cask-completion
    homebrew/dupes/grep
    homebrew/dupes/openssh
    neovim/neovim/neovim
    autojump
    python
    the_silver_searcher
    wget
)

brew install "${apps[@]}"

# Remove outdated versions from the cellar
brew cleanup
