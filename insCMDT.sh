#!/usr/bin/env bash

# --- macOS用CLIツールインストーラスクリプト ---

# Homebrewがインストールされているか確認し、なければ終了
if ! command -v brew &> /dev/null; then
  echo "Homebrew is not installed. Please install it first from https://brew.sh/"
  exit 1
fi


# --- Alacrittyの強制インストール/アップデート ---
echo "Attempting to install or update Alacritty..."
if brew install --cask alacritty; then
    echo "✅ Alacritty has been successfully installed or updated."
else
    echo "⚠️ Failed to install Alacritty."
fi
echo "---------------------------------"


# fzfがインストールされているか確認し、なければインストール
if ! brew list fzf &> /dev/null; then
  echo "fzf is not installed. Installing fzf first..."
  brew install fzf
fi

if ! command -v zsh &> /dev/null; then
  echo "ZSH is not installed. You can install it using the shell script currently running, so please be sure to execute it. There is also an option to install all tools at once."
  exit 1
fi

# --- ツールのリストと説明 ---
# フォーマット: "パッケージ名:種別(formula/cask):説明"
tools_list=(
"visual-studio-code:cask:高機能なコードエディタ(VSCode)"
"gemini-cli:formula:Google Gemini APIと対話するためのCLIツール"
"zoxide:formula:より賢いcdコマンド。効率的にディレクトリを移動できます。"
"curl:formula:URL経由でデータを転送するためのコマンドラインツール。(通常プリインストール済み、更新可能)"
"bat:formula:シンタックスハイライト機能付きのcat代替コマンド。"
"fd:formula:高速で使いやすいfind代替コマンド。"
"fzf:formula:対話的な選択が可能なコマンドラインファジーファインダー。"
"eza:formula:lsコマンドのモダンな代替。"
"lsd:formula:次世代のlsコマンド。"
"procs:formula:Rustで書かれたpsコマンドのモダンな代替。"
"pastel:formula:色の生成、分析、変換、操作を行うコマンドラインツール。"
"ripgrep:formula:正規表現パターンでカレントディレクトリを再帰的に検索する行指向の検索ツール。"
"tmux:formula:ターミナルマルチプレクサ。1つの画面で複数のターミナルを管理。"
"zellij:formula:Rust製のモダンなターミナルマルチプレクサ。より使いやすい機能を提供。"
"zsh:formula:強力で使いやすいコマンドラインシェル。"
)

# パッケージの種別を保存するための連想配列
declare -A pkg_types

# --- 高速化のための変更点 ---
# 1. Homebrewでインストール済みの全パッケージを一度に取得
echo "Checking installed Homebrew packages..."
INSTALLED_BREW_PACKAGES=$(brew list) # Formulae
INSTALLED_BREW_CASKS=$(brew list --cask)  # Casks

# 未インストールパッケージの有無をチェックするためのフラグ
ALL_PACKAGES_INSTALLED=true


# 一時的な説明ファイルを作成し、未インストールツールのみを記述
> descriptions_for_fzf.txt # fzfの選択肢用
> uninstalled_packages_for_all.txt

for item in "${tools_list[@]}"; do
  pkg_name=$(echo "$item" | cut -d':' -f1)
  pkg_type=$(echo "$item" | cut -d':' -f2)
  pkg_desc=$(echo "$item" | cut -d':' -f3-)
  pkg_types["$pkg_name"]="$pkg_type" # インストール用に種別を保存

  is_installed=false
  if [[ "$pkg_type" == "cask" ]]; then
    if echo "$INSTALLED_BREW_CASKS" | grep -qw "$pkg_name"; then
      is_installed=true
    fi
  else
    if echo "$INSTALLED_BREW_PACKAGES" | grep -qw "$pkg_name"; then
      is_installed=true
    fi
  fi

  if $is_installed; then
    # インストール済みだが、fzfのプレビューで表示するためにdescriptionファイルには残しておく
    echo "${pkg_name}:✅ [インストール済み] ${pkg_desc}" >> descriptions_for_fzf.txt
  else
    echo "${pkg_name}:${pkg_desc}" >> descriptions_for_fzf.txt # 未インストールはfzfの選択肢にもプレビューにも
    echo "$pkg_name" >> uninstalled_packages_for_all.txt # 未インストールリストに追加
    ALL_PACKAGES_INSTALLED=false # 未インストールパッケージが見つかった
  fi
done

# 全てのパッケージがインストール済みであれば、ここで早期終了
if "$ALL_PACKAGES_INSTALLED"; then
  echo "全てのコマンド及びパッケージはインストール済みです。"
  rm descriptions_for_fzf.txt uninstalled_packages_for_all.txt
  exit 0
fi

# 未インストールコマンドを全てインストールするオプション
read -p "全ての未インストールコマンドをインストールしますか？ (y/N): " install_all_response
selected_packages=""

if [[ "$install_all_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "全ての未インストールコマンドをインストールします。"
  selected_packages=$(cat uninstalled_packages_for_all.txt)
else
  # fzf を使ってパッケージ選択（プレビュー付き）
  selected_packages=$(cat uninstalled_packages_for_all.txt | fzf --multi \
    --preview "awk -F ':' -v pkg='{}' '{if (\$1 == pkg) print \$2}' descriptions_for_fzf.txt" \
    --prompt="Select packages to install (use TAB to select multiple): ")
fi

# 選択されたパッケージがあればインストール処理を開始
if [[ -n "$selected_packages" ]]; then
  echo "Updating Homebrew..."
  brew update

  for pkg in $selected_packages; do
    echo "---------------------------------"
    echo "Installing $pkg..."
    if [[ "${pkg_types[$pkg]}" == "cask" ]]; then
      brew install --cask "$pkg"
    else
      brew install "$pkg"
    fi
  done

  # --- インストール後の補足情報 ---
  echo -e "\n--- Post-installation notes ---"
  # 'selected_packages' の中に 'zoxide' が含まれているかチェック
  if [[ "$selected_packages" == *"zoxide"* ]]; then
    echo "✅ For 'zoxide' to work, you need to add the following line to your shell configuration file (.zshrc, .bash_profile, etc.):"
    echo '   eval "$(zoxide init zsh)"'
    echo "   or for bash:"
    echo '   eval "$(zoxide init bash)"'
    echo "   Then, restart your shell."
  fi
  # 'selected_packages' の中に 'zsh' が含まれているかチェック
  if [[ "$selected_packages" == *"zsh"* ]]; then
    echo "✅ Installing/updating zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)..."
    brew install zsh-autosuggestions zsh-syntax-highlighting

    # --- .zshrcにプラグインの設定を追記 ---
    echo "✅ Configuring zsh plugins in ~/dotfilem/.zshrc..."

    # dotfileディレクトリと.zshrcのパスを定義
    DOTFILES_DIR="$HOME/dotfilem"
    ZSHRC_SOURCE_FILE="$DOTFILES_DIR/.zshrc"
    ZSHRC_SYMLINK_TARGET="$HOME/.zshrc"

    # dotfileディレクトリがなければ作成
    mkdir -p "$DOTFILES_DIR"

    # .zshrcがなければ作成
    touch "$ZSHRC_SOURCE_FILE"

    # プラグインのパスを定義
    BREW_PREFIX=$(brew --prefix)
    AUTOSUGGESTIONS_PATH="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    SYNTAX_HIGHLIGHTING_PATH="$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # 追加する行を定義
    AUTOSUGGEST_LINE="source \"${AUTOSUGGESTIONS_PATH}\""
    SYNTAX_LINE="source \"${SYNTAX_HIGHLIGHTING_PATH}\""

    # zsh-autosuggestions の設定を追記
    if ! grep -Fxq -- "$AUTOSUGGEST_LINE" "$ZSHRC_SOURCE_FILE"; then
      echo -e "\n# Enable zsh-autosuggestions" >> "$ZSHRC_SOURCE_FILE"
      echo "$AUTOSUGGEST_LINE" >> "$ZSHRC_SOURCE_FILE"
      echo "   Added zsh-autosuggestions to $ZSHRC_SOURCE_FILE"
    else
      echo "   zsh-autosuggestions already configured in $ZSHRC_SOURCE_FILE"
    fi

    # zsh-syntax-highlighting の設定を追記
    if ! grep -Fxq -- "$SYNTAX_LINE" "$ZSHRC_SOURCE_FILE"; then
      echo -e "\n# Enable zsh-syntax-highlighting" >> "$ZSHRC_SOURCE_FILE"
      echo "$SYNTAX_LINE" >> "$ZSHRC_SOURCE_FILE"
      echo "   Added zsh-syntax-highlighting to $ZSHRC_SOURCE_FILE"
    else
      echo "   zsh-syntax-highlighting already configured in $ZSHRC_SOURCE_FILE"
    fi

    # ~/.zshrc のシンボリックリンクを管理
    if [ ! -e "$ZSHRC_SYMLINK_TARGET" ]; then
        echo "✅ Creating symbolic link: $ZSHRC_SYMLINK_TARGET -> $ZSHRC_SOURCE_FILE"
        ln -s "$ZSHRC_SOURCE_FILE" "$ZSHRC_SYMLINK_TARGET"
        echo "   Symbolic link created."
    elif [ -L "$ZSHRC_SYMLINK_TARGET" ] && [ "$(readlink "$ZSHRC_SYMLINK_TARGET")" == "$ZSHRC_SOURCE_FILE" ]; then
        echo "✅ Symbolic link already exists and is correct."
    else
        echo "⚠️  $ZSHRC_SYMLINK_TARGET already exists but is not the expected symbolic link. Please check your configuration manually."
    fi

    BREW_ZSH_PATH=$(brew --prefix)/bin/zsh
    if [[ -f "$BREW_ZSH_PATH" ]]; then
      # 現在のシェルがHomebrewのZshでない場合にのみプロンプトを表示
      if [[ "$SHELL" != "$BREW_ZSH_PATH" ]]; then
        read -p "✅ 'zsh'をデフォルトのシェルに変更しますか？(推奨) (y/N): " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          # /etc/shells にBrew Zshのパスがなければ追記
          if ! grep -Fxq "$BREW_ZSH_PATH" /etc/shells; then
            echo "HomebrewのZshを信頼できるシェルリストに追加します。パスワードが必要です。"
            echo "$BREW_ZSH_PATH" | sudo tee -a /etc/shells
          fi
          echo "デフォルトシェルを変更します..."
          chsh -s "$BREW_ZSH_PATH"
          echo "シェルを変更しました。ターミナルを再起動すると有効になります。"
        else
          echo "シェルの変更はスキップしました。"
        fi
      else
        echo "✅ 'zsh' は既にデフォルトのシェルです。"
      fi
    fi
  fi
  echo "---------------------------------"

else
  echo "No packages selected. Exiting..."
fi

# 一時的に作成したファイルを削除
rm descriptions_for_fzf.txt
rm uninstalled_packages_for_all.txt

echo "Scriptは正常に終了"


