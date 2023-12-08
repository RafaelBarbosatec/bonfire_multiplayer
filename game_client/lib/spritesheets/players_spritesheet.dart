import 'package:bonfire/bonfire.dart';

enum SpritSheetDirection { up, down, left, right }

class PlayersSpriteSheet {
  static Future<SpriteSheet> _create(
    String path, {
    int columns = 3,
    int rows = 4,
  }) async {
    Image image = await Flame.images.load(path);
    return SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: columns,
      rows: rows,
    );
  }

  static Future<SpriteAnimation> idle(
      String path, SpritSheetDirection direction) {
    return _create(path).then((value) {
      return value.createAnimation(
        row: _getRowDirection(direction),
        stepTime: 10,
        to: 1,
      );
    });
  }

  static Future<SpriteAnimation> walk(
      String path, SpritSheetDirection direction) {
    return _create(path).then((value) {
      return value.createAnimation(
        row: _getRowDirection(direction),
        stepTime: 0.2,
        from: 1,
        to: 3,
      );
    });
  }

  static SimpleDirectionAnimation simpleAnimation(String path) {
    return SimpleDirectionAnimation(
      idleRight: idle(path, SpritSheetDirection.right),
      idleUp: idle(path, SpritSheetDirection.up),
      idleDown: idle(path, SpritSheetDirection.down),
      idleLeft: idle(path, SpritSheetDirection.left),
      runUp: walk(path, SpritSheetDirection.up),
      runDown: walk(path, SpritSheetDirection.down),
      runLeft: walk(path, SpritSheetDirection.left),
      runRight: walk(path, SpritSheetDirection.right),
    );
  }

  static int _getRowDirection(SpritSheetDirection direction) {
    switch (direction) {
      case SpritSheetDirection.up:
        return 0;
      case SpritSheetDirection.down:
        return 1;
      case SpritSheetDirection.left:
        return 2;
      case SpritSheetDirection.right:
        return 3;
    }
  }
}
