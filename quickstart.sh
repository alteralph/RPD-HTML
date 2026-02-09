#!/bin/bash
# Quick start script - builds AppImage and Pacman package

echo "RPD Sky - Linux Build Quickstart"
echo "=================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install/linux"
    exit 1
fi

echo "✓ Flutter found"

# Check for required build tools
MISSING_TOOLS=()

if ! command -v cmake &> /dev/null; then MISSING_TOOLS+=("cmake"); fi
if ! command -v ninja &> /dev/null; then MISSING_TOOLS+=("ninja"); fi
if ! command -v pkg-config &> /dev/null; then MISSING_TOOLS+=("pkg-config"); fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ Missing required tools: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Install on Arch Linux:"
    echo "  sudo pacman -S cmake ninja gtk3"
    echo ""
    echo "Install on Debian/Ubuntu:"
    echo "  sudo apt-get install cmake ninja-build libgtk-3-dev pkg-config"
    exit 1
fi

echo "✓ All required build tools found"
echo ""

# Run the main build script
cd "$(dirname "${BASH_SOURCE[0]}")"
chmod +x build_release.sh
./build_release.sh

echo ""
echo "✓ Build complete!"
echo ""
echo "Output files:"
echo "  - AppImage: dist/rpd-sky-x86_64.AppImage"
echo "  - Pacman:   dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst (if built)"
echo ""
echo "To run the AppImage:"
echo "  ./dist/rpd-sky-x86_64.AppImage"
echo ""
echo "To install with Pacman:"
echo "  sudo pacman -U dist/pkgbuild/rpd-sky-1.0.0-1-x86_64.pkg.tar.zst"
