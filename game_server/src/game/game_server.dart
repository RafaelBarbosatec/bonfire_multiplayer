import 'dart:async';
import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../main.dart';
import '../api/data/model/character_model.dart';
import '../api/data/repositories/character_repository.dart';
import '../api/usecases/authenticator.dart';
import '../infrastructure/websocket/websocket_provider.dart';
import 'components/my_enemy.dart';
import 'components/player.dart';
import 'state_tracker.dart';

class GameServer extends Game {
  GameServer({
    required this.server,
    required super.maps,
    required this.characterRepository,
    required this.authenticator,
  });
  static const tileSize = 16.0;

  /// Interval between automatic position saves (safety net for crashes).
  static const _saveInterval = Duration(seconds: 5);

  /// Minimum interval between two melee attacks of the same player.
  static const Duration meleeAttackCooldown = Duration(milliseconds: 600);

  /// Melee reach (center distance, world units — tiles are 16px).
  static const double meleeAttackRange = 48;

  List<WebsocketClient> clients = [];

  final WebsocketProvider server;

  /// Used to load the selected character when a client joins with a JWT.
  final CharacterRepository characterRepository;

  /// Validates the JWT sent in [JoinEvent].
  final Authenticator authenticator;

  /// Maps client id → character id (only for authenticated joins).
  final Map<String, String> _clientCharacterIds = {};

  /// Last persisted position per character — avoids redundant writes.
  final Map<String, _SavedPosition> _lastSaved = {};

  Timer? _saveTimer;

  /// State tracker per map for delta updates
  final Map<String, MapStateTracker> _mapTrackers = {};

  /// Last accepted attack timestamp per client (melee cooldown).
  final Map<String, DateTime> _lastAttackByClient = {};

  void enterClient(WebsocketClient client) {
    clients.add(client);
    logger.i('Client(${client.id}) Connected!');
    client.on<JoinEvent>(EventType.JOIN.name, (message) {
      logger.i('JoinEvent: ${message.toMap()}');
      _joinPlayerInTheGame(client, message);
    });
    client.on<AttackEvent>(EventType.ATTACK.name, (message) {
      _handleMeleeAttack(client, message);
    });
  }

  void leaveClient(WebsocketClient client) {
    clients.remove(client);
    for (final map in maps) {
      final players = map.components
          .whereType<Player>()
          .where((element) => element.id == client.id)
          .toList();
      for (final player in players) {
        // Persist the final position before removing the player.
        _saveCharacterPosition(player, map);
        player.removeFromParent();
      }
    }
    requestUpdate();
    logger.i('Client(${client.id}) Disconnected!');
  }

  @override
  void updateListeners(GameComponent compChanged) {
    if (compChanged is GameMap) {
      if (compChanged.players.isEmpty) {
        return;
      }

      // Get or create tracker for this map
      final tracker = _mapTrackers.putIfAbsent(
        compChanged.id,
        () => MapStateTracker(),
      );

      // Generate delta (only changed entities)
      final delta = tracker.generateDelta(
        currentPlayers: compChanged.playersState,
        currentNpcs: compChanged.npcsState,
      );

      // Only send if there are actual changes
      if (tracker.hasChanges(delta)) {
        final players = compChanged.players.whereType<Player>().toList();
        if (players.isEmpty) {
          return;
        }
        // Serialize ONCE for the whole broadcast: the delta is the same for
        // every player in the map, so we do a single msgpack pass and send
        // the same bytes to each recipient (binary frames).
        final bytes = players.first.client.serializeEvent<GameStateModel>(
          EventType.UPDATE_STATE.name,
          delta,
        );
        for (final player in players) {
          player.client.sendRaw(bytes);
        }
      }
    }
  }

  Future<void> _joinPlayerInTheGame(
    WebsocketClient client,
    JoinEvent message,
  ) async {
    if (components.whereType<Player>().any(
      (element) => element.id == client.id,
    )) {
      return;
    }

    if (maps.isEmpty) {
      return;
    }

    // Auth: when a JWT is provided, validate it and load the selected
    // character. Anonymous join (no token) keeps working for quick tests.
    CharacterModel? character;
    if (message.token != null) {
      final user = await authenticator.verifyToken(message.token!);
      if (user == null) {
        logger.e('Client(${client.id}) join rejected: invalid token');
        return;
      }
      if (message.characterId == null) {
        logger.e('Client(${client.id}) join rejected: characterId missing');
        return;
      }
      final result = await characterRepository.getById(message.characterId!);
      character = result.when(
        (c) => c.userId == user.id ? c : null,
        (error) => null,
      );
      if (character == null) {
        logger.e('Client(${client.id}) join rejected: character not found');
        return;
      }
      // Remember the character so position/map can be persisted later.
      _clientCharacterIds[client.id] = character.id;
    }

    // Position: saved character position or default spawn.
    final position = character != null
        ? GameVector(x: character.position.x, y: character.position.y)
        : GameVector(x: (3 + Random().nextInt(3)) * tileSize, y: 11 * tileSize);

    // Attributes: from the saved character or defaults for anonymous
    // quick-test joins. Pools are normalized from level/VIT/INT (formula may
    // have changed since the last session) and stamina restores to full on
    // spawn. From here on the authoritative values live in
    // `player.state.attributes` (see Player).
    final savedAttributes = character?.attributes ?? const PlayerAttributes();
    final normalized = savedAttributes.withDerivedMax();
    final attributes = normalized.copyWith(stamina: normalized.maxStamina);

    // Adds Player
    final player = Player(
      state: ComponentStateModel(
        id: client.id,
        name: character?.nickName ?? message.name,
        position: position,
        size: GameVector.all(16),
        life: 100,
        properties: {'skin': character?.skin ?? message.skin},
        attributes: attributes,
      ),
      client: client,
    );

    player.state.serverTimestamp = DateTime.now().microsecondsSinceEpoch;

    // Map: character's saved map or the first map.
    final initialMap = maps.firstWhere(
      (m) => m.id == character?.mapId,
      orElse: () => maps[0],
    );
    initialMap.add(player);

    // send ACK to client that request join.
    client.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: initialMap.playersState,
        npcs: initialMap.npcsState,
        map: initialMap.toModel(),
      ),
    );
  }

  @override
  void onPlayerChangeMap(GamePlayer player, GameMap map) {
    // Persist the new map + spawn position so a later re-join returns here.
    _saveCharacterPosition(player, map);
    player.send(
      EventType.JOIN_MAP.name,
      JoinMapEvent(
        state: player.state,
        players: map.playersState,
        npcs: map.npcsState,
        map: map.toModel(),
      ),
    );
  }

  @override
  Future<void> onLoadMaps() {
    logger.d('Loading maps...');
    return super.onLoadMaps();
  }

  // --- Melee combat (server-authoritative) --------------------------------

  /// Handles a melee attack request: validates map/cooldown, broadcasts the
  /// attack effect (so every client, including the attacker, sees the swing),
  /// then resolves the nearest enemy in reach, applies the player's ATK as
  /// damage and broadcasts the hit for client feedback.
  void _handleMeleeAttack(WebsocketClient client, AttackEvent message) {
    final player = _findPlayerByClient(client);
    if (player == null || player.map.id != message.mapId) return;

    final now = DateTime.now();
    final last = _lastAttackByClient[client.id];
    if (last != null && now.difference(last) < meleeAttackCooldown) return;
    _lastAttackByClient[client.id] = now;

    // Visual swing — broadcast even on a whiff so the attacker always sees
    // the attack happen. Effect id + position come from the server; clients
    // render only ids they know (unknown → nothing).
    final target = _findMeleeTarget(player);
    final direction = target != null
        ? _directionBetween(player.state, target.state)
        : (player.state.lastDirection ?? MoveDirectionEnum.down);
    _broadcastAttackEffect(
      player.map,
      AttackEffectEvent(
        sourceId: player.id,
        effectId: AttackEffectId.meleeSlash,
        position: _attackEffectPosition(player.state, direction),
        direction: direction,
      ),
    );
    if (target == null) return;

    final attrs = player.state.attributes;
    final damage = attrs == null ? 1 : (attrs.atk < 1 ? 1 : attrs.atk);
    target.receiveAttack(player, damage);
    _broadcastDamage(
      player.map,
      DamageEvent(
        sourceId: player.id,
        targetId: target.state.id,
        damage: damage,
        targetDied: target.state.life <= 0,
      ),
    );
  }

  /// World position where the melee slash effect should be spawned: one
  /// visual tile (~24px) ahead of the attacker's center, facing [direction].
  GameVector _attackEffectPosition(
    ComponentStateModel attacker,
    MoveDirectionEnum direction,
  ) {
    final unit = _directionUnitVector(direction);
    // Clients render every entity with a fixed 32px sprite whose top-left is
    // [state.position], so the visual center is +16px on each axis.
    const visualCenterOffset = 16.0;
    // Spawn the slash one body-width ahead (center + 16 half-body + 16 tile),
    // so it covers the tile(s) in melee reach instead of overlapping the body.
    const effectOffset = 32.0;
    final centerX = attacker.position.x + visualCenterOffset;
    final centerY = attacker.position.y + visualCenterOffset;
    return GameVector(
      x: centerX + unit.dx * effectOffset,
      y: centerY + unit.dy * effectOffset,
    );
  }

  /// Coarse 8-way direction from [from] to [to] (used to orient the effect).
  /// Centers use the same +16px visual offset the client renders with, so the
  /// direction matches what the attacker sees on screen.
  MoveDirectionEnum _directionBetween(
    ComponentStateModel from,
    ComponentStateModel to,
  ) {
    const visualCenterOffset = 16.0;
    final dx = (to.position.x + visualCenterOffset) -
        (from.position.x + visualCenterOffset);
    final dy = (to.position.y + visualCenterOffset) -
        (from.position.y + visualCenterOffset);
    if (dx.abs() > dy.abs() * 1.2) {
      return dx > 0 ? MoveDirectionEnum.right : MoveDirectionEnum.left;
    }
    if (dy.abs() > dx.abs() * 1.2) {
      return dy > 0 ? MoveDirectionEnum.down : MoveDirectionEnum.up;
    }
    if (dx > 0)
      return dy > 0 ? MoveDirectionEnum.downRight : MoveDirectionEnum.upRight;
    return dy > 0 ? MoveDirectionEnum.downLeft : MoveDirectionEnum.upLeft;
  }

  /// Unit vector for an 8-way direction.
  ({double dx, double dy}) _directionUnitVector(MoveDirectionEnum direction) {
    const diag = 0.7071;
    switch (direction) {
      case MoveDirectionEnum.up:
        return (dx: 0, dy: -1);
      case MoveDirectionEnum.down:
        return (dx: 0, dy: 1);
      case MoveDirectionEnum.left:
        return (dx: -1, dy: 0);
      case MoveDirectionEnum.right:
        return (dx: 1, dy: 0);
      case MoveDirectionEnum.upLeft:
        return (dx: -diag, dy: -diag);
      case MoveDirectionEnum.upRight:
        return (dx: diag, dy: -diag);
      case MoveDirectionEnum.downLeft:
        return (dx: -diag, dy: diag);
      case MoveDirectionEnum.downRight:
        return (dx: diag, dy: diag);
    }
  }

  Player? _findPlayerByClient(WebsocketClient client) {
    for (final map in maps) {
      for (final player in map.players.whereType<Player>()) {
        if (player.id == client.id) return player;
      }
    }
    return null;
  }

  /// Nearest alive enemy whose center is within melee reach of [player].
  MyEnemy? _findMeleeTarget(Player player) {
    MyEnemy? nearest;
    var bestDistance = double.infinity;
    final origin = player.state.position;
    final rangeSquared = meleeAttackRange * meleeAttackRange;
    for (final npc in player.map.npcs.whereType<MyEnemy>()) {
      if (npc.state.life <= 0) continue;
      final dx = npc.state.position.x - origin.x;
      final dy = npc.state.position.y - origin.y;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared <= rangeSquared && distanceSquared < bestDistance) {
        bestDistance = distanceSquared;
        nearest = npc;
      }
    }
    return nearest;
  }

  /// Serializes [damage] once and sends it raw to every player on [map]
  /// (same single-pass pattern as the state-delta broadcast).
  void _broadcastDamage(GameMap map, DamageEvent damage) {
    final players = map.players.whereType<Player>().toList();
    if (players.isEmpty) return;
    final bytes = players.first.client.serializeEvent<DamageEvent>(
      EventType.DAMAGE.name,
      damage,
    );
    for (final player in players) {
      player.client.sendRaw(bytes);
    }
  }

  /// Serializes [effect] once and sends it raw to every player on [map], so
  /// everyone (including the attacker) renders the same attack effect at the
  /// same world position.
  void _broadcastAttackEffect(GameMap map, AttackEffectEvent effect) {
    final players = map.players.whereType<Player>().toList();
    if (players.isEmpty) return;
    final bytes = players.first.client.serializeEvent<AttackEffectEvent>(
      EventType.ATTACK_EFFECT.name,
      effect,
    );
    for (final player in players) {
      player.client.sendRaw(bytes);
    }
  }

  @override
  void onStart() {
    logger.i('Start Game loop');
    _saveTimer ??= Timer.periodic(
      _saveInterval,
      (_) => _saveAllPlayersPosition(),
    );
    super.onStart();
  }

  @override
  void stop() {
    logger.i('Stop Game loop');
    _saveTimer?.cancel();
    _saveTimer = null;
    super.stop();
  }

  /// Periodically persists the position of every authenticated player, so a
  /// server crash loses at most [_saveInterval] of movement.
  void _saveAllPlayersPosition() {
    for (final map in maps) {
      for (final player in map.players) {
        _saveCharacterPosition(player, map);
      }
    }
  }

  /// Persists [player]'s current position/map to its character (best-effort,
  /// fire-and-forget). Anonymous players (no character) are ignored.
  Future<void> _saveCharacterPosition(GamePlayer player, GameMap map) async {
    final characterId = _clientCharacterIds[player.state.id];
    if (characterId == null) return;

    final x = player.position.x;
    final y = player.position.y;
    final mapId = map.id;
    final attributes = player.state.attributes;

    // Skip when nothing changed since the last save (avoids redundant
    // writes) — compares position/map AND attributes (a player standing
    // still can still level up / regen stamina).
    final last = _lastSaved[characterId];
    if (last != null &&
        last.mapId == mapId &&
        (last.x - x).abs() < 0.01 &&
        (last.y - y).abs() < 0.01 &&
        last.attributes == attributes) {
      return;
    }
    _lastSaved[characterId] = _SavedPosition(x, y, mapId, attributes);

    try {
      final result = await characterRepository.updatePosition(
        characterId: characterId,
        x: x,
        y: y,
        mapId: mapId,
        attributes: attributes,
      );
      result.when(
        (_) {},
        (error) => logger.e(
          'Failed to save position for character($characterId): $error',
        ),
      );
    } catch (e) {
      logger.e('Failed to save position for character($characterId): $e');
    }
  }
}

/// Last persisted position/map/attributes of a character.
class _SavedPosition {
  _SavedPosition(this.x, this.y, this.mapId, this.attributes);

  final double x;
  final double y;
  final String mapId;
  final PlayerAttributes? attributes;
}
