# fluxy_test

Testing utilities and mocks for the Fluxy framework, providing comprehensive testing support for Fluxy applications and plugins.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_test: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized in your tests:

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Fluxy Tests', () {
    setUp(() async {
      await FluxyTest.initialize();
    });
    
    tearDown(() async {
      await FluxyTest.cleanup();
    });
  });
}
```

### Basic Testing Setup

```dart
import 'package:fluxy_test/fluxy_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    tearDown(() async {
      await fluxyTest.cleanup();
    });
    
    testWidgets('App should render correctly', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(MyApp());
      
      // Verify initial state
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

### Mock Services

```dart
import 'package:fluxy_test/fluxy_test.dart';

class MockAuthService {
  final FluxyMock mock = FluxyMock();
  
  void setupMockAuth() {
    mock.when(Fx.auth.signIn)
      .thenAnswer((_) async => true);
    
    mock.when(Fx.auth.signOut)
      .thenAnswer((_) async {});
    
    mock.when(Fx.auth.currentUser)
      .thenReturn(MockUser());
  }
  
  void setupMockAuthFailure() {
    mock.when(Fx.auth.signIn)
      .thenThrow(AuthException('Login failed'));
  }
}

class MockUser {
  String get email => 'test@example.com';
  String get name => 'Test User';
}
```

### Reactive State Testing

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Reactive State Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    test('Flux signal should update correctly', () async {
      // Create a test signal
      final counter = flux(0);
      
      // Test initial value
      expect(counter.value, equals(0));
      
      // Update value
      counter.value = 5;
      
      // Verify updated value
      expect(counter.value, equals(5));
    });
    
    test('Async flux should handle async operations', () async {
      // Create async flux
      final asyncFlux = asyncFlux(() async {
        await Future.delayed(Duration(milliseconds: 100));
        return 'Hello World';
      });
      
      // Wait for completion
      await tester.pump(Duration(milliseconds: 150));
      
      // Verify result
      expect(asyncFlux.value, equals('Hello World'));
    });
  });
}
```

### Widget Testing with Fluxy

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Widget Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    testWidgets('Counter widget should increment', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(CounterWidget());
      
      // Find the increment button
      final incrementButton = find.byKey(Key('increment_button'));
      
      // Verify initial count
      expect(find.text('Count: 0'), findsOneWidget);
      
      // Tap the button
      await tester.tap(incrementButton);
      await tester.pump();
      
      // Verify updated count
      expect(find.text('Count: 1'), findsOneWidget);
    });
    
    testWidgets('Form should validate correctly', (WidgetTester tester) async {
      // Build the form widget
      await tester.pumpWidget(LoginForm());
      
      // Find form fields
      final emailField = find.byKey(Key('email_field'));
      final passwordField = find.byKey(Key('password_field'));
      final submitButton = find.byKey(Key('submit_button'));
      
      // Submit empty form
      await tester.tap(submitButton);
      await tester.pump();
      
      // Verify error messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      
      // Fill valid data
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      // Submit form
      await tester.tap(submitButton);
      await tester.pump();
      
      // Verify successful submission
      expect(find.text('Login successful'), findsOneWidget);
    });
  });
}
```

### Plugin Testing

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Plugin Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    test('Auth plugin should initialize correctly', () async {
      // Mock auth plugin
      fluxyTest.mockPlugin('auth');
      
      // Test initialization
      await Fluxy.init();
      Fluxy.autoRegister();
      
      // Verify plugin is registered
      expect(Fluxy.isRegistered('auth'), isTrue);
    });
    
    test('Camera plugin should handle permissions', () async {
      // Mock camera plugin
      fluxyTest.mockPlugin('camera');
      
      // Mock permission granted
      fluxyTest.mockPermission(FluxyPermission.camera, true);
      
      // Test camera initialization
      await Fx.camera.initialize();
      
      // Verify initialization succeeded
      expect(fluxyTest.verifyCalled('camera.initialize'), isTrue);
    });
  });
}
```

### Integration Testing

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Integration Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    testWidgets('Complete user flow should work', (WidgetTester tester) async {
      // Mock all required services
      fluxyTest.mockPlugin('auth');
      fluxyTest.mockPlugin('storage');
      fluxyTest.mockPlugin('permissions');
      
      // Build the app
      await tester.pumpWidget(MyApp());
      
      // Test login flow
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // Fill login form
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      
      // Submit form
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pumpAndSettle();
      
      // Verify successful login
      expect(find.byKey(Key('home_screen')), findsOneWidget);
      
      // Test navigation
      await tester.tap(find.byKey(Key('profile_button')));
      await tester.pumpAndSettle();
      
      // Verify profile screen
      expect(find.byKey(Key('profile_screen')), findsOneWidget);
    });
  });
}
```

### Performance Testing

```dart
import 'package:fluxy_test/fluxy_test.dart';

void main() {
  group('Performance Tests', () {
    late FluxyTestHelper fluxyTest;
    
    setUp(() async {
      fluxyTest = await FluxyTestHelper.setup();
    });
    
    test('Widget rendering should be fast', () async {
      // Measure render time
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(ComplexWidget());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify render time is acceptable (< 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
    
    test('Signal updates should be efficient', () async {
      // Create multiple signals
      final signals = List.generate(1000, (i) => flux(i));
      
      // Measure update time
      final stopwatch = Stopwatch()..start();
      
      for (final signal in signals) {
        signal.value = signal.value + 1;
      }
      
      stopwatch.stop();
      
      // Verify update time is acceptable (< 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
```

## Features

- **Test Setup**: Easy test environment setup and cleanup
- **Mock Services**: Comprehensive mocking for all Fluxy services
- **Widget Testing**: Enhanced widget testing utilities
- **Reactive Testing**: Specialized testing for reactive state
- **Plugin Testing**: Test individual Fluxy plugins
- **Integration Testing**: End-to-end testing support
- **Performance Testing**: Performance measurement utilities
- **Assertion Helpers**: Custom assertions for Fluxy-specific tests

## API Reference

### Classes

- `FluxyTestHelper` - Main test helper class
- `FluxyMock` - Mock service provider
- `FluxyTestUtils` - Utility functions for testing

### Methods

- `FluxyTestHelper.setup()` - Set up test environment
- `FluxyTestHelper.cleanup()` - Clean up test environment
- `FluxyTestHelper.mockPlugin(String)` - Mock a specific plugin
- `FluxyTestHelper.mockPermission(FluxyPermission, bool)` - Mock permission status
- `FluxyTestHelper.verifyCalled(String)` - Verify method was called
- `FluxyMock.when()` - Set up mock behavior
- `FluxyMock.thenReturn()` - Set return value
- `FluxyMock.thenThrow()` - Set exception to throw

### Testing Utilities

- `testSignal()` - Test reactive signals
- `testAsyncFlux()` - Test async signals
- `testWidget()` - Test Fluxy widgets
- `testPlugin()` - Test Fluxy plugins

## Best Practices

### Test Organization
```dart
// Group related tests
group('Authentication', () {
  group('Login', () {
    test('should login with valid credentials');
    test('should reject invalid credentials');
  });
  
  group('Logout', () {
    test('should logout successfully');
    test('should clear user data');
  });
});
```

### Mock Setup
```dart
// Set up mocks in setUp
setUp(() async {
  fluxyTest = await FluxyTestHelper.setup();
  fluxyTest.mockPlugin('auth');
  fluxyTest.mockPlugin('storage');
});

// Clean up in tearDown
tearDown(() async {
  await fluxyTest.cleanup();
});
```

### Assertion Best Practices
```dart
// Use specific assertions
expect(counter.value, equals(5));
expect(user.email, equals('test@example.com'));
expect(find.byType(LoginButton), findsOneWidget);

// Use descriptive test names
test('should show error message when email is invalid');
test('should navigate to home screen after successful login');
```

## License

This package is licensed under the MIT License. See the LICENSE file for details.
