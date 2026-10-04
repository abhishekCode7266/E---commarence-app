# Android Build and Deployment Guide

This guide details how to build, test on devices, sign, and deploy **TaskFlow** to the Google Play Store.

---

## 1. Emulator and Physical Device Setup

### Android Emulator Setup
1. Open Android Studio.
2. Go to **Virtual Device Manager**.
3. Create a Virtual Device with **API 33 or 34** (e.g., Pixel 7 Pro with Google Play Services).
4. Launch the emulator:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

### Physical Android Device Setup
1. On your Android phone, enable **Developer Options**:
   - Go to **Settings > About Phone**.
   - Tap **Build Number** 7 times until you see "You are now a developer".
2. Open **Developer Options** and enable:
   - **USB Debugging**
   - **Install via USB**
3. Connect your device via USB cable and allow USB debugging when prompted.
4. Verify connected devices:
   ```bash
   flutter devices
   ```

---

## 2. Generating a Working Debug APK

To compile and verify the debug build:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Build debug APK
flutter build apk --debug
```

The output APK will be generated at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

To install directly to a connected device:
```bash
flutter install
# Or:
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 3. Generating a Signed Release APK / App Bundle

### Step 1: Create an Upload Keystore

Run the following command in PowerShell / Terminal:

```powershell
keytool -genkey -v -keystore C:\Users\<YourUsername>\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Remember your store password and key password.*

### Step 2: Create `key.properties`

In `android/`, copy `key.properties.example` to `key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=C:\\Users\\<YourUsername>\\upload-keystore.jks
```

> **Security Note:** Never commit `key.properties` or `.jks` files to version control. They are already excluded in `.gitignore`.

### Step 3: Build Signed Release APK
```bash
flutter build apk --release
```
Output:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Build Signed Android App Bundle (AAB for Google Play Store)
Google Play requires App Bundles (`.aab`) for publishing:
```bash
flutter build appbundle --release
```
Output:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 4. Google Play Store Preparation Checklist

Before submitting to Google Play Console:

| Category | Requirement | TaskFlow Status |
| :--- | :--- | :--- |
| **API Level** | `targetSdkVersion 34` (Android 14+) | Configured in `build.gradle` |
| **Minimum SDK** | `minSdkVersion 21` (Android 5.0+) | Configured in `build.gradle` |
| **Format** | Android App Bundle (`.aab`) | Produced via `flutter build appbundle` |
| **App Icon** | 512 x 512 px PNG (32-bit, no alpha) | Configured in mipmap |
| **Feature Graphic** | 1024 x 500 px JPG/PNG | Required for store listing |
| **Screenshots** | At least 2 phone screenshots (16:9 or 9:16) | Capture task list & add task screens |
| **Privacy Policy** | Live URL declaring data usage (Auth & Firestore) | Required in Console Policy tab |
| **Data Safety** | Disclose Email collection for authentication | Self-certify in Console |
| **Permissions** | Exact alarm and notification permissions declared | Documented in Manifest |
