#!/bin/zsh

ln -s .config/dotfiles/zshrc ~/.zshrc
ln -s .config/dotfiles/env.sh ~/.zshenv
ln -s ../../dotfiles/env.sh .config/plasma-workspace/env/
ln -s .config/dotfiles/zpreztorc ~/.zpreztorc 

ln -s ../dotfiles/gitconfig git/config
ln -s ../dotfiles/fonts.conf .config/fontconfig/
ln -s .config/dotfiles/vimrc ~/.vimrc
