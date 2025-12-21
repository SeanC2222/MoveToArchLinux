#!/bin/bash

export STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/seanm/.local/share/Steam
[ -d $STEAM_COMPAT_CLIENT_INSTALL_PATH ] && echo "Steam Client path found." || (echo "Steam client path not found at" $STEAM_COMPAT_CLIENT_INSTALL_PATH && exit -1)

VORTEX_PATH=/home/games_ssd/Vortex/
mkdir -p "$VORTEX_PATH" && echo "Vortex directory ready."

export FAKE_VORTEX_APPID=823578
PFX_PATH=$VORTEX_PATH/$FAKE_VORTEX_APPID

mkdir -p "$PFX_PATH" && echo "Vortex Prefix directory ready."

export STEAM_COMPAT_DATA_PATH=$PFX_PATH

PROTON_VERSION=GE-Proton10-26
PROTON_PATH=$STEAM_COMPAT_CLIENT_INSTALL_PATH/compatibilitytools.d/$PROTON_VERSION/proton

[ -f $PROTON_PATH ] && echo "Found proton version $PROTON_VERSION" || { echo "Couldn't find proton $PROTON_PATH"; exit 1; }

if find "$PFX_PATH" -mindepth 1 -print -quit 2>/dev/null | grep -q .
    then echo "Prefix populated."
    else echo "Building prefix " $PFX_PATH && "$PROTON_PATH" throwawayInput
fi

VORTEX_EXE_PATH="$PFX_PATH/pfx/drive_c/Program Files/Black Tree Gaming Ltd/Vortex/Vortex.exe"
DOWNLOADS="$HOME/Downloads"

if [ -f "$VORTEX_EXE_PATH" ]
    then echo "Vortex already installed."
    else echo "Installing Vortex..." && "$PROTON_PATH" waitforexitandrun "$DOWNLOADS/$(ls $DOWNLOADS | grep Vortex | head -n 1)"
fi

echo "Starting Vortex"

echo $PROTON_PATH '|' $VORTEX_EXE_PATH
"$PROTON_PATH" waitforexitandrun "$VORTEX_EXE_PATH"
