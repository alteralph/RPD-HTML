#!/bin/bash
# Quick start guide for Android builds on Linux

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}RPD Sky - Android Build Setup${NC}"
echo "=================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Java
echo -n "Java (JDK): "
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Found${NC} ($java_version)"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    echo "  Install: sudo apt-get install openjdk-11-jdk"
fi

# Check Flutter
echo -n "Flutter: "
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    echo "  Install: https://flutter.dev/docs/get-started/install/linux"
fi

# Check Android SDK
echo -n "Android SDK: "
if [ -n "$ANDROID_HOME" ] || [ -d "$HOME/Android/Sdk" ]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${YELLOW}⚠ Not configured${NC}"
    echo "  Set: export ANDROID_HOME=\$HOME/Android/Sdk"
fi

echo ""
echo "Running flutter doctor..."
echo ""

# Run flutter doctor
flutter doctor

echo ""
echo "=================================="
echo ""

# Ask if user wants to continue
echo -e "${BLUE}Setup Instructions:${NC}"
echo ""
echo "1. If Java is missing:"
echo "   sudo apt-get install openjdk-11-jdk"
echo ""
echo "2. If Android SDK is missing:"
echo "   - Download Android Studio: https://developer.android.com/studio"
echo "   - Or use command-line tools: https://developer.android.com/studio/command-line"
echo ""
echo "3. Accept Android licenses:"
echo "   flutter doctor --android-licenses"
echo ""
echo "4. Build APK:"
echo "   chmod +x build_android.sh"
echo "   ./build_android.sh"
echo ""
echo "5. Install on device:"
echo "   adb install dist/android/rpd-sky-release.apk"
echo ""
