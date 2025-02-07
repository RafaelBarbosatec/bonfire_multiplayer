import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:shared_events/shared_events.dart';

class MyPlayer extends SimplePlayer
    with
        BlockMovementCollision,
        WithNameBottom,
        BonfireBlocListenable<MyPlayerBloc, MyPlayerState> {
  JoystickMoveDirectional? _joystickDirectional;
  bool sendedIdle = false;
  async.Timer? timer;
  static const double _positionThreshold = 32.0; // 1 tile distance

  MyPlayer({
    required ComponentStateModel state,
    required GameEventManager eventManager,
    required String mapId,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(
              PlayerSkin.fromName(state.properties['skin']).path),
          initDirection: state.lastDirection?.toDirection() ?? Direction.down,
          position: state.position.toVector2(),
        ) {
    name = state.name;
    speed = state.speed;
    bloc = MyPlayerBloc(
      eventManager,
      state,
      mapId,
    );
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (isMounted && _joystickDirectional != event.directional) {
      _joystickDirectional = event.directional;
      _sendMove();
    }

    super.onJoystickChangeDirectional(event);
  }

  @override
  void onNewState(MyPlayerState state) {
    final _serverPosition = state.position;

    // Check if local position deviated too much from server position
    if (position.distanceTo(_serverPosition) > _positionThreshold) {
      _smoothCorrectPosition(_serverPosition);
    }

    if (state.direction != null) {
      moveFromDirection(state.direction!.toDirection());
    } else {
      lastDirection = state.lastDirection.toDirection();
      stopMove(forceIdle: true);
    }
    super.onNewState(state);
  }

  void _sendMove() {
    bloc.add(
      UpdateMoveStateEvent(
        position: position,
        direction: _joystickDirectional?.toMoveDirection(),
      ),
    );
  }

  void _smoothCorrectPosition(Vector2 serverPosition) {
    // Correct position over 200ms for smooth transition
    add(
      MoveEffect.to(
        serverPosition,
        EffectController(duration: 0.2),
      ),
    );
  }

  @override
  void onRemove() {
    bloc.close();
    super.onRemove();
  }
}
