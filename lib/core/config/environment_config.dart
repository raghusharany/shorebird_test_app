import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'env_constants.dart';

/// Enum representing different application environments
enum Environment { dev, staging, production }

/// Configuration class for managing environment-specific settings
class EnvironmentConfig {
  EnvironmentConfig._();

  /// Map of environment to corresponding .env file names
  static const Map<Environment, String> environmentFilesName = {
    Environment.dev: 'dev.env',
    Environment.staging: 'staging.env',
    Environment.production: 'production.env',
  };

  /// Current environment of the application
  static late Environment currentEnvironment;

  /// Get the .env file name for the specified environment
  static String getEnvFileName(Environment environment) {
    return environmentFilesName[environment] ?? 'dev.env';
  }

  /// Get the current environment name as a string
  static String get environment =>
      dotenv.env[EnvConstants.environment]?.toUpperCase() ?? 'DEV';

  /// Check if the current environment is development
  static bool get isDevelopment => environment == 'DEV';

  /// Check if the current environment is staging
  static bool get isStaging => environment == 'STAGING';

  /// Check if the current environment is production
  static bool get isProduction => environment == 'PRODUCTION';

  /// Initialize the environment configuration
  static Future<void> initialize(Environment environment) async {
    currentEnvironment = environment;
    await dotenv.load(fileName: getEnvFileName(environment));
  }

  /// Determine environment from package name
  static Environment determineEnvironmentFromPackageName(String packageName) {
    final lowerPackageName = packageName.toLowerCase();
    if (lowerPackageName.contains('dev')) {
      return Environment.dev;
    } else if (lowerPackageName.contains('staging')) {
      return Environment.staging;
    } else if (lowerPackageName.contains('prod') ||
        lowerPackageName.contains('production')) {
      return Environment.production;
    } else {
      return Environment.dev; // Default fallback
    }
  }

  /// Get environment value from dart-define or determine from package name
  static Future<Environment> determineEnvironment() async {
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
            determineEnvironmentFromPackageName(packageName);
        environmentValue = determinedEnvironment.toString().split('.').last;
      } else {
        // If package name is not available, try to determine from application ID
        try {
          final packageInfo = await PackageInfo.fromPlatform();
          final determinedEnvironment =
              determineEnvironmentFromPackageName(packageInfo.packageName);
          environmentValue = determinedEnvironment.toString().split('.').last;
        } catch (e) {
          environmentValue = 'dev'; // Default fallback
        }
      }
    }

    // Convert string to Environment enum
    final environment = Environment.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          environmentValue.toLowerCase(),
      orElse: () => Environment.dev,
    );

    return environment;
  }
}
