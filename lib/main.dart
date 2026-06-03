import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'overlay_info.dart';

const String _flutterVersion =
    String.fromEnvironment('APP_FLUTTER_VERSION', defaultValue: 'unknown');
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
