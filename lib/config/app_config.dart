import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/config/env_constants.dart';
import '../core/config/environment_config.dart';

class AppConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;
  final String websocketUrl;
  final Color primaryColor;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.websocketUrl,
    required this.primaryColor,
  });

  /// Get configuration from .env file
  static AppConfig fromEnv() {
    final envString = dotenv.env[EnvConstants.environment] ?? 'dev';
    final environment = Environment.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() == envString.toLowerCase(),
      orElse: () => Environment.dev,
    );

    final primaryColorString = dotenv.env[EnvConstants.primaryColor] ?? 'blue';
    final primaryColor = _getColorFromString(primaryColorString);

    return AppConfig(
      environment: environment,
      appName: dotenv.env[EnvConstants.appName] ?? 'Shorebird Test App',
      apiBaseUrl: dotenv.env[EnvConstants.apiBaseUrl] ?? '',
      websocketUrl: dotenv.env[EnvConstants.websocketUrl] ?? '',
      primaryColor: primaryColor,
    );
  }

  static Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.purple;
    }
  }

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
