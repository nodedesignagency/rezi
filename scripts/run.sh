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

# The full output goes to a log; only the lines worth reading are shown.
LOG="$DERIVED/xcodebuild.log"
mkdir -p "$DERIVED"

# Returns xcodebuild's own status. It has to be read straight off the
# pipeline: an `|| true` after it would overwrite the status with its own
# success, and a failed build would go on to launch the previous one.
build() {
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "id=$UDID" \
    -derivedDataPath "$DERIVED" \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 \
    | tee "$LOG" \
    | grep -E "error:|warning:|BUILD |Compiling|Linking"
  return "${PIPESTATUS[0]}"
}

step "Building $SCHEME"
if ! build; then
  # The marquee screen's ripple is a Metal shader. Recent Xcode ships without
  # the compiler for those until it is downloaded once, so fetch it and retry.
  if grep -q "missing Metal Toolchain" "$LOG"; then
    step "Downloading Apple's Metal Toolchain ${dim}(one time only, takes a few minutes)${reset}"
    xcodebuild -downloadComponent MetalToolchain \
      || die "could not download the Metal Toolchain. In Xcode, open Settings > Components and install Metal Toolchain, then run this again."
    step "Building $SCHEME"
    build || die "build failed. The full log is in $LOG"
  else
    die "build failed. The full log is in $LOG"
  fi
fi

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
echo "${green}Running.${reset} ${dim}Drag the cards; tap one on the marquee screen to apply.${reset}"
echo
