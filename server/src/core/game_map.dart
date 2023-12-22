// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/type_layer.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

import 'game_component.dart';

abstract class GameMap extends GameComponent {
  final String name;
  final String path;
  final List<GameRectangle> _collisions = [];

  GameMap({
    required this.name,
    required this.path,
  });

  @override
  bool checkCollisionWithParent(GameRectangle rect) {
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
                GameRectangle(
                  position: GameVector(x: obj.x ?? 0, y: obj.y ?? 0),
                  size: GameVector(x: obj.width ?? 0, y: obj.height ?? 0),
                ),
              );
            }
          }
        case TypeLayer.imagelayer:
        case TypeLayer.group:
        // ignore: no_default_cases
        default:
      }
    }
  }
}
