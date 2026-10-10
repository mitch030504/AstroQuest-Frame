# AstroQuest on Steam Frame

Native ARM64 Linux emulator with embedded FEXCore translating the PS4 game's CPU
instructions, Vulkan rendering and the headset's SteamVR OpenXR runtime.
Supply your own dumped game; no game or PS4 firmware files are included.
US release CUSA12431 versions 1.00 and 1.04 match the existing European build
signatures and use the same guarded timing, resolution and physics fixes.

## Build

On the Frame, clone this repository with submodules and run:

```sh
git clone --recurse-submodules https://github.com/mitch030504/AstroQuest.git
cd AstroQuest
bash tools/build-frame.sh
```

The script builds inside a dedicated rootless Podman container using Valve's ARM64
Steam Runtime 4 SDK, pinned to `4.0.20260805.254769`. Packages are installed inside
that container. Compilation uses two jobs. Output is
`build/AstroQuest-SteamFrame-ARM64.tar.gz`.

## Install and run

Download `AstroQuest-SteamFrame-ARM64.tar.gz` from
[the release page](https://github.com/mitch030504/AstroQuest/releases/tag/steam-frame-v0.1.1).
Install **Steam Linux Runtime 4.0 ARM64** in Steam before launching.

Extract the archive into `~/Applications`. Put the extracted US game in
`~/Games/AstroQuest/CUSA12431`, with update files in the sibling
`CUSA12431-UPDATE` directory. Both need `sce_sys/param.sfo`.

Use the PC launcher’s PKG extractor with its bundled runtime. Do not run the old
PkgTool under a newer .NET runtime using `DOTNET_ROLL_FORWARD`: its single
`DeflateStream.Read` leaves compressed blocks partly filled with zeroes. For a
source build targeting .NET 10, change that call in `PFS/PFSCReader.cs` to
`ds.ReadExactly(output, 0, hdr.BlockSz)` before extracting.

```sh
~/Applications/astroquest-frame/launch.sh
# Or pass the location of your extracted game:
~/Applications/astroquest-frame/launch.sh /path/to/CUSA12431
```

Add `launch.sh` as a non-Steam game for launching from the headset's library.
In the shortcut’s Properties, enable **Include in VR Library**. Close the Steam
dashboard to give the OpenXR session focus.
The launcher invokes the installed Steam Linux Runtime 4 ARM64 and uses the active
OpenXR runtime and system Vulkan driver. SteamVR must be running.

Saves, configuration and shader cache are under
`~/.local/share/astroquest/user`; console output is in
`~/.local/share/astroquest/logs/console.log`. Replacing the application keeps them.
PS4 firmware modules, if needed, go in `user/sys_modules`.

Frame controllers use the native Steam Frame OpenXR profile: left stick moves,
right stick controls the touchpad, and the right controller's A/B/X/Y buttons are
Cross/Circle/Square/Triangle respectively. A jumps and X attacks. Hold B + Y to
blow without a microphone. SteamVR's automatic Touch conversion maps B/X/Y to
the same button, so it must support `XR_VALVE_frame_controller_interaction`.
Triggers and grips provide the existing gadget gestures. Press the left View
button for OPTIONS, or press both sticks together to recenter. The right
controller supplies the controller's tracked pose.
The left D-pad maps to the PS4 D-pad. The right stick has no normal camera-turn
binding: it moves a finger on the touchpad for gadgets, and pressing it clicks
the touchpad. Hold the left grip and flick the right stick sideways to turn the
view in steps.
SDL gamepads, including DualSense, remain supported. Audio and microphone use
the system defaults.
While VR is active, the emulator filters out the Frame controllers' duplicate SDL gamepad
(`28de:11e0`) so their buttons and tracked pose come through OpenXR together.

The initial scene resolution is 816×870 per eye, with MSAA capped at one sample
and GPU commands flushed every 64 draws, matching the existing mobile defaults.
Set `SHADPS4_TITLE_RESOLUTION=4`, `5`
or `6` before launching to select 960×1080, 1200×1280 or 1440×1536. The existing
VR settings documented in README-PC-VR.md also apply.

## Status

Experimental: stereo VR launch, head/controller tracking and opening gameplay were
checked on Steam Frame with SteamVR/OpenXR 2.18.2. Full gameplay, gadgets,
microphone and separate gamepads remain unverified.
