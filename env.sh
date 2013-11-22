#stuff that GUI apps need to see

xset b off #no annoying bell

export SSH_ASKPASS='/usr/bin/ksshaskpass'
ssh-add </dev/null 2>/dev/null

#custom XCompose
export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim

export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on \
                      -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
                      -Dswing.systemlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel \
                      -Djayatana.force=true"

#context minimals
export OSFONTDIR="/usr/share/fonts:$HOME/.fonts"
#source /opt/context-minimals/setuptex

#some AUR packages
export LOCAL_PACKAGE_SOURCES="$HOME/Downloads/"

#VSYNC
export __GL_YIELD='USLEEP'
