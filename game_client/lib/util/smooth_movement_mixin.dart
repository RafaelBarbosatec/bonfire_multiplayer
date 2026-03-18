import 'dart:math';
import 'package:bonfire/bonfire.dart';

/// Enhanced movement interpolation with lag compensation
mixin SmoothMovementMixin on GameComponent {
  static const double _maxTeleportDistance = 64.0;
  static const double _defaultInterpolationTime = 0.06;

  Vector2? _targetPosition;
  DateTime? _lastUpdateTime;
  double _interpolationProgress = 1.0;
  late Vector2 _interpolationStart;
  late Vector2 _interpolationEnd;
  double _interpolationDuration = _defaultInterpolationTime;

  /// Smoothly move to target position with adaptive interpolation
  void smoothMoveTo(Vector2 target) {
    final now = DateTime.now();

    // Calculate optimal interpolation duration
    _calculateInterpolationDuration(now);

    final distance = position.distanceTo(target);

    // For large distances, teleport immediately (e.g., player respawn, map change)
    if (distance > _maxTeleportDistance) {
      position.setFrom(target);
      _interpolationProgress = 1.0;
      _targetPosition = target;
      _lastUpdateTime = now;
      return;
    }

    // Setup smooth interpolation
    _interpolationStart = position.clone();
    _interpolationEnd = target.clone();
    _interpolationProgress = 0.0;
    _targetPosition = target;
    _lastUpdateTime = now;
  }

  void _calculateInterpolationDuration(DateTime now) {
    if (_lastUpdateTime != null) {
      final timeBetweenUpdates =
          now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
      // Use 120% of actual update interval for smoother movement
      _interpolationDuration = (timeBetweenUpdates * 1.2).clamp(0.03, 0.12);
    } else {
      _interpolationDuration = _defaultInterpolationTime;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateInterpolation(dt);
  }

  void _updateInterpolation(double dt) {
    if (_interpolationProgress < 1.0 && _targetPosition != null) {
      _interpolationProgress += dt / _interpolationDuration;

      if (_interpolationProgress >= 1.0) {
        _interpolationProgress = 1.0;
        position.setFrom(_interpolationEnd);
      } else {
        // Use easing for smoother movement
        final easedProgress = _easeOutCubic(_interpolationProgress);
        final lerpedPosition = _interpolationStart +
            (_interpolationEnd - _interpolationStart) * easedProgress;
        position.setFrom(lerpedPosition);
      }
    }
  }

  /// Easing function for smoother animation
  double _easeOutCubic(double t) {
    return 1 - pow(1 - t, 3).toDouble();
  }

  /// Check if currently interpolating
  bool get isInterpolating => _interpolationProgress < 1.0;

  /// Get interpolation progress (0.0 to 1.0)
  double get interpolationProgress => _interpolationProgress;
}
