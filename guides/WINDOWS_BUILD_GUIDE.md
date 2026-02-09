# RPD Sky - Windows Build Guide

## Overview

This guide explains how to build RPD Sky as a Windows installer and portable package.

## Prerequisites

### Required
- **Flutter SDK** with Windows support
- **Visual Studio 2022** or **Visual Studio Build Tools 2022**
  - C++ development tools
  - Windows SDK
- **Git** for version control

### Optional (for installer creation)
- **NSIS (Nullsoft Scriptable Install System)**
  - Download: https://nsis.sourceforge.io
  - Used to create professional .exe installers

## Installation Setup

### 1. Install Flutter (Windows)

```bash
# Download Flutter from https://flutter.dev/docs/get-started/install/windows
# Extract to a suitable location (e.g., C:\flutter)
# Add Flutter to PATH

# Verify installation
flutter --version
flutter doctor
```

### 2. Install Visual Studio Build Tools

```bash
# Download from:
# https://visualstudio.microsoft.com/downloads/
# https://visualstudio.microsoft.com/visual-cpp-build-tools/

# During installation, select:
# - Desktop development with C++
# - Windows SDK (latest)
# - CMake tools
```

### 3. Install NSIS (Optional)

```bash
# Download from: https://nsis.sourceforge.io
# Run the installer and follow prompts
# Add to PATH (or NSIS will be found automatically)
```

## Building for Windows

### Quick Build (Automatic)

```bash
# Run the batch script
build_windows.bat

# Or on WSL/Linux:
chmod +x build_windows.sh
./build_windows.sh
```

This will:
1. Get Flutter dependencies
2. Build the release binary
3. Create a portable package
4. Create the installer (if NSIS is available)

### Manual Build Steps

```bash
# Step 1: Get dependencies
flutter pub get

# Step 2: Build release binary
flutter build windows --release

# Step 3: Create portable package (optional)
# The build output is at: build/windows/x64/runner/Release/

# Step 4: Create installer (requires NSIS)
makensis.exe windows_installer.nsi
```

## Output Files

### Portable Version
- **Location**: `dist\windows\rpd-sky-portable\`
- **Contents**: All runtime files needed to run the app
- **Distribution**: Zip the folder and share
- **Usage**: Users extract and run `rpd-sky.exe` directly

### Installer
- **Location**: `dist\rpd-sky-1.0.0-installer.exe`
- **Size**: ~50-100 MB (depends on dependencies)
- **Features**:
  - Installs to Program Files
  - Creates Start Menu shortcuts
  - Creates desktop shortcut
  - Automatic uninstaller
  - Registry entries for Add/Remove Programs
- **Distribution**: Share the .exe file

## Customization

### Application Icon

The installer uses `icon.png` from the project root. To customize:

1. **For installer appearance**, create Windows-compatible icons:
   ```bash
   # Create these files in the project root:
   icon.ico      # 256x256 or larger
   header.bmp    # 150x57 pixels (installer header)
   sidebar.bmp   # 164x314 pixels (installer sidebar)
   ```

2. **Update the NSIS script** if you add custom images:
   Edit `windows_installer.nsi`:
   ```nsis
   !define MUI_ICON "icon.ico"
   !define MUI_HEADERIMAGE_BITMAP "header.bmp"
   !define MUI_WELCOMEFINISHPAGE_BITMAP "sidebar.bmp"
   ```

### Installation Path

To change where the app installs, edit `windows_installer.nsi`:

```nsis
; Current:
!define INSTALL_DIR "$PROGRAMFILES\${APPNAME}"

; Change to:
!define INSTALL_DIR "$APPDATA\${APPNAME}"
```

### Application Name in Registry

Edit `windows_installer.nsi`:

```nsis
!define APPNAME "RPD Sky"
!define APPID "com.alteralph.rpdsky"
!define PUBLISHERNAME "alteralph"
```

## Troubleshooting

### "Flutter not found"
- Ensure Flutter is installed and in PATH
- Run `flutter --version` to verify

### "Visual Studio not found"
- Install Visual Studio Build Tools
- Run `flutter doctor -v` to diagnose

### "NSIS not found"
- Install NSIS from https://nsis.sourceforge.io
- Add to PATH or run from NSIS installation directory

### "Build fails with C++ errors"
- Ensure Visual Studio Build Tools are fully installed
- Run `flutter clean && flutter pub get`
- Try again: `flutter build windows --release`

### "Installer is too large"
- This is normal (includes Flutter runtime)
- Can be reduced by using UPX (executable packer)
- Or remove unneeded files from the build directory

## Distributing Your App

### Option 1: Portable Version
1. Create ZIP: `rpd-sky-portable.zip`
2. Share the ZIP file
3. Users extract and run `rpd-sky.exe`
4. **Pros**: Simple, no admin rights needed
5. **Cons**: Users must find the .exe themselves

### Option 2: Installer
1. Share `rpd-sky-1.0.0-installer.exe`
2. Users run the installer
3. App appears in Start Menu and Control Panel
4. **Pros**: Professional, easy uninstall, familiar to Windows users
5. **Cons**: Requires admin rights during install

### Option 3: Both
1. Provide both options
2. Let users choose their preferred method

## Additional Resources

- **Flutter Windows Documentation**: https://flutter.dev/docs/deployment/windows
- **NSIS Documentation**: https://nsis.sourceforge.io/Docs/
- **Visual Studio Build Tools**: https://visualstudio.microsoft.com/downloads/

## Notes

- The app requires Windows 7 SP1 or later (Windows 10+ recommended)
- 64-bit only (the current build targets x86_64)
- For 32-bit support, rebuild with `flutter build windows --release` using 32-bit Flutter
- The window title will display "RPD Sky" (set in `lib/main.dart`)
- The application icon uses the `icon.png` file

## Version Updates

When releasing a new version:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2
   ```

2. Update version in `windows_installer.nsi`:
   ```nsis
   !define APPVERSION "1.1.0"
   ```

3. Rebuild and redistribute

## Next Steps

1. Run `build_windows.bat` to create your first build
2. Test the portable version and/or installer
3. Distribute to users!
