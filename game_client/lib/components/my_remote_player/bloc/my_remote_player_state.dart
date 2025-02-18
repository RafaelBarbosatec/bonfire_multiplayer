// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_player_bloc.dart';

class MyRemotePlayerState extends MoveState {

  const MyRemotePlayerState({
    required super.position,
    super.direction,
    required super.lastDirection,
  });

  MyRemotePlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
  }) {
    return MyRemotePlayerState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
    );
  }

  @override
  List<Object?> get props => [position, direction, lastDirection];
}
