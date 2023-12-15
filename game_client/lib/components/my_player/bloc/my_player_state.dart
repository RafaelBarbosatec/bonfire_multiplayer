part of 'my_player_bloc.dart';

class MyPlayerState {}

class MoveValidationState extends MyPlayerState {
  MoveValidationState({
    required this.isValid,
    required this.position,
    required this.direction,
    required this.event,
  });

  final bool isValid;
  final Vector2 position;
  final Direction? direction;
  final UpdateMoveStateEvent event;
}
