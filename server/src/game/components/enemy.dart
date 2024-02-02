import '../../core/game_npc.dart';
import '../../core/mixins/vision.dart';

class Enemy extends GameNpc with Vision {
  Enemy({required super.state});
}
