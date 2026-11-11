#!/usr/bin/env bash
# Build local protocol, host kernels and planner, using all available CPUs.
set -Eeuo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set +u
source "${ROS_SETUP:-/opt/ros/jazzy/setup.bash}"
set -u
cd "${module_root}/workspace"
export CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)"
"${module_root}/workspace/.venv/bin/python3" -m colcon build --base-paths src \
  --packages-select path_planning fpga_uav_native fpga_uav_planner_ros2 \
  --parallel-workers "$(nproc)" \
  --cmake-args -DCMAKE_BUILD_TYPE=Release -DAMENT_CMAKE_SYMLINK_INSTALL=OFF \
  -DPython3_EXECUTABLE=/usr/bin/python3 -DPYTHON_EXECUTABLE=/usr/bin/python3
