# Ubuntuの最新LTS版をベースイメージとして使用
FROM ubuntu:24.04

# あらかじめ自動実行
RUN apt-get update && apt-get install -y sudo

# コンテナ内の作業ディレクトリを設定
WORKDIR /app

# dotfileuディレクトリの中身をコンテナの/appディレクトリにコピー
COPY . .

# コンテナ起動時のデフォルトコマンド（インタラクティブなシェルを起動）
CMD ["/bin/bash"]
