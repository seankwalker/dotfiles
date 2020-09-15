# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/skw/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# Dotfile management
# Manage the ~ working tree but from a repository in ~/.dotfiles for cleanliness
alias dotf='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias zource='source ~/.zshrc'
