#!/usr/bin/env bash
# Start an independent media component from this software directory.
set -eo pipefail
media_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "${media_root}"
media_python="${PYTHON:-${media_root}/.venv/bin/python}"
export PYTHONPATH="${media_root}:${PYTHONPATH:-}"
media_mode="${1:-camera}"
if (( $# )); then shift; fi
case "${media_mode}" in
  camera) exec "${media_python}" video_service/camera_panel.py "$@" ;;
  files) exec "${media_python}" video_service/file_manager.py "$@" ;;
  ground) exec "${media_python}" video_service/ground_media.py "$@" ;;
  relay) exec "${media_python}" video_service/ground_relay.py "$@" ;;
  service) exec "${media_python}" video_service/camera_service.py "$@" ;;
  onboard)
    source /opt/ros/jazzy/setup.bash
    source "${media_root}/install/setup.bash"
    exec "${media_python}" video_service/onboard_video_node.py "$@"
    ;;
  *) printf 'Usage: ./run.sh {camera|files|ground|relay|service|onboard} [arguments]\n' >&2; exit 2 ;;
esac
