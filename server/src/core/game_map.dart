// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/type_layer.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

import '../util/geometry.dart';
import 'game_component.dart';

abstract class GameMap extends GameComponent {
  final String name;
  final String path;
  final List<Rect> _collisions = [];

  GameMap({
    required this.name,
    required this.path,
  });

  @override
  bool checkCollisionWithParent(Rect rect) {
    for (final collision in _collisions) {
      if (rect.overlaps(collision)) {
        return true;
      }
    }
    return super.checkCollisionWithParent(rect);
  }

  Future<void> load() async {
    final tiled = TiledJsonReader('public/$path');
    final map = await tiled.read();
    for (final layer in map.layers ?? <MapLayer>[]) {
      switch (layer.type) {
        case TypeLayer.tilelayer:
          break;
        case TypeLayer.objectgroup:
          if (layer.layerClass == 'collision') {
            for (final obj in (layer as ObjectLayer).objects ?? <Objects>[]) {
              _collisions.add(
                Rect.fromLTWH(
                  obj.x ?? 0,
                  obj.y ?? 0,
                  obj.width ?? 0,
                  obj.height ?? 0,
                ),
              );
            }
          }
        case TypeLayer.imagelayer:
        case TypeLayer.group:
        default:
      }
    }
  }
}
