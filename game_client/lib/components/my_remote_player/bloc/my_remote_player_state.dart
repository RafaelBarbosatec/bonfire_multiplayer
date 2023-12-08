// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_player_bloc.dart';

class MyRemotePlayerState {
  final Vector2 position;
  final Direction? direction;

  MyRemotePlayerState({
    required this.position,
    this.direction,
  });

  MyRemotePlayerState copyWith({
    Vector2? position,
    Direction? direction,
  }) {
    return MyRemotePlayerState(
      position: position ?? this.position,
      direction: direction ?? this.direction,
    );
  }
}
