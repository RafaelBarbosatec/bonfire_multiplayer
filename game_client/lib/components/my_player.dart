import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';

enum PayerSkin {
  girl,
  boy;

  String get path {
    switch (this) {
      case PayerSkin.girl:
        return 'player_girl.png';
      case PayerSkin.boy:
        return 'player_boy.png';
    }
  }
}

class MyPlayer extends SimplePlayer with BlockMovementCollision {
  MyPlayer({
    required super.position,
    required PayerSkin skin,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: Direction.down,
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
      ),
    );
    return super.onLoad();
  }
}
