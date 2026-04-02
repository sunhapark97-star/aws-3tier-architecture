#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/ubuntu/anonymous_project"
ENV_FILE="${PROJECT_DIR}/.env"

mkdir -p "${PROJECT_DIR}"
chown -R ubuntu:ubuntu "${PROJECT_DIR}"

mkdir -p "${PROJECT_DIR}/logs" "${PROJECT_DIR}/staticfiles" "${PROJECT_DIR}/media"
chown -R ubuntu:ubuntu "${PROJECT_DIR}/logs" "${PROJECT_DIR}/staticfiles" "${PROJECT_DIR}/media"

if [ ! -f "${ENV_FILE}" ]; then
  cat > "${ENV_FILE}" <<'EOF'
DJANGO_SETTINGS_MODULE=anonymous_project.settings.production
# DB_HOST=
# DB_NAME=
# DB_USER=
# DB_PASSWORD=
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
EOF
  chown ubuntu:ubuntu "${ENV_FILE}"
  chmod 600 "${ENV_FILE}"
fi

bash deploy/scripts/00_inject_env_from_ssm.sh || true

echo "[OK] Prepared directories and env."
