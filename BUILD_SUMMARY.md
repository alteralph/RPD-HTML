# RPD Sky - Complete Build Summary

## What You Have Now

Your project is now configured to build for **three platforms**:

### 1. Linux (AppImage & Pacman)
**Location**: `./quickstart.sh` or `./build_release.sh`

**Output**:
- `dist/rpd-sky-x86_64.AppImage` - Portable executable
- `dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst` - Pacman package
- `dist/rpd-sky-1.0.0.tar.gz` - Source tarball

**Build**:
```bash
./quickstart.sh
```

---

### 2. Windows (Portable & Installer)
**Location**: `./build_windows.bat` (on Windows) or `./build_windows.sh` (on Linux/WSL)

**Output**:
- `dist/windows/rpd-sky-portable/` - Standalone executable folder
- `dist/rpd-sky-1.0.0-installer.exe` - Professional installer (requires NSIS)

**Build on Windows**:
```bash
build_windows.bat
```

**Build on Linux/WSL**:
```bash
chmod +x build_windows.sh
./build_windows.sh
```

---

### 3. Android (APK & AAB)
**Location**: `./build_android.sh`

**Output**:
- `dist/android/rpd-sky-release.apk` - Universal APK (all devices)
- `dist/android/rpd-sky-arm64-release.apk` - ARM64 optimized APK
- `dist/android/rpd-sky-armv7-release.apk` - ARMv7 optimized APK
- `dist/android/rpd-sky-release.aab` - App Bundle (Google Play)

**Prerequisites**:
- Java Development Kit (JDK) 11+
- Android SDK

**Build**:
```bash
chmod +x build_android.sh
./build_android.sh
```

---

### 4. macOS (Future)
Use Flutter's built-in macOS support:
```bash
flutter build macos --release
```

---

## Quick Reference

| Platform | Command | Output | Format |
|----------|---------|--------|--------|
| **Linux** | `./quickstart.sh` | AppImage + Pacman | Portable + Package Manager |
| **Windows** | `build_windows.bat` | Portable + Installer | Standalone + .exe Installer |
| **macOS** | `flutter build macos` | .app bundle | Native macOS app |

---

## Build Scripts Summary

### Linux Scripts
- **`quickstart.sh`** - Fastest way to build everything
  - Builds AppImage
  - Builds Pacman package
  - One command, fully automated

- **`build_release.sh`** - Manual control over build steps
  - More detailed output
  - Better for debugging
  - Same end result as quickstart

### Windows Scripts
- **`build_windows.bat`** - Windows batch script
  - Run from Command Prompt or PowerShell on Windows
  - Builds portable package automatically
  - Can build NSIS installer if installed

- **`build_windows.sh`** - Bash version
  - Run on Linux, WSL, or macOS with bash
  - Useful for CI/CD pipelines
  - Cross-platform compatibility

---

## Configuration Files

| File | Platform | Purpose |
|------|----------|---------|
| `linux/CMakeLists.txt` | Linux | Build configuration (app name set to "RPD Sky") |
| `PKGBUILD` | Linux | Arch Linux package definition |
| `windows_installer.nsi` | Windows | NSIS installer script |
| `pubspec.yaml` | All | Flutter dependencies and metadata |

---

## Desktop Files & Branding

### Linux
- **Icon**: `icon.png` (used in all Linux distributions)
- **Desktop Entry**: `linux/com.alteralph.rpdsky.desktop` (app menu entry)
- **Window Title**: "RPD Sky" (set in code via window_manager)

### Windows
- **Icon**: `icon.png` (used in installer and shortcuts)
- **App Name**: "RPD Sky" (in Start Menu and Control Panel)
- **Company**: alteralph (in registry)

---

## Distribution Checklist

### For Linux Users
- [ ] Test `rpd-sky-x86_64.AppImage` 
  - Easy to share, works on any Linux
  - Users just download and run

- [ ] Test Pacman package (if you have Arch Linux)
  - Users install with: `sudo pacman -U rpd-sky-1.0.0-1-x86_64.pkg.tar.zst`
  - Shows in Add/Remove Programs

### For Windows Users
- [ ] Test portable version
  - Users extract and run `rpd-sky.exe`
  - No installation required
  - Can run from USB

- [ ] Test installer
  - Users run `.exe` installer
  - Installs to Program Files
  - Creates Start Menu shortcut
  - Professional experience

### For All Users
- [ ] Window title shows "RPD Sky" ✓
- [ ] Application icon displays correctly ✓
- [ ] App name is proper case ✓

---

## Next Steps

### If building on Linux:
```bash
# Build for Linux
./quickstart.sh

# To also build Windows:
# You'll need to do this on Windows or WSL2
# Then run: build_windows.bat
```

### If building on Windows:
```bash
# Build for Windows
build_windows.bat

# To also build Linux:
# You'll need Linux or WSL
# Then run: ./quickstart.sh
```

### Release Steps:
1. **Test** on target platform
2. **Version bump** (if needed):
   - Update `pubspec.yaml` version
   - Update `windows_installer.nsi` APPVERSION
   - Update `PKGBUILD` pkgver

3. **Rebuild** all targets:
   - Linux: `./quickstart.sh`
   - Windows: `build_windows.bat`

4. **Package** for distribution:
   - Linux: Upload AppImage or Pacman package
   - Windows: Upload .exe installer or portable .zip

5. **Distribute**:
   - GitHub Releases
   - Your website
   - Package managers

---

## Documentation Available

- **Linux Guide**: [LINUX_BUILD_GUIDE.md](LINUX_BUILD_GUIDE.md)
- **Windows Guide**: [WINDOWS_BUILD_GUIDE.md](WINDOWS_BUILD_GUIDE.md)
- **Setup Summary**: [SETUP_SUMMARY.md](SETUP_SUMMARY.md)

---

## Key Features Implemented

✓ **Cross-platform support** (Linux & Windows)
✓ **Professional installers** (NSIS for Windows, Pacman for Linux)
✓ **Portable versions** (AppImage for Linux, standalone exe for Windows)
✓ **Proper branding** (App name, icon, window title)
✓ **Automated builds** (One-command build scripts)
✓ **Registry integration** (Windows Add/Remove Programs)
✓ **Menu shortcuts** (Start Menu, Desktop, Applications)
✓ **Uninstaller** (Clean removal support)

---

## Success!

You now have a fully buildable, distributable application for Linux and Windows!

Build with confidence:
```bash
# Linux
./quickstart.sh

# Windows
build_windows.bat
```

Enjoy! 🚀
