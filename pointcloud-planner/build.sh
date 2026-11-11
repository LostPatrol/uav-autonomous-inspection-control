#!/usr/bin/env bash
# Build the standalone CPU planner and its shared integration interfaces natively.
set -eo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cd "${root}"
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
export MAKEFLAGS="-j$(nproc)"
colcon build --base-paths src --parallel-workers "$(nproc)" \
  --cmake-args -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE=/usr/bin/python3 "$@"
