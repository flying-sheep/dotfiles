#!/bin/zsh

test -f pacman && pacman -Qq >/dev/null \
    prezto \
    thefuck undistract-me-git pkgfile \
    bat exa \
    ksshaskpass xdotool

ln -s .config/dotfiles/zshrc ~/.zshrc
ln -s .config/dotfiles/env.sh ~/.zshenv
ln -s ../../dotfiles/env.sh ~/.config/plasma-workspace/env/env.sh
ln -s .config/dotfiles/zpreztorc ~/.zpreztorc 

ln -s ../dotfiles/gitconfig ~/.config/git/config
ln -s ../dotfiles/fonts.conf ~/.config/fontconfig/fonts.conf
ln -s .config/dotfiles/vimrc ~/.vimrc
