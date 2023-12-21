import 'package:bonfire/util/direction.dart';

Direction? getDirectionFromName(String? direction) {
    if (direction != null) {
      return Direction.values.firstWhere(
        (element) => element.name == direction,
      );
    }
    return null;
  }