#!/usr/bin/env bash
# Start the independent ground station with its configured Python runtime.
set -Eeuo pipefail
readonly software_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GROUND_STATION_PYTHON="${GROUND_STATION_PYTHON:-${software_root}/.venv/bin/python}"
exec bash "${software_root}/scripts/ground/start_ground_all.sh" "$@"
