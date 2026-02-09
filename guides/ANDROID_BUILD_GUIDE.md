# RPD Sky - Android Build Guide

## Overview

Build APK and AAB files for Android distribution directly on Linux!

## Prerequisites

### Required
- **Flutter SDK** (with Android support)
- **Android SDK** (API level 21+)
- **Java Development Kit (JDK)** (version 11+)

### Optional
- **Android Studio** (for easier setup and testing)
- **Android Emulator** (for testing)
- **adb** (Android Debug Bridge, for device connection)

## Installation

### 1. Install Java Development Kit (JDK)

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install openjdk-11-jdk
java -version
```

#### Arch Linux
```bash
sudo pacman -S jdk-openjdk
java -version
```

#### Other Linux
Download from: https://www.oracle.com/java/technologies/downloads/

### 2. Install Android SDK

#### Option A: Using Android Studio (Recommended)
1. Download Android Studio: https://developer.android.com/studio
2. Extract and run
3. Follow setup wizard
4. Accept all licenses: `flutter doctor --android-licenses`

#### Option B: Using command line tools
```bash
# Download Android command line tools
# https://developer.android.com/studio#command-line-tools

# Set ANDROID_HOME (add to ~/.bashrc or ~/.zshrc)
export ANDROID_HOME=~/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Accept licenses
flutter doctor --android-licenses

# Verify
flutter doctor
```

### 3. Accept Android Licenses

```bash
flutter doctor --android-licenses
# Answer 'y' to all prompts
```

### 4. Verify Setup

```bash
flutter doctor
```

Should show:
```
✓ Flutter
✓ Android toolchain
✓ Java Development Kit (JDK)
✓ Android SDK
```

## Building

### Quick Build

```bash
chmod +x build_android.sh
./build_android.sh
```

This creates:
- **APK** - Universal and/or architecture-specific APKs
- **AAB** - Android App Bundle for Google Play

### Manual Build

#### Release APK (Universal)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Split APKs (optimized by architecture)
```bash
flutter build apk --release --split-per-abi
# Output:
#   build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
#   build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

#### App Bundle (for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Debug APK (for testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

## Output Files

### Universal APK
- **File**: `rpd-sky-release.apk`
- **Size**: ~50-100 MB
- **Use**: Install on any Android device
- **Installation**: Drag to device or `adb install rpd-sky-release.apk`

### Split APKs (optimized)
- **ARM64**: `rpd-sky-arm64-release.apk` (~30 MB)
- **ARMv7**: `rpd-sky-armv7-release.apk` (~28 MB)
- **Use**: More efficient, smaller downloads
- **Installation**: `adb install-multiple arm64 armv7`

### App Bundle
- **File**: `rpd-sky-release.aab`
- **Size**: ~35-50 MB
- **Use**: Google Play Store upload only
- **Installation**: Not installable directly; Google Play generates APKs

## Installation on Device

### Via adb (Android Debug Bridge)

```bash
# Connect device via USB with USB debugging enabled
# Or use emulator

# Install APK
adb install dist/android/rpd-sky-release.apk

# Install and run
adb install -r dist/android/rpd-sky-release.apk
adb shell am start -n com.alteralph.rpdsky/com.alteralph.rpdsky.MainActivity

# View logs
adb logcat | grep flutter
```

### Via Android Studio
1. Open Android Studio
2. Select "Open an existing Android Studio project"
3. Choose `android/` folder
4. Connect device
5. Click "Run"

### Via emulator
```bash
flutter run
# or
flutter run --release
```

## Google Play Store Distribution

### Prerequisites
1. **Google Play Developer Account** ($25 one-time fee)
2. **Signing Key** (create with `keytool`)
3. **App Metadata**:
   - Title: RPD Sky
   - Description
   - Screenshots (minimum 2)
   - Icon (512x512 PNG)
   - Featured graphic
   - Category
   - Privacy policy (if collecting data)

### Step-by-Step

#### 1. Create Signing Key
```bash
# Generate keystore (one time only)
keytool -genkey -v -keystore ~/rpd-sky-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias rpd-sky

# Answer prompts with your information
```

#### 2. Configure Signing in Flutter

Edit `android/app/build.gradle`:
```gradle
signingConfigs {
    release {
        keyAlias System.getenv('KEY_ALIAS') ?: 'rpd-sky'
        keyPassword System.getenv('KEY_PASSWORD')
        storeFile System.getenv('KEYSTORE_PATH') ? file(System.getenv('KEYSTORE_PATH')) : null
        storePassword System.getenv('KEYSTORE_PASSWORD')
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

#### 3. Set Environment Variables
```bash
export KEY_ALIAS=rpd-sky
export KEY_PASSWORD=your_key_password
export KEYSTORE_PATH=~/rpd-sky-keystore.jks
export KEYSTORE_PASSWORD=your_keystore_password
```

#### 4. Build Signed AAB
```bash
flutter build appbundle --release
```

#### 5. Upload to Google Play
1. Go to https://play.google.com/console
2. Create new app or select existing
3. Upload AAB in "Release" section
4. Fill in all required metadata
5. Submit for review

### Release Checklist
- [ ] Create signing key
- [ ] Configure build signing
- [ ] Build release AAB
- [ ] App title: "RPD Sky"
- [ ] App description
- [ ] Screenshots (at least 2)
- [ ] Icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Category selected
- [ ] Privacy policy provided
- [ ] Version code incremented
- [ ] App tested on device

## Testing on Device

### Enable USB Debugging
1. Open Settings on Android device
2. Go to About phone
3. Tap Build number 7 times to unlock Developer Options
4. Go back to Settings
5. Open Developer Options
6. Enable USB Debugging
7. Connect to Linux PC

### Test APK
```bash
# Check connected devices
adb devices

# Install and run
adb install dist/android/rpd-sky-release.apk
adb shell am start -n com.alteralph.rpdsky/com.alteralph.rpdsky.MainActivity

# View logs
adb logcat flutter:V *:S
```

## Troubleshooting

### "Android SDK not found"
```bash
flutter doctor
# Will tell you what's missing

# Set Android home
export ANDROID_HOME=~/Android/Sdk
flutter doctor --android-licenses
```

### "Java not found"
```bash
sudo apt-get install openjdk-11-jdk
java -version
```

### "Gradle build failed"
```bash
flutter clean
flutter pub get
flutter build apk --release -v
```

### "APK too large"
- Remove unused dependencies from `pubspec.yaml`
- Use `--split-per-abi` to create smaller APKs
- Enable ProGuard minification in `android/app/build.gradle`

### "App crashes on startup"
```bash
adb logcat | grep flutter
# Check error logs for clues
```

### "Can't connect to device"
```bash
# Check USB debugging is enabled
adb devices

# Restart adb
adb kill-server
adb start-server

# Check permissions
adb root
```

## Architecture Support

Your app is configured for multiple architectures:
- **ARM64** (arm64-v8a) - Modern phones (90%+)
- **ARMv7** (armeabi-v7a) - Older phones
- **x86** - Tablets and emulators
- **x86_64** - Modern tablets and emulators

## App Metadata (AndroidManifest.xml)

Located in `android/app/src/main/AndroidManifest.xml`

Current configuration:
```xml
<application
    android:label="RPD Sky"
    android:icon="@mipmap/ic_launcher">
```

To customize:
- App name: Edit `android/app/src/main/AndroidManifest.xml`
- Icon: Place in `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Permissions: Add to `AndroidManifest.xml`

## Permissions

Your app currently has these permissions (if needed):
```xml
<!-- In AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^     ^
#     semantic  build number
```

This automatically updates `android/app/build.gradle`:
```gradle
versionName "1.0.0"
versionCode 1
```

## Next Steps

1. ✅ Install JDK and Android SDK
2. ✅ Run `flutter doctor --android-licenses`
3. ✅ Run `./build_android.sh`
4. ✅ Test APK on device
5. ✅ Create signing key (for Play Store)
6. ✅ Upload to Google Play

## Resources

- **Flutter Android Docs**: https://flutter.dev/docs/deployment/android
- **Android Dev Docs**: https://developer.android.com/docs
- **Google Play Console**: https://play.google.com/console
- **adb Commands**: https://developer.android.com/studio/command-line/adb

## Support

For issues:
```bash
flutter doctor -v        # Detailed diagnostics
flutter build apk -v     # Verbose build output
adb logcat -c            # Clear logs
adb logcat flutter:V *:S # Filter to Flutter logs
```
