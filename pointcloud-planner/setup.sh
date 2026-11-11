#!/usr/bin/env bash
# Source the ROS distribution and this standalone workspace in the current shell.
planner_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
source "${planner_root}/install/local_setup.bash"
unset planner_root
