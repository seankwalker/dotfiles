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
plugins=(git macos)

. $ZSH/oh-my-zsh.sh

# Secrets
# Not tracked in dotfiles because...duh.....
. $HOME/.env


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

# Automatically start tmux, if: it exists, the shell is interactive, and this
# is not being evaluated in an exisiting session.
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] \
        && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi


######################################
# Functions
######################################

# Move to specified directory and open it in Vim.
function vim_open {
    _z $1 && vim .
}

# Check which port a process is listening on OR which process is listening on
# a port.
# h/t https://stackoverflow.com/a/30029855
function listening {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

function api_logs {
    if [ $# -eq 0 ]; then
        echo "Usage: api_logs pod_name"
    else
        kubectl logs $1 --namespace api | jq -R --color-output 'fromjson? | .' | less -R
    fi
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
alias yt="yarn test:local --coverage=false"
alias tf="terraform"

# Shortcuts
alias trc="vi ~/.config/ghostty/config" # "Terminal rc"
alias vrc="vi ~/.vimrc"
alias zource=". ~/.zshrc"
alias zrc="vi ~/.zshrc"
alias ghb="GH_TOKEN=$GH_TOKEN_BRANDON gh"
# alias ide="open /Applications/Cursor.app/"

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
alias grc="git rebase --continue"
alias gs="git stash"
alias gdf="git-per-file-diff"


######################################
# Environment
######################################

export CC="clang" # Use `clang` to compile C

# Use Java 11 (Homebrew, zulu17)
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# Android SDK setup
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/ndk-bundle

# Load `rvm` into a shell session *as a function*
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
# [[ "$APP" = *"/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/"* ]] && {
#   echo Xcode detected
#   rvm use system
# }

# MongoDB
#export MONGODB_URI="" # defined in .env

# npm
#export NPM_TOKEN="" # defined in .env

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


######################################
# Binaries
######################################

# Personal bin
export PATH="/$HOME/bin:$PATH"

# Homebrew
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/opt/redis@4.0/bin:$PATH" # Redis 4.0.x
export PATH="/usr/local/opt/ruby/bin:$PATH" # Ruby 3.x
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
# export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH" # GNU grep

# Use system installation of Ruby for Xcode .ipa building
# export PATH="$PATH:$HOME/.rvm/bin" # add `rvm` to PATH for scripting

# Cargo
# export PATH="$HOME/.cargo/bin:$PATH"

# Yarn
# export PATH="$(yarn global bin):$PATH"

# zsh-syntax-highlighting
# . /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
. /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Arch
# . /usr/local/bin/z/z.sh
# . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# z
. $HOME/bin/z/z.sh

# pipx
export PATH="$PATH:/Users/seankwalker/.local/bin"

# poetry
export PATH="/Users/sean/.local/bin:$PATH"

# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/sean/.zsh/completions:"* ]]; then export FPATH="/Users/sean/.zsh/completions:$FPATH"; fi

setopt INC_APPEND_HISTORY

# pnpm
export PNPM_HOME="/Users/sean/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(mise activate zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sean/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sean/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sean/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sean/google-cloud-sdk/completion.zsh.inc'; fi
