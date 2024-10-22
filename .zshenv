export CLASSPATH=.

export JAVA_HOME=/usr/lib/jvm/default

export _JAVA_AWT_WM_NONREPARENTING=1

#set xdg right
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export STARDICT_DATA_DIR="$HOME/.local/share/stardict"

#make programms respect xdg
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export LESSHISTFILE=-
export MPLAYER_HOME="$XDG_CONFIG_HOME"/mplayer
export VIMINIT=":source $XDG_CONFIG_HOME"/nvim/nvimrc

export MATLAB_LOG_DIR=~/.local/MATLAB/R2020a/logs #reallocate matlab logs

export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

export VISUAL=nvim
export EDITOR=nvim
export PAGER=less

export TMUX=''

export SANE_DEFAULT_DEVICE="airscan:e0:EPSON XP-7100 Series"

#############
## ANDROID ##
#############
export ANDROID_HOME=$HOME/Android/Sdk
path+=("$ANDROID_HOME/platform-tools")

path+=("$(go env GOPATH)/bin")
path+=("${CARGO_HOME}/bin")
path+=("${HOME}/.local/bin")
path+=("${HOME}/.texmf/scripts"/*/)

# less in color
export LESS=-R # allow ansi colors
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

eval $(luarocks path)
