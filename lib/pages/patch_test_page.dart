import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';

class PatchTestPage extends StatefulWidget {
  final AppConfig config;

  const PatchTestPage({super.key, required this.config});

  @override
  State<PatchTestPage> createState() => _PatchTestPageState();
}

class _PatchTestPageState extends State<PatchTestPage> {
  final _updater = ShorebirdUpdater();
  late final bool _isUpdaterAvailable;

  var _isCheckingForUpdates = false;
  Patch? _currentPatch;
  UpdateStatus? _lastUpdateStatus;

  // UI elements that will change with patches
  MaterialColor _themeColor = Colors.purple;
  int _clickCount = 0;
  final String _welcomeMessage =
      '🎨 Patch Update Applied! UI Changed via Shorebird Patch! ✨';

  // App version - dynamically loaded from package info
  String _appVersion = 'Loading...';
  String _buildNumber = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();

    // Check whether Shorebird is available
    setState(() => _isUpdaterAvailable = _updater.isAvailable);

    // Read the current patch (if there is one)
    _updater.readCurrentPatch().then((currentPatch) {
      if (mounted) {
        setState(() => _currentPatch = currentPatch);
      }
    }).catchError((Object error) {
      debugPrint('Error reading current patch: $error');
    });

    // Set initial theme color based on environment
    _themeColor = _getMaterialColor(widget.config.primaryColor);
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('Error loading package info: $e');
      if (mounted) {
        setState(() {
          _appVersion = 'Unknown';
          _buildNumber = 'Unknown';
        });
      }
    }
  }

  MaterialColor _getMaterialColor(Color color) {
    if (color == Colors.blue) return Colors.blue;
    if (color == Colors.orange) return Colors.orange;
    if (color == Colors.purple) return Colors.purple;
    return Colors.purple; // default
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;

    try {
      setState(() => _isCheckingForUpdates = true);

      // Check if there's an update available
      final status = await _updater.checkForUpdate();

      if (!mounted) return;

      setState(() => _lastUpdateStatus = status);

      // Handle different update statuses
      switch (status) {
        case UpdateStatus.upToDate:
          _showNoUpdateAvailableBanner();
        case UpdateStatus.outdated:
          _showUpdateAvailableBanner();
        case UpdateStatus.restartRequired:
          _showRestartBanner();
        case UpdateStatus.unavailable:
          // Do nothing, there is already a warning displayed
          break;
      }
    } on Exception catch (error) {
      debugPrint('Error checking for update: $error');
      if (mounted) {
        _showErrorBanner('Error checking for update: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingForUpdates = false);
      }
    }
  }

  void _showDownloadingBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        const MaterialBanner(
          content: Text('Downloading update...'),
          actions: [
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
  }

  void _showUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text(
            'Update available for your environment.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                await _downloadUpdate();
              },
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Later'),
            ),
          ],
        ),
      );
  }

  void _showNoUpdateAvailableBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text(
            'No update available for your environment.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  void _showRestartBanner() {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text(
            'A new patch is ready! Please restart your app to see the changes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  void _showErrorBanner(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
  }

  Future<void> _downloadUpdate() async {
    _showDownloadingBanner();

    try {
      // Perform the update (download the latest patch for current environment)
      await _updater.update();

      if (!mounted) return;

      // Refresh patch info after update
      final currentPatch = await _updater.readCurrentPatch();
      if (mounted) {
        setState(() => _currentPatch = currentPatch);
      }

      // Show a banner to inform the user that the update is ready
      _showRestartBanner();
    } on UpdateException catch (error) {
      // If an error occurs, show a banner with the error message
      _showErrorBanner('Error downloading update: ${error.message}');
    }
  }

  void _incrementCounter() {
    setState(() {
      _clickCount++;
    });
  }

  void _changeTheme() {
    setState(() {
      // Cycle through different colors to show patch changes
      final colors = <MaterialColor>[
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
      ];
      final currentIndex = colors.indexOf(_themeColor);
      _themeColor = colors[(currentIndex + 1) % colors.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _themeColor),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('🔄 ${widget.config.appName}'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Environment Badge
              Card(
                color: widget.config.primaryColor.withAlpha(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: widget.config.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Environment: ${widget.config.environment.name.toUpperCase()}',
                        style: TextStyle(
                          color: widget.config.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Shorebird Availability Warning
              if (!_isUpdaterAvailable)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Shorebird is not available. Make sure the app was built via "shorebird release" and is running in release mode.',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isUpdaterAvailable) const SizedBox(height: 16),

              // Patch Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _currentPatch != null
                                ? Icons.check_circle
                                : Icons.info,
                            color: _currentPatch != null
                                ? Colors.green
                                : Colors.blue,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Patch Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatusRow('App Version', _appVersion),
                      const SizedBox(height: 8),
                      _buildStatusRow('Build Number', _buildNumber),
                      const SizedBox(height: 8),
                      _buildStatusRow(
                        'Current Patch',
                        _currentPatch != null
                            ? 'Patch #${_currentPatch!.number}'
                            : 'Base Release (No patch)',
                      ),
                      if (_lastUpdateStatus != null) ...[
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          'Last Check Status',
                          _lastUpdateStatus.toString().split('.').last,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Check for Updates Button
              ElevatedButton.icon(
                onPressed: _isCheckingForUpdates ? null : _checkForUpdate,
                icon: _isCheckingForUpdates
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isCheckingForUpdates
                    ? 'Checking...'
                    : 'Check for Updates'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Interactive Test Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Test Interactions - PATCHED VERSION! 🚀',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _welcomeMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '✅ This UI was updated via Shorebird patch! Notice the purple theme and new messages!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _incrementCounter,
                              icon: const Icon(Icons.star, size: 24),
                              label: Text('⭐ Tap Me: $_clickCount'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _changeTheme,
                              icon: const Icon(Icons.color_lens, size: 24),
                              label: const Text('New Theme'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: theme.colorScheme.tertiary,
                                foregroundColor: theme.colorScheme.onTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions Card
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '📱 Patch Update Instructions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        '1',
                        'FIRST RELEASE: Build release: shorebird release android/ios --flavor dev/staging/production',
                      ),
                      _buildInstructionStep(
                        '2',
                        'Install the release build on your device',
                      ),
                      _buildInstructionStep(
                        '3',
                        'Make UI changes (colors, text, layout) in the code',
                      ),
                      _buildInstructionStep(
                        '4',
                        'Create a patch: shorebird patch android/ios --flavor dev/staging/production --dart-define=ENVIRONMENT=dev/staging/production',
                      ),
                      _buildInstructionStep(
                        '5',
                        'In the app, tap "Check for Updates"',
                      ),
                      _buildInstructionStep(
                        '6',
                        'Download the update and restart the app to see changes',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isCheckingForUpdates ? null : _checkForUpdate,
          tooltip: 'Check for update',
          child: _isCheckingForUpdates
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
