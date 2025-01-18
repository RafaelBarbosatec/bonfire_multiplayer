part of 'my_remote_enemy_bloc.dart';

sealed class MyRemoteEnemyEvent {}

class UpdateStateEvent extends MyRemoteEnemyEvent {
  final ComponentStateModel state;

  UpdateStateEvent({required this.state});
}

class RemoveSubscribe extends MyRemoteEnemyEvent {}
