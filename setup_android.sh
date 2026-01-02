#!/bin/bash
echo "============================================================================"
echo "HAMIKISAN ANDROID DEV SETUP (Bash Script)"
echo "============================================================================"

echo "Checking for Android SDK locations..."

# Check for Android SDK in common locations
if [ -d "$HOME/AppData/Local/Android/Sdk" ]; then
    echo "✓ Found Android SDK: $HOME/AppData/Local/Android/Sdk"
    export ANDROID_HOME="$HOME/AppData/Local/Android/Sdk"
elif [ -d "/c/Program Files/Android/Android Studio/sdk" ]; then
    echo "✓ Found Android SDK: /c/Program Files/Android/Android Studio/sdk"
    export ANDROID_HOME="/c/Program Files/Android/Android Studio/sdk"
elif [ -d "$HOME/android-sdk" ]; then
    echo "✓ Found Android SDK: $HOME/android-sdk"
    export ANDROID_HOME="$HOME/android-sdk"
else
    echo "⚠️ Android SDK not found!"
    echo ""
    echo "To install Android SDK:"
    echo ""
    echo "Option 1 - Install Android Studio:"
    echo "1. Download: https://developer.android.com/studio"
    echo "2. Install with Android SDK checkbox"
    echo ""
    echo "Option 2 - Command line SDK only:"
    echo "Download: https://developer.android.com/studio#downloads"
    echo "(Scroll down to \"Command line tools only\")"
    echo ""
    echo "After installation, set ANDROID_HOME environment variable and run this script again."
    exit 1
fi

echo ""
echo "Android SDK found at: $ANDROID_HOME"
echo "Setting environment variables..."

# Set Android environment variables
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"
export JAVA_HOME="/c/Program Files/Java/jdk-11" # Assuming Java 11 is installed here

echo ""
echo "Verifying Android setup..."
cd "/d/Gorkha/HamiKisan"

echo "Checking Java..."
java -version 2>&1 | grep "version \"11" || echo "⚠️ Java 11 recommended"

echo "Checking Android licenses..."
# Use the full path to flutter.bat for bash compatibility
"$PWD/flutter/bin/flutter" doctor --android-licenses --yes >/dev/null 2>&1 || echo "⚠️ May need to accept Android licenses manually"

echo ""
echo "Configuration complete! Run build_apk.sh to create APK."

echo ""
echo "============================================================================"
read -p "Press any key to continue . . ."
