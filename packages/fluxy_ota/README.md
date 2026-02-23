# fluxy_ota

OTA (Over-The-Air) update system and SDUI renderer for the Fluxy framework, providing seamless app updates and server-driven UI capabilities.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_ota: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the OTA plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including OTA
  
  runApp(MyApp());
}
```

### Basic OTA Update Management

```dart
import 'package:fluxy/fluxy.dart';

class OTAService {
  // Initialize OTA system
  Future<void> initializeOTA() async {
    try {
      await Fx.ota.initialize();
      Fx.toast.success('OTA system initialized');
    } catch (e) {
      Fx.toast.error('OTA initialization failed: $e');
    }
  }
  
  // Check for updates
  Future<void> checkForUpdates() async {
    try {
      final updateInfo = await Fx.ota.checkForUpdates();
      if (updateInfo.hasUpdate) {
        Fx.toast.success('Update available: ${updateInfo.version}');
        await _showUpdateDialog(updateInfo);
      } else {
        Fx.toast.info('App is up to date');
      }
    } catch (e) {
      Fx.toast.error('Failed to check for updates: $e');
    }
  }
  
  // Show update dialog
  Future<void> _showUpdateDialog(UpdateInfo updateInfo) async {
    final shouldUpdate = await Fx.dialog.confirm(
      'Update Available',
      'Version ${updateInfo.version} is available. Would you like to update now?',
      confirmText: 'Update',
      cancelText: 'Later',
    );
    
    if (shouldUpdate) {
      await downloadAndInstallUpdate(updateInfo);
    }
  }
  
  // Download and install update
  Future<void> downloadAndInstallUpdate(UpdateInfo updateInfo) async {
    try {
      Fx.toast.info('Downloading update...');
      
      // Listen to download progress
      Fx.ota.downloadProgress.listen((progress) {
        Fx.toast.info('Download progress: ${progress.percentage}%');
      });
      
      await Fx.ota.downloadUpdate(updateInfo);
      Fx.toast.success('Update downloaded successfully');
      
      // Install update
      await Fx.ota.installUpdate(updateInfo);
      Fx.toast.success('Update installed successfully');
    } catch (e) {
      Fx.toast.error('Update installation failed: $e');
    }
  }
}
```

### SDUI (Server-Driven UI) Rendering

```dart
class SDUIService {
  // Render SDUI from server
  Future<Widget> renderSDUI(String screenId) async {
    try {
      final sduiConfig = await Fx.ota.fetchSDUI(screenId);
      return Fx.ota.renderSDUI(sduiConfig);
    } catch (e) {
      Fx.toast.error('Failed to render SDUI: $e');
      return Fx.text('Error loading content');
    }
  }
  
  // Cache SDUI configuration
  Future<void> cacheSDUI(String screenId, SDUIConfig config) async {
    try {
      await Fx.ota.cacheSDUI(screenId, config);
      Fx.toast.success('SDUI cached successfully');
    } catch (e) {
      Fx.toast.error('Failed to cache SDUI: $e');
    }
  }
  
  // Get cached SDUI
  Future<SDUIConfig?> getCachedSDUI(String screenId) async {
    try {
      return await Fx.ota.getCachedSDUI(screenId);
    } catch (e) {
      Fx.toast.error('Failed to get cached SDUI: $e');
      return null;
    }
  }
}
```

### Advanced OTA Features

```dart
class AdvancedOTAService {
  // Schedule automatic updates
  Future<void> scheduleAutoUpdate() async {
    try {
      await Fx.ota.scheduleAutoUpdate(
        interval: Duration(hours: 24),
        requireWifi: true,
        requireCharging: true,
      );
      Fx.toast.success('Auto-update scheduled');
    } catch (e) {
      Fx.toast.error('Failed to schedule auto-update: $e');
    }
  }
  
  // Enable/disable automatic updates
  Future<void> setAutoUpdateEnabled(bool enabled) async {
    try {
      await Fx.ota.setAutoUpdateEnabled(enabled);
      Fx.toast.success('Auto-update ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      Fx.toast.error('Failed to set auto-update: $e');
    }
  }
  
  // Get update history
  Future<List<UpdateRecord>> getUpdateHistory() async {
    try {
      return await Fx.ota.getUpdateHistory();
    } catch (e) {
      Fx.toast.error('Failed to get update history: $e');
      return [];
    }
  }
  
  // Rollback to previous version
  Future<void> rollbackUpdate() async {
    try {
      await Fx.ota.rollback();
      Fx.toast.success('Rollback completed');
    } catch (e) {
      Fx.toast.error('Rollback failed: $e');
    }
  }
}
```

### SDUI Configuration Management

```dart
class SDUIConfigService {
  // Create SDUI configuration
  SDUIConfig createHomeScreenConfig() {
    return SDUIConfig(
      screenId: 'home',
      version: '1.0.0',
      components: [
        SDUIComponent(
          type: 'container',
          props: {
            'padding': '16',
            'background': '#ffffff',
          },
          children: [
            SDUIComponent(
              type: 'text',
              props: {
                'text': 'Welcome to Fluxy',
                'style': 'headline',
              },
            ),
            SDUIComponent(
              type: 'button',
              props: {
                'text': 'Get Started',
                'onPress': 'navigate_to_features',
              },
            ),
          ],
        ),
      ],
    );
  }
  
  // Render dynamic SDUI
  Widget renderDynamicSDUI(SDUiConfig config) {
    return Fx.ota.renderSDUI(config);
  }
  
  // Update SDUI remotely
  Future<void> updateSDUIRemotely(String screenId) async {
    try {
      final newConfig = await Fx.ota.fetchSDUI(screenId);
      await Fx.ota.cacheSDUI(screenId, newConfig);
      Fx.toast.success('SDUI updated remotely');
    } catch (e) {
      Fx.toast.error('Failed to update SDUI: $e');
    }
  }
}
```

### OTA Update Settings Screen

```dart
import 'package:fluxy/fluxy.dart';

class OTASettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTA Settings')),
      body: Fx.col([
        Fx.card([
          Fx.col([
            Fx.text('Automatic Updates').font.lg().bold(),
            Fx.text('Enable automatic app updates').font.sm().muted(),
            Fx.switcher(
              flux(false).listen((value) async {
                await AdvancedOTAService().setAutoUpdateEnabled(value);
              }),
              'Enable Automatic Updates',
            ).gap(2),
          ]).gap(2),
        ]).gap(2),
        
        Fx.card([
          Fx.col([
            Fx.text('Update Schedule').font.lg().bold(),
            Fx.button('Schedule Auto-Update')
              .onTap(() async {
                await AdvancedOTAService().scheduleAutoUpdate();
              }),
          ]).gap(2),
        ]).gap(2),
        
        Fx.card([
          Fx.col([
            Fx.text('Update Management').font.lg().bold(),
            Fx.button('Check for Updates')
              .onTap(() async {
                await OTAService().checkForUpdates();
              }),
            Fx.button('View Update History')
              .onTap(() async {
                final history = await AdvancedOTAService().getUpdateHistory();
                // Show update history dialog
              }),
            Fx.button('Rollback Update')
              .onTap(() async {
                await AdvancedOTAService().rollbackUpdate();
              }),
          ]).gap(2),
        ]).gap(2),
      ]).gap(2).p(2),
    );
  }
}
```

## Features

- **OTA Updates**: Seamless over-the-air app updates
- **SDUI Rendering**: Server-driven UI rendering capabilities
- **Update Management**: Complete update lifecycle management
- **Automatic Updates**: Configurable automatic update scheduling
- **Update History**: Track and manage update history
- **Rollback Support**: Rollback to previous app versions
- **Progress Tracking**: Real-time download and installation progress
- **Caching**: Local caching of SDUI configurations
- **Cross-Platform**: Works on both iOS and Android

## API Reference

### Methods

- `initialize()` - Initialize OTA system
- `checkForUpdates()` - Check for available updates
- `downloadUpdate(UpdateInfo)` - Download update package
- `installUpdate(UpdateInfo)` - Install downloaded update
- `fetchSDUI(String screenId)` - Fetch SDUI configuration from server
- `renderSDUI(SDUIConfig)` - Render SDUI configuration
- `cacheSDUI(String screenId, SDUIConfig)` - Cache SDUI locally
- `getCachedSDUI(String screenId)` - Get cached SDUI configuration
- `scheduleAutoUpdate()` - Schedule automatic updates
- `setAutoUpdateEnabled(bool)` - Enable/disable automatic updates
- `getUpdateHistory()` - Get update history
- `rollback()` - Rollback to previous version

### Properties

- `downloadProgress` - Stream of download progress updates

### SDUI Components

- **Container**: Layout container with styling
- **Text**: Text display with styling options
- **Button**: Interactive button with actions
- **Image**: Image display with loading states
- **List**: Scrollable list of items
- **Form**: Input form with validation

## Error Handling

The OTA plugin provides comprehensive error handling:

```dart
try {
  await Fx.ota.checkForUpdates();
} on OTAException catch (e) {
  // Handle specific OTA errors
  switch (e.type) {
    case OTAErrorType.networkError:
      Fx.toast.error('Network error while checking updates');
      break;
    case OTAErrorType.downloadFailed:
      Fx.toast.error('Update download failed');
      break;
    case OTAErrorType.installationFailed:
      Fx.toast.error('Update installation failed');
      break;
    case OTAErrorType.insufficientStorage:
      Fx.toast.error('Insufficient storage for update');
      break;
    default:
      Fx.toast.error('OTA error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected OTA error: $e');
}
```

## Security Considerations

- All updates are verified with digital signatures
- SDUI configurations are validated before rendering
- Update packages are encrypted during transmission
- Rollback capability for security issues
- No unauthorized code execution

## Platform Support

- **iOS**: Native iOS update integration
- **Android**: Android update package support
- **Cross-Platform**: Unified API across platforms

## License

This package is licensed under the MIT License. See the LICENSE file for details.
