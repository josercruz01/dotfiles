#!/bin/sh

#
# This script configures my Node.js development setup. Note that
# nvm is installed by the Homebrew install script.
#
# Also, I would highly reccomend not installing your Node.js build
# tools, e.g., Grunt, gulp, WebPack, or whatever you use, globally.
# Instead, install these as local devDepdencies on a project-by-project
# basis. Most Node CLIs can be run locally by using the executable file in
# "./node_modules/.bin". For example:
#
#     ./node_modules/.bin/webpack --config webpack.local.config.js
#

mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"
. "$(brew --prefix nvm)/nvm.sh"
echo "Installing a stable version of Node..."

# Install the stable version of node.
nvm install 6

# Switch to the installed version
nvm use 6

# Use the stable version of node by default.
nvm alias default 6

# All `npm install <pkg>`` commands will pin to the version that was available at the time you run the command
npm config set save-exact = true

# Globally install with npm
# git-open: to open the GitHub page or website for a repository.
# trash: the safe `rm` alternative
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
