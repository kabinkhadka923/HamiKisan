#!/bin/bash

# Navigate to the project directory
cd "/d/Gorkha/HamiKisan"

echo "[1/2] Refreshing dependencies..."
"$PWDC" pub get

echo ""
echo "[2/2] Starting localhost development server..."
echo ""
echo "🚀 HamiKisan will open in Chrome browser at:"
echo "   http://localhost:8080"
echo ""

# Run the Flutter web app
"$PWD/flutter/bin/flutter" run -d chrome --web-port=8080 --web-renderer=canvaskit

read -p "Press any key to continue . . ."
