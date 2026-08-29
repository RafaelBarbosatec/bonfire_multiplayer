// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'my_remote_player_bloc.dart';

class MyRemotePlayerState extends MoveState {
  /// Server time (µs epoch) at which the position is true. Used to
  /// interpolate on the server timeline (immune to network jitter).
  final int? serverTimestamp;

  const MyRemotePlayerState({
    required super.position,
    super.direction,
    required super.lastDirection,
    this.serverTimestamp,
  });

  MyRemotePlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    int? serverTimestamp,
  }) {
    return MyRemotePlayerState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
    );
  }

  @override
  List<Object?> get props =>
      [position, direction, lastDirection, serverTimestamp];
}
