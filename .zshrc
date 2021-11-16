######################################
# oh-my-zsh Setup
######################################

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=skw

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh


######################################
# General Terminal Setup
######################################

# export MANPATH="/usr/local/man:$MANPATH"

# Set environment language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# Editor
export EDITOR="vim"

# Colors for `ls`
# Arch
# export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'
# macOS
export CLICOLOR=1
export LSCOLORS="gxBxhxDxfxhxhxhxhxcxcx"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"


######################################
# Functions
######################################

# Move to specified directory and open it in Vim.
function vim_open {
    z $1 && vim .
}


######################################
# Aliases
######################################

# Better QoL for common commands
# Arch # alias ff="firefox &"
alias grep="grep -n" # Display line numbers
# Arch # alias ls="ls --color -F" # Distinguish file types
alias ls="ls -F" # Distinguish file types
alias rm="rm -i" # Warn about deletion by default
alias gdb="gdb -tui" # Open `gdb` UI by default
alias python="python3" # Use python3 by default
alias pip="pip3" # Use pip3 by default

# Shortcuts
alias trc="vi ~/.alacritty.yml" # "Terminal rc"
alias vrc="vi ~/.vimrc"
alias zource="source ~/.zshrc"
alias zrc="vi ~/.zshrc"

# Manage dotfiles
alias dotf="git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME"

alias v="vim_open"

alias nrd="npm run dev"
alias nrs="npm run start"

alias ys="yarn start"

# Git
alias gaa="git add --all -p"
alias gcv="git commit --no-verify"
alias gca="git commit --amend"
alias gcam="git commit --amend --no-edit"
alias gcva="git commit --no-verify --amend --no-edit"
alias gcap="gca && gp -f"
alias gdc="git diff --cached"
alias gdp="git-diff-prev"   # Diff between commit and its parent
alias gl="git pull -p"
alias glg="git-pretty-log"  # h/t Gary Bernhardt
alias gpf="git push -f"
alias gpo="git-quick-push"  # push to upstream with current branch name
alias gr="git-easy-rebase"  # update specified branch then rebase onto


######################################
# Environment
######################################

export CC="clang" # Use `clang` to compile C

# use Java 1.8
# export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_212.jdk/Contents/Home"

# Android SDK setup
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Load `rvm` into a shell session *as a function*
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# [[ "$APP" = *"/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/"* ]] && {
#   echo Xcode detected
#   rvm use system
# }

# MongoDB
export MONGODB_URI=""

# npm
export NPM_TOKEN=""

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


######################################
# Binaries
######################################

. /$HOME/bin/z/z.sh # `z` directory changer

# Personal bin
export PATH="/$HOME/bin:$PATH"

# Homebrew
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
# export PATH="/usr/local/opt/ruby/bin:$PATH" # Ruby
# export PATH="/usr/local/opt/postgresql@12/bin:$PATH" # Postgres
# export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH" # GNU grep

# Use system installation of Ruby for Xcode .ipa building
# export PATH="$PATH:$HOME/.rvm/bin" # add `rvm` to PATH for scripting

# Cargo
# export PATH="$HOME/.cargo/bin:$PATH"

# Yarn
export PATH="$(yarn global bin):$PATH"

# Arch
# source /usr/local/bin/z/z.sh
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
