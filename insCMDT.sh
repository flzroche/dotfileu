#!/usr/bin/env bash

# --- Ubuntu用 CLI ツールインストーラスクリプト (apt 版) ---

# fzf がインストールされているか確認し、なければインストール
if ! command -v fzf &> /dev/null; then
  echo "fzf is not installed. Installing fzf first..."
  sudo apt update
  sudo apt install -y fzf
fi

# zsh が無ければインストール（元スクリプトの挙動に近づけるなら exit でもOK）
if ! command -v zsh &> /dev/null; then
  echo "ZSH is not installed. Installing zsh..."
  sudo apt update
  sudo apt install -y zsh
fi

# --- ツールのリストと説明 ---
# フォーマット: "パッケージ名:種別(aptのみなので常にapt):説明"
tools_list=(
"zoxide:apt:より賢いcdコマンド。効率的にディレクトリを移動できます。"
"curl:apt:URL経由でデータを転送するためのコマンドラインツール。(通常プリインストール済み、更新可能)"
"bat:apt:シンタックスハイライト機能付きのcat代替コマンド。（Debian系では batcat 名の場合あり）"
"fd-find:apt:高速で使いやすいfind代替コマンド。（コマンド名は fd-find または fd）"
"fzf:apt:対話的な選択が可能なコマンドラインファジーファインダー。"
"eza:apt:lsコマンドのモダンな代替。（PPAや別途リポジトリが必要な場合あり）"
"lsd:apt:次世代のlsコマンド。（PPAや別途リポジトリが必要な場合あり）"
"procs:apt:Rustで書かれたpsコマンドのモダンな代替。"
"pastel:apt:色の生成、分析、変換、操作を行うコマンドラインツール。"
"ripgrep:apt:正規表現パターンでカレントディレクトリを再帰的に検索する行指向の検索ツール。"
"zsh:apt:強力で使いやすいコマンドラインシェル。"
)

# パッケージの種別を保存するための連想配列（形式維持のため）
declare -A pkg_types

echo "Checking installed APT packages..."
ALL_PACKAGES_INSTALLED=true

> descriptions_for_fzf.txt
> uninstalled_packages_for_all.txt

for item in "${tools_list[@]}"; do
  pkg_name=$(echo "$item" | cut -d':' -f1)
  pkg_type=$(echo "$item" | cut -d':' -f2)
  pkg_desc=$(echo "$item" | cut -d':' -f3-)
  pkg_types["$pkg_name"]="$pkg_type"

  # dpkg -s でインストール状況を確認
  if dpkg -s "$pkg_name" &> /dev/null; then
    echo "${pkg_name}:✅ [インストール済み] ${pkg_desc}" >> descriptions_for_fzf.txt
  else
    echo "${pkg_name}:${pkg_desc}" >> descriptions_for_fzf.txt
    echo "$pkg_name" >> uninstalled_packages_for_all.txt
    ALL_PACKAGES_INSTALLED=false
  fi
done

if "$ALL_PACKAGES_INSTALLED"; then
  echo "全てのコマンド及びパッケージはインストール済みです。"
  rm descriptions_for_fzf.txt uninstalled_packages_for_all.txt
  exit 0
fi

read -p "全ての未インストールコマンドをインストールしますか？ (y/N): " install_all_response
selected_packages=""

if [[ "$install_all_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "全ての未インストールコマンドをインストールします。"
  selected_packages=$(cat uninstalled_packages_for_all.txt)
else
  selected_packages=$(cat uninstalled_packages_for_all.txt | fzf --multi \
    --preview "awk -F ':' -v pkg='{}' '{if (\$1 == pkg) print \$2}' descriptions_for_fzf.txt" \
    --prompt="Select packages to install (use TAB to select multiple): ")
fi

if [[ -n "$selected_packages" ]]; then
  echo "Updating APT package index..."
  sudo apt update

  for pkg in $selected_packages; do
    echo "---------------------------------"
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  done

  echo -e "\n--- Post-installation notes ---"

  if [[ "$selected_packages" == *"zoxide"* ]]; then
    echo "✅ For 'zoxide' to work, you need to add the following line to your shell configuration file (.zshrc, .bashrc, etc.):"
    echo '   eval "$(zoxide init zsh)"'
    echo "   or for bash:"
    echo '   eval "$(zoxide init bash)"'
    echo "   Then, restart your shell."
  fi

  if [[ "$selected_packages" == *"zsh"* ]]; then
    echo "✅ Installing/updating zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)..."
    # Ubuntu ではこれらは apt から導入可能なディストリもある
    sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting

    echo "✅ Configuring zsh plugins in ~/dotfilem/.zshrc..."

    DOTFILES_DIR="$HOME/dotfilem"
    ZSHRC_SOURCE_FILE="$DOTFILES_DIR/.zshrc"
    ZSHRC_SYMLINK_TARGET="$HOME/.zshrc"

    mkdir -p "$DOTFILES_DIR"
    touch "$ZSHRC_SOURCE_FILE"

    # apt 版のパスはディストリによって異なるので代表的な場所を想定
    AUTOSUGGESTIONS_PATH="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    SYNTAX_HIGHLIGHTING_PATH="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    AUTOSUGGEST_LINE="source \"${AUTOSUGGESTIONS_PATH}\""
    SYNTAX_LINE="source \"${SYNTAX_HIGHLIGHTING_PATH}\""

    if ! grep -Fxq -- "$AUTOSUGGEST_LINE" "$ZSHRC_SOURCE_FILE"; then
      echo -e "\n# Enable zsh-autosuggestions" >> "$ZSHRC_SOURCE_FILE"
      echo "$AUTOSUGGEST_LINE" >> "$ZSHRC_SOURCE_FILE"
      echo "   Added zsh-autosuggestions to $ZSHRC_SOURCE_FILE"
    else
      echo "   zsh-autosuggestions already configured in $ZSHRC_SOURCE_FILE"
    fi

    if ! grep -Fxq -- "$SYNTAX_LINE" "$ZSHRC_SOURCE_FILE"; then
      echo -e "\n# Enable zsh-syntax-highlighting" >> "$ZSHRC_SOURCE_FILE"
      echo "$SYNTAX_LINE" >> "$ZSHRC_SOURCE_FILE"
      echo "   Added zsh-syntax-highlighting to $ZSHRC_SOURCE_FILE"
    else
      echo "   zsh-syntax-highlighting already configured in $ZSHRC_SOURCE_FILE"
    fi

    if [ ! -e "$ZSHRC_SYMLINK_TARGET" ]; then
        echo "✅ Creating symbolic link: $ZSHRC_SYMLINK_TARGET -> $ZSHRC_SOURCE_FILE"
        ln -s "$ZSHRC_SOURCE_FILE" "$ZSHRC_SYMLINK_TARGET"
        echo "   Symbolic link created."
    elif [ -L "$ZSHRC_SYMLINK_TARGET" ] && [ "$(readlink "$ZSHRC_SYMLINK_TARGET")" == "$ZSHRC_SOURCE_FILE" ]; then
        echo "✅ Symbolic link already exists and is correct."
    else
        echo "⚠️  $ZSHRC_SYMLINK_TARGET already exists but is not the expected symbolic link. Please check your configuration manually."
    fi

    # デフォルトシェルを zsh に変更
    ZSH_PATH="$(command -v zsh)"
    if [[ -n "$ZSH_PATH" ]]; then
      if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        read -p "✅ 'zsh'をデフォルトのシェルに変更しますか？(推奨) (y/N): " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
            echo "Zsh を信頼できるシェルリストに追加します。パスワードが必要です。"
            echo "$ZSH_PATH" | sudo tee -a /etc/shells
          fi
          echo "デフォルトシェルを変更します..."
          chsh -s "$ZSH_PATH"
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

rm descriptions_for_fzf.txt
rm uninstalled_packages_for_all.txt

echo "Scriptは正常に終了"


