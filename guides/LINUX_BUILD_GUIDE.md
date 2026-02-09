# RPD Sky - Linux Build Guide

## Overview
This guide explains how to build RPD Sky as both an AppImage and a Pacman package for Linux.

## Prerequisites

### For Building
- Flutter SDK with Linux support
- CMake 3.13+
- Ninja build system
- GTK3 development files
- clang and linux-headers

Install dependencies on Arch Linux:
```bash
sudo pacman -S flutter cmake ninja gtk3 clang linux-headers
```

Install dependencies on Debian/Ubuntu:
```bash
sudo apt-get install cmake ninja-build libgtk-3-dev clang linux-headers-generic
```

### For AppImage (Optional)
- appimagetool (for creating AppImages)

```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimaketool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimaketool
```

## Quick Build

Run the automated build script:
```bash
chmod +x build_release.sh
./build_release.sh
```

This will:
1. Build the Flutter application for Linux
2. Create an AppImage (if appimagetool is installed)
3. Prepare source files for Pacman packaging
4. Build a Pacman package (if makepkg is available)

## Build Outputs

All files will be created in the `dist/` directory:
- `rpd-sky-x86_64.AppImage` - Standalone AppImage executable
- `rpd-sky-1.0.0.tar.gz` - Source tarball for Pacman build
- `pkgbuild/` - Pacman package build directory

## Manual AppImage Build

If you prefer to build manually:

```bash
# 1. Build Flutter
flutter pub get
flutter build linux --release

# 2. Create AppImage structure
mkdir -p rpd-sky.AppDir/usr/{bin,share/{applications,pixmaps}}
cp -r build/linux/x64/release/bundle/* rpd-sky.AppDir/usr/bin/
cp linux/com.alteralph.rpdsky.desktop rpd-sky.AppDir/usr/share/applications/
cp icon.png rpd-sky.AppDir/usr/share/pixmaps/rpd-sky.png

# 3. Create AppRun script
cat > rpd-sky.AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export LD_LIBRARY_PATH="$HERE/usr/bin/lib:$LD_LIBRARY_PATH"
exec "$HERE/usr/bin/rpd-sky" "$@"
EOF
chmod +x rpd-sky.AppDir/AppRun

# 4. Generate AppImage
appimagetool rpd-sky.AppDir rpd-sky-x86_64.AppImage
```

## Manual Pacman Package Build

If you prefer to build manually:

```bash
# 1. Create a build directory
mkdir -p build_pacman
cd build_pacman

# 2. Copy PKGBUILD
cp ../PKGBUILD .

# 3. Build package
makepkg

# 4. Install (optional)
sudo pacman -U rpd-sky-1.0.0-1-x86_64.pkg.tar.zst
```

## Testing

### AppImage
```bash
./dist/rpd-sky-x86_64.AppImage
```

### Pacman Package
```bash
sudo pacman -U dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst
rpd-sky
```

## Configuration Files

- **[linux/CMakeLists.txt](linux/CMakeLists.txt)** - Build configuration with app name "RPD Sky"
- **[linux/com.alteralph.rpdsky.desktop](linux/com.alteralph.rpdsky.desktop)** - Desktop entry file
- **[linux/AppRun](linux/AppRun)** - AppImage entry point script
- **[PKGBUILD](PKGBUILD)** - Arch Linux package definition
- **[build_release.sh](build_release.sh)** - Automated build script

## Window Title and Icon

The application now includes:
- **Window Title**: "RPD Sky" (set via window_manager package)
- **Application Icon**: Uses the `icon.png` file from the project root
- **Package Name**: RPD Sky (as shown in application menus)

## Troubleshooting

### Flutter build fails with GTK errors
Ensure GTK3 development files are installed:
```bash
# Arch Linux
sudo pacman -S gtk3

# Debian/Ubuntu
sudo apt-get install libgtk-3-dev pkg-config
```

### appimagetool not found
Either install appimagetool (see Prerequisites) or just use the AppDir folder as-is.

### makepkg permission denied
Run with proper permissions:
```bash
cd dist/pkgbuild
makepkg -s  # Build with dependency resolution
```

### Window title not showing in title bar
The window manager support may require a window manager setting. Ensure your window manager respects the `_NET_WM_NAME` property.

## Distribution

### Share AppImage
- The AppImage file (`rpd-sky-x86_64.AppImage`) is self-contained and can be run on any Linux x86_64 system with glibc.
- Users can simply download and run it: `./rpd-sky-x86_64.AppImage`

### Share Pacman Package
- The package file (`.pkg.tar.zst`) can be installed with: `sudo pacman -U rpd-sky-1.0.0-1-x86_64.pkg.tar.zst`
- For distribution on Arch User Repository (AUR), update the PKGBUILD and submit to AUR.

## Notes

- The binary name is `rpd-sky` (with hyphen, not underscore)
- Application ID is `com.alteralph.rpdsky`
- Both AppImage and Pacman builds use the same icon and desktop configuration
