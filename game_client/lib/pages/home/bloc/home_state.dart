// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.connected = false,
    this.skinSelected = PayerSkin.boy,
    this.ackEvent,
  });

  final bool connected;
  final JoinAckEvent? ackEvent;
  final PayerSkin skinSelected;

  @override
  List<Object?> get props => [connected, ackEvent, skinSelected];

  HomeState copyWith(
      {bool? connected, JoinAckEvent? ackEvent, PayerSkin? skinSelected}) {
    return HomeState(
      connected: connected ?? this.connected,
      ackEvent: ackEvent ?? this.ackEvent,
      skinSelected: skinSelected ?? this.skinSelected,
    );
  }
}
