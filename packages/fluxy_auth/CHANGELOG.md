## [1.1.0] - 2026-02-28

### Changed
- Synchronized with Fluxy 1.1.0 industrial stability release.
- Internal optimization for reactive signal management.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-02-23

### Added
- Initial release of fluxy_auth authentication plugin
- Email and password authentication functionality
- Social authentication support (Google, Apple)
- Session management with automatic token refresh
- Password reset and change functionality
- Reactive authentication state management
- Comprehensive error handling with specific error types
- Secure token storage using Flutter Secure Storage
- User-friendly toast notifications for auth events
- Integration with Fluxy framework DSL

### Security Features
- Secure token storage and management
- Automatic token refresh mechanism
- Proper session invalidation on sign out
- HTTPS encrypted network communications
- No local password storage

### Documentation
- Complete API reference documentation
- Usage examples for all authentication methods
- Error handling guidelines
- Security considerations documentation

### Integration
- Seamless integration with Fluxy framework
- Support for Fluxy.autoRegister() automatic plugin registration
- Compatible with Fluxy reactive state management
- Works with Fluxy toast notification system

