#!/usr/bin/env bash
# Install local Python dependencies and build the standalone calibration workspace.
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ ! -f /opt/ros/jazzy/setup.bash ]]; then
  echo '请先安装 ROS 2 Jazzy（Ubuntu 24.04）。' >&2
  exit 1
fi
sudo apt-get update
sudo apt-get install -y build-essential cmake python3-venv python3-colcon-common-extensions \
  python3-numpy python3-opencv python3-yaml python3-pytest pybind11-dev libopencv-dev v4l-utils ros-jazzy-pybind11-vendor
python3 -m venv --system-site-packages "${root}/.venv"
"${root}/.venv/bin/python" -m pip install -r "${root}/requirements.txt"
exec "${root}/build.sh"
