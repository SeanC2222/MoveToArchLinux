# Launch Options Documentation

Launch options are an injection point into the launch cycle of Steam games where you can run arbitrary code as part of the launch process. This is important in Linux where we can configure a handful of settings, pretty much only on the launch path to Proton (the compatability layer, "compat", that enables Windows software to run on Linux kernels).

## Terminology:

Mesa - The open source Linux drivers for AMD GPU hardware primarily used in the AMD/Linux gaming world. Required to leverage your AMD GPU hardware to its fullest (i.e.... _at all_).

Wine - The original Windows _compatability_ layer. This software sits between the game and the hardware, and intercepts calls to the hardware and provides a Linux specific translation. In order to use Wine, you must call the game process within a Wine context. Wine is not an emulator, nor is it a VM, but it _does_ need certain Windows references for Windows software to work on top of its compatability layer. So, it can create a "windows like" environment in a target folder that it uses to emulate things like a C:\ and a windows install. This provides a Windows .exe the required Windows context (most of the time) to operate. Wine does not encapsulate a full Windows install, but it does have a lot of the necessary library references and components for most games to work. *NOTE*: This environment adds about 400-600MB of overhead, per game, if you're running them in isolation (see: Proton).

Wine "prefix" - This is a weird word I haven't figured out the origin of, but it means "the path to the Wine environment" described under Wine. It's used interchangably with the specific path, as well as the environment itself as the pertinent detail to Wine functioning is informing it _where_ the environment is through an environmental variable, WINEPREFIX, which is in fact the path.

Proton - Steam's proprietary branch of Wine that has matured and grown to more robustly support gaming and other Steam desired features. Most people don't use Wine directly anymore, but understanding Proton is a "next step" from wine simplifies things.

GE Proton - Some guy decided Valve didn't do a good enough job, fast enough, and wrote his own branch of Proton with advanced features enabled and supported Loooooool. It works great and is pretty much the standard for "hardcore" gaming and maximizing your gaming experience.
    https://github.com/GloriousEggroll/proton-ge-custom
    Probably should donate to him: https://patreon.com/gloriouseggroll

FSR - AMD's upscaling technology used primarily for taking lower resolutions and expanding them to larger resolutions (upscaling). It can also be used by certain games to generate frames based on motion vectors of the game.

AMD Fluid Motion Frames (AFMF) - AMD's driver level frame generation technology. Not available through Mesa at this time (Dec, 2025).

MangoHud - A utility for monitoring your gaming hardware profiles. From FPS to CPU/GPU load, it's the standard choice for hardware monitoring. This also, strangely, provides certain utilities for managing a few facets of gaming (like an FPS limit). Not generally the recommended point of management.

"game mode", and `gamemoderun` - "Game mode" is basically an OS concept about balancing OS resources towards gaming processes while gaming. `gamemoderun` is a utility for enabling a game mode through a process scoping. You want this to go around the conceptual "game" invocation command that it will wrap.

gamescope - A Steam utility ("compositor"), for managing a gaming Window. It provides a window scope of management for numerous gaming features being enabled relating to the rendering pipeline. This can enable certain features a game may not natively support, but its strongest power is managing the upscaling for games that don't implement it natively. You can define the game render resolution, and the gamescope window resolution and use FSR to have _gamescope_ do the upscaling of the signal. This invocation should be as close to the steam command as possible.

Wayland - A "display server" that is "simpler and more secure replacement for x11 (the long standing display server)". It is still being developed, so it's very hit and miss on quality.

HDR (High Dynamic Range) - A visual process to enhance games, videos, rendering to offer a wider range of brightness, contracts and color.


```
PROTON_ENABLE_WAYLAND=1 WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=2 PROTON_ENABLE_HDR=1 PROTON_FSR4_UPGRADE=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16,fps_limit=124 gamemoderun mangohud gamescope -f -F fsr -W 5120 -H 1440 -w 3840 -h 1080 --mangoapp --hdr-enabled --adaptive-sync  --force-grab-cursor -- %command% >> logfile.txt 2>&1
```

PROTON_ENABLE_WAYLAND=1                  | Enables native wayland display management, MAY INTRODUCE INPUT LAG
WINE_FULLSCREEN_FSR=1                    | Enables FSR Upscaling,
                                            | Enable AMD FidelityFX Super Resolution (FSR) 1, use in conjunction with
                                            | WINE_FULLSCREEN_FSR_STRENGTH. Only works in Vulkan games (DXVK and VKD3D-Proton included).
WINE_FULLSCREEN_FSR_STRENGTH=2           | Sets sharpness. Default: 2.
                                            | AMD FidelityFX Super Resolution (FSR) strength, the default sharpening of 5 is enough without needing
                                            | modification, but can be changed with 0-5 if wanted. 0 is the maximum sharpness, higher values mean less
                                            | sharpening. 2 is the AMD recommended default and is set by GE-Proton by default.
PROTON_ENABLE_HDR=1                      | Enables HDR in Proton. Needs gamescope flag AND desktop environment enabled, AND GAME SUPPORT FOR HDR.
PROTON_FSR4_UPGRADE=1                    | Uses FSR4 over FSR3. Works with 7900xtx
                                            | Automatically download amdxcffx64.dll and upgrade games with FSR 3.1 to use FSR 4. Version to download can
                                            | be specified by supplying it as a value, like so PROTON_FSR4_UPGRADE="4.0.1", instead of 1. Downloads
                                            | version 4.0.2 of the required DLL by default. This option also disables AMD Anti-Lag 2 currently due to
                                            | various issues.
MANGOHUD_CONFIG=                         | Configuration for MangoHud whether it runs in, or out of gamescope's process
                                         | Full Configuration Options: https://github.com/flightlessmango/MangoHud?tab=readme-ov-file#environment-variables
    alpha=0.4,                              | Opacity to 40$
    show_fps_limit,                         | Shows governed FPS limit
    cpu_mhz,                                | Displays CPU frequency
    cpu_load_change                         | Changes color of label with usage
    gpu_load,                               | Displays GPU frequency
    gpu_load_change,                        | Changes color of label with usage
    frametime,                              | Shows frametime graph, and simple metrics
    gamemode,                               | Shows if gamemode is successfully enabled
    position=top-right,                     | Positions the metrics in the top-right
    font_size=24,                           | Primary metric font sizes (CPU, GPU, FPS)
    font_size_secondary=16,                 | Secondary metric font sizes (frametime, gamemode)
    fps_limit=124                           | MangoHud governed FPS limit (when no in-game, or gamescope FPS limits)


gamemoderun                              | Utility that optimizes system settings temporarily (CPU/GPU to performance, Process priorities, etc)
gamescope                                | Utility for creating a display container/environment to run game in
    -f                                      | Force fullscreen
    -b                                      | Force borderless
    -W 5120                                 | Gamescope window width (Defaults to screen resolution)
    -H 1440                                 | Gamescope window height (Defaults to screen resolution)
    -w 3840                                 | GAME width (should be lower than screen resolution if using upscaling)
    -h 1080                                 | GAME height (should be lower than screen resolution if using upscaling)
    -F fsr                                  | Use FSR upscaling
    --mangoapp                              | Enable MangoHud
    --hdr-enabled                           | Enables HDR
    --adaptive-sync                         | Enables Active sync
    --force-grab-cursor                     | Grabs cursor within gamescope context
    --expose-wayland                        | [Experimental] Exposes native wayland support. May not work well, may introduce input lag if it does work.
-- %command% >> logfile.txt 2>&1         | Steam launch game with optional logging redirect to a file


FOR DYNAMIC HANDLING OF GAMESCOPE RESOLUTIONS!

Minified Example:
```
. "/home/seanm/.local/share/Steam/setEnvironmentVariables.sh" "skyrimse"; gamescope -f -w $SMALL_RENDER_WIDTH -h $SMALL_RENDER_HEIGHT -F fsr -- %command%
```

_Bash scripts can be invoked natively in the Launch Option_. This leverages a custom script to set in-game render width for gamescope to dynamically detected values (from switching screen resolutions). It then runs the game in the "small render" version (e.g. 3840x1080, when 5120x1440), and runs in Fullscreen mode with FSR upscaling.

Note the quiet `.` at the beginning. The script is being invoked in the context of the Steam process and must be to be able to set the shareable variables.

# Game Configurations

## Armored Core VI Fires of Rubicon
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 python ac6-patcher --all --rate 180 -- gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --hdr-enabled --force-grab-cursor --adaptive-sync --mangoapp -- %command% &>> ~/Games/SteamLogs/ArmoredCoreVI/launch.txt
```
I modified the `er-patcher` for Armored Core VI (Find/replace "eldenring" => "armoredcore6"), and it works. This is just the ER launch command with that injected instead.


## Baldur's Gate 3
#### (Dec 2025)
```
gamemoderun -- %command%
```

## Borderlands 4
#### (Dec 2025)
```
. "/home/seanm/source/repos/MoveToArchLinux/Scripts/Steam/set_environment_variables.sh" "borderlands4" &>> /home/seanm/Games/SteamLogs/Borderlands4/launch.txt; PROTON_ENABLE_HDR=1 PROTON_FSR4_UPGRADE=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16,fsr,hdr gamemoderun gamescope -f -F fsr -w $SMALL_RENDER_WIDTH -h $SMALL_RENDER_HEIGHT --mangoapp --hdr-enabled --adaptive-sync  --force-grab-cursor -- %command% >> logfile.txt 2>&1
```

## Counter-Strike 2
#### (Dec 2025)
```
gamemoderun %command%
```

## Dark Souls II: Scholar of the First Sin
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -F fsr -f --hdr-enabled --adaptive-sync --mangoapp -- %command%
```
Requires heavy modding. Run game on install before changing everything. Then run `.../source/repos/MoveToArchLinux/Scripts/Steam/dark_souls_ii_fixer.sh --dark_souls_ii`

## Dark Souls III
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --hdr-enabled --force-grab-cursor --adaptive-sync --mangoapp -- %command% &>> ~/Games/SteamLogs/EldenRing/launch.txt
```

Install the Proper PC mod prior to playing to unlock FPS/ultrawide. See `.../source/repos/MoveToArchLinux/Backup Game Utils/Dark Souls III`. Extract to `/DARK SOULS III/Game/*`

## Dead Space
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr -r 120 --hdr-enabled --adaptive-sync --mangoapp -- %command%
```

Has extreme 1-5% frames. Not sure what's triggering it. When it happens GPU shoots to 100, but it seems sporadic. Needs more tuning, but this looks good currently. `-r` doesn't seem to work.

## Disco Elysium
#### (Dec 2025)
```
gamemoderun %command%
```

## Dynasty Warriors 8 (Xtreme Legends Complete Edition)
#### (Dec 2025)
```
gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --mangoapp --adaptive-sync -- %command%
```

GE-Proton doesn't run this game as of (December 2025). Have to peg it to Proton 10. Game runs odd but not because of Proton, just an odd play.

## Elden Ring
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 python er-patcher --all --rate 180 -- gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --hdr-enabled --force-grab-cursor --adaptive-sync --mangoapp -- %command% &>> ~/Games/SteamLogs/EldenRing/launch.txt
```

Elden Ring has a specialized boot layer `er-patcher` that unlocks FPS, and enables ultrawide (5120x1440) to work correctly. Local note in case my other notes get lost: `er-patcher` copies everything in the `(steam).../ELDEN RING/Game/` folder into a temporary sub folder before opening Elden Ring. This should be considered regarding some of the tweaks and mods (ERSS for example).

Special Elden Ring Linux Framegen can be installed. Mod is called ERSS, and can only be located through secondary sites (author pulled fix). This fix, when paired with `er-patcher` requires starting Elden Ring, and copying a generated config file from the temporary sub folder to the Game folder to persist the config file between executions and prevent reconfiguration every time.

## Lies of P
#### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --mangoapp --hdr-enabled --adaptive-sync -- %command%
```

## Magicka 2
#### (Dec 2025)
```
gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr -- %command%
```

This is currently rendering fully to the left of the screen, and changes to in-game resolution cause it to shrink. But it plays fine.
Doesn't seem to have ultrawide support. Not that worried about this.

## Remnant II
### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --mangoapp --hdr-enabled --adaptive-sync --force-grab-cursor -- %command%
```

## Remnant II
### (Dec 2025)
```
PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16,fsr,hdr gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --mangoapp --hdr-enabled --adaptive-sync --force-grab-cursor -- %command%
```

Ensure you tweak the in-game settings a touch. But runs pretty solid.

## Rimworld
#### (Dec 2025)
```
gamemoderun %command%
```

## Roller Coaster Tycoon 3
#### (Dec 2025)
```
gamemoderun %command%
```

GE-Proton doesn't support this game. Works with Proton 10.

Doesn't support ultrawide. Not really worth trying to fix. Can upgrade resolution to 2560x1440. `.../SteamLibrary/steamapps/compatdata/2700/pfx/drive_c/users/steamuser/AppData/Roaming/Atari/RCT3/Options.txt` and set the first line to "Resolution 2560 1440".

## SkyrimSE
#### (Dec 2025)
```
. "/home/seanm/source/repos/MoveToArchLinux/Helper Scripts/Steam/setEnvironmentVariables.sh" "skyrimse" &>> /home/seanm/Games/SteamLogs/SkryimSe/launch.txt; PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 MANGOHUD_CONFIG=alpha=0.4,show_fps_limit,cpu_mhz,gpu_load,gpu_load_change,frametime,gamemode,position=top-right,font_size=24,font_size_secondary=16,fps_limit=120 gamemoderun mangohud %command%
```

## The Sims 4
#### (Dec 2025)
```
gamemoderun %command%
```

Consider other EA titles. EA app may want to install into each prefix. Not ideal.

## Sonic Adventure 2
#### (Dec 2025)
```
gamemoderun %command%
```

## Sonic Racing: Cross Worlds
#### (Dec 2025)
```
WINEDLLOVERRIDES="winmm=n,b" gamemoderun %command%
```

This command requires a patch to make functional for 5120x1440. Download, and deploy before adding this launch command.
https://steamcommunity.com/sharedfiles/filedetails/?id=3576681189 (or see backups)

## Terraria
#### (Dec 2025)
```
PROTON_HDR_ENABLED=1 gamemoderun gamescope -W 5120 -H 1440 -w 3840 -h 1080 -f -F fsr --adaptive-sync --hdr-enabled -- %command% &>> ~/Games/SteamLogs/Terraria/launch.txt
```

Terraria can render up to 4096x1152 by ingame processes. Forcing the rendering window for the game to 3840x1080, and upscaling through gamescope fills the space in proper aspect ratio.

NOTE: If you mess with the ingame resolution and set to 4096x1152 _before_ setting gamescope, you may find yourself with a rendering that's upscaled in proper aspect ratio, but with unreachable UI elements. The gamescope window allows for 5120x1440, and so it renders based on the in-game resolution (even though gamescope says "we're only 3840x1080"), and then the upscaling to the max gamescope size happens.
The solution is to re-set the ingame resolution to the 3840x1080 setting that should be the max size.

## The Witcher 3
#### (Dec 2025)
```
PROTON_ENABLE_WAYLAND=1 PROTON_FSR4_UPGRADE=1 gamemoderun %command%
```

Steam launch path does not like gamescope. But Witcher natively supports 5120x1440. Could probably improve performance with upscaling.

## XCom: Enemy Unknown
#### (Dec 2025)
```
gamemoderun gamescope -W 2560 -H 1440 -w 1920 -h 1080 -f -F fsr -- %command%
```

XCom mouse map gets skewed with rendering larger than 1920x1080. There's _likely_ Unreal Engine .ini changes that can be made to fix this skewing, but couldn't figure it out. Instead, upscaling 1920 => 2560 seems a reasonable, easy path.

# Non-Steam Game Configurations

(JK we're going to try to use Steam for this too)

## Battle.nex
#### (Dec 2025)

Battle.Net Installer:
```
export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam
export STEAM_COMPAT_DATA_PATH=~/Games/SteamLibrary/steamapps/compatdata/847713 # 847713 - Made up AppId ("Battle", lol), but may have collisions in future.
PROTON_PATH=$STEAM_COMPAT_CLIENT_INSTALL_PATH/compatability.d/GE-Proton10-27/proton

sudo pacman -S gnutls lib32-gnutls # Required by Battle.net; Gnu TLS library so not a bad choice to have.

$PROTON_PATH waitforexitandrun ~/Downloads/Battle.net-Setup.exe
```
Was getting stuck at 45% until the gnutls libraries were installed.

Battle.Net
```
export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam
export STEAM_COMPAT_DATA_PATH=~/Games/SteamLibrary/steamapps/compatdata/847713 # 847713 - Made up AppId ("Battle", lol), but may have collisions in future.
PROTON_PATH=$STEAM_COMPAT_CLIENT_INSTALL_PATH/compatability.d/GE-Proton10-27/proton

$PROTON_PATH waitforexitandrun "$STEAM_COMPAT_DATA_PATH/pfx/drive_c/Program Files(x86)/Battle.net/Battle.net.ext"
```

If you see black screen, go to:
Gear icon in top right => Settings => Advanced => Turn _off_ hardware acceleration and restart Bnet.


# Reference Hardware

Reference Hardware used in tuning:

Motherboard:    ROG STRIX B550-F GAMING WIFI II
CPU:            AMD Ryzen 7 5800X3D 8-Core Processor
RAM:            64GB DDR4, 3600MHz
GPU:            Radeon 7900xtx, Sapphire Nitro+
Storage:        Samsung 990 M2 NVME Pro
