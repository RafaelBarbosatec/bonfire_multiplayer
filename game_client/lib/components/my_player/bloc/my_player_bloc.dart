import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  final GameEventManager _eventManager;
  final String id;
  final Vector2 initPosition;
  final String map;
  MyPlayerBloc(this._eventManager, this.id, this.initPosition, this.map)
      : super(
            MyPlayerState(position: initPosition, direction: Direction.down)) {
    on<UpdateMoveStateEvent>(_onUpdateMoveStateEvent);
    on<UpdatePlayerPositionEvent>(_onUpdatePlayerPositionEvent);
    on<DisposeEvent>(_onDisposeEvent);

    _eventManager.onSpecificPlayerState(
      id,
      _onPlayerState,
    );
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    _eventManager.send(
      EventType.MOVE.name,
      MoveEvent(
        position: event.position.toGamePosition(),
        time: DateTime.now().toIso8601String(),
        direction: event.direction?.name,
        map: map,
      ),
    );
  }

  void _onPlayerState(ComponentStateModel state) => add(
        UpdatePlayerPositionEvent(
          position: state.position.toVector2(),
          direction: getDirectionFromName(state.direction),
        ),
      );

  FutureOr<void> _onUpdatePlayerPositionEvent(
    UpdatePlayerPositionEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position, direction: event.direction));
  }

  FutureOr<void> _onDisposeEvent(
    DisposeEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    _eventManager.removeOnSpecificPlayerState(id);
  }
}
