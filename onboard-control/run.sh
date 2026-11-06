#!/usr/bin/env bash
# Start the onboard task service using the selected aircraft configuration.
set -eo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
source "${root}/install/local_setup.bash"
exec ros2 launch onboard_control control.launch.py "$@"
