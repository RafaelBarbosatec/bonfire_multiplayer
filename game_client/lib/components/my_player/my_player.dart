import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
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

class MyPlayer extends SimplePlayer
    with
        BlockMovementCollision,
        WithNameBottom,
        BonfireBlocListenable<MyPlayerBloc, MyPlayerState> {
  JoystickMoveDirectional? _joystickDirectional;
  bool sendedIdle = false;
  bool moveEnabled = true;

  MyPlayer({
    required super.position,
    required String name,
    required PayerSkin skin,
    super.speed,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: Direction.down,
        ) {
    this.name = name;
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (moveEnabled) {
      _joystickDirectional = event.directional;
    }

    // comments this part to not move component
    // super.onJoystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    // sent move state
    _sendMoveState();
    super.update(dt);
  }

  void _sendMoveState() {
    // send move state if not stoped
    if (_joystickDirectional == JoystickMoveDirectional.IDLE) {
      if (!sendedIdle) {
        sendedIdle = true;
        _sendMove();
      }
    } else if (_joystickDirectional != null) {
      sendedIdle = false;
      _sendMove();
    }
  }

  @override
  void onNewState(MyPlayerState state) {
    if (state.position.distanceTo(position) > 4) {
      add(
        MoveEffect.to(
          state.position,
          EffectController(duration: 0.05),
        ),
      );
    }
    if (state.direction != null) {
      moveFromDirection(state.direction!);
    } else {
      stopMove(forceIdle: true);
    }
    super.onNewState(state);
  }

  void _sendMove() {
    bloc.add(
      UpdateMoveStateEvent(
        position: position,
        direction: _joystickDirectional?.toDirection(),
      ),
    );
  }

  @override
  void onRemove() {
    bloc.add(DisposeEvent());
    super.onRemove();
  }
}
