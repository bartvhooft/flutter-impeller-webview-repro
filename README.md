# flutter_impeller_webview_repro

Minimal reproducible sample for Flutter WebView blurry/low-resolution rendering on Impeller OpenGLES (Android).

## Bug

WebView renders blurry/low-resolution on devices with ARM Mali-G52 GPUs after Flutter 3.44.1. Setting `EnableImpeller=false` (Skia fallback) restores correct rendering.

Flutter uses the **Impeller OpenGLES** backend on this device (not Vulkan). Platform view uses SurfaceProducer with legacy composition strategy.

## Reproduce

### Requirements

- Flutter 3.44.1 (`flutter --version`)
- Android device with ARM Mali-G52 GPU (e.g. Rockchip RK3576, Android 14)
- USB debugging enabled

### Steps

**1. Broken — Impeller enabled (default)**

```bash
flutter run \
  --flavor impellerOn \
  --dart-define=APP_FLUTTER_VERSION=3.44.1 \
  --dart-define=IMPELLER_ENABLED=true
```

Observe: WebView content is blurry/low-resolution on physical screen.

**2. Fixed — Impeller disabled (Skia fallback)**

```bash
flutter run \
  --flavor impellerOff \
  --dart-define=APP_FLUTTER_VERSION=3.44.1 \
  --dart-define=IMPELLER_ENABLED=false
```

Observe: WebView renders correctly.

> **Note:** Android screenshots partially mask the issue. Physical camera photos of the screen clearly show the difference.

### How the flavors work

The two flavors control `EnableImpeller` via `AndroidManifest.xml`:

```xml
<!-- impellerOn/AndroidManifest.xml -->
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />

<!-- impellerOff/AndroidManifest.xml -->
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="false"
    tools:replace="android:value" />
```

## Device tested

| Field | Value |
|---|---|
| GPU | ARM Mali-G52 (`GLES: ARM, Mali-G52, OpenGL ES 3.2 v1.g15p0-01eac0`) |
| SoC | Rockchip RK3576 |
| Android | 14 (API 34) |
| Impeller backend | OpenGLES |
| Platform view | SurfaceProducer + legacy composition |

## Flutter doctor

```
[✓] Flutter (Channel stable, 3.44.1, on macOS 26.4.1 25E253 darwin-arm64, locale en-US)
    • Flutter version 3.44.1 on channel stable at /Users/bart.vanhooft/.asdf/installs/flutter/3.44.1
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision 924134a44c (5 days ago), 2026-05-29 12:13:22 -0400
    • Engine revision c416acfeb8
    • Dart version 3.12.1
    • DevTools version 2.57.0

[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.0)
    • Android SDK at /Users/bart.vanhooft/Library/Android/sdk
    • Platform android-36, build-tools 35.0.0
    • Java binary at: /Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 17.0.11+0-17.0.11b1207.24-11852314)
    • All Android licenses accepted.

[✓] Connected device (3 available)
    • Kindermann TD 12xx (mobile) • 10.50.0.103:46193 • android-arm64 • Android 14 (API 34)
```
