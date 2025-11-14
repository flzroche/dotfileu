# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/roche/.zsh/completions:"* ]]; then export FPATH="/Users/roche/.zsh/completions:$FPATH"; fi
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
FPATH=/opt/homebrew/share/zsh-completions:$FPATH
FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
source "$HOME/dotfilem/funcs"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
FPATH=/opt/homebrew/share/zsh-completions:$FPATH
FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
source "$HOME/dotfileu/.alias"
source "$HOME/dotfileu/.exVPSAlias"
# source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

autoload -Uz compinit
compinit

export DOTS="$HOME/dotfilem"
export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GEMINI_API_KEY='AIzaSyC4HIwuiHBdYrJRlT2n8aU0L_PpVNEhMxo'
export GOOGLE_API_KEY='AIzaSyC4HIwuiHBdYrJRlT2n8aU0L_PpVNEhMxo'
autoload -Uz compinit
compinit

export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GEMINI_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export GOOGLE_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export XDGkCONFIG_HOME="$HOME/.config"
export EDITOR='nvim'
export VISUAL='nvim'
export GITDIR="$HOME/gD"
unset LC_TIME
export LC_TIME=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

source "$DOTS/funcs"
source ~/dotfilem/.alias
# source ~/dotfilem/.aliasExternal
source ~/scripts/timer.sh
# source "$GITDIR/antigen/antigen.zsh"

### Arc Browserが開かれている場合にタブに検索結果を表示する
source ~/scripts/webSearch.zsh

setopt AUTO_CD

# zstyle ':completion:*' menu yes select
autoload -U compinit


source ~/dotfilem/.alias
# source ~/dotfilem/.aliasExternal
source ~/scripts/timer.sh
# source "$GITDIR/antigen/antigen.zsh"

### Arc Browserが開かれている場合にタブに検索結果を表示する
source ~/scripts/webSearch.zsh

setopt AUTO_CD

# zstyle ':completion:*' menu yes select
autoload -U compinit


eval "$(zoxide init zsh)"
eval "$(starship init zsh)"



# Enable zsh-autosuggestions
source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Enable zsh-syntax-highlighting
source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/roche/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/roche/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/completion.zsh.inc'; fi
. "/Users/roche/.deno/env"


# Enable zsh-autosuggestions
source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Enable zsh-syntax-highlighting
source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/roche/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/roche/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/completion.zsh.inc'; fi
