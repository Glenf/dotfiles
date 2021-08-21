#!/usr/bin/env zsh

DOTFILES=$HOME/.dotfiles
GREP_EXCLUDE_DIR="{.git,.sass-cache,artwork,node_modules,vendor}"
OS=`uname`

path=($DOTFILES/bin $path)

source $DOTFILES/vendor/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundle git
antigen bundle asdf

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-history-substring-search

antigen bundle darvid/zsh-poetry
antigen bundle woefe/git-prompt.zsh

# This has to be the last plugin to import
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

unalias -m "*"

export CLICOLOR=1
export EDITOR=nvim
export KEYTIMEOUT=1
export QUOTING_STYLE=literal
export TERM=xterm-256color

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

## VIM to NVIM
alias vim=nvim

## Rosetta
alias rosetta="arch -x86_64 /bin/zsh"



# open ~/.zshrc in using the default editor specified in $EDITOR
alias ec="$EDITOR $HOME/.zshrc"

# source ~/.zshrc
alias sc="source $HOME/.zshrc"

# -------------------------------------------------------------------
# Python
# -------------------------------------------------------------------

# export PATH="$HOME/.pyenv/bin:$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "$(pyenv init -)"
# fi

# python3 Alias
alias python="python3"

# pipx
export PATH="$PATH:$HOME/.local/bin"

export PATH="$PATH:$HOME/bin:$HOME/.poetry/bin"

# # Numpy fix
# export OPENBLAS=$(brew --prefix openblas)
# export CFLAGS="-falign-functions=8 ${CFLAGS}"

# -------------------------------------------------------------------
# ASDF things
# -------------------------------------------------------------------

# . /opt/homebrew/opt/asdf/asdf.sh

# Hook direnv into your shell.
eval "$(asdf exec direnv hook zsh)"

# A shortcut for asdf managed direnv.
direnv() { asdf exec direnv "$@"; }

# Workman - QWERTY mapping
alias asht="asdf"

# -------------------------------------------------------------------
# Docker and Kubernetes
# -------------------------------------------------------------------

# Kubernetes completion
source <(kubectl completion zsh)

## Docker & Docker Compose aliases
alias dcu="docker compose up -d"
alias dcr="docker compose run --rm"
alias dcd="docker compose down"
alias dlogs="docker logs -f"

# -------------------------------------------------------------------
# Prompt
# -------------------------------------------------------------------

function username() {
  # if [[ `whoami` != 'tommi' ]]; then
    echo "%F{248}%n%F{reset}"
  # fi
}

function server() {
  if [[ `hostname` != tommi-* ]]; then
    echo "%F{244}@%F{magenta}%m%F{reset} "
  fi
}

function architecture() {
  if [[ `arch` == i386 ]]; then
    echo "%F{244}%F{blue}(intel)%F{reset} "
  fi
}

zsh_terraform() {
  # break if there is no .terraform directory
  if [[ -d .terraform ]]; then
    local tf_workspace=$(terraform workspace show)
    echo -n "Tf %F{green}$tf_workspace%F{reset}"
  fi
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

PROMPT=$'\n┏╸$PROMPT_USER%(?..%F{red}%?%f · )%B%~%b\n┗╸$(zsh_terraform) %F{blue}❯%f%F{cyan}❯%f%F{green}❯%f '
RPROMPT='$(gitprompt)'
