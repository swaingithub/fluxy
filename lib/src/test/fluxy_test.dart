import '../../fluxy.dart';

/// A toolkit for writing Fluxy-grade unit and widget tests.
/// Provides helpers for DI mocking and lifecycle verification.
class FluxyTest {
  /// Initializes the testing environment for Fluxy.
  static void setUp() {
    FluxyDI.reset();
  }

  /// Inject a mock dependency into the Fluxy DI system for testing.
  static void inject<T>(T instance, {String? tag}) {
    FluxyDI.put<T>(instance, tag: tag);
  }
}
