#!/bin/sh

# This script configures my Node.js development setup. Note that
# nvm is installed by the Homebrew install script.

NODE_VERSION=6.9.1
mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"
echo "Installing a stable version of Node..."

# Install the stable version of node if not currently installed.
current_version=`nvm current`
if [ "${current_version}" == "v${NODE_VERSION}" ]; then
  echo "Node 'v${NODE_VERSION}' is already installed. Skipping installation."
else
  nvm install $NODE_VERSION
  # Switch to the installed version
  nvm use $NODE_VERSION

  # Use the stable version of node by default.
  nvm alias default $NODE_VERSION
  
  # All `npm install <pkg>`` commands will pin to the version that was available at the time you run the command
  npm config set save-exact = true
fi

# Globally install with npm
# git-open: to open the GitHub page or website for a repository.
# trash: the safe `rm` alternative
# diff-so-fancy: colorful git diff
packages=(
    diff-so-fancy
    gulp
    bower
    git-open
    trash-cli
    yo
    eslint
)

npm install -g "${packages[@]}"
