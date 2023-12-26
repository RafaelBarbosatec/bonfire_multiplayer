// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import '../core/game_map.dart';
import '../core/game_player.dart';
import '../core/game_sensor.dart';
import '../infrastructure/websocket/polo_websocket.dart';

class Player extends GamePlayer with GameSensorContact {
  Player({
    required super.state,
    required this.client,
  }) {
    position = state.position;
    _confMove();
    setupGameSensor(
      GameRectangle(
        position: GameVector(x: 8, y: 16),
        size: GameVector.all(16),
      ),
    );
  }

  final PoloClient client;

  String get id => state.id;

  void _confMove() {
    client.onEvent<MoveEvent>(
      EventType.MOVE.name,
      (data) {
        if (data.map == (parent as GameMap?)?.name) {
          state.direction = data.direction;
        }
      },
    );
  }

  bool sendedIdle = false;

  @override
  void onUpdate(double dt) {
    if (state.direction != null) {
      sendedIdle = false;
      _updatePosition(dt);
      requestUpdate();
    } else {
      if (!sendedIdle) {
        sendedIdle = true;
        requestUpdate();
      }
    }
  }

  void _updatePosition(double dt) {
    final lastPosition = position.clone();
    final displacement = dt * state.speed;

    if (state.direction == 'left') {
      position.x -= displacement;
    }
    if (state.direction == 'right') {
      position.x += displacement;
    }

    if (state.direction == 'up') {
      position.y -= displacement;
    }
    if (state.direction == 'down') {
      position.y += displacement;
    }
    if (checkCollisionWithParent(this)) {
      position = lastPosition;
      state.direction = null;
    }
  }

  @override
  void send<T>(String event, T data) {
    client.send<T>(event, data);
  }
}
