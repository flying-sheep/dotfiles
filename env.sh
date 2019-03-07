export DEFAULT_USER=$(whoami)

typeset -U path  # unique entries
path=("$HOME/bin" "$HOME/.cargo/bin" $path)

# Application choices
test -f /usr/bin/ksshaskpass && export SSH_ASKPASS='/usr/bin/ksshaskpass'
export EDITOR=vim
test -n "$DISPLAY" && export EDITOR=kate
export PAGER=less
export JPM_FIREFOX_BINARY='firefox-developer'

# less config:
# F: quit-if-one-screen
# R: RAW-CONTROL-CHARS
# S: chop-long-lines
# M: LONG-PROMPT
# K: quit-on-intr
# X: “more” mode. We skip that one
export LESSOPEN='|lesspipe.sh %s'
export SYSTEMD_LESS=FRSMK
export LESS="-$SYSTEMD_LESS"
export BAT_PAGER="less $LESS"

# Data directories
export R_LIBS_USER="$HOME/.local/lib/R/$(R --slave -e 'cat(as.character(getRversion()[1, 1:2]))')"
export JUPYTERLAB_DIR="$HOME/.jupyter/lab"

# custom XCompose
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim

# Theming goodies
export CALIBRE_USE_SYSTEM_THEME=1
export GTK_USE_PORTAL=1  # Native file picker for Firefox
export _JAVA_OPTIONS="\
    -Dawt.useSystemAAFontSettings=on \
    -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
    -Dswing.systemlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
    -Djayatana.force=true"

# global menus
export GTK_MODULES=appmenu-gtk-module
export SAL_USE_VCLPLUGIN=gtk

# ConTeXt
test -f /opt/context-minimals/setuptex && source /opt/context-minimals/setuptex

# Fixup
export VIRTUAL_ENV_DISABLE_PROMPT=y  # my prompt has this built in
export WINEDLLOVERRIDES='winemenubuilder.exe=d wine setup.exe'  # prevent silly wine apps hijacking .ini files
