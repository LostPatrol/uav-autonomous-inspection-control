#!/usr/bin/env bash
# Start the sampling and window estimator with the selected aircraft profile.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/environment.bash"
config_dir="${CALIBRATION_CONFIG_DIR:-$("${calibration_python}" -c 'from project_configuration import config_file; print(config_file("correction"))')}"
exec "${calibration_python}" -m correction_service.node --ros-args -p "config_dir:=${config_dir}" "$@"
