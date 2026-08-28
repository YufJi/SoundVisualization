#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MASTER_ICON="$ROOT_DIR/Resources/AppIcon.png"
ICONSET="$ROOT_DIR/Resources/AppIcon.iconset"
OUTPUT="$ROOT_DIR/Resources/SoundViz.icns"

swift "$ROOT_DIR/scripts/generate-icon.swift" "$MASTER_ICON"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

sips -z 16 16 "$MASTER_ICON" --out "$ICONSET/icon_16x16.png" >/dev/null
sips -z 32 32 "$MASTER_ICON" --out "$ICONSET/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$MASTER_ICON" --out "$ICONSET/icon_32x32.png" >/dev/null
sips -z 64 64 "$MASTER_ICON" --out "$ICONSET/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$MASTER_ICON" --out "$ICONSET/icon_128x128.png" >/dev/null
sips -z 256 256 "$MASTER_ICON" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$MASTER_ICON" --out "$ICONSET/icon_256x256.png" >/dev/null
sips -z 512 512 "$MASTER_ICON" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$MASTER_ICON" --out "$ICONSET/icon_512x512.png" >/dev/null
sips -z 1024 1024 "$MASTER_ICON" --out "$ICONSET/icon_512x512@2x.png" >/dev/null

iconutil -c icns "$ICONSET" -o "$OUTPUT"
rm -rf "$ICONSET"
printf 'Generated %s\n' "$OUTPUT"
