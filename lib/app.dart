import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'pages/patch_test_page.dart';

class ShorebirdTestApp extends StatelessWidget {
  final AppConfig config;

  const ShorebirdTestApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: config.primaryColor),
        useMaterial3: true,
      ),
      home: PatchTestPage(config: config),
    );
  }
}
