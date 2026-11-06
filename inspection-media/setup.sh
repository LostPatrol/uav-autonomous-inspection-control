#!/usr/bin/env bash
# Create the media software's Python environment and seed local ground settings.
set -eo pipefail
media_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "${media_root}"
python3 -m venv --system-site-packages .venv
.venv/bin/python -m pip install -r requirements.txt
if [[ ! -f config/ground/media.json ]]; then
  cp config/ground/media.example.conf config/ground/media.json
fi
printf 'Environment ready. Run ./run.sh files or ./run.sh camera.\n'
