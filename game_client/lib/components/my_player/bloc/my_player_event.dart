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

  UpdatePlayerPositionEvent({required this.position, required this.direction});
}

class DisposeEvent extends MyPlayerEvent {}
