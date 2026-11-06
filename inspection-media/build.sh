#!/usr/bin/env bash
# Build the shared ROS interface dependency on the current host architecture.
set -eo pipefail
media_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "${media_root}"
source /opt/ros/jazzy/setup.bash
colcon build --symlink-install --packages-select guided_interfaces --parallel-workers "$(nproc)"
