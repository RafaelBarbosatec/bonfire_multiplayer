import 'package:shared_events/shared_events.dart';

import 'game_component.dart';

abstract class GameNpc extends GameComponent {
   GameNpc({
    required this.state,
    super.components,
    super.position,
  });

  final ComponentStateModel state;
}
