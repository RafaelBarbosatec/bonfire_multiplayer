import 'package:bonfire/bonfire.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_events/shared_events.dart';

class MoveState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum lastDirection;

  const MoveState({
    required this.position,
    this.direction,
    required this.lastDirection,
  });

  @override
  List<Object?> get props => [position, direction, lastDirection];
}
