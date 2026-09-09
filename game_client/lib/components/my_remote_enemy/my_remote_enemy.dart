import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:bonfire_multiplayer/util/smooth_movement_mixin.dart';
import 'package:bonfire_multiplayer/util/update_movement_mixin.dart';
import 'package:flutter/material.dart';

import 'bloc/my_remote_enemy_bloc.dart';

class MyRemoteEnemy extends SimpleEnemy
    with
        WithNameBottom,
        SmoothMovementMixin,
        UpdateMovementMixin,
        BonfireBlocListenable<MyRemoteEnemyBloc, MyRemoteEnemyState>,
        WithLifeBar {
  final String id;
  final GameEventManager eventManager;

  MyRemoteEnemy({
    required super.position,
    required PlayerSkin skin,
    required this.eventManager,
    required this.id,
    required String name,
    required double life,
    required double maxLife,
    Direction? initDirection,
    super.speed,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(skin.path),
          initDirection: initDirection ?? Direction.down,
          life: maxLife,
        ) {
    this.name = name;

    // The server spawns enemies at full life, but a client that joins
    // mid-fight sees an already-damaged enemy: keep the correct max (from
    // `maxLife`) and lower only the current value.
    if (life < maxLife) {
      this.life.update(life);
    }

    // Small bar above the head; default colors (green → yellow → red as
    // life drops) read well at 32px without the numeric text.
    lifeBar.setup(
      size: Vector2(size.x * 0.8, 3),
      drawPosition: BarLifeDrawPosition.top,
      offset: Vector2(0, -4),
      showLifeText: false,
      borderWidth: 1,
      borderRadius: BorderRadius.circular(1),
    );

    bloc = MyRemoteEnemyBloc(id, position, eventManager);
  }

  @override
  Future<void> onLoad() {
    // Hitbox so the local player collides with (is blocked by) this enemy.
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

    // Server-authoritative life: the delta already carries it (the server
    // broadcasts the NPC whenever it takes damage). The life bar attached by
    // WithLifeBar listens to `life` updates, so a simple sync keeps it in
    // perfect agreement with the server.
    final serverLife = state.life;
    if (serverLife != null && serverLife != life.value) {
      life.update(serverLife.toDouble());
    }
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
}
