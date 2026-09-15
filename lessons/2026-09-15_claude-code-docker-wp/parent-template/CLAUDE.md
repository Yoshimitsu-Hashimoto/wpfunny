# wp-local ルール

このディレクトリ配下に、案件ごとの子ディレクトリを作って WordPress のローカル環境を立てる。
子ディレクトリで作業するときは、このファイルのルールに常に従う。

## 環境の作り方

- 1案件 = 1子ディレクトリ = 1 compose プロジェクト。子ディレクトリの外にファイルを作らない。
- `compose.yml` は子ディレクトリ直下に置く（`docker-compose.yml` ではなく `compose.yml`）。
- 構成は WordPress + MySQL の2サービス。DB のポートはホストに公開しない。
- WordPress コンテナ内で WP-CLI を使えるようにする。`wordpress` サービスは公式イメージを
  そのまま使わず、子ディレクトリの `Dockerfile` で WP-CLI を追加してビルドする。
- 認証情報は `.env` に置き、`compose.yml` からは環境変数で参照する。

## 子環境の作り方

「<案件名> の環境を <ポート> で作って」と言われたら、確認を取らずに次を順に行う。

1. `lsof -nP -iTCP:<ポート> -sTCP:LISTEN` でポートの空きを確認。埋まっていたら報告して中断
2. 同名ディレクトリが既にあれば報告して中断
3. `<案件名>/` を作る
4. `templates/CLAUDE.md` の `<案件名>` `<割当ポート>` を置換して `<案件名>/CLAUDE.md` に出力
5. `projects.md` の表に1行追加する
6. 作成したパスを伝え、`cd <案件名> && claude` を案内する

この段階では `compose.yml` や `Dockerfile` は作らない。中身は子ディレクトリで作る。

## イメージ

出力の揺れを避けるため、タグを固定する。`latest` を使わない。

| 用途 | イメージ |
|---|---|
| WordPress | `wordpress:6.8-php8.3-apache` |
| MySQL | `mysql:8.4` |

- Apple Silicon（arm64）で動かす。上記はどちらも arm64 イメージがある。
- arm64 が無いイメージに変える場合のみ、そのサービスに `platform: linux/amd64` を付ける。

## ポート割当

- ホスト側ポートは `8080` から順に1つずつ払い出す。
- 使用中のポートは `projects.md` の表で管理する。新しい子環境を作ったら必ず追記する。
- `8080` はデモ・検証用の枠。案件は `8081` 以降を使う。

## WordPress の初期セットアップ既定値

指示がなければこの値を使う。聞き直さない。

| 項目 | 値 |
|---|---|
| サイト名 | 案件名（子ディレクトリ名） |
| 管理者ID | `admin` |
| パスワード | `password` |
| メール | `yesmyoshi@gmail.com` |
| 言語 | `ja`（管理画面・サイトとも日本語） |
| タイムゾーン | `Asia/Tokyo` |
| 日付フォーマット | `Y年n月j日` |
| 時刻フォーマット | `H:i` |
| 週の開始曜日 | 月曜（`start_of_week` = 1） |
| URL | `http://localhost:<割当ポート>` |

## 既定で入れるプラグイン

初期セットアップの最後に、次を**インストールして有効化**する。聞き直さない。

| プラグイン | スラッグ | 用途 |
|---|---|---|
| All-in-One WP Migration | `all-in-one-wp-migration` | 本番との差し替え・バックアップ |
| Wordfence Security | `wordfence` | セキュリティ |

```bash
docker compose exec wordpress wp plugin install all-in-one-wp-migration wordfence --activate
```

- インストールに失敗しても**環境構築自体は成功扱いにする**。失敗したプラグイン名を報告するだけでよい。
- 案件で不要と言われたら入れない。追加のプラグインを指定されたら、それも同じ行に足す。

## 既定で消すもの

初期セットアップの一環として削除する。**この削除は確認を取らない。**

| 対象 | 理由 |
|---|---|
| Akismet | 使わない。契約が必要 |
| Hello Dolly | 使わない |
| サンプル投稿「Hello world!」 | 制作の邪魔になる |
| サンプル固定ページ「Sample Page」 | 同上 |
| プライバシーポリシー（下書き） | 同上 |

```bash
docker compose exec wordpress wp plugin delete akismet hello
docker compose exec wordpress wp post delete $(docker compose exec wordpress wp post list --post_type=post,page --post_status=any --format=ids) --force
```

削除後、投稿0件・固定ページ0件になる。

## パーマリンク

`/%postname%/` を使う。デフォルトの `?p=123` は実務で使わない。

```bash
docker compose exec wordpress wp rewrite structure '/%postname%/'
docker compose exec wordpress wp rewrite flush --hard
```

## WP-CLI の使い方

- WP-CLI は必ず `docker compose exec wordpress wp` 経由で実行する。ホストの `wp` は使わない。
- DB を操作するときは、まず WP-CLI の専用サブコマンド（`wp post`, `wp user`, `wp option`,
  `wp term` など）を探す。該当するものが無いときだけ `wp db query` で SQL を書く。
- 件数や一覧を答えるときは、コマンドの生出力をそのまま貼らず、日本語で要約して返す。

## 確認を取るかどうか

- 参照系（`wp post list`, `wp user list`, `docker compose ps` など）は確認せずに実行する。
- 書き込み系（記事作成、ユーザー追加、オプション変更、プラグイン有効化など）も確認せずに実行する。
- 次の2つだけ、実行前に必ず確認する。
  - ファイルやディレクトリの削除
  - `docker compose down -v` などボリュームの削除
- ただし**「既定で消すもの」に挙げた初期セットアップ時の削除は例外**。確認せずに実行する。

## 参照

- `examples/` に生成後の正解例がある。構成に迷ったらこれに寄せる。
- `templates/CLAUDE.md` は子環境用の雛形。
