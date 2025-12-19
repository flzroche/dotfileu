source "$HOME/dotfileu/.alias"
source "$HOME/dotfileu/.exVPSAlias"

autoload -Uz compinit
compinit

export DOTS="$HOME/dotfilem"
export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GEMINI_API_KEY='AIzaSyC4HIwuiHBdYrJRlT2n8aU0L_PpVNEhMxo'
export GOOGLE_API_KEY='AIzaSyC4HIwuiHBdYrJRlT2n8aU0L_PpVNEhMxo'
export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GEMINI_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export GOOGLE_API_KEY='AIzaSyCnRTcycTi1hgzazmbOw0zGtJ0BHRkxdZY'
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR='nvim'
export VISUAL='nvim'
export GITDIR="$HOME/gD"
unset LC_TIME
export LC_TIME=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

# Homebrew ではなく手動クローン or パッケージ前提のパスに変更

source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"





