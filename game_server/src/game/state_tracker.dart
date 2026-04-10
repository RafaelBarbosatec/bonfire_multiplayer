import 'package:shared_events/shared_events.dart';

/// Tracks entity state changes per map for delta updates
class MapStateTracker {
  /// Last known state hash for each entity by ID
  final Map<String, int> _lastPlayerHashes = {};
  final Map<String, int> _lastNpcHashes = {};

  /// IDs of entities that existed in last tick
  final Set<String> _lastPlayerIds = {};
  final Set<String> _lastNpcIds = {};

  /// Calculate hash for a ComponentStateModel (for change detection)
  int _calculateHash(ComponentStateModel state) {
    // Hash based on position, direction, life, and action
    // These are the fields that matter for visual updates
    return Object.hash(
      state.position.x.toInt(),
      state.position.y.toInt(),
      state.direction,
      state.life,
      state.action,
    );
  }

  /// Generate delta update comparing current state to last known state
  /// Returns GameStateModel with only changed entities and removed IDs
  GameStateModel generateDelta({
    required Iterable<ComponentStateModel> currentPlayers,
    required Iterable<ComponentStateModel> currentNpcs,
  }) {
    final changedPlayers = <ComponentStateModel>[];
    final changedNpcs = <ComponentStateModel>[];
    final removed = <String>[];

    // Current IDs
    final currentPlayerIds = currentPlayers.map((p) => p.id).toSet();
    final currentNpcIds = currentNpcs.map((n) => n.id).toSet();

    // Find removed players
    for (final id in _lastPlayerIds) {
      if (!currentPlayerIds.contains(id)) {
        removed.add(id);
        _lastPlayerHashes.remove(id);
      }
    }

    // Find removed NPCs
    for (final id in _lastNpcIds) {
      if (!currentNpcIds.contains(id)) {
        removed.add(id);
        _lastNpcHashes.remove(id);
      }
    }

    // Find changed/new players
    for (final player in currentPlayers) {
      final hash = _calculateHash(player);
      final lastHash = _lastPlayerHashes[player.id];

      if (lastHash == null || lastHash != hash) {
        changedPlayers.add(player);
        _lastPlayerHashes[player.id] = hash;
      }
    }

    // Find changed/new NPCs
    for (final npc in currentNpcs) {
      final hash = _calculateHash(npc);
      final lastHash = _lastNpcHashes[npc.id];

      if (lastHash == null || lastHash != hash) {
        changedNpcs.add(npc);
        _lastNpcHashes[npc.id] = hash;
      }
    }

    // Update last known IDs
    _lastPlayerIds
      ..clear()
      ..addAll(currentPlayerIds);
    _lastNpcIds
      ..clear()
      ..addAll(currentNpcIds);

    return GameStateModel(
      players: changedPlayers,
      npcs: changedNpcs,
      removed: removed,
    );
  }

  /// Generate full state (for new clients joining)
  GameStateModel generateFullState({
    required Iterable<ComponentStateModel> currentPlayers,
    required Iterable<ComponentStateModel> currentNpcs,
  }) {
    // Update tracking
    _lastPlayerIds
      ..clear()
      ..addAll(currentPlayers.map((p) => p.id));
    _lastNpcIds
      ..clear()
      ..addAll(currentNpcs.map((n) => n.id));

    for (final player in currentPlayers) {
      _lastPlayerHashes[player.id] = _calculateHash(player);
    }
    for (final npc in currentNpcs) {
      _lastNpcHashes[npc.id] = _calculateHash(npc);
    }

    return GameStateModel(
      players: currentPlayers,
      npcs: currentNpcs,
      fullState: true,
    );
  }

  /// Clear all tracking data
  void clear() {
    _lastPlayerHashes.clear();
    _lastNpcHashes.clear();
    _lastPlayerIds.clear();
    _lastNpcIds.clear();
  }

  /// Check if there are any changes to send
  bool hasChanges(GameStateModel delta) {
    return delta.players.isNotEmpty ||
        delta.npcs.isNotEmpty ||
        delta.removed.isNotEmpty;
  }
}
