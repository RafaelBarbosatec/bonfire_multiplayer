part of 'my_player_bloc.dart';

class MyPlayerState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum lastDirection;
  final int? lastInputId; // For client-side prediction acknowledgment

  const MyPlayerState({
    required this.position,
    required this.direction,
    required this.lastDirection,
    this.lastInputId,
  });

  MyPlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    int? lastInputId,
  }) {
    return MyPlayerState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
      lastInputId: lastInputId ?? this.lastInputId,
    );
  }

  @override
  List<Object?> get props => [position, direction, lastDirection, lastInputId];
}
