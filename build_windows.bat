@echo off
REM RPD Sky Windows Build Script
REM This script builds the Windows installer and portable package

setlocal enabledelayedexpansion
cd /d "%~dp0"

set "PROJECT_DIR=%cd%"
set "OUTPUT_DIR=%PROJECT_DIR%\dist"

echo.
echo ========================================
echo  Building RPD Sky for Windows
echo ========================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

REM Step 1: Get dependencies
echo [Step 1/4] Getting Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

REM Step 2: Build Flutter app for Windows
echo [Step 2/4] Building Flutter application for Windows (Release)...
call flutter build windows --release
if errorlevel 1 (
    echo ERROR: Flutter build failed
    pause
    exit /b 1
)
echo ✓ Build successful

REM Step 3: Create portable package
echo [Step 3/4] Creating portable Windows package...
if not exist "%OUTPUT_DIR%\windows" mkdir "%OUTPUT_DIR%\windows"

setlocal enabledelayedexpansion
if exist "%PROJECT_DIR%\build\windows\x64\runner\Release" (
    echo Copying files...
    if exist "%OUTPUT_DIR%\windows\rpd-sky-portable" rmdir /s /q "%OUTPUT_DIR%\windows\rpd-sky-portable"
    
    xcopy "%PROJECT_DIR%\build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\windows\rpd-sky-portable\" /E /I /Y >nul
    copy "%PROJECT_DIR%\icon.png" "%OUTPUT_DIR%\windows\rpd-sky-portable\" >nul
    
    REM Create README
    (
        echo RPD Sky - Portable Version
        echo.
        echo To run:
        echo 1. This folder contains the portable application
        echo 2. Double-click rpd-sky.exe to launch
        echo.
        echo No installation required!
        echo This executable can be run from anywhere.
        echo.
        echo For a proper installation with shortcuts and uninstaller,
        echo use the installer (rpd-sky-2.0.0-installer.exe^)
    ) > "%OUTPUT_DIR%\windows\rpd-sky-portable\README.txt"
    
    echo ✓ Portable package created
) else (
    echo ERROR: Build output not found
    pause
    exit /b 1
)

REM Step 4: Build installer with NSIS
echo [Step 4/4] Building Windows installer...

where makensis >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: NSIS is not installed
    echo.
    echo To create the installer:
    echo 1. Download NSIS from: https://nsis.sourceforge.io
    echo 2. Install NSIS
    echo 3. Run: makensis.exe windows_installer.nsi
    echo.
) else (
    echo Running NSIS...
    call makensis.exe windows_installer.nsi
    if errorlevel 1 (
        echo ERROR: NSIS build failed
        pause
        exit /b 1
    )
    echo ✓ Installer created successfully
)

echo.
echo ========================================
echo  Build Complete!
echo ========================================
echo.
echo Output files:
echo   Portable: %OUTPUT_DIR%\windows\rpd-sky-portable\
echo   Installer: %OUTPUT_DIR%\rpd-sky-2.0.0-installer.exe (if NSIS is installed)
echo.
echo To distribute:
echo   - Share the portable folder (or ZIP it)
echo   - Or share the installer .exe file
echo.
pause
