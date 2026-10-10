# Third-party notices

AstroQuest-Frame and the shadPS4 emulator are licensed under GPL-2.0-or-later
(see [LICENSE](LICENSE)). The Steam Frame ARM64 release is built from this repository
and the dependencies listed below. Their license and notice files are included in the
release archive under `licenses/`.

| Component | License | Source |
| --- | --- | --- |
| shadPS4 and its bundled libraries | GPL-2.0-or-later; individual dependency licenses | [`shadps4-arm64-main/`](shadps4-arm64-main/), with dependency revisions in its submodules |
| FEXCore, used to run the game's x86-64 code on ARM64 | MIT | [FEX-Emu/FEX](https://github.com/FEX-Emu/FEX), fetched and patched by `shadps4-arm64-main/runtime/scripts/build-fexcore-smoke-aarch64.sh`; exact revision in `shadps4-arm64-main/runtime/locks/components.lock.json` |
| Khronos OpenXR loader | Apache-2.0 | [`shadps4-arm64-main/externals/openxr-sdk`](shadps4-arm64-main/externals/openxr-sdk) |
| Steam Linux Runtime 4 and SteamOS Vulkan driver | Their respective licenses | Installed by SteamOS; not distributed in the release archive |

For the GPL and LGPL source corresponding to a release, use that release's source tag
and its recorded submodule and FEX revisions. A copy of the source is available on
request for three years from each release; open an issue in this repository.

The game and PlayStation firmware are not included. No part of ASTRO BOT Rescue
Mission, the PlayStation 4 system software, or any console key is included.
