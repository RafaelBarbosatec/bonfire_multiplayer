// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import 'player.dart';

class MyEnemy extends GameNpc
    with Vision<Player>, Collision, BlockMovementOnCollision, RandomMovement {
  MyEnemy({required super.state}) {
    _spawnState = _cloneState(state);
    setupCollision(
      RectangleShape(GameVector.all(16), position: GameVector(x: 8, y: 16)),
    );
  }

  /// XP granted to the killer (leveling needs [PlayerAttributes.xpPerLevel]).
  static const int xpReward = 20;

  /// Time before the enemy respawns at its original spawn point.
  static const Duration respawnDelay = Duration(seconds: 8);

  /// Copy of the state this enemy spawned with, so a respawn is identical
  /// (same id, position, full life).
  late final ComponentStateModel _spawnState;

  Player? _targetPlayer;

  bool exitVision = false;

  Timer? _respawnTimer;

  /// Server-authoritative melee hit: subtracts [damage] from life and pushes
  /// the state delta. On death, rewards [attacker] with XP and schedules a
  /// respawn at the original spawn point.
  void receiveAttack(Player attacker, int damage) {
    if (state.life <= 0) return; // already dead/dying
    final nextLife = state.life - damage;
    state.life = nextLife < 0 ? 0 : nextLife;
    if (state.life <= 0) {
      attacker.addXp(xpReward);
      _scheduleRespawn();
      removeFromParent();
      return;
    }
    requestUpdate();
  }

  void _scheduleRespawn() {
    final spawnMap = parent;
    if (spawnMap == null || _respawnTimer != null) return;
    _respawnTimer = Timer(respawnDelay, () {
      _respawnTimer = null;
      spawnMap.add(MyEnemy(state: _cloneState(_spawnState)));
    });
  }

  ComponentStateModel _cloneState(ComponentStateModel s) {
    return ComponentStateModel(
      id: s.id,
      name: s.name,
      position: s.position.clone(),
      size: s.size.clone(),
      life: s.life,
      maxLife: s.maxLife,
      speed: s.speed,
      direction: s.direction,
      lastDirection: s.lastDirection,
      action: s.action,
      properties: Map<String, dynamic>.from(s.properties),
      lastInputId: s.lastInputId,
      serverTimestamp: s.serverTimestamp,
      attributes: s.attributes,
    );
  }

  @override
  void onUpdate(double dt) {
    if (state.life <= 0) return; // waiting for removal
    exitVision = _targetPlayer == null;
    _targetPlayer = null;
    super.onUpdate(dt);

    if (_targetPlayer != null) {
      followComponent(_targetPlayer!, dt);
    } else {
      randomMove(dt);
    }
  }

  @override
  void onFieldOfVision(Iterable<Player> components) {
    _targetPlayer = components.first;
  }

  @override
  double get radiusVision => size.x * 2;
}
