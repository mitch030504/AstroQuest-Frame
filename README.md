# AstroQuest-Frame

Play **ASTRO BOT Rescue Mission** on **Steam Frame** with an experimental native
ARM64 Linux build of AstroQuest. The emulator runs on the headset, using FEXCore
for the PS4 game's CPU instructions, Vulkan for rendering, and SteamVR OpenXR for
stereo VR and tracking.

**[Download v0.1.2](https://github.com/mitch030504/AstroQuest-Frame/releases/tag/steam-frame-v0.1.2)**
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

## What you need

- A Steam Frame running SteamOS and its built-in SteamVR/OpenXR runtime.
- **Steam Linux Runtime 4.0 - Arm64**, installed on the Frame through Steam. The launcher uses
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

Run the installer **on the Frame**, as your normal Steam user. For SSH access,
see [Valve's developer-mode setup](https://partner.steamgames.com/doc/steamhardware/steamframe/setup#developer-mode).

1. Download `AstroQuest-SteamFrame-ARM64.tar.gz` and `SHA256SUMS.txt` from
   [v0.1.2](https://github.com/mitch030504/AstroQuest-Frame/releases/tag/steam-frame-v0.1.2)
   and put both files in the same folder on the Frame.
2. In that folder, run:

   ```sh
   sha256sum -c SHA256SUMS.txt && \
   tar -xzf AstroQuest-SteamFrame-ARM64.tar.gz && \
   bash astroquest-frame/install.sh
   ```

   The installer copies the app to `~/Applications/astroquest-frame` and registers
   its Steam shortcut through the Frame's devkit interface. If the ARM64 runtime
   is missing, it opens Steam's install dialog; finish that installation in the
   headset, then rerun `install.sh`.
3. Put your extracted US base game in `~/Games/AstroQuest/CUSA12431`. Optional
   update 1.04 goes in the sibling `CUSA12431-UPDATE` folder. Both folders need
   their own `sce_sys/param.sfo`. See
   [game preparation](README-FRAME.md#prepare-the-game) for extraction details.
4. In the headset, open **Library > Non-Steam > Devkit Game: AstroQuest_Frame**.
   Close the Steam dashboard to give the game focus.

For a game stored elsewhere, pass its extracted folder to the installer:

```sh
bash astroquest-frame/install.sh /path/to/CUSA12431
```

That location is saved for the shortcut and retained when you rerun the installer
without an argument. Updating uses the same installer; quit and relaunch the game
to load the new build. This native Linux package uses Steam Linux Runtime 4 ARM64.

The SteamOS Devkit Client can also upload the app and add its shortcut; see
[the alternative workflow](README-FRAME.md#alternative-steamos-devkit-client).

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

Extract a newer release and run its `install.sh`, then restart the game. Saves and configuration live separately in
`~/.local/share/astroquest/user`; replacing the application keeps them.

The default scene resolution is **816×870 per eye**. Higher resolutions and
pacing controls are documented in [settings](README-FRAME.md#settings).
Eye-tracked foveation is experimental and opt-in; it uses the 1200×1280 preset
unless a resolution is set explicitly. See the [foveation setting](README-FRAME.md#settings).
Performance depends on the scene and settings; this release has no guaranteed
frame rate.

For a black screen or missing input, check the game folder, installed ARM64
runtime, the Frame's built-in VR runtime and dashboard focus. See
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

## Upstream

AstroQuest-Frame is based on
[evertec82/AstroQuest](https://github.com/evertec82/AstroQuest), which builds on
[bigmak94/AstroQuest](https://github.com/bigmak94/AstroQuest). This fork focuses on
the native Steam Frame ARM64 build; its releases contain the Frame package and checksum.

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
  [Bachata S4](https://github.com/JICA98/Bachata-S4), for the ARM64 build of shadPS4,
  FEX integration and Linux runtime work used by this port.
- [FEX-Emu](https://github.com/FEX-Emu/FEX), which runs the game's x86-64 code on the
  headset's ARM processor.
- [Mesa](https://www.mesa3d.org/) and its Turnip driver for Adreno GPUs. Frame uses
  the SteamOS driver.
- [LibOrbisPkg](https://github.com/maxton/LibOrbisPkg), whose PkgTool can unpack game packages.
- Everyone who reported what went wrong, and those who sent the fix along:
  [Clodo76](https://github.com/Clodo76) for finding the game's
  1.04 executable from inside, [evertec82](https://github.com/evertec82) for what stopped the
  game under SteamVR.
- [The Khronos Group](https://www.khronos.org/) for OpenXR and Vulkan, and
  [vgmstream](https://github.com/vgmstream/vgmstream) for documenting Sony's audio formats.
