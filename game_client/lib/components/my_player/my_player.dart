import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
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

class MyPlayer extends SimplePlayer
    with
        BlockMovementCollision,
        BonfireBlocListenable<MyPlayerBloc, MyPlayerState> {
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
    // adds Rectangle collision
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // use checkInterval to sent move state 30 times per second
    if (checkInterval('updateServer', 33, dt)) {
      _sendMoveState();
    }
    super.update(dt);
  }

  void _sendMoveState() {
    // send move state if not stoped
    if (!isIdle) {
      bloc.add(
        UpdateMoveStateEvent(
          position: position,
          direction: lastDirection,
        ),
      );
    }
  }

  @override
  void idle() {
    // send move state stopped
    if (isMounted) {
      bloc.add(
        UpdateMoveStateEvent(
          position: position,
        ),
      );
    }

    super.idle();
  }
}
