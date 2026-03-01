# fluxy_websocket

High-performance real-time WebSocket plugin for the Fluxy framework.

## Features

- **Native Fluxy Support**: Seamlessly integrate with Fluxy's reactive state and plugin architecture.
- **Robust Real-time**: Built on top of `web_socket_channel` for reliable connection management.
- **Managed Lifecycle**: Let Fluxy handle the connection lifecycle alongside your application.
- **Minimal Boilerplate**: Simple API for sending and receiving messages.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  fluxy: ^1.1.0
  fluxy_websocket: ^1.1.0
```

## Usage

```dart
import 'package:fluxy/fluxy.dart';
import 'package:fluxy_websocket/fluxy_websocket.dart';

void main() {
  final websocketPlugin = FluxyWebSocketPlugin(
    url: 'ws://example.com',
  );

  Fluxy.init(
    plugins: [websocketPlugin],
  );
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
