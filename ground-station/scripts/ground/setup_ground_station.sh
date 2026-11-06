#!/usr/bin/env bash
# Preserve the GUI setup entry point for desktop integration.
set -Eeuo pipefail
readonly software_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec bash "${software_root}/setup.sh" "$@"
