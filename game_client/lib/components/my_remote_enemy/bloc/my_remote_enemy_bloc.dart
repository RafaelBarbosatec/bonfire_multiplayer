import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_remote_player_event.dart';
part 'my_remote_player_state.dart';

class MyRemoteEnemyBloc
    extends Bloc<MyRemoteEnemyEvent, MyRemoteEnemyState> {
  final GameEventManager _eventManager;
  final String playerId;
  final Vector2 initPosition;
  MyRemoteEnemyBloc(this.playerId, this.initPosition, this._eventManager)
      : super(MyRemoteEnemyState(
          position: initPosition,
          lastDirection: MoveDirectionEnum.down,
        )) {
    on<UpdateStateEvent>(_onUpdateStateEvent);
    on<RemoveSubscribe>(_onRemoveSubscribe);
    _eventManager.onSpecificEnemyState(
      playerId,
      _onStateListener,
    );
  }

  void _onStateListener(state) => add(UpdateStateEvent(state: state));

  FutureOr<void> _onUpdateStateEvent(
    UpdateStateEvent event,
    Emitter<MyRemoteEnemyState> emit,
  ) {
    emit(
      state.copyWith(
        direction: event.state.direction,
        position: event.state.position.toVector2(),
        lastDirection: event.state.lastDirection,
      ),
    );
  }

  FutureOr<void> _onRemoveSubscribe(
    RemoveSubscribe event,
    Emitter<MyRemoteEnemyState> emit,
  ) {
    _eventManager.removeOnSpecificEnemyState(playerId);
  }
}
