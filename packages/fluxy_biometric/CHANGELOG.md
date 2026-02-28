## [1.1.0] - 2026-02-28

### Changed
- Synchronized with Fluxy 1.1.0 industrial stability release.
- Internal optimization for reactive signal management.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-02-23

### Added
- Initial release of fluxy_biometric authentication plugin
- Fingerprint authentication support
- Face recognition authentication support
- Biometric availability checking
- Available biometric type detection
- Configurable authentication options
- Comprehensive error handling with specific error types
- Cross-platform biometric support
- Biometric authentication flow management
- Security level configuration options
- Integration with Fluxy storage for preferences

### Authentication Features
- Single biometric authentication
- Custom authentication reasons
- Configurable authentication options
- Sticky authentication support
- Biometric-only authentication mode
- Sensitive transaction marking
- Authentication process control

### Security Features
- Platform-specific secure authentication
- No biometric data storage or transmission
- Secure authentication result handling
- Fallback to device PIN support
- Sensitive transaction protection

### Platform Integration
- iOS biometric integration with native support
- Android biometric API support
- Face ID support on iOS
- Fingerprint support on Android
- Proper permission handling across platforms

### Documentation
- Complete API reference documentation
- Usage examples for all authentication methods
- Error handling guidelines
- Platform configuration instructions
- Security considerations documentation

### Integration
- Seamless integration with Fluxy framework
- Support for Fluxy.autoRegister() automatic plugin registration
- Compatible with Fluxy reactive state management
- Works with Fluxy storage system
- Integration with Fluxy toast notification system

