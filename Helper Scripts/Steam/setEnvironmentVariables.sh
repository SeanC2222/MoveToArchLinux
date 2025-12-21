#!/bin/bash

if [[ $* == *-Debug* ]]; then
  DEBUG=true

  echo $*
fi

SetSmallRenderResolutions() {
	echo "Exporting $1x$2"
	export SMALL_RENDER_WIDTH=$1
	export SMALL_RENDER_HEIGHT=$2
}

SetSkyrimSePrefs() {
	SKYRIM_PREFS_INI="$STEAM_COMPAT_DATA_PATH/pfx/drive_c/users/steamuser/My Documents/My Games/Skyrim Special Edition/SkyrimPrefs.ini"
	echo "Updating $SKYRIM_PREFS_INI"
	sed -i "s/iSize W=[0-9]\+/iSize W=$SMALL_RENDER_WIDTH/" "$SKYRIM_PREFS_INI"
	sed -i "s/iSize H=[0-9]\+/iSize H=$SMALL_RENDER_HEIGHT/" "$SKYRIM_PREFS_INI"
}

export CURRENT_SCREEN_WIDTH=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
export CURRENT_SCREEN_HEIGHT=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)
echo "Current Screen Resolution: ${CURRENT_SCREEN_WIDTH}x${CURRENT_SCREEN_HEIGHT}"

SCREEN_RATIO=$(awk 'BEGIN{print (ENVIRON["CURRENT_SCREEN_WIDTH"] / ENVIRON["CURRENT_SCREEN_HEIGHT"])}')
echo "Current Screen Ratio: $SCREEN_RATIO"

if [ $DEBUG ]; then
	echo "Known Resolutions"
fi
# 32:9
KNOWN_RATIO_1=$(awk 'BEGIN{print (5120 / 1440)}')
SMALL_RENDER_WIDTH_1=3840;
SMALL_RENDER_HEIGHT_1=1080;
if [ $DEBUG ]; then
	echo "${SMALL_RENDER_WIDTH_1}x${SMALL_RENDER_WIDTH_1}"
fi

# ~21:9
KNOWN_RATIO_2=$(awk 'BEGIN{print (2560 / 1440)}')
SMALL_RENDER_WIDTH_2=1920;
SMALL_RENDER_HEIGHT_2=1080;
if [ $DEBUG ]; then
	echo "${SMALL_RENDER_WIDTH_2}x${SMALL_RENDER_WIDTH_2}"
fi


if [ "$SCREEN_RATIO" = "$KNOWN_RATIO_1" ]; then
{
	SetSmallRenderResolutions $SMALL_RENDER_WIDTH_1 $SMALL_RENDER_HEIGHT_1
};
fi

if [ "$SCREEN_RATIO" = "$KNOWN_RATIO_2" ]; then
{
	SetSmallRenderResolutions $SMALL_RENDER_WIDTH_2 $SMALL_RENDER_HEIGHT_2
};
fi

if [ "$SMALL_RENDER_WIDTH" = "" ]; then
	echo "Small render width not set!"
	exit -1;

fi

if [ "$SMALL_RENDER_HEIGHT" = "" ]; then
	echo "Small render height not set!"
	exit -1;
fi

if [[ $* == *skyrimse* ]]; then
	echo "Setting SkryimSe prefs"
	SetSkyrimSePrefs
fi
