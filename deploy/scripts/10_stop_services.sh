#!/usr/bin/env bash
set -euo pipefail

systemctl stop gunicorn-app || true
systemctl stop nginx || true

echo "[OK] Stopped services (if running)"
