// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import '../core/game_component.dart';
import '../infrastructure/websocket/polo_websocket.dart';
import '../util/geometry.dart';

class Player extends GameComponent {
  static const speed = 80;
  Player({
    required this.state,
    required this.client,
  }) {
    _confMove();
  }

  final ComponentStateModel state;
  final PoloClient client;

  String get id => state.id;

  Rect _getRect(GameVector position) => Rect.fromLTWH(
        position.x + 8,
        position.y + 16,
        16, // TODO adds size collision
        16, // TODO adds size collision
      );

  void _confMove() {
    client.onEvent<MoveEvent>(
      EventType.PLAYER_MOVE.name,
      (data) {
        state.direction = data.direction;
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
    final newPosition = state.position.clone();
    final displacement = dt * speed;

    if (state.direction == 'left') {
      newPosition.x -= displacement;
    }
    if (state.direction == 'right') {
      newPosition.x += displacement;
    }

    if (state.direction == 'up') {
      newPosition.y -= displacement;
    }
    if (state.direction == 'down') {
      newPosition.y += displacement;
    }
    if (!checkCollisionWithParent(_getRect(newPosition))) {
      state.position = newPosition;
    } else {
      state.direction = null;
    }
  }
}
