// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:typed_data';

abstract class EventSerializer {
  Uint8List serialize(Map<String, dynamic> map);
  Map<String, dynamic> deserialize(Uint8List data);
}

class EventSerializerDefault implements EventSerializer {
  @override
  Uint8List serialize(Map<String, dynamic> map) {
    final json = jsonEncode(map);
    return utf8.encode(json);
  }

  @override
  Map<String, dynamic> deserialize(Uint8List data) {
    final bytes = utf8.decode(data);
    return jsonDecode(bytes) as Map<String, dynamic>;
  }
}
