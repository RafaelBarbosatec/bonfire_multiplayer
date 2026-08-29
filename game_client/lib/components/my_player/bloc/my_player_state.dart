part of 'my_player_bloc.dart';

class MyPlayerState extends Equatable {
  final Vector2 position;
  final MoveDirectionEnum? direction;
  final MoveDirectionEnum lastDirection;
  final int? lastInputId; // For client-side prediction acknowledgment

  /// Whether there are still inputs not yet confirmed by the server.
  /// While true, the client should NOT correct its position (the server is
  /// simply behind — correcting now would cause a visible "pull").
  final bool hasPendingInputs;

  const MyPlayerState({
    required this.position,
    required this.direction,
    required this.lastDirection,
    this.lastInputId,
    this.hasPendingInputs = false,
  });

  MyPlayerState copyWith({
    Vector2? position,
    MoveDirectionEnum? direction,
    MoveDirectionEnum? lastDirection,
    int? lastInputId,
    bool? hasPendingInputs,
  }) {
    return MyPlayerState(
      position: position ?? this.position,
      direction: direction,
      lastDirection: lastDirection ?? this.lastDirection,
      lastInputId: lastInputId ?? this.lastInputId,
      hasPendingInputs: hasPendingInputs ?? this.hasPendingInputs,
    );
  }

  @override
  List<Object?> get props => [
        position,
        direction,
        lastDirection,
        lastInputId,
        hasPendingInputs,
      ];
}
