## [1.1.0] - 2026-02-28

### Changed
- Synchronized with Fluxy 1.1.0 industrial stability release.
- Internal optimization for reactive signal management.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-02-23

### Added
- Initial release of fluxy_permissions permission management plugin
- Unified API for cross-platform permission handling
- Single permission request functionality
- Batch permission request capabilities
- Real-time permission status monitoring
- Permission status change stream
- Comprehensive error handling with specific error types
- Built-in user-friendly dialogs and notifications
- Direct app settings integration
- Support for all common device permissions
- Permission rationale display functionality
- Permanently denied permission handling

### Permission Types
- Camera permission support
- Microphone permission support
- Storage permission support
- Location permission support
- Photo library permission support
- Contacts permission support
- Notification permission support
- Phone permission support
- SMS permission support
- Calendar permission support

### Platform Support
- iOS permission handling with native integration
- Android permission API support
- Platform-specific permission dialogs
- Proper iOS Info.plist configuration support
- Android Manifest permission configuration

### Security Features
- Explicit user consent requirement
- Real-time permission status monitoring
- Sensitive permission additional confirmation
- No unauthorized background access
- Proper permanently denied permission handling

### Documentation
- Complete API reference documentation
- Usage examples for all permission operations
- Error handling guidelines
- Platform configuration instructions
- Security considerations documentation

### Integration
- Seamless integration with Fluxy framework
- Support for Fluxy.autoRegister() automatic plugin registration
- Compatible with Fluxy reactive state management
- Works with Fluxy toast notification system
- Integration with Fluxy dialog system

