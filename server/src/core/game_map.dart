// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:tiledjsonreader/map/layer/group_layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/object_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/layer/type_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

import '../util/game_map_object_properties.dart';
import 'game_component.dart';
import 'game_npc.dart';
import 'game_player.dart';
import 'geometry/base/extensions.dart';
import 'geometry/base/shape.dart';
import 'geometry/rectangle.dart';
import 'mixins/contact_sensor.dart';

abstract class GameMap extends GameComponent {
  final String name;
  final String path;
  final String id;
  final List<Shape> _collisions = [];

  Iterable<GamePlayer> get players => components.whereType();
  Iterable<GameNpc> get npcs => components.whereType();

  Iterable<ComponentStateModel> get playersState => players.map((e) => e.state);
  Iterable<ComponentStateModel> get npcsState => npcs.map((e) => e.state);

  GameMap({
    required this.id,
    required this.name,
    required this.path,
  });

  MapModel toModel() {
    return MapModel(
      id: id,
      name: name,
      path: path,
    );
  }

  void onObjectBuilder(GameMapObjectProperties object);

  @override
  bool checkContactWithParent(ContactSensor comp) {
    final shape = comp.getShapeContact();
    if (shape != null) {
      for (final collision in _collisions) {
        if (shape.isCollision(collision)) {
          comp.onDidContact(this);
          return true;
        }
      }
    }
    return super.checkContactWithParent(comp);
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
        final tileLayer = layer as TileLayer;
        final tileCount = tileLayer.data?.length ?? 0;
        for (var tileIndex = 0; tileIndex < tileCount; tileIndex++) {
          final tileId = tileLayer.data![tileIndex];
          if (tileId != 0) {
            _getCollisionFromTile(tileId, tileIndex, map, tileLayer);
          }
        }

      case TypeLayer.objectgroup:
        if (layer.layerClass == 'collision') {
          for (final obj in (layer as ObjectLayer).objects ?? <Objects>[]) {
            _collisions.add(
              RectangleShape(
                GameVector(x: obj.width ?? 0, y: obj.height ?? 0),
                position: GameVector(x: obj.x ?? 0, y: obj.y ?? 0),
              ),
            );
          }
        } else {
          for (final obj in (layer as ObjectLayer).objects ?? <Objects>[]) {
            if (obj.typeOrClass == 'collision') {
              _collisions.add(
                RectangleShape(
                  GameVector(x: obj.width ?? 0, y: obj.height ?? 0),
                  position: GameVector(x: obj.x ?? 0, y: obj.y ?? 0),
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

  void _getCollisionFromTile(
    int tileId,
    int tileIndex,
    TiledMap map,
    TileLayer layer,
  ) {
    final tile = getTileDetails(map.tileSets!, tileId);
    final collisionObjects = tile?.objectGroup?.objects ?? [];
    final isCollisionClass = tile?.typeOrClass == 'collision';
    if (!isCollisionClass && collisionObjects.isEmpty) return;

    final tileWidth = map.tileWidth ?? 0;
    final tileHeight = map.tileHeight ?? 0;
    final position = getTilePosition(
      layer: layer,
      map: map,
      tileIndex: tileIndex,
    );

    if (tile?.typeOrClass == 'collision') {
      _collisions.add(
        RectangleShape(
          GameVector(x: tileWidth.toDouble(), y: tileHeight.toDouble()),
          position: position,
        ),
      );
    } else if (collisionObjects.isNotEmpty) {
      for (final collision in collisionObjects) {
        final collisionOffset = GameVector(
          x: collision.x ?? 0,
          y: collision.y ?? 0,
        );
        _collisions.add(
          RectangleShape(
            GameVector(x: collision.width ?? 0, y: collision.height ?? 0),
            position: position + collisionOffset,
          ),
        );
      }
    }
  }

  TileSetItem? getTileDetails(List<TileSetDetail> tileSets, int tileId) {
    for (final tileSet in tileSets) {
      final tileTilesetIndex = tileSet.tiles?.indexWhere(
            (tile) => (tile.id! + tileSet.firsTgId!) == tileId,
          ) ??
          -1;
      if (tileTilesetIndex > -1) {
        return tileSet.tiles![tileTilesetIndex];
      }
    }
    return null;
  }

  GameVector getTilePosition({
    required int tileIndex,
    required TileLayer layer,
    required TiledMap map,
  }) {
    final xTileCount = tileIndex % layer.width!;
    final yTileCount = tileIndex ~/ layer.width!;
    final xTilePosition = xTileCount * map.tileWidth!;
    final yTilePosition = (yTileCount * map.tileHeight!).toDouble();
    return GameVector(x: xTilePosition, y: yTilePosition);
  }
}
