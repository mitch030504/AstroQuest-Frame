#!/usr/bin/env bash
set -euo pipefail
app_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
game=${1:-"$HOME/Games/AstroQuest/CUSA12431"}
if [[ $# -gt 0 ]]; then shift; fi
[[ -f "$game/eboot.bin" && -f "$game/sce_sys/param.sfo" ]] || {
  echo "Usage: $0 <extracted game folder> [emulator arguments]" >&2; exit 1;
}
game=$(realpath "$game")
runtime="$HOME/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4-arm64/run"
[[ -x "$runtime" ]] || { echo "Install Steam Linux Runtime 4.0 ARM64 in Steam." >&2; exit 1; }
data="${XDG_DATA_HOME:-$HOME/.local/share}/astroquest"
mkdir -p "$data/user" "$data/logs"
cd "$data"
export DISPLAY=${DISPLAY:-:0}
if [[ ${SHADPS4_VR_FOVEATION:-0} == 1 ]]; then
  export SHADPS4_TITLE_RESOLUTION=${SHADPS4_TITLE_RESOLUTION:-5}
else
  export SHADPS4_TITLE_RESOLUTION=${SHADPS4_TITLE_RESOLUTION:-3}
fi
export SHADPS4_VR_FPS_CAP=${SHADPS4_VR_FPS_CAP:-60}
export SHADPS4_XR_WAIT=${SHADPS4_XR_WAIT:-30}
export SHADPS4_MAX_MSAA=${SHADPS4_MAX_MSAA:-1}
export SHADPS4_FLUSH_DRAWS=${SHADPS4_FLUSH_DRAWS:-64}
exec "$runtime" -- "$app_dir/astroquest" -g "$game/eboot.bin" "$@" \
  >>"$data/logs/console.log" 2>&1
