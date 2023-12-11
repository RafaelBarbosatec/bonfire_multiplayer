part of 'my_remote_player_bloc.dart';

sealed class MyRemotePlayerEvent {}

class UpdateStateEvent extends MyRemotePlayerEvent {
  final PlayerStateModel state;

  UpdateStateEvent({required this.state});
}

class RemoveSbscribe extends MyRemotePlayerEvent {}
