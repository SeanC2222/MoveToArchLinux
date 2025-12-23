#!/bin/bash

# Default values
FILE_PATH=""
OUTPUT_FILE=""
ENCODING="UTF-8" # Default encoding
SED_CMDS=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --file_path) FILE_PATH="$2"; shift ;;
        --encoding)  ENCODING="${2^^}"; shift ;; # Normalize to uppercase
        --x_key)
            X_KEY="$2"
            X_VALUE="$3"
            # Regex: finds <tag>...</tag> and replaces content between them
            SED_CMDS+="s|(<${X_KEY}>).*?(</${X_KEY}>)|\1${X_VALUE}\2|g; "
            shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validation
if [[ -z "$FILE_PATH" ]]; then
    echo "Error: --file_path is required." >&2
    exit 1
fi

# Define target destination (default to overwrite if no --output)
TARGET_DEST="${OUTPUT_FILE:-$FILE_PATH}"

# Logic:
# 1. iconv: Convert from source encoding to UTF-8
# 2. sed: Perform the replacements
# 3. iconv: Convert back to the original encoding
# 4. temp file: Used to avoid race conditions during in-place updates

TEMP_FILE=$(mktemp)

if iconv -f "$ENCODING" -t "UTF-8" "$FILE_PATH" | \
   sed -E "$SED_CMDS" | \
   iconv -f "UTF-8" -t "$ENCODING" > "$TEMP_FILE"; then

    mv "$TEMP_FILE" "$TARGET_DEST"
    echo "Successfully updated $TARGET_DEST using $ENCODING encoding."
else
    echo "Error: Encoding conversion or processing failed." >&2
    rm -f "$TEMP_FILE"
    exit 1
fi
