// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_enemy_bloc.dart';

class MyRemoteEnemyState extends MoveState {
  /// Server time (µs epoch) at which the position is true. Used to
  /// interpolate on the server timeline (immune to network jitter).
  final int? serverTimestamp;

  /// Server-authoritative remaining life (null until the first delta
  /// arrives). Drives the enemy's life bar.
  final int? life;

  const MyRemoteEnemyState({
    required super.position,
    super.direction,
    required super.lastDirection,
    this.serverTimestamp,
    this.life,
  });

  MyRemoteEnemyState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    int? serverTimestamp,
    int? life,
  }) {
    return MyRemoteEnemyState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      life: life ?? this.life,
    );
  }

  @override
  List<Object?> get props => [
    position,
    direction,
    lastDirection,
    serverTimestamp,
    life,
  ];
}
