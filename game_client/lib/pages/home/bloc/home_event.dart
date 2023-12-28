part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class ConnectEvent extends HomeEvent {}

class ConnectedEvent extends HomeEvent {}

class DisconnectedEvent extends HomeEvent {}

class EnterGameEvent extends HomeEvent {
  final JoinMapEvent ackEvent;

  const EnterGameEvent({required this.ackEvent});
}

class SelectSkinEvent extends HomeEvent {
  final PlayerSkin skin;

  const SelectSkinEvent({required this.skin});
}

class JoinGameEvent extends HomeEvent {
  final String name;

  const JoinGameEvent({
    required this.name,
  });
}

class DisposeEvent extends HomeEvent {}
