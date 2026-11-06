#!/usr/bin/env bash
# Start the standalone visual marker calibration window.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/environment.bash"
exec "${calibration_python}" "${calibration_root}/correction_service/correction_panel.py" "$@"
