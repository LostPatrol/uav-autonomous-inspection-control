#!/usr/bin/env bash
# Build the ground station interfaces and visualization package.
set -Eeuo pipefail
readonly software_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set +u
source "${ROS_SETUP:-/opt/ros/jazzy/setup.bash}"
set -u
cd "${software_root}"
colcon build --packages-select guided_interfaces guided_sim \
  --parallel-workers "$(nproc)" \
  --cmake-args -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE=/usr/bin/python3
