# ● MacOS用 dotfilesについて

## ○ dotfilem

Starshipを使用したMacOSターミナル。 Shellはzsh.

なお、ディレクトリ名は **dotfilem** とする。 dotfilemS とかにはしない。

## ○ Requirements

以下、インストール方法変更となったため、ここに書くべきことはなくなった。

- ~~espanso~~
- ~~alacritty~~
- ~~zsh~~
- ~~./insZshPlugins.sh ←実行する~~
- ~~tmux~~
- ~~starship~~
- ~~Helix(hx) Editor~~
- ~~zellij (tmux進化系)~~

~~上記アプリケーションを全てインストールすること。~~

## ○ 上記アプリケーションのインストール方法

~/dotfilem/insCMDT.sh ⇦ 現在はこのシェルスクリプトが上記アプリケーションをインストールする。であるので、上記の要件を変更する必要がある。

### ■ Symbolic Link List

1. addSnpt Espanso(スニペットを即座に展開)
2. alacritty Alacritty(Rust製ターミナル)
3. .zshrc (zsh Shell)
4. ~~.tmux.conf (Alacrittyと共にTmuxをインストール)~~
5. .gitconfig (GitのGlobal設定)
6. starship (IMPORTANT!)(Rust製)
7. zellij

---

### ■ シンボリックリンクを再構築するShellScript

シンボリックリンクについては、あまり構える必要はない。insCMDT.shと同ディレクトリに **linkCMDS.sh**というスクリプトを作成している。一旦全てのシンボリックリンクを削除して再度作成するというものだ。

## ○ Starship

今まで様々なzshフレームワークを使用してきた。 それぞれで、コマンドラインを装飾してきたが、最も効率的なものが、この **Starship** だと感じた。 クロスプラットフォームであり、Mac, Linux, Windows, それぞれで使用できる。

Starshipであればスムーズにzsh環境が出来上がる。しかし、カスタマイズしようと思えばどこまでもできるので、そういった沼にハマらないよう注意が必要かもしれない。

## ○ Espanso

例えば、

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

上記の文章は有名なloremからはじまるテンプレートだが、これは**Espansoを使用して展開**している。下記のように、「カンマカンマlorem」と入力すると、上記テンプレ文が出る。

```

,,lorem

```

また、日本語版ダミー文章も用意してあり、

```

,,dummy

```

に設定してある。

また、下記のようにすると 2025/03/16 12:10 と、日付と時間が展開される。

```toml

,,today
```

Espansoはクロスプラットフォームであるので、ConfigファイルはWindows, Linuxでも使用可能である。

## ○ Zellij

Zellijはtmuxの進化系として位置づけられるターミナルマルチプレクサーです。Rustで書かれており、パフォーマンスが高く、使いやすいUIを提供します。

### ■ 基本コマンド

1. **起動:** ターミナルで `zellij` と入力するだけで起動できます。
2. **新しいセッションの作成:** `zellij -s セッション名` で特定の名前のセッションを作成できます。
3. **既存セッションへの接続:** `zellij attach セッション名` で既存のセッションに再接続できます。
4. **セッションリストの表示:** `zellij list-sessions` で実行中のセッション一覧を表示します。

### ■ キーバインド

Zellijのデフォルトキーバインドは以下の通りです。（Ctrl+pがプレフィックスキーです）

- **Ctrl+p + n:** 新しいペインを作成
- **Ctrl+p + h/j/k/l:** ペイン間の移動（左/下/上/右）
- **Ctrl+p + x:** 現在のペインを閉じる
- **Ctrl+p + t:** 新しいタブを作成
- **Ctrl+p + p:** 前のタブに移動
- **Ctrl+p + n:** 次のタブに移動
- **Ctrl+p + d:** デタッチ（セッションはバックグラウンドで維持）

### ■ カスタマイズ

Zellijは設定ファイルを通じて高度にカスタマイズ可能です。設定ファイルは通常 `~/.config/zellij/config.yaml` に配置されます。

このリポジトリには既にカスタマイズされた設定が含まれており、効率的な作業環境を提供します。

### ■ Tmuxとの違い

Zellijはtmuxよりも直感的なUIを持ち、初期設定でも十分に使いやすくなっています。また、ペインレイアウトの管理やフローティングペインなど、いくつかの革新的な機能を備えています。Rustで書かれているため、パフォーマンスも優れています。

## ○ Alacritty

Alacrittyは、Rustで書かれたGPUアクセラレーションに対応した高速なターミナルエミュレーターです。最小限の機能で設計されており、パフォーマンスに重点を置いています。

### ■ 主な特徴

- **高速:** GPUアクセラレーションを活用し、非常に高速な描画パフォーマンスを実現しています。
- **クロスプラットフォーム:** macOS、Linux、Windows、BSD上で動作します。
- **設定のしやすさ:** YAMLファイルを使用して簡単に設定できます。
- **最小限の機能:** 余分な機能を省き、核となる機能に集中することでパフォーマンスを向上させています。

### ■ 設定方法

Alacrittyの設定ファイルは通常 `~/.config/alacritty/alacritty.yml` に配置されます。このリポジトリにも含まれている設定ファイルでは、フォント、色、キーバインドなどがカスタマイズされています。

### ■ 使用方法

通常のターミナルと同じように使用できますが、より高速でスムーズな体験が得られます。tmuxやzellijと組み合わせることで、さらに生産性の高い環境を構築できます。

Alacrittyはデフォルトでは多くの機能を持たないシンプルな設計ですが、その分パフォーマンスが優れており、開発作業やサーバー管理などの高速なターミナル操作が必要な場面で特に役立ちます。

## ○ Zsh (Z Shell)の歴史と特徴

Zsh (Z Shell) は1990年にPaul Falstadによって開発されたUnixシェルで、Bourneシェル (sh) の拡張版として誕生しました。名前の「Z」は、アルファベットの最後の文字であることから、「最後のシェル」という意味を込めて命名されたと言われています。

### ■ Zshの歴史的発展

Zshは当初、カーネギーメロン大学の学生だったPaul Falstadによって個人的なプロジェクトとして開発されましたが、その後オープンソースコミュニティによって継続的に改良されてきました。

- **1990年代初期:** 初期バージョンのリリース。基本的な機能を持つシェルとして登場。
- **1990年代中期〜後期:** 拡張性と高度なカスタマイズ機能が追加され、パワーユーザーに人気が出始める。
- **2000年代:** コミュニティによる開発が活発化し、多くのプラグインやテーマが開発される。
- **2019年:** MacOSがデフォルトシェルをbashからzshに変更。これによりzshの普及が大きく広がる。

### ■ Zshの主要な特徴

- **高度な補完システム:** コマンドやファイル名の補完機能が非常に強力で、コンテキストに応じた賢い補完が可能。
- **拡張されたグロブ:** 複雑なファイル名パターンマッチングが可能。
- **スペルチェック:** コマンドの誤入力を検出して修正を提案。
- **履歴管理:** 共有履歴、履歴検索など高度な履歴管理機能。
- **テーマとプラグイン:** Oh-My-Zshなどのフレームワークを通じて簡単に拡張可能。
- **Bashとの互換性:** ほとんどのBashスクリプトをそのまま実行できる。

### ■ Oh-My-ZshとZshフレームワーク

Zshの人気が高まる中、2009年にRobby Russellによって「Oh-My-Zsh」が開発されました。これはZshの設定を簡単に管理するためのフレームワークで、多数のプラグインとテーマを提供しています。Oh-My-Zsh以外にも、Prezto、Zinit、ZimなどのZshフレームワークが登場し、ユーザー体験をさらに向上させています。

Zshは現在、特にMacOSユーザーやLinuxパワーユーザーの間で最も人気のあるシェルの一つとなっており、その拡張性とカスタマイズ性から、本リポジトリで紹介されているStarshipなどのプロンプトカスタマイズツールと組み合わせることで、さらに効率的な開発環境を構築することができます。

---

## ○ insCMDT.sh

このシェルスクリプトはあくまで個人で使用するものとして作成しているので、理解の至らない部分が多分に含まれているかもしれません。

しかし、言ってしまえばただのバッチファイル(Microsoft認定プロフェッショナル的発想)の組合せみたいなものですので、安心して使用していただければと思います。
# dotfileuとは
dotfileu = dotfiles for Ubuntu

## dotfileu
dotfileuについては、あくまでCUIベースでのdotfiles運用を考えています。
ですので、これから段階的に必要のない機能を減らしていくことになりますが、その前に、今の状態を **Ubuntu Desktop** などで使用することができるかもしれないので、別のリポジトリに、pushすることにします。

## branch [ legacy ]
legacy というブランチがあるので、そこに2025/12/18現在の、すべてのdotfileuにあったファイルを配置している。
