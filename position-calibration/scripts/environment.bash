# Load only ROS Jazzy and this software's local overlay.
calibration_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
calibration_python="${CALIBRATION_PYTHON:-${calibration_root}/.venv/bin/python}"
[[ -x "${calibration_python}" ]] || calibration_python=/usr/bin/python3
set +u
source /opt/ros/jazzy/setup.bash
if [[ ! -f "${calibration_root}/install/local_setup.bash" ]]; then
  echo '请先执行 ./setup.sh 或 ./build.sh。' >&2
  exit 1
fi
source "${calibration_root}/install/local_setup.bash"
set -u
export PYTHONPATH="${calibration_root}:${calibration_root}/correction_service:${PYTHONPATH:-}"
