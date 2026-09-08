#!/usr/bin/env bash
# Copyright (c) 2026 北京航空航天大学
# SPDX-License-Identifier: Apache-2.0
# 在地面开发机或机载计算机上重建共享接口与机载控制器。

set -Eeuo pipefail

readonly project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly workspace_helper="${project_root}/src/onboard_control/deploy/onboard_workspace.sh"

usage() {
  cat <<'EOF'
Usage: ./build_onboard_control.sh [--verify]

不带参数时，以 Release 模式重建飞行控制包、独立修正接口与修正服务。

Options:
  --verify  检查依赖、重新构建并执行隔离冒烟验证。
  -h, --help  显示帮助。

脚本自动识别地面端 Jazzy 或兼容目标上的 ROS 发行版。它不会启动、停止或重启
机载服务，也不会发送任何飞行命令。
EOF
}

[[ -x "${workspace_helper}" ]] || {
  printf '[build-onboard] ERROR: helper is missing or not executable: %s\n' \
    "${workspace_helper}" >&2
  exit 1
}

case "${1:-}" in
  "")
    command=build
    ;;
  --verify)
    command=verify
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

printf '[build-onboard] workspace=%s\n' "${project_root}"
printf '[build-onboard] mode=%s; running services will not be restarted\n' "${command}"
export ONBOARD_WORKSPACE="${project_root}"
exec "${workspace_helper}" "${command}"
