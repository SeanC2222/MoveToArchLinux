#!/usr/bin/env bash

# ============================================================
#  Aspect Ratio & Resolution Maps
# ============================================================

declare -A ASPECT_RATIOS=(
    ["5:4"]="0000A03F"
    ["4:3"]="ABAAAA3F"
    ["3:2"]="0000C03F"
    ["16:10"]="CDCCCC3F"
    ["15:9"]="5555D53F"
    ["16:9"]="398EE33F"
    ["1.85:1"]="CDCCEC3F"
    ["21:9_2560x1080"]="26B41740"
    ["21:9_3440x1440"]="8EE31840"
    ["2.39:1"]="C3F51840"
    ["21:9_3840x1600"]="9A991940"
    ["2.76:1"]="D7A33040"
    ["32:10"]="CDCC4C40"
    ["32:9"]="398E6340"
    ["3x5:4"]="00007040"
    ["3x4:3"]="00008040"
    ["3x16:10"]="9A999940"
    ["3x15:9"]="0000A040"
    ["3x16:9"]="ABAAAA40"
)

declare -A RESOLUTIONS=(
    [200]="C800"
    [240]="F000"
    [320]="4001"
    [480]="E001"
    [525]="0D02"
    [540]="1C02"
    [576]="4002"
    [600]="5802"
    [640]="8002"
    [704]="C002"
    [720]="D002"
    [768]="0003"
    [800]="2003"
    [840]="4803"
    [848]="5003"
    [854]="5603"
    [900]="8403"
    [945]="B103"
    [960]="C003"
    [992]="E003"
    [1000]="E803"
    [1024]="0004"
    [1050]="1A04"
    [1080]="3804"
    [1152]="8004"
    [1200]="B004"
    [1280]="0005"
    [1360]="5005"
    [1366]="5605"
    [1368]="5805"
    [1440]="A005"
    [1536]="0006"
    [1600]="4006"
    [1680]="9006"
    [1768]="E806"
    [1776]="F006"
    [1800]="0807"
    [1920]="8007"
    [2048]="0008"
    [2160]="7008"
    [2400]="6009"
    [2560]="000A"
    [2720]="A00A"
    [2880]="400B"
    [3072]="000C"
    [3200]="800C"
    [3360]="200D"
    [3440]="700D"
    [3840]="000F"
    [4080]="F00F"
    [4320]="E010"
    [4800]="C012"
    [5040]="B013"
    [5120]="0014"
    [5760]="8016"
)

get_resolution_hex() {
    local target_x="1920"
    local target_y="1080"
    if [[ "$#" -ne 0 ]]; then
        target_x=$1
        target_y=$2
    fi

    local hex="${RESOLUTIONS[$target_x]}0000${RESOLUTIONS[$target_y]}"

    echo $hex
}

# ============================================================
#  Argument Parsing
# ============================================================

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

ASPECT=""
WIDTH=""
HEIGHT=""
FILE_PATH_HEX=""
FILE_PATH_XML=""
MAP_HEX_ARGS=()
XML_ARGS=()
IS_DARK_SOULS_II=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dark_souls_ii) IS_DARK_SOULS_II=true; shift ;;
        # Leave other arguments for now. This likely doesn't have a broad usage.
        # Probably include preconfigured games, and optional targets?
        --aspect_ratio) ASPECT="$2"; shift ;;
        --width) WIDTH="$2"; shift ;;
        --height) HEIGHT="$2"; shift ;;

        --file_path_hex) FILE_PATH_HEX="$2"; shift ;;
        --file_path_xml) FILE_PATH_XML="$2"; shift ;;

        --list_aspect_ratios)
            printf "Available Aspect Ratios:\n"
            for key in "${!ASPECT_RATIOS[@]}"; do
                echo "  $key"
            done
            exit 0
            ;;

        --list_res_dimensions)
            printf "Available Resolution Dimensions:\n"
            for key in "${!RESOLUTIONS[@]}"; do
                echo "  $key"
            done
            exit 0
            ;;

        # Forward args to child scripts
        --map-hex-arg) MAP_HEX_ARGS+=("$2"); shift ;;
        --xml-arg) XML_ARGS+=("$2"); shift ;;

        *) echo "Unknown parameter: $1" >&2; exit 1 ;;
    esac
    shift
done

# ============================================================
#  Dark Souls II configuration
# ============================================================
set_dark_souls_II_config() {
    ASPECT=32:9
    WIDTH=3840
    HEIGHT=1080
    if [[ $FILE_PATH_HEX -eq "" ]]; then
        FILE_PATH_HEX="/home/games/SteamLibrary/steamapps/common/Dark Souls II Scholar of the First Sin/Game/DarkSoulsII.exe"
    fi
    if [[ $FILE_PATH_XML -eq "" ]]; then
        FILE_PATH_XML="/home/games/SteamLibrary/steamapps/compatdata/335300/pfx/drive_c/users/steamuser/AppData/Roaming/DarkSoulsII/GraphicsConfig_SOFS.xml"
    fi
    MAP_HEX_ARGS=(
        "--s_hex" "$(get_resolution_hex 1680 945)"
        "--r_hex" "$(get_resolution_hex $WIDTH $HEIGHT)"

        "--s_hex" "${ASPECT_RATIOS["16:9"]}"
        "--r_hex" "${ASPECT_RATIOS[$ASPECT]}"
    )
    XML_ARGS=(
        "--x_key" "Resolution-WindowScreenWidth" "3840"
        "--x_key" "Resolution-WindowScreenHeight" "1080"
        "--x_key" "Fullscreen" "OFF"
        "--encoding" "UTF-16LE"
    )
}

if $IS_DARK_SOULS_II; then
    set_dark_souls_II_config
fi

# ============================================================
#  Validation
# ============================================================

if [[ -z "$ASPECT" ]]; then
    echo "Error: --aspect_ratio is required." >&2
    exit 1
fi

if [[ -z "$WIDTH" || -z "$HEIGHT" ]]; then
    echo "Error: --width and --height are required." >&2
    exit 1
fi

if [[ -z "$FILE_PATH_HEX" ]]; then
    echo "Error: --file_path_hex is required." >&2
    exit 1
fi

if [[ -z "$FILE_PATH_XML" ]]; then
    echo "Error: --file_path_xml is required." >&2
    exit 1
fi

if [[ -z "${ASPECT_RATIOS[$ASPECT]}" ]]; then
    echo "Error: Unknown aspect ratio '$ASPECT'." >&2
    exit 1
fi

if [[ -z "${RESOLUTIONS[$WIDTH]}" ]]; then
    echo "Error: Unknown width '$WIDTH'." >&2
    exit 1
fi

if [[ -z "${RESOLUTIONS[$HEIGHT]}" ]]; then
    echo "Error: Unknown height '$HEIGHT'." >&2
    exit 1
fi

# ============================================================
#  Execute Worker Scripts
# ============================================================

echo "Running map_hex.sh..."
"$SCRIPT_DIR/map_hex.sh" --file_path "$FILE_PATH_HEX" "${MAP_HEX_ARGS[@]}" --output "$FILE_PATH_HEX"


echo "Running update_xml.sh..."
"$SCRIPT_DIR/update_xml.sh" --file_path "$FILE_PATH_XML" "${XML_ARGS[@]}" --output "$FILE_PATH_XML"

echo "Orchestration complete."
