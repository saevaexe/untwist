#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./AppStore/capture_screenshot.sh home_tr
#   ./AppStore/capture_screenshot.sh mood_en --launch
#   ./AppStore/capture_screenshot.sh mood_en --ensure-boot
#
# Notes:
# - Writes to AppStore/screenshots/{name}.png
# - Uses iPhone 17 simulator by default

UDID_DEFAULT="BA1AD949-65EF-42D6-8866-3D303D4E9FB9"
APP_BUNDLE_ID="com.osmanseven.untwist"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/AppStore/screenshots"
NAME="${1:-}"
ARG2="${2:-}"
ARG3="${3:-}"
LAUNCH_APP="false"
ENSURE_BOOT="false"
UDID="${SIM_UDID:-$UDID_DEFAULT}"

for arg in "$ARG2" "$ARG3"; do
  [[ -z "${arg:-}" ]] && continue
  if [[ "$arg" == "--launch" ]]; then
    LAUNCH_APP="true"
  fi
  if [[ "$arg" == "--ensure-boot" ]]; then
    ENSURE_BOOT="true"
  fi
done

if [[ -z "$NAME" ]]; then
  echo "Usage: ./AppStore/capture_screenshot.sh <name> [--launch]"
  exit 1
fi

mkdir -p "$OUT_DIR"

run_with_retry() {
  local attempts=0
  local max_attempts=4
  local delay=1
  while (( attempts < max_attempts )); do
    if "$@"; then
      return 0
    fi
    attempts=$((attempts + 1))
    sleep "$delay"
  done
  return 1
}

# Optional: ensure device boot once.
# In this environment, calling boot/bootstatus repeatedly can destabilize CoreSimulatorService.
if [[ "$ENSURE_BOOT" == "true" ]]; then
  run_with_retry xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
fi

if [[ "$LAUNCH_APP" == "true" ]]; then
  run_with_retry xcrun simctl launch "$UDID" "$APP_BUNDLE_ID" >/dev/null || true
  sleep 1
fi

OUT_FILE="$OUT_DIR/${NAME}.png"
run_with_retry xcrun simctl io "$UDID" screenshot "$OUT_FILE" >/dev/null
echo "Saved: $OUT_FILE"
