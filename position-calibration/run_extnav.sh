#!/usr/bin/env bash
# Publish the corrected navigation pose and expose the correction application service.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/environment.bash"
parameters="$("${calibration_python}" -c 'from project_configuration import config_file; print(config_file("odin_extrinsics.yaml"))')"
exec "${calibration_root}/install/extnav_bridge/lib/extnav_bridge/extnav_to_vision_pose" --ros-args --params-file "${parameters}" "$@"
