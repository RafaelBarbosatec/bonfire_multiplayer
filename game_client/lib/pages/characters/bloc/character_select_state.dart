part of 'character_select_bloc.dart';

class CharacterSelectState extends Equatable {
  const CharacterSelectState({
    this.loading = false,
    this.creating = false,
    this.joining = false,
    this.characters = const [],
    this.error,
    this.ackEvent,
  });

  final bool loading;
  final bool creating;
  final bool joining;
  final List<CharacterSummary> characters;
  final String? error;

  /// Set when the server ACKs the join — the page navigates to the game.
  final JoinMapEvent? ackEvent;

  @override
  List<Object?> get props =>
      [loading, creating, joining, characters, error, ackEvent];

  CharacterSelectState copyWith({
    bool? loading,
    bool? creating,
    bool? joining,
    List<CharacterSummary>? characters,
    String? error,
    JoinMapEvent? ackEvent,
  }) {
    return CharacterSelectState(
      loading: loading ?? this.loading,
      creating: creating ?? this.creating,
      joining: joining ?? this.joining,
      characters: characters ?? this.characters,
      error: error,
      ackEvent: ackEvent,
    );
  }
}
