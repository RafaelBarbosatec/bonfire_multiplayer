part of 'my_player_bloc.dart';

sealed class MyPlayerEvent {}

// When direction is null it's consider idle state.
class UpdateMoveStateEvent extends MyPlayerEvent {
  final Vector2 position;
  final MoveDirectionEnum? direction;

  UpdateMoveStateEvent({required this.position, this.direction});
}

class UpdatePlayerPositionEvent extends MyPlayerEvent {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum? lastDirection;

  UpdatePlayerPositionEvent({
    required this.position,
    required this.direction,
    required this.lastDirection,
  });
}

