// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

class EventPacker {
  final EventSerializerProvider serializerProvider;
  final BonfireTypeAdapterProvider typeAdapterProvider;

  EventPacker({
    required this.serializerProvider,
    required this.typeAdapterProvider,
  });

  EventSerializer get serializer => serializerProvider.serializer;
  Map<String, BTypeAdapter<dynamic>> get types => typeAdapterProvider.types;

  List<int> packEvent<T>(String event, T data) {
    final typeString = T.toString();
    dynamic eventdata = data;
    if (types.containsKey(typeString)) {
      final adapter = types[typeString]! as BTypeAdapter<T>;

      eventdata = adapter.toMap(data);
    }
    final e = BEvent(
      event: event,
      data: eventdata,
    );
    return serializer.serialize(e.toMap());
  }

  T unpackData<T>(dynamic data) {
    final typeString = T.toString();
    if (types.containsKey(typeString)) {
      final adapter = types[typeString]! as BTypeAdapter<T>;
      return adapter.fromMap((data as Map).cast());
    } else {
      return data as T;
    }
  }

  BEvent unpackEvent(Uint8List data) {
    return BEvent.fromMap(
      serializer.deserialize(data),
    );
  }
}
