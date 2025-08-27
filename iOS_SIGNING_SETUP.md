# iOS Code Signing Setup for GitHub Actions

## Overview
The current GitHub Actions workflow builds iOS apps without code signing (`--no-codesign`). For App Store distribution, you'll need to set up proper code signing.

## Required Setup for Production iOS Builds

### 1. Apple Developer Account Requirements
- Active Apple Developer Program membership ($99/year)
- App ID registered in Apple Developer Console
- Distribution Certificate
- Provisioning Profile

### 2. GitHub Secrets Setup
Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

```
IOS_CERTIFICATE_BASE64          # Base64 encoded .p12 certificate
IOS_CERTIFICATE_PASSWORD        # Password for .p12 certificate
IOS_PROVISIONING_PROFILE_BASE64 # Base64 encoded provisioning profile
KEYCHAIN_PASSWORD              # Password for temporary keychain
```

### 3. How to Get Required Files

#### Distribution Certificate (.p12)
1. Open Keychain Access on Mac
2. Find your "iPhone Distribution" certificate
3. Right-click → Export → Save as .p12
4. Convert to base64: `base64 -i certificate.p12 | pbcopy`

#### Provisioning Profile
1. Download from Apple Developer Console
2. Convert to base64: `base64 -i profile.mobileprovision | pbcopy`

### 4. Updated iOS Build Job (for production)
Replace the current `build-ios` job with this signed version:

```yaml
build-ios:
  runs-on: macos-latest
  name: Build iOS App (Signed)

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Setup iOS Signing
      run: |
        # Create temporary keychain
        security create-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
        security default-keychain -s build.keychain
        security unlock-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
        security set-keychain-settings -t 3600 -u build.keychain

        # Import certificate
        echo "${{ secrets.IOS_CERTIFICATE_BASE64 }}" | base64 --decode > certificate.p12
        security import certificate.p12 -k build.keychain -P "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" -T /usr/bin/codesign

        # Import provisioning profile
        echo "${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}" | base64 --decode > profile.mobileprovision
        mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
        cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

        # Set partition list
        security set-key-partition-list -S apple-tool:,apple: -s -k "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain

    - name: Build iOS Archive
      run: flutter build ipa --release

    - name: Upload IPA as artifact
      uses: actions/upload-artifact@v4
      with:
        name: ios-ipa
        path: build/ios/ipa/*.ipa

    - name: Cleanup
      if: always()
      run: |
        security delete-keychain build.keychain
        rm -f certificate.p12 profile.mobileprovision
```

### 5. Current Workflow Status
✅ **Android APK**: Ready for production builds  
⚠️ **iOS**: Currently builds unsigned `.app` files (development only)

To enable signed iOS builds for App Store distribution, follow the setup above and replace the iOS job in the workflow file.

## Testing the Workflow
1. Push changes to `main` branch
2. Check Actions tab for build status
3. Download artifacts from successful builds
4. Android APK can be installed directly
5. iOS .app requires Xcode/simulator for testing (unsigned builds)
