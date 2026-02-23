# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-02-23

### Added
- Initial release of fluxy_storage unified storage plugin
- Secure storage support using Flutter Secure Storage
- Regular storage support using SharedPreferences
- Unified API for both storage types
- Batch storage operations for efficiency
- Complex object storage with JSON encoding
- Storage management utilities
- Cross-platform storage support
- Comprehensive error handling with specific error types
- Storage size calculation functionality
- Key existence checking
- Storage clearing capabilities

### Storage Features
- String storage and retrieval
- Number storage with automatic conversion
- Boolean storage with automatic conversion
- Complex object storage with JSON encoding
- Secure storage for sensitive data
- Regular storage for non-sensitive data

### Platform Integration
- iOS Keychain integration for secure storage
- iOS UserDefaults for regular storage
- Android EncryptedSharedPreferences for secure storage
- Android SharedPreferences for regular storage
- Web localStorage support for regular storage

### Performance Features
- Batch read/write operations
- Efficient storage management
- Storage size monitoring
- Key-based operations optimization

### Security Features
- Platform-specific secure storage mechanisms
- Automatic encryption on secure platforms
- Sensitive data protection
- Access control for secure storage

### Documentation
- Complete API reference documentation
- Usage examples for all storage operations
- Error handling guidelines
- Security considerations documentation
- Performance optimization notes

### Integration
- Seamless integration with Fluxy framework
- Support for Fluxy.autoRegister() automatic plugin registration
- Compatible with Fluxy reactive state management
- Works with Fluxy toast notification system
