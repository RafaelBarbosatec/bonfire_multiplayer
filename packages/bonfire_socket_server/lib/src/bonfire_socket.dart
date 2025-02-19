import 'package:bonfire_socket_server/src/socket_actions.dart';
import 'package:bonfire_socket_server/src/socket_client.dart';
import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:uuid/uuid.dart';

/// The `BonfireSocket` class is a server-side implementation for handling
/// WebSocket connections. It provides methods to manage client connections,
/// broadcast messages, and handle incoming messages from clients.
///
/// This class is designed to be used in a server environment where multiple
/// clients can connect and communicate with each other through WebSocket
/// connections.
///
/// Features:
/// - Accepts new WebSocket connections from clients.
/// - Manages a list of connected clients.
/// - Broadcasts messages to all connected clients.
/// - Handles incoming messages from clients and processes them accordingly.
///
/// Example usage:
/// ```dart
/// import 'package:bonfire_socket_server/bonfire_socket_server.dart';
/// import 'package:dart_frog/dart_frog.dart';
///
/// Future<Response> onRequest(RequestContext context) async {
///  final socket = BonfireSocket(
///   onClientConnect: (client) {
///    print('Client connected: ${client.id}');
///  },
///  onClientDisconnect: (client) {
///   print('Client disconnected: ${client.id}');
///  },
///  return socket.handler()(context);
///}
/// ```
///
/// Note: This class requires the `dart:io` library for WebSocket functionality.
class BonfireSocket
    with
        BonfireTypeAdapterProvider,
        BonfireSocketActions,
        EventSerializerProvider {
  /// Creates a new instance of [BonfireSocket].
  BonfireSocket({
    this.onClientConnect,
    this.onClientDisconnect,
    EventSerializer? serializer,
    this.bufferDelayEnabled = false,
  }) {
    this.serializer = serializer ?? EventSerializerDefault();
  }

  final List<BSocketClient> _clients = [];
  final Map<String, List<BSocketClient>> _rooms = {};

  /// Returns a list of connected clients.
  List<BSocketClient> get clients => List.unmodifiable(_clients);

  /// Callback function that is called when a client connects.
  void Function(BSocketClient client)? onClientConnect;

  /// Callback function that is called when a client disconnects.
  void Function(BSocketClient client)? onClientDisconnect;

  /// Whether to enable buffer delay for incoming messages.
  final bool bufferDelayEnabled;

  /// Returns a [Handler] that manages WebSocket connections.
  Future<Response> handler(RequestContext context) async {
    return webSocketHandler(_addClient)(context);
  }

  void _addClient(WebSocketChannel channel, _) {
    final client = BSocketClient(
      id: const Uuid().v1(),
      channel: channel,
      onDisconnect: _onClientDisconnect,
      typeAdapterProvider: this,
      socket: this,
      serializerProvider: this,
      bufferDelayEnabled: bufferDelayEnabled,
    );
    _clients.add(client);
    onClientConnect?.call(client);
  }

  void _onClientDisconnect(BSocketClient client) {
    _clients.remove(client);
    client.leaveRoom();
    onClientDisconnect?.call(client);
  }

  @override
  void sendBroadcast<T>(String event, T message) {
    for (final client in _clients) {
      client.send<T>(event, message);
    }
  }

  @override
  void sendBroadcastFrom<T>(BSocketClient client, String event, T message) {
    for (final client in _clients.where((c) => c != client)) {
      client.send<T>(event, message);
    }
  }

  @override
  void sendTo<T>(BSocketClient client, String event, T message) {
    client.send<T>(event, message);
  }

  @override
  void createRoom(String roomId) {
    if (!_rooms.containsKey(roomId)) {
      _rooms[roomId] = [];
    }
  }

  @override
  void closeRoom(String roomId) {
    _rooms.remove(roomId);
  }

  @override
  bool enterRoom(String roomId, BSocketClient client) {
    if (_rooms.containsKey(roomId)) {
      _rooms[roomId]!.add(client);
      return true;
    } else {
      return false;
    }
  }

  @override
  void createAndEnterRoom(String roomId, BSocketClient client) {
    createRoom(roomId);
    enterRoom(roomId, client);
  }

  @override
  void leaveRoom(String roomId, BSocketClient client) {
    _rooms[roomId]?.remove(client);
    if (_rooms[roomId]?.isEmpty ?? false) {
      _rooms.remove(roomId);
    }
  }

  @override
  void sendToRoom<T>(String roomId, String event, T message) {
    final clients = _rooms[roomId];
    if (clients != null) {
      for (final client in clients) {
        client.send<T>(event, message);
      }
    }
  }

  @override
  String? getMyRoomId(BSocketClient client) {
    for (final entry in _rooms.entries) {
      if (entry.value.contains(client)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  List<BSocketClient> getRoom(String roomId) {
    return _rooms[roomId] ?? [];
  }

  @override
  Map<String, List<BSocketClient>> getRooms() {
    return Map.unmodifiable(_rooms);
  }
}
