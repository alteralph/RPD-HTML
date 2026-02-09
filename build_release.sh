#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR="$PROJECT_DIR/build/linux/x64/release/bundle"
OUTPUT_DIR="$PROJECT_DIR/dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building RPD Sky for Linux...${NC}"

# Step 1: Build Flutter app for Linux
echo -e "${BLUE}Step 1: Building Flutter application...${NC}"
cd "$PROJECT_DIR"
flutter pub get
flutter build linux --release

if [ ! -d "$RELEASE_DIR" ]; then
    echo -e "${RED}Error: Build failed. Release directory not found.${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 2: Build AppImage
echo -e "${BLUE}Step 2: Building AppImage...${NC}"

APPIMAGE_DIR="$OUTPUT_DIR/rpd-sky.AppDir"
rm -rf "$APPIMAGE_DIR"
mkdir -p "$APPIMAGE_DIR/usr/bin"
mkdir -p "$APPIMAGE_DIR/usr/share/applications"
mkdir -p "$APPIMAGE_DIR/usr/share/pixmaps"

# Copy application files
cp -r "$RELEASE_DIR"/* "$APPIMAGE_DIR/usr/bin/" 2>/dev/null || true

# Copy desktop file to both locations
cp "$PROJECT_DIR/linux/com.alteralph.rpdsky.desktop" "$APPIMAGE_DIR/"
cp "$PROJECT_DIR/linux/com.alteralph.rpdsky.desktop" "$APPIMAGE_DIR/usr/share/applications/"

# Copy icon
cp "$PROJECT_DIR/icon.png" "$APPIMAGE_DIR/usr/share/pixmaps/rpd-sky.png"
cp "$PROJECT_DIR/icon.png" "$APPIMAGE_DIR/rpd-sky.png"

# Create AppRun script
cat > "$APPIMAGE_DIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export LD_LIBRARY_PATH="$HERE/usr/bin/lib:$LD_LIBRARY_PATH"
exec "$HERE/usr/bin/rpd-sky" "$@"
EOF
chmod +x "$APPIMAGE_DIR/AppRun"

# Create AppImage using appimagetool if available
if command -v appimagetool &> /dev/null; then
    echo -e "${BLUE}Creating AppImage with appimagetool...${NC}"
    ARCH=x86_64 appimagetool "$APPIMAGE_DIR" "$OUTPUT_DIR/rpd-sky-x86_64.AppImage"
    chmod +x "$OUTPUT_DIR/rpd-sky-x86_64.AppImage"
    echo -e "${GREEN}✓ AppImage created: $OUTPUT_DIR/rpd-sky-x86_64.AppImage${NC}"
else
    echo -e "${BLUE}appimagetool not found. Skipping AppImage creation.${NC}"
    echo "To create AppImage, install appimagetool:"
    echo "  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    echo "  chmod +x appimagetool-x86_64.AppImage"
    echo "  sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool"
fi

# Step 3: Build Pacman package
echo -e "${BLUE}Step 3: Building Pacman package...${NC}"

if command -v makepkg &> /dev/null; then
    PKGBUILD_DIR="$OUTPUT_DIR/pkgbuild"
    mkdir -p "$PKGBUILD_DIR"
    
    # Clean old builds
    rm -rf "$PKGBUILD_DIR/src" "$PKGBUILD_DIR/pkg" "$PKGBUILD_DIR"/*.pkg.tar.zst 2>/dev/null || true
    
    # Copy PKGBUILD
    cp "$PROJECT_DIR/PKGBUILD" "$PKGBUILD_DIR/"
    
    cd "$PKGBUILD_DIR"
    
    echo -e "${BLUE}Running makepkg in: $PKGBUILD_DIR${NC}"
    if makepkg -f; then
        PACKAGE_FILE=$(ls -1 rpd-sky-*.pkg.tar.zst 2>/dev/null | head -1)
        if [ -f "$PACKAGE_FILE" ]; then
            echo -e "${GREEN}✓ Pacman package built successfully!${NC}"
            echo -e "${GREEN}  Location: $PKGBUILD_DIR/$PACKAGE_FILE${NC}"
            echo -e "${GREEN}  Install with: sudo pacman -U $PKGBUILD_DIR/$PACKAGE_FILE${NC}"
        else
            echo -e "${RED}Package file not found after makepkg${NC}"
        fi
    else
        echo -e "${RED}makepkg failed${NC}"
    fi
else
    echo -e "${RED}makepkg not found. Install with: sudo pacman -S base-devel${NC}"
fi

echo -e "${GREEN}Build complete!${NC}"
echo -e "${GREEN}Output files in: $OUTPUT_DIR${NC}"
