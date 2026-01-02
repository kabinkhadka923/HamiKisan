@echo off
echo Running HamiKisan on Web (Chrome)...
echo Fetching dependencies...
call .\flutter\bin\flutter.bat pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies.
    pause
    exit /b %errorlevel%
)

echo Running application on Chrome...
call .\flutter\bin\flutter.bat run -d chrome
if %errorlevel% neq 0 (
    echo Error: Failed to run application on web.
    pause
    exit /b %errorlevel%
)
pause
