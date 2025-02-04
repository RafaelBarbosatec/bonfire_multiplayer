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
    if (isMounted) {
      _joystickDirectional = event.directional;
    }

    // comments this part to not move the player
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
      setZeroVelocity();
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
}
