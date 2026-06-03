# Flutter Impeller WebView Repro — Design Spec

**Date:** 2026-06-03  
**Purpose:** Minimal reproducible sample for Flutter bug report — WebView pixelation on Impeller Vulkan backend (Android, ARM Mali-G52)

## Background

Flutter 3.44.1 introduced a regression where WebView renders blocky/pixelated on devices with ARM Mali-G52 GPUs (and other Impeller Vulkan-affected drivers). Setting `EnableImpeller=false` restores correct rendering (Skia fallback). This app demonstrates the broken vs fixed state.

Related Flutter issues:
- [flutter/flutter#177868](https://github.com/flutter/flutter/issues/177868) — WebView pixelated on Impeller Vulkan
- [flutter/flutter#187419](https://github.com/flutter/flutter/issues/187419) — SurfaceProducer/SurfaceTextureEntry corruption on Impeller Vulkan

## App Design

### Single screen

Fullscreen `WebView` loading `https://flutter.dev`, with a semi-transparent overlay in the top-left showing:
- Flutter version (injected at build time via `--dart-define=FLUTTER_VERSION=x.y.z`)
- `EnableImpeller: true/false` (injected at build time via `--dart-define=IMPELLER_ENABLED=true/false`)
- Device model (read at runtime via `device_info_plus`)

### File structure

```
flutter_impeller_webview_repro/
├── lib/
│   ├── main.dart           # MaterialApp + HomePage (WebView + overlay)
│   └── overlay_info.dart   # InfoOverlay widget
├── android/app/src/
│   ├── main/               # Default — EnableImpeller=true (broken)
│   └── impellerOff/        # Flavor — EnableImpeller=false (workaround)
├── pubspec.yaml
├── .tool-versions           # Flutter 3.44.1 pin
└── README.md
```

### Android flavors

Two product flavors in `android/app/build.gradle`:
- `main` (default): `AndroidManifest.xml` with `EnableImpeller=true`
- `impellerOff`: `AndroidManifest.xml` with `EnableImpeller=false`

### Build commands

```bash
# Shows pixelation (Impeller Vulkan — broken)
flutter run --dart-define=FLUTTER_VERSION=3.44.1 --dart-define=IMPELLER_ENABLED=true

# Fixed (Skia fallback — workaround)
flutter run --flavor impellerOff --dart-define=FLUTTER_VERSION=3.44.1 --dart-define=IMPELLER_ENABLED=false
```

## Dependencies

| Package | Purpose |
|---|---|
| `webview_flutter` | WebView widget |
| `device_info_plus` | Runtime device model for overlay |

## Flutter version

Pinned to **3.44.1** via `.tool-versions` (asdf/FVM).

## Out of scope

- Navigation, multiple pages
- iOS support (bug is Android Vulkan-specific)
- Tests
- CI/CD

## Success criteria

On an ARM Mali-G52 device (or other Impeller Vulkan-affected device):
1. Default build shows pixelated/blocky WebView rendering
2. `impellerOff` build shows correct rendering
3. Overlay clearly identifies Flutter version, Impeller status, and device model in screenshots
