#!/usr/bin/env bash
# Run the generic planner, or its optional coordinate/business adapter with --bridge.
set -eo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "${root}/setup.sh"
if [[ "${1:-}" == --bridge ]]; then
  shift
  exec ros2 launch avoidance_bridge avoidance.launch.py "$@"
fi
exec ros2 launch path_planning planner.launch.py "$@"
