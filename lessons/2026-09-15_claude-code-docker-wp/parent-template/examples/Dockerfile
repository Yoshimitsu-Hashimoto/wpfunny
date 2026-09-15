# WP-CLI 入りの WordPress イメージ。
# docker compose exec wordpress wp ... で WP-CLI を使うためにこれを噛ませる。
FROM wordpress:6.8-php8.3-apache

RUN apt-get update \
 && apt-get install -y --no-install-recommends default-mysql-client less \
 && rm -rf /var/lib/apt/lists/*

ADD --chmod=0755 \
  https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  /usr/local/bin/wp

# exec は root で入るので、毎回 --allow-root を付けずに済むようにしておく
ENV WP_CLI_ALLOW_ROOT=1
