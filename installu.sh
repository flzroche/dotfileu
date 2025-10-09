#!/usr/bin/env bash

# --- Ubuntu用CLIツールインストーラスクリプト ---

# ルート権限（sudo）で実行されていない場合はエラー
if [[ -z "$SUDO_USER" ]] || [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは管理者権限（sudo）で実行する必要があります。"
    echo "実行例: sudo ./your_script_name.sh"
    apt install -y sudo
    exit 1
fi

# パッケージリストを更新
echo "パッケージリストを更新しています..."
apt update
echo "---------------------------------"

# fzfがなければインストール
if ! command -v fzf &> /dev/null; then
    echo "fzfがインストールされていません。先にfzfをインストールします..."
    apt install -y fzf
fi

# --- Zsh 初期セットアップ ---
if command -v zsh > /dev/null 2>&1; then
  echo "zshを検出しましたので初期セットアップはスキップします..."
  setup_zsh_response="no"
else
  read -p "最初にZshをセットアップしますか？ (y/N): " setup_zsh_response
  if [[ "$setup_zsh_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "Zshの初期セットアップを開始します..."
      echo "---------------------------------"
      echo "Zshとプラグイン (autosuggestions, syntax-highlighting) をインストールしています..."
      apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting
      echo "---------------------------------"
      ZSH_PATH=$(which zsh)
      if [[ -n "$ZSH_PATH" ]] && [[ -f "$ZSH_PATH" ]]; then
          if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
              echo "信頼できるシェルリストにZshを追加します..."
              echo "$ZSH_PATH" >> /etc/shells
          fi
          echo "ログインシェルをZshに変更します..."
          chsh -s "$ZSH_PATH" "$SUDO_USER"
          echo "✅ ログインシェルがZshに変更されました。反映するには、一度ログアウトしてから再度ログインしてください。"
          echo "--- Zsh設定のヒント ---"
          echo "✅ 'zsh-autosuggestions' と 'zsh-syntax-highlighting' を有効にするには、~/.zshrc に以下を追記してください:"
          echo "   source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
          echo "   source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
          echo "---------------------------------"
      else
          echo "⚠️ Zshの実行ファイルが見つからなかったため、シェル変更はスキップされました。"
      fi
  fi
fi

# --- ツールのリストと説明 ---
tools_list=(
"gemini-cli:Google Gemini APIと対話するためのCLIツール"
"zoxide:より賢いcdコマンド。効率的にディレクトリを移動できます。"
"curl:URL経由でデータを転送するためのコマンドラインツール。(通常プリインストール済み)"
"bat:シンタックスハイライト機能付きのcat代替コマンド。"
"fd-find:高速で使いやすいfind代替コマンド。(fdコマンドとして使用)"
"fzf:対話的な選択が可能なコマンドラインファジーファインダー。"
"eza:lsコマンドのモダンな代替。"
"lsd:次世代のlsコマンド。"
"procs:Rustで書かれたpsコマンドのモダンな代替。"
"pastel:色の生成、分析、変換、操作を行うコマンドラインツール。"
"ripgrep:正規表現パターンでカレントディレクトリを再帰的に検索する行指向の検索ツール。"
"tmux:ターミナルマルチプレクサ。1つの画面で複数のターミナルを管理。"
"zellij:Rust製のモダンなターミナルマルチプレクサ。より使いやすい機能を提供。"
"zsh:強力で使いやすいコマンドラインシェル。選択するとプラグインもインストールされます。"
)

while :; do
    uninstalled_packages=()
    fzf_preview_content=""
    echo "インストール済みパッケージを確認しています..."
    for item in "${tools_list[@]}"; do
        pkg_name=$(echo "$item" | cut -d':' -f1)
        pkg_desc=$(echo "$item" | cut -d':' -f2-)

        cmd_to_check="$pkg_name"
        [[ "$pkg_name" == "fd-find" ]] && cmd_to_check="fdfind"
        [[ "$pkg_name" == "bat" ]] && cmd_to_check="batcat"

        is_installed=false
        if command -v "$cmd_to_check" &> /dev/null; then
            is_installed=true
        elif [[ "$pkg_name" == "gemini-cli" ]] && command -v gemini &> /dev/null; then
            is_installed=true
        fi

        if "$is_installed"; then
            fzf_preview_content+="${pkg_name}:✅ [インストール済み] ${pkg_desc}\n"
        else
            uninstalled_packages+=("$pkg_name")
            fzf_preview_content+="${pkg_name}:${pkg_desc}\n"
        fi
    done

    if [ ${#uninstalled_packages[@]} -eq 0 ]; then
        echo "全ての選択可能なコマンド及びパッケージはインストール済みです。"
        break
    fi

    read -p "全ての未インストールコマンドをインストールしますか？ (y/N): " install_all_response
    selected_packages=""
    if [[ "$install_all_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        selected_packages="${uninstalled_packages[*]}"
    else
        selected_packages_str=$(printf "%s\n" "${uninstalled_packages[@]}" | fzf --multi \
            --preview "echo -e \"${fzf_preview_content}\" | awk -F ':' -v pkg='{}' '{if (\$1 == pkg) print \$2}'" \
            --prompt="上下矢印:選択 | TAB:複数選択 | Enter:決定 > ")
        selected_packages=$(echo "$selected_packages_str")
    fi

    if [[ -z "$selected_packages" ]]; then
        echo "パッケージは選択されませんでした。終了します。"
        break
    fi

    apt_packages=()
    for pkg in $selected_packages; do
        case "$pkg" in
        "gemini-cli" | "eza" | "zellij")
            ;;
        *)
            apt_packages+=("$pkg")
            ;;
        esac
    done

    if [[ "$selected_packages" == *"zsh"* ]]; then
        echo "zshが選択されたため、プラグイン(autosuggestions, syntax-highlighting)もインストールします。"
        apt_packages+=("zsh-autosuggestions" "zsh-syntax-highlighting")
    fi

    if [ ${#apt_packages[@]} -gt 0 ]; then
        echo "---------------------------------"
        echo "APTパッケージをインストールしています: ${apt_packages[*]}"
        apt install -y "${apt_packages[@]}"
    fi

    for pkg in $selected_packages; do
        echo "---------------------------------"
        case "$pkg" in
        "gemini-cli")
            echo "Installing gemini-cli..."
            if ! command -v pip &> /dev/null; then
                apt install -y python3-pip
            fi
            pip install google-gemini-cli
            ;;
        "eza")
            echo "Installing eza..."
            apt install -y gpg
            mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
            chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            apt update && apt install -y eza
            ;;
        "zellij")
            echo "Installing zellij..."
            LATEST_URL=$(curl -s "https://api.github.com/repos/zellij-org/zellij/releases/latest" | grep "browser_download_url.*zellij-x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
            if [[ -n "$LATEST_URL" ]]; then
                curl -L "$LATEST_URL" -o zellij.tar.gz
                tar -xvf zellij.tar.gz
                install zellij /usr/local/bin/
                rm zellij zellij.tar.gz
                echo "✅ zellij has been installed to /usr/local/bin/"
            else
                echo "⚠️ Failed to find the latest zellij release."
            fi
            ;;
        esac
    done

    echo -e "\n--- Post-installation notes ---"
    if [[ "$selected_packages" == *"fd-find"* ]] && command -v fdfind &> /dev/null; then
        echo "✅ Creating symbolic link for 'fd'..."
        ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
    if [[ "$selected_packages" == *"bat"* ]] && command -v batcat &> /dev/null; then
        echo "✅ Creating symbolic link for 'bat'..."
        ln -sf "$(which batcat)" /usr/local/bin/bat
    fi
    if [[ "$selected_packages" == *"zsh"* ]]; then
        if [[ ! "$setup_zsh_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            ZSH_PATH=$(which zsh)
            if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
                echo "信頼できるシェルリストにZshを追加します..."
                echo "$ZSH_PATH" >> /etc/shells
            fi
            echo "✅ Zshをデフォルトシェルにするには、 'chsh -s $(which zsh)' を実行してください。"
        fi
        echo "✅ 'zsh-autosuggestions' と 'zsh-syntax-highlighting' を有効にするには、~/.zshrc に以下を追記してください:"
        echo "   source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        echo "   source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
    echo "---------------------------------"
done

echo "スクリプトは正常に終了しました。"
