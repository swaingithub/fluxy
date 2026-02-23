# fluxy_connectivity

Network connectivity plugin for the Fluxy framework, providing comprehensive network connectivity monitoring and management capabilities.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_connectivity: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the connectivity plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including connectivity
  
  runApp(MyApp());
}
```

### Basic Connectivity Monitoring

```dart
import 'package:fluxy/fluxy.dart';

class ConnectivityService {
  // Initialize connectivity monitoring
  Future<void> initializeConnectivity() async {
    try {
      await Fx.connectivity.initialize();
      Fx.toast.success('Connectivity monitoring initialized');
    } catch (e) {
      Fx.toast.error('Connectivity initialization failed: $e');
    }
  }
  
  // Check current connectivity status
  Future<bool> isConnected() async {
    try {
      final connected = await Fx.connectivity.isConnected;
      if (connected) {
        Fx.toast.success('Device is connected');
      } else {
        Fx.toast.warning('Device is offline');
      }
      return connected;
    } catch (e) {
      Fx.toast.error('Failed to check connectivity: $e');
      return false;
    }
  }
  
  // Get current connectivity type
  Future<ConnectivityType> getConnectivityType() async {
    try {
      final type = await Fx.connectivity.currentType;
      Fx.toast.success('Connectivity type: $type');
      return type;
    } catch (e) {
      Fx.toast.error('Failed to get connectivity type: $e');
      return ConnectivityType.none;
    }
  }
}
```

### Advanced Connectivity Features

```dart
class AdvancedConnectivityService {
  // Listen to connectivity changes
  void startConnectivityMonitoring() {
    Fx.connectivity.connectivityChanges.listen((ConnectivityResult result) {
      switch (result.type) {
        case ConnectivityType.wifi:
          Fx.toast.success('Connected to WiFi');
          break;
        case ConnectivityType.mobile:
          Fx.toast.info('Connected to mobile network');
          break;
        case ConnectivityType.ethernet:
          Fx.toast.success('Connected to Ethernet');
          break;
        case ConnectivityType.bluetooth:
          Fx.toast.info('Connected via Bluetooth');
          break;
        case ConnectivityType.none:
          Fx.toast.warning('No internet connection');
          break;
      }
    });
  }
  
  // Check if WiFi is connected
  Future<bool> isWifiConnected() async {
    try {
      final type = await Fx.connectivity.currentType;
      return type == ConnectivityType.wifi;
    } catch (e) {
      Fx.toast.error('Failed to check WiFi connection: $e');
      return false;
    }
  }
  
  // Check if mobile data is connected
  Future<bool> isMobileConnected() async {
    try {
      final type = await Fx.connectivity.currentType;
      return type == ConnectivityType.mobile;
    } catch (e) {
      Fx.toast.error('Failed to check mobile connection: $e');
      return false;
    }
  }
  
  // Get connection strength (if available)
  Future<int?> getConnectionStrength() async {
    try {
      return await Fx.connectivity.getConnectionStrength();
    } catch (e) {
      Fx.toast.error('Failed to get connection strength: $e');
      return null;
    }
  }
}
```

### Network Status Management

```dart
class NetworkStatusService {
  // Monitor network status with reactive state
  final networkStatus = flux(false);
  
  NetworkStatusService() {
    _initializeMonitoring();
  }
  
  void _initializeMonitoring() {
    // Start monitoring connectivity changes
    Fx.connectivity.connectivityChanges.listen((result) {
      final isConnected = result.type != ConnectivityType.none;
      networkStatus.value = isConnected;
      
      if (isConnected) {
        Fx.toast.success('Network connection restored');
      } else {
        Fx.toast.warning('Network connection lost');
      }
    });
  }
  
  // Check if online with retry mechanism
  Future<bool> checkOnlineWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      final isConnected = await Fx.connectivity.isConnected;
      if (isConnected) {
        return true;
      }
      
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return false;
  }
  
  // Wait for connection restoration
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<bool>();
    Timer? timeoutTimer;
    
    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    
    // Listen for connection restoration
    StreamSubscription? subscription;
    subscription = Fx.connectivity.connectivityChanges.listen((result) {
      if (result.type != ConnectivityType.none) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });
    
    // Check current connection
    final isConnected = await Fx.connectivity.isConnected;
    if (isConnected) {
      timeoutTimer?.cancel();
      subscription?.cancel();
      return true;
    }
    
    return completer.future;
  }
}
```

### Network-Aware Operations

```dart
class NetworkAwareService {
  // Execute operation only when online
  Future<T?> executeWhenOnline<T>(Future<T> Function() operation) async {
    try {
      final isConnected = await Fx.connectivity.isConnected;
      if (!isConnected) {
        Fx.toast.warning('No internet connection');
        return null;
      }
      
      return await operation();
    } catch (e) {
      Fx.toast.error('Operation failed: $e');
      return null;
    }
  }
  
  // Execute with automatic retry
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final isConnected = await Fx.connectivity.isConnected;
        if (!isConnected) {
          await Fx.connectivity.waitForConnection();
        }
        
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) {
          Fx.toast.error('Operation failed after $maxRetries retries: $e');
          rethrow;
        }
        
        Fx.toast.warning('Operation failed, retrying... (${i + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
      }
    }
    
    throw Exception('Operation failed after all retries');
  }
  
  // Sync data when online
  Future<void> syncWhenOnline() async {
    try {
      final isConnected = await Fx.connectivity.isConnected;
      if (!isConnected) {
        Fx.toast.info('Will sync when connection is available');
        return;
      }
      
      // Perform sync operation
      await _performSync();
      Fx.toast.success('Data synchronized successfully');
    } catch (e) {
      Fx.toast.error('Sync failed: $e');
    }
  }
  
  Future<void> _performSync() async {
    // Implement your sync logic here
    await Future.delayed(Duration(seconds: 2)); // Simulate sync
  }
}
```

## Features

- **Connectivity Monitoring**: Real-time network status monitoring
- **Connection Types**: Support for WiFi, mobile, Ethernet, and Bluetooth
- **Reactive State**: Reactive connectivity state management
- **Retry Mechanisms**: Automatic retry for network operations
- **Connection Restoration**: Wait for connection restoration
- **Network-Aware Operations**: Execute operations based on network status
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Cross-Platform**: Works on both iOS and Android devices

## API Reference

### Methods

- `initialize()` - Initialize connectivity monitoring
- `isConnected` - Check if device is connected to internet
- `currentType` - Get current connectivity type
- `getConnectionStrength()` - Get connection strength (if available)
- `waitForConnection({Duration timeout})` - Wait for connection restoration

### Properties

- `connectivityChanges` - Stream of connectivity changes
- `isConnected` - Current connection status

### Connectivity Types

- `ConnectivityType.wifi` - WiFi connection
- `ConnectivityType.mobile` - Mobile data connection
- `ConnectivityType.ethernet` - Ethernet connection
- `ConnectivityType.bluetooth` - Bluetooth connection
- `ConnectivityType.none` - No connection

## Error Handling

The connectivity plugin provides comprehensive error handling:

```dart
try {
  await Fx.connectivity.initialize();
} on ConnectivityException catch (e) {
  // Handle specific connectivity errors
  switch (e.type) {
    case ConnectivityErrorType.initializationFailed:
      Fx.toast.error('Connectivity monitoring initialization failed');
      break;
    case ConnectivityErrorType.permissionDenied:
      Fx.toast.error('Network access permission denied');
      break;
    case ConnectivityErrorType.serviceUnavailable:
      Fx.toast.error('Network connectivity service unavailable');
      break;
    default:
      Fx.toast.error('Connectivity error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected connectivity error: $e');
}
```

## Platform Configuration

### Android

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
```

### iOS

Add the following to your `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Performance Considerations

- Connectivity monitoring uses minimal system resources
- Stream-based updates are efficient and real-time
- Automatic cleanup of unused resources
- Battery-friendly monitoring approach

## License

This package is licensed under the MIT License. See the LICENSE file for details.
