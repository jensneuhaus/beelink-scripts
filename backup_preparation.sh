#!/bin/bash

echo "========== Backup preparation started =========="

echo "--------> Paperless..."

docker exec paperless document_exporter /usr/src/paperless/backup

echo "--------> Gitea..."

docker exec -u git -it -w /backups gitea  bash -c '/usr/local/bin/gitea dump -c /etc/gitea/app.ini'

echo "--------> Pinging healthcheck..."

curl -m 10 --retry 5 https://hc-ping.com/7a592111-712b-4c68-841d-52b799fa237a

echo "========== Backup preparation ✅ =========="
