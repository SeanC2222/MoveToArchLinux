#!/bin/bash
set -e # Exit on error

# --- Task 1: Environment & Dependency Check ---
check_environment() {
    if ! command -v pacman &> /dev/null; then
        echo "❌ Error: This script requires 'pacman' (Arch-based system)."
        exit 1
    fi

    if ! pacman -Q apparmor &> /dev/null; then
        echo "Installing AppArmor..."
        sudo pacman -S --noconfirm apparmor apparmor-utils
        sudo systemctl enable --now apparmor.service
    fi

    # 2025 Check: Ensure AppArmor is actually enabled in the kernel
    if [[ ! -d /sys/kernel/security/apparmor ]]; then
        echo "❌ Error: AppArmor is installed but not enabled in the kernel."
        echo "Please add 'lsm=landlock,lockdown,yama,integrity,apparmor,bpf' to your kernel parameters."
        exit 1
    fi
}

# --- Task 2: Validation ---
validate_input() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: $0 <profile_name> <exec_filename> [is_game: true/false]"
        exit 1
    fi
}

# --- Task 3: Path Formatting ---
get_exe_path() {
    local s="$1"
    case "$s" in
        "/**/"* | "/home/"*) echo "$s" ;;
        *) echo "/**/$s" ;;
    esac
}

# --- Task 4: Profile Status Check ---
# Simplified check using built-in aa-status filters
is_profile_enforced() {
    local profile_name=$1

    RESULT=$(sudo apparmor_status --filter.profiles="$profile_name" | grep -B1 "$profile_name")

    # 1. Count lines
    LINE_COUNT=$(echo "$RESULT" | grep -c '^')

    # 2. Extract specific lines for validation
    FIRST_LINE=$(echo "$RESULT" | sed -n '1p')
    SECOND_LINE=$(echo "$RESULT" | sed -n '2p')

    # 3. Perform the checks
    # Check if line count is 2 AND first line has 'enforce mode' AND second line is {whitespace}{name}
    if [[ "$LINE_COUNT" -eq 2 ]] && \
    [[ "$FIRST_LINE" == *"enforce mode"* ]] && \
    [[ "$SECOND_LINE" =~ ^[[:space:]]+$profile_name$ ]]; then
        return 0
    else
        return 1
    fi
}

# --- Task 5: Template & Deployment ---
deploy_profile() {
    local name="$1"
    local path="$2"
    local is_game="${3:-true}"
    local p_file="/etc/apparmor.d/$name"

    local flags=""
    [[ "$is_game" == "true" ]] && flags="flags=(attach_disconnected)"

    echo "Generating profile at $p_file..."
    cat <<EOF | sudo tee "$p_file" > /dev/null
#include <tunables/global>
profile $name "$path" $flags {
  #include <abstractions/base>
  deny network inet,
  deny network inet6,
  deny network raw,
  deny capability net_admin,
  deny capability net_raw,
  deny capability net_bind_service,
  file, capability, mount, remount, umount, pivot_root, ptrace, signal, dbus, unix, change_profile,
}
EOF
    sudo apparmor_parser -r -W "$p_file"
}

# --- MAIN FLOW ---
validate_input "$@"
check_environment

PROFILE_NAME="$1"
EXE_PATH=$(get_exe_path "$2")
IS_GAME="${3:-true}"


if is_profile_enforced "$PROFILE_NAME"; then
    echo "✅ Success: Profile '$PROFILE_NAME' is loaded and active."
    exit 0;
fi

deploy_profile "$PROFILE_NAME" "$EXE_PATH" "$IS_GAME"

if is_profile_enforced "$PROFILE_NAME"; then
    echo "✅ Success: Profile '$PROFILE_NAME' is loaded and active."
    echo "ℹ️ Note: If the game is already running, you MUST restart it to apply the block."
else
    echo "❌ Error: Profile failed to load. Check 'dmesg' for syntax errors."
    exit 1
fi
