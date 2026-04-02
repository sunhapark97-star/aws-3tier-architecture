#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/ubuntu/anonymous_project"
ENV_FILE="${PROJECT_DIR}/.env"

# Resolve SSM_PREFIX:
# 1) If SSM_PREFIX is already set in the environment, use it
# 2) Else try /etc/environment (written by cloud-init/UserData)
# 3) Else fall back to /edu-arch (demo default)
if [ -z "${SSM_PREFIX:-}" ]; then
  if [ -f /etc/environment ] && grep -q '^SSM_PREFIX=' /etc/environment; then
    # shellcheck disable=SC1091
    . /etc/environment || true
  fi
fi
SSM_PREFIX="${SSM_PREFIX:-/edu-arch}"


# Default Django settings module (can be overridden via SSM or environment)
DEFAULT_DJANGO_SETTINGS_MODULE="${DEFAULT_DJANGO_SETTINGS_MODULE:-anonymous_project.settings.production}"

upsert_env() {
  local key="$1"
  local value="$2"
  if [ -z "${value}" ] || [ "${value}" = "None" ] || [ "${value}" = "null" ]; then
    return 0
  fi
  if grep -qE "^${key}=" "${ENV_FILE}" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|g" "${ENV_FILE}"
  else
    echo "${key}=${value}" >> "${ENV_FILE}"
  fi
}

# Resolve region via instance identity document (IMDSv2 compatible)
get_region() {
  local token=""
  token="$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60" || true)"
  if [ -n "${token}" ]; then
    curl -s -H "X-aws-ec2-metadata-token: ${token}" http://169.254.169.254/latest/dynamic/instance-identity/document       | python3 -c 'import sys,json; print(json.load(sys.stdin).get("region",""))'
  else
    curl -s http://169.254.169.254/latest/dynamic/instance-identity/document       | python3 -c 'import sys,json; print(json.load(sys.stdin).get("region",""))'
  fi
}

REGION="$(get_region)"
if [ -n "${REGION}" ]; then
  export AWS_DEFAULT_REGION="${REGION}"
fi

mkdir -p "${PROJECT_DIR}"
touch "${ENV_FILE}"
chown ubuntu:ubuntu "${ENV_FILE}"
chmod 600 "${ENV_FILE}"

# Local cache default (diagram: Local Redis/Local Cache)
upsert_env "REDIS_HOST" "127.0.0.1"
upsert_env "REDIS_PORT" "6379"

# DB params (created by CloudFormation as SSM Parameters)
DB_HOST="$(aws ssm get-parameter --name "${SSM_PREFIX}/db/host" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || true)"
DB_NAME="$(aws ssm get-parameter --name "${SSM_PREFIX}/db/name" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || true)"
DB_USER="$(aws ssm get-parameter --name "${SSM_PREFIX}/db/user" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || true)"
DB_PASSWORD="$(aws ssm get-parameter --name "${SSM_PREFIX}/db/password" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || true)"

upsert_env "DB_HOST" "${DB_HOST}"
upsert_env "DB_NAME" "${DB_NAME}"
upsert_env "DB_USER" "${DB_USER}"
upsert_env "DB_PASSWORD" "${DB_PASSWORD}"
# Django core settings (optional)
DJANGO_SECRET_KEY_VALUE="$(aws ssm get-parameter --with-decryption --name "${SSM_PREFIX}/django/secret_key" --query "Parameter.Value" --output text 2>/dev/null || true)"
upsert_env "DJANGO_SECRET_KEY" "${DJANGO_SECRET_KEY_VALUE}"

DJANGO_ALLOWED_HOSTS_VALUE="$(aws ssm get-parameter --name "${SSM_PREFIX}/django/allowed_hosts" --query "Parameter.Value" --output text 2>/dev/null || true)"
upsert_env "DJANGO_ALLOWED_HOSTS" "${DJANGO_ALLOWED_HOSTS_VALUE}"

DJANGO_DEBUG_VALUE="$(aws ssm get-parameter --name "${SSM_PREFIX}/django/debug" --query "Parameter.Value" --output text 2>/dev/null || true)"
upsert_env "DJANGO_DEBUG" "${DJANGO_DEBUG_VALUE}"

STATIC_BUCKET_VALUE="$(aws ssm get-parameter --name "${SSM_PREFIX}/app/static_bucket" --query "Parameter.Value" --output text 2>/dev/null || true)"
upsert_env "STATIC_BUCKET" "${STATIC_BUCKET_VALUE}"



# Optionally set Django settings module (useful for manage.py and gunicorn)
DJANGO_SETTINGS_MODULE_VALUE="$(aws ssm get-parameter --name "${SSM_PREFIX}/django/settings_module" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || true)"
if [ -z "${DJANGO_SETTINGS_MODULE_VALUE}" ] || [ "${DJANGO_SETTINGS_MODULE_VALUE}" = "None" ] || [ "${DJANGO_SETTINGS_MODULE_VALUE}" = "null" ]; then
  DJANGO_SETTINGS_MODULE_VALUE="${DEFAULT_DJANGO_SETTINGS_MODULE}"
fi
upsert_env "DJANGO_SETTINGS_MODULE" "${DJANGO_SETTINGS_MODULE_VALUE}"


chown ubuntu:ubuntu "${ENV_FILE}"
chmod 600 "${ENV_FILE}"

echo "[OK] Injected env values from SSM (${SSM_PREFIX})"
