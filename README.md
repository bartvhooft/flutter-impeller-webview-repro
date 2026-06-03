# flutter_impeller_webview_repro

Minimal reproducible sample for Flutter WebView pixelation on Impeller Vulkan (Android).

## Bug

WebView renders blocky/pixelated on devices with ARM Mali-G52 GPUs (and other Impeller Vulkan-affected drivers) after Flutter 3.44.1. Setting `EnableImpeller=false` (Skia fallback) restores correct rendering.

Related issues:
- [flutter/flutter#177868](https://github.com/flutter/flutter/issues/177868)
- [flutter/flutter#187419](https://github.com/flutter/flutter/issues/187419)

## Reproduce

### Requirements

- Flutter 3.44.1 (`flutter --version`)
- Android device with ARM Mali-G52 GPU (e.g. Rockchip RK3576, Android 14)
- USB debugging enabled

### Steps

**1. Broken — Impeller Vulkan enabled (default)**

```bash
flutter run \
  --flavor impellerOn \
  --dart-define=APP_FLUTTER_VERSION=3.44.1 \
  --dart-define=IMPELLER_ENABLED=true
```

Observe: WebView content is blocky/pixelated/low-resolution.

**2. Fixed — Impeller disabled (Skia fallback)**

```bash
flutter run \
  --flavor impellerOff \
  --dart-define=APP_FLUTTER_VERSION=3.44.1 \
  --dart-define=IMPELLER_ENABLED=false
```

Observe: WebView renders correctly.

## Device tested

| Field | Value |
|---|---|
| GPU | ARM Mali-G52 |
| SoC | Rockchip RK3576 |
| Android | 14 (API 34) |
| Vulkan level | 1 |
| Flutter log | `e: impeller-naughty-driver` |

## Flutter doctor

```
[paste flutter doctor -v output here]
```
