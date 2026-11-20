#!/usr/bin/env bash
set -euo pipefail

POOL="pool-final"
NET="net-prod"
PROXY_IP="10.10.10.10"
APP_IP="10.10.10.11"
DB_IP="10.10.10.12"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="SenhaForteWP2026!"
SITE_URL="https://servico.lab:8444"

lxc network show "$NET" >/dev/null 2>&1 || lxc network create "$NET" ipv4.address=10.10.10.1/24 ipv4.nat=true ipv6.address=none
lxc storage show "$POOL" >/dev/null 2>&1 || lxc storage create "$POOL" dir
lxc storage volume show "$POOL" vol-db >/dev/null 2>&1 || lxc storage volume create "$POOL" vol-db

for p in perfil-base perfil-db perfil-app perfil-proxy; do
  lxc profile show "$p" >/dev/null 2>&1 || lxc profile create "$p"
  lxc profile edit "$p" < "profiles/${p}.yaml"
done

lxc info db >/dev/null 2>&1 || lxc init ubuntu:24.04 db --storage "$POOL" --profile perfil-base --profile perfil-db
lxc config device show db | grep -q "^dados:" || lxc config device add db dados disk pool="$POOL" source=vol-db path=/var/lib/mysql
lxc config device override db eth0 ipv4.address="$DB_IP" >/dev/null 2>&1 || lxc config device set db eth0 ipv4.address="$DB_IP"
lxc config set db snapshots.expiry 7d
lxc storage volume set "$POOL" vol-db snapshots.expiry 7d

lxc info app >/dev/null 2>&1 || lxc init ubuntu:24.04 app --storage "$POOL" --profile perfil-base --profile perfil-app
lxc config device override app eth0 ipv4.address="$APP_IP" >/dev/null 2>&1 || lxc config device set app eth0 ipv4.address="$APP_IP"

lxc info proxy >/dev/null 2>&1 || lxc init ubuntu:24.04 proxy --storage "$POOL" --profile perfil-base --profile perfil-proxy
lxc config device override proxy eth0 ipv4.address="$PROXY_IP" >/dev/null 2>&1 || lxc config device set proxy eth0 ipv4.address="$PROXY_IP"
lxc config device show proxy | grep -q ":8444" || lxc config device add proxy https-port proxy listen=tcp:0.0.0.0:8444 connect=tcp:127.0.0.1:443

lxc start db app proxy 2>/dev/null || true
for c in db app proxy; do
  lxc exec "$c" -- cloud-init status --wait >/dev/null 2>&1 || true
done

lxc file push conf/config-mariadb.sh db/root/config-mariadb.sh
lxc exec db -- bash /root/config-mariadb.sh "$APP_IP" "$DB_NAME" "$DB_USER" "$DB_PASS"

lxc file push conf/instala-wp.sh app/root/instala-wp.sh
lxc exec app -- bash /root/instala-wp.sh "$DB_IP" "$DB_PASS" "$SITE_URL"

lxc file push conf/tls/servico.crt proxy/etc/ssl/certs/servico.crt
lxc file push conf/tls/servico.key proxy/etc/ssl/private/servico.key
lxc exec proxy -- chmod 600 /etc/ssl/private/servico.key
lxc file push conf/nginx-servico.conf proxy/etc/nginx/sites-available/servico.conf
lxc exec proxy -- ln -sf /etc/nginx/sites-available/servico.conf /etc/nginx/sites-enabled/servico.conf
lxc exec proxy -- rm -f /etc/nginx/sites-enabled/default
lxc exec proxy -- nginx -t
lxc exec proxy -- systemctl reload nginx
echo "Deploy concluido com sucesso! Acesse: $SITE_URL"
