# fluxy_analytics

Analytics plugin for the Fluxy framework, providing comprehensive analytics tracking and user behavior monitoring capabilities.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_analytics: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the analytics plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including analytics
  
  runApp(MyApp());
}
```

### Basic Analytics Tracking

```dart
import 'package:fluxy/fluxy.dart';

class AnalyticsService {
  // Initialize analytics
  Future<void> initializeAnalytics() async {
    try {
      await Fx.analytics.initialize();
      Fx.toast.success('Analytics initialized');
    } catch (e) {
      Fx.toast.error('Analytics initialization failed: $e');
    }
  }
  
  // Track custom event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      await Fx.analytics.track(eventName, parameters: parameters);
      Fx.toast.success('Event tracked: $eventName');
    } catch (e) {
      Fx.toast.error('Failed to track event: $e');
    }
  }
  
  // Track screen view
  Future<void> trackScreenView(String screenName) async {
    try {
      await Fx.analytics.trackScreen(screenName);
      Fx.toast.success('Screen view tracked: $screenName');
    } catch (e) {
      Fx.toast.error('Failed to track screen view: $e');
    }
  }
  
  // Set user property
  Future<void> setUserProperty(String name, String value) async {
    try {
      await Fx.analytics.setUserProperty(name, value);
      Fx.toast.success('User property set: $name');
    } catch (e) {
      Fx.toast.error('Failed to set user property: $e');
    }
  }
}
```

### Advanced Analytics Features

```dart
class AdvancedAnalyticsService {
  // Track user engagement
  Future<void> trackUserEngagement(String action, {Map<String, dynamic>? context}) async {
    try {
      await Fx.analytics.track('user_engagement', parameters: {
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?context,
      });
    } catch (e) {
      Fx.toast.error('Failed to track user engagement: $e');
    }
  }
  
  // Track app performance
  Future<void> trackPerformance(String metric, double value) async {
    try {
      await Fx.analytics.track('app_performance', parameters: {
        'metric': metric,
        'value': value,
        'device': Platform.operatingSystem,
      });
    } catch (e) {
      Fx.toast.error('Failed to track performance: $e');
    }
  }
  
  // Track error events
  Future<void> trackError(String error, {String? stackTrace}) async {
    try {
      await Fx.analytics.track('app_error', parameters: {
        'error': error,
        'stack_trace': stackTrace,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Fx.toast.error('Failed to track error: $e');
    }
  }
  
  // Track conversion events
  Future<void> trackConversion(String conversionType, double value) async {
    try {
      await Fx.analytics.track('conversion', parameters: {
        'type': conversionType,
        'value': value,
        'currency': 'USD',
      });
    } catch (e) {
      Fx.toast.error('Failed to track conversion: $e');
    }
  }
}
```

### User Management

```dart
class UserAnalyticsService {
  // Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await Fx.analytics.setUserId(userId);
      Fx.toast.success('User ID set: $userId');
    } catch (e) {
      Fx.toast.error('Failed to set user ID: $e');
    }
  }
  
  // Set user properties
  Future<void> setUserProperties(Map<String, String> properties) async {
    try {
      for (final entry in properties.entries) {
        await Fx.analytics.setUserProperty(entry.key, entry.value);
      }
      Fx.toast.success('User properties set');
    } catch (e) {
      Fx.toast.error('Failed to set user properties: $e');
    }
  }
  
  // Clear user data
  Future<void> clearUserData() async {
    try {
      await Fx.analytics.clearUser();
      Fx.toast.success('User data cleared');
    } catch (e) {
      Fx.toast.error('Failed to clear user data: $e');
    }
  }
}
```

### E-commerce Analytics

```dart
class EcommerceAnalyticsService {
  // Track product view
  Future<void> trackProductView(String productId, String productName, double price) async {
    try {
      await Fx.analytics.track('product_view', parameters: {
        'product_id': productId,
        'product_name': productName,
        'price': price,
      });
    } catch (e) {
      Fx.toast.error('Failed to track product view: $e');
    }
  }
  
  // Track add to cart
  Future<void> trackAddToCart(String productId, int quantity, double price) async {
    try {
      await Fx.analytics.track('add_to_cart', parameters: {
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      });
    } catch (e) {
      Fx.toast.error('Failed to track add to cart: $e');
    }
  }
  
  // Track purchase
  Future<void> trackPurchase(String orderId, double totalValue, List<Map<String, dynamic>> items) async {
    try {
      await Fx.analytics.track('purchase', parameters: {
        'order_id': orderId,
        'total_value': totalValue,
        'items': items,
        'currency': 'USD',
      });
    } catch (e) {
      Fx.toast.error('Failed to track purchase: $e');
    }
  }
}
```

### Analytics Configuration

```dart
class AnalyticsConfigurationService {
  // Enable/disable analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      await Fx.analytics.setEnabled(enabled);
      Fx.toast.success('Analytics ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      Fx.toast.error('Failed to set analytics state: $e');
    }
  }
  
  // Set analytics collection interval
  Future<void> setCollectionInterval(Duration interval) async {
    try {
      await Fx.analytics.setCollectionInterval(interval);
      Fx.toast.success('Collection interval set');
    } catch (e) {
      Fx.toast.error('Failed to set collection interval: $e');
    }
  }
  
  // Get analytics session ID
  Future<String?> getSessionId() async {
    try {
      return await Fx.analytics.getSessionId();
    } catch (e) {
      Fx.toast.error('Failed to get session ID: $e');
      return null;
    }
  }
}
```

## Features

- **Event Tracking**: Track custom events with parameters
- **Screen Tracking**: Monitor screen views and navigation
- **User Properties**: Set and manage user-specific properties
- **Performance Monitoring**: Track app performance metrics
- **Error Tracking**: Monitor and analyze app errors
- **E-commerce Tracking**: Specialized e-commerce event tracking
- **User Management**: Set user IDs and clear user data
- **Configuration**: Configure analytics settings and intervals

## API Reference

### Methods

- `initialize()` - Initialize analytics service
- `track(String eventName, {Map<String, dynamic>? parameters})` - Track custom event
- `trackScreen(String screenName)` - Track screen view
- `setUserId(String userId)` - Set user ID
- `setUserProperty(String name, String value)` - Set user property
- `clearUser()` - Clear user data
- `setEnabled(bool enabled)` - Enable/disable analytics
- `setCollectionInterval(Duration interval)` - Set collection interval
- `getSessionId()` - Get current session ID

### Event Types

- **Custom Events**: User-defined events with parameters
- **Screen Views**: Automatic screen tracking
- **User Engagement**: User interaction tracking
- **Performance**: App performance metrics
- **Errors**: Error and exception tracking
- **Conversions**: Business conversion tracking

## Error Handling

The analytics plugin provides comprehensive error handling:

```dart
try {
  await Fx.analytics.track('custom_event', parameters: {'key': 'value'});
} on AnalyticsException catch (e) {
  // Handle specific analytics errors
  switch (e.type) {
    case AnalyticsErrorType.initializationFailed:
      Fx.toast.error('Analytics initialization failed');
      break;
    case AnalyticsErrorType.trackingDisabled:
      Fx.toast.error('Analytics tracking is disabled');
      break;
    case AnalyticsErrorType.invalidParameters:
      Fx.toast.error('Invalid event parameters');
      break;
    default:
      Fx.toast.error('Analytics error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected analytics error: $e');
}
```

## Privacy Considerations

- All user data is handled according to privacy policies
- Analytics can be disabled by users
- No sensitive personal information is collected without consent
- Data retention policies are configurable
- GDPR and CCPA compliance features

## Platform Support

- **iOS**: Native iOS analytics integration
- **Android**: Native Android analytics support
- **Web**: Web analytics tracking capabilities
- **Cross-Platform**: Unified API across all platforms

## License

This package is licensed under the MIT License. See the LICENSE file for details.
