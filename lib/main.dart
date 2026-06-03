import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'overlay_info.dart';

const String _flutterVersion =
    String.fromEnvironment('APP_FLUTTER_VERSION', defaultValue: 'unknown');
const bool _impellerEnabled =
    bool.fromEnvironment('IMPELLER_ENABLED', defaultValue: true);
const String _gpu = String.fromEnvironment('GPU', defaultValue: 'unknown');

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
  String _androidVersion = 'loading...';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com'));
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = DeviceInfoPlugin();
    String model;
    String androidVersion;
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      model = '${android.manufacturer} ${android.model}';
      androidVersion =
          '${android.version.release} (API ${android.version.sdkInt})';
    } else {
      model = 'non-android';
      androidVersion = 'n/a';
    }
    setState(() {
      _deviceModel = model;
      _androidVersion = androidVersion;
    });
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
            androidVersion: _androidVersion,
            gpu: _gpu,
          ),
        ],
      ),
    );
  }
}
