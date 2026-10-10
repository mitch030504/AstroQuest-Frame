# AstroQuest-Frame

Play **ASTRO BOT Rescue Mission** on **Steam Frame** with an experimental native
ARM64 Linux build of AstroQuest. The emulator runs on the headset, using FEXCore
for the PS4 game's CPU instructions, Vulkan for rendering, and SteamVR OpenXR for
stereo VR and tracking.

**[Download v0.1.1](https://github.com/mitch030504/AstroQuest-Frame/releases/tag/steam-frame-v0.1.1)**
· [Detailed setup and build guide](README-FRAME.md)
· [Report an issue](https://github.com/mitch030504/AstroQuest-Frame/issues)

> Supply your own dumped game. No game files, PS4 firmware or keys are included.

## Status

This is an experimental prerelease. Opening gameplay, stereo rendering and head
and controller tracking have been observed on Steam Frame with SteamVR/OpenXR
2.18.2. A full playthrough has not been completed.

| Feature | Current status |
| --- | --- |
| Native ARM64 build and stereo VR launch | Checked on Steam Frame |
| Head and right-controller tracking | Observed in the opening scene |
| A/B/X/Y buttons | Native Frame bindings accepted by SteamVR; latest Circle action awaits player confirmation |
| D-pad | Added in v0.1.1; gameplay behavior awaits player confirmation |
| Touchpad gadgets, microphone and separate gamepads | Implemented paths; unverified on Frame |

Windows and Quest builds have not been rebuilt or checked for these releases.

## What you need

- A Steam Frame running SteamOS, with SteamVR running and selected as the active
  OpenXR runtime.
- **Steam Linux Runtime 4.0 ARM64**, installed through Steam. The launcher uses
  its installed runtime; the release does not bundle it.
- SteamVR support for `XR_VALVE_frame_controller_interaction`. The device used
  for this port runs SteamVR/OpenXR 2.18.2.
- Your own extracted **ASTRO BOT Rescue Mission** dump, including `eboot.bin`
  and `sce_sys/param.sfo`, plus space for the game and its optional update.

The Frame launch was checked with the **US release CUSA12431**. Both US 1.00 and
1.04 executables match the guarded signatures used by the existing timing,
resolution and physics fixes. European **CUSA12392** 1.00/1.04 support is inherited
from AstroQuest; it has not been checked on Frame. Other builds are unverified.

## Install and launch

1. Download `AstroQuest-SteamFrame-ARM64.tar.gz` and `SHA256SUMS.txt` from
   [v0.1.1](https://github.com/mitch030504/AstroQuest-Frame/releases/tag/steam-frame-v0.1.1).
   In the directory containing both downloads, run:

   ```sh
   sha256sum -c SHA256SUMS.txt
   mkdir -p ~/Applications
   tar -xzf AstroQuest-SteamFrame-ARM64.tar.gz -C ~/Applications
   ```

2. Put the extracted US base game in `~/Games/AstroQuest/CUSA12431`. If you have
   update 1.04, put its extracted files in the sibling `CUSA12431-UPDATE` folder.
   Both folders need their own `sce_sys/param.sfo`. The update alone is not the
   base game. See [game preparation](README-FRAME.md#prepare-the-game) for the
   Linux PKG extraction caveat.
3. Add `~/Applications/astroquest-frame/launch.sh` as a non-Steam game. Name the
   shortcut **AstroQuest-Frame** and enable **Include in VR Library** in its
   Properties. Launch it from the headset library and close the Steam dashboard
   to give the game focus.

To use a game stored elsewhere, pass its extracted folder to the launcher:

```sh
~/Applications/astroquest-frame/launch.sh /path/to/CUSA12431
```

This Linux build launches through Steam Linux Runtime 4 ARM64. It does not need
Proton. Restart the game after replacing an older build to load the new controls.

## Frame controls

The native Frame profile keeps the four right-hand face buttons distinct:

| Frame input | PS4 input / action |
| --- | --- |
| Right A | Cross — jump / confirm |
| Right B | Circle |
| Right X | Square — attack |
| Right Y | Triangle |
| Left stick | Move |
| Left D-pad | PS4 D-pad |
| Right stick | Move a finger on the touchpad; press it to click the touchpad |
| Left View | Options |
| Both sticks pressed | Recenter |
| Left grip held + right stick flicked sideways | Turn the view in steps |
| B + Y held | Simulate blowing into the microphone |

The right stick's touchpad input is used by gadgets and may have no visible
response in the opening scene. The **right controller** supplies the virtual
controller's position and orientation. Trigger and grip gestures are described
in [the full control guide](README-FRAME.md#controls).

SteamVR's automatic Touch-controller conversion mapped Frame B, X and Y to Square.
The native Frame profile fixes that conversion. The duplicate SDL gamepad from the
Frame controllers is filtered out during VR so it cannot compete with OpenXR input.

## Updates, settings and troubleshooting

Extract a newer release into the same `~/Applications` directory, then restart
the game. Saves and configuration live separately in
`~/.local/share/astroquest/user`; replacing the application keeps them.

The default scene resolution is **816×870 per eye**. Higher resolutions and
pacing controls are documented in [settings](README-FRAME.md#settings).
Performance depends on the scene and settings; this release has no guaranteed
frame rate.

For a black screen or missing input, check the game folder, installed ARM64
runtime, SteamVR, the shortcut's VR-library flag and dashboard focus. See
[troubleshooting](README-FRAME.md#troubleshooting) before reporting a problem.
Console output is in `~/.local/share/astroquest/logs/console.log`.

## Build from source

Run on Steam Frame or an ARM64 Linux host with Git and rootless Podman available:

```sh
git clone --recurse-submodules https://github.com/mitch030504/AstroQuest-Frame.git
cd AstroQuest-Frame
bash tools/build-frame.sh
```

The script builds in a dedicated container using Valve's ARM64 Steam Runtime 4
SDK pinned to `4.0.20260805.254769`. It produces
`build/AstroQuest-SteamFrame-ARM64.tar.gz`. See
[build details](README-FRAME.md#build-from-source) for the container and dependencies.

## Upstream and other platforms

AstroQuest-Frame is based on
[evertec82/AstroQuest](https://github.com/evertec82/AstroQuest), which builds on
[bigmak94/AstroQuest](https://github.com/bigmak94/AstroQuest). Their PC performance
changes and Quest host remain in the source tree.

- [Windows PC VR reference](README-PC-VR.md)
- [Meta Quest standalone reference](README-QUEST-VR.md)
- [Upstream AstroQuest README and installation instructions](https://github.com/bigmak94/AstroQuest#readme)
- [Upstream Quest and Windows releases](https://github.com/bigmak94/AstroQuest/releases)

Those guides describe their respective platforms and upstream results. This fork's
published assets are the Steam Frame ARM64 package and its checksum.

## License and attribution

AstroQuest-Frame is licensed under
[GPL-2.0-or-later](LICENSE), as is the shadPS4 emulator it builds on. Dependencies
retain their own licenses; the archive includes them under `licenses/`. See
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for sources and release contents.

ASTRO BOT, PlayStation and PlayStation VR are trademarks of Sony Interactive
Entertainment. This project is not affiliated with, endorsed or sponsored by Sony
Interactive Entertainment, Team Asobi, Meta or Valve.

To support the original AstroQuest project, use
[its upstream support link](https://buy.stripe.com/6oU4gB5450PZ18h8aK1wY00).

## Thanks

- **The [shadPS4](https://github.com/shadps4-emu/shadPS4) team and contributors.** None of
  this would exist without their PlayStation 4 emulator: everything here is built on top of
  their years of work. Thank you!
- [zenithblue-oss/shadps4-arm64](https://github.com/zenithblue-oss/shadps4-arm64) and
  [Bachata S4](https://github.com/JICA98/Bachata-S4), for the ARM64 build of shadPS4, its FEX
  integration and the Linux runtime it runs in on Android.
- [FEX-Emu](https://github.com/FEX-Emu/FEX), which runs the game's x86-64 code on the
  headset's ARM processor.
- [Mesa](https://www.mesa3d.org/) and its Turnip driver for Adreno GPUs. Frame uses
  the SteamOS driver; the upstream Quest runtime uses
  [Vauzi-17/mesa-tu8](https://github.com/Vauzi-17/mesa-tu8).
- [LibOrbisPkg](https://github.com/maxton/LibOrbisPkg), whose PkgTool unpacks game packages
  for the PC launcher.
- Everyone who reported what went wrong, and those who sent the fix along:
  [ODevStudio](https://github.com/ODevStudio) for SteamVR and Valve Index support and the
  desktop's spectator views, [Clodo76](https://github.com/Clodo76) for finding the game's
  1.04 executable from inside, [evertec82](https://github.com/evertec82) for what stopped the
  game under SteamVR.
- [The Khronos Group](https://www.khronos.org/) for OpenXR and Vulkan,
  [vgmstream](https://github.com/vgmstream/vgmstream) for documenting Sony's audio formats,
  and [Virtual Desktop](https://www.vrdesktop.net/) for the PC streaming path.
