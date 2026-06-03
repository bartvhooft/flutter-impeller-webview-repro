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
  --dart-define=IMPELLER_ENABLED=true
```

Observe: WebView content is blurry/low-resolution on physical screen.

**2. Fixed — Impeller disabled (Skia fallback)**

```bash
flutter run \
  --flavor impellerOff \
  --dart-define=IMPELLER_ENABLED=false
```

Observe: WebView renders correctly.

Impeller: ON
<img width="4032" height="3024" alt="IMG_2709" src="https://github.com/user-attachments/assets/29eb7f29-3639-47e2-9f38-151577f0e925" />

Impeller: OFF
<img width="4032" height="3024" alt="IMG_2711" src="https://github.com/user-attachments/assets/8fad2da0-6cc1-4e89-8b2a-b941ae0369db" />

Impeller: ON
<img width="1091" height="596" alt="Screenshot 2026-06-03 at 14 14 08" src="https://github.com/user-attachments/assets/60fa8f2f-2351-4717-8fde-397e1e0562eb" />

Impeller: OFF
<img width="1034" height="604" alt="Screenshot 2026-06-03 at 14 14 01" src="https://github.com/user-attachments/assets/41f69084-f8ab-49c2-8211-46dd1af91e16" />


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

## Logs

Key lines captured via `adb logcat` on startup:

```
D libEGL               : loaded /vendor/lib64/egl/libGLES_mali.so
I flutter              : [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
I PlatformViewsChannel : Using legacy platform view rendering strategy.
I PlatformViewsController: Hosting view in view hierarchy for platform view: 0
I PlatformViewsController: PlatformView is using SurfaceProducer backend
```

Vulkan layers load (`VK_LAYER_KHRONOS_validation` found) but Flutter never initializes a Vulkan context — goes straight to OpenGLES.

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
