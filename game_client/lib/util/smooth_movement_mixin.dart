import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Smooth interpolation for remote entities using a render buffer.
///
/// Server states are pushed into a small buffer and the entity is rendered
/// at a fixed delay ([renderDelay]) behind the latest state. This is the
/// standard technique for networked movement: instead of restarting an
/// interpolation every time a state arrives (which stutters under jitter),
/// we always interpolate between two buffered states on a fixed timeline.
mixin SmoothMovementMixin on GameComponent {
  // Snap thresholds
  static const double _teleportDistance =
      128.0; // real teleports (respawn, map change): snap instantly
  static const double _minInterpolateDistance = 0.5; // ignore tiny differences

  // Render buffer configuration
  static const Duration renderDelay =
      Duration(milliseconds: 80); // fixed render delay (jitter buffer)
  static const int _maxBufferSize = 30; // ~1.5s of states at 20Hz (safety)
  static const double _idleSnapDuration = 0.06; // short correction on stop (60ms)

  final List<_BufferedState> _buffer = [];

  // Short dedicated interpolation used when the entity becomes idle
  Vector2? _snapStart;
  Vector2? _snapTarget;
  double _snapProgress = 0.0;

  /// Adds a new authoritative position from the server.
  void smoothMoveTo(Vector2 target, {bool snapWhenIdle = false}) {
    final now = DateTime.now();
    final distance = position.distanceTo(target);

    // Ignore negligible differences (reduces jitter)
    if (distance < _minInterpolateDistance) {
      return;
    }

    // Real teleport (respawn, map change): snap instantly, no animation
    if (distance > _teleportDistance) {
      _buffer.clear();
      _snapTarget = null;
      position.setFrom(target);
      return;
    }

    if (snapWhenIdle) {
      // Short smooth correction (60ms) instead of a long MoveEffect —
      // long corrections are what users perceive as "muita correção".
      _buffer.clear();
      _snapStart = position.clone();
      _snapTarget = target.clone();
      _snapProgress = 0.0;
      return;
    }

    // Moving: push into the render buffer (single source of truth)
    _snapTarget = null;
    _buffer.add(_BufferedState(target.clone(), now));
    if (_buffer.length > _maxBufferSize) {
      _buffer.removeAt(0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateInterpolation(dt);
  }

  void _updateInterpolation(double dt) {
    // 1) Short idle snap in progress
    if (_snapTarget != null) {
      _snapProgress += dt / _idleSnapDuration;
      if (_snapProgress >= 1.0) {
        position.setFrom(_snapTarget!);
        _snapTarget = null;
      } else {
        final eased = _easeOutCubic(_snapProgress);
        position.setFrom(_snapStart! + (_snapTarget! - _snapStart!) * eased);
      }
      return;
    }

    if (_buffer.isEmpty) return;

    final renderTime = DateTime.now().subtract(renderDelay);

    // Render time older than everything buffered: hold the oldest state
    if (!renderTime.isAfter(_buffer.first.time)) {
      position.setFrom(_buffer.first.position);
      return;
    }

    // Interpolate between the two buffered states that surround renderTime
    for (var i = 0; i < _buffer.length - 1; i++) {
      final a = _buffer[i];
      final b = _buffer[i + 1];
      if (!renderTime.isBefore(a.time) && !renderTime.isAfter(b.time)) {
        final span = b.time.difference(a.time).inMicroseconds;
        final t = span == 0
            ? 0.0
            : (renderTime.difference(a.time).inMicroseconds / span)
                .clamp(0.0, 1.0);
        position.setFrom(Vector2.lerp(a.position, b.position, t));

        // Drop states that are now behind the render time (keep at least 2)
        while (_buffer.length > 2 && _buffer[1].time.isBefore(renderTime)) {
          _buffer.removeAt(0);
        }
        return;
      }
    }

    // Render time newer than everything buffered: hold the latest state
    position.setFrom(_buffer.last.position);
  }

  double _easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();

  /// Whether the entity is currently interpolating/snapping.
  bool get isInterpolating => _snapTarget != null || _buffer.isNotEmpty;
}

class _BufferedState {
  _BufferedState(this.position, this.time);
  final Vector2 position;
  final DateTime time;
}
