source "$HOME/dotfilem/funcs"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
FPATH=/opt/homebrew/share/zsh-completions:$FPATH
FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH

autoload -Uz compinit
compinit

export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GEMINI_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export GOOGLE_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export XDGkCONFIG_HOME="$HOME/.config"
export PATH="$HOME/.pyenv/shims:$HOME/.cargo/bin:/opt/homebrew/opt:/opt/homebrew/bin:/Library/Android/sdk:$HOME/bin:$HOME/.local/bin:$HOME/scripts:$PATH"
export EDITOR='vim'
export VISUAL='vim'

# 自分でGitCloneする場合は下記ディレクトリにて実行する
unset LC_TIME
export LC_TIME=ja_JP.UTF-8
export GITDIR="$HOME/gD"

export LANG=ja_JP.UTF-8

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
# eval "$(mise activate zsh)"
eval "$(starship init zsh)"
# eval "$(~/.local/bin/mise activate zsh)"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion



# Enable zsh-autosuggestions
source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Enable zsh-syntax-highlighting
source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/roche/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/roche/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/roche/google-cloud-sdk/completion.zsh.inc'; fi
