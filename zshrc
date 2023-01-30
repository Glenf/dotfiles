#!/usr/bin/env zsh

DOTFILES=$HOME/.dotfiles
GREP_EXCLUDE_DIR="{.git,.sass-cache,artwork,node_modules,vendor}"
OS=$(uname)


source $DOTFILES/zsh/env
source $DOTFILES/zsh/alias

path=($DOTFILES/bin $path)

source $DOTFILES/vendor/antigen.zsh

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-history-substring-search

antigen bundle darvid/zsh-poetry
antigen bundle woefe/git-prompt.zsh

# This has to be the last plugin to import
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

if type brew &>/dev/null; then
	FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit && compinit
zmodload -i zsh/complist

unsetopt menu_complete
unsetopt flowcontrol

setopt always_to_end
setopt append_history
setopt auto_menu
setopt complete_in_word
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt interactivecomments
setopt share_history

# Colorful man pages
man() {
	env \
		LESS_TERMCAP_md=$'\e[1;36m' \
		LESS_TERMCAP_me=$'\e[0m' \
		LESS_TERMCAP_se=$'\e[0m' \
		LESS_TERMCAP_so=$'\e[1;40;92m' \
		LESS_TERMCAP_ue=$'\e[0m' \
		LESS_TERMCAP_us=$'\e[1;32m' \
		man "$@"
}

bindkey -v
bindkey '^R' history-incremental-pattern-search-backward

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '\eOA' history-substring-search-up
bindkey '\eOB' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# -------------------------------------------------------------------
# ASDF things
# -------------------------------------------------------------------

# Find where asdf should be installed
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"

# If not found, check for Homebrew package
# if [[ ! -f "$ASDF_DIR/asdf.sh" ]] && (( $+commands[brew] )); then
if (( $+commands[brew] )); then
	ASDF_DIR="$(brew --prefix asdf)/libexec"
fi

# Load command
if [[ -f "$ASDF_DIR/asdf.sh" ]]; then
	. "$ASDF_DIR/asdf.sh"
fi

# Hook direnv into your shell.
eval "$(asdf exec direnv hook zsh)"

# A shortcut for asdf managed direnv.
direnv() { asdf exec direnv "$@"; }

# -------------------------------------------------------------------
# Docker and Kubernetes
# -------------------------------------------------------------------

# Kubernetes completion, if kubectl is installed
if type kubectl &>/dev/null; then
	source <(kubectl completion zsh)
fi

# -------------------------------------------------------------------
# Prompt
# -------------------------------------------------------------------

function username() {
	# if [[ `whoami` != 'tommi' ]]; then
	echo "%F{248}%n%F{reset}"
	# fi
}

function server() {
	if [[ $(hostname) != tommi-* ]]; then
		echo "%F{244}@%F{magenta}%m%F{reset} "
	fi
}

function architecture() {
	if [[ $(arch) == i386 ]]; then
		echo "%F{244}%F{blue}(intel)%F{reset} "
	fi
}

zsh_terraform() {
	[[ -d .terraform ]] || return

	if (( $+commands[terraform] )); then
		local tf_workspace=$(terraform workspace show)
		echo -n "%F{105}🛠 $tf_workspace%F{reset}"
	else
		return
	fi
}

prompt_node() {
	[[ -f package.json || -d node_modules || -n *.js(#qN^/) ]] || return

	local 'node_version'

	if (( $+commands[node] )); then
		node_version=$(node -v 2>/dev/null)
	else
		return
	fi

	echo -n "%F{green}⬢ $node_version%F{reset}"
}

prompt_char() {
	local 'color'

	if [[ $RETVAL -eq 0 ]]; then
		color="green"
	else
		color="red"
	fi

	echo -n "%F{blue}❯%f%F{cyan}❯%f%F{green}❯%f"

}

ZSH_GIT_PROMPT_FORCE_BLANK=1
ZSH_GIT_PROMPT_SHOW_UPSTREAM="full"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="›"
ZSH_THEME_GIT_PROMPT_SEPARATOR=" ‹"
ZSH_THEME_GIT_PROMPT_BRANCH="⎇ %{$fg_bold[cyan]%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SYMBOL="%{$fg_bold[yellow]%}⟳ "
ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[yellow]%} ⤳ "
ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_no_bold[cyan]%}:"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_no_bold[cyan]%}↓"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_no_bold[cyan]%}↑"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}✖"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}✚"
ZSH_THEME_GIT_PROMPT_UNTRACKED="…"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}⚑"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✔"

PROMPT_USER="$(username)$(server)$(architecture)"

PROMPT=$'\n┏╸$PROMPT_USER%(?..%F{red}%?%f · )%B%~%b\n┗╸$(zsh_terraform) $(prompt_node) $(prompt_char) '
RPROMPT='$(gitprompt)'

