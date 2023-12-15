import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';

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

  factory PayerSkin.fromName(String name) {
    return PayerSkin.values.firstWhere(
      (element) => element.name == name,
      orElse: () => PayerSkin.boy,
    );
  }
}

class MyPlayer extends SimplePlayer with BlockMovementCollision, WithNameBottom, BonfireBlocListenable<MyPlayerBloc, MyPlayerState> {
  MyPlayer({
    required super.position,
    required String name,
    required PayerSkin skin,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: Direction.down,
        ) {
    this.name = name;
  }

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
    // sent move state
    _sendMoveState();
    super.update(dt);
  }

  // Altere este método na classe MyPlayer
  void _sendMoveState() {
    // send move state if not stoped
    if (!isIdle) {
      final event = UpdateMoveStateEvent(
        position: position,
        direction: lastDirection,
      );
      bloc.add(event);
      print('Sending move event: $event');
      // Wait for the server to validate the move before updating the player's position
      bloc.stream.firstWhere((state) => state is MoveValidationState && state.event == event).then((state) {
        if (state is MoveValidationState) {
          // The server has validated the move, update the player's position
          position = state.position;
          print('Received move validation from server. New position: $position');
        }
      });
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
