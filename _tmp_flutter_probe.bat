@echo off
setlocal
for %%i in ("%~dp0flutter\bin\..") do set FLUTTER_ROOT=%%~fi
echo ROOT=[%FLUTTER_ROOT%]
where /q git
echo git_err=%errorlevel%
where /q pwsh && (
  set "powershell_executable=call pwsh"
) || where /q powershell.exe && (
  set powershell_executable=PowerShell.exe
) || (
  echo no ps
  exit /b 1
)
echo PS=[%powershell_executable%]
set shared_bin=%FLUTTER_ROOT%\bin\internal\shared.bat
echo SHARED=[%shared_bin%]
call "%shared_bin%"
echo AFTER_SHARED err=%errorlevel%