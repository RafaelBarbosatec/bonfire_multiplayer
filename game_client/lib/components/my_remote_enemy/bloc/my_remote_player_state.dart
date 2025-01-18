// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_enemy_bloc.dart';

class MyRemoteEnemyState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum lastDirection;

  const MyRemoteEnemyState({
    required this.position,
    this.direction,
    required this.lastDirection,
  });

  MyRemoteEnemyState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
  }) {
    return MyRemoteEnemyState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
    );
  }

  @override
  List<Object?> get props => [position, direction, lastDirection];
}
