// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.connected = false,
    this.skinSelected = PlayerSkin.boy,
    this.ackEvent,
  });

  final bool connected;
  final JoinMapEvent? ackEvent;
  final PlayerSkin skinSelected;

  @override
  List<Object?> get props => [connected, ackEvent, skinSelected];

  HomeState copyWith({
    bool? connected,
    JoinMapEvent? ackEvent,
    PlayerSkin? skinSelected,
  }) {
    return HomeState(
      connected: connected ?? this.connected,
      ackEvent: ackEvent,
      skinSelected: skinSelected ?? this.skinSelected,
    );
  }
}
