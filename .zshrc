source "$HOME/dotfileu/.alias"
source "$HOME/dotfileu/.exVPSAlias"
source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

export XDGkCONFIG_HOME="$HOME/.config"
export EDITOR='nvim'
export VISUAL='nvim'
export GITDIR="$HOME/gD"
unset LC_TIME
export LC_TIME=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

