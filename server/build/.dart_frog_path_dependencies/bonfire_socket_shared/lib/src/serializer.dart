import 'dart:convert';

abstract class EventSerializer {
  List<int> serialize(Map<String, dynamic> map);
  Map<String, dynamic> deserialize(List<int> data);
}

class EventSerializerDefault implements EventSerializer {
  @override
  List<int> serialize(Map<String, dynamic> map) {
    return utf8.encode(jsonEncode(map));
  }

  @override
  Map<String, dynamic> deserialize(List<int> data) {
    return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
  }
}
