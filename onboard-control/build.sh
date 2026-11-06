#!/usr/bin/env bash
# Build the standalone onboard controller and its ROS interface contracts.
set -eo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cd "${root}"
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
export MAKEFLAGS="-j$(nproc)"
colcon build --base-paths src --packages-select guided_interfaces correction_interfaces onboard_control \
  --parallel-workers "$(nproc)" --cmake-args -DCMAKE_BUILD_TYPE=Release "$@"
