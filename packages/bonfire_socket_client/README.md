# BonfireSocketClient

BonfireSocketClient is a Dart library for managing WebSocket connections with advanced features like event serialization, time synchronization, and event buffering.

## Features

- WebSocket connection management
- Event serialization and deserialization
- Time synchronization
- Event buffering with delay

## Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
   bonfire_socket_client:
    git:
      url: https://github.com/RafaelBarbosatec/bonfire_multiplayer
      path: packages/bonfire_socket_client
```

## Usage

### Import the library

```dart
import 'package:bonfire_socket_client/bonfire_socket_client.dart';
```

### Create an instance of BonfireSocketClient

```dart
final client = BonfireSocketClient(
  uri: Uri.parse('wss://your-websocket-url'),
  debug: true,
);
```

### Connect to the WebSocket server

```dart
client.connect(
  onConnected: () {
    print('Connected to the server');
  },
  onDisconnected: (reason) {
    print('Disconnected from the server: $reason');
  },
  onConnecting: () {
    print('Connecting to the server...');
  },
);
```

### Listen for events

```dart
client.on<String>('event_name', (data) {
  print('Received event: $data');
});
```

### Send events

```dart
client.send('event_name', 'Your message');
```

### Time synchronization

The client automatically synchronizes time with the server. You can configure the synchronization interval using the `syncTimeInterval` parameter.

### Event buffering

Enable event buffering with delay using the `bufferDelayEnabled` parameter.

### Registering Type Adapters

To send and receive custom classes, you need to register type adapters.

1. Create a class and a corresponding type adapter:

```dart
class MyCustomClass {
  final String name;
  final int value;

  MyCustomClass({required this.name, required this.value});
}

class MyCustomClassAdapter extends BTypeAdapter<MyCustomClass> {
  @override
  MyCustomClass fromMap(Map<String, dynamic> map) {
    return MyCustomClass(
      name: map['name'],
      value: map['value'],
    );
  }

  @override
  Map<String, dynamic> toMap(MyCustomClass data) {
    return {
      'name': data.name,
      'value': data.value,
    };
  }
}
```

2. Register the type adapter with the client:

```dart
client.registerType(MyCustomClassAdapter());
```

3. Send and receive events using the custom class:

```dart
client.send('custom_event', MyCustomClass(name: 'example', value: 42));

client.on<MyCustomClass>('custom_event', (data) {
  print('Received custom event: ${data.name}, ${data.value}');
});
```

## Example

Here is a complete example:

```dart
import 'package:bonfire_socket_client/bonfire_socket_client.dart';

class MyCustomClass {
  final String name;
  final int value;

  MyCustomClass({required this.name, required this.value});
}

class MyCustomClassAdapter extends BTypeAdapter<MyCustomClass> {
  @override
  MyCustomClass fromMap(Map<String, dynamic> map) {
    return MyCustomClass(
      name: map['name'],
      value: map['value'],
    );
  }

  @override
  Map<String, dynamic> toMap(MyCustomClass data) {
    return {
      'name': data.name,
      'value': data.value,
    };
  }
}

void main() {
  final client = BonfireSocketClient(
    uri: Uri.parse('wss://your-websocket-url'),
    debug: true,
  );

  client.registerType(MyCustomClassAdapter());

  client.connect(
    onConnected: () {
      print('Connected to the server');
    },
    onDisconnected: (reason) {
      print('Disconnected from the server: $reason');
    },
    onConnecting: () {
      print('Connecting to the server...');
    },
  );

  client.on<MyCustomClass>('custom_event', (data) {
    print('Received custom event: ${data.name}, ${data.value}');
  });

  client.send('custom_event', MyCustomClass(name: 'example', value: 42));
}
```

## License

This project is licensed under the MIT License.