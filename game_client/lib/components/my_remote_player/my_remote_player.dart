import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/bloc/my_remote_player_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';
import 'package:bonfire_multiplayer/util/update_movement_mixin.dart';

class MyRemotePlayer extends SimplePlayer
    with
        WithNameBottom,
        SmoothMovementMixin,
        UpdateMovementMixin,
        BonfireBlocListenable<MyRemotePlayerBloc, MyRemotePlayerState> {
  final String id;
  final GameEventManager eventManager;

  MyRemotePlayer({
    required super.position,
    required PlayerSkin skin,
    required this.eventManager,
    required this.id,
    required String name,
    Direction? initDirection,
    super.speed,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: initDirection ?? Direction.down,
        ) {
    this.name = name;
    bloc = MyRemotePlayerBloc(
      id,
      position,
      eventManager,
    );
  }

  // NOTE: no hitbox/collision on purpose — the remote player is a "ghost":
  // its position is fully owned by SmoothMovementMixin interpolation and the
  // local player passes through it (see MyPlayer's collision listener).

  @override
  void onNewState(MyRemotePlayerState state) {
    updateStateMove(state, serverTime: _serverTimeOf(state));
    super.onNewState(state);
  }

  /// Converts the server timestamp to the local timeline so interpolation
  /// follows the SERVER clock (immune to network jitter).
  DateTime? _serverTimeOf(MyRemotePlayerState state) {
    final ts = state.serverTimestamp;
    if (ts == null) return null;
    return eventManager.timeSync?.serverTimestampToLocal(ts);
  }

  @override
  void onRemove() {
    bloc.add(RemoveSbscribe());
    super.onRemove();
  }
}
