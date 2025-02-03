import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return context.read<BonfireSocket>().handler()(context);
}

class BonfireSocket extends BonfireTypeAdaptertProvider
    with BonfireSocketActions {
  List<BSocketClient> _clients = [];
  void Function(BSocketClient client)? onClientConnect;
  void Function(BSocketClient client)? onClientDisconnect;

  BonfireSocket({this.onClientConnect, this.onClientDisconnect});

  Handler handler() {
    return webSocketHandler(_addClient);
  }

  void _addClient(WebSocketChannel channel, _) {
    final client = BSocketClient(
      id: Uuid().v1(),
      channel: channel,
      onDisconnect: _onClientDisconnect,
      typeAdapterProvider: this,
      socket: this,
    );
    _clients.add(client);
    onClientConnect?.call(client);
    print('BonfireSocket: Client connected: ${client.id}');
  }

  void _onClientDisconnect(BSocketClient client) {
    _clients.remove(client);
    onClientDisconnect?.call(client);
    print('BonfireSocket: Client disconnected: ${client.id}');
  }

  @override
  void sendBroadcast<T>(String event, T message) {
    for (final client in _clients) {
      client.send<T>(event, message);
    }
  }

  @override
  void sendTo<T>(BSocketClient client, String event, T message) {
    client.send<T>(event, message);
  }
}

class BSocketClient {
  final String id;
  final WebSocketChannel channel;
  final void Function(BSocketClient client) onDisconnect;
  final BonfireTypeAdaptertProvider _typeAdapterProvider;
  final BonfireSocketActions socket;

  Map<String, void Function(dynamic)> _onSubscribers = {};

  BSocketClient({
    required this.id,
    required this.channel,
    required this.onDisconnect,
    required BonfireTypeAdaptertProvider typeAdapterProvider,
    required this.socket,
  }) : _typeAdapterProvider = typeAdapterProvider {
    channel.stream.listen(
      _onChannelListen,
      onDone: () => onDisconnect(this),
    );
  }

  void send<T>(String event, T message) {
    final typeString = T.toString();
    if (_typeAdapterProvider.types.containsKey(typeString)) {
      final adapter = _typeAdapterProvider.types[typeString] as BTypeAdapter<T>;
      final e = BEvent(
        event: event,
        data: adapter.toMap(message),
      );
      channel.sink.add(e.toJson());
    } else {
      final e = BEvent(
        event: event,
        data: message,
      );
      channel.sink.add(e.toJson());
    }
  }

  void on<T>(String event, void Function(T event) callback) {
    final typeString = T.toString();
    _onSubscribers[event] = (map) {
      if (_typeAdapterProvider.types.containsKey(typeString)) {
        final adapter =
            _typeAdapterProvider.types[typeString] as BTypeAdapter<T>;
        callback(adapter.fromMap(map));
      } else {
        callback(map as T);
      }
    };
  }

  void _onChannelListen(dynamic message) {
    final map = BEvent.fromArray(jsonDecode(message));
    try {
      final dataJson = jsonDecode(map.data);
      _onSubscribers[map.event]?.call(dataJson);
    } catch (e) {
      _onSubscribers[map.event]?.call(map.data);
    }
    print(message);
    send('oi', TestEvent(name: 'Test', age: 10));
  }
}

abstract class BonfireTypeAdaptertProvider {
  Map<String, BTypeAdapter> _types = {};

  Map<String, BTypeAdapter> get types => _types;

  void registerType<T>(BTypeAdapter<T> type) {
    _types[T.toString()] = type;
  }
}

mixin BonfireSocketActions {
  void sendBroadcast<T>(String event, T message);
  void sendTo<T>(BSocketClient client, String event, T message);
}

/// A generic adapter class for converting objects to and from maps.
///
/// This class is used to serialize and deserialize objects of type `T`
/// to and from `Map<String, dynamic>`. It requires two functions:
/// - `toMap`: Converts an object of type `T` to a map.
/// - `fromMap`: Converts a map to an object of type `T`.
class BTypeAdapter<T> {
  BTypeAdapter({required this.toMap, required this.fromMap});
  final Map<String, dynamic> Function(T type) toMap;
  final T Function(Map<String, dynamic> map) fromMap;
}

class TestEvent {
  final String name;
  final int age;

  TestEvent({required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory TestEvent.fromMap(Map<String, dynamic> map) {
    return TestEvent(
      name: map['name'],
      age: map['age'],
    );
  }
}

class BEvent {
  final String event;
  final dynamic data;

  BEvent({required this.event, required this.data});

  List toArray() {
    return [event, data];
  }

  factory BEvent.fromArray(List array) {
    return BEvent(
      event: array[0],
      data: array[1],
    );
  }

  String toJson() => jsonEncode(toArray());
}
