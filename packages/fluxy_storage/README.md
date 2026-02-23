# fluxy_storage

Unified storage plugin for the Fluxy framework, providing secure and convenient data storage solutions with support for both secure and non-secure storage options.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_storage: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the storage plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including storage
  
  runApp(MyApp());
}
```

### Basic Storage Operations

```dart
import 'package:fluxy/fluxy.dart';

class StorageService {
  // Store data in secure storage
  Future<void> storeSecureData(String key, String value) async {
    try {
      await Fx.storage.setSecure(key, value);
      Fx.toast.success('Data stored securely');
    } catch (e) {
      Fx.toast.error('Failed to store secure data: $e');
    }
  }
  
  // Store data in regular storage
  Future<void> storeData(String key, String value) async {
    try {
      await Fx.storage.set(key, value);
      Fx.toast.success('Data stored successfully');
    } catch (e) {
      Fx.toast.error('Failed to store data: $e');
    }
  }
  
  // Retrieve data from secure storage
  Future<String?> getSecureData(String key) async {
    try {
      final value = await Fx.storage.getSecure(key);
      if (value != null) {
        Fx.toast.success('Secure data retrieved');
      }
      return value;
    } catch (e) {
      Fx.toast.error('Failed to retrieve secure data: $e');
      return null;
    }
  }
  
  // Retrieve data from regular storage
  Future<String?> getData(String key) async {
    try {
      final value = await Fx.storage.get(key);
      if (value != null) {
        Fx.toast.success('Data retrieved');
      }
      return value;
    } catch (e) {
      Fx.toast.error('Failed to retrieve data: $e');
      return null;
    }
  }
  
  // Remove data from storage
  Future<void> removeData(String key, {bool secure = false}) async {
    try {
      if (secure) {
        await Fx.storage.removeSecure(key);
      } else {
        await Fx.storage.remove(key);
      }
      Fx.toast.success('Data removed successfully');
    } catch (e) {
      Fx.toast.error('Failed to remove data: $e');
    }
  }
}
```

### Advanced Storage Operations

```dart
class AdvancedStorageService {
  // Store complex objects
  Future<void> storeObject(String key, Map<String, dynamic> object) async {
    try {
      final jsonString = jsonEncode(object);
      await Fx.storage.set(key, jsonString);
      Fx.toast.success('Object stored successfully');
    } catch (e) {
      Fx.toast.error('Failed to store object: $e');
    }
  }
  
  // Retrieve complex objects
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = await Fx.storage.get(key);
      if (jsonString != null) {
        final object = jsonDecode(jsonString) as Map<String, dynamic>;
        Fx.toast.success('Object retrieved successfully');
        return object;
      }
      return null;
    } catch (e) {
      Fx.toast.error('Failed to retrieve object: $e');
      return null;
    }
  }
  
  // Store user preferences
  Future<void> storeUserPreferences(UserPreferences preferences) async {
    try {
      await Fx.storage.set('theme', preferences.theme);
      await Fx.storage.set('language', preferences.language);
      await Fx.storage.set('notifications', preferences.notifications.toString());
      Fx.toast.success('Preferences saved');
    } catch (e) {
      Fx.toast.error('Failed to save preferences: $e');
    }
  }
  
  // Retrieve user preferences
  Future<UserPreferences> getUserPreferences() async {
    try {
      final theme = await Fx.storage.get('theme') ?? 'light';
      final language = await Fx.storage.get('language') ?? 'en';
      final notifications = await Fx.storage.get('notifications') ?? 'true';
      
      return UserPreferences(
        theme: theme,
        language: language,
        notifications: notifications == 'true',
      );
    } catch (e) {
      Fx.toast.error('Failed to load preferences: $e');
      return UserPreferences(); // Return default preferences
    }
  }
}
```

### Storage Management

```dart
class StorageManagementService {
  // Clear all storage
  Future<void> clearAllStorage() async {
    try {
      await Fx.storage.clear();
      await Fx.storage.clearSecure();
      Fx.toast.success('All storage cleared');
    } catch (e) {
      Fx.toast.error('Failed to clear storage: $e');
    }
  }
  
  // Get all storage keys
  Future<List<String>> getAllKeys({bool secure = false}) async {
    try {
      final keys = await Fx.storage.getAllKeys(secure: secure);
      return keys;
    } catch (e) {
      Fx.toast.error('Failed to get storage keys: $e');
      return [];
    }
  }
  
  // Check if key exists
  Future<bool> containsKey(String key, {bool secure = false}) async {
    try {
      return await Fx.storage.containsKey(key, secure: secure);
    } catch (e) {
      Fx.toast.error('Failed to check key existence: $e');
      return false;
    }
  }
  
  // Get storage size
  Future<int> getStorageSize({bool secure = false}) async {
    try {
      final keys = await Fx.storage.getAllKeys(secure: secure);
      int totalSize = 0;
      
      for (final key in keys) {
        final value = await Fx.storage.get(key, secure: secure);
        totalSize += value?.length ?? 0;
      }
      
      return totalSize;
    } catch (e) {
      Fx.toast.error('Failed to calculate storage size: $e');
      return 0;
    }
  }
}
```

### Batch Operations

```dart
class BatchStorageService {
  // Store multiple key-value pairs
  Future<void> storeBatch(Map<String, String> data, {bool secure = false}) async {
    try {
      for (final entry in data.entries) {
        if (secure) {
          await Fx.storage.setSecure(entry.key, entry.value);
        } else {
          await Fx.storage.set(entry.key, entry.value);
        }
      }
      Fx.toast.success('Batch data stored successfully');
    } catch (e) {
      Fx.toast.error('Failed to store batch data: $e');
    }
  }
  
  // Retrieve multiple values
  Future<Map<String, String?>> getBatch(List<String> keys, {bool secure = false}) async {
    try {
      final results = <String, String?>{};
      
      for (final key in keys) {
        final value = await Fx.storage.get(key, secure: secure);
        results[key] = value;
      }
      
      return results;
    } catch (e) {
      Fx.toast.error('Failed to retrieve batch data: $e');
      return {};
    }
  }
  
  // Remove multiple keys
  Future<void> removeBatch(List<String> keys, {bool secure = false}) async {
    try {
      for (final key in keys) {
        if (secure) {
          await Fx.storage.removeSecure(key);
        } else {
          await Fx.storage.remove(key);
        }
      }
      Fx.toast.success('Batch data removed successfully');
    } catch (e) {
      Fx.toast.error('Failed to remove batch data: $e');
    }
  }
}
```

## Features

- **Unified API**: Single interface for both secure and non-secure storage
- **Secure Storage**: Built-in support for Flutter Secure Storage
- **Regular Storage**: Shared Preferences for non-sensitive data
- **Batch Operations**: Efficient batch read/write operations
- **Type Support**: Support for strings, numbers, booleans, and complex objects
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Storage Management**: Tools for managing storage size and content
- **Cross-Platform**: Works on both iOS and Android

## API Reference

### Methods

- `set(String key, String value)` - Store data in regular storage
- `setSecure(String key, String value)` - Store data in secure storage
- `get(String key)` - Retrieve data from regular storage
- `getSecure(String key)` - Retrieve data from secure storage
- `remove(String key)` - Remove data from regular storage
- `removeSecure(String key)` - Remove data from secure storage
- `clear()` - Clear all regular storage
- `clearSecure()` - Clear all secure storage
- `containsKey(String key, {bool secure})` - Check if key exists
- `getAllKeys({bool secure})` - Get all storage keys

### Storage Types

- **Regular Storage**: Non-sensitive data using SharedPreferences
- **Secure Storage**: Sensitive data using FlutterSecureStorage

### Data Types

- **Strings**: Direct string storage
- **Numbers**: Converted to strings and stored
- **Booleans**: Converted to strings and stored
- **Objects**: JSON encoded for storage

## Error Handling

The storage plugin provides comprehensive error handling:

```dart
try {
  await Fx.storage.set('key', 'value');
} on StorageException catch (e) {
  // Handle specific storage errors
  switch (e.type) {
    case StorageErrorType.accessDenied:
      Fx.toast.error('Storage access denied');
      break;
    case StorageErrorType.notFound:
      Fx.toast.error('Storage key not found');
      break;
    case StorageErrorType.invalidData:
      Fx.toast.error('Invalid data format');
      break;
    default:
      Fx.toast.error('Storage error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected storage error: $e');
}
```

## Security Considerations

- Secure storage uses platform-specific secure storage mechanisms
- Regular storage is not encrypted and should not contain sensitive data
- All secure storage operations are protected by platform security features
- Data is automatically encrypted on secure storage platforms
- No sensitive data is stored in regular storage by default

## Platform Support

- **iOS**: Uses Keychain for secure storage, UserDefaults for regular storage
- **Android**: Uses EncryptedSharedPreferences for secure storage, SharedPreferences for regular storage
- **Web**: Uses localStorage for regular storage, secure storage is limited

## Performance Considerations

- Batch operations are more efficient than individual operations
- Secure storage operations are slower than regular storage
- Large objects should be stored in regular storage when possible
- Consider storage size limits on mobile devices

## License

This package is licensed under the MIT License. See the LICENSE file for details.
