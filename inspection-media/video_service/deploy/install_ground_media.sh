#!/usr/bin/env bash
# Install the independent ground media service using the local package entry point.
set -eo pipefail
media_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
media_user="${SUDO_USER:-$(id -un)}"
media_home="$(getent passwd "${media_user}" | cut -d: -f6)"
if [[ "${1:-}" == --help ]]; then
  printf 'Usage: %s [--install-only]\n' "$0"
  exit 0
fi
if [[ "${1:-}" != '' && "${1:-}" != --install-only ]]; then exit 2; fi
[[ -x "${media_root}/.venv/bin/python" ]] || { echo 'Run ./setup.sh first' >&2; exit 1; }
media_unit="$(mktemp)"
trap 'rm -f -- "${media_unit}"' EXIT
cat > "${media_unit}" <<EOF
[Unit]
Description=Inspection media ground service
After=network-online.target
[Service]
User=${media_user}
Environment=HOME=${media_home}
WorkingDirectory=${media_root}
ExecStart=${media_root}/run.sh ground
Restart=on-failure
RestartSec=5
TimeoutStopSec=60
[Install]
WantedBy=multi-user.target
EOF
sudo install -m 0644 "${media_unit}" /etc/systemd/system/ground-media.service
sudo systemctl daemon-reload
if [[ "${1:-}" != --install-only ]]; then
  sudo systemctl enable --now ground-media.service
fi
