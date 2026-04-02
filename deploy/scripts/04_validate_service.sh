#!/usr/bin/env bash
set -euo pipefail

systemctl is-active --quiet nginx
systemctl is-active --quiet gunicorn-app

code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/healthz || true)
if [ "$code" != "200" ]; then
  echo "[ERROR] /healthz returned $code"
  exit 1
fi

echo "[OK] ValidateService passed"
