import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/name_bottom.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

class MyPlayer extends SimplePlayer
    with
        BlockMovementCollision,
        WithNameBottom,
        BonfireBlocListenable<MyPlayerBloc, MyPlayerState> {
  JoystickMoveDirectional? _joystickDirectional;
  async.Timer? _correctionTimer;

  // Thresholds for position correction
  static const double _idleCorrectionThreshold =
      8.0; // Small threshold when idle
  static const double _emergencyThreshold = 64.0; // Force correction if way off

  // Track if we're currently doing a correction
  bool _isCorrectingPosition = false;

  MyPlayer({
    required ComponentStateModel state,
    required GameEventManager eventManager,
    required String mapId,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(
            PlayerSkin.fromName(state.properties['skin']).path,
          ),
          initDirection: state.lastDirection?.toDirection() ?? Direction.down,
          position: state.position.toVector2(),
        ) {
    name = state.name;
    speed = state.speed;
    bloc = MyPlayerBloc(
      eventManager,
      state,
      mapId,
    );
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (isMounted && _joystickDirectional != event.directional) {
      _joystickDirectional = event.directional;
// If not visible, snap immediately
      if (!isVisible) {
        position.setFrom(bloc.state.position);
        return;
      }
      // Cancel any pending correction when player starts moving
      _cancelCorrection();

      _sendMove();
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onNewState(MyPlayerState state) {
    final serverPosition = state.position;

    final distance = position.distanceTo(serverPosition);
    final isMoving = state.direction != null;

    // Emergency correction: player is way too far from server position
    // This handles teleports, respawns, or severe desync
    if (distance > _emergencyThreshold) {
      _cancelCorrection();
      position.setFrom(serverPosition);
      return;
    }

    if (isMoving) {
      // Player is moving - don't correct to avoid "stuttering"
      // Trust client-side movement, server will correct when player stops
      _cancelCorrection();
    } else {
      // Player stopped (server says direction is null)
      // Schedule a correction after a small delay to ensure player really stopped
      _scheduleIdleCorrection(serverPosition);
    }

    super.onNewState(state);
  }

  void _scheduleIdleCorrection(Vector2 serverPosition) {
    // Cancel any existing timer
    _correctionTimer?.cancel();

    // Wait a bit to make sure player really stopped
    // This prevents corrections during brief pauses in movement
    _correctionTimer = async.Timer(
      const Duration(milliseconds: 200),
      () {
        // Double check we're still supposed to be idle
        if (_joystickDirectional == JoystickMoveDirectional.IDLE) {
          _performIdleCorrection(serverPosition);
        }
      },
    );
  }

  void _performIdleCorrection(Vector2 targetPosition) {
    final distance = position.distanceTo(targetPosition);

    // Only correct if deviation is noticeable
    if (distance < _idleCorrectionThreshold) {
      return;
    }

    // Remove any existing MoveEffects to prevent conflicts
    _removeExistingMoveEffects();

    _isCorrectingPosition = true;

    // Smooth correction with appropriate duration based on distance
    // Shorter distance = faster correction
    final duration = (distance / 100).clamp(0.15, 0.35);

    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: duration, curve: Curves.easeOut),
        onComplete: () {
          _isCorrectingPosition = false;
        },
      ),
    );
  }

  void _removeExistingMoveEffects() {
    // Remove all MoveEffects to prevent stacking
    children.whereType<MoveEffect>().toList().forEach((effect) {
      effect.removeFromParent();
    });
  }

  void _cancelCorrection() {
    _correctionTimer?.cancel();
    _correctionTimer = null;

    if (_isCorrectingPosition) {
      _removeExistingMoveEffects();
      _isCorrectingPosition = false;
    }
  }

  void _sendMove() {
    bloc.add(
      UpdateMoveStateEvent(
        position: position,
        direction: _joystickDirectional?.toMoveDirection(),
      ),
    );
  }

  @override
  void onRemove() {
    _cancelCorrection();
    bloc.close();
    super.onRemove();
  }

  @override
  Future<void> onLoad() {
    // adds Rectangle collision
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
      ),
    );
    return super.onLoad();
  }
}
