#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/ubuntu/anonymous_project"
VENV_DIR="${PROJECT_DIR}/venv"
VENV_BIN="${VENV_DIR}/bin"

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Installing OS dependencies (nginx, python venv/pip, awscli)"
apt-get update -y
apt-get install -y nginx python3-venv python3-pip curl awscli

# Create venv if missing
if [ ! -x "${VENV_BIN}/python" ]; then
  echo "[INFO] Creating python venv at ${VENV_DIR}"
  python3 -m venv "${VENV_DIR}"
fi

echo "[INFO] Upgrading pip inside venv"
"${VENV_BIN}/pip" install --upgrade pip wheel setuptools

# Install python dependencies
if [ -f "${PROJECT_DIR}/requirements.txt" ]; then
  if [ -d "${PROJECT_DIR}/wheelhouse" ] && compgen -G "${PROJECT_DIR}/wheelhouse/*.whl" > /dev/null; then
    echo "[INFO] Installing requirements from wheelhouse (no internet from pip)"
    "${VENV_BIN}/pip" install --no-index --find-links "${PROJECT_DIR}/wheelhouse" -r "${PROJECT_DIR}/requirements.txt"
  else
    echo "[WARN] wheelhouse not found; installing requirements from internet (pip)"
    "${VENV_BIN}/pip" install -r "${PROJECT_DIR}/requirements.txt"
  fi
else
  echo "[WARN] requirements.txt not found; skipping pip install"
fi

# Install systemd unit + nginx config
install -m 0644 "${PROJECT_DIR}/deploy/systemd/gunicorn-app.service" /etc/systemd/system/gunicorn-app.service
systemctl daemon-reload
systemctl enable gunicorn-app

install -m 0644 "${PROJECT_DIR}/deploy/nginx/anonymous_project.nginx" /etc/nginx/sites-available/anonymous_project
ln -sf /etc/nginx/sites-available/anonymous_project /etc/nginx/sites-enabled/anonymous_project
rm -f /etc/nginx/sites-enabled/default || true

nginx -t
systemctl enable nginx

echo "[OK] Installed runtime dependencies + systemd + nginx configs"
