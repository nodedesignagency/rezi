#!/usr/bin/env bash
#
# Copies images from assets/raw/ into Rezi/Assets.xcassets and writes the
# Contents.json for each imageset. Safe to re-run; it rebuilds each imageset
# from whatever is currently in assets/raw/.
#
# Usage:  ./scripts/import-assets.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW="$ROOT/assets/raw"
CATALOG="$ROOT/Rezi/Assets.xcassets"

# Base name in assets/raw  ->  imageset name in the catalog
IMAGESETS=(
  "onboarding-background:OnboardingBackground"
  "clouds:Clouds"
  "phone-mockup:PhoneMockup"
  "rezi-icon:ReziIcon"
  "company-logo:CompanyLogo"
)

# Vector icons: base name in assets/raw -> imageset name. These go in as a
# single SVG with vector data preserved and template rendering, so they stay
# crisp at any size and pick up the tint colour from SwiftUI. The Solar
# duotone icons carry their second tone as alpha, which template rendering
# preserves.
ICONSETS=(
  "stat-applications:StatApplications"
  "stat-rating:StatRating"
  "stat-seekers:StatSeekers"
)

bold=$(printf '\033[1m'); dim=$(printf '\033[2m')
green=$(printf '\033[32m'); yellow=$(printf '\033[33m'); reset=$(printf '\033[0m')

[ -d "$RAW" ] || { echo "No assets/raw directory. Nothing to do."; exit 0; }

# Find the file for a given base name + scale. Tries png/jpg/jpeg.
# @1x has no suffix. Echoes the filename (not path), or nothing.
find_variant() {
  local base="$1" scale="$2" suffix="" f
  [ "$scale" != "1x" ] && suffix="@$scale"
  for ext in png PNG jpg JPG jpeg JPEG; do
    f="$RAW/${base}${suffix}.${ext}"
    if [ -f "$f" ]; then basename "$f"; return 0; fi
  done
  return 0
}

write_imageset() {
  local base="$1" name="$2"
  local dir="$CATALOG/${name}.imageset"
  mkdir -p "$dir"

  # Clear out previously imported images so renames/removals take effect.
  find "$dir" -type f ! -name 'Contents.json' -delete

  local entries=() found=0
  for scale in 1x 2x 3x; do
    local file
    file="$(find_variant "$base" "$scale")"
    if [ -n "$file" ]; then
      cp "$RAW/$file" "$dir/$file"
      entries+=("    {
      \"idiom\" : \"universal\",
      \"filename\" : \"$file\",
      \"scale\" : \"$scale\"
    }")
      found=$((found + 1))
    else
      entries+=("    {
      \"idiom\" : \"universal\",
      \"scale\" : \"$scale\"
    }")
    fi
  done

  # Join entries with ",\n"
  local body=""
  for i in "${!entries[@]}"; do
    body+="${entries[$i]}"
    [ "$i" -lt $(( ${#entries[@]} - 1 )) ] && body+=$',\n'
  done

  cat > "$dir/Contents.json" <<JSON
{
  "images" : [
$body
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

  if [ "$found" -gt 0 ]; then
    printf '  %s✓%s %-22s %s(%d file%s)%s\n' \
      "$green" "$reset" "$name" "$dim" "$found" "$([ "$found" -eq 1 ] || echo s)" "$reset"
  else
    printf '  %s·%s %-22s %sno image yet — using the SwiftUI fallback%s\n' \
      "$yellow" "$reset" "$name" "$dim" "$reset"
  fi
}

write_vector_imageset() {
  local base="$1" name="$2"
  local dir="$CATALOG/${name}.imageset"
  local src=""

  for ext in svg SVG pdf PDF; do
    [ -f "$RAW/${base}.${ext}" ] && src="$RAW/${base}.${ext}"
  done

  if [ -z "$src" ]; then
    printf '  %s\xc2\xb7%s %-22s %sno vector yet - using the SF Symbol fallback%s\n' \
      "$yellow" "$reset" "$name" "$dim" "$reset"
    return 0
  fi

  mkdir -p "$dir"
  find "$dir" -type f ! -name 'Contents.json' -delete
  local file; file="$(basename "$src")"
  cp "$src" "$dir/$file"

  cat > "$dir/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "$file",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true,
    "template-rendering-intent" : "template"
  }
}
JSON
  printf '  %s\xe2\x9c\x93%s %-22s %s(vector)%s\n' "$green" "$reset" "$name" "$dim" "$reset"
}

echo
echo "${bold}Importing assets${reset} ${dim}from assets/raw${reset}"
echo

for pair in "${IMAGESETS[@]}"; do
  write_imageset "${pair%%:*}" "${pair##*:}"
done

for pair in "${ICONSETS[@]}"; do
  write_vector_imageset "${pair%%:*}" "${pair##*:}"
done

# ---- Numbered company logos: company-logo-1, company-logo-2, ... ----------
# Remove stale ones first so deletions in assets/raw are reflected.
find "$CATALOG" -maxdepth 1 -type d -name 'CompanyLogo[0-9]*.imageset' -exec rm -rf {} + 2>/dev/null || true
n=1
while :; do
  if [ -n "$(find_variant "company-logo-$n" 1x)" ] \
  || [ -n "$(find_variant "company-logo-$n" 2x)" ] \
  || [ -n "$(find_variant "company-logo-$n" 3x)" ]; then
    write_imageset "company-logo-$n" "CompanyLogo$n"
    n=$((n + 1))
  else
    break
  fi
done

# ---- Fonts ---------------------------------------------------------------
# Anything in assets/raw/fonts is copied into the app, and registered at launch
# by InterFont.registerBundledFonts(). Drop the static Inter TTFs there to move
# the whole screen off SF Pro.
FONT_SRC="$RAW/fonts"
FONT_DIR="$ROOT/Rezi/Fonts"
mkdir -p "$FONT_DIR"
find "$FONT_DIR" -type f \( -name '*.ttf' -o -name '*.otf' \) -delete 2>/dev/null || true

font_count=0
if [ -d "$FONT_SRC" ]; then
  while IFS= read -r font; do
    [ -n "$font" ] || continue
    cp "$font" "$FONT_DIR/"
    font_count=$((font_count + 1))
  done <<EOF
$(find "$FONT_SRC" -maxdepth 1 -type f \( -name '*.ttf' -o -name '*.otf' \) 2>/dev/null)
EOF
fi

if [ "$font_count" -gt 0 ]; then
  printf '  %s\xe2\x9c\x93%s %-22s %s(%d file%s)%s\n' \
    "$green" "$reset" "Fonts" "$dim" "$font_count" \
    "$([ "$font_count" -eq 1 ] || echo s)" "$reset"
else
  printf '  %s\xc2\xb7%s %-22s %sno fonts yet - using SF Pro%s\n' \
    "$yellow" "$reset" "Fonts" "$dim" "$reset"
fi

# ---- App icon -------------------------------------------------------------
APPICON_SRC=""
for ext in png PNG; do
  [ -f "$RAW/app-icon.$ext" ] && APPICON_SRC="$RAW/app-icon.$ext"
done
APPICON_DIR="$CATALOG/AppIcon.appiconset"
mkdir -p "$APPICON_DIR"
if [ -n "$APPICON_SRC" ]; then
  find "$APPICON_DIR" -type f ! -name 'Contents.json' -delete
  cp "$APPICON_SRC" "$APPICON_DIR/app-icon.png"
  cat > "$APPICON_DIR/Contents.json" <<'JSON'
{
  "images" : [
    {
      "filename" : "app-icon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
  printf '  %s✓%s %-22s %s(1024×1024)%s\n' "$green" "$reset" "AppIcon" "$dim" "$reset"
else
  printf '  %s·%s %-22s %sno app-icon.png yet%s\n' "$yellow" "$reset" "AppIcon" "$dim" "$reset"
fi

echo
echo "${bold}Done.${reset} Rebuild in Xcode (${dim}Cmd-R${reset}) or run ${dim}./scripts/run.sh${reset}"
echo
