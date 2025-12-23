#!/bin/bash

# Defaults
HEX_MODE=false
SED_CMDS=""
FILE_PATH=""
OUTPUT_FILE=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --file_path) FILE_PATH="$2"; shift ;;
        --s_hex) S_HEX="${2,,}"; shift ;;
        --r_hex) R_HEX="${2,,}"; SED_CMDS+="s/$S_HEX/$R_HEX/g; "; shift ;;
        --hex-mode) HEX_MODE=true ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter: $1" >&2; exit 1 ;;
    esac
    shift
done

# Input Source
INPUT_SRC="${FILE_PATH:--}"

# Define Processing Pipeline
process_stream() {
    if [ "$HEX_MODE" = true ]; then
        # Assumes input is already hex; remains hex for next pipe
        cat "$INPUT_SRC" | sed "$SED_CMDS"
    else
        # Standard: Binary -> Hex -> Sed -> Binary
        cat "$INPUT_SRC" | xxd -p -c 256 | tr -d '\n' | sed "$SED_CMDS" | xxd -r -p
    fi
}

# Output
if [[ -n "$OUTPUT_FILE" ]]; then
    # Create a unique temp file
    TEMP_FILE=$(mktemp)

    # Process and write to temp
    process_stream > "$TEMP_FILE"

    # Overwrite the original (only if processing succeeded)
    if [[ $? -eq 0 ]]; then
        mv "$TEMP_FILE" "$OUTPUT_FILE"
    else
        rm "$TEMP_FILE"
        echo "Error: Processing failed." >&2
        exit 1
    fi
else
    process_stream
fi
