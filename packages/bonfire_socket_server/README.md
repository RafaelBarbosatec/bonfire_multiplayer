# BonfireSocket

The `BonfireSocket` class is a server-side implementation for handling WebSocket connections. It provides methods to manage client connections, broadcast messages, and handle incoming messages from clients.

## Features

- Accepts new WebSocket connections from clients.
- Manages a list of connected clients.
- Broadcasts messages to all connected clients.
- Handles incoming messages from clients and processes them accordingly.

## Usage

### Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  bonfire_socket_server:
    git:
      url: https://github.com/RafaelBarbosatec/bonfire_multiplayer
      path: packages/bonfire_socket_server
  dart_frog: ^1.2.0
```

### Example

Here is an example of how to use `BonfireSocket` in a Dart Frog application:

Just create a route `ws.dart`: 

```dart
import 'package:bonfire_socket_server/bonfire_socket_server.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final socket = BonfireSocket(
    onClientConnect: (client) {
      print('Client connected: ${client.id}');
    },
    onClientDisconnect: (client) {
      print('Client disconnected: ${client.id}');
    },
  );
  return socket.handler(context);
}
```

### API

#### `BonfireSocket`

- `BonfireSocket({void Function(BSocketClient client)? onClientConnect, void Function(BSocketClient client)? onClientDisconnect, EventSerializer? serializer, bool bufferDelayEnabled = false})`
  - Creates a new instance of `BonfireSocket`.

- `List<BSocketClient> get clients`
  - Returns a list of connected clients.

- `Handler handler()`
  - Returns a `Handler` that manages WebSocket connections.

- `void sendBroadcast<T>(String event, T message)`
  - Broadcasts a message to all connected clients.

- `void sendBroadcastFrom<T>(BSocketClient client, String event, T message)`
  - Broadcasts a message to all connected clients except the sender.

- `void sendTo<T>(BSocketClient client, String event, T message)`
  - Sends a message to a specific client.

- `void createRoom(String roomId)`
  - Creates a new room.

- `void closeRoom(String roomId)`
  - Closes a room.

- `bool enterRoom(String roomId, BSocketClient client)`
  - Adds a client to a room.

- `void createAndEnterRoom(String roomId, BSocketClient client)`
  - Creates a new room and adds a client to it.

- `void leaveRoom(String roomId, BSocketClient client)`
  - Removes a client from a room.

- `void sendToRoom<T>(String roomId, String event, T message)`
  - Sends a message to all clients in a room.

- `String? getMyRoomId(BSocketClient client)`
  - Returns the room ID of a client.

- `List<BSocketClient> getRoom(String roomId)`
  - Returns a list of clients in a room.

- `Map<String, List<BSocketClient>> getRooms()`
  - Returns a map of all rooms and their clients.


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

2. Register the type adapter with the BonfireSocket:

```dart
socket.registerType(MyCustomClassAdapter());
```

3. Send and receive events using the custom class:

```dart
client.send('custom_event', MyCustomClass(name: 'example', value: 42));

client.on<MyCustomClass>('custom_event', (data) {
  print('Received custom event: ${data.name}, ${data.value}');
});
```


## License

This project is licensed under the MIT License.
