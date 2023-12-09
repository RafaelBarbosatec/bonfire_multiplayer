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
      : super(MyRemotePlayerState(position: initPosition)) {
    on<UpdateStateEvent>(_onUpdateStateEvent);
    on<RemoveSbscribe>(_onRemoveSbscribe);
    _eventManager.onPlayerState(
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
        direction: _getDirectionFromName(event.state.direction),
        position: event.state.position.toVector2(),
      ),
    );
  }

  FutureOr<void> _onRemoveSbscribe(
    RemoveSbscribe event,
    Emitter<MyRemotePlayerState> emit,
  ) {
    _eventManager.removeOnPlayerState(playerId);
  }

  Direction? _getDirectionFromName(String? direction) {
    if (direction != null) {
      return Direction.values.firstWhere(
        (element) => element.name == direction,
      );
    }
    return null;
  }
}
