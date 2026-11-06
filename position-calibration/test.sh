#!/usr/bin/env bash
# Run the retained geometry, tag orientation, estimation and window regressions.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/environment.bash"
cd "${calibration_root}"
exec "${calibration_python}" -m pytest -q correction_service/test tests/correction "$@"
