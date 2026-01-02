@echo off
echo ==========================================
echo HAMI KISAN - LOCAL TESTING GUIDE
echo ==========================================
echo.

echo [1] Checking Flutter installation...
flutter --version
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter first: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo.
echo [2] Getting dependencies...
flutter pub get

echo.
echo [3] Running code generation (if needed)...
flutter packages pub run build_runner build --delete-conflicting-outputs 2>nul || echo No code generation needed

echo.
echo [4] Starting HamiKisan app on localhost...
echo.
echo ==========================================
echo APP WILL RUN ON:
echo - Android Emulator: http://localhost:3000
echo - iOS Simulator: http://localhost:3000  
echo - Web Browser: http://localhost:3000
echo - Physical Device: Device IP
echo ==========================================
echo.
echo Press Ctrl+C to stop the app
echo.

flutter run

pause
