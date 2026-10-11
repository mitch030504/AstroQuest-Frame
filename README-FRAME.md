# AstroQuest-Frame setup and build guide

Native ARM64 Linux build of AstroQuest for Steam Frame, using embedded FEXCore,
Vulkan and the headset's SteamVR OpenXR runtime. For a quick start and the current
validation status, see [README.md](README.md).

## Requirements

- Steam Frame with its built-in SteamVR/OpenXR runtime.
- **Steam Linux Runtime 4.0 - Arm64**, installed on the Frame in Steam. The launcher expects it at
  `~/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4-arm64/run`.
- SteamVR support for `XR_VALVE_frame_controller_interaction` for the native Frame
  buttons. SteamVR/OpenXR 2.18.2 was used on the device during this port.
- Your own extracted game dump. No game files, firmware or keys are included.

The tested launch uses **US CUSA12431**. Its 1.00 and 1.04 executables match the
existing European signatures and use the same guarded timing, resolution and
physics fixes. European CUSA12392 support is inherited and unverified on Frame;
pass its folder explicitly to the launcher. Other builds are unverified.

## Install

Download the ARM64 archive and `SHA256SUMS.txt` from
[the v0.2.0 release](https://github.com/mitch030504/AstroQuest-Frame/releases/tag/steam-frame-v0.2.0).
Put both files in a folder on the Frame, then run these commands **on the Frame**,
using a terminal or SSH as your normal Steam user:

```sh
sha256sum -c SHA256SUMS.txt && \
tar -xzf AstroQuest-SteamFrame-ARM64.tar.gz && \
bash astroquest-frame/install.sh
```

For SSH access, see [Valve's developer-mode setup](https://partner.steamgames.com/doc/steamhardware/steamframe/setup#developer-mode).
Run the installer without `sudo`.

The installer:

- Checks the ARM64 package and that Steam is running.
- Opens the installation dialog for Steam Linux Runtime 4.0 - Arm64 if it is
  missing. Finish that download in the headset, then rerun the installer.
- Copies the application into `~/Applications/astroquest-frame`.
- Registers **Devkit Game: AstroQuest_Frame** through Steam's devkit interface
  and confirms that Steam lists the shortcut.

The installer uses the devkit helpers supplied on the Frame. It creates
`~/devkit-game/AstroQuest_Frame` as a link to the app,
with the shortcut's configuration alongside it. Repeating the installation
updates the same devkit title. Existing saves remain in the separate data directory.

To choose a game folder, pass it to the installer:

```sh
bash astroquest-frame/install.sh /path/to/CUSA12431
```

The folder must contain `eboot.bin` and `sce_sys/param.sfo`. Rerunning without an
argument preserves the saved location; a new install uses the default US path.
Game files are prepared separately, as described below.

## Prepare the game

Put the extracted US base game in `~/Games/AstroQuest/CUSA12431`. If you have the
1.04 update, extract it into the sibling `CUSA12431-UPDATE` directory. Each folder
needs its own `sce_sys/param.sfo`; the update alone cannot replace the base game.
The launcher still points at the base game's `eboot.bin` and the emulator loads
its sibling update.

```text
~/Games/AstroQuest/
├── CUSA12431/
│   ├── eboot.bin
│   ├── sce_sys/param.sfo
│   └── ...remaining base-game files
└── CUSA12431-UPDATE/          # optional
    ├── sce_sys/param.sfo
    └── ...extracted update files
```

The launcher accepts an extracted folder, not a PKG file. To extract a package made
from your own dump, use PkgTool from the
[upstream AstroQuest PC release](https://github.com/evertec82/AstroQuest/releases)
on a Windows PC, then copy the extracted folders to Frame.

### Linux PKG extraction caveat

Running the old PkgTool with `DOTNET_ROLL_FORWARD` under a newer .NET runtime
produced incomplete decompressed blocks during this port: the game could pass the
title screen and then fail while loading the opening scene.

For the LibOrbisPkg source build targeting .NET 10 used to repair that extraction,
the call in `LibOrbisPkg/PFS/PFSCReader.cs` must read the entire output buffer:

```csharp
ds.ReadExactly(output, 0, hdr.BlockSz);
```

Re-extract both the base and update after fixing the extractor. The game's
`param.sfo` is a separate package entry and must also be extracted into `sce_sys`.
PkgTool and game files are not included in the Frame archive.

## Launch in VR

After installation, choose **Library > Non-Steam > Devkit Game: AstroQuest_Frame**
on the headset. Close the Steam dashboard so the OpenXR session receives input.
The launcher uses the Frame's built-in VR runtime, installed Steam Linux Runtime
4 ARM64 and system Vulkan driver.

For a terminal launch from the default installation:

```sh
~/Applications/astroquest-frame/launch.sh
~/Applications/astroquest-frame/launch.sh /path/to/CUSA12431
```

Extra emulator arguments may follow the game folder. Quit and relaunch after
updating so the running game loads the new binary and bindings.

### Alternative: SteamOS Devkit Client

You can deploy from a PC with the
[SteamOS Devkit Client](https://partner.steamgames.com/doc/steamhardware/steamframe/loadgames).
Extract the archive **on that PC**. Enable Developer Mode on the Frame, select
**Pair new host**, register the Frame in the client's **Devkits** tab, and confirm
pairing in the headset. Open **Title Upload** and use:

| Field | Value |
| --- | --- |
| Name | `AstroQuest_Frame` |
| Local Folder | The extracted `astroquest-frame` folder on your PC, containing `astroquest` and `launch.sh` |
| Start Command | `./launch.sh` |
| Runtime | `Not specified` — the packaged launcher invokes Runtime 4 ARM64 itself |

Upload, then use **Start** or launch the resulting devkit game from the headset's
Non-Steam library. Install Runtime 4 ARM64 on the Frame before launching; the
installer above opens its Steam dialog when needed. Devkit title IDs use
underscores here because the client's name validation does not accept hyphens.
A custom game path can follow `./launch.sh` as a quoted argument in Start Command.

## Controls

These are the native Frame bindings in v0.1.1 and later, with the default right controller
supplying the virtual controller's position and orientation:

| Frame input | PS4 input / behavior |
| --- | --- |
| Right A | Cross — jump / confirm |
| Right B | Circle |
| Right X | Square — attack |
| Right Y | Triangle |
| Left D-pad | PS4 Up / Down / Left / Right |
| Left stick | Move |
| Left stick pressed | L3 |
| Right stick moved | Move a finger on the PS4 touchpad |
| Right stick pressed | Touchpad click |
| Left View | Options; hold for about a second to recenter |
| Both sticks pressed together | Recenter |
| Left grip held + right stick flicked sideways | Turn the view, normally 30 degrees per flick |
| B + Y held together | Simulate blowing; the combined press is consumed by this gesture |
| Left / right trigger | L2 / R2, plus the gadget gestures below |
| Left / right grip | L1 / R1, plus the gadget gestures below |

The right stick's touchpad input can appear inactive before a gadget needs it.
Turning with the left-grip gesture temporarily takes over from touchpad movement.
The D-pad sends ordinary PS4 D-pad input; its visible effect depends on the screen.

The existing gadget gestures, with the default controller hand, are:

| Input | Touchpad gesture / intended use |
| --- | --- |
| Right trigger held | Press and hold — water cannon / machine gun |
| Right grip pressed | Swipe forward — hook / throwing stars / chests |
| Left trigger pulled, then released | Pull back and release — catapult |

Gadget behavior and microphone input remain unverified on Frame. Audio and
microphone use the system default devices. Separate SDL gamepads, including
DualSense, retain the existing input path but are also unverified on Frame.

The native profile avoids SteamVR's automatic Touch conversion, which mapped
Frame B, X and Y to Square. During VR, the emulator filters out the Frame
controllers' duplicate SDL gamepad (`28de:11e0`) so OpenXR controls their buttons
and tracked pose together. Restart an older running build to load these bindings.

## Settings

Set environment variables before launching, or use Steam launch options of the
form `NAME=value %command%`. The defaults below refer to `tools/launch-frame.sh`.

| Setting | Behavior |
| --- | --- |
| `SHADPS4_TITLE_RESOLUTION=3` | 816×870 per eye; default when foveation is off |
| `SHADPS4_TITLE_RESOLUTION=4` | 960×1080 per eye |
| `SHADPS4_TITLE_RESOLUTION=5` | 1200×1280 per eye; default when foveation is enabled |
| `SHADPS4_TITLE_RESOLUTION=6` | 1440×1536 per eye |
| `SHADPS4_VR_FOVEATION=1` | Experimental eye-tracked variable-rate shading; defaults to preset 5 unless a resolution is explicitly set |
| `SHADPS4_MAX_MSAA=1` | Default maximum of one MSAA sample |
| `SHADPS4_FLUSH_DRAWS=64` | Default GPU command flush interval |
| `SHADPS4_XR_WAIT=30` | Default wait, in seconds, for a headset |
| `SHADPS4_VR_TURN=30` | Default turn step in degrees; `0` disables stick turning |

For example:

```sh
SHADPS4_TITLE_RESOLUTION=4 ~/Applications/astroquest-frame/launch.sh
```

Enable eye-tracked foveation from the Frame shortcut's launch options with
`SHADPS4_VR_FOVEATION=1 %command%`. It requires OpenXR eye-gaze support and
Vulkan fragment-shading-rate attachments. If either is unavailable, the game
uses full-rate shading and records the fallback in its console log. The gaze
sample is mapped onto the per-eye scene passes; invalid or older than
100 ms samples also use full-rate shading. On the Frame, detail was
seen to follow the player's gaze, and one level held 45–51 frames a second at
1200×1280. It has not been benchmarked against full-rate shading in the same
scene, and does not promise a performance gain.

The inherited pacing code defaults to `SHADPS4_VR_PACE=1`, targeting one rendered
frame per headset refresh. The launcher's `SHADPS4_VR_FPS_CAP=60` default does not
override that fixed pace. To select the governor and apply its FPS cap, use
`SHADPS4_VR_PACE=0` together with `SHADPS4_VR_FPS_CAP=60`. Available frame rates are
quantized to the headset refresh rate; performance still depends on scene load.

## Saves, updates and logs

| Location | Contents |
| --- | --- |
| `~/Applications/astroquest-frame/` | Installed application, launcher and documentation |
| `~/.local/share/astroquest/user/` | Saves, configuration and shader cache |
| `~/.local/share/astroquest/user/sys_modules/` | Your PS4 firmware modules, if needed |
| `~/.local/share/astroquest/logs/console.log` | Appended console output |
| `~/.local/share/astroquest/user/log/shad_log.txt` | Emulator log |

If `XDG_DATA_HOME` is set, the data and logs use `$XDG_DATA_HOME/astroquest`.
Extract a newer archive, run its `install.sh`, and restart the game.
The installer replaces the application and preserves the separate save directory.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Installer reports missing Steam | Start Steam and run as the logged-in Steam user, without sudo |
| Launcher prints its usage and exits | Pass an extracted game folder containing `eboot.bin` and `sce_sys/param.sfo` |
| Installer opens a runtime installation dialog | Finish installing Steam Linux Runtime 4.0 - Arm64 in the headset, then rerun `install.sh` |
| Flat window or black headset view | Check that the Frame's built-in VR runtime is running and inspect the console log |
| Controllers do not respond | Close the Steam dashboard and give the game focus |
| B, X and Y all act as Square | Restart with v0.1.1 and check for `Steam Frame native bindings` in the log; the runtime must offer the Frame extension |
| D-pad does not respond | Restart with v0.1.1; check in a screen that uses the D-pad |
| Right stick appears inactive | It supplies touchpad input; try it when a gadget uses the touchpad, or hold the left grip to turn the view |
| Game fails after the title while loading | Check that both game folders were extracted completely; see the Linux PKG caveat above |

When reporting an issue, include the release version, SteamVR version, game serial
and version, the scene where it occurs, and the relevant log excerpt. A full game
playthrough, latest Circle/D-pad gameplay checks, gadgets, microphone and separate
gamepads are still outstanding.

## Build from source

Run on Steam Frame or an ARM64 Linux host with Git and rootless Podman available.
The first build needs network access for the SDK image, dependencies and locked
FEX checkout:

```sh
git clone --recurse-submodules https://github.com/mitch030504/AstroQuest-Frame.git
cd AstroQuest-Frame
bash tools/build-frame.sh
```

The script uses the dedicated Podman container `astroquest-build`, with Valve's
ARM64 Steam Runtime 4 SDK pinned to `4.0.20260805.254769`. Packages are installed
inside that container. Keep the clone at the same path when reusing its container.
The emulator compilation uses two jobs; the FEX build uses its existing script.
The build also runs the FEX smoke/harness checks and checks ARM64 output and
runtime library resolution.

Output is `build/AstroQuest-SteamFrame-ARM64.tar.gz`; its staging directory is
`build/astroquest-frame/`. Install that archive using its `install.sh`, as described above.

The container stays running after the script finishes. To stop it after building:

```sh
podman stop astroquest-build
```
