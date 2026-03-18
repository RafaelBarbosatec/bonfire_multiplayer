import 'dart:math';

import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

/// Enhanced movement prediction and lag compensation for server-side components
mixin LagCompensationMixin on PositionedGameComponent {
  static const double _maxLagCompensationMs = 200; // 200ms max lag compensation

  final List<StateSnapshot> _stateHistory = [];

  /// Add current state to history for lag compensation
  void addStateSnapshot() {
    final now = DateTime.now();
    _stateHistory.add(
      StateSnapshot(
        position: position.clone(),
        timestamp: now.millisecondsSinceEpoch,
      ),
    );

    // Keep only last 1 second of history
    final cutoffTime = now.millisecondsSinceEpoch - 1000;
    _stateHistory.removeWhere((snapshot) => snapshot.timestamp < cutoffTime);
  }

  /// Get position at specific timestamp for lag compensation
  GameVector getPositionAtTime(int timestamp) {
    if (_stateHistory.isEmpty) return position;

    // Find closest snapshots
    StateSnapshot? before;
    StateSnapshot? after;

    for (final snapshot in _stateHistory) {
      if (snapshot.timestamp <= timestamp) {
        before = snapshot;
      } else {
        after = snapshot;
        break;
      }
    }

    // If no suitable snapshots, return current position
    if (before == null) return _stateHistory.first.position;
    if (after == null) return before.position;

    // Interpolate between snapshots
    final totalTime = after.timestamp - before.timestamp;
    if (totalTime == 0) return before.position;

    final elapsed = timestamp - before.timestamp;
    final t = elapsed / totalTime;

    return GameVector(
      x: before.position.x + (after.position.x - before.position.x) * t,
      y: before.position.y + (after.position.y - before.position.y) * t,
    );
  }

  /// Process input with lag compensation
  /// Returns true if input should be processed, false if rejected
  bool processInputWithLagCompensation(
    int? inputId,
    int? clientTimestamp,
    GameVector clientPosition,
    GameVector newPosition,
  ) {
    if (inputId == null) return true; // No prediction needed

    // Apply lag compensation if timestamp is provided
    if (clientTimestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lag = now - clientTimestamp;

      // Only compensate for reasonable lag amounts
      if (lag > 0 && lag <= _maxLagCompensationMs) {
        // Rewind to client's time for validation
        final serverPosAtClientTime = getPositionAtTime(clientTimestamp);

        // Calculate the difference between what client thought vs server reality
        final positionDiff =
            _calculateDistance(clientPosition, serverPosAtClientTime);

        // If difference is too large, client is out of sync - reject input
        const maxPositionDrift = 48.0; // 3 tiles tolerance
        if (positionDiff > maxPositionDrift) {
          return false; // Reject - client too far from server state
        }

        // Validate if the movement from compensated position is reasonable
        final movementDistance =
            _calculateDistance(serverPosAtClientTime, newPosition);
        const maxMovementPerFrame = 16.0; // Max movement in single update

        if (movementDistance > maxMovementPerFrame) {
          return false; // Reject - movement too large (possible speed hack)
        }
      }
    }

    return true; // Accept input
  }

  /// Calculate distance between two positions
  double _calculateDistance(GameVector pos1, GameVector pos2) {
    final dx = pos1.x - pos2.x;
    final dy = pos1.y - pos2.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Get current lag compensation status for debugging
  Map<String, dynamic> getLagCompensationDebugInfo() {
    return {
      'historySize': _stateHistory.length,
      'oldestSnapshot': _stateHistory.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(_stateHistory.first.timestamp)
          : null,
      'newestSnapshot': _stateHistory.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(_stateHistory.last.timestamp)
          : null,
    };
  }
}

class StateSnapshot {
  StateSnapshot({
    required this.position,
    required this.timestamp,
  });
  final GameVector position;
  final int timestamp;
}
