// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_player_bloc.dart';

class MyRemotePlayerState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;

  const MyRemotePlayerState({
    required this.position,
    this.direction,
  });

  MyRemotePlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
  }) {
    return MyRemotePlayerState(
      position: position ?? this.position,
      direction: direction,
    );
  }

  @override
  List<Object?> get props => [position, direction];
}
