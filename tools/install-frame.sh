#!/usr/bin/env bash
set -euo pipefail
package=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ $(uname -m) == aarch64 && $(uname -s) == Linux ]] || {
  echo "Run install.sh on the Steam Frame itself." >&2; exit 1;
}
[[ $EUID != 0 ]] || { echo "Run as your Steam user, without sudo." >&2; exit 1; }
[[ $# -le 1 ]] || { echo "Usage: $0 [extracted game folder]" >&2; exit 1; }

exec python3 - "$package" "$@" <<'PY'
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
from urllib.parse import urlencode

package = Path(sys.argv[1])
home = Path.home()
app = home / 'Applications/astroquest-frame'
gameid = 'AstroQuest_Frame'
devkit = home / 'devkit-game'

def fail(message):
    sys.exit(message)

required = ('astroquest', 'launch.sh', 'install.sh', 'LICENSE', 'THIRD-PARTY-NOTICES.md')
if not all((package / name).is_file() for name in required):
    fail('Extract the complete release archive, then run its install.sh.')
with (package / 'astroquest').open('rb') as binary:
    header = binary.read(20)
if header[:4] != b'\x7fELF' or int.from_bytes(header[18:20], 'little') != 183:
    fail('The package does not contain an ARM64 Linux executable.')
game = Path(sys.argv[2]).expanduser().resolve() if len(sys.argv) == 3 else None
if game and not all((game / name).is_file() for name in ('eboot.bin', 'sce_sys/param.sfo')):
    fail('The game folder must contain eboot.bin and sce_sys/param.sfo.')

for helpers in (Path('/usr/share/steamos-devkit/hooks'), home / 'devkit-utils'):
    if (helpers / 'devkit_utils/__init__.py').is_file():
        sys.path.insert(0, str(helpers))
        break
else:
    fail('SteamOS devkit helpers are missing. Enable Developer Mode on the Frame.')
import devkit_utils
try:
    devkit_utils.validate_steam_client()
except devkit_utils.SteamClientNotRunningException:
    fail('Start Steam on the Frame, then rerun install.sh as your normal Steam user.')

runtime = home / '.local/share/Steam/steamapps/common/SteamLinuxRuntime_4-arm64/run'
if not os.access(runtime, os.X_OK):
    subprocess.run(['steam', 'steam://install/4185400'], check=True)
    fail('Finish installing Steam Linux Runtime 4.0 - Arm64 in the headset, then rerun install.sh.')

entry = devkit / gameid
if (entry.exists() or entry.is_symlink()) and entry.resolve() != app.resolve():
    fail(f'{entry} already points to another installation; it was left untouched.')
app.mkdir(parents=True, exist_ok=True)
if package.resolve() != app.resolve():
    for source in package.iterdir():
        if source.name not in required + ('README.md', 'README-FRAME.md', 'needed.txt', 'licenses'):
            continue
        destination = app / source.name
        if source.is_dir():
            shutil.copytree(source, destination, dirs_exist_ok=True)
        else:
            # Replace running executables by rename so updates leave their mapped inode intact.
            fd, temporary = tempfile.mkstemp(prefix='.install-', dir=app)
            os.close(fd)
            try:
                shutil.copy2(source, temporary)
                os.replace(temporary, destination)
            finally:
                if os.path.exists(temporary):
                    os.unlink(temporary)
for name in ('astroquest', 'launch.sh', 'install.sh'):
    (app / name).chmod(0o755)

devkit.mkdir(exist_ok=True)
if not entry.is_symlink() and not entry.exists():
    entry.symlink_to(app, target_is_directory=True)
argv_path = devkit / f'{gameid}-argv.json'
new_shortcut = not argv_path.exists()
if game or not argv_path.exists():
    devkit_utils.save_argv(gameid, ['./launch.sh'] + ([shlex.quote(str(game))] if game else []))
devkit_utils.save_settings(gameid, {'settings': {'steam_play': '0', 'compat_tool': ''}})

try:
    with tempfile.TemporaryDirectory(prefix='astroquest-install-') as temporary:
        response = str(Path(temporary) / 'registered')
        devkit_utils.execute_steam_client_command('create-shortcut?' + urlencode({
            'response': response, 'gameid': gameid,
        }))
        with devkit_utils.wait_on_file_response(response, timeout=30):
            pass
        response = str(Path(temporary) / 'shortcuts')
        devkit_utils.execute_steam_client_command('list-shortcuts?' + urlencode({'response': response}))
        with devkit_utils.wait_on_file_response(response, timeout=30) as result:
            shortcuts = json.loads(result)
        if shortcuts.get('gameids', []).count(gameid) != 1:
            fail('Steam did not confirm a single AstroQuest_Frame shortcut. Rerun install.sh with Steam running.')
except (devkit_utils.SteamResponse_Timeout, devkit_utils.SteamResponse_Error):
    fail('App files are installed, but Steam registration failed. Rerun install.sh with Steam running.')

print(f'Installed in {app}')
print('Launch "Devkit Game: AstroQuest_Frame" from Library > Non-Steam on the Frame.')
print('Close the Steam dashboard to give the game focus. Relaunch after updating.')
if new_shortcut and game is None and not (home / 'Games/AstroQuest/CUSA12431/eboot.bin').is_file():
    print('Before playing, copy your extracted game to ~/Games/AstroQuest/CUSA12431,')
    print('or rerun install.sh with the extracted game folder as its argument.')
PY
