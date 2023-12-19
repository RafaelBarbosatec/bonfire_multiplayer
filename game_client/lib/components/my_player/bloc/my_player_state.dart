part of 'my_player_bloc.dart';

class MyPlayerState extends Equatable {
  final Vector2 position;

  const MyPlayerState({required this.position});

  MyPlayerState copyWith({
    Vector2? position,
  }) {
    return MyPlayerState(
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [position];
}
