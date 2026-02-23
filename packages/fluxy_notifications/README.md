# fluxy_notifications

Push and local notifications plugin for the Fluxy framework, providing comprehensive notification management with support for local notifications, scheduled notifications, and push notification handling.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  fluxy_notifications: ^1.0.0
```

## Usage

First, ensure you have Fluxy initialized and the notifications plugin registered:

```dart
import 'package:fluxy/fluxy.dart';

void main() async {
  await Fluxy.init();
  Fluxy.autoRegister(); // Registers all available plugins including notifications
  
  runApp(MyApp());
}
```

### Basic Notification Operations

```dart
import 'package:fluxy/fluxy.dart';

class NotificationService {
  // Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      await Fx.notifications.initialize();
      Fx.toast.success('Notifications initialized');
    } catch (e) {
      Fx.toast.error('Notification initialization failed: $e');
    }
  }
  
  // Show simple notification
  Future<void> showSimpleNotification() async {
    try {
      await Fx.notifications.show(
        title: 'Hello',
        body: 'This is a simple notification',
        payload: 'simple_notification',
      );
      Fx.toast.success('Notification sent');
    } catch (e) {
      Fx.toast.error('Failed to send notification: $e');
    }
  }
  
  // Show notification with actions
  Future<void> showNotificationWithActions() async {
    try {
      await Fx.notifications.show(
        title: 'New Message',
        body: 'You have received a new message',
        payload: 'new_message',
        actions: [
          NotificationAction(
            key: 'reply',
            title: 'Reply',
          ),
          NotificationAction(
            key: 'mark_read',
            title: 'Mark as Read',
          ),
        ],
      );
      Fx.toast.success('Notification with actions sent');
    } catch (e) {
      Fx.toast.error('Failed to send notification: $e');
    }
  }
  
  // Schedule notification
  Future<void> scheduleNotification() async {
    try {
      await Fx.notifications.schedule(
        id: 1,
        title: 'Reminder',
        body: 'This is a scheduled notification',
        scheduledTime: DateTime.now().add(Duration(minutes: 5)),
        payload: 'scheduled_notification',
      );
      Fx.toast.success('Notification scheduled');
    } catch (e) {
      Fx.toast.error('Failed to schedule notification: $e');
    }
  }
}
```

### Advanced Notification Features

```dart
class AdvancedNotificationService {
  // Show notification with custom style
  Future<void> showStyledNotification() async {
    try {
      await Fx.notifications.show(
        title: 'Styled Notification',
        body: 'This notification has custom styling',
        payload: 'styled_notification',
        style: NotificationStyle.bigPicture,
        largeIcon: 'assets/images/notification_icon.png',
        bigPicture: 'assets/images/notification_image.png',
        color: Colors.blue,
        importance: NotificationImportance.high,
        priority: NotificationPriority.high,
      );
      Fx.toast.success('Styled notification sent');
    } catch (e) {
      Fx.toast.error('Failed to send styled notification: $e');
    }
  }
  
  // Show progress notification
  Future<void> showProgressNotification() async {
    try {
      await Fx.notifications.show(
        title: 'Download Progress',
        body: 'Downloading file...',
        payload: 'download_progress',
        progress: 0,
        maxProgress: 100,
        indeterminate: false,
        ongoing: true,
        autoCancel: false,
      );
      
      // Update progress
      for (int i = 0; i <= 100; i += 10) {
        await Fx.notifications.updateProgress(
          id: 1,
          progress: i,
          body: 'Downloading file... $i%',
        );
        await Future.delayed(Duration(seconds: 1));
      }
      
      // Complete notification
      await Fx.notifications.updateProgress(
        id: 1,
        progress: 100,
        title: 'Download Complete',
        body: 'File downloaded successfully',
        ongoing: false,
      );
      
      Fx.toast.success('Progress notification completed');
    } catch (e) {
      Fx.toast.error('Failed to show progress notification: $e');
    }
  }
  
  // Show grouped notifications
  Future<void> showGroupedNotifications() async {
    try {
      // Show multiple notifications in a group
      await Fx.notifications.show(
        id: 1,
        title: 'New Email 1',
        body: 'You have a new email from sender1@example.com',
        payload: 'email_1',
        groupKey: 'emails',
        isGroupSummary: false,
      );
      
      await Fx.notifications.show(
        id: 2,
        title: 'New Email 2',
        body: 'You have a new email from sender2@example.com',
        payload: 'email_2',
        groupKey: 'emails',
        isGroupSummary: false,
      );
      
      // Show group summary
      await Fx.notifications.show(
        id: 0,
        title: 'New Emails',
        body: 'You have 2 new emails',
        payload: 'email_summary',
        groupKey: 'emails',
        isGroupSummary: true,
      );
      
      Fx.toast.success('Grouped notifications sent');
    } catch (e) {
      Fx.toast.error('Failed to send grouped notifications: $e');
    }
  }
}
```

### Notification Management

```dart
class NotificationManagementService {
  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await Fx.notifications.cancel(id);
      Fx.toast.success('Notification cancelled');
    } catch (e) {
      Fx.toast.error('Failed to cancel notification: $e');
    }
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await Fx.notifications.cancelAll();
      Fx.toast.success('All notifications cancelled');
    } catch (e) {
      Fx.toast.error('Failed to cancel all notifications: $e');
    }
  }
  
  // Get pending notifications
  Future<List<PendingNotification>> getPendingNotifications() async {
    try {
      final notifications = await Fx.notifications.getPendingNotifications();
      return notifications;
    } catch (e) {
      Fx.toast.error('Failed to get pending notifications: $e');
      return [];
    }
  }
  
  // Check notification permission
  Future<bool> checkNotificationPermission() async {
    try {
      final isGranted = await Fx.notifications.isPermissionGranted();
      if (!isGranted) {
        final granted = await Fx.notifications.requestPermission();
        if (granted) {
          Fx.toast.success('Notification permission granted');
        } else {
          Fx.toast.error('Notification permission denied');
        }
        return granted;
      }
      return true;
    } catch (e) {
      Fx.toast.error('Failed to check notification permission: $e');
      return false;
    }
  }
}
```

### Notification Channels (Android)

```dart
class NotificationChannelService {
  // Create notification channel
  Future<void> createNotificationChannel() async {
    try {
      await Fx.notifications.createChannel(
        id: 'important_channel',
        name: 'Important Notifications',
        description: 'Channel for important notifications',
        importance: NotificationImportance.high,
        sound: 'notification_sound.mp3',
        vibrationPattern: [0, 1000, 500, 1000],
        enableLights: true,
        enableVibration: true,
        ledColor: Colors.red,
      );
      Fx.toast.success('Notification channel created');
    } catch (e) {
      Fx.toast.error('Failed to create notification channel: $e');
    }
  }
  
  // Update notification channel
  Future<void> updateNotificationChannel() async {
    try {
      await Fx.notifications.updateChannel(
        id: 'important_channel',
        name: 'Updated Important Notifications',
        description: 'Updated channel for important notifications',
        importance: NotificationImportance.max,
      );
      Fx.toast.success('Notification channel updated');
    } catch (e) {
      Fx.toast.error('Failed to update notification channel: $e');
    }
  }
  
  // Delete notification channel
  Future<void> deleteNotificationChannel() async {
    try {
      await Fx.notifications.deleteChannel('important_channel');
      Fx.toast.success('Notification channel deleted');
    } catch (e) {
      Fx.toast.error('Failed to delete notification channel: $e');
    }
  }
}
```

## Features

- **Local Notifications**: Show immediate local notifications
- **Scheduled Notifications**: Schedule notifications for specific times
- **Notification Actions**: Add interactive actions to notifications
- **Progress Notifications**: Show progress in notifications
- **Grouped Notifications**: Group related notifications
- **Notification Channels**: Android notification channel support
- **Custom Styling**: Customize notification appearance
- **Permission Management**: Handle notification permissions
- **Cross-Platform**: Works on both iOS and Android

## API Reference

### Methods

- `initialize()` - Initialize notification service
- `show()` - Show immediate notification
- `schedule()` - Schedule notification for later
- `cancel(int id)` - Cancel specific notification
- `cancelAll()` - Cancel all notifications
- `getPendingNotifications()` - Get list of pending notifications
- `isPermissionGranted()` - Check notification permission
- `requestPermission()` - Request notification permission
- `createChannel()` - Create notification channel (Android)
- `updateChannel()` - Update notification channel (Android)
- `deleteChannel()` - Delete notification channel (Android)

### Notification Properties

- `title` - Notification title
- `body` - Notification body text
- `payload` - Custom payload data
- `actions` - List of notification actions
- `style` - Notification style (default, big picture, big text)
- `importance` - Notification importance level
- `priority` - Notification priority
- `color` - Notification color
- `largeIcon` - Large notification icon
- `bigPicture` - Big picture for big picture style

## Error Handling

The notifications plugin provides comprehensive error handling:

```dart
try {
  await Fx.notifications.show(title: 'Test', body: 'Test notification');
} on NotificationException catch (e) {
  // Handle specific notification errors
  switch (e.type) {
    case NotificationErrorType.permissionDenied:
      Fx.toast.error('Notification permission denied');
      break;
    case NotificationErrorType.schedulingFailed:
      Fx.toast.error('Failed to schedule notification');
      break;
    case NotificationErrorType.channelError:
      Fx.toast.error('Notification channel error');
      break;
    default:
      Fx.toast.error('Notification error: $e');
  }
} catch (e) {
  Fx.toast.error('Unexpected notification error: $e');
}
```

## Platform Configuration

### Android

Add the following to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### iOS

Add the following to your `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>remote-notification</string>
</array>
```

## Security Considerations

- All notification content is handled securely
- Permission requests require explicit user consent
- Sensitive data in payloads should be encrypted
- Notification channels are properly managed
- No unauthorized background notifications

## License

This package is licensed under the MIT License. See the LICENSE file for details.
