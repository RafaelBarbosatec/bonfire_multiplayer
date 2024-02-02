import 'package:shared_events/shared_events.dart';

abstract class Shape {
  Shape(GameVector? position) : _position = position ?? GameVector.zero();
  GameVector _position;

  // ignore: unnecessary_getters_setters
  set position(GameVector value) {
    _position = value;
  }

  // ignore: unnecessary_getters_setters
  GameVector get position => _position;
}
