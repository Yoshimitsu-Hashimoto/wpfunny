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
```

確認:

```bash
docker compose exec wordpress wp core is-installed && echo installed
docker compose exec wordpress wp option get siteurl
```
