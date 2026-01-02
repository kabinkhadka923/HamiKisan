#!/bin/bash
echo "============================================================================"
echo "HAMIKISAN APK BUILD SCRIPT (Bash Script)"
echo "============================================================================"

# Navigate to the project directory
cd "/d/Gorkha/HamiKisan"

echo "[1/4] Checking Flutter environment..."
# Use the full path to flutter for bash compatibility
"$PWD/flutter/bin/flutter" doctor -v | grep "Android SDK" || echo "Android SDK: NOT FOUND"

echo ""
echo "[2/4] Refreshing dependencies..."
"$PWD/flutter/bin/flutter" pub get

echo ""
echo "[3/4] Building release APK..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "Removing old APK..."
    rm -f "build/app/outputs/flutter-apk/app-release.apk"
fi

"$PWD/flutter/bin/flutter" build apk --release --target-platform android-arm,android-arm64 --split-per-abi

echo ""
echo "[4/4] Build complete! Check these locations:"
echo ""
echo "APK Location: $PWD/build/app/outputs/flutter-apk/"
echo ""
echo "Available APKs:"
ls -1 "build/app/outputs/flutter-apk/"*release.apk 2>/dev/null || echo "No release APKs found."
echo ""
echo "============================================================================"
echo "Transfer APK to mobile:"
echo "1. USB transfer: Copy APK to Downloads folder on Android"
echo "2. Cloud: Upload to Google Drive, share download link"
echo "3. WiFi: Share via messaging apps"
echo "============================================================================"

read -p "Press any key to continue . . ."
