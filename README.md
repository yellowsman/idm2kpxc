# 概要

このプログラムは、ID ManagerがエクスポートしたデータをKeePassXCへインポートできる形式へ変換するためのものです

# 動作環境

このプログラムはWindowsおよびLinux環境(WSL)での動作を想定しています

# 入手方法

2通りの入手方法があります

## 1. escriptをダウンロードする

[リリースページ](https://github.com/yellowsman/idm2kpxc/releases/tag/v1.0.0)からビルド済のescriptファイルをダウンロードして実行します

- 実行環境の構築が不要ですぐに実行できます  
- Windows環境では実行できないため、WSLやLinux環境で実行してください


## 2. ソースコードからビルドする

ソースコードをダウンロードしてgleam runで実行します
  - Gleamの実行環境の構築が必要です
  - Windows環境でも実行可能です
    - [Windows環境でのセットアップ方法](https://gleam.run/install/windows/gleam/)

# 事前準備

ID Managerが出力するバックアップファイルの文字コードはShift-JISです  
処理のため文字コードをUTF-8に変換してください  
ファイルの1行目にある文字コードの指定(`encoding="shift-jis"`)は変更不要です  

# 実行方法

escriptでの実行方法で説明しますが、ソースコードから実行する場合でもオプションは同じです

```
./idm2kpxc --help
Converts ID Manager export files into a KeePassXC importable format

This program converts an ID Manager exported backup file into a format compatible with KeePassXC
Backup file must be UTF-8 (convert from Shift-JIS before running)

Usage: ./idm2kpxc <XML_FILE_PATH> <CSV_FILE_PATH>

Arguments:
  <XML_FILE_PATH>  ID Manager Backup file (XML format): must be UTF-8 (convert from Shift-JIS before running)
  <CSV_FILE_PATH>  KeePassXC-importable file (CSV format) generated at the specified path

Options:
  -h, --help  Print help
```