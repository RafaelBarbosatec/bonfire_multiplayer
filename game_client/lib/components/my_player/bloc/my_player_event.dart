part of 'my_player_bloc.dart';

sealed class MyPlayerEvent {}

// When direction is null it's consider idle state.
class UpdateMoveStateEvent extends MyPlayerEvent {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final int? inputId; // For client-side prediction

  UpdateMoveStateEvent({required this.position, this.direction, this.inputId});
}

class UpdatePlayerPositionEvent extends MyPlayerEvent {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum? lastDirection;
  final int? lastInputId;

  UpdatePlayerPositionEvent({
    required this.position,
    required this.direction,
    required this.lastDirection,
    this.lastInputId,
  });
}
