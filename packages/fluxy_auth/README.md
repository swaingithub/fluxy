# fluxy_auth

Authentication plugin for the Fluxy framework, providing secure user authentication and session management.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_auth: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the auth plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including auth
  
  runApp(MyApp());
}
```

### Basic Authentication

```dart
import 'package:fluxy/fluxy.dart';

class AuthService {
  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      await Fx.auth.signIn(email, password);
      return true;
    } catch (e) {
      Fx.toast.error('Sign in failed: $e');
      return false;
    }
  }
  
  // Sign out current user
  Future<void> signOut() async {
    await Fx.auth.signOut();
    Fx.toast.success('Signed out successfully');
  }
  
  // Check if user is authenticated
  bool get isAuthenticated => Fx.auth.currentUser != null;
  
  // Get current user
  User? get currentUser => Fx.auth.currentUser;
}
```

### Social Authentication

```dart
class SocialAuthService {
  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await Fx.auth.signInWithGoogle();
      return true;
    } catch (e) {
      Fx.toast.error('Google sign in failed: $e');
      return false;
    }
  }
  
  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      await Fx.auth.signInWithApple();
      return true;
    } catch (e) {
      Fx.toast.error('Apple sign in failed: $e');
      return false;
    }
  }
}
```

### Session Management

```dart
class SessionManager {
  // Get authentication state stream
  Stream<bool> get authState => Fx.auth.authStateChanges;
  
  // Listen to auth state changes
  void listenToAuthChanges() {
    Fx.auth.authStateChanges.listen((isAuthenticated) {
      if (isAuthenticated) {
        // User signed in
        Fx.toast.success('Welcome back!');
      } else {
        // User signed out
        Fx.toast.info('You have been signed out');
      }
    });
  }
  
  // Refresh user token
  Future<void> refreshToken() async {
    try {
      await Fx.auth.refreshToken();
    } catch (e) {
      Fx.toast.error('Token refresh failed: $e');
    }
  }
}
```

### Password Management

```dart
class PasswordService {
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await Fx.auth.resetPassword(email);
      Fx.toast.success('Password reset email sent');
      return true;
    } catch (e) {
      Fx.toast.error('Password reset failed: $e');
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await Fx.auth.changePassword(oldPassword, newPassword);
      Fx.toast.success('Password changed successfully');
      return true;
    } catch (e) {
      Fx.toast.error('Password change failed: $e');
      return false;
    }
  }
}
```

## Features

- **Email/Password Authentication**: Secure sign in with email and password
- **Social Authentication**: Support for Google, Apple, and other social providers
- **Session Management**: Automatic token refresh and session persistence
- **Password Management**: Reset and change password functionality
- **State Management**: Reactive authentication state with stream updates
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Security**: Built-in security best practices and token management

## API Reference

### Methods

- `signIn(String email, String password)` - Sign in with email and password
- `signInWithGoogle()` - Sign in with Google account
- `signInWithApple()` - Sign in with Apple account
- `signOut()` - Sign out current user
- `resetPassword(String email)` - Send password reset email
- `changePassword(String oldPassword, String newPassword)` - Change user password
- `refreshToken()` - Refresh authentication token

### Properties

- `currentUser` - Get currently authenticated user
- `authStateChanges` - Stream of authentication state changes

## Error Handling

The auth plugin provides comprehensive error handling:

```dart
try {
  await Fx.auth.signIn(email, password);
} on AuthException catch (e) {
  // Handle specific auth errors
  switch (e.type) {
    case AuthErrorType.invalidEmail:
      Fx.toast.error('Invalid email address');
      break;
    case AuthErrorType.wrongPassword:
      Fx.toast.error('Incorrect password');
      break;
    case AuthErrorType.userNotFound:
      Fx.toast.error('User not found');
      break;
    default:
      Fx.toast.error('Authentication failed');
  }
} catch (e) {
  Fx.toast.error('Unexpected error: $e');
}
```

## Security Considerations

- All authentication tokens are securely stored using Flutter Secure Storage
- Tokens are automatically refreshed when needed
- Sessions are properly invalidated on sign out
- Passwords are never stored locally
- Network communications use HTTPS encryption

## License

This package is licensed under the MIT License. See the LICENSE file for details.
