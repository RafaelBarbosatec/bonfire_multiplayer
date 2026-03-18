// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../infrastructure/websocket/websocket_provider.dart';
import '../mixins/lag_compensation_mixin.dart';

class Player extends GamePlayer
    with Collision, MapRef, BlockMovementOnCollision, LagCompensationMixin {
  Player({
    required super.state,
    required this.client,
  }) {
    _listenMove();
    setupCollision(
      RectangleShape(
        GameVector.all(16),
        position: GameVector(x: 8, y: 16),
      ),
    );
  }

  final WebsocketClient client;

  String get id => state.id;

  MoveDirectionEnum? moveDirection;

  void _listenMove() {
    client
      ..on<MoveEvent>(
        EventType.MOVE.name,
        (data) {
          if (data.mapId == map.id) {
            // Calculate new position based on direction and speed
            final newPos = _calculateNewPosition(data.direction);

            // Process input with lag compensation validation
            if (processInputWithLagCompensation(
              data.inputId,
              data.timestamp,
              data.position, // Client's position when input was sent
              newPos, // Where client wants to move
            )) {
              // Input validated - apply movement
              moveDirection = data.direction;
            } else {
              // Input rejected - force client correction by not updating position
              // The next server state update will correct client position
              print('Lag compensation rejected input from client ${client.id}');
            }
          }
        },
      )
      ..on<MoveEvent>(
        EventType.LEAVE.name,
        (data) {
          client.cleanListener(EventType.MOVE.name);
          removeFromParent();
        },
      );
  }

  /// Calculate where player would move based on direction
  GameVector _calculateNewPosition(MoveDirectionEnum? direction) {
    if (direction == null) return GameVector(x: position.x, y: position.y);

    const moveSpeed = 2.0; // Pixels per update
    switch (direction) {
      case MoveDirectionEnum.up:
        return GameVector(x: position.x, y: position.y - moveSpeed);
      case MoveDirectionEnum.down:
        return GameVector(x: position.x, y: position.y + moveSpeed);
      case MoveDirectionEnum.left:
        return GameVector(x: position.x - moveSpeed, y: position.y);
      case MoveDirectionEnum.right:
        return GameVector(x: position.x + moveSpeed, y: position.y);
      default:
        return GameVector(x: position.x, y: position.y);
    }
  }

  @override
  bool checkContact(Collision other) {
    if (other is Player) {
      return false;
    }
    return super.checkContact(other);
  }

  @override
  void onUpdate(double dt) {
    // Add current state to history for lag compensation
    addStateSnapshot();

    if (moveDirection != null) {
      moveFromDirection(dt, moveDirection!);
    } else {
      stopMove();
    }
    super.onUpdate(dt);
  }

  @override
  void send<T>(String event, T data) {
    client.send<T>(event, data);
  }

  @override
  void stopMove() {
    moveDirection = null;
    super.stopMove();
  }
}
