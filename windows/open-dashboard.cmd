@echo off
setlocal

cd /d "%~dp0.."

if exist "%cd%\codexscope-windows-amd64.exe" (
  "%cd%\codexscope-windows-amd64.exe"
  goto open_dashboard
)

where go >nul 2>nul
if %errorlevel%==0 (
  go build -trimpath -ldflags "-s -w" -o codexscope-generator.exe generate_codex_data.go
  if errorlevel 1 goto generator_failed
  "%cd%\codexscope-generator.exe"
  goto open_dashboard
)

echo No prebuilt generator was found, and Go is not installed.
echo Please download CodexScope-windows.zip from the GitHub Releases page.
pause
exit /b 1

:open_dashboard
if errorlevel 1 goto generator_failed
start "" "%cd%\index.html"
exit /b 0

:generator_failed
echo Failed to generate data.js.
pause
exit /b 1
