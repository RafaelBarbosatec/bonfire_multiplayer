// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../util/geometry.dart';
import 'game_component.dart';

class GameMap extends GameComponent {
  final String path;

  GameMap({
    required this.path,
  });

  @override
  bool checkCollisionWithParent(Rect rect) {
    print('check collision');
    return super.checkCollisionWithParent(rect);
  }
}
