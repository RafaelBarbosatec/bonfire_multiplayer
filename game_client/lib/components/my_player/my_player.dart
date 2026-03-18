import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_bloc/bonfire_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/spritesheets/players_spritesheet.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/input_event.dart';
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
  bool sendedIdle = false;
  async.Timer? timer;
  static const double _positionThreshold =
      32; // 2 tiles threshold for correction

  // Client-side prediction variables
  final List<InputEvent> _inputBuffer = [];

  MyPlayer({
    required ComponentStateModel state,
    required GameEventManager eventManager,
    required String mapId,
  }) : super(
          size: Vector2.all(32),
          animation: PlayersSpriteSheet.simpleAnimation(
              PlayerSkin.fromName(state.properties['skin']).path),
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

      // Add input to buffer for prediction
      final inputId = _generateInputId();
      final inputEvent = InputEvent(
        id: inputId,
        direction: event.directional.toMoveDirection(),
        timestamp: DateTime.now(),
        position: position.clone(),
      );

      _inputBuffer.add(inputEvent);
      _sendMove(inputId);

      // Perform client-side prediction
      _performClientPrediction();
    }
    timer?.cancel();
    timer = null;
    super.onJoystickChangeDirectional(event);
  }

  @override
  void onNewState(MyPlayerState state) {
    final serverPosition = state.position;

    // Process server reconciliation
    _reconcileWithServer(state);

    if (state.direction == null) {
      timer = async.Timer(
        const Duration(
          milliseconds: 250,
        ), // Increased delay for better tolerance
        () {
          // Check if local position deviated too much from server position
          final distance = position.distanceTo(serverPosition);
          if (distance > _positionThreshold / 4) {
            _smoothCorrectPosition(serverPosition);
          }
        },
      );
    } else {
      timer?.cancel();
      timer = null;
    }
    super.onNewState(state);
  }

  void _sendMove(int inputId) {
    bloc.add(
      UpdateMoveStateEvent(
        position: position,
        direction: _joystickDirectional?.toMoveDirection(),
        inputId: inputId, // Include input ID for server acknowledgment
      ),
    );
  }

  void _smoothCorrectPosition(Vector2 serverPosition) {
    // Correct position over 300ms for smoother transition
    add(
      MoveEffect.to(
        serverPosition,
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    );
  }

  int _generateInputId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _performClientPrediction() {
    // Continue moving locally while waiting for server confirmation
    // This provides immediate feedback to the player
  }

  void _reconcileWithServer(MyPlayerState serverState) {
    // Remove acknowledged inputs from buffer
    if (serverState.lastInputId != null) {
      _inputBuffer.removeWhere((input) => input.id <= serverState.lastInputId!);
    }

    // Check for significant position deviation
    final distance = position.distanceTo(serverState.position);
    if (distance > _positionThreshold) {
      // Significant deviation detected - smooth correction needed
      _smoothCorrectPosition(serverState.position);
    }
  }

  @override
  void onRemove() {
    _inputBuffer.clear();
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
