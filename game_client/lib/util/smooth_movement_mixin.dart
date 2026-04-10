import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Enhanced movement interpolation with lag compensation for remote entities.
/// Provides smooth position updates between server state updates.
mixin SmoothMovementMixin on GameComponent {
  // Distance thresholds
  static const double _teleportDistance =
      64.0; // Snap immediately (respawn, map change)
  static const double _minInterpolateDistance = 2.0; // Ignore tiny differences

  // Interpolation timing
  static const double _defaultInterpolationTime = 0.5;
  static const double _minInterpolationTime = 0.03;
  static const double _maxInterpolationTime = 0.12;

  double get distanceToInterpolate =>
      8.0; // Minimum distance to apply interpolation

  Vector2? _targetPosition;
  DateTime? _lastUpdateTime;
  double _interpolationProgress = 1.0;
  Vector2 _interpolationStart = Vector2.zero();
  Vector2 _interpolationEnd = Vector2.zero();
  double _interpolationDuration = _defaultInterpolationTime;

  /// Smoothly move to target position with adaptive interpolation.
  ///
  /// [target] - The server position to move towards
  /// [snapWhenIdle] - If true, snaps directly to position (used when entity stops)
  void smoothMoveTo(Vector2 target, {bool snapWhenIdle = false}) {
    final now = DateTime.now();
    final distance = position.distanceTo(target);

    // Skip if difference is negligible (reduces jitter)
    if (distance < _minInterpolateDistance && !snapWhenIdle) {
      _lastUpdateTime = now;
      return;
    }

    // Snap immediately for: teleports, respawns, or when entity is idle
    if (distance > _teleportDistance || snapWhenIdle) {
      _snapToPosition(target, now);
      return;
    }

    // Calculate optimal interpolation duration based on update frequency
    _calculateInterpolationDuration(now);

    // Setup smooth interpolation
    _interpolationStart = position.clone();
    _interpolationEnd = target.clone();
    _interpolationProgress = 0.0;
    _targetPosition = target;
    _lastUpdateTime = now;
  }

  void _snapToPosition(Vector2 target, DateTime now) {
    final distance = position.distanceTo(target);
    // Smooth correction with appropriate duration based on distance
    // Shorter distance = faster correction
    final duration = (distance / 100).clamp(0.15, 0.35);

    add(
      MoveEffect.to(
        target,
        EffectController(duration: duration, curve: Curves.easeOut),
      ),
    );
    _interpolationProgress = 1.0;
    _targetPosition = target;
    _lastUpdateTime = now;
  }

  void _calculateInterpolationDuration(DateTime now) {
    if (_lastUpdateTime != null) {
      final timeBetweenUpdates =
          now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
      // Use 120% of actual update interval for overlap (smoother movement)
      _interpolationDuration = (timeBetweenUpdates * 1.2).clamp(
        _minInterpolationTime,
        _maxInterpolationTime,
      );
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
    if (_interpolationProgress >= 1.0 || _targetPosition == null) {
      return;
    }

    _interpolationProgress += dt / _interpolationDuration;
    if (_interpolationProgress >= 1.0) {
      _interpolationProgress = 1.0;
    } else {
      // Cubic easing for natural movement
      final easedProgress = _easeOutCubic(_interpolationProgress);
      final newPosition = _interpolationStart +
          (_interpolationEnd - _interpolationStart) * easedProgress;
      final distance = position.distanceTo(newPosition);

      if (distance > distanceToInterpolate) {
        position.setFrom(
          newPosition,
        );
      }
    }
  }

  double _easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();

  /// Check if currently interpolating
  bool get isInterpolating => _interpolationProgress < 1.0;
}
