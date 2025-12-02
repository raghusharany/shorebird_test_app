import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

void main() {
  runApp(const ShorebirdTestApp());
}

class ShorebirdTestApp extends StatelessWidget {
  const ShorebirdTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shorebird Patch Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const PatchTestPage(),
    );
  }
}

class PatchTestPage extends StatefulWidget {
  const PatchTestPage({super.key});

  @override
  State<PatchTestPage> createState() => _PatchTestPageState();
}

class _PatchTestPageState extends State<PatchTestPage> {
  final _updater = ShorebirdUpdater();
  late final bool _isUpdaterAvailable;

  var _currentTrack = UpdateTrack.stable;
  var _isCheckingForUpdates = false;
  Patch? _currentPatch;
  UpdateStatus? _lastUpdateStatus;

  // UI elements that will change with patches
  MaterialColor _themeColor = Colors.purple;
  int _clickCount = 0;
  final String _welcomeMessage =
      '🎨 Patch Update Applied! UI Changed via Shorebird Patch! ✨';
  // App version - dynamically loaded from package info
  final String _appVersion = '1.0.0+2';

  @override
  void initState() {
    super.initState();
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
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingForUpdates) return;

    try {
      setState(() => _isCheckingForUpdates = true);

      // Check if there's an update available
      final status = await _updater.checkForUpdate(track: _currentTrack);

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
          content: Text(
            'Update available for the ${_currentTrack.name} track.',
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
          content: Text(
            'No update available on the ${_currentTrack.name} track.',
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
      // Perform the update (download the latest patch on current track)
      await _updater.update(track: _currentTrack);

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
          title: const Text('🔄 Shorebird Patch Tester'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      _buildStatusRow(
                        'Current Patch',
                        _currentPatch != null
                            ? 'Patch #${_currentPatch!.number}'
                            : 'Base Release (No patch)',
                      ),
                      const SizedBox(height: 8),
                      _buildStatusRow(
                        'Update Track',
                        _currentTrack.name.toUpperCase(),
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

              // Track Selection
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update Track',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<UpdateTrack>(
                        segments: const [
                          ButtonSegment(
                            label: Text('Stable'),
                            value: UpdateTrack.stable,
                          ),
                          ButtonSegment(
                            label: Text('Beta'),
                            icon: Icon(Icons.science),
                            value: UpdateTrack.beta,
                          ),
                          ButtonSegment(
                            label: Text('Staging'),
                            icon: Icon(Icons.construction),
                            value: UpdateTrack.staging,
                          ),
                        ],
                        selected: {_currentTrack},
                        onSelectionChanged: (tracks) {
                          setState(() => _currentTrack = tracks.single);
                        },
                      ),
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
                        'FIRST RELEASE: Build release: shorebird release android/ios',
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
                        'Create a patch: shorebird patch android/ios --track stable/beta/staging',
                      ),
                      _buildInstructionStep(
                        '5',
                        'In the app, select track and tap "Check for Updates"',
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
