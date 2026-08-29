import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';
import 'package:bonfire_multiplayer/util/update_movement_mixin.dart';

import 'bloc/my_remote_enemy_bloc.dart';

class MyRemoteEnemy extends SimpleEnemy
    with
        WithNameBottom,
        SmoothMovementMixin,
        UpdateMovementMixin,
        BonfireBlocListenable<MyRemoteEnemyBloc, MyRemoteEnemyState> {
  final String id;
  final GameEventManager eventManager;

  MyRemoteEnemy({
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

    bloc = MyRemoteEnemyBloc(
      id,
      position,
      eventManager,
    );

    movementOnlyVisible = false;
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
  void onNewState(MyRemoteEnemyState state) {
    updateStateMove(state, serverTime: _serverTimeOf(state));
    super.onNewState(state);
  }

  /// Converts the server timestamp to the local timeline so interpolation
  /// follows the SERVER clock (immune to network jitter).
  DateTime? _serverTimeOf(MyRemoteEnemyState state) {
    final ts = state.serverTimestamp;
    if (ts == null) return null;
    return eventManager.timeSync?.serverTimestampToLocal(ts);
  }

  @override
  void onRemove() {
    bloc.add(RemoveSubscribe());
    super.onRemove();
  }

  // Remote position is FULLY controlled by SmoothMovementMixin interpolation.
  // The movement engine must NOT move remote entities — if it does, the
  // engine's translate() fights the interpolation (both write position),
  // causing constant jitter/corrections. Animation only is triggered via
  // moveFromDirection() in UpdateMovementMixin.
  @override
  void translate(Vector2 displacement) {
    // no-op
  }
}
