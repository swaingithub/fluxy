# Fluxy Framework Example

This comprehensive example demonstrates the core capabilities of the Fluxy framework, including reactive state management, platform integration, and unified hardware access.

## Features Demonstrated

### 🔄 Reactive State Management
- **Persistent State**: Counter and user data that survives app restarts
- **Reactive UI**: Automatic UI updates when state changes
- **Flux Signals**: High-performance reactive signals with zero-config persistence

### 🔐 Authentication & Security
- **Biometric Authentication**: Fingerprint/face ID integration
- **Session Management**: Secure user authentication state
- **Permission Handling**: Camera, storage, and other device permissions

### 📱 Platform Integration
- **Connectivity Monitoring**: Real-time network status updates
- **Platform Information**: Device and OS version detection
- **Hardware Access**: Unified API for camera, biometrics, and more

### 💾 Data Persistence
- **Secure Storage**: Encrypted data storage for sensitive information
- **State Hydration**: Automatic state restoration on app startup
- **Vault Integration**: Built-in encrypted storage system

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.10.0)
- Android/iOS development environment

### Installation

1. Clone the fluxy repository
2. Navigate to the example directory:
   ```bash
   cd fluxy/example
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the example:
   ```bash
   flutter run
   ```

## Example Structure

```
example/
├── lib/
│   └── main.dart          # Main example application
├── pubspec.yaml           # Dependencies and configuration
└── README.md             # This file
```

## Key Concepts Demonstrated

### 1. Fluxy Initialization
```dart
await Fluxy.init();
runApp(FluxyExampleApp());
```

### 2. Reactive State with Persistence
```dart
final counter = flux(0, key: 'counter', persist: true);
final userName = flux('', key: 'user_name', persist: true);
```

### 3. Reactive UI Building
```dart
Fx(() => Fx.text('Counter: ${counter.value}')
    .font(size: 24, weight: FontWeight.bold)
    .color(Colors.blue.shade600))
    .build(),
```

### 4. Platform Hardware Access
```dart
// Biometric authentication
final isAuthenticated = await Fx.biometric.authenticate();

// Permission checking
final cameraPermission = await Fx.permissions.checkPermission(Permission.camera);

// Connectivity monitoring
Fx.connectivity.onConnectivityChanged.listen((status) {
  isConnected.value = status != ConnectivityStatus.none;
});
```

### 5. Fluxy DSL Styling
```dart
Fx.button('Login')
    .color(Colors.green)
    .textColor(Colors.white)
    .onPressed(_handleLogin)
    .build(),
```

## Testing the Features

### State Management
1. Use the increment/decrement buttons to see reactive state updates
2. Close and reopen the app to see state persistence
3. Enter text in the name field to see persistent storage

### Authentication
1. Click "Login" to simulate user authentication
2. Click "Logout" to clear authentication state
3. Try biometric authentication (if supported on device)

### Platform Features
1. Check device permissions for camera and storage
2. View platform information (OS version, device details)
3. Monitor connectivity status changes

## Architecture Highlights

This example showcases Fluxy's key architectural principles:

- **Managed Runtime**: Automatic plugin registration and lifecycle management
- **Stability Kernel**: Built-in error handling and layout protection
- **Unified API**: Consistent interface across all platform modules
- **Zero-Config Setup**: Minimal boilerplate for maximum productivity

## Troubleshooting

### Common Issues

1. **Biometric Authentication Not Working**
   - Ensure device supports biometric authentication
   - Check that biometrics are enabled in device settings

2. **Permission Errors**
   - Grant necessary permissions through system dialogs
   - Check app permissions in device settings

3. **State Not Persisting**
   - Ensure app has proper storage permissions
   - Check if secure storage is available on device

## Next Steps

After exploring this example, consider:

1. **Building Your Own App**: Use this as a template for your Fluxy application
2. **Exploring Modules**: Try other Fluxy modules like `fluxy_camera`, `fluxy_notifications`
3. **Advanced Features**: Implement routing, analytics, or OTA updates
4. **Custom Plugins**: Create your own Fluxy-compatible plugins

## Resources

- [Fluxy Documentation](https://fluxy-doc.vercel.app)
- [Main Repository](https://github.com/swaingithub/fluxy)
- [Migration Guide](../MIGRATION_GUIDE.md)
- [Changelog](../CHANGELOG.md)

## Contributing

Found an issue or want to improve the example? Please:

1. Open an issue on GitHub
2. Submit a pull request with your improvements
3. Follow the existing code style and patterns

---

## **v1.1.0 - The Full Engine Update**

**This example project has been updated for Fluxy v1.1.0!** 

- Added **Stability Kernel™** (Layout, State, and Async protection)
- Added **Managed Resource Manager** (`FluxyResourceManager`)
- Added **Real-Time Ecosystem** (`fluxy_websocket`, `fluxy_sync`, etc.)
- Added **X-Ray Observability** (Signal and Rebuild audits)

**[Read Migration Guide](../MIGRATION_GUIDE.md)**

---

**Built with ❤️ using the Fluxy Framework**
