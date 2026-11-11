#!/usr/bin/env bash
# Check installation by default; start software MOCK or real board mode explicitly.
set -Eeuo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:---check}"
[[ $# == 0 ]] || shift
set +u
source "${ROS_SETUP:-/opt/ros/jazzy/setup.bash}"
source "${module_root}/workspace/install/local_setup.bash"
set -u
export FPGA_FASTPATH_LIB="${module_root}/workspace/install/fpga_uav_native/lib/libfpga_fastpath_native.so"
python_bin="${module_root}/workspace/.venv/bin/python3"
case "${mode}" in
  --check)
    "${python_bin}" -c 'from fpga_uav_planner_ros2.flight_backend_node import FlightBackend; from path_planning.srv import PlanMotion, SetGoal; print("Independent planner and protocol ready; no board probe started.")'
    ;;
  --mock)
    export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-226}"
    export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
    unset ROS_STATIC_PEERS
    exec "${python_bin}" -m fpga_uav_planner_ros2.flight_backend_node \
      --config "${module_root}/config/offline_mock.yaml" \
      --ros-args -r __ns:=/fpga_avoidance "$@"
    ;;
  --hardware)
    config_file="${FPGA_AVOIDANCE_CONFIG:-${module_root}/config/backend.yaml}"
    exec "${python_bin}" -m fpga_uav_planner_ros2.flight_backend_node \
      --config "${config_file}" --ros-args -r __ns:=/fpga_avoidance "$@"
    ;;
  *) echo 'Usage: ./run.sh [--check|--mock|--hardware] [ROS arguments]' >&2; exit 2 ;;
esac
