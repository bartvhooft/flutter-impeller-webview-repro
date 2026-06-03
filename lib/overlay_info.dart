import 'package:flutter/material.dart';

class InfoOverlay extends StatelessWidget {
  const InfoOverlay({
    super.key,
    required this.flutterVersion,
    required this.impellerEnabled,
    required this.deviceModel,
    required this.androidVersion,
    required this.gpu,
  });

  final String flutterVersion;
  final bool impellerEnabled;
  final String deviceModel;
  final String androidVersion;
  final String gpu;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
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
                  color:
                      impellerEnabled ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
              Text('Device: $deviceModel'),
              Text('Android: $androidVersion'),
              Text('GPU: $gpu'),
            ],
          ),
        ),
      ),
    );
  }
}
