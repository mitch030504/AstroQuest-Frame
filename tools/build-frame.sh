#!/usr/bin/env bash
# Run on Steam Frame, from a clone with initialized submodules.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
[[ $(uname -m) == aarch64 ]] || { echo "Run this build on an ARM64 Linux host." >&2; exit 1; }

sdk=registry.gitlab.steamos.cloud/steamrt/steamrt4/sdk/arm64:4.0.20260805.254769
container=astroquest-build
if [[ ${1:-} != --container ]]; then
  if ! podman container exists "$container"; then
    podman create --name "$container" --network host -v "$root:$root" -w "$root" \
      "$sdk" sleep infinity
  fi
  [[ $(podman inspect --format '{{.Config.Image}}' "$container") == "$sdk" ]] || {
    echo "The $container container uses a different SDK." >&2; exit 1;
  }
  podman start "$container" >/dev/null
  exec podman exec "$container" bash "$root/tools/build-frame.sh" --container
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends clang lld llvm cmake ninja-build git nodejs \
  pkg-config python3 libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxi-dev \
  libwayland-dev libxkbcommon-dev wayland-protocols libasound2-dev libpulse-dev \
  libudev-dev libusb-1.0-0-dev libvulkan-dev libgl-dev
export CMAKE_BUILD_PARALLEL_LEVEL=2
source_dir="$root/shadps4-arm64-main"
bash "$source_dir/runtime/scripts/build-fexcore-smoke-aarch64.sh"
"$source_dir/runtime/build/fexcore-smoke-stage/bin/fexcore-smoke"
"$source_dir/runtime/build/fexcore-smoke-stage/bin/fexcore-guest-harness"

cmake -S "$source_dir" -B "$root/build/frame" -G Ninja \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DENABLE_FEX_GUEST_CPU=ON -DENABLE_OPENXR=ON -DENABLE_BACHATA_RUNTIME=OFF \
  -DENABLE_USERFAULTFD=OFF -DENABLE_DISCORD_RPC=OFF -DENABLE_UPDATER=OFF
cmake --build "$root/build/frame" --target shadps4
readelf -h "$root/build/frame/shadps4" | grep -q 'Machine:.*AArch64'
strings "$root/build/frame/shadps4" | grep -F 'Steam Frame controllers use OpenXR' >/dev/null
strings "$root/build/frame/shadps4" | grep -F 'Steam Frame native bindings' >/dev/null

stage="$root/build/astroquest-frame"
mkdir -p "$stage"
install -m755 "$root/build/frame/shadps4" "$stage/astroquest"
strip "$stage/astroquest"
install -m755 "$root/tools/launch-frame.sh" "$stage/launch.sh"
cp "$root/LICENSE" "$root/THIRD-PARTY-NOTICES.md" "$root/README-FRAME.md" \
  "$root/README-PC-VR.md" "$stage/"
while IFS= read -r -d '' notice; do
  destination="$stage/licenses/${notice#"$source_dir/"}"
  mkdir -p "$(dirname "$destination")"
  cp "$notice" "$destination"
done < <(find "$source_dir/externals" "$source_dir/runtime/sources/fex" -type f \
  \( -iname 'LICENSE*' -o -iname 'LICENCE*' -o -iname 'COPYING*' \
     -o -iname 'NOTICE*' -o -iname 'COPYRIGHT*' \) -print0)
ldd "$stage/astroquest" | tee "$stage/needed.txt"
if grep -q 'not found' "$stage/needed.txt"; then
  echo "Unresolved runtime libraries; package is incomplete." >&2; exit 1;
fi
tar -C "$root/build" -czf "$root/build/AstroQuest-SteamFrame-ARM64.tar.gz" astroquest-frame
