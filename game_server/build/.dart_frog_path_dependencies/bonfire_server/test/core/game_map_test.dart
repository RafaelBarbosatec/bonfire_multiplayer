import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';
import 'package:test/test.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tile_set_detail.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set_item.dart';

void main() {
  group('GameMap', () {
    late TileLayer layer;
    late TiledMap map;
    late GameMap gameMap;

    setUp(() {
      layer = TileLayer(width: 3, height: 3, data: [0, 0, 0, 0, 1, 0, 0, 0, 0])
        ..offsetX = 0
        ..offsetY = 0;
      map = TiledMap(
        tileHeight: 16,
        tileWidth: 16,
        width: 3,
        height: 3,
        tileSets: [
          TileSetDetail()
            ..tiles = [
              TileSetItem(id: 0),
              TileSetItem(id: 1)..typeOrClass = 'collision',
            ],
        ],
        layers: [layer],
      );
      gameMap = DesertMap(id: 'mock-id', name: 'mock-name', path: 'mock-path');
    });

    test('getTilePosition index 0', () {
      expect(
        gameMap.getTilePosition(tileIndex: 0, layer: layer, map: map),
        GameVector(x: 0, y: 0),
      );
    });

    test('getTilePosition index 4', () {
      expect(
        gameMap.getTilePosition(tileIndex: 4, layer: layer, map: map),
        GameVector(x: 16, y: 16),
      );
    });
  });
}

class DesertMap extends GameMap {
  DesertMap({required super.id, required super.name, required super.path});

  @override
  void onObjectBuilder(GameMapObjectProperties object) {
    // TODO: implement onObjectBuilder
  }
}
