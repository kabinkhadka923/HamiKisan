@echo off
echo Running HamiKisan...
echo Fetching dependencies...
call .\flutter\bin\flutter.bat pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies. Make sure Flutter is installed and in your PATH.
    pause
    exit /b %errorlevel%
)

echo Running application...
call .\flutter\bin\flutter.bat run -d windows
if %errorlevel% neq 0 (
    echo Error: Failed to run application.
    pause
    exit /b %errorlevel%
)
pause
