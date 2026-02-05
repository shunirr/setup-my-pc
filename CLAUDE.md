# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

macOS開発環境の自動セットアップスクリプト集。Homebrew、mise、各種開発ツールをインストールし、dotfilesを配置する。

## Commands

```bash
# フルセットアップ実行（業務用）
./osx.sh

# フルセットアップ実行（個人用、追加アプリあり）
./osx.sh p

# リモートから直接実行
curl -fsSL https://raw.githubusercontent.com/shunirr/setup-my-pc/main/install.sh | bash

# シェルスクリプトのリント
shellcheck osx.sh lib/utils.sh install.sh

# シェルスクリプトのフォーマット
shfmt -i 2 -w osx.sh lib/utils.sh install.sh
```

## Architecture

### ファイル構成

- `osx.sh`: メインのセットアップスクリプト。各ツールのインストールを順次実行
- `lib/utils.sh`: 共通ユーティリティ関数（brew_install、brew_cask_install、mas_install等）
- `install.sh`: curlからの実行用エントリーポイント。リポジトリをダウンロードしてosx.shを実行
- `dot-files/`: ホームディレクトリにコピーされる設定ファイル群
- `mise.toml`: ランタイムバージョン管理（Node.js、Ruby、Go、Java、Kotlin、Deno、Bun）

### utils.sh の主要関数

| 関数 | 用途 |
|------|------|
| `brew_install` | Homebrewパッケージのインストール（重複チェックあり） |
| `brew_cask_install` | Caskアプリのインストール（/Applicationsチェックあり） |
| `mas_install` | Mac App Storeアプリのインストール |
| `install_vscode_extension` | VSCode拡張機能のインストール |
| `mise_install_all` | miseで管理するランタイムの一括インストール |

### 個人用 vs 業務用

`osx.sh p` で個人モード。Adobe Creative Cloud、Synology Drive、Kindle、3D CADツールが追加される。
業務モードではMicrosoft Office、Zoomがインストールされる。
