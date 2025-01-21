// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.connected = false,
    this.skinSelected = PlayerSkin.boy,
    this.ackEvent,
    this.error = false,
  });

  final bool connected;
  final bool error;
  final JoinMapEvent? ackEvent;
  final PlayerSkin skinSelected;

  @override
  List<Object?> get props => [connected, ackEvent, skinSelected, error];

  HomeState copyWith({
    bool? connected,
    JoinMapEvent? ackEvent,
    PlayerSkin? skinSelected,
    bool? error,
  }) {
    return HomeState(
      connected: connected ?? this.connected,
      ackEvent: ackEvent,
      skinSelected: skinSelected ?? this.skinSelected,
      error: error ?? false,
    );
  }
}
