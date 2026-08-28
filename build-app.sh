#!/bin/bash
set -euo pipefail

APP_NAME="SoundViz"
BUNDLE_ID="local.prototype.SoundViz"
BUILD_DIR="build"
CONFIGURATION="${CONFIGURATION:-release}"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

swift build -c "$CONFIGURATION"
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
cp ".build/$CONFIGURATION/$APP_NAME" "$MACOS_DIR/$APP_NAME"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.2</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAudioCaptureUsageDescription</key>
    <string>SoundViz 需要读取系统输出音频来显示菜单栏可视化。</string>
    <key>NSHumanReadableCopyright</key>
    <string>Prototype</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

plutil -lint "$CONTENTS_DIR/Info.plist"
codesign --force --sign "$CODESIGN_IDENTITY" "$APP_DIR"
codesign --verify --strict "$APP_DIR"
printf 'Built %s\n' "$APP_DIR"
