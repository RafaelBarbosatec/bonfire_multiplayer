import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_remote_player_event.dart';
part 'my_remote_player_state.dart';

class MyRemotePlayerBloc
    extends Bloc<MyRemotePlayerEvent, MyRemotePlayerState> {
  final GameEventManager _eventManager;
  final String playerId;
  final Vector2 initPosition;
  MyRemotePlayerBloc(this.playerId, this.initPosition, this._eventManager)
      : super(MyRemotePlayerState(
          position: initPosition,
          lastDirection: MoveDirectionEnum.down,
        )) {
    on<UpdateStateEvent>(_onUpdateStateEvent);
    on<RemoveSbscribe>(_onRemoveSubscribe);
    _eventManager.onSpecificPlayerState(
      playerId,
      _onPlayerState,
    );
  }

  void _onPlayerState(state) => add(UpdateStateEvent(state: state));

  FutureOr<void> _onUpdateStateEvent(
    UpdateStateEvent event,
    Emitter<MyRemotePlayerState> emit,
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
    RemoveSbscribe event,
    Emitter<MyRemotePlayerState> emit,
  ) {
    _eventManager.removeOnSpecificPlayerState(playerId);
  }
}
