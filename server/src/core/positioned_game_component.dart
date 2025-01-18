// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';

import 'game_component.dart';

abstract class PositionedGameComponent extends GameComponent {
  GameVector position;
  GameVector size;
 

  PositionedGameComponent({
    super.components,
    GameVector? position,
    GameVector? size,
  })  : position = position ?? GameVector.zero(),
        size = size ?? GameVector.zero();
}
