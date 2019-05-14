# if prezto isn’t globally installed
test -z "$ZPREZTODIR" && source "$HOME/.zprezto/init.zsh"

test -f "$HOME/.zshrc_local" && source "$HOME/.zshrc_local"

# aliases
eval $(thefuck --alias)
alias cat=bat
alias less=bat
alias ls=exa
alias ll='exa -l --header --git --time-style=long-iso'
alias tree='exa --tree'

alias pipup='pip3 list -o --format freeze | cut -d= -f1 | xargs pip3 install -U --user'
alias qstat='qstat -u $USER'

R() {
    if (( $# > 0 )); then
        /usr/bin/R "$@"
    else
        jupyter console --kernel=ir
    fi
}

# notify on long running commands
if [[ -f /usr/share/undistract-me/long-running.bash ]]; then
	source /usr/share/undistract-me/long-running.bash
	preexec_install() {
		# Just patch precmd instead of setting traps
		eval "$(whence -f precmd | sed '2ipreexec_set_exit')"
	}
	notify_when_long_running_commands_finish_install
fi

# command not found
test -f /usr/share/doc/pkgfile/command-not-found.zsh && source /usr/share/doc/pkgfile/command-not-found.zsh

# Secrets
ssh-add </dev/null 2>/dev/null
test -n "$SSH_ASKPASS" && export GITHUB_PAT=$("$SSH_ASKPASS" 'Password for "token flying-sheep@github.com"')

