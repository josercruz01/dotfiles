#!/bin/bash

brew tap caskroom/cask

# Install packages
apps=(
    spectacle
    iterm2
    sublime
    firefox
    google-chrome
    spotify
    vlc
)

brew cask install "${apps[@]}"

# Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package
