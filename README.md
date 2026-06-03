# flutter_impeller_webview_repro

Minimal reproducible sample for Flutter WebView blurry/low-resolution rendering on Impeller OpenGLES (Android).

## Bug

WebView renders blurry/low-resolution on devices with ARM Mali-G52 GPUs after Flutter 3.44.1. Setting `EnableImpeller=false` (Skia fallback) restores correct rendering.

Flutter uses the **Impeller OpenGLES** backend on this device (not Vulkan). Platform view uses SurfaceProducer with legacy composition strategy.

Related issues:
- [flutter/flutter#177868](https://github.com/flutter/flutter/issues/177868)
- [flutter/flutter#187419](https://github.com/flutter/flutter/issues/187419)

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
[paste flutter doctor -v output here]
```
