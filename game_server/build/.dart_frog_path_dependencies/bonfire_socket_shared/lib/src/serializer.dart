// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

abstract class EventSerializer {
  Uint8List serialize(Map<String, dynamic> map);
  Map<String, dynamic> deserialize(Uint8List data);
}

class EventSerializerDefault implements EventSerializer {
  @override
  Uint8List serialize(Map<String, dynamic> map) {
    return msgpack.serialize(map);
  }

  @override
  Map<String, dynamic> deserialize(Uint8List data) {
    return msgpack.deserialize(data) as Map<String, dynamic>;
  }
}
