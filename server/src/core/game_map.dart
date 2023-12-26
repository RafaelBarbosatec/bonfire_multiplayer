// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:tiledjsonreader/map/layer/group_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/layer/type_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

import '../util/game_map_object_properties.dart';
import 'game_component.dart';
import 'game_npc.dart';
import 'game_player.dart';
import 'game_sensor.dart';

abstract class GameMap extends GameComponent {
  final String name;
  final String path;
  final List<GameRectangle> _collisions = [];

  Iterable<GamePlayer> get players => components.whereType();
  Iterable<GameNpc> get npcs => components.whereType();

  Iterable<ComponentStateModel> get playersState => players.map((e) => e.state);
  Iterable<ComponentStateModel> get npcsState => npcs.map((e) => e.state);

  GameMap({
    required this.name,
    required this.path,
  });

  void onObjectBuilder(GameMapObjectProperties object);

  @override
  bool checkCollisionWithParent(GameSensorContact comp) {
    for (final collision in _collisions) {
      if (comp.getRectContact().overlaps(collision)) {
        return true;
      }
    }
    return super.checkCollisionWithParent(comp);
  }

  Future<void> load() async {
    final tiled = TiledJsonReader('public/$path');
    final map = await tiled.read();
    for (final layer in map.layers ?? <MapLayer>[]) {
      _collectLayerInformations(layer, map);
    }
  }

  void _collectLayerInformations(MapLayer layer, TiledMap map) {
    switch (layer.type) {
      case TypeLayer.tilelayer:
        for (final tile in (layer as TileLayer).data ?? <int>[]) {
          if (tile != 0) {
            _getCollisionFromTile(tile, map);
          }
        }
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
        } else {
          for (final obj in (layer as ObjectLayer).objects ?? <Objects>[]) {
            if (obj.typeOrClass == 'collision') {
              _collisions.add(
                GameRectangle(
                  position: GameVector(x: obj.x ?? 0, y: obj.y ?? 0),
                  size: GameVector(x: obj.width ?? 0, y: obj.height ?? 0),
                ),
              );
            } else {
              onObjectBuilder(GameMapObjectProperties.fromObjects(obj));
            }
          }
        }
      case TypeLayer.group:
        for (final subLayer in (layer as GroupLayer).layers ?? <MapLayer>[]) {
          _collectLayerInformations(subLayer, map);
        }
      case TypeLayer.imagelayer:
      // ignore: no_default_cases
      default:
    }
  }

  void _getCollisionFromTile(int tile, TiledMap map) {
    // TODO extract collision from tile configuration.
  }
}
