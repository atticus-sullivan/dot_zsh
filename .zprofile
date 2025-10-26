#
# ~/.zprofile
#

# umask 0077

# [[ -f ~/.zshrc ]] && . ~/.zshrc

# start the ssh agent once, source the env file in .zshrc
SSH_ENV="$HOME/.ssh/environment"
/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
chmod 600 "${SSH_ENV}"
. "${SSH_ENV}" > /dev/null
/usr/bin/ssh-add


if [[ "$(tty)" == "/dev/tty1" ]]
then
	startx /home/lukas/.xinitrc bspwm
fi
