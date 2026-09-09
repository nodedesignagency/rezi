#!/usr/bin/env bash
#
# Build the app, boot a simulator, install and launch it.
#
#   ./scripts/run.sh
#   ./scripts/run.sh --device "iPhone 16 Pro Max"
#   ./scripts/run.sh --list
#   ./scripts/run.sh --clean
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="Rezi.xcodeproj"
SCHEME="Rezi"
BUNDLE_ID="com.nodedesignagency.rezi"
DERIVED="$ROOT/build"

DEVICE=""
CLEAN=0

bold=$(printf '\033[1m'); dim=$(printf '\033[2m')
red=$(printf '\033[31m'); green=$(printf '\033[32m'); reset=$(printf '\033[0m')

die() { echo "${red}error:${reset} $*" >&2; exit 1; }
step() { echo; echo "${bold}$*${reset}"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --device) DEVICE="${2:-}"; shift 2 ;;
    --clean)  CLEAN=1; shift ;;
    --list)
      echo "Available iOS simulators:"
      xcrun simctl list devices available \
        | awk '/-- iOS/{on=1; print; next} /^-- /{on=0} on && /\(/ {print}'
      exit 0 ;;
    -h|--help) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

command -v xcodebuild >/dev/null || die "xcodebuild not found. Install Xcode and run: xcode-select --install"

# ---- Pick a simulator -----------------------------------------------------
# Prefer whatever the user asked for, then a modern iPhone, then anything.
pick_device() {
  if [ -n "$DEVICE" ]; then echo "$DEVICE"; return; fi
  local list
  list="$(xcrun simctl list devices available)"
  for candidate in "iPhone 16 Pro" "iPhone 16" "iPhone 15 Pro" "iPhone 15" "iPhone 14 Pro"; do
    if grep -qF "    $candidate (" <<<"$list"; then echo "$candidate"; return; fi
  done
  grep -oE '^    iPhone[^(]*' <<<"$list" | head -1 | sed 's/ *$//;s/^ *//'
}

DEVICE="$(pick_device)"
[ -n "$DEVICE" ] || die "no iOS simulator available. Open Xcode > Settings > Components and add one."

UDID="$(xcrun simctl list devices available \
  | grep -F "    $DEVICE (" | head -1 \
  | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
[ -n "$UDID" ] || die "could not resolve a simulator named '$DEVICE'. Try: $0 --list"

echo "${dim}Simulator:${reset} $DEVICE  ${dim}($UDID)${reset}"

# ---- Build ----------------------------------------------------------------
if [ "$CLEAN" = "1" ]; then
  step "Cleaning"
  rm -rf "$DERIVED"
fi

step "Building $SCHEME"
set +e
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  build \
  | grep -E "error:|warning:|BUILD |Compiling|Linking" || true
BUILD_STATUS=${PIPESTATUS[0]}
set -e
[ "$BUILD_STATUS" -eq 0 ] || die "build failed. Re-run without the filter to see everything:
  xcodebuild -project $PROJECT -scheme $SCHEME -destination 'id=$UDID' -derivedDataPath build build"

APP="$DERIVED/Build/Products/Debug-iphonesimulator/$SCHEME.app"
[ -d "$APP" ] || die "built, but $APP is missing"

# ---- Boot, install, launch ------------------------------------------------
step "Booting simulator"
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true
open -a Simulator --args -CurrentDeviceUDID "$UDID" 2>/dev/null || open -a Simulator || true

step "Installing"
xcrun simctl install "$UDID" "$APP"

step "Launching"
xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null

echo
echo "${green}Running.${reset} ${dim}Drag the job cards to swipe; they also cycle on their own.${reset}"
echo
