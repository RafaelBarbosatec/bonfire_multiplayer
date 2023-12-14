part of 'my_player_bloc.dart';

sealed class MyPlayerEvent {}

// When direction is null it's consider idle state.
class UpdateMoveStateEvent extends MyPlayerEvent {
  final Vector2 position;
  final Direction? direction;

  UpdateMoveStateEvent({required this.position, this.direction});
}

class MoveResponseEvent extends MyPlayerEvent {
  final bool success;
  final String? errorMessage;
  final Vector2? position; // Add this line

  MoveResponseEvent({required this.success, this.errorMessage, this.position}); // Modify this line
}
