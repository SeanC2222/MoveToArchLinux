# Overview

This describes the ERSS zip and how to get Frame Gen going.

1) Unzip ERSS into (Steam Path)/ELDEN RING/Game folder.
2) Download the FidelityFX-SDK-v1.1.2.zip from GPUOpen: https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK/releases/tag/v1.1.2
3) extract the amd_fidelityfx_d12.dll into the ERSS/bin/ folder and overwrite the other file
4) Boot Elden Ring. Should see an overlay asking you to press home.

NOTE:
If you're still using `er-patcher` to run the game: This python utility sets the .exe updates to turn on ultrawide screen, etc. BUT, to do it, it copies the file and executes it in a temporary location.

If you want the ERSS config file that gets generated on the first execution of FrameGen on (tells you it needs a restart to work). You need to either create the file in the ELDEN RING/Game/ folder yourself, or you can open the folder while the game is running, enter the temporary `er-patcher-tmp` folder and retrieve the ERSS-FG.toml file that configures the frame gen tweak and copy it into ELDEN RING/Game/ERSS/{here}.

No compat data tweaks.
