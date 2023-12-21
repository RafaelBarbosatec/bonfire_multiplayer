part of 'my_player_bloc.dart';

class MyPlayerState extends Equatable {
  final Vector2 position;
  final Direction? direction;

  const MyPlayerState({required this.position, required this.direction});

  MyPlayerState copyWith({
    Vector2? position,
    Direction? direction,
  }) {
    return MyPlayerState(
      position: position ?? this.position,
      direction: direction,
    );
  }

  @override
  List<Object?> get props => [position, direction];
}
