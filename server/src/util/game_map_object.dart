import 'package:shared_events/shared_events.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';

class GameMapObject {
  GameMapObject({
    required this.id,
    required this.name,
    required this.typeOrClass,
    required this.position,
    required this.size,
    required this.properties,
  });

  factory GameMapObject.fromObjects(Objects obj) {
    final properties = <String, dynamic>{};
    for (final prop in obj.properties ?? <Property>[]) {
      if (prop.name != null && prop.value != null) {
        properties[prop.name!] = prop.value;
      }
    }
    return GameMapObject(
      id: obj.id,
      name: obj.name ?? '',
      typeOrClass: obj.typeOrClass,
      position: GameVector(x: obj.x ?? 0, y: obj.y ?? 0),
      size: GameVector(x: obj.width ?? 0, y: obj.height ?? 0),
      properties: properties,
    );
  }

  final int? id;
  final String name;
  final String? typeOrClass;
  final GameVector position;
  final GameVector size;
  final Map<String, dynamic> properties;
}
