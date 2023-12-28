part of 'my_player_bloc.dart';

class MyPlayerState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;

  const MyPlayerState({
    required this.position,
    required this.direction,
  });

  MyPlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
  }) {
    return MyPlayerState(
      position: position ?? this.position,
      direction: direction,
    );
  }

  @override
  List<Object?> get props => [position, direction];
}
