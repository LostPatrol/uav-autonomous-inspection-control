#!/usr/bin/env bash
# Run the frozen trajectory and real-DDS tests with software solving on localhost.
set -Eeuo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set +u
source "${ROS_SETUP:-/opt/ros/jazzy/setup.bash}"
source "${module_root}/workspace/install/local_setup.bash"
set -u
export ROS_DOMAIN_ID=226 ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
unset ROS_STATIC_PEERS
export FPGA_FASTPATH_LIB="${module_root}/workspace/install/fpga_uav_native/lib/libfpga_fastpath_native.so"
"${module_root}/workspace/.venv/bin/python3" "${module_root}/tests/test_executable_trajectory.py"
"${module_root}/workspace/.venv/bin/python3" "${module_root}/tests/test_flight_backend.py"
