#!/usr/bin/env bash
# Run the actual MOCK backend and capture its DDS trajectory from synthetic sensor input.
set -Eeuo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_dir="${1:?Usage: ./demo.sh /absolute/output/directory}"
mkdir -p "${output_dir}"
export ROS_DOMAIN_ID=226 ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST
unset ROS_STATIC_PEERS
"${module_root}/run.sh" --mock -p cloud_topic:=/fpga_material/cloud >"${output_dir}/backend.log" 2>&1 &
backend_pid=$!
trap 'kill -INT "${backend_pid}" 2>/dev/null || true; wait "${backend_pid}" 2>/dev/null || true' EXIT
set +u
source "${ROS_SETUP:-/opt/ros/jazzy/setup.bash}"
source "${module_root}/workspace/install/local_setup.bash"
set -u
"${module_root}/workspace/.venv/bin/python3" "${module_root}/examples/capture_offline.py" --output "${output_dir}"
