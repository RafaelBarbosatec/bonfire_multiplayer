// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

/// A class responsible for packing and unpacking events.
class EventPacker {
  /// Creates an instance of [EventPacker].
  EventPacker({
    required this.serializerProvider,
    required this.typeAdapterProvider,
  });

  final EventSerializerProvider serializerProvider;
  final BonfireTypeAdapterProvider typeAdapterProvider;

  /// Gets the event serializer.
  EventSerializer get serializer => serializerProvider.serializer;

  /// Packs an event into the serialized bytes ready to be sent over the wire.
  ///
  /// Returns the raw serialized bytes (msgpack by default) so the transport
  /// can send a binary WebSocket frame — no base64 inflation (binary frames
  /// are ~25% smaller than base64-encoded text frames).
  Uint8List packEvent(BEvent event) {
    return serializer.serialize(event.toMap());
  }

  /// Unpacks a received message into a [BEvent].
  ///
  /// Accepts both binary frames (`List<int>`) and legacy base64 text frames
  /// (`String`) so old clients/servers remain compatible during rollout.
  BEvent unpackEvent(dynamic data) {
    final Uint8List bytes;
    if (data is String) {
      bytes = base64Decode(data);
    } else if (data is List<int>) {
      bytes = Uint8List.fromList(data);
    } else {
      throw ArgumentError(
        'Unsupported message type: ${data.runtimeType}. '
        'Expected String (base64 text frame) or List<int> (binary frame).',
      );
    }
    return BEvent.fromMap(
      serializer.deserialize(bytes),
    );
  }

  T unpackData<T>(dynamic data) {
    return typeAdapterProvider.toType<T>(data);
  }

  dynamic packData<T>(T data) {
    return typeAdapterProvider.toMap<T>(data) ?? data;
  }
}
