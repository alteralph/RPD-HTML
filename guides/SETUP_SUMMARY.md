# RPD Sky - Linux Packaging Setup Summary

## What Was Changed

### 1. Application Configuration
- **Binary name**: Changed from `rpd_flutter` to `rpd-sky`
- **App ID**: Changed to `com.alteralph.rpdsky`
- **Display name**: "RPD Sky"
- **Icon**: Uses `icon.png` from project root
- **Window title**: Automatically set to "RPD Sky" at runtime

### 2. Files Created/Modified

#### Modified:
- `linux/CMakeLists.txt` - Updated binary name and application ID
- `lib/main.dart` - Added window_manager dependency and window title setup
- `pubspec.yaml` - Added window_manager package

#### Created:
- `linux/com.alteralph.rpdsky.desktop` - Desktop entry file for Linux systems
- `linux/AppRun` - AppImage entry point script
- `PKGBUILD` - Arch Linux package build definition
- `build_release.sh` - Automated build script (executable)
- `quickstart.sh` - Quick setup script (executable)
- `LINUX_BUILD_GUIDE.md` - Comprehensive build documentation

## Quick Start

### Option 1: Automated Build (Recommended)
```bash
cd ~/Documents/projects/rpd_flutter
./quickstart.sh
```

### Option 2: Manual Build
```bash
cd ~/Documents/projects/rpd_flutter
chmod +x build_release.sh
./build_release.sh
```

## Build Outputs

After running the build script, you'll have:

1. **AppImage** (if appimagetool is installed)
   - Location: `dist/rpd-sky-x86_64.AppImage`
   - Usage: `./dist/rpd-sky-x86_64.AppImage`
   - Portable across Linux distributions

2. **Pacman Package** (if makepkg is available)
   - Location: `dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst`
   - Usage: `sudo pacman -U dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst`

3. **Source Tarball**
   - Location: `dist/rpd-sky-1.0.0.tar.gz`
   - For custom builds or distribution

## Key Features

✓ **Window Title**: "RPD Sky" shown in title bar  
✓ **Application Icon**: Uses your icon.png file  
✓ **Package Name**: "RPD Sky" in application menus  
✓ **Multiple Formats**: Both AppImage and Pacman package support  
✓ **Automated Build**: Single command builds everything  

## Next Steps

1. **Install dependencies** (if not already installed):
   ```bash
   # Arch Linux
   sudo pacman -S flutter cmake ninja gtk3 clang
   
   # Debian/Ubuntu
   sudo apt-get install flutter cmake ninja-build libgtk-3-dev clang
   ```

2. **Build the project**:
   ```bash
   ./quickstart.sh
   ```

3. **Run or distribute**:
   - **AppImage**: Share `dist/rpd-sky-x86_64.AppImage`
   - **Pacman**: Install with `sudo pacman -U dist/pkgbuild/...pkg.tar.zst`

## Notes

- The build process first compiles Flutter to native Linux binaries
- AppImage creation requires appimaketool (optional but recommended)
- Pacman package building requires makepkg (part of base-devel)
- All scripts are bash and work on Linux systems
- The window_manager package ensures proper window title display

## Troubleshooting

If you encounter issues, see [LINUX_BUILD_GUIDE.md](LINUX_BUILD_GUIDE.md) for detailed troubleshooting steps.

For more information about Flutter on Linux, visit: https://flutter.dev/docs/deployment/linux
