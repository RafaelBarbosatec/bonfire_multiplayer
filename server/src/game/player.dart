// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import '../core/game_component.dart';
import '../infrastructure/websocket/polo_websocket.dart';
import '../util/geometry.dart';

class Player extends GameComponent {
  Player({
    required this.state,
    required this.client,
  }) {
    _confMove();
  }

  final PlayerStateModel state;
  final PoloClient client;

  String get id => state.id;

  Rect _getRect(GamePosition position) => Rect.fromLTWH(
        position.x,
        position.y,
        0, // TODO adds size collision
        0, // TODO adds size collision
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
      parent?.requestUpdate();
    } else {
      if (!sendedIdle) {
        sendedIdle = true;
        parent?.requestUpdate();
      }
    }
  }

  void _updatePosition(double dt) {
    final newPosition = state.position.clone();

    if (state.direction == 'left') {
      newPosition.x -= dt * 100;
    }
    if (state.direction == 'right') {
      newPosition.x += dt * 100;
    }

    if (state.direction == 'up') {
      newPosition.y -= dt * 100;
    }
    if (state.direction == 'down') {
      newPosition.y += dt * 100;
    }
    if (!checkCollisionWithParent(_getRect(newPosition))) {
      state.position = newPosition;
    } else {
      state.direction = null;
    }
  }
}
