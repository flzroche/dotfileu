#!/usr/bin/env bash

# =====================================================================# クロスラットフォーム設定 ＆ CLIツールインストーラスクリプト
# 対応OS: macOS, Ubuntu, Parrot OS (Debian系), iPad (iSH)
# ==============================================================================

# エラー終了時や中断時にも一時ディレクトリを自動削除
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

DESCRIPTIONS_FILE="$TMP_DIR/descriptions_for_fzf.txt"
UNINSTALLED_FILE="$TMP_DIR/uninstalled_packages_for_all.txt"

DOTFILES_DIR="$HOME/dotfilem"

# --- OS & パッケージマネージャーの判定 ---
OS_TYPE="unknown"
PKG_MGR="unknown"

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
  OS_TYPE="linux"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    # Ubuntu, Debian, Parrot OS等を一括でapt系として判定
    [[ "$ID" == "ubuntu" || "$ID" == "parrot" || "$ID_LIKE" == *"ubuntu"* || "$ID_LIKE" == *"debian"* ]] && OS_TYPE="debian_based"
    [[ "$ID" == "alpine" ]] && OS_TYPE="alpine"
  fi
elif uname -a 2>/dev/null | grep -qi "ish" || [[ -n "$ISH_VERSION" ]]; then
  OS_TYPE="ish_ipad"
fi

# パッケージマネージャーの自動判定
if command -v brew &> /dev/null; then
  PKG_MGR="brew"
elif command -v apt-get &> /dev/null; then
  PKG_MGR="apt"
elif command -v apk &> /dev/null; then
  PKG_MGR="apk"
elif command -v pkg &> /dev/null; then
  PKG_MGR="pkg"
fi

echo "OS Detected: $OS_TYPE"
echo "Package Manager Detected: $PKG_MGR"
echo "---------------------------------"

if [[ "$PKG_MGR" == "unknown" ]]; then
  echo "⚠️ 判定可能なパッケージマネージャー (brew, apt, apk) が見つかりませんでした。"
  echo "Homebrew または apt などをインストールしてから再実行してください。"
  exit 1
fi

# --- Alacrittyのインストール (GUI環境のみ) ---
if [[ "$OS_TYPE" == "macos" ]] && [[ "$PKG_MGR" == "brew" ]]; then
  echo "Attempting to install or update Alacritty..."
  brew install --cask alacritty &> /dev/null || echo "⚠️ Failed to install Alacritty."
elif [[ "$OS_TYPE" == "debian_based" ]]; then
  if command -v xrandr &> /dev/null || [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "Attempting to install Alacritty on Linux..."
    sudo apt-get update -y && sudo apt-get install -y alacritty &> /dev/null || echo "⚠️ Failed to install Alacritty (パッケージが存在しない可能性があります)."
  else
    echo "ℹ️  CUI環境のため、Alacrittyのインストールをスキップします。"
  fi
else
  echo "ℹ️  GUI非対応環境のため、Alacrittyのインストールをスキップします。"
fi
echo "---------------------------------"

# --- fzfの自動インストール（未インストールの場合） ---
if ! command -v fzf &> /dev/null; then
  echo "fzf is not installed. Installing fzf..."
  case "$PKG_MGR" in
    brew) brew install fzf ;;
    apt)  sudo apt-get update -y && sudo apt-get install -y fzf ;;
    apk)  sudo apk add fzf ;;
    pkg)  pkg install fzf ;;
  esac
fi

# --- ツールのリストと説明 ---
# フォーマット: "コマンド名:brewパッケージ名:aptパッケージ名:説明"
tools_list=(
"zoxide:zoxide:zoxide:より賢いcdコマンド。効率的にディレクトリを移動できます。"
"curl:curl:curl:URL経由でデータを転送するためのコマンドラインツール。"
"bat:bat:bat:シンタックスハイライト機能付きのcat代替コマンド。"
"fd:fd:fd-find:高速で使いやすいfind代替コマンド。"
"eza:eza:eza:lsコマンドのモダンな代替。"
"lsd:lsd:lsd:次世代のlsコマンド。"
"procs:procs:procs:Rustで書かれたpsコマンドのモダンな代替。"
"pastel:pastel:pastel:色の生成、分析、変換、操作を行うコマンドラインツール。"
"ripgrep:ripgrep:ripgrep:正規表現パターンで検索する高速ツール。"
"tmux:tmux:tmux:ターミナルマルチプレクサ。1画面で複数ターミナルを管理。"
"zellij:zellij:zellij:Rust製のモダンなターミナルマルチプレクサ。"
"zsh:zsh:zsh:強力で使いやすいコマンドラインシェル。"
"nvim:neovim:neovim:Vimからのフォーク。拡張性が高くモダンなテキストエディタ(Neovim)。"
)

declare -A pkg_to_install

# --- コマンド存在チェック ---
echo "Checking installed CLI tools..."
ALL_PACKAGES_INSTALLED=true
> "$DESCRIPTIONS_FILE"
> "$UNINSTALLED_FILE"

for item in "${tools_list[@]}"; do
  IFS=':' read -r cmd_name brew_pkg apt_pkg pkg_desc <<< "$item"

  if [[ "$PKG_MGR" == "apt" ]]; then
    pkg_to_install["$cmd_name"]="$apt_pkg"
  else
    pkg_to_install["$cmd_name"]="$brew_pkg"
  fi

  # コマンドのインストール確認 (Ubuntuの batcat / fdfind に対応)
  is_installed=false
  if command -v "$cmd_name" &> /dev/null; then
    is_installed=true
  elif [[ "$cmd_name" == "bat" ]] && command -v batcat &> /dev/null; then
    is_installed=true
  elif [[ "$cmd_name" == "fd" ]] && command -v fdfind &> /dev/null; then
    is_installed=true
  fi

  if $is_installed; then
    echo "${cmd_name}:✅ [インストール済み] ${pkg_desc}" >> "$DESCRIPTIONS_FILE"
  else
    echo "${cmd_name}:${pkg_desc}" >> "$DESCRIPTIONS_FILE"
    echo "$cmd_name" >> "$UNINSTALLED_FILE"
    ALL_PACKAGES_INSTALLED=false
  fi
done

# パッケージインストール処理
if ! $ALL_PACKAGES_INSTALLED; then
  read -p "全ての未インストールコマンドをインストールしますか？ (y/N): " install_all_response
  selected_packages=""

  if [[ "$install_all_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "全ての未インストールコマンドをインストールします。"
    selected_packages=$(cat "$UNINSTALLED_FILE")
  else
    selected_packages=$(cat "$UNINSTALLED_FILE" | fzf --multi \
      --preview "sed -n 's/^{}://p' '$DESCRIPTIONS_FILE'" \
      --prompt="Select packages to install (use TAB to select multiple): ")
  fi

  if [[ -n "$selected_packages" ]]; then
    case "$PKG_MGR" in
      brew) brew update ;;
      apt)  sudo apt-get update -y ;;
      apk)  sudo apk update ;;
    esac

    for cmd in $selected_packages; do
      target_pkg="${pkg_to_install[$cmd]}"
      echo "---------------------------------"
      echo "Installing $cmd (Package: $target_pkg)..."
      
      case "$PKG_MGR" in
        brew) brew install "$target_pkg" || echo "⚠️ $target_pkg のインストールをスキップしました。" ;;
        apt)  
          sudo apt-get install -y "$target_pkg" || echo "⚠️ $target_pkg のインストールをスキップしました。"
          if [[ "$cmd" == "bat" ]] && ! command -v bat &> /dev/null && command -v batcat &> /dev/null; then
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
          fi
          if [[ "$cmd" == "fd" ]] && ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
          fi
          ;;
        apk) sudo apk add "$target_pkg" || echo "⚠️ $target_pkg のインストールをスキップしました。" ;;
        pkg) pkg install "$target_pkg" || echo "⚠️ $target_pkg のインストールをスキップしました。" ;;
      esac
    done

    # --- インストール後の設定案内 ---
    echo -e "\n--- Post-installation notes ---"
    if [[ "$selected_packages" == *"zoxide"* ]]; then
      echo "✅ For 'zoxide' to work, add this line to your shell config (.zshrc or .bashrc):"
      echo '   eval "$(zoxide init zsh)"  # or bash'
    fi

    if [[ "$selected_packages" == *"zsh"* ]] || command -v zsh &> /dev/null; then
      mkdir -p "$DOTFILES_DIR"
      ZSHRC_SOURCE_FILE="$DOTFILES_DIR/.zshrc"
      touch "$ZSHRC_SOURCE_FILE"

      AUTOSUGGEST_LINE=""
      SYNTAX_LINE=""
      if [[ "$PKG_MGR" == "brew" ]]; then
        brew install zsh-autosuggestions zsh-syntax-highlighting &> /dev/null
        BREW_PREFIX=$(brew --prefix)
        AUTOSUGGEST_LINE="source \"${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh\""
        SYNTAX_LINE="source \"${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\""
      elif [[ "$PKG_MGR" == "apt" ]]; then
        sudo apt-get install -y zsh-autosuggestions zsh-syntax-highlighting &> /dev/null
        AUTOSUGGEST_LINE="source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        SYNTAX_LINE="source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      fi

      if [[ -n "$AUTOSUGGEST_LINE" ]]; then
        grep -Fxq -- "$AUTOSUGGEST_LINE" "$ZSHRC_SOURCE_FILE" || echo -e "\n# Enable zsh-autosuggestions\n$AUTOSUGGEST_LINE" >> "$ZSHRC_SOURCE_FILE"
        grep -Fxq -- "$SYNTAX_LINE" "$ZSHRC_SOURCE_FILE" || echo -e "\n# Enable zsh-syntax-highlighting\n$SYNTAX_LINE" >> "$ZSHRC_SOURCE_FILE"
      fi

      CURRENT_ZSH=$(command -v zsh)
      if [[ -n "$CURRENT_ZSH" ]] && [[ "$SHELL" != "$CURRENT_ZSH" ]]; then
        read -p "✅ 'zsh' をデフォルトシェルに変更しますか？ (y/N): " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          if ! grep -Fxq "$CURRENT_ZSH" /etc/shells 2>/dev/null; then
            echo "$CURRENT_ZSH" | sudo tee -a /etc/shells &> /dev/null
          fi
          chsh -s "$CURRENT_ZSH"
          echo "デフォルトシェルを変更しました。再ログイン後に反映されます。"
        fi
      fi
    fi
  else
    echo "No packages selected for installation."
  fi
else
  echo "全てのコマンド及びパッケージはインストール済みです。"
fi

# ==============================================================================
# シンボリックリンクの生成処理
# ==============================================================================
echo -e "\n---------------------------------"
echo "Dotfiles (設定ファイル) のシンボリックリンク設定を開始します。"

# OSによるEspansoのパス切り分け
ESPANSO_DIR="$HOME/.config/espanso/match"
if [[ "$OS_TYPE" == "macos" ]]; then
  ESPANSO_DIR="$HOME/Library/Application Support/espanso/match"
fi

files_to_remove=(
  "$HOME/.config/starship.toml"
  "$HOME/.config/alacritty/alacritty.toml"
  "$HOME/.config/wezterm/wezterm.lua"
  "$HOME/.config/wezterm/keybind.lua"
  "$HOME/.zshrc"
  "$ESPANSO_DIR/addSnpt.yml"
  "$ESPANSO_DIR/addSnpt_Secret.yml"
  "$HOME/.config/nvim/init.lua"
  "$HOME/.config/nvim/lua/indent.lua"
  "$HOME/.config/zellij/config.kdl"
)

echo "以下のシンボリックリンク(またはファイル)を削除し、再作成します:"
for file in "${files_to_remove[@]}"; do
  echo "- $file"
done
echo ""

read -r -p "シンボリックリンクを作成・更新しますか？ (y/Y/Enter=yes, n/N=no): " symlink_response
case "$symlink_response" in
  [yY]|"")
    echo "Starting symlink setup..."

    # 古いリンク・ファイルの削除
    for file in "${files_to_remove[@]}"; do
      rm -f "$file"
    done

    # 必要なディレクトリの作成
    echo "Creating directories if they don't exist..."
    mkdir -p "$HOME/.config/alacritty"
    mkdir -p "$HOME/.config/nvim/lua"
    mkdir -p "$HOME/.config/zellij"
    mkdir -p "$HOME/.config/wezterm"
    mkdir -p "$ESPANSO_DIR"

    # シンボリックリンクの作成
    echo "Creating symbolic links..."
    ln -s "$DOTFILES_DIR/starship.toml"        "$HOME/.config/starship.toml"
    ln -s "$DOTFILES_DIR/alacritty.toml"       "$HOME/.config/alacritty/alacritty.toml"
    ln -s "$DOTFILES_DIR/wezterm.lua"          "$HOME/.config/wezterm/wezterm.lua"
    ln -s "$DOTFILES_DIR/keybind.lua"          "$HOME/.config/wezterm/keybind.lua"
    ln -s "$DOTFILES_DIR/.zshrc"               "$HOME/.zshrc"
    ln -s "$DOTFILES_DIR/addSnpt.yml"          "$ESPANSO_DIR/addSnpt.yml"
    ln -s "$DOTFILES_DIR/addSnpt_Secret.yml"   "$ESPANSO_DIR/addSnpt_Secret.yml"
    ln -s "$DOTFILES_DIR/init.lua"             "$HOME/.config/nvim/init.lua"
    ln -s "$DOTFILES_DIR/indent.lua"           "$HOME/.config/nvim/lua/indent.lua"
    ln -s "$DOTFILES_DIR/zjconfig.kdl"         "$HOME/.config/zellij/config.kdl"

    echo "✅ Symbolic links created successfully."
    ;;
  *)
    echo "Symlink setup skipped."
    ;;
esac

echo "---------------------------------"
echo "🎉 全ての処理が正常に終了しました。"
