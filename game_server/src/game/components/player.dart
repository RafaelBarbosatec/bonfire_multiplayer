// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../infrastructure/websocket/websocket_provider.dart';

/// Authoritative server-side player.
///
/// Besides movement, it owns the [PlayerAttributes] lifecycle: stamina drains
/// while walking and regenerates while idle, and the game hooks ([takeDamage],
/// [heal], [addXp], [restoreStamina]) are the only way to mutate HP/XP/level.
/// Every change is pushed to clients through the regular state delta
/// ([requestUpdate]), so the HUD stays in sync without extra events.
class Player extends GamePlayer
    with Collision, MapRef, BlockMovementOnCollision {
  Player({required super.state, required this.client}) {
    _listenMove();
    setupCollision(
      RectangleShape(GameVector.all(16), position: GameVector(x: 8, y: 16)),
    );
  }

  /// Stamina points regenerated per second while idle.
  static const double staminaRegenPerSecond = 1;

  /// Cost of a melee attack in SP (special attacks will cost more later).
  static const int meleeStaminaCost = 5;

  final WebsocketClient client;

  /// Fractional stamina accumulator so drain/regen is smooth across ticks.
  double _staminaAccumulator = 0;

  String get id => state.id;

  MoveDirectionEnum? moveDirection;

  void _listenMove() {
    client
      ..on<MoveEvent>(EventType.MOVE.name, (data) {
        if (data.mapId == map.id) {
          moveDirection = data.direction;
          // Echo the last processed input id back to the client so it
          // can reconcile its pending inputs (client-side prediction).
          if (data.inputId != null) {
            state.lastInputId = data.inputId;
          }
        }
      })
      ..on<MoveEvent>(EventType.LEAVE.name, (data) {
        client.cleanListener(EventType.MOVE.name);
        removeFromParent();
      })
      ..on<AllocateStatEvent>(EventType.ALLOCATE_STAT.name, (data) {
        _allocateStat(data.stat);
      });
  }

  // --- Game hooks (server-authoritative attribute mutations) -------------

  /// Reduces HP by [damage] (clamped to 0 by [PlayerAttributes]).
  void takeDamage(int damage) {
    _apply(state.attributes?.takeDamage(damage) ?? const PlayerAttributes());
  }

  /// Restores [amount] HP (clamped to max by [PlayerAttributes]).
  void heal(int amount) {
    _apply(state.attributes?.heal(amount) ?? const PlayerAttributes());
  }

  /// Grants [amount] XP, applying level-ups (100 XP per level, status points
  /// per classic Ragnarok) and recomputing the derived max pools.
  void addXp(int amount) {
    final current = state.attributes;
    if (current == null) return;
    final leveled = current.addXp(amount);
    if (identical(leveled, current)) return;
    _apply(leveled.withDerivedMax());
  }

  /// Invests one status point in [stat] ('str'/'agi'/'vit'/'int'/'dex'/'luk').
  /// Validated server-side (progressive cost, cap 99, available points).
  /// No dedicated ack — the regular state delta carries the result.
  void allocateStat(String stat) {
    final current = state.attributes;
    if (current == null) return;
    final updated = current.tryAllocateStat(stat);
    if (updated == null) return;
    _apply(updated);
  }

  void _allocateStat(String stat) => allocateStat(stat);

  /// Fills stamina to its maximum (e.g. when the player spawns).
  void restoreStamina() {
    final attrs = state.attributes;
    if (attrs == null || attrs.stamina >= attrs.maxStamina) return;
    _apply(attrs.changeStamina(attrs.maxStamina - attrs.stamina));
  }

  /// Consumes [amount] SP for a melee attack. Returns `false` (and changes
  /// nothing) when there isn't enough SP — the attack simply doesn't happen.
  bool spendStamina(int amount) {
    final attrs = state.attributes;
    if (attrs == null || attrs.stamina < amount) return false;
    _apply(attrs.changeStamina(-amount));
    return true;
  }

  void _apply(PlayerAttributes next) {
    if (state.attributes == next) return;
    state.attributes = next;
    requestUpdate();
  }

  // --- Engine hooks -------------------------------------------------------

  @override
  bool checkContact(Collision other) {
    if (other is Player) {
      return false;
    }
    return super.checkContact(other);
  }

  @override
  void onUpdate(double dt) {
    if (moveDirection != null) {
      moveFromDirection(dt, moveDirection!);
      // Stamp when this position is true on the server timeline, so clients
      // can interpolate remote entities on server time (immune to network
      // jitter) instead of on arrival time.
      state.serverTimestamp = DateTime.now().microsecondsSinceEpoch;
    } else {
      stopMove();
    }
    _updateStamina(dt);
    super.onUpdate(dt);
  }

  /// SP is only spent by attacks ([spendStamina]) — walking is free, so it
  /// does not pause regeneration. SP refills slowly (1/s). Only pushes a state
  /// update when a whole point regenerates (no per-tick spam).
  void _updateStamina(double dt) {
    final attrs = state.attributes;
    if (attrs == null || attrs.stamina >= attrs.maxStamina) {
      _staminaAccumulator = 0;
      return;
    }
    _staminaAccumulator += dt * staminaRegenPerSecond;
    final whole = _staminaAccumulator.truncate();
    if (whole == 0) return;
    _staminaAccumulator -= whole.toDouble();
    _apply(attrs.changeStamina(whole));
  }

  @override
  void send<T>(String event, T data) {
    client.send<T>(event, data);
  }

  @override
  void stopMove() {
    moveDirection = null;
    state.serverTimestamp = DateTime.now().microsecondsSinceEpoch;
    super.stopMove();
  }
}
