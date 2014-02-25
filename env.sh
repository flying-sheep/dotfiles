#stuff that GUI apps need to see

xset b off #no annoying bell

if [[ -z $SSH_AGENT_PID ]]; then
	eval "$(ssh-agent -s)"
fi
export SSH_ASKPASS='/usr/bin/ksshaskpass'

#custom XCompose
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim

export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on \
                      -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
                      -Dswing.systemlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
                      -Djayatana.force=true"

#context minimals
_setuptex=/opt/context-minimals/setuptex
test -f $_setuptex && source $_setuptex

#some AUR packages
export LOCAL_PACKAGE_SOURCES="$HOME/Downloads/"

#VSYNC
#export __GL_YIELD='USLEEP'
