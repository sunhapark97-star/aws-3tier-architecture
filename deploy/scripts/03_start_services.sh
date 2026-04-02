#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/ubuntu/anonymous_project"
VENV_BIN="${PROJECT_DIR}/venv/bin"

# Ensure production settings are used for management commands
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-anonymous_project.settings.production}"

bash "${PROJECT_DIR}/deploy/scripts/00_inject_env_from_ssm.sh" || true

systemctl restart gunicorn-app
systemctl restart nginx

if [ -f "${PROJECT_DIR}/manage.py" ]; then
  set +e
  "${VENV_BIN}/python" "${PROJECT_DIR}/manage.py" migrate --noinput
  "${VENV_BIN}/python" "${PROJECT_DIR}/manage.py" collectstatic --noinput --clear
  set -e
fi

echo "[OK] Started services"
