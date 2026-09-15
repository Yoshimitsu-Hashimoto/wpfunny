# 起動後に流すコマンドの正解例

```bash
docker compose up -d --build

docker compose exec wordpress wp core install \
  --url="http://localhost:8080" \
  --title="<案件名>" \
  --admin_user="admin" \
  --admin_password="password" \
  --admin_email="yesmyoshi@gmail.com" \
  --skip-email

docker compose exec wordpress wp language core install ja --activate

docker compose exec wordpress wp option update timezone_string 'Asia/Tokyo'
docker compose exec wordpress wp option update date_format 'Y年n月j日'
docker compose exec wordpress wp option update time_format 'H:i'
docker compose exec wordpress wp option update start_of_week 1

docker compose exec wordpress wp plugin install all-in-one-wp-migration wordfence --activate

# 不要なデフォルトを消す
docker compose exec wordpress wp plugin delete akismet hello
docker compose exec wordpress wp post delete \
  $(docker compose exec wordpress wp post list --post_type=post,page --post_status=any --format=ids) --force

# パーマリンク
docker compose exec wordpress wp rewrite structure '/%postname%/'
docker compose exec wordpress wp rewrite flush --hard
```

確認:

```bash
docker compose exec wordpress wp core is-installed && echo installed
docker compose exec wordpress wp option get siteurl
docker compose exec wordpress wp option get timezone_string
docker compose exec wordpress wp plugin list --status=active --field=name
docker compose exec wordpress wp post list --post_type=post,page --post_status=any --format=count   # 0
docker compose exec wordpress wp option get permalink_structure                                      # /%postname%/
```
