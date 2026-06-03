# Flutter Impeller WebView Repro — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal Flutter app that reproduces WebView pixelation on Impeller Vulkan (Android) and demonstrates the `EnableImpeller=false` workaround, suitable for filing a Flutter bug report.

**Architecture:** Single-screen app with a fullscreen WebView and a small info overlay. Two Android product flavors (`main` = Impeller on, `impellerOff` = Impeller off) share one Dart codebase. Build-time `--dart-define` values inject Flutter version and Impeller status into the overlay.

**Tech Stack:** Flutter 3.44.1, Dart, `webview_flutter ^4.x`, `device_info_plus ^10.x`, Android Gradle with product flavors

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `pubspec.yaml` | Create | App metadata + dependencies |
| `.tool-versions` | Create | Pin Flutter 3.44.1 via asdf |
| `lib/main.dart` | Create | MaterialApp → HomePage with WebView + overlay |
| `lib/overlay_info.dart` | Create | InfoOverlay widget |
| `android/app/build.gradle` | Modify | Add `impellerOff` product flavor |
| `android/app/src/main/AndroidManifest.xml` | Modify | Default manifest — `EnableImpeller=true` |
| `android/app/src/impellerOff/AndroidManifest.xml` | Create | Override manifest — `EnableImpeller=false` |
| `README.md` | Create | Steps to reproduce + build commands |

---

## Task 1: Bootstrap Flutter app

**Files:**
- Run: `flutter create` in `/Users/bart.vanhooft/git/dev/flutter-impeller-webview-repro/`

- [ ] **Step 1: Create the Flutter app**

```bash
cd /Users/bart.vanhooft/git/dev/flutter-impeller-webview-repro
export PATH="$HOME/.asdf/shims:$PATH"
flutter create --org com.gynzy.repro --project-name flutter_impeller_webview_repro .
```

Expected output: `All done! ...`

- [ ] **Step 2: Pin Flutter version**

Create `.tool-versions`:
```
flutter 3.44.1
```

- [ ] **Step 3: Verify Flutter version resolves**

```bash
export PATH="$HOME/.asdf/shims:$PATH"
flutter --version
```

Expected: `Flutter 3.44.1`

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "chore: bootstrap flutter app"
```

---

## Task 2: Add dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add packages to pubspec.yaml**

Replace the `dependencies:` section with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.10.0
  device_info_plus: ^10.1.0
```

- [ ] **Step 2: Install packages**

```bash
export PATH="$HOME/.asdf/shims:$PATH"
flutter pub get
```

Expected: `Got dependencies!`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add webview_flutter and device_info_plus"
```

---

## Task 3: Build the InfoOverlay widget

**Files:**
- Create: `lib/overlay_info.dart`

- [ ] **Step 1: Create overlay_info.dart**

```dart
import 'package:flutter/material.dart';

class InfoOverlay extends StatelessWidget {
  const InfoOverlay({
    super.key,
    required this.flutterVersion,
    required this.impellerEnabled,
    required this.deviceModel,
  });

  final String flutterVersion;
  final bool impellerEnabled;
  final String deviceModel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Flutter: $flutterVersion'),
              Text(
                'Impeller: ${impellerEnabled ? "enabled" : "disabled"}',
                style: TextStyle(
                  color: impellerEnabled ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
              Text('Device: $deviceModel'),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
export PATH="$HOME/.asdf/shims:$PATH"
flutter analyze lib/overlay_info.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/overlay_info.dart
git commit -m "feat: add InfoOverlay widget"
```

---

## Task 4: Build the main screen

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace lib/main.dart**

```dart
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'overlay_info.dart';

const String _flutterVersion =
    String.fromEnvironment('FLUTTER_VERSION', defaultValue: 'unknown');
const bool _impellerEnabled =
    bool.fromEnvironment('IMPELLER_ENABLED', defaultValue: true);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impeller WebView Repro',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _controller;
  String _deviceModel = 'loading...';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev'));
    _loadDeviceModel();
  }

  Future<void> _loadDeviceModel() async {
    final info = DeviceInfoPlugin();
    String model;
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      model = '${android.manufacturer} ${android.model}';
    } else {
      model = 'non-android';
    }
    setState(() => _deviceModel = model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          InfoOverlay(
            flutterVersion: _flutterVersion,
            impellerEnabled: _impellerEnabled,
            deviceModel: _deviceModel,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
export PATH="$HOME/.asdf/shims:$PATH"
flutter analyze lib/main.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: add HomePage with WebView and InfoOverlay"
```

---

## Task 5: Configure Android product flavors

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `android/app/src/impellerOff/AndroidManifest.xml`

- [ ] **Step 1: Add impellerOff flavor to android/app/build.gradle**

Inside the `android { ... }` block, add a `flavorDimensions` and `productFlavors` block. Find the line `buildTypes {` and insert before it:

```groovy
    flavorDimensions += "impeller"

    productFlavors {
        main {
            dimension "impeller"
        }
        impellerOff {
            dimension "impeller"
        }
    }
```

- [ ] **Step 2: Confirm EnableImpeller=true in main AndroidManifest**

Open `android/app/src/main/AndroidManifest.xml`. Inside the `<application>` tag, add (or confirm present):

```xml
        <meta-data
            android:name="io.flutter.embedding.android.EnableImpeller"
            android:value="true" />
```

- [ ] **Step 3: Create impellerOff flavor manifest**

Create `android/app/src/impellerOff/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application>
        <meta-data
            android:name="io.flutter.embedding.android.EnableImpeller"
            android:value="false"
            tools:replace="android:value" />
    </application>

</manifest>
```

- [ ] **Step 4: Verify build resolves (no device needed)**

```bash
export PATH="$HOME/.asdf/shims:$PATH"
flutter build apk --flavor main --dart-define=FLUTTER_VERSION=3.44.1 --dart-define=IMPELLER_ENABLED=true --debug
flutter build apk --flavor impellerOff --dart-define=FLUTTER_VERSION=3.44.1 --dart-define=IMPELLER_ENABLED=false --debug
```

Expected: both commands end with `Built build/app/outputs/flutter-apk/...`

- [ ] **Step 5: Commit**

```bash
git add android/
git commit -m "feat: add impellerOff Android product flavor"
```

---

## Task 6: Write README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create README.md**

```markdown
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
  --dart-define=FLUTTER_VERSION=3.44.1 \
  --dart-define=IMPELLER_ENABLED=true
```

Observe: WebView content is blocky/pixelated/low-resolution.

**2. Fixed — Impeller disabled (Skia fallback)**

```bash
flutter run \
  --flavor impellerOff \
  --dart-define=FLUTTER_VERSION=3.44.1 \
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with reproduction steps"
```

---

## Self-Review Checklist

After writing each task, verify:

- [ ] All spec requirements covered (WebView, overlay, two flavors, README)
- [ ] No TBD/TODO/placeholder steps
- [ ] `InfoOverlay` widget name consistent across Task 3 and Task 4
- [ ] `_impellerEnabled` and `_flutterVersion` dart-define names consistent across Task 4 and Task 5 README
- [ ] Both APK build commands in Task 5 match README commands in Task 6
