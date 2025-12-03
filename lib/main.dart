import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/config/environment_config.dart';
import 'core/config/env_constants.dart';
import 'config/app_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get environment from dart-define or fallback to flavor
  var environmentValue = const String.fromEnvironment(
    EnvConstants.environment,
    defaultValue: '',
  );

  // If environment is not set via dart-define, try to determine from package name
  if (environmentValue.isEmpty) {
    // Try to determine environment from package name
    const packageName = String.fromEnvironment(
      'PACKAGE_NAME',
      defaultValue: '',
    );

    if (packageName.isNotEmpty) {
      final determinedEnvironment =
          EnvironmentConfig.determineEnvironmentFromPackageName(packageName);
      environmentValue = determinedEnvironment.toString().split('.').last;
    } else {
      // If package name is not available, try to determine from application ID
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final determinedEnvironment =
            EnvironmentConfig.determineEnvironmentFromPackageName(
          packageInfo.packageName,
        );
        environmentValue = determinedEnvironment.toString().split('.').last;
      } catch (e) {
        environmentValue = 'dev'; // Default fallback
      }
    }
  }

  final environment = Environment.values.firstWhere(
    (e) =>
        e.toString().split('.').last.toLowerCase() ==
        environmentValue.toLowerCase(),
    orElse: () => Environment.dev,
  );

  // Initialize environment configuration
  await EnvironmentConfig.initialize(environment);

  // Get app configuration from .env file
  final appConfig = AppConfig.fromEnv();

  runApp(ShorebirdTestApp(config: appConfig));
}
