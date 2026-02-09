@echo off
REM Quick start guide for Windows builds
REM This file contains helpful information for building on Windows

echo.
echo ============================================
echo  RPD Sky - Windows Build Quick Start Guide
echo ============================================
echo.

REM Check if we're on Windows
if not "%OS%"=="Windows_NT" (
    echo This guide is for Windows. You're not on Windows.
    echo If you're on Linux/WSL, use: ./build_windows.sh
    pause
    exit /b 1
)

echo.
echo Prerequisites Check:
echo.

REM Check Flutter
echo Checking Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo   ✗ Flutter NOT FOUND
    echo     Download from: https://flutter.dev/docs/get-started/install/windows
    echo     Add Flutter\bin to your PATH
) else (
    echo   ✓ Flutter is installed
)

REM Check Visual Studio
echo Checking Visual Studio Build Tools...
where cl.exe >nul 2>&1
if errorlevel 1 (
    echo   ✗ Visual Studio Build Tools NOT FOUND
    echo     Download from: https://visualstudio.microsoft.com/downloads/
    echo     Select: Desktop development with C++
) else (
    echo   ✓ Visual Studio C++ compiler found
)

REM Check NSIS
echo Checking NSIS...
where makensis.exe >nul 2>&1
if errorlevel 1 (
    echo   ✗ NSIS NOT FOUND (optional)
    echo     Download from: https://nsis.sourceforge.io
    echo     Note: You can still build portable version without NSIS
) else (
    echo   ✓ NSIS is installed
)

echo.
echo ============================================
echo  Building RPD Sky for Windows
echo ============================================
echo.

REM Ask user if they want to build
choice /C YN /M "Ready to build? (Y/N): "
if errorlevel 2 goto :EOF
if errorlevel 1 goto :build

:build
echo.
call build_windows.bat
pause
exit /b 0
