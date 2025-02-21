// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bonfire_server/src/components/game_component.dart';
import 'package:shared_events/shared_events.dart';

abstract class PositionedGameComponent extends GameComponent {
  GameVector position;
  GameVector size;

  PositionedGameComponent({
    super.components,
    GameVector? position,
    GameVector? size,
  })  : position = position ?? GameVector.zero(),
        size = size ?? GameVector.zero();

  GameVector get center => GameVector(
        x: position.x + size.x / 2,
        y: position.y + size.y / 2,
      );
}
