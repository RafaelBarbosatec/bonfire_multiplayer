// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import '../../core/game_player.dart';
import '../../core/geometry/rectangle.dart';
import '../../core/mixins/block_movement_contact.dart';
import '../../core/mixins/contact_sensor.dart';
import '../../core/mixins/map_ref.dart';
import '../../infrastructure/websocket/websocket_provider.dart';

class Player extends GamePlayer
    with ContactSensor, MapRef, BlockMovementOnContact {
  Player({
    required super.state,
    required this.client,
  }) {
    _listenMove();
    setupGameSensor(
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
    client.on<MoveEvent>(
      EventType.MOVE.name,
      (data) {
        if (data.mapId == map.id) {
          moveDirection = data.direction;
        }
      },
    );
  }

  @override
  bool checkContact(ContactSensor other) {
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
