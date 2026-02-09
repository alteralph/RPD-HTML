#!/bin/bash
# Build script for Windows AppImage

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building RPD Sky for Windows...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}Flutter not found. Building on Linux for Windows is limited.${NC}"
    echo -e "${YELLOW}To build Windows installers, you need:${NC}"
    echo "  1. Windows system or Windows Subsystem for Linux (WSL2)"
    echo "  2. Flutter SDK with Windows support"
    echo "  3. Visual Studio Build Tools or MinGW"
    echo "  4. NSIS (for installer creation)"
    exit 1
fi

# Step 1: Build Flutter app for Windows
echo -e "${BLUE}Step 1: Building Flutter application for Windows...${NC}"
cd "$PROJECT_DIR"
flutter pub get

# Note: This command requires Windows or proper cross-compilation setup
# For WSL2/cross-compilation, use:
# flutter build windows --release

if flutter build windows --release 2>/dev/null; then
    echo -e "${GREEN}✓ Windows build successful${NC}"
else
    echo -e "${YELLOW}Windows build not possible on Linux. See instructions below.${NC}"
    echo ""
    echo "To build for Windows, do one of the following:"
    echo ""
    echo "Option 1: Build on Windows directly"
    echo "  1. Install Flutter SDK on Windows"
    echo "  2. Run: flutter build windows --release"
    echo "  3. Run: .build_windows.bat"
    echo ""
    echo "Option 2: Use WSL2 on Windows"
    echo "  1. Install Flutter in WSL2"
    echo "  2. Run: flutter build windows --release"
    echo "  3. Run: build_windows.sh"
    echo ""
    exit 0
fi

# Step 2: Prepare dist directory
mkdir -p "$OUTPUT_DIR/windows"

# Step 3: Create portable ZIP
echo -e "${BLUE}Step 2: Creating portable Windows package...${NC}"
if [ -d "$PROJECT_DIR/build/windows/x64/runner/Release" ]; then
    cd "$OUTPUT_DIR/windows"
    
    # Copy application files
    cp -r "$PROJECT_DIR/build/windows/x64/runner/Release" ./rpd-sky-portable
    cp "$PROJECT_DIR/icon.png" ./rpd-sky-portable/
    
    # Create README for portable version
    cat > ./rpd-sky-portable/README.txt << 'PORTABLE_README'
RPD Sky - Portable Version

To run:
1. Extract this folder
2. Double-click rpd-sky.exe

No installation required!

This is a portable executable that doesn't require installation.
Simply run it from anywhere.

For a proper installation with shortcuts and uninstaller,
use the installer (rpd-sky-2.0.0-installer.exe)
PORTABLE_README
    
    # Create ZIP archive
    zip -r "rpd-sky-${flutter_version}-portable.zip" rpd-sky-portable/
    
    echo -e "${GREEN}✓ Portable package created: rpd-sky-portable.zip${NC}"
fi

# Step 4: Instructions for building installer
echo -e "${BLUE}Step 3: Preparing for installer creation...${NC}"
echo ""
echo "To create the Windows installer (.exe):"
echo ""
echo "Option 1: On Windows"
echo "  1. Install NSIS from: https://nsis.sourceforge.io"
echo "  2. Right-click windows_installer.nsi > Compile NSIS Script"
echo "  3. Or run: makensis.exe windows_installer.nsi"
echo ""
echo "Option 2: On Linux/WSL2 with NSIS installed"
echo "  makensis windows_installer.nsi"
echo ""
echo "The installer will be created at: dist/rpd-sky-2.0.0-installer.exe"
echo ""

echo -e "${GREEN}Build preparation complete!${NC}"
echo ""
echo "Output files:"
echo "  - dist/windows/rpd-sky-portable.zip (Portable version)"
echo "  - dist/rpd-sky-2.0.0-installer.exe (After running NSIS)"
