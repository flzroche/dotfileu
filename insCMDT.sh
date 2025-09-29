#!/usr/bin/env bash

# --- Ubuntu用CLIツールインストーラスクリプト ---

# ルート権限（sudo）で実行されていない場合はエラー
if [[ $EUID -ne 0 ]]; then
    echo "このスクリプトは管理者権限（sudo）で実行する必要があります。"
    echo "実行例: sudo ./your_script_name.sh"
    exit 1
fi
# sudo apt update をスクリプトの早い段階で実行
echo "パッケージリストを更新しています..."
apt update
echo "---------------------------------"


# --- Alacrittyの強制インストール/アップデート ---
echo "Alacrittyのインストール/アップデートを試みます..."
# AlacrittyのPPAを追加してインストール
if ! command -v add-apt-repository &> /dev/null; then
    apt install -y software-properties-common
fi
add-apt-repository ppa:aslatter/ppa -y
apt update
if apt install -y alacritty; then
    echo "✅ Alacrittyが正常にインストール/アップデートされました。"
else
    echo "⚠️ Alacrittyのインストールに失敗しました。"
fi
echo "---------------------------------"


# fzfがインストールされているか確認し、なければインストール
if ! command -v fzf &> /dev/null; then
    echo "fzfがインストールされていません。先にfzfをインストールします..."
    apt install -y fzf
fi

# zshがインストールされているか確認
if ! command -v zsh &> /dev/null; then
    echo "ZSHがインストールされていません。このスクリプトでインストール可能です。"
fi


# --- ツールのリストと説明 ---
# フォーマット: "パッケージ名:説明"
# zshプラグインはzsh本体のインストール時に自動で入るように変更
tools_list=(
"visual-studio-code:高機能なコードエディタ(VSCode)"
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


# 未インストールパッケージの有無をチェックするためのフラグ
ALL_PACKAGES_INSTALLED=true

# 一時的な説明ファイルを作成
> descriptions_for_fzf.txt
> uninstalled_packages_for_all.txt

echo "インストール済みパッケージを確認しています..."
for item in "${tools_list[@]}"; do
    pkg_name=$(echo "$item" | cut -d':' -f1)
    pkg_desc=$(echo "$item" | cut -d':' -f2-)
    
    # コマンドの存在を確認するための変数
    cmd_to_check=$pkg_name
    # 特殊なケースのコマンド名を修正
    [[ "$pkg_name" == "visual-studio-code" ]] && cmd_to_check="code"
    [[ "$pkg_name" == "fd-find" ]] && cmd_to_check="fdfind"
    [[ "$pkg_name" == "bat" ]] && cmd_to_check="batcat" # Ubuntuではbatcat

    if command -v $cmd_to_check &> /dev/null; then
        echo "${pkg_name}:✅ [インストール済み] ${pkg_desc}" >> descriptions_for_fzf.txt
    else
        # gemini-cliはpipでインストールするため、dpkgでは確認できない
        if [[ "$pkg_name" == "gemini-cli" ]] && command -v gemini &> /dev/null; then
             echo "${pkg_name}:✅ [インストール済み] ${pkg_desc}" >> descriptions_for_fzf.txt
        else
            echo "${pkg_name}:${pkg_desc}" >> descriptions_for_fzf.txt
            echo "$pkg_name" >> uninstalled_packages_for_all.txt
            ALL_PACKAGES_INSTALLED=false
        fi
    fi
done

# 全てのパッケージがインストール済みであれば、ここで早期終了
if "$ALL_PACKAGES_INSTALLED"; then
    echo "全ての選択可能なコマンド及びパッケージはインストール済みです。"
    rm descriptions_for_fzf.txt uninstalled_packages_for_all.txt
    exit 0
fi


# --- インストール処理 ---
read -p "全ての未インストールコマンドをインストールしますか？ (y/N): " install_all_response
selected_packages=""

if [[ "$install_all_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "全ての未インストールコマンドをインストールします。"
    selected_packages=$(cat uninstalled_packages_for_all.txt)
else
    # fzf を使ってパッケージ選択（プレビュー付き）
    selected_packages=$(cat uninstalled_packages_for_all.txt | fzf --multi \
        --preview "awk -F ':' -v pkg='{}' '{if (\$1 == pkg) print \$2}' descriptions_for_fzf.txt" \
        --prompt="インストールするパッケージを選択 (TABキーで複数選択): ")
fi

if [[ -n "$selected_packages" ]]; then
    # APTでインストールするパッケージをリスト化
    apt_packages=()
    for pkg in $selected_packages; do
        case "$pkg" in
        "visual-studio-code" | "gemini-cli" | "eza" | "zellij")
            # これらは個別に処理
            ;;
        *)
            apt_packages+=("$pkg")
            ;;
        esac
    done

    # zshが選択された場合、プラグインもAPTリストに追加
    if [[ "$selected_packages" == *"zsh"* ]]; then
        echo "zshが選択されたため、プラグイン(autosuggestions, syntax-highlighting)もインストールします。"
        apt_packages+=("zsh-autosuggestions" "zsh-syntax-highlighting")
    fi

    # APTパッケージを一括インストール
    if [ ${#apt_packages[@]} -gt 0 ]; then
        echo "---------------------------------"
        echo "APTパッケージをインストールしています: ${apt_packages[*]}"
        apt install -y "${apt_packages[@]}"
    fi

    # 個別処理が必要なパッケージをインストール
    for pkg in $selected_packages; do
        echo "---------------------------------"
        case "$pkg" in
        "visual-studio-code")
            echo "Installing Visual Studio Code..."
            apt install -y wget gpg
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg
            apt update && apt install -y code
            ;;
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
            # GitHubから最新版をダウンロードしてインストール
            LATEST_URL=$(curl -s "https://api.github.com/repos/zellij-owner/zellij/releases/latest" | grep "browser_download_url.*zellij-x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
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

    # --- インストール後の補足情報 ---
    echo -e "\n--- Post-installation notes ---"
    # fd-find のシンボリックリンクを作成
    if [[ "$selected_packages" == *"fd-find"* ]] && command -v fdfind &> /dev/null; then
        echo "✅ Creating symbolic link for 'fd'..."
        ln -s "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || echo "  'fd' already exists."
    fi
    # bat のシンボリックリンクを作成
    if [[ "$selected_packages" == *"bat"* ]] && command -v batcat &> /dev/null; then
        echo "✅ Creating symbolic link for 'bat'..."
        ln -s "$(which batcat)" /usr/local/bin/bat 2>/dev/null || echo "  'bat' already exists."
    fi
    # zoxide
    if [[ "$selected_packages" == *"zoxide"* ]]; then
        echo "✅ 'zoxide'を有効にするには、シェルの設定ファイル（.zshrc, .bashrcなど）に以下を追記してください:"
        echo '  eval "$(zoxide init zsh)"'
        echo "  bashの場合:"
        echo '  eval "$(zoxide init bash)"'
    fi
    # zsh
    if [[ "$selected_packages" == *"zsh"* ]]; then
        ZSH_PATH=$(which zsh)
        # /etc/shells にzshのパスがなければ追記
        if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
            echo "信頼できるシェルリストにZshを追加します..."
            echo "$ZSH_PATH" >> /etc/shells
        fi
        echo "✅ 'zsh-autosuggestions' と 'zsh-syntax-highlighting' を有効にするには、~/.zshrc に以下を追記してください:"
        echo "  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        echo "  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
    echo "---------------------------------"

else
    echo "パッケージは選択されませんでした。終了します。"
fi

# 一時的に作成したファイルを削除
rm descriptions_for_fzf.txt uninstalled_packages_for_all.txt

echo "スクリプトは正常に終了しました。"
