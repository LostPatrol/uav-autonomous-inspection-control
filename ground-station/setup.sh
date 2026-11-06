#!/usr/bin/env bash
# Install the GUI Python environment and build this software's ROS packages.
set -Eeuo pipefail
readonly software_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 -m venv --system-site-packages "${software_root}/.venv"
"${software_root}/.venv/bin/python" -m pip install -r "${software_root}/requirements-gui.txt"
bash "${software_root}/build.sh"
"${software_root}/.venv/bin/python" "${software_root}/ground_station.py" --check-environment
