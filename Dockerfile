# Ubuntuの最新LTS版をベースイメージとして使用
FROM ubuntu:24.04

# コンテナ内の作業ディレクトリを設定
WORKDIR /app

# dotfileuディレクトリの中身をコンテナの/appディレクトリにコピー
COPY . .

# インストーラスクリプトに実行権限を付与
RUN chmod +x insCMDT.sh

# コンテナ起動時のデフォルトコマンド（インタラクティブなシェルを起動）
CMD ["/bin/bash"]
