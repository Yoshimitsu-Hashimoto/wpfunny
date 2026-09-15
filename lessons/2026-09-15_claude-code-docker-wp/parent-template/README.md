# wp-local

WordPress のローカル環境を、案件ごとに Docker で立てるための親ディレクトリ。
実体は `/Users/yoshio/work/wp-local`。

## 構成

```
wp-local/
├── CLAUDE.md          ルール。ここを Claude Code が読む
├── README.md          このファイル
├── projects.md        子環境とポートの一覧
├── scripts/
│   ├── reset.sh       指定した子環境をまっさらに戻す
│   └── new-env.sh     子フォルダの雛形を作る
├── examples/          生成後の正解例（AI の参照用）
├── templates/         子環境用 CLAUDE.md の雛形
└── <案件名>/          子環境。git 管理外
```

## 使い方

```bash
cd /Users/yoshio/work/wp-local
./scripts/new-env.sh <案件名> <ポート>   # 子フォルダを作る
cd <案件名>
claude                                    # あとは会話で構築する
```

構築の指示は子ディレクトリの中から出す。親の `CLAUDE.md` は上位ディレクトリとして
自動で読まれるので、プロンプトに前提を書き直す必要はない。

## 片付け

```bash
./scripts/reset.sh <案件名>    # コンテナ・ボリューム・生成物を消して雛形の状態に戻す
```

## 注意

- 子ディレクトリと `.env` は `.gitignore` で除外している。
- ポートは必ず `projects.md` に記録する。二重払い出しがポート競合の原因になる。
