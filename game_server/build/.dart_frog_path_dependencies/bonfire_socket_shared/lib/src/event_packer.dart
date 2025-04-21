// ignore_for_file: public_member_api_docs

import 'dart:convert';

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

  /// Packs an event with the given [event] name and [data].
  ///
  /// Returns the packed event as a base64 encoded string.
  String packEvent(BEvent event) {
    return base64Encode(
      serializer.serialize(event.toMap()),
    );
  }

  /// Unpacks an event from the given base64 encoded [data].
  ///
  /// Returns the unpacked [BEvent].
  BEvent unpackEvent(String data) {
    final bytes = base64Decode(data);
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
