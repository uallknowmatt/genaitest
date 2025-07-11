@echo off
echo 🚀 Quick Azure Test Cycle
echo.

echo This script will:
echo 1. Create Azure infrastructure
echo 2. Test the application for 30 minutes
echo 3. Destroy everything to save costs
echo.
echo Estimated cost per session: $1.50-2.50
echo Cost saved vs 24/7: ~$130/month
echo.

set /p confirm="Continue? (y/N): "
if /i not "%confirm%"=="y" goto :end

echo.
echo 🏗️ Creating infrastructure...
powershell -ExecutionPolicy Bypass -File "scripts\dev-test-destroy.ps1" -Action "full-cycle" -TestDurationMinutes 30

:end
echo.
echo Done!
pause 