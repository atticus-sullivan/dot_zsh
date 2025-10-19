##################
## ZSH specific ##
##################

fpath+=("/home/lukas/coding/00_completion/")

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt HIST_IGNORE_SPACE
HISTIGNORE="exit:ls:ll:l"	#ignore commands seperated by ':' when writing to history
setopt autocd numericglobsort extendedglob
unsetopt beep nomatch notify

##################
## Key bindings ##
##################
bindkey -v
export KEYTIMEOUT=40 # delay of pressing Esc key in vi mode = 0.4s

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-Left]="^[[1;5D"
key[Control-Right]="^[[1;5C"

# autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search

# setup key accordingly
[[ -n "${key[Home]}"      ]]     && bindkey -- "${key[Home]}"          beginning-of-line
[[ -n "${key[End]}"       ]]     && bindkey -- "${key[End]}"           end-of-line
[[ -n "${key[Insert]}"    ]]     && bindkey -- "${key[Insert]}"        overwrite-mode
[[ -n "${key[Backspace]}" ]]     && bindkey -- "${key[Backspace]}"     backward-delete-char
[[ -n "${key[Delete]}"    ]]     && bindkey -- "${key[Delete]}"        delete-char
[[ -n "${key[Up]}"        ]]     && bindkey -- "${key[Up]}"            up-line-or-history
[[ -n "${key[Down]}"      ]]     && bindkey -- "${key[Down]}"          down-line-or-history
[[ -n "${key[Left]}"      ]]     && bindkey -- "${key[Left]}"          backward-char
[[ -n "${key[Right]}"     ]]     && bindkey -- "${key[Right]}"         forward-char
[[ -n "${key[PageUp]}"    ]]     && bindkey -- "${key[PageUp]}"        beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]]     && bindkey -- "${key[PageDown]}"      end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]]     && bindkey -- "${key[Shift-Tab]}"     reverse-menu-complete
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word
bindkey '^U' backward-kill-line
bindkey '^R' history-incremental-pattern-search-backward

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# close shell on ctrl+d if partial line is present
exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

function clear-screen-and-scrollback() {
    printf '\x1Bc'
    zle clear-screen
}

zle -N clear-screen-and-scrollback
bindkey '^L' clear-screen-and-scrollback

################
## Completion ##
################
autoload -Uz compinit
compinit
zstyle ':completion:*' rehash true # automatical rehash to find newly installed packages

## changed completer settings
zstyle ':completion:*' completer _complete _correct
zstyle ':completion:*' expand prefix suffix
# zstyle ':completion:*' menu select
source <(klog completion -c zsh)
source <(glow completion zsh)

############
## PROMPT ##
############
autoload -Uz promptinit
promptinit
prompt walters

# Report CPU usage for commands running longer than 10 seconds
REPORTTIME=1

setopt prompt_subst
autoload -Uz vcs_info # enable vcs_info
precmd () { eval "$PROMPT_COMMAND" ; vcs_info } # always load before displaying the prompt
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'
zstyle ':vcs_info:*' formats ' %s(%F{red}%b%u%c%f)' # git(main)
zstyle ':vcs_info:git:*' actionformats '%s(%F{red}%b|%a%u%c%f)'

if [[ ${EUID} == 0 ]] #if user is root
then #root
	pscol="%F{red}" #red for root
else #normal user
	pscol="%F{green}" #green for the normal user
fi
PROMPT='%B${pscol}[%n@%m %f%C${pscol}]%(?.%F{green}.%F{red})%?${pscol}$%f%b '
RPROMPT='${vcs_info_msg_0_}'

##########
## HELP ##
##########
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo run-help-svk run-help-svn


###############
## PREDITION ##
###############
# set command prediction from history, see 'man 1 zshcontrib'
autoload predict-on
zle -N predict-on
zle -N predict-off
bindkey "^X^Z" predict-on
bindkey "^Z" predict-off

# define word separators (for stuff like backward-word, forward-word, backward-kill-word,..)
# WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # the default
# WORDCHARS=.
# WORDCHARS='*?_[]~=&;!#$%^(){}'
# WORDCHARS='${WORDCHARS:s@/@}'

# just type '...' to get '../..'
rationalise-dot() {
local MATCH
if [[ $LBUFFER =~ '(^|/| |	|'$'\n''|\||;|&)\.\.$' ]]; then
	LBUFFER+=/
	zle self-insert
	zle self-insert
else
	zle self-insert
fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# without this, typing a . aborts incremental history search
bindkey -M isearch . self-insert

## add `|' to output redirections in the history
#setopt histallowclobber

# try to avoid the 'zsh: no matches found...'
setopt nonomatch

# warning if file exists ('cat /dev/null > ~/.zshrc')
setopt NO_clobber

## don't warn me about bg processes when exiting
#setopt nocheckjobs

# Allow comments even in interactive shells
setopt interactivecomments

# if a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
setopt histignorealldups
setopt histignorespace

################
## DIR COLORS ##
################
[[ -f ~/.config/dir_colors   ]] && match_lhs="${match_lhs}$(<~/.config/dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database) #executed if neither ~/.dir_colors nor /etc/DIR_COLORS exists. Prints color for each file type and which terminal emulators are supported
	[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true #check whether terminal emulator is supported

	if type dircolors >/dev/null
	then
		if [[ -f ~/.config/dir_colors ]]
		then
			eval $(dircolors -b ~/.config/dir_colors)
		elif [[ -f /etc/DIR_COLORS ]]
		then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

# Change the window title of X terminals
case ${TERM} in
	st*)
		PROMPT_COMMAND='printf "\033]0;st-${HOSTNAME%%.*} - ${PWD/#${HOME}\//\~\/}\007"'
		;;
	screen*)
		PROMPT_COMMAND=''
		;;
esac

# autoload -Uz add-zsh-hook
# function xterm_title_precmd () {
# 	print -Pn -- '\e]2;%n@%m %~\a'
# 	[[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
# }
#
# function xterm_title_preexec () {
# 	print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "${(q)1}\a"
# 	[[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
# }
#
# if [[ "$TERM" == (Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|screen*|wezterm*|tmux*|xterm*) ]]; then
# 	add-zsh-hook -Uz precmd xterm_title_precmd
# 	add-zsh-hook -Uz preexec xterm_title_preexec
# fi

#ranger load only own config
export RANGER_LOAD_DEFAULT_RC=FALSE

[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

###aliases
#### You may want to put all your additions into a separate file like
#### ~/.zaliased, instead of adding them here directly.
if [ -f ~/.zaliases ]; then
	source ~/.zaliases
fi
# same for global functions
if [ -f ~/.zfuncs ]; then
	source ~/.zfuncs
fi

source "${XDG_CONFIG_HOME}/zsh_dot/catppuccin_macchiato-zsh-syntax-highlighting.zsh"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

zlong_ignore_cmds="vim ssh nvim"
source "${XDG_CONFIG_HOME}/zsh_dot/zlong_alert.zsh"

# plugin manager
# https://github.com/rossmacarthur/sheldon
