#!/usr/bin/env bash
# Create this software's Python environment and compile its standalone ROS workspace.
set -Eeuo pipefail
module_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python_bin="${PROJECT_PYTHON:-/usr/bin/python3}"
if [[ ! -x "${module_root}/workspace/.venv/bin/python3" ]]; then
  "${python_bin}" -m venv --system-site-packages "${module_root}/workspace/.venv"
fi
"${module_root}/workspace/.venv/bin/python3" -c 'import numpy, yaml, colcon_core'
exec "${module_root}/build.sh" "$@"
