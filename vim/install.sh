#!/bin/bash

export VIM_DIR
VIM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p "${VIM_DIR}/vimfiles"

BUNDLE_DIR="${VIM_DIR}/vimfiles/bundle"
mkdir -p "${BUNDLE_DIR}"

echo $BUNDLE_DIR

# Install Vundle
if [ ! -d "${BUNDLE_DIR}/Vundle.vim" ]
then
  git clone https://github.com/VundleVim/Vundle.vim.git "${BUNDLE_DIR}/Vundle.vim"
else
  cd "${BUNDLE_DIR}/Vundle.vim"
  git pull
  cd ..
fi
