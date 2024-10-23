# shellcheck shell=bash
export DEFAULT_USER=$(whoami)

typeset -U path  # unique entries
path=("$HOME/bin" "$HOME/.cargo/bin" $path "$HOME/.local/bin")

# Application choices
test -f /usr/bin/ksshaskpass && export SSH_ASKPASS='/usr/bin/ksshaskpass'
export EDITOR=nvim
test -n "$DISPLAY" && export EDITOR='kate -b'
export PAGER=less
export PARU_PAGER=delta  # paru prefers $PAGER to its own config
export JPM_FIREFOX_BINARY='firefox-developer'
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

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
export R_LIBS_USER="$HOME/.local/lib/R/%v" # https://stat.ethz.ch/R-manual/R-devel/library/base/html/libPaths.html
# export JUPYTERLAB_DIR="$HOME/.jupyter/lab"
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share/:/usr/local/share/:/usr/share/"

# custom XCompose
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim

# Theming goodies
export CALIBRE_USE_SYSTEM_THEME='1'
export KRITA_NO_STYLE_OVERRIDE='1'
export _JAVA_OPTIONS="\
    -Dawt.useSystemAAFontSettings=on \
    -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
    -Dswing.systemlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
    -Djdk.gtk.version=3 \
    -Djayatana.force=true"
# export GTK_USE_PORTAL=1  # Native file picker for Firefox, but breaks themeing
export MOZ_WEBRENDER='1'
export MOZ_ENABLE_WAYLAND='1'
export MOZ_DBUS_REMOTE='1'

# global menus
export GTK_MODULES=appmenu-gtk-module
export SAL_USE_VCLPLUGIN=gtk

# performance & dev goodies
export RUSTFLAGS='-C target-cpu=native'
export DOCKER_BUILDKIT='1'

# ConTeXt
#test -f /opt/context-minimals/setuptex && source /opt/context-minimals/setuptex
export DIGESTIF_TEXMF=/opt/context-lmtx

# Fixup
export SDL_JOYSTICK_HIDAPI='0'  # https://github.com/atar-axis/xpadneo?tab=readme-ov-file#sdl2-228-compatibility
export KWIN_DRM_USE_EGL_STREAMS='1'  # Wayland
export WINEDLLOVERRIDES='winemenubuilder.exe=d wine setup.exe'  # prevent silly wine apps hijacking .ini files

# SSL logging
export SSLKEYLOGFILE="$HOME/.cache/ssl-key.log"
