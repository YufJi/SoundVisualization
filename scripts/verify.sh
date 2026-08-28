#!/bin/bash
set -euo pipefail

swift build
swift test
./build-app.sh
plutil -lint build/SoundViz.app/Contents/Info.plist
codesign --verify --strict build/SoundViz.app

