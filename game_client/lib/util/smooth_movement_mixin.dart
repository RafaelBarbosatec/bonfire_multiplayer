import 'dart:math';

import 'package:bonfire/bonfire.dart';

import 'vector_utils.dart';

/// Smooth interpolation for remote entities using a render buffer.
///
/// Server states are pushed into a small buffer and the entity is rendered
/// behind the latest state by an ADAPTIVE delay. This is the standard
/// technique for networked movement: instead of restarting an interpolation
/// every time a state arrives (which stutters under jitter), we always
/// interpolate between two buffered states on a fixed timeline.
///
/// Why adaptive (and not a fixed 80ms like the first version)?
/// The render delay must be LARGER than the age of a state when it arrives
/// (one-way network latency + processing). If it is smaller, the render
/// cursor passes the newest buffered state before the next one arrives and
/// the entity freezes at the latest position until it does — reading as
/// "travadas / pequenos saltos" while walking. On localhost the latency is
/// ~0 so a fixed small delay works; on a real server it does not. The delay
/// is therefore measured from the server timestamp of each state and adapted
/// continuously. As a second line of defence, when the buffer still runs
/// dry mid-walk the entity extrapolates for a short window instead of
/// freezing, keeping the walk fluid.
mixin SmoothMovementMixin on GameComponent {
  // Snap thresholds
  static const double _teleportDistance =
      128.0; // real teleports (respawn, map change): snap instantly
  static const double _minInterpolateDistance = 0.5; // ignore tiny differences

  // Render buffer configuration
  static const Duration _minRenderDelay = Duration(milliseconds: 60);
  static const Duration _maxRenderDelay = Duration(milliseconds: 220);

  /// Extra time kept above the measured arrival age so the buffer absorbs the
  /// server's inter-state gap (states are produced every ~30-60ms while
  /// moving) instead of running dry between arrivals.
  static const Duration _renderHeadroom = Duration(milliseconds: 60);
  static const double _delayAdaptRate = 0.12; // EMA smoothing factor
  static const int _maxBufferSize = 30; // ~1.5s of states at 20Hz (safety)
  static const double _idleSnapDuration = 0.06; // short correction on stop (60ms)
  static const Duration _maxExtrapolation = Duration(milliseconds: 150);

  final List<_BufferedState> _buffer = [];

  Duration _renderDelay = const Duration(milliseconds: 80);

  /// Whether the entity is mid-walk (last state had a direction). When true
  /// and the buffer runs dry we glide instead of freezing.
  bool _moving = false;

  // Short dedicated interpolation used when the entity becomes idle
  Vector2? _snapStart;
  Vector2? _snapTarget;
  double _snapProgress = 0.0;

  /// Current render delay (how far behind the latest state we render).
  Duration get renderDelay => _renderDelay;

  /// Adds a new authoritative position from the server.
  ///
  /// [serverTime] is the local-time equivalent of the server timestamp at
  /// which the position is true. When provided, the render buffer
  /// interpolates on the SERVER timeline (immune to network jitter) and the
  /// render delay adapts to the measured arrival age; otherwise it falls
  /// back to the arrival time.
  void smoothMoveTo(
    Vector2 target, {
    bool snapWhenIdle = false,
    DateTime? serverTime,
  }) {
    if (serverTime != null) {
      _adaptRenderDelay(serverTime);
    }

    final distance = position.distanceTo(target);

    // Ignore negligible differences (reduces jitter)
    if (distance < _minInterpolateDistance) {
      return;
    }

    // Real teleport (respawn, map change): snap instantly, no animation
    if (distance > _teleportDistance) {
      _moving = false;
      _buffer.clear();
      _snapTarget = null;
      position.setFrom(target);
      return;
    }

    if (snapWhenIdle) {
      // Short smooth correction (60ms) instead of a long MoveEffect —
      // long corrections are what users perceive as "muita correção".
      _moving = false;
      _buffer.clear();
      _snapStart = position.clone();
      _snapTarget = target.clone();
      _snapProgress = 0.0;
      return;
    }

    // Moving: push into the render buffer (single source of truth)
    _moving = true;
    _snapTarget = null;
    _buffer.add(
      _BufferedState(target.clone(), serverTime ?? DateTime.now()),
    );
    if (_buffer.length > _maxBufferSize) {
      _buffer.removeAt(0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateInterpolation(dt);
  }

  /// Tracks the age of arriving states (one-way latency) and keeps the render
  /// delay just above it, so the buffer always has states ahead of the render
  /// cursor. EMA-smoothed to avoid reacting to a single outlier.
  void _adaptRenderDelay(DateTime serverTime) {
    final age = DateTime.now().difference(serverTime);
    if (age < Duration.zero) {
      return; // clock not synced yet; keep current delay
    }
    final targetUs =
        (age + _renderHeadroom).inMicroseconds.toDouble();
    final currentUs = _renderDelay.inMicroseconds.toDouble();
    var nextUs =
        (currentUs + (targetUs - currentUs) * _delayAdaptRate).round();
    if (nextUs < _minRenderDelay.inMicroseconds) {
      nextUs = _minRenderDelay.inMicroseconds;
    } else if (nextUs > _maxRenderDelay.inMicroseconds) {
      nextUs = _maxRenderDelay.inMicroseconds;
    }
    _renderDelay = Duration(microseconds: nextUs);
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

    final renderTime = DateTime.now().subtract(_renderDelay);

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
        position.setFrom(VectorUtils.lerp(a.position, b.position, t));

        // Drop states that are now behind the render time (keep at least 2)
        while (_buffer.length > 2 && _buffer[1].time.isBefore(renderTime)) {
          _buffer.removeAt(0);
        }
        return;
      }
    }

    // Render time newer than everything buffered. Instead of freezing at the
    // latest state (which reads as stutter/small jumps whenever a frame is
    // delayed on the network), keep gliding using the last measured velocity
    // for a short window until the next state arrives.
    if (_moving && _buffer.length >= 2) {
      _extrapolatePastBuffer(renderTime);
    } else {
      position.setFrom(_buffer.last.position);
    }
  }

  /// Continues the last known velocity for a bounded time when the buffer has
  /// run dry mid-walk. The next state resumes the normal interpolation, and
  /// because the server moves at (near) constant speed while walking, the
  /// extrapolation error is tiny.
  void _extrapolatePastBuffer(DateTime renderTime) {
    final a = _buffer[_buffer.length - 2];
    final b = _buffer.last;
    final span = b.time.difference(a.time);
    if (span <= Duration.zero) {
      position.setFrom(b.position);
      return;
    }
    final elapsed = renderTime.difference(b.time);
    if (elapsed <= Duration.zero || elapsed > _maxExtrapolation) {
      position.setFrom(b.position);
      return;
    }
    final spanSeconds =
        span.inMicroseconds / Duration.microsecondsPerSecond;
    final elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final vx = (b.position.x - a.position.x) / spanSeconds;
    final vy = (b.position.y - a.position.y) / spanSeconds;
    position.setFrom(
      b.position + Vector2(vx * elapsedSeconds, vy * elapsedSeconds),
    );
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
