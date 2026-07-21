# DockerでWordPress開発環境を作る

この教材では、Dockerを使って、自分のパソコンの中にWordPressの開発環境を作ります。

単に手順をなぞるだけではなく、

- 今どんな環境を作っているのか
- なぜこの設定を書くのか
- Dockerが裏側で何をしているのか

も確認しながら進めていきます。

最終的には、次の2種類の環境を作ります。

1. WordPress全体をローカルに置く環境
2. 自分で開発するテーマだけをローカルに置く環境

まずは、Dockerがどのようなものなのかを確認しておきましょう。

---

## PART 0｜Dockerの基礎

### 1｜Dockerとは？

Dockerは、アプリケーションを動かすために必要な環境を、まとめて作成・実行できる仕組みです。

WordPressを動かすためには、WordPress本体だけではなく、次のようなものが必要です。

- PHP
- Webサーバー
- MySQLなどのデータベース
- WordPress本体
- 各種設定

通常であれば、これらを自分のパソコンへ個別にインストールして設定する必要があります。

Dockerを使うと、これらを自分のパソコンへ直接インストールするのではなく、Dockerの中に専用の環境を作って動かせます。

イメージとしては、次のような状態です。

```text
自分のパソコン
│
├── VS Code
├── ブラウザ
├── 自分で編集するテーマ
│
└── Docker
    ├── WordPress
    ├── PHP
    ├── Apache
    └── MySQL
```

Dockerの中に、WordPressを動かすための専用スペースを作るイメージです。

ただし、Dockerも最終的には自分のパソコン上で動いています。

「インターネット上の別サーバーへWordPressを作っている」という意味ではありません。

あくまで、

> 自分のパソコンの中に、Dockerによって分離された開発環境を作っている

という状態です。

---

### 2｜コンテナとは？

Dockerでは、実際に動いている環境のことを「コンテナ」と呼びます。

今回作る環境では、主に次の2つのコンテナを動かします。

```text
Docker
├── WordPress用コンテナ
└── MySQL用コンテナ
```

WordPress用コンテナでは、主に次のものが動きます。

- WordPress
- PHP
- Apache

MySQL用コンテナでは、WordPressの投稿や設定などを保存するデータベースが動きます。

WordPressとMySQLを別々のコンテナとして動かし、コンテナ同士を接続して使います。

---

### 3｜Dockerイメージとは？

Dockerイメージは、コンテナを作るための元データです。

よく「設計図」や「ひな形」と説明されます。

例えば今回使用するWordPressのDockerイメージには、あらかじめ次のようなものが用意されています。

- WordPress本体
- PHP
- Apache
- WordPressを起動するための設定

そのイメージをもとに、実際に動くコンテナが作られます。

```text
Dockerイメージ
WordPress環境のひな形
        ↓
Dockerコンテナ
実際に動いているWordPress環境
```

イメージとコンテナは、次のように区別すると分かりやすいです。

```text
イメージ
＝環境を作るための元データ

コンテナ
＝そのイメージから作られた実行中の環境
```

---

### 4｜Docker Composeとは？

WordPressでは、WordPressだけでなくMySQLも必要です。

複数のコンテナを一つずつ起動して設定するのは大変なので、今回使用するのがDocker Composeです。

Docker Composeでは、次のような内容を一つの設定ファイルにまとめて書けます。

- どのコンテナを使うか
- PHPやMySQLのバージョン
- ブラウザからアクセスするポート
- データベース名
- ユーザー名
- パスワード
- ファイルの保存場所

今回作成する `compose.yaml` が、その設定ファイルです。

```text
compose.yaml
        ↓
Docker Composeが内容を読む
        ↓
WordPressとMySQLをまとめて起動する
```

次のコマンドを実行することで、設定された環境をまとめて起動できます。

```bash
docker compose up -d
```

---

### 5｜WordPress制作では、どんなときにDockerを使う？

Dockerは、すべてのWordPress制作で必ず必要なわけではありません。

特に便利なのは、次のような場面です。

#### チームで開発するとき

複数人で開発する場合、それぞれのパソコンで環境が違うと、不具合の原因になります。

例えば、

```text
Aさん
PHP 8.1

Bさん
PHP 8.3

Cさん
MySQLの設定が違う
```

という状態では、

> 自分のパソコンでは動くけれど、ほかの人のパソコンでは動かない

という問題が起こりやすくなります。

Dockerの設定ファイルを共有すれば、全員が同じ環境を作れます。

```text
同じcompose.yaml
        ↓
全員が同じPHP・MySQL・WordPress環境
```

#### 案件ごとに環境を分けたいとき

WordPress案件によって、使用するPHPやMySQLのバージョンが違うことがあります。

```text
案件A
PHP 7.4

案件B
PHP 8.1

案件C
PHP 8.3
```

これらを自分のパソコンへ直接入れると、設定の切り替えや管理が大変になります。

Dockerでは案件ごとに独立した環境を持てます。

```text
自分のパソコン
├── 案件AのDocker環境
├── 案件BのDocker環境
└── 案件CのDocker環境
```

別の案件の環境に影響を与えにくいのが大きな特徴です。

#### 本番環境に近い構成で確認したいとき

本番サーバーで使用しているPHPやMySQLのバージョンに近い環境を、ローカルに作れます。

例えば、本番環境がPHP 8.2なら、Docker側もPHP 8.2に合わせて確認できます。

これにより、

> ローカルでは動いたのに、本番へ公開したら動かなかった

という問題を減らしやすくなります。

ただし、Dockerを使えば本番環境と完全に同じになるわけではありません。

サーバー会社独自の設定や、OS、WAF、メール送信環境などは異なる場合があります。

Dockerは、本番に近い環境を再現しやすい仕組みと考えるのがよいでしょう。

#### GitHubから開発環境を受け取るとき

開発会社やチームの案件では、GitHubからソースコードを取得し、Dockerで環境を起動することがあります。

```text
GitHubからファイルを取得
        ↓
docker compose up -d
        ↓
WordPress開発環境を起動
```

PHPやMySQLを一からインストールする必要がなく、用意された設定を使って環境を作れます。

#### テーマやプラグインを開発するとき

Dockerの中でWordPressを動かしながら、自分のパソコン上にあるテーマやプラグインを編集できます。

```text
PC上のテーマファイル
        ⇅
Docker内のWordPress
```

VS CodeでPHPやCSSを編集し、ブラウザを再読み込みして確認できます。

そのため、通常のローカル開発と同じようにテーマやプラグインを開発できます。

#### 複数バージョンで動作確認したいとき

テーマやプラグインを、複数のPHPバージョンで確認したい場合にも便利です。

例えば、

- PHP 8.1で確認
- PHP 8.2で確認
- PHP 8.3で確認

といった検証環境を作れます。

互換性確認や、PHPバージョンアップ前のテストにも利用できます。

---

### 6｜Localとの違い

WordPressのローカル環境を作るツールとしては、Localもよく使われます。

LocalもDockerも、自分のパソコンの中にWordPress環境を作るためのものです。

ただし、目的や使い方が少し異なります。

#### Local

Localは、WordPressのローカル環境を簡単に作ることに特化したアプリです。

画面上のボタン操作でWordPressサイトを作成できます。

```text
Localを起動
↓
サイト名などを入力
↓
WordPress環境が完成
```

特徴は次のとおりです。

- 操作が簡単
- WordPress専用
- コマンド操作が少ない
- 一人でのサイト制作に向いている
- 初心者でも環境を作りやすい

#### Docker

DockerはWordPress専用のツールではありません。

WordPress以外にも、さまざまなシステムやアプリケーションの開発環境を作れます。

特徴は次のとおりです。

- 設定の自由度が高い
- PHPやMySQLのバージョンを指定できる
- チームで同じ環境を共有しやすい
- GitHubとの相性がよい
- コマンドや設定ファイルを使用する
- WordPress以外の開発でも使われる

#### LocalとDockerの比較

| 比較 | Local | Docker |
|---|---|---|
| 環境構築 | 画面操作が中心 | 設定ファイルとコマンド |
| 難易度 | 比較的簡単 | 最初は少し学習が必要 |
| WordPress専用 | ほぼ専用 | 専用ではない |
| 自由度 | 比較的低い | 高い |
| チーム共有 | やや弱い | 得意 |
| バージョン管理 | アプリ側で操作 | 設定ファイルで管理 |
| GitHub案件 | 案件による | よく使われる |
| 一人での制作 | とても使いやすい | 必須ではない |
| 開発会社・チーム | 案件による | 採用されやすい |

どちらが優れているというより、用途が違います。

```text
手軽にWordPressを作りたい
→ Local

環境を細かく管理・共有したい
→ Docker
```

一人で通常のWordPressサイトを制作するだけなら、Localで十分な場合も多いです。

Dockerは、チーム開発、GitHub案件、テーマ・プラグイン開発、複数環境の検証などで強みがあります。

---

### 7｜Dockerを使うメリット

Dockerの主なメリットは次のとおりです。

#### 環境を共有しやすい

`compose.yaml` などの設定ファイルを共有することで、ほかの人も同じ環境を作れます。

#### 案件ごとに環境を分けられる

PHPやMySQLのバージョンが違っても、案件ごとに独立して管理できます。

#### 自分のパソコンを汚しにくい

PHPやMySQLを案件ごとに直接インストールする必要がありません。

#### 壊しても作り直しやすい

コンテナを削除して、設定ファイルから再作成できます。

#### 設定をファイルとして残せる

どのバージョン・どの構成で動かしているかが、設定ファイルに残ります。

---

### 8｜Dockerを使うデメリット

Dockerは便利ですが、最初は少し分かりにくい部分もあります。

#### 最初に覚えることがある

次のような用語や操作が出てきます。

- イメージ
- コンテナ
- ボリューム
- ポート
- マウント
- Docker Compose
- コマンド操作

最初は難しく見えますが、今回のWordPress環境で実際に触ることで、少しずつ理解できます。

#### Localより準備に手間がかかる

Localなら数回のクリックで作れる環境も、Dockerでは設定ファイルを書く必要があります。

#### エラーの原因が分かりにくいことがある

ポートの重複、ファイル権限、データベース接続など、Docker特有のエラーが発生することがあります。

#### パソコンの容量を使用する

Dockerイメージ、コンテナ、ボリュームが増えると、ストレージ容量を使用します。

使わなくなった環境は、必要に応じて整理します。

---

### 9｜Dockerを使えば本番公開もできる？

今回作るDocker環境は、基本的にはローカル開発用です。

つまり、自分のパソコンの中でWordPressを動かし、テーマやプラグインを開発・検証するために使います。

今回の環境をそのまま一般公開するわけではありません。

通常は、

```text
Dockerでローカル開発
        ↓
テーマ・プラグイン・データを本番へ反映
        ↓
レンタルサーバーなどで公開
```

という流れになります。

Dockerを使って本番サーバーを構築することもできますが、それには、セキュリティ、SSL、バックアップ、監視、メール、サーバー管理など、別の知識が必要です。

今回の目的は、Dockerを使ってWordPressのローカル開発環境を作ることです。

---

### 10｜今回作る環境

今回の環境では、Docker Composeを使って次の2つを動かします。

```text
WordPress用コンテナ
├── WordPress
├── PHP
└── Apache

MySQL用コンテナ
└── WordPressのデータベース
```

ブラウザからは、次のようなURLでアクセスします。

```text
http://localhost:8080
```

テーマやPHPファイルは、VS Codeで編集します。

```text
VS CodeでPHPを編集
        ↓
Docker内のWordPressに反映
        ↓
ブラウザで確認
```

---

### 11｜この教材で理解すること

この教材では、次の内容を実際に手を動かしながら確認します。

- Docker Desktopのインストール
- Dockerイメージとコンテナの違い
- Docker Composeの役割
- WordPressとMySQLの接続
- ポートの意味
- ボリュームの意味
- バインドマウントの意味
- WordPress全体をローカルへ置く方法
- テーマだけをローカルへ置く方法
- PHPやCSSの編集
- コンテナの起動・停止・再起動
- コンテナ内のファイル確認

すべてを一度に暗記する必要はありません。

実際の設定と動作を見ながら、

> この設定は、この動きをさせるために書いている

という形で理解していきます。

---

### 12｜最初に覚えておきたい言葉

現時点では、次のように理解しておけば十分です。

```text
Docker
環境をまとめて作成・実行する仕組み

イメージ
環境を作るための元データ

コンテナ
実際に動いている環境

Docker Compose
複数のコンテナをまとめて管理する仕組み

ポート
ブラウザなどからコンテナへ入るための入口

ボリューム
コンテナを削除してもデータを残すための保存場所

バインドマウント
PC上のフォルダとコンテナ内のフォルダを接続する仕組み
```

これから実際にWordPress環境を作りながら、一つずつ詳しく確認していきます。

---

### 13｜完成後の状態

#### 環境1：WordPress全体をローカルに置く

```text
docker-wordpress-all/
├── compose.yaml
└── wordpress/
    ├── wp-admin/
    ├── wp-content/
    ├── wp-includes/
    └── wp-config.php
```

アクセス先：

```text
http://localhost:8080
```

#### 環境2：テーマだけローカルに置く

```text
docker-wordpress-theme/
├── compose.yaml
└── themes/
    └── my-docker-theme/
        ├── style.css
        ├── functions.php
        └── index.php
```

アクセス先：

```text
http://localhost:8081
```

環境2では、WordPress本体やアップロード画像、データベースなどはDockerが管理し、自分で編集するテーマだけがPC上に見える構成にします。

---

## 事前準備

### STEP 1｜Docker Desktopをインストールする

https://www.docker.com/ja-jp/products/docker-desktop/

Docker Desktopをインストールして起動します。

Docker Desktopには、今回使う次のものがまとめて含まれています。

- Docker Engine
- Docker CLI
- Docker Compose

そのため、Docker Desktopを入れれば、別途Docker Composeをインストールする必要はありません。

Macの場合は、機種によってインストーラーが異なります。

- Apple Silicon：M1、M2、M3、M4など
- Intel：古いIntel搭載Mac

Windowsの場合は、一般的にはWSL 2を利用します。公式ページにMac・Windowsそれぞれの手順があります。

インストール後、Docker Desktopを起動してください。

---

### STEP 2｜Dockerが動いているか確認する

VS Codeを開き、

```text
ターミナル
→ 新しいターミナル
```

を選びます。

次を実行します。

```bash
docker --version
```

続けて、

```bash
docker compose version
```

バージョン番号が表示されれば準備完了です。

例えば次のような表示です。

```text
Docker version ...
Docker Compose version ...
```

エラーになる場合は、まずDocker Desktopが起動しているか確認してください。

---

## PART 1｜WordPress全体をローカルに置く

最初はこちらから作ります。

この方法では、WordPress本体・テーマ・プラグイン・アップロード画像などが、すべてPC上のフォルダに作成されます。

---

### STEP 3｜作業フォルダを作る

任意の場所に、次のフォルダを作ります。

```text
docker-wordpress-all
```

VS Codeで、

```text
ファイル
→ フォルダーを開く
→ docker-wordpress-all
```

を選びます。

現時点では空のフォルダです。

```text
docker-wordpress-all/
```

---

### STEP 4｜compose.yamlを作る

フォルダ直下に、次のファイルを作ります。

```text
compose.yaml
```

以前は `docker-compose.yml` という名前がよく使われていましたが、現在のComposeでは `compose.yaml` が標準的な名前です。

どちらの名前でも利用できます。

Docker Composeは、このYAMLファイルに複数のサービスやボリュームなどを定義して、一括管理する仕組みです。

次の内容を貼り付けて保存します。

```yaml
services:
  wordpress:
    image: wordpress:php8.3-apache
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
    volumes:
      - ./wordpress:/var/www/html
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

WordPress公式Dockerイメージには、WordPressを動かすためのPHPやApache、WordPress本体が用意されています。

今回はWordPressとMySQLを別々のコンテナとして動かします。

---

### compose.yamlの意味を確認する

まだ起動せず、ひとまず内容を見てみます。

#### services

```yaml
services:
```

この下に、起動するコンテナの構成を書きます。

今回は次の2つです。

```yaml
wordpress:
db:
```

つまり、

```text
Docker Compose
├── WordPress用コンテナ
└── MySQL用コンテナ
```

という構成です。

#### image

```yaml
image: wordpress:php8.3-apache
```

Dockerイメージは、コンテナを作るための元データです。

この指定では、

- WordPress
- PHP 8.3
- Apache

が入った公式イメージを使います。

こちらはMySQLです。

```yaml
image: mysql:8.0
```

自分のPCにPHP、Apache、MySQLを個別インストールする代わりに、それぞれのイメージからコンテナを作ります。

#### ports

```yaml
ports:
  - "8080:80"
```

左側が自分のPC、右側がコンテナです。

```text
自分のPCの8080番
        ↓
WordPressコンテナの80番
```

そのため、ブラウザから次のURLでアクセスできます。

```text
http://localhost:8080
```

Apacheはコンテナ内の80番ポートで待ち受けています。

#### environment

```yaml
environment:
  WORDPRESS_DB_HOST: db:3306
  WORDPRESS_DB_NAME: wordpress
  WORDPRESS_DB_USER: wordpress
  WORDPRESS_DB_PASSWORD: wordpress_password
```

WordPressがMySQLへ接続するための設定です。

特に重要なのがこちらです。

```yaml
WORDPRESS_DB_HOST: db:3306
```

`db` は、次のサービス名を指しています。

```yaml
db:
```

Docker Composeで作られたコンテナ同士は、サービス名を使って通信できます。

つまりWordPressには、

> `db` という名前のMySQLへ接続してください

と伝えています。

#### MySQL側の設定

```yaml
environment:
  MYSQL_DATABASE: wordpress
  MYSQL_USER: wordpress
  MYSQL_PASSWORD: wordpress_password
  MYSQL_ROOT_PASSWORD: root_password
```

MySQLを初めて起動するときに、次のものを作ります。

- `wordpress` というデータベース
- `wordpress` というユーザー
- そのユーザーのパスワード
- MySQL管理者のパスワード

WordPress側とMySQL側で、データベース名・ユーザー名・パスワードを一致させています。

#### WordPress全体のマウント

```yaml
volumes:
  - ./wordpress:/var/www/html
```

これが今回の重要部分です。

左側：

```text
./wordpress
```

は、自分のPC上のフォルダです。

右側：

```text
/var/www/html
```

は、WordPressコンテナ内でWordPressが置かれる場所です。

つまり、

```text
PC側
./wordpress
        ⇅
コンテナ側
/var/www/html
```

が同じ場所として扱われます。

このように、PC上のフォルダをコンテナ内へ直接接続する方式をバインドマウントと呼びます。

ソースコードをPC側で編集し、その変更をコンテナへ即座に反映する用途に向いています。

#### データベースの保存

```yaml
volumes:
  - db_data:/var/lib/mysql
```

MySQLのデータは `db_data` というDockerボリュームへ保存します。

最後のこちらが、ボリューム自体の宣言です。

```yaml
volumes:
  db_data:
```

WordPressファイルは自分で見たいのでPCのフォルダへ保存し、MySQLデータは直接編集しないのでDockerに管理してもらう、という使い分けです。

DockerボリュームはDockerが管理する保存領域で、コンテナを削除してもデータを残す用途に適しています。

#### depends_on

```yaml
depends_on:
  - db
```

WordPressより先に、MySQLコンテナを起動させるための依存関係です。

Composeは `depends_on` に従い、依存先から順に起動・停止します。

ただし、これは「MySQLのコンテナを先に起動する」という意味で、MySQLが完全に接続可能になるまで待つ保証ではありません。

WordPress側はしばらく接続を再試行するため、通常はそのまま起動できます。

---

### WordPressを起動する

ここから実際に起動していきます。

---

### STEP 5｜構成を確認する

VS Codeのターミナルで、現在地を確認します。

Mac・Linux：

```bash
pwd
```

Windows PowerShell：

```powershell
Get-Location
```

`compose.yaml` があるフォルダにいることを確認します。

ファイル一覧も確認できます。

Mac・Linux：

```bash
ls
```

Windows：

```powershell
dir
```

次のファイルが表示されればOKです。

```text
compose.yaml
```

---

### STEP 6｜設定ファイルを検証する

次を実行します。

```bash
docker compose config
```

これは、Composeファイルの構文を確認するコマンドです。

内容が整形されて表示されれば問題ありません。

YAMLはインデントが重要です。エラーになった場合は、タブではなく半角スペースで字下げされているか確認してください。

---

### STEP 7｜コンテナを起動する

次を実行します。

```bash
docker compose up -d
```

それぞれの意味は次のとおりです。

```text
docker compose
Composeを使う

up
必要なコンテナを作成・起動する

-d
バックグラウンドで動かす
```

初回は、WordPressとMySQLのイメージがダウンロードされます。

完了すると、おおむね次のように表示されます。

```text
Container docker-wordpress-all-db-1         Started
Container docker-wordpress-all-wordpress-1  Started
```

---

### STEP 8｜動作状態を確認する

```bash
docker compose ps
```

WordPressとMySQLの2行が表示され、状態が `Up` または `running` なら起動しています。

```text
NAME                               SERVICE      STATUS
docker-wordpress-all-db-1          db           Up
docker-wordpress-all-wordpress-1   wordpress    Up
```

実際の出力には `IMAGE` や `PORTS` などの列も表示されます。ここでは要点だけを抜粋しています。

すべてのDockerコンテナを確認する場合はこちらです。

```bash
docker ps
```

---

### STEP 9｜WordPressを開く

ブラウザで次を開きます。

```text
http://localhost:8080
```

WordPressの初期設定画面が表示されます。

表示されない場合は、10〜20秒ほど待って再読み込みしてください。

---

### STEP 10｜WordPressをセットアップする

言語で日本語を選び、次の情報を入力します。

```text
サイトのタイトル：
Docker練習サイト

ユーザー名：
任意の管理者名

パスワード：
任意のパスワード

メールアドレス：
自分のメールアドレス
```

ローカル環境なので検索エンジンのチェックは大きな意味を持ちませんが、チェックを入れても構いません。

インストール後、管理画面へログインします。

```text
http://localhost:8080/wp-admin/
```

---

### STEP 11｜ローカルのファイルを確認する

VS Codeの左側を見ると、`wordpress` フォルダが作られています。

```text
docker-wordpress-all/
├── compose.yaml
└── wordpress/
    ├── wp-admin/
    ├── wp-content/
    │   ├── plugins/
    │   ├── themes/
    │   └── uploads/
    ├── wp-includes/
    └── wp-config.php
```

これはコンテナ内の `/var/www/html` とつながっています。

テーマを開発する場合は、こちらを編集します。

```text
wordpress/wp-content/themes/
```

---

### 簡単なテーマを作ってみる

ここからは、実際に自作テーマを置いて動きを確認します。

---

### STEP 12｜テーマフォルダを作る

次のフォルダを作ります。

```text
wordpress/wp-content/themes/docker-test-theme
```

その中に、次の3ファイルを作ります。

```text
docker-test-theme/
├── style.css
├── functions.php
└── index.php
```

---

### STEP 13｜style.cssを作る

```css
/*
Theme Name: Docker Test Theme
Author: Yoshimitsu
Version: 1.0.0
*/

body {
  font-family: sans-serif;
  margin: 0;
  background: #f5f5f5;
  color: #222;
}
```

WordPressは `style.css` のヘッダー情報を見て、テーマとして認識します。

---

### STEP 14｜functions.phpを作る

```php
<?php

declare(strict_types=1);

function docker_test_theme_setup(): void {
    add_theme_support('title-tag');
}

add_action('after_setup_theme', 'docker_test_theme_setup');

function docker_test_theme_enqueue_assets(): void {
    wp_enqueue_style(
        'docker-test-theme-style',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
}

add_action('wp_enqueue_scripts', 'docker_test_theme_enqueue_assets');
```

---

### STEP 15｜index.phpを作る

```php
<!doctype html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<main style="max-width: 960px; margin: 80px auto; padding: 40px; background: white;">
    <h1>Dockerでテーマ開発中です</h1>

    <p>
        このPHPファイルは、ローカルのVS Codeで編集しています。
    </p>

    <p>
        現在時刻：
        <?php echo esc_html(current_time('Y年n月j日 H:i:s')); ?>
    </p>
</main>

<?php wp_footer(); ?>
</body>
</html>
```

---

### STEP 16｜テーマを有効化する

WordPress管理画面から、

```text
外観
→ テーマ
→ Docker Test Theme
→ 有効化
```

を選びます。

サイトを表示すると、

> Dockerでテーマ開発中です

と表示されます。

`index.php` の文字を変更して保存し、ブラウザを再読み込みしてください。

コンテナを再起動しなくても変更が反映されます。

これはPC上のテーマファイルとコンテナ内のテーマファイルが、バインドマウントによって同じものとして扱われているためです。

---

### 停止・再開する

---

### STEP 17｜停止する

```bash
docker compose down
```

このコマンドではコンテナを停止・削除します。

ただし、次のデータは残ります。

- `wordpress` フォルダ内のWordPressファイル
- `db_data` ボリューム内のデータベース

---

### STEP 18｜再度起動する

```bash
docker compose up -d
```

その後、

```text
http://localhost:8080
```

へアクセスします。

先ほど作ったサイト、投稿、設定、テーマが残っていれば成功です。

---

### データを完全に初期化する場合

通常は実行しませんが、データベースも削除して最初から作り直す場合はこちらです。

```bash
docker compose down -v
```

`-v` を付けると、Composeで使用している名前付きボリュームも削除されます。

ただし今回の `wordpress` フォルダはPC上の実ファイルなので、このコマンドでは削除されません。

完全にやり直す場合は、

1. `docker compose down -v`
2. `wordpress` フォルダを削除
3. `docker compose up -d`

となります。
---

## PART 2｜テーマだけをローカルに置く

ここからは、新しい環境を別に作ります。

### この環境の考え方

```text
PC
└── 自作テーマだけ
      ⇅ バインドマウント
Docker
├── WordPress本体
├── プラグイン
├── アップロード画像
├── PHP
├── Apache
└── MySQL
```

正確には、WordPress本体などはDockerの名前付きボリュームに保存します。

テーマだけは、VS Codeで編集できるようにPC上のフォルダを直接マウントします。

---

### STEP 19｜2つ目の作業フォルダを作る

1つ目とは別の場所に、次のフォルダを作ります。

```text
docker-wordpress-theme
```

VS Codeでこのフォルダを開きます。

---

### STEP 20｜フォルダ構成を作る

次のフォルダを作ります。

```text
themes/my-docker-theme
```

現時点の構成はこうなります。

```text
docker-wordpress-theme/
└── themes/
    └── my-docker-theme/
```

---

### STEP 21｜テーマファイルを作る

`my-docker-theme` の中に、次の3ファイルを作ります。

```text
style.css
functions.php
index.php
```

#### style.css

```css
/*
Theme Name: My Docker Theme
Author: Yoshimitsu
Description: Dockerのテーマ単体マウントを試すテーマ
Version: 1.0.0
*/

body {
  margin: 0;
  font-family: sans-serif;
  background: #eef2f5;
  color: #20242a;
}

.site-main {
  width: min(960px, calc(100% - 40px));
  margin: 80px auto;
  padding: 48px;
  box-sizing: border-box;
  background: #fff;
  border-radius: 12px;
}
```

#### functions.php

```php
<?php

declare(strict_types=1);

function my_docker_theme_setup(): void {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
}

add_action('after_setup_theme', 'my_docker_theme_setup');

function my_docker_theme_enqueue_assets(): void {
    wp_enqueue_style(
        'my-docker-theme-style',
        get_stylesheet_uri(),
        [],
        wp_get_theme()->get('Version')
    );
}

add_action('wp_enqueue_scripts', 'my_docker_theme_enqueue_assets');
```

#### index.php

```php
<!doctype html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>
<?php wp_body_open(); ?>

<main class="site-main">
    <h1>テーマだけをローカルからマウントしています</h1>

    <p>
        WordPress本体はDockerボリューム側にあります。
    </p>

    <p>
        このテーマは、PC上の
        <code>themes/my-docker-theme</code>
        を編集しています。
    </p>
</main>

<?php wp_footer(); ?>
</body>
</html>
```

---

### STEP 22｜2つ目のcompose.yamlを作る

`docker-wordpress-theme` の直下に `compose.yaml` を作ります。

```text
docker-wordpress-theme/
├── compose.yaml
└── themes/
    └── my-docker-theme/
```

次の内容を貼り付けます。

```yaml
services:
  wordpress:
    image: wordpress:php8.3-apache
    ports:
      - "8081:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
    volumes:
      - wordpress_data:/var/www/html
      - ./themes/my-docker-theme:/var/www/html/wp-content/themes/my-docker-theme
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - db_data:/var/lib/mysql

volumes:
  wordpress_data:
  db_data:
```

`db_data` という名前はPART 1と同じですが、Docker Composeはフォルダ名をプロジェクト名として先頭に付けるため、PART 1のボリュームとは別物として扱われます。

---

### 2つのマウントを理解する

WordPressサービスには、2行のマウントがあります。

```yaml
volumes:
  - wordpress_data:/var/www/html
  - ./themes/my-docker-theme:/var/www/html/wp-content/themes/my-docker-theme
```

#### 1行目：WordPress全体

```yaml
- wordpress_data:/var/www/html
```

コンテナ内のWordPress全体を、Dockerの名前付きボリュームへ保存します。

```text
Dockerのwordpress_data
        ⇅
/var/www/html
```

この中には次のものが入ります。

```text
wp-admin
wp-content
wp-includes
wp-config.php
```

ただし、これはDockerが管理する領域なので、通常のFinderやエクスプローラーにはWordPress一式が表示されません。

Docker DesktopのVolumes画面から、Dockerボリュームの内容を確認することはできます。

#### 2行目：自作テーマだけ

```yaml
- ./themes/my-docker-theme:/var/www/html/wp-content/themes/my-docker-theme
```

この1つのテーマだけ、PC上のフォルダをコンテナ内へ直接接続します。

```text
PC
./themes/my-docker-theme
        ⇅
コンテナ
/var/www/html/wp-content/themes/my-docker-theme
```

この部分だけはVS Codeから直接編集できます。

#### なぜ2行必要なのか

1行目だけなら、WordPress全体は残りますが、テーマもDockerボリュームの中に入り、普段のVS Codeから扱いにくくなります。

2行目を追加すると、特定テーマの保存場所だけがPC上のフォルダへ置き換わります。

イメージとしては、

```text
/var/www/html                         Docker管理
└── wp-content                       Docker管理
    └── themes                       Docker管理
        └── my-docker-theme          PC側に差し替え
```

という状態です。

バインドマウントを既存ディレクトリへ重ねると、その場所に元からあったコンテナ側の内容は、マウント中は隠れてPC側の内容が見えるようになります。

そのため、テーマフォルダを空のままマウントすると、WordPress側にも空のテーマとして見えます。先に `style.css` などを作ったのはそのためです。

---

### 2つ目の環境を起動する

---

### STEP 23｜設定を確認する

```bash
docker compose config
```

問題がなければ起動します。

```bash
docker compose up -d
```

---

### STEP 24｜ブラウザで開く

2つ目はポートを8081にしているので、こちらを開きます。

```text
http://localhost:8081
```

1つ目の環境は8080です。

```text
全体マウント
http://localhost:8080

テーマだけマウント
http://localhost:8081
```

両方を同時に起動できます。

---

### STEP 25｜WordPressをセットアップする

先ほどとは別のWordPress環境なので、もう一度初期セットアップします。

例：

```text
サイトタイトル：
テーママウント練習

ユーザー名：
任意

パスワード：
任意

メールアドレス：
任意
```

---

### STEP 26｜テーマを有効化する

管理画面で、

```text
外観
→ テーマ
→ My Docker Theme
→ 有効化
```

を選びます。

サイトを表示すると、

> テーマだけをローカルからマウントしています

と表示されます。

---

### STEP 27｜PHPを編集する

ローカルのこちらを編集します。

```text
themes/my-docker-theme/index.php
```

例えば、

```php
<h1>テーマだけをローカルからマウントしています</h1>
```

を、

```php
<h1>PHPの編集がブラウザに反映されました</h1>
```

へ変更します。

保存してブラウザを再読み込みします。

変更が表示されれば成功です。

---

### 2つの方式の違い

| 比較 | WordPress全体 | テーマだけ |
|---|---|---|
| WordPress本体 | PC上に見える | Dockerボリューム内 |
| 自作テーマ | PC上に見える | PC上に見える |
| 他のテーマ | PC上に見える | Dockerボリューム内 |
| プラグイン | PC上に見える | Dockerボリューム内 |
| uploads | PC上に見える | Dockerボリューム内 |
| VS Codeで触る範囲 | WordPress全体 | 自作テーマだけ |
| Git管理しやすさ | 除外設定が必要 | テーマだけ管理しやすい |
| 学習用途 | 全体構造が分かりやすい | 実務的で整理しやすい |

---

### どちらを使うか

#### WordPress全体をマウントするケース

```yaml
- ./wordpress:/var/www/html
```

向いているのは、

- WordPress全体のフォルダ構造を確認したい
- 複数のテーマやプラグインをまとめて触りたい
- `wp-config.php` も直接編集したい
- 既存サイト一式をローカルへ展開したい
- Dockerの動きを目で確認しながら学びたい

というケースです。

#### テーマだけをマウントするケース

```yaml
- ./themes/my-docker-theme:/var/www/html/wp-content/themes/my-docker-theme
```

向いているのは、

- オリジナルテーマ開発
- テーマだけGitHubで管理する
- WordPress本体を自分で管理したくない
- 作業対象を明確にしたい
- チームでテーマ開発する

というケースです。

テーマ開発だけなら、最終的にはこちらの方が整理しやすいと思います。

---

### よく使うコマンド

起動

```bash
docker compose up -d
```

状態確認

```bash
docker compose ps
```

ログ確認

```bash
docker compose logs
```

WordPressだけ確認：

```bash
docker compose logs wordpress
```

リアルタイムで確認：

```bash
docker compose logs -f wordpress
```

`-f` で表示し続けている状態を終了するときは `Ctrl + C` です。

停止・コンテナ削除

```bash
docker compose down
```

再起動

```bash
docker compose restart
```

WordPressコンテナ内へ入る

```bash
docker compose exec wordpress bash
```

入ったあと、

```bash
pwd
```

を実行すると、

```text
/var/www/html
```

と表示されます。

ファイル一覧：

```bash
ls -la
```

テーマ一覧：

```bash
ls -la wp-content/themes
```

コンテナから出る：

```bash
exit
```

---

### 最初に試す順番

今日はこの順番で進めるのがよさそうです。

1. Docker Desktopを入れて起動
2. PART 1の全体マウント環境を作る
3. WordPressをインストールする
4. テーマのPHPを編集して反映を確認する
5. 一度 `down` して再起動する
6. PART 2のテーマ単体マウント環境を作る
7. 2つのフォルダ構造を見比べる
8. コンテナ内へ入ってWordPress本体を確認する

ここまでできれば、単にコマンドをコピーしただけではなく、

- イメージからコンテナが作られる
- WordPressとMySQLは別コンテナ
- ポートでブラウザから接続する
- DBはボリュームに保存される
- PC上のテーマはバインドマウントで接続される
- テーマ単体マウントでもWordPress本体はDocker側に存在する

というDockerの基本が、かなり立体的に理解できるはずです。
---

## PART 3｜チーム開発でGitHubと組み合わせる

ここまでは、自分ひとりのDocker環境を作ってきました。

最後に、この環境をチームで共有する場合の考え方を確認します。

チーム開発では基本的に、

> **GitHubには、開発環境を再現するための設定と、実際に開発するソースコードを置く。
> データベースやアップロード画像は、原則としてGitでは管理しない。**

という運用になります。

---

### 全体像

例えば、オリジナルテーマを3人で開発する場合です。

```text
GitHubリポジトリ
├── compose.yaml
├── .env.example
├── .gitignore
├── README.md
└── themes/
    └── project-theme/
        ├── style.css
        ├── functions.php
        ├── theme.json
        ├── templates/
        └── assets/
```

各メンバーはGitHubからこのリポジトリを取得します。

```text
GitHub
   ↓ git clone

AさんのPC
├── 同じcompose.yaml
└── 同じテーマ

BさんのPC
├── 同じcompose.yaml
└── 同じテーマ

CさんのPC
├── 同じcompose.yaml
└── 同じテーマ
```

全員が同じ `compose.yaml` を使って、

```bash
docker compose up -d
```

を実行します。

すると、全員のPCに同じ構成のWordPress・PHP・MySQL環境が作られます。Docker Composeは、サービス・ネットワーク・ボリュームなどを1つのYAMLファイルに定義し、まとめて起動する仕組みです。

---

### GitHubで共有するもの

#### 1．`compose.yaml`

これは基本的に共有します。

PART 1・PART 2ではパスワードやポートを直接書きましたが、チームで共有する場合は、環境ごとに変えたい値を環境変数へ出しておくと扱いやすくなります。

```yaml
services:
  wordpress:
    image: wordpress:php8.3-apache
    ports:
      - "${WP_PORT:-8080}:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE:-wordpress}
      WORDPRESS_DB_USER: ${MYSQL_USER:-wordpress}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD:-wordpress_password}
    volumes:
      - wordpress_data:/var/www/html
      - ./themes/project-theme:/var/www/html/wp-content/themes/project-theme
    depends_on:
      - db

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE:-wordpress}
      MYSQL_USER: ${MYSQL_USER:-wordpress}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-wordpress_password}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-root_password}
    volumes:
      - db_data:/var/lib/mysql

volumes:
  wordpress_data:
  db_data:
```

`${WP_PORT:-8080}` の `:-` はデフォルト値の指定です。`.env` を作り忘れても、この既定値で起動できます。

これを共有することで、

- WordPressの構成
- PHPのバージョン
- MySQLのバージョン
- コンテナ間の接続
- テーマのマウント先
- データの保存方法

をメンバー間でそろえられます。

#### 2．テーマやプラグインのソースコード

実際に開発する対象もGitHubで共有します。

テーマ開発なら、

```text
themes/project-theme/
```

プラグイン開発なら、

```text
plugins/project-plugin/
```

です。

PC上のソースコードをコンテナへバインドマウントすると、保存した変更をコンテナ側でもすぐ確認できます。Dockerの公式ドキュメントでも、ソースコードをホストPCとコンテナで共有する用途にはバインドマウントが推奨されています。

#### 3．`README.md`

チーム開発では、これがかなり重要です。

最低限、次の内容を書きます。

````markdown
# 開発環境の起動方法

## 必要なもの

- Git
- Docker Desktop

## 初回起動

```bash
git clone リポジトリURL
cd project-name
cp .env.example .env
docker compose up -d
```

ブラウザで以下へアクセスします。

http://localhost:8080

## 停止

```bash
docker compose down
```

## ログ確認

```bash
docker compose logs -f
```
````

新人や途中参加のメンバーでも、このREADMEを上から実行すれば環境を作れる状態が理想です。

#### 4．`.gitignore`

GitHubへ入れないファイルを指定します。

例えば、

```gitignore
.env
.DS_Store
node_modules/
vendor/
*.log
```

WordPress全体をローカルへ出す構成なら、必要に応じて次のような除外も考えます。

```gitignore
wordpress/wp-admin/
wordpress/wp-includes/
wordpress/wp-content/uploads/
wordpress/wp-config.php
```

ただ、テーマだけマウントする構成なら、そもそもWordPress本体がGitの作業フォルダに出てこないため、管理がかなり楽です。

GitHubは各種プロジェクト用の `.gitignore` テンプレートも公開しているので、そちらを出発点にしても構いません。

---

### GitHubで共有しないもの

#### データベースそのもの

次のボリュームは、各メンバーのPCに個別に作られます。

```yaml
volumes:
  db_data:
```

つまり、

```text
Aさんのdb_data
Bさんのdb_data
Cさんのdb_data
```

は別物です。

名前付きボリュームはDockerが管理する保存領域で、通常はGitHubに入るファイルではありません。

したがって、同じ `compose.yaml` を使っても、各メンバーが作った投稿や固定ページは自動では共有されません。

#### `uploads` の画像

メディアライブラリへアップロードした画像も、通常はGit管理しません。

理由は、

- ファイル数が増える
- 容量が大きくなる
- Gitの差分管理に向かない
- 本番の画像をすべて開発環境へ入れる必要がないことも多い

ためです。

ただし、テーマ内で使用する画像はGitで管理します。

```text
テーマ内の画像
themes/project-theme/assets/images/
→ Gitで管理する

管理画面からアップロードした画像
wp-content/uploads/
→ 原則Gitで管理しない
```

#### パスワードやAPIキー

本番のパスワードやAPIキーは、GitHubへ直接書かないようにします。

例えば、こういうファイルを用意します。

##### `.env.example`

```dotenv
WP_PORT=8080

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=change_me
MYSQL_ROOT_PASSWORD=change_me
```

これは共有します。

各メンバーはコピーして、

```bash
cp .env.example .env
```

自分の `.env` を作ります。

##### `.env`

```dotenv
WP_PORT=8080

MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=local_password
MYSQL_ROOT_PASSWORD=local_root_password
```

こちらは `.gitignore` に入れます。

```gitignore
.env
```

秘密情報はコードへ直接書かず、環境変数やシークレット管理機能を使うのが基本です。

ローカル開発だけで使う仮のDBパスワードなら大きなリスクになりにくいですが、**本番と同じパスワードは絶対に入れない**運用にします。

---

### 各メンバーの初回セットアップ

新しく参加した人は、次のように進めます。

#### 1．GitHubから取得

```bash
git clone git@github.com:example/project-name.git
```

```bash
cd project-name
```

#### 2．環境変数を作る

```bash
cp .env.example .env
```

Windows PowerShellなら、

```powershell
Copy-Item .env.example .env
```

#### 3．Dockerを起動

```bash
docker compose up -d
```

#### 4．状態を確認

```bash
docker compose ps
```

#### 5．WordPressをセットアップ

```text
http://localhost:8080
```

へアクセスします。

テーマはすでにGitHubから取得され、コンテナへマウントされています。

```text
PC
themes/project-theme
        ⇅
Docker
/var/www/html/wp-content/themes/project-theme
```

管理画面からテーマを有効化すれば、開発を開始できます。

---

### 普段の開発フロー

例えば、Aさんがヘッダーを修正するとします。

#### 1．最新状態を取得

```bash
git switch main
git pull
```

#### 2．作業ブランチを作る

```bash
git switch -c feature/header
```

#### 3．テーマを編集

```text
themes/project-theme/header.php
themes/project-theme/assets/css/header.css
```

保存すると、バインドマウントを通じてDocker内へ反映されます。

通常のPHPやCSSの変更なら、Dockerの再起動は不要です。

#### 4．ブラウザで確認

```text
http://localhost:8080
```

#### 5．コミット

```bash
git add .
git commit -m "ヘッダーのレイアウトを調整"
```

#### 6．GitHubへ送る

```bash
git push -u origin feature/header
```

#### 7．プルリクエストを作る

GitHubで、

```text
feature/header
        ↓
main
```

のPull Requestを作ります。

ほかのメンバーがコードを確認して、問題がなければ `main` へマージします。

---

### Bさんはどうやって変更を受け取る？

Aさんの変更が `main` にマージされたら、Bさんは、

```bash
git switch main
git pull
```

を実行します。

すると、PC上のテーマが更新されます。

```text
GitHubの新しいテーマ
        ↓ git pull
Bさんのテーマフォルダ
        ↓ バインドマウント
BさんのDocker内WordPress
```

ブラウザを再読み込みすれば、変更を確認できます。

つまり、GitHubで共有されるのはテーマのファイルであり、**DockerコンテナそのものをGitHubへ送っているわけではありません。**

---

### データベースはどう共有するの？

ここがWordPressチーム開発で少し難しいところです。

テーマファイルはGitで共有できますが、次のものはデータベースに入っています。

- 投稿
- 固定ページ
- メニュー
- ウィジェット
- WordPressの各種設定
- カスタムフィールドの内容
- ブロックエディターで作ったページ
- テーマカスタマイザーの設定
- 一部プラグインの設定

そのため、GitHubからテーマを取得しただけでは、全員の表示内容が完全に同じになるとは限りません。

運用方法は主に3つあります。

#### 方法1｜各自で最低限のデータを作る

テーマ開発中心なら、最初はこれでも十分です。

各メンバーが自分のWordPressで、

- テスト投稿
- 固定ページ
- メニュー
- アイキャッチ画像
- テストユーザー

を作ります。

メリットは単純なことです。

デメリットは、各自で表示内容に差が出ることです。

#### 方法2｜初期データを配布する

リーダーがWordPressのデータベースをエクスポートし、初回セットアップ用として共有します。

例えば、

```text
setup/
├── database.sql
└── uploads.zip
```

ただし、個人情報や本番の秘密情報が入らないように、開発用データへ整える必要があります。

SQLファイルをGitに入れる場合もありますが、頻繁に更新するデータベースをGitで共同編集するのはおすすめしません。

```text
初期構築用のSQL
→ 必要ならGitで共有

毎日のDB変更
→ Gitでマージしない
```

という使い分けです。

#### 方法3｜共通のステージング環境を用意する

実務では、これが分かりやすいことが多いです。

```text
各自のDocker環境
→ テーマ・プラグイン開発

共有ステージングサイト
→ 共通の投稿・設定・確認環境

本番環境
→ 公開サイト
```

各自はローカルDockerでコードを書きます。

コードはGitHub経由で共有し、まとまった段階でステージング環境へ反映します。

ページ内容や管理画面の設定は、ステージング環境を共通の基準にします。

---

### おすすめの役割分担

例えば3人チームなら、次のような運用です。

```text
Aさん
テーマのテンプレート開発

Bさん
CSS・JavaScript・ブロック開発

Cさん
管理画面設定・コンテンツ入力
```

AさんとBさんのコードはGitHubで共有します。

Cさんが入力した投稿や固定ページは、ステージング環境で共有します。

ただし、Cさんがステージングで変更したDBを、そのまま全員のローカルへ常時同期するとは限りません。

必要なタイミングで、

- DBのスナップショットを配布する
- ステージングを確認する
- 必要な設定だけ各自で再現する

などを選びます。

---

### Docker設定を変更した場合

例えばAさんがPHPを8.3から8.4へ変更したとします。

```yaml
image: wordpress:php8.4-apache
```

この変更をコミットします。

```bash
git add compose.yaml
git commit -m "開発環境のPHPを8.4へ変更"
git push
```

BさんとCさんが `git pull` したあと、次を実行します。

```bash
docker compose pull
docker compose up -d
```

設定によっては、次でも構いません。

```bash
docker compose up -d --pull always
```

自作の `Dockerfile` を使っている場合は、再ビルドします。

```bash
docker compose up -d --build
```

つまり、`compose.yaml` の変更もGitHubを通じてチーム全体へ配布できます。

---

### 各自でポートを変えたい場合

AさんのPCでは8080が空いていても、BさんのPCでは別アプリが使っているかもしれません。

そのため、`compose.yaml` に直接固定せず、環境変数にする方法があります。

```yaml
ports:
  - "${WP_PORT:-8080}:80"
```

Aさんの `.env`：

```dotenv
WP_PORT=8080
```

Bさんの `.env`：

```dotenv
WP_PORT=8081
```

環境の基本構成は同じまま、それぞれのPC事情に応じてポートだけ変えられます。

---

### 現実的なリポジトリ構成

テーマ開発なら、このくらいが扱いやすいです。

```text
project-name/
├── compose.yaml
├── .env.example
├── .gitignore
├── README.md
│
├── themes/
│   └── project-theme/
│       ├── style.css
│       ├── functions.php
│       ├── theme.json
│       ├── templates/
│       ├── parts/
│       ├── patterns/
│       └── assets/
│
├── plugins/
│   └── project-plugin/
│
└── setup/
    └── README.md
```

`plugins` は自作プラグインがある場合だけ使います。

Compose側は次のようにマウントできます。

```yaml
volumes:
  - wordpress_data:/var/www/html
  - ./themes/project-theme:/var/www/html/wp-content/themes/project-theme
  - ./plugins/project-plugin:/var/www/html/wp-content/plugins/project-plugin
```

---

### 何をGitHubで管理するか

| 対象 | GitHub管理 | 理由 |
|---|---:|---|
| `compose.yaml` | する | 開発環境を再現する |
| `Dockerfile` | する | 独自イメージの構成を共有する |
| `.env.example` | する | 必要な設定項目を共有する |
| `.env` | しない | 個人設定や秘密情報を含む |
| 自作テーマ | する | 開発対象 |
| 自作プラグイン | する | 開発対象 |
| WordPress本体 | 通常しない | Dockerイメージから用意する |
| `wp-admin` | 通常しない | WordPress本体 |
| `wp-includes` | 通常しない | WordPress本体 |
| DBボリューム | しない | Git管理するファイルではない |
| `uploads` | 通常しない | 容量・差分管理の問題 |
| 初期データSQL | 場合による | 初回環境をそろえるため |
| README | する | 起動方法やルールを共有する |

---

### まずはこの運用から始める

オリジナルテーマまたはプラグインの開発を想定すると、最初は次の形が分かりやすいです。

```text
GitHubで共有
├── compose.yaml
├── .env.example
├── README.md
├── 自作テーマ
└── 自作プラグイン

各自のDockerで管理
├── WordPress本体
├── MySQLデータ
├── インストール済みプラグイン
└── uploads

共通のステージングで管理
├── 正式なページ内容
├── 共通設定
├── クライアント確認
└── 結合テスト
```

流れは、

```text
GitHubから取得
        ↓
Dockerで各自の環境を起動
        ↓
各自がブランチで開発
        ↓
Pull Requestでレビュー
        ↓
mainへマージ
        ↓
ステージングへ反映
        ↓
確認後に本番へ反映
```

です。

Dockerは**チーム全員の開発環境をそろえる役目**、GitHubは**コードと環境設定の変更履歴を共有する役目**、ステージングは**DBを含めたサイト全体を共通確認する役目**と分けると、かなり理解しやすいです。
