// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire_server/bonfire_server.dart';
import 'package:shared_events/shared_events.dart';

import '../../infrastructure/websocket/websocket_provider.dart';

class Player extends GamePlayer
    with Collision, MapRef, BlockMovementOnCollision {
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
            moveDirection = data.direction;
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

  @override
  bool checkContact(Collision other) {
    if (other is Player) {
      return false;
    }
    return super.checkContact(other);
  }

  @override
  void onUpdate(double dt) {
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
