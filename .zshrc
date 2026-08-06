# ==============================================================================
# 1. dotfiles の s なのか m なのか u なのか判別
# ==============================================================================
# eval "$(/opt/homebrew/bin/brew shellenv)Vkkk
# 既存の DOTFILES_DIR 設定を削除（重複防止）
sed -i '/^DOTFILES_DIR=/d' ~/.zshrc

# 新しい設定を先頭に追加
# cat << 'EOF' | tee -a ~/.zshrc > /dev/null

# 自動検出された dotfiles ディレクトリ
DOTFILES_DIR=$(find "$HOME" -maxdepth 1 -type d -name 'dotfile[a-zA-Z]' | head -n1)
[ -n "$DOTFILES_DIR" ] && export DOTFILES_DIR

# ==============================================================================
# 2. Environment Variables (環境変数・APIキー)
# ==============================================================================
# Editor

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# Locale & Language
unset LC_TIME
export LC_TIME=ja_JP.UTF-8
export LANG=ja_JP.UTF-8

# Directories
export XDG_CONFIG_HOME="$HOME/.config"
export DOTS="$HOME/dotfileu"
export ENDSH="$HOME/endOfScripts:$HOME/endsh"
export GITDIR="$HOME/gD"

# Ruby Gems
export GEM_HOME="$HOME/gems"

# ==============================================================================
# 3. PATH Configuration (パスの設定)
# ==============================================================================
# パスの重複を防ぐ設定
typeset -U path

path=(
  # Ruby & Gems
  $GEM_HOME/bin
  $HOME/.rbenv/bin

  # Development Tools
  $HOME/.pyenv/shims
  $HOME/.cargo/bin

  # Homebrew
  /opt/homebrew/opt
  /opt/homebrew/bin

  # Android SDK
  /Library/Android/sdk

  # Personal Directories
  $HOME/bin
  $HOME/.local/bin
  $HOME/scripts
  $HOME/.config/emacs/bin

  # 既存のパスを保持
  $path
)
export PATH

# ==============================================================================
# 4. Tool Initializations (ツールの初期化)
# ==============================================================================
eval "$(rbenv init - zsh)"
# eval "$(pyenv init - zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# ==============================================================================
# 5. Zsh Settings & Completions (基本設定・補完)
# ==============================================================================
setopt AUTO_CD

autoload -Uz compinit
compinit

# ==============================================================================
# 6. User Scripts & Aliases (独自スクリプトの読み込み)
# ==============================================================================
source "./.alias"

# ==============================================================================
# 7. Zsh Plugins (プラグイン)
# ※シンタックスハイライトは必ず最後に読み込む
# ==============================================================================
# --- 一番最後にプラグインを読み込む ---
#source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#
