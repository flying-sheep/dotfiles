#terminal-only exports
export PATH=/home/phil/bin:/usr/local/bin:/usr/bin:/usr/bin/core_perl:/usr/bin/vendor_perl
export PYTHONPATH="/home/phil/Scripts/lib"
export NODE_PATH="/usr/lib/node_modules:$NODE_PATH"

export EDITOR=vim
export LESS='-R'
export LESSOPEN="| $HOME/.dotfiles/autopygmentize %s"

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME='' #we use powerline
DISABLE_AUTO_UPDATE=true

#gui exports, too (executed also by startkde when symlinked to ~/.kde4/env/*.sh)
source "$HOME/.dotfiles/env.sh"

#oh my zsh
plugins=(git svn dbus npm showoff)
source "$ZSH/oh-my-zsh.sh"

#powerline
source /usr/share/zsh/site-contrib/powerline.zsh #echo -e "\ue0a0\ue0a1\ue0a2\ue0b0\ue0b1\ue0b2"
export VIRTUAL_ENV_DISABLE_PROMPT=true

#aliases
alias sudo="sudo " #completion
alias svim="sudo vim" #yes, *that* lazy
alias sensible-browser="firefox" #for jist
alias jist="jist -p" #public gists by default
alias addon-sdk="cd /opt/addon-sdk && source bin/activate; cd -"
alias pcat="$HOME/.dotfiles/autopygmentize"

#command not found
. /etc/profile.d/cnf.sh

#fancy console blurring
source "$HOME/.dotfiles/blur_console.sh"
