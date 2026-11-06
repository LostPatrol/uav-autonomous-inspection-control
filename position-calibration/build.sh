#!/usr/bin/env bash
# Build all native and ROS interface packages on the current processor architecture.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
python="${CALIBRATION_PYTHON:-${root}/.venv/bin/python}"
[[ -x "${python}" ]] || python=/usr/bin/python3
set +u
source /opt/ros/jazzy/setup.bash
set -u
cd "${root}"
exec "${python}" -m colcon build --base-paths src correction_service \
  --packages-select correction_interfaces correction_native correction_service extnav_bridge \
  --parallel-workers "$(nproc)" --cmake-args -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="${python}"
