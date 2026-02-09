#!/bin/bash
# Build script for Android APK

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building RPD Sky for Android...${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# Step 1: Check Android setup
echo -e "${BLUE}Step 1: Checking Android setup...${NC}"
flutter doctor -v | grep -A 10 "Android toolchain"

# Step 2: Get dependencies
echo -e "${BLUE}Step 2: Getting Flutter dependencies...${NC}"
cd "$PROJECT_DIR"
flutter pub get

# Step 3: Build APK Release
echo -e "${BLUE}Step 3: Building Android APK (Release)...${NC}"
flutter build apk --release --split-per-abi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ APK build successful!${NC}"
else
    echo -e "${YELLOW}Build failed. Check errors above.${NC}"
    exit 1
fi

# Step 4: Copy to dist
echo -e "${BLUE}Step 4: Copying APK to dist...${NC}"
mkdir -p "$OUTPUT_DIR/android"

# Copy all APKs
if [ -d "$PROJECT_DIR/build/app/outputs/flutter-apk" ]; then
    cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk" \
       "$OUTPUT_DIR/android/rpd-sky-release.apk" 2>/dev/null || true
    
    # Copy split APKs if they exist
    if [ -d "$PROJECT_DIR/build/app/outputs/flutter-apk" ]; then
        cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" \
           "$OUTPUT_DIR/android/rpd-sky-arm64-release.apk" 2>/dev/null || true
        cp "$PROJECT_DIR/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" \
           "$OUTPUT_DIR/android/rpd-sky-armv7-release.apk" 2>/dev/null || true
    fi
fi

# Step 5: Build AAB (Android App Bundle) for Google Play
echo -e "${BLUE}Step 5: Building Android App Bundle (AAB)...${NC}"
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ AAB build successful!${NC}"
    
    # Copy AAB to dist
    if [ -f "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab" ]; then
        cp "$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab" \
           "$OUTPUT_DIR/android/rpd-sky-release.aab"
    fi
fi

# Step 6: Create summary
echo ""
echo -e "${GREEN}Build Complete!${NC}"
echo ""
echo "Output files:"
if [ -f "$OUTPUT_DIR/android/rpd-sky-release.apk" ]; then
    echo "  - Universal APK: $OUTPUT_DIR/android/rpd-sky-release.apk"
fi
if [ -f "$OUTPUT_DIR/android/rpd-sky-arm64-release.apk" ]; then
    echo "  - ARM64 APK: $OUTPUT_DIR/android/rpd-sky-arm64-release.apk"
fi
if [ -f "$OUTPUT_DIR/android/rpd-sky-armv7-release.apk" ]; then
    echo "  - ARMv7 APK: $OUTPUT_DIR/android/rpd-sky-armv7-release.apk"
fi
if [ -f "$OUTPUT_DIR/android/rpd-sky-release.aab" ]; then
    echo "  - Google Play Bundle: $OUTPUT_DIR/android/rpd-sky-release.aab"
fi
echo ""

# Installation instructions
echo "To install on device/emulator:"
echo "  adb install $OUTPUT_DIR/android/rpd-sky-release.apk"
echo ""

echo -e "${BLUE}For Google Play Store:${NC}"
echo "  1. Upload the AAB file ($OUTPUT_DIR/android/rpd-sky-release.aab)"
echo "  2. Use Google Play Console"
echo "  3. Requires: signing key, app metadata, screenshots, etc."
echo ""
